// Copyright (C) 2026 5V Network LLC <5vnetwork@proton.me>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
