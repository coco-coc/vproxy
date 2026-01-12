import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:android_package_installer/android_package_installer.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:vx/common/version.dart';
import 'package:vx/main.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/utils/download.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/utils/os.dart';
import 'package:vx/utils/path.dart';
import 'package:window_manager/window_manager.dart';

Future<String> assetName() async {
  if (Platform.isAndroid) {
    return 'vx-arm64-v8a.apk.zip';
  } else if (Platform.isWindows) {
    // final ar = await arch();
    return 'VXInstaller.exe';
  } else if (isRpm()) {
    final ar = await arch();
    if (ar.contains('arm64')) {
      return 'vx-arm64.rpm';
    }
    return 'vx-x64.rpm';
  } else {
    final ar = await arch();
    if (ar.contains('arm64')) {
      return 'vx-arm64.deb';
    }
    return 'vx-x64.deb';
  }
}
