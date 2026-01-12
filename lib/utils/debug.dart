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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/utils/path.dart';

void saveLogToApplicationDocumentsDir() async {
  logger.d("saveLogToApplicationDocumentsDir");

  final dstDir = Platform.isAndroid
      ? ('/storage/emulated/0/Documents/vx')
      : (await getApplicationDocumentsDirectory()).path;
  logger.d(dstDir);
  if (!Directory(dstDir).existsSync()) {
    Directory(dstDir).createSync(recursive: true);
  }

  // copy tunnel logFile to dst dir
  final tunnelLogDir = getTunnelLogDir();
  final dstTunnelLogDir = join(dstDir, "tunnel_logs");
  if (!Directory(dstTunnelLogDir).existsSync()) {
    Directory(dstTunnelLogDir).createSync(recursive: true);
  }
  for (final file in await tunnelLogDir.list().toList()) {
    if (file is File) {
      final fileName = basename(file.path);
      if (fileName.startsWith(".")) {
        continue;
      }
      final destinationFile = File(join(dstTunnelLogDir, fileName));
      await file.copy(destinationFile.path);
    }
  }
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(
        "saved log to: $dstDir",
      ),
    ),
  );

  // copy flutterLogDir to ApplicationDocumentsDirectory
  final flutterLogDir = getFlutterLogDir();
  if (await flutterLogDir.exists()) {
    final dstFlutterLogDir = join(dstDir, "flutter_logs");
    if (!Directory(dstFlutterLogDir).existsSync()) {
      Directory(dstFlutterLogDir).createSync(recursive: true);
    }
    final flutterLogFiles = await flutterLogDir.list().toList();
    for (final logFile in flutterLogFiles) {
      if (logFile is File) {
        final fileName = basename(logFile.path);
        if (fileName.startsWith(".")) {
          continue;
        }
        final destinationFile = File(join(dstFlutterLogDir, fileName));
        await logFile.copy(destinationFile.path);
      }
    }
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          "copied flutter logs to: $dstFlutterLogDir",
        ),
      ),
    );
  } else {
    logger.d("flutter log directory does not exist");
  }
}

Future<void> clearDatabase(String dbPath) async {
  if (kDebugMode) {
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      try {
        await dbFile.delete();
        logger.d('Deleted existing database file');
      } catch (e) {
        logger.e('Failed to delete database file: $e');
      }
    }
  }
}
