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
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:vx/utils/logger.dart';

/// A utility class for compressing and decompressing files
class CompressionHelper {
  /// Compress multiple files into a single zip archive
  ///
  /// [files] - List of file paths to compress
  /// [destinationPath] - Path where the zip file will be saved
  static Future<void> compressFiles(
      List<String> files, String destinationPath) async {
    final encoder = ZipEncoder();
    final archive = Archive();

    for (final filePath in files) {
      final file = File(filePath);
      if (!await file.exists()) {
        continue;
      }

      final bytes = await file.readAsBytes();
      final archiveFile = ArchiveFile(
        path.basename(filePath),
        bytes.length,
        bytes,
      );
      archive.addFile(archiveFile);
    }

    // Encode and write to file
    final zipData = encoder.encode(archive);
    if (zipData == null) {
      throw Exception('Failed to encode zip archive');
    }

    final zipFile = File(destinationPath);
    await zipFile.writeAsBytes(zipData);
  }

  static Future<List<int>> compressFilesToBytes(List<String> files) async {
    final encoder = ZipEncoder();
    final archive = Archive();

    for (final filePath in files) {
      final file = File(filePath);
      if (!await file.exists()) {
        continue;
      }

      final bytes = await file.readAsBytes();
      final archiveFile = ArchiveFile(
        path.basename(filePath),
        bytes.length,
        bytes,
      );
      archive.addFile(archiveFile);
    }

    // Encode and write to file
    final zipData = encoder.encode(archive);
    if (zipData == null) {
      throw Exception('Failed to encode zip archive');
    }

    return zipData;
  }
}
