import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:vx/utils/upload_log.dart';

void main() {
  group('LogUploadService.getLogsContent', () {
    late Directory tempDir;
    late LogUploadService logUploadService;

    setUp(() async {
      // Create a temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('log_upload_test_');
      
      // Create a mock LogUploadService instance
      logUploadService = LogUploadService(
        uploadUrl: 'https://example.com/upload',
        flutterLogDir: tempDir,
        tunnelLogDir: tempDir,
        secret: 'test_secret',
      );
    });

    tearDown(() async {
      // Clean up temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should return null when no log files exist', () async {
      // Arrange: Empty directory
      
      // Act
      final result = await logUploadService.getLogsContent(tempDir);
      
      // Assert
      expect(result, isNull);
    });

    test('should return null when only empty files exist', () async {
      // Arrange: Create empty files
      final emptyFile1 = File(path.join(tempDir.path, 'empty1.log'));
      final emptyFile2 = File(path.join(tempDir.path, 'empty2.log'));
      await emptyFile1.create();
      await emptyFile2.create();
      
      // Act
      final result = await logUploadService.getLogsContent(tempDir);
      
      // Assert
      expect(result, isNull);
      expect(await emptyFile1.exists(), isFalse); // Should be deleted
      expect(await emptyFile2.exists(), isFalse); // Should be deleted
    });

    test('should compress and return base64 when log files exist', () async {
      // Arrange: Create log files with content
      final logFile1 = File(path.join(tempDir.path, 'app.log'));
      final logFile2 = File(path.join(tempDir.path, 'error.log'));
      
      await logFile1.writeAsString('This is app log content');
      await logFile2.writeAsString('This is error log content');
      
      // Act
      final result = await logUploadService.getLogsContent(tempDir);
      
      // Assert
      expect(result, isNotNull);
      expect(result, isNotEmpty);
      
      // Verify the result is valid base64
      expect(() => base64Url.decode(result!), returnsNormally);
      
      // Verify original files are deleted
      expect(await logFile1.exists(), isFalse);
      expect(await logFile2.exists(), isFalse);
    });

    test('should delete all files except those containing "latest"', () async {
      // Arrange: Create various log files
      final regularFile1 = File(path.join(tempDir.path, 'app.log'));
      final regularFile2 = File(path.join(tempDir.path, 'error.log'));
      final latestFile = File(path.join(tempDir.path, 'latest.log'));
      final latestBackupFile = File(path.join(tempDir.path, 'backup_latest.log'));
      
      await regularFile1.writeAsString('Regular log content 1');
      await regularFile2.writeAsString('Regular log content 2');
      await latestFile.writeAsString('Latest log content');
      await latestBackupFile.writeAsString('Latest backup content');
      
      // Act
      await logUploadService.getLogsContent(tempDir);
      
      // Assert: Regular files should be deleted
      expect(await regularFile1.exists(), isFalse);
      expect(await regularFile2.exists(), isFalse);
      
      // Assert: Files containing "latest" should exist but be empty
      expect(await latestFile.exists(), isTrue);
      expect(await latestBackupFile.exists(), isTrue);
      expect(await latestFile.readAsString(), isEmpty);
      expect(await latestBackupFile.readAsString(), isEmpty);
    });

    test('should clear files containing "latest" but not delete them', () async {
      // Arrange: Create a file with "latest" in the name
      final latestFile = File(path.join(tempDir.path, 'latest.log'));
      await latestFile.writeAsString('This content should be cleared');
      
      // Act
      await logUploadService.getLogsContent(tempDir);
      
      // Assert: File should exist but be empty
      expect(await latestFile.exists(), isTrue);
      expect(await latestFile.readAsString(), isEmpty);
    });

    test('should handle mixed files correctly', () async {
      // Arrange: Create a mix of regular and latest files
      final regularFile = File(path.join(tempDir.path, 'regular.log'));
      final latestFile = File(path.join(tempDir.path, 'latest.log'));
      final mixedFile = File(path.join(tempDir.path, 'mixed_latest_backup.log'));
      
      await regularFile.writeAsString('Regular content');
      await latestFile.writeAsString('Latest content');
      await mixedFile.writeAsString('Mixed content');
      
      // Act
      await logUploadService.getLogsContent(tempDir);
      
      // Assert: Regular file should be deleted
      expect(await regularFile.exists(), isFalse);
      
      // Assert: Files with "latest" should exist but be empty
      expect(await latestFile.exists(), isTrue);
      expect(await latestFile.readAsString(), isEmpty);
      expect(await mixedFile.exists(), isTrue);
      expect(await mixedFile.readAsString(), isEmpty);
    });

    test('should handle case sensitivity for "latest"', () async {
      // Arrange: Create files with different case variations
      final latestFile = File(path.join(tempDir.path, 'latest.log'));
      final LATESTFile = File(path.join(tempDir.path, 'LATEST.log'));
      final LatestFile = File(path.join(tempDir.path, 'Latest.log'));
      final regularFile = File(path.join(tempDir.path, 'regular.log'));
      
      await latestFile.writeAsString('lowercase latest');
      await LATESTFile.writeAsString('uppercase LATEST');
      await LatestFile.writeAsString('titlecase Latest');
      await regularFile.writeAsString('regular content');
      
      // Act
      await logUploadService.getLogsContent(tempDir);
      
      // Assert: All "latest" variations should be cleared but not deleted
      expect(await latestFile.exists(), isTrue);
      expect(await latestFile.readAsString(), isEmpty);
      expect(await LATESTFile.exists(), isTrue);
      expect(await LATESTFile.readAsString(), isEmpty);
      expect(await LatestFile.exists(), isTrue);
      expect(await LatestFile.readAsString(), isEmpty);
      
      // Regular file should be deleted
      expect(await regularFile.exists(), isFalse);
    });

    test('should handle subdirectories correctly', () async {
      // Arrange: Create a subdirectory with files
      final subDir = Directory(path.join(tempDir.path, 'subdir'));
      await subDir.create();
      
      final subDirFile = File(path.join(subDir.path, 'subdir.log'));
      final latestSubDirFile = File(path.join(subDir.path, 'latest_subdir.log'));
      
      await subDirFile.writeAsString('Subdirectory content');
      await latestSubDirFile.writeAsString('Latest subdirectory content');
      
      // Act
      await logUploadService.getLogsContent(tempDir);
      
      // Assert: Subdirectory files should be handled (deleted or cleared)
      expect(await subDirFile.exists(), isFalse);
      expect(await latestSubDirFile.exists(), isTrue);
      expect(await latestSubDirFile.readAsString(), isEmpty);
    });

    test('should handle files with special characters in names', () async {
      // Arrange: Create files with special characters
      final specialFile = File(path.join(tempDir.path, 'file-with-dashes.log'));
      final underscoreFile = File(path.join(tempDir.path, 'file_with_underscores.log'));
      final dotFile = File(path.join(tempDir.path, 'file.latest.backup.log'));
      
      await specialFile.writeAsString('Dashed file content');
      await underscoreFile.writeAsString('Underscore file content');
      await dotFile.writeAsString('Dot file content');
      
      // Act
      await logUploadService.getLogsContent(tempDir);
      
      // Assert: Files without "latest" should be deleted
      expect(await specialFile.exists(), isFalse);
      expect(await underscoreFile.exists(), isFalse);
      
      // File with "latest" should be cleared
      expect(await dotFile.exists(), isTrue);
      expect(await dotFile.readAsString(), isEmpty);
    });

    test('should handle empty directory after processing', () async {
      // Arrange: Create a file with "latest" in name
      final latestFile = File(path.join(tempDir.path, 'latest.log'));
      await latestFile.writeAsString('Content to be cleared');
      
      // Act
      await logUploadService.getLogsContent(tempDir);
      
      // Assert: Directory should still exist but only contain empty latest file
      expect(await tempDir.exists(), isTrue);
      final remainingFiles = tempDir.listSync().whereType<File>().toList();
      expect(remainingFiles.length, equals(1));
      expect(remainingFiles.first.path.contains('latest'), isTrue);
      expect(await remainingFiles.first.readAsString(), isEmpty);
    });

    test('should handle concurrent access to files', () async {
      // Arrange: Create multiple files
      final files = List.generate(5, (i) => File(path.join(tempDir.path, 'file$i.log')));
      for (final file in files) {
        await file.writeAsString('Content for ${file.path}');
      }
      
      final latestFile = File(path.join(tempDir.path, 'latest.log'));
      await latestFile.writeAsString('Latest content');
      
      // Act: Call getLogsContent multiple times concurrently
      final futures = List.generate(3, (_) => logUploadService.getLogsContent(tempDir));
      await Future.wait(futures);
      
      // Assert: All regular files should be deleted
      for (final file in files) {
        expect(await file.exists(), isFalse);
      }
      
      // Latest file should exist but be empty
      expect(await latestFile.exists(), isTrue);
      expect(await latestFile.readAsString(), isEmpty);
    });

    test('should return null when zip file is too large', () async {
      // Arrange: Create a large file (simulate by creating many small files)
      final files = List.generate(100, (i) => File(path.join(tempDir.path, 'large_file_$i.log')));
      for (final file in files) {
        await file.writeAsString('Large content ' * 1000); // Create substantial content
      }
      
      // Act
      final result = await logUploadService.getLogsContent(tempDir);
      
      // Assert: Should return null when zip is too large
      expect(result, isNull);
      
      // Files should still be cleaned up
      for (final file in files) {
        expect(await file.exists(), isFalse);
      }
    });
  });
} 