import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vx/auth/auth_bloc.dart';
import 'package:vx/auth/auth_provider.dart';
import 'package:vx/main.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/utils/download.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/utils/path.dart';

class AdsProvider with ChangeNotifier {
  AdsProvider(
      {required String adsDirectory,
      required AuthBloc authBloc,
      required SharedPreferences sharedPreferences,
      required Downloader downloader,
      Duration refreshInterval = const Duration(hours: 24)})
      : _adsDirectory = adsDirectory,
        _sharedPreferences = sharedPreferences,
        _downloader = downloader,
        _refreshInterval = refreshInterval {
    authBloc.stream.listen((state) {
      onAuthStateChanged(state);
    });
    onAuthStateChanged(authBloc.state);
  }

  void onAuthStateChanged(AuthState state) {
    if (state.pro) {
      stop();
    } else {
      start();
    }
  }

  bool running = false;

  void start() {
    logger.d('Starting ads provider');
    _loadAds();
    _startPeriodicFetchAds();
    running = true;
  }

  void stop() {
    running = false;
    _timer?.cancel();
    _timer = null;
    _adsToShow.clear();
    _adsShown.clear();
  }

  // LinkedList for ads to be shown
  final Queue<Ad> _adsToShow = Queue<Ad>();
  // LinkedList for ads that have been shown
  final Queue<Ad> _adsShown = Queue<Ad>();
  Timer? _timer;
  int get adsLen => _adsToShow.length + _adsShown.length;
  // Remote URL to fetch ads configuration from
  // The URL should return a JSON array of ad objects with 'name', 'website', and 'imageUrl'
  String? remoteUrl;
  final String _adsDirectory;
  static const String _adsMetadataFile = 'ads.json';
  final SharedPreferences _sharedPreferences;
  final Downloader _downloader;
  final Duration _refreshInterval;

  /// Move to next ad that fits within constraints
  Ad? getNextAd({double? maxHeight, double? maxWidth}) {
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

  DateTime? get _lastAdsFetchTime {
    final time = _sharedPreferences.getInt('lastAdsFetchTime');
    if (time == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  void _setLastAdsFetchTime(DateTime time) {
    _sharedPreferences.setInt('lastAdsFetchTime', time.millisecondsSinceEpoch);
  }

  /// Load local ads
  void _loadAds() {
    try {
      final metadataFile = File(path.join(_adsDirectory, _adsMetadataFile));
      if (!metadataFile.existsSync()) {
        return;
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
      notifyListeners();
      logger.i('Loaded ${_adsToShow.length} cached ads');
    } catch (e) {
      logger.e('Error loading cached ads: $e');
    }
  }

  /// Check if we need to fetch ads today
  static const _adsZipUrl = 'https://ads.5vnetwork.com/ads.zip';

  /// Fetch ads.zip from remote URL and extract it to _adsDirectory
  Future<void> fetchAds() async {
    try {
      if (isProduction()) {
        await _downloader.downloadZip(_adsZipUrl, _adsDirectory);
      }
      _setLastAdsFetchTime(DateTime.now());
      _loadAds();
    } catch (e) {
      logger.e('Error fetching ads: $e');
    }
  }

  Future<List<Ad>> fetchAllAds() async {
    await _downloader.downloadZip(_adsZipUrl, _adsDirectory);
    _setLastAdsFetchTime(DateTime.now());
    final metadataFile = File(path.join(_adsDirectory, _adsMetadataFile));
    if (!metadataFile.existsSync()) {
      return [];
    }
    final List<dynamic> adsJson = jsonDecode(metadataFile.readAsStringSync());
    // Parse ads and filter out expired ones
    final loadedAds = adsJson
        .map((json) => Ad.fromJson(json))
        .where((ad) => ad.expiresAt.isAfter(DateTime.now()))
        .toList();
    for (final ad in loadedAds) {
      ad.imageProvider = FileImage(File(path.join(_adsDirectory, ad.name)));
    }
    return loadedAds;
  }

  /// Start a timer to check daily for new ads
  void _startPeriodicFetchAds() {
    // Cancel existing timer if any
    _timer?.cancel();

    // Calculate time until next fetch
    late Duration durationUntilNextFetch;
    if (_lastAdsFetchTime == null) {
      durationUntilNextFetch = Duration.zero;
    } else {
      durationUntilNextFetch = _refreshInterval -
          (_lastAdsFetchTime!.difference(DateTime.now())).abs();
    }
    logger.i('Next fetch ads in $durationUntilNextFetch');
    // Set timer to fetch ads
    _timer = Timer(durationUntilNextFetch, () async {
      await fetchAds();
      _startPeriodicFetchAds();
    });
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
