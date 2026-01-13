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
import 'dart:io';
import 'package:vx/utils/os.dart';

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
