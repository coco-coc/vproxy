import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

final desktopPlatforms =
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

const androidPackageNme = appFlavor == 'staging'
    ? 'com5vnetwork.vproxy.staging'
    : 'com5vnetwork.vproxy';
const darwinBundleId = 'com.5vnetwork.x';
const dartBackendUrl = false
    ? 'http://127.0.0.1:8080/verifypurchase'
    : 'https://iap.5vnetwork.com/verifypurchase';
const logKey = kDebugMode ? '1234567890' : String.fromEnvironment('LOG_KEY');

List<int> generateUniqueNumbers(int count, {int min = 1, int max = 100}) {
  final random = Random();
  final Set<int> numbers = {};

  while (numbers.length < count) {
    numbers.add(min + random.nextInt(max - min + 1));
  }

  return numbers.toList();
}

final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
final numericRegExp = RegExp(r'^\d+$');
const isStore = bool.fromEnvironment('STORE');
const isPkg = appFlavor == 'pkg';
final androidApkRelease =
    Platform.isAndroid && !const bool.fromEnvironment('PLAY_STORE');

String getUserCountryFromLocale() {
  final locale = PlatformDispatcher.instance.locale;
  return locale.countryCode ?? 'Unknown';
}
