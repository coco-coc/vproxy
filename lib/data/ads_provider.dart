import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:vx/auth/auth_provider.dart';
import 'package:vx/main.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/utils/download.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/utils/path.dart';

class AdsProvider {
  AdsProvider(
      {required String directory,
      required PrefHelper prefHelper,
      required Downloader downloader,
      required AuthProvider authProvider})
      : _adsParentDirectory = directory,
        _adsDirectory = path.join(directory, 'ads'),
        _prefHelper = prefHelper,
        _downloader = downloader {
    authProvider.user.listen((user) {
      if (user == null || !user.isProUser) {
        startFetching();
      } else {
        stopFetching();
      }
    });
  }
  // LinkedList for ads to be shown
  final Queue<Ad> _adsToShow = Queue<Ad>();
  // LinkedList for ads that have been shown
  final Queue<Ad> _adsShown = Queue<Ad>();
  Timer? _dailyTimer;
  int get adsLen => _adsToShow.length + _adsShown.length;

  /// Move to next ad that fits within constraints
  Ad? getNextAd({int? maxHeight, int? maxWidth}) {
    // If no ads to show, swap the queues
    if (_adsToShow.isEmpty) {
      if (_adsShown.isEmpty) return null; // No ads at all
      // Swap the two queues
      _adsToShow.addAll(_adsShown);
      _adsShown.clear();
      // Shuffle the ads for variety
      final adsList = _adsToShow.toList()..shuffle(Random());
      _adsToShow.clear();
      _adsToShow.addAll(adsList);
      logger.i('Swapped ad queues, reset with ${_adsToShow.length} ads');
    }

    // Iterate through ads to find one that meets constraints
    Ad? selectedAd;
    final iterator = _adsToShow.iterator;
    while (iterator.moveNext()) {
      final ad = iterator.current;
      // Check if ad meets constraints
      if (maxHeight != null && ad.height > maxHeight) {
        continue;
      }
      if (maxWidth != null && ad.width > maxWidth) {
        continue;
      }
      selectedAd = ad;
      break;
    }
    // if no ad meets constraints, try to find one that meets constraints * 1.5
    if (selectedAd == null) {
      while (iterator.moveNext()) {
        final ad = iterator.current;
        // Check if ad meets constraints
        if (maxHeight != null && ad.height > maxHeight * 1.5) {
          continue;
        }
        if (maxWidth != null && ad.width > maxWidth * 1.5) {
          continue;
        }
        selectedAd = ad;
        break;
      }
    }
    selectedAd ??= iterator.current;

    // If we found a suitable ad, remove it from _adsToShow and add to _adsShown
    selectedAd.imageProvider ??=
        FileImage(File(path.join(_adsDirectory, selectedAd.name)));
    _adsToShow.remove(selectedAd);
    _adsShown.add(selectedAd);
    return selectedAd;

    // return null; // No suitable ads available
  }

  // Remote URL to fetch ads configuration from
  // The URL should return a JSON array of ad objects with 'name', 'website', and 'imageUrl'
  String? remoteUrl;
  final String _adsParentDirectory;
  final String _adsDirectory;
  static const String _adsMetadataFile = 'ads.json';
  final PrefHelper _prefHelper;
  final Downloader _downloader;

  /// Load cached ads metadata from SharedPreferences
  Future<void> _loadAds() async {
    try {
      final metadataFile = File(path.join(_adsDirectory, _adsMetadataFile));
      if (!metadataFile.existsSync()) {
        await fetchAds();
        _prefHelper.setLastAdsFetchTime(DateTime.now());
      }

      final List<dynamic> adsJson = jsonDecode(metadataFile.readAsStringSync());

      // Parse ads and filter out expired ones
      final loadedAds = adsJson
          .map((json) => Ad.fromJson(json))
          .where((ad) => ad.expiresAt.isAfter(DateTime.now()))
          .toList();

      // Shuffle and add to _adsToShow queue
      loadedAds.shuffle(Random());
      _adsToShow.clear();
      _adsShown.clear();
      _adsToShow.addAll(loadedAds);

      logger.i('Loaded ${_adsToShow.length} cached ads');
    } catch (e) {
      logger.e('Error loading cached ads: $e');
    }
  }

  /// Check if we need to fetch ads today
  Future<void> _checkAndFetchAds() async {
    if (_shouldFetchToday()) {
      await fetchAds();
    }
  }

  /// Check if we should fetch ads today
  bool _shouldFetchToday() {
    try {
      final lastFetch = _prefHelper.lastAdsFetchTime;
      if (lastFetch == null) return true;

      final today = DateTime.now();

      // Check if last fetch was on a different day
      return lastFetch.year != today.year ||
          lastFetch.month != today.month ||
          lastFetch.day != today.day;
    } catch (e) {
      logger.e('Error checking last fetch date: $e');
    }
    return true;
  }

  static const _adsZipUrl = 'https://ads.5vnetwork.com/ads.zip';

  /// Fetch ads.zip from remote URL and extract it to _adsDirectory
  Future<void> fetchAds() async {
    try {
      // Ensure ads directory exists
      final adsDir = Directory(_adsDirectory);
      if (!adsDir.existsSync()) {
        adsDir.createSync(recursive: true);
      }

      final downloadDest = path.join(await getCacheDir(), 'ads.zip');
      await _downloader.download(_adsZipUrl, downloadDest);
      adsDir.deleteSync();

      await extractFileToDisk(
          path.join(resourceDirectory.path, 'ads.zip'), _adsParentDirectory);
    } catch (e) {
      logger.e('Error fetching ads: $e');
    }
  }

  /// Start a timer to check daily for new ads
  void _startDailyTimer() {
    // Cancel existing timer if any
    _dailyTimer?.cancel();

    // Calculate time until next midnight
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    // Set timer to check at midnight
    _dailyTimer = Timer(durationUntilMidnight, () async {
      await _checkAndFetchAds();
      _startDailyTimer();
    });
  }

  Future<void> startFetching() async {
    await _loadAds();
    if (!isProduction()) {
      return;
    }
    await _checkAndFetchAds();
    _startDailyTimer();
  }

  Future<void> stopFetching() async {
    _dailyTimer?.cancel();
    _dailyTimer = null;
    _adsToShow.clear();
    _adsShown.clear();
  }
}

enum AdImageType {
  png,
  jpg,
  jpeg,
  gif,
  webp,
}

class Ad {
  final String name;
  final String website;
  final DateTime expiresAt;
  final int width;
  final int height;
  final AdImageType imageType;
  ImageProvider? imageProvider;

  Ad({
    required this.name,
    required this.website,
    required this.expiresAt,
    required this.width,
    required this.height,
    required this.imageType,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'website': website,
        'expiresAt': expiresAt.toIso8601String(),
        'width': width,
        'height': height,
        'imageType': imageType.name,
      };

  factory Ad.fromJson(Map<String, dynamic> json) => Ad(
        name: json['name'],
        website: json['website'],
        expiresAt: DateTime.parse(json['expiresAt']),
        width: json['width'],
        height: json['height'],
        imageType: AdImageType.values.byName(json['imageType']),
      );
}
