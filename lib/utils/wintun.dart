import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vx/utils/download.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/common/os.dart';
import 'package:vx/utils/path.dart';
import 'package:archive/archive_io.dart';

const String wintunDownloadLink =
    'https://www.wintun.net/builds/wintun-0.14.1.zip';

Future<void> makeWinTunAvailable(Downloader downloader) async {
  if (!Platform.isWindows) {
    return;
  }
  final wintunDir = Directory(await getWintunDir());
  final arch = getCpuArch();
  logger.d('CPU Architecture: $arch');
  final dllPath = join(wintunDir.path, arch, "wintun.dll");
  // Get CPU architecture
  if (!File(dllPath).existsSync()) {
    // delete existing dir
    final eistingWintunDir =
        Directory(join((await resourceDir()).path, 'wintun'));
    if (eistingWintunDir.existsSync()) {
      eistingWintunDir.deleteSync(recursive: true);
    }
    final zipPath =
        join((await getApplicationCacheDirectory()).path, 'wintun-zip');
    await downloader.download(wintunDownloadLink, zipPath);
    // Extract the zip file
    await extractFileToDisk(zipPath, (await resourceDir()).path);
    // Clean up zip file after extraction
    await File(zipPath).delete();
    logger.d('Wintun DLL downloaded and extracted to $dllPath');
  }
}

Future<void> installWindowsService() async {
  if (kDebugMode) {
    print(Directory.current.path);
    final process = await Process.run(
        'powershell.exe',
        [
          '-Command',
          'Start-Process',
          '..\\vx-core\\win_service\\service\\service_install.exe',
          'install',
          '-Verb',
          'RunAs'
        ],
        stderrEncoding: utf8,
        stdoutEncoding: utf8,
        /* runInShell: true */
        runInShell: true);
    final exitCode = process.exitCode;
    logger.d('Windows service installed with exit code: $exitCode');
    // get stdout and stderr
    final stdout = process.stdout;
    final stderr = process.stderr;
    logger.d('Windows service installed with stdout: $stdout');
    logger.d('Windows service installed with stderr: $stderr');
    if (exitCode != 0) {
      throw Exception(
          'Windows service installation failed with exit code: $exitCode. stdout: $stdout, stderr: $stderr');
    }
    // the process might takes some time to finish. so wait for 1 second
    await Future.delayed(const Duration(seconds: 1));
  }
  // final process = await Process.run('powershell.exe', [
  //   '-Command',
  //   'Start-Process',
  //   getServiceInstallExePath(),
  //   'install',
  //   '-Verb',
  //   'RunAs'
  // ]);
  // final geoFile = await rootBundle.load('assets/geo/simplified_geosite.dat');
}

String getServiceInstallExePath() {
  final String localExePath = join('data', 'flutter_assets', 'packages',
      'tm_windows', 'assets', 'service_install.exe');
  String pathToExe =
      join(Directory(Platform.resolvedExecutable).parent.path, localExePath);
  logger.d('pathToExe: $pathToExe');
  return pathToExe;
}
