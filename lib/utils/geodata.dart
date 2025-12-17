import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:vx/data/database_helper.dart';
import 'package:vx/app/routing/repo.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/common/const.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/utils/download.dart';
import 'package:vx/utils/path.dart';
import 'package:vx/utils/xapi_client.dart';

Future<void> writeStaticGeo() async {
  logger.d('writeStaticGeo');
  final geoFile = await rootBundle.load('assets/geo/simplified_geosite.dat');
  final geoIP = await rootBundle.load('assets/geo/simplified_geoip.dat');
  // write to file
  File(await getSimplifiedGeositePath())
      .writeAsBytesSync(geoFile.buffer.asUint8List());
  File(await getSimplifiedGeoIPPath())
      .writeAsBytesSync(geoIP.buffer.asUint8List());
}

class GeoDataHelper {
  final Downloader downloader;
  final PrefHelper psr;
  final XApiClient xApiClient;
  final DbHelper databaseHelper;
  final String resouceDirPath;

  GeoDataHelper(
      {required this.downloader,
      required this.psr,
      required this.xApiClient,
      required this.databaseHelper,
      required this.resouceDirPath});

  Completer<void>? _completer;

  /// download geosite and geoip and update the last geo update time
  Future<void> downloadAndProcessGeo() async {
    if (_completer != null) {
      return _completer!.future;
    }
    _completer = Completer<void>();

    logger.d('downloadGeo');
    try {
      final dir = await resourceDir();
      final tasks = [
        downloader.downloadProxyFirst(
            geositeUrls[0], join(dir.path, 'geosite.dat')),
        downloader.downloadProxyFirst(
            geoipUrls[0], join(dir.path, 'geoip.dat')),
      ];
      await Future.wait(tasks);
      await xApiClient.processGeoFiles();
      psr.setLastGeoUpdate(DateTime.now());
      _completer!.complete();
    } catch (e) {
      logger.e('downloadAndProcessGeo error', error: e);
      // await reportError(e, StackTrace.current);
      _completer!.completeError(e);
    } finally {
      _completer = null;
    }
  }

  Future<void> makeGeoDataAvailable() async {
    logger.d('makeGeoDataAvailable');
    // check if there is geo data
    final dir = Directory(resouceDirPath);
    final geoSiteFile = File(join(dir.path, 'geoip.dat'));
    final geoIpFile = File(join(dir.path, 'geosite.dat'));
    if (!geoSiteFile.existsSync() || !geoIpFile.existsSync()) {
      await downloadAndProcessGeo();
    }
    // download all clash rule files and clean files that are not in the urls
    final clashUrls = <String>{};
    final geoUrls = <String>{};
    await databaseHelper.getAtomicDomainSets().then((values) async {
      for (final set in values) {
        clashUrls.addAll(set.clashRuleUrls ?? []);
        if (set.geoUrl != null) {
          geoUrls.add(set.geoUrl!);
        }
      }
    });
    await databaseHelper.getAppSets().then((values) async {
      for (final set in values) {
        clashUrls.addAll(set.clashRuleUrls ?? []);
      }
    });
    await databaseHelper.getAtomicIpSets().then((values) async {
      for (final set in values) {
        clashUrls.addAll(set.clashRuleUrls ?? []);
        if (set.geoUrl != null) {
          geoUrls.add(set.geoUrl!);
        }
      }
    });
    final futures = <Future>[];
    for (final url in clashUrls) {
      final path = await getClashRulesPath(url);
      if (!File(path).existsSync()) {
        futures.add(downloader.download(url, path));
      }
    }
    for (final url in geoUrls) {
      final path = await getGeoUrlPath(url);
      if (!File(path).existsSync()) {
        futures.add(downloader.download(url, path));
      }
    }
    await Future.wait(futures);
    // clean files that are not in the urls
    final paths = <String>{};
    for (final url in clashUrls) {
      paths.add(await getClashRulesPath(url));
    }
    for (final url in geoUrls) {
      paths.add(await getGeoUrlPath(url));
    }
    for (final file in (await getClashRulesDir()).listSync()) {
      if (!paths.contains(file.path)) {
        file.deleteSync();
      }
    }
    for (final file in (await getGeoDir()).listSync()) {
      if (!paths.contains(file.path)) {
        file.deleteSync();
      }
    }
    // else {
    //   // check whether the geo data is outdated
    //   final lastGeoUpdate = psr.lastGeoUpdate;
    //   if (lastGeoUpdate == null ||
    //       DateTime.now().difference(lastGeoUpdate) > Duration(days: 7)) {
    //     await downloadGeo();
    //   }
    // }
  }

  /// download geo files on friday once
  void geoFilesFridayUpdate() {
    final now = DateTime.now();

    // Check if we already updated today
    final lastUpdate = psr.lastGeoUpdate;
    final hasUpdated = lastUpdate != null &&
        now.difference(lastUpdate) < const Duration(days: 1);

    // If it's Friday and we haven't updated today, download immediately
    if (now.weekday == DateTime.friday && !hasUpdated) {
      downloadAndProcessGeo();
    }

    // Calculate next Friday midnight
    final daysUntilFriday = (DateTime.friday - now.weekday) % 7;
    final nextFriday = DateTime(
      now.year,
      now.month,
      now.day + daysUntilFriday,
      0, // hour
      0, // minute
      0, // second
    );

    // If we've already passed Friday midnight, add 7 days
    final targetDate = now.isAfter(nextFriday)
        ? nextFriday.add(const Duration(days: 7))
        : nextFriday;

    final random = Random();
    // Calculate duration until next Friday
    final initialDelay =
        targetDate.difference(now) + Duration(hours: random.nextInt(12));

    // Schedule initial timer
    Timer(initialDelay, () {
      downloadAndProcessGeo(); // Run update

      // Schedule subsequent updates every Friday
      Timer.periodic(const Duration(days: 7), (_) {
        downloadAndProcessGeo();
      });
    });
  }
}
