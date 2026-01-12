import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:tm/protos/app/api/api.pbgrpc.dart';
import 'package:tm/protos/protos/outbound.pb.dart';
import 'package:vx/app/outbound/outbound_repo.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/path.dart';
import 'package:vx/utils/xapi_client.dart';

/// download content from url, save them to [dest] file
Future<void> directDownloadToFile(String url, String dest,
    [http.Client? client]) async {
  logger.d("downloading $url to $dest");
  final httpClient = client ?? http.Client();
  // Create temporary file path
  final tempPath = '$dest.tmp.${DateTime.now().millisecondsSinceEpoch}';
  final tempFile = File(tempPath);
  tempFile.createSync(recursive: true);

  try {
    final request = await httpClient.send(http.Request('GET', Uri.parse(url)));
    if (request.statusCode != 200) {
      throw Exception("download failed: ${request.statusCode}");
    }
    // Open the file in write mode
    final fileStream = tempFile.openWrite();
    // Pipe the response stream to the file
    await request.stream.pipe(fileStream);
    // Close the file
    await fileStream.flush();
    await fileStream.close();

    await tempFile.rename(dest);
    logger.d("downloaded $url to $dest");
  } catch (e) {
    // Clean up temp file if anything goes wrong
    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }
    rethrow;
  } finally {
    httpClient.close();
  }
}

/// download from url, return the content
Future<Uint8List> directDownloadMemory(String url,
    [http.Client? client]) async {
  final httpClient = client ?? http.Client();
  final res = await httpClient.get(Uri.parse(url));
  return res.bodyBytes;
}

/// Download something and record traffic usage
class Downloader {
  final OutboundRepo outboundRepo;
  final XApiClient xApiClient;
  Downloader(this.outboundRepo, this.xApiClient);

  /// download from multiple urls, return the first successful one
  Future<void> downloadMulti(List<String> urls, String dest) async {
    for (var url in urls) {
      try {
        return await download(url, dest);
      } catch (e) {
        logger.d("download failed: $e");
      }
    }
    throw Exception("all download failed");
  }

  Future<void> downloadProxyFirst(String url, String dest) async {
    try {
      final handlers = await outboundRepo.getHandlers(
          usable: true, orderBySpeed1MBDesc: true);
      if (handlers.isNotEmpty) {
        final configs = handlersToHandlerConfig(handlers);
        await xApiClient.download(DownloadRequest(
            url: url, handlers: configs.sublist(0, 5), dest: dest));
        return;
      }
    } catch (e) {
      logger.d("proxy download failed: $e", stackTrace: StackTrace.current);
    }

    return await directDownloadToFile(url, dest);
  }

  Future<void> download(String url, String dest) async {
    await _download(url, dest);
  }

  Future<void> downloadZip(String url, String dest,
      {bool cleanDest = true}) async {
    final tmpPath = '${await tempFilePath()}.zip';
    await downloadProxyFirst(url, tmpPath);

    if (cleanDest && Directory(dest).existsSync()) {
      Directory(dest).deleteSync(recursive: true);
    }

    // unzip the file to dest. If dest already exists, there will be no error.
    // existing files that are also in the zip will be replaced
    // if dest does not exist, it will be created
    await extractFileToDisk(tmpPath, dest);
    File(tmpPath).deleteSync();
  }

  /// try direct download first, if failed, try to use outbound handlers
  Future<void> _download(String url, String dest) async {
    try {
      await directDownloadToFile(url, dest);
      return;
    } catch (e) {
      logger.d("plain download failed: $e", stackTrace: StackTrace.current);
    }

    List<HandlerConfig> configs = handlersToHandlerConfig(await outboundRepo
        .getHandlers(usable: true, orderBySpeed1MBDesc: true));
    if (configs.length >= 5) {
      configs = configs.sublist(0, 5);
    }
    await xApiClient
        .download(DownloadRequest(url: url, handlers: configs, dest: dest));
  }

  Future<Uint8List> downloadMemory(String url) async {
    try {
      return await directDownloadMemory(url);
    } catch (e) {
      logger.e("plain download failed: $e");
    }

    final configs =
        handlersToHandlerConfig(await outboundRepo.getHandlers(usable: true));
    final rsp =
        await xApiClient.download(DownloadRequest(url: url, handlers: configs));
    return Uint8List.fromList(rsp.data);
  }
}
