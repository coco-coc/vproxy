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

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vx/utils/download.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/common/os.dart';
import 'package:vx/main.dart';
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
    try {
      // delete existing dir
      final eistingWintunDir = Directory(
        join((await resourceDir()).path, 'wintun'),
      );
      if (eistingWintunDir.existsSync()) {
        eistingWintunDir.deleteSync(recursive: true);
      }
      final zipPath = join(
        (await getApplicationCacheDirectory()).path,
        'wintun-zip',
      );
      await downloader.download(wintunDownloadLink, zipPath);
      // Extract the zip file
      await extractFileToDisk(zipPath, (await resourceDir()).path);
      // Clean up zip file after extraction
      await File(zipPath).delete();
      logger.d('Wintun DLL downloaded and extracted to $dllPath');
    } catch (e, s) {
      logger.e('Failed to prepare Wintun DLL', error: e, stackTrace: s);
      final errorMessage =
          rootLocalizations()?.fatalError('Failed to prepare Wintun DLL: $e') ??
          'Failed to prepare Wintun DLL: $e';
      if (rootNavigationKey.currentContext != null) {
        fatalMessageDialog(errorMessage);
      } else {
        fatalErrorMessage = errorMessage;
      }
      rethrow;
    }
  }
}

String getServiceInstallExePath() {
  final String localExePath = join(
    'data',
    'flutter_assets',
    'packages',
    'tm_windows',
    'assets',
    'service_install.exe',
  );
  String pathToExe = join(
    Directory(Platform.resolvedExecutable).parent.path,
    localExePath,
  );
  logger.d('pathToExe: $pathToExe');
  return pathToExe;
}
