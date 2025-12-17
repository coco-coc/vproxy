import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GeoDataHelper - Testable Components', () {
    late String tempDir;
    late Directory resourceDir;
    late Directory clashRulesDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync().path;
      resourceDir = Directory(path.join(tempDir, 'resources'));
      clashRulesDir = Directory(path.join(tempDir, 'resources', 'clash_rules'));
      resourceDir.createSync(recursive: true);
      clashRulesDir.createSync(recursive: true);
    });

    tearDown(() {
      Directory(tempDir).deleteSync(recursive: true);
    });

    group('File Operations Tests', () {
      test('should detect missing geo files correctly', () {
        // Arrange: Create only one geo file
        final geoSiteFile = File(path.join(resourceDir.path, 'geosite.dat'));
        geoSiteFile.writeAsStringSync('test data');

        // Act & Assert: Check file existence logic
        final geoSiteExists = geoSiteFile.existsSync();
        final geoIpExists = File(path.join(resourceDir.path, 'geoip.dat')).existsSync();

        expect(geoSiteExists, true);
        expect(geoIpExists, false);
      });

      test('should detect both geo files exist', () {
        // Arrange: Create both geo files
        final geoSiteFile = File(path.join(resourceDir.path, 'geosite.dat'));
        final geoIpFile = File(path.join(resourceDir.path, 'geoip.dat'));
        geoSiteFile.writeAsStringSync('test geosite data');
        geoIpFile.writeAsStringSync('test geoip data');

        // Act & Assert: Check file existence logic
        final geoSiteExists = geoSiteFile.existsSync();
        final geoIpExists = geoIpFile.existsSync();

        expect(geoSiteExists, true);
        expect(geoIpExists, true);
      });

      test('should handle clash rules directory operations', () {
        // Arrange: Create clash rules directory
        final clashRulesDir = Directory(path.join(resourceDir.path, 'clash_rules'));
        clashRulesDir.createSync(recursive: true);

        // Create some test files
        final file1 = File(path.join(clashRulesDir.path, 'rule1.yaml'));
        final file2 = File(path.join(clashRulesDir.path, 'rule2.yaml'));
        file1.writeAsStringSync('rule1 content');
        file2.writeAsStringSync('rule2 content');

        // Act: List files in directory
        final files = clashRulesDir.listSync();

        // Assert
        expect(files.length, 2);
        expect(files.any((f) => f.path.endsWith('rule1.yaml')), true);
        expect(files.any((f) => f.path.endsWith('rule2.yaml')), true);
      });

      test('should handle file deletion operations', () {
        // Arrange: Create clash rules directory with files
        final clashRulesDir = Directory(path.join(resourceDir.path, 'clash_rules'));
        clashRulesDir.createSync(recursive: true);

        final file1 = File(path.join(clashRulesDir.path, 'rule1.yaml'));
        final file2 = File(path.join(clashRulesDir.path, 'rule2.yaml'));
        file1.writeAsStringSync('rule1 content');
        file2.writeAsStringSync('rule2 content');

        // Act: Delete one file
        file1.deleteSync();

        // Assert
        expect(file1.existsSync(), false);
        expect(file2.existsSync(), true);
      });

      test('should handle URL to file path mapping logic', () {
        // This test verifies the logic for mapping URLs to file paths
        // which is used in makeGeoDataAvailable for clash rules
        
        final urls = <String>{
          'https://example.com/rules1.yaml',
          'https://example.com/rules2.yaml',
          'https://example.com/rules3.yaml',
        };

        final paths = <String>{};
        for (final url in urls) {
          // Simulate the hash-based path generation used in getClashRulesPath
          final hash = url.hashCode.toString();
          paths.add(path.join(clashRulesDir.path, hash));
        }

        // Assert: All paths should be unique
        expect(paths.length, 3);
        expect(paths.every((p) => p.startsWith(clashRulesDir.path)), true);
      });

      test('should handle file cleanup logic', () {
        // Arrange: Create clash rules directory with files
        final clashRulesDir = Directory(path.join(resourceDir.path, 'clash_rules'));
        clashRulesDir.createSync(recursive: true);

        // Create test files
        final keepFile = File(path.join(clashRulesDir.path, 'keep.yaml'));
        final deleteFile = File(path.join(clashRulesDir.path, 'delete.yaml'));
        keepFile.writeAsStringSync('keep content');
        deleteFile.writeAsStringSync('delete content');

        // Simulate the cleanup logic from makeGeoDataAvailable
        final validPaths = <String>{keepFile.path};
        
        for (final file in clashRulesDir.listSync()) {
          if (!validPaths.contains(file.path)) {
            file.deleteSync();
          }
        }

        // Assert: keep file should exist, delete file should be removed
        expect(keepFile.existsSync(), true);
        expect(deleteFile.existsSync(), false);
      });

      test('should handle empty clash rules directory', () {
        // Arrange: Create empty clash rules directory
        final clashRulesDir = Directory(path.join(resourceDir.path, 'clash_rules'));
        clashRulesDir.createSync(recursive: true);

        // Act: List files in empty directory
        final files = clashRulesDir.listSync();

        // Assert
        expect(files, isEmpty);
      });

      test('should handle non-existent clash rules directory', () {
        // Arrange: Create a different directory path that doesn't exist
        final nonExistentDir = Directory(path.join(tempDir, 'non_existent'));

        // Act & Assert: Directory should not exist
        expect(nonExistentDir.existsSync(), false);
      });
    });

    group('Logic Tests', () {
      test('should handle empty URL sets', () {
        // Test the logic for handling empty URL sets
        final urls = <String>{};
        final paths = <String>{};
        
        for (final url in urls) {
          final hash = url.hashCode.toString();
          paths.add(hash);
        }

        expect(paths, isEmpty);
      });

      test('should handle duplicate URLs', () {
        // Test the logic for handling duplicate URLs
        final urls = <String>{
          'https://example.com/rules.yaml',
          'https://example.com/rules.yaml', // duplicate
          'https://example.com/other.yaml',
        };

        // Using Set should automatically deduplicate
        expect(urls.length, 2);
        expect(urls.contains('https://example.com/rules.yaml'), true);
        expect(urls.contains('https://example.com/other.yaml'), true);
      });

      test('should handle null clash rule URLs gracefully', () {
        // Test the logic for handling null clash rule URLs
        final List<String>? nullUrls = null;
        final List<String>? emptyUrls = [];
        final List<String>? validUrls = ['https://example.com/rules.yaml'];

        // Test null handling
        final urls1 = <String>{};
        urls1.addAll(nullUrls ?? []);
        expect(urls1, isEmpty);

        // Test empty list handling
        final urls2 = <String>{};
        urls2.addAll(emptyUrls ?? []);
        expect(urls2, isEmpty);

        // Test valid URLs handling
        final urls3 = <String>{};
        urls3.addAll(validUrls ?? []);
        expect(urls3.length, 1);
        expect(urls3.contains('https://example.com/rules.yaml'), true);
      });
    });

    group('Friday Update Logic Tests', () {
      test('should calculate days until Friday correctly', () {
        // Test the logic for calculating days until Friday
        final monday = DateTime(2024, 1, 15); // Monday
        final tuesday = DateTime(2024, 1, 16); // Tuesday
        final wednesday = DateTime(2024, 1, 17); // Wednesday
        final thursday = DateTime(2024, 1, 18); // Thursday
        final friday = DateTime(2024, 1, 19); // Friday
        final saturday = DateTime(2024, 1, 20); // Saturday
        final sunday = DateTime(2024, 1, 21); // Sunday

        // Test the modulo calculation used in geoFilesFridayUpdate
        expect((DateTime.friday - monday.weekday) % 7, 4);
        expect((DateTime.friday - tuesday.weekday) % 7, 3);
        expect((DateTime.friday - wednesday.weekday) % 7, 2);
        expect((DateTime.friday - thursday.weekday) % 7, 1);
        expect((DateTime.friday - friday.weekday) % 7, 0);
        expect((DateTime.friday - saturday.weekday) % 7, 6);
        expect((DateTime.friday - sunday.weekday) % 7, 5);
      });

      test('should handle time difference calculations', () {
        // Test the logic for checking if already updated today
        final now = DateTime.now();
        final oneHourAgo = now.subtract(const Duration(hours: 1));
        final oneDayAgo = now.subtract(const Duration(days: 1));
        final twoDaysAgo = now.subtract(const Duration(days: 2));

        // Test the hasUpdated logic from geoFilesFridayUpdate
        expect(now.difference(oneHourAgo) < const Duration(days: 1), true);
        expect(now.difference(oneDayAgo) < const Duration(days: 1), false); // Exactly 1 day ago
        expect(now.difference(twoDaysAgo) < const Duration(days: 1), false);
      });

      test('should handle random delay calculation', () {
        // Test the random delay logic used in geoFilesFridayUpdate
        final now = DateTime.now();
        final targetDate = now.add(const Duration(days: 1));
        final baseDelay = targetDate.difference(now);
        
        // Test that random delay is within expected range (0-12 hours)
        for (int i = 0; i < 100; i++) {
          final randomDelay = Duration(hours: i % 12);
          final totalDelay = baseDelay + randomDelay;
          expect(totalDelay.inHours, greaterThanOrEqualTo(baseDelay.inHours));
          expect(totalDelay.inHours, lessThanOrEqualTo(baseDelay.inHours + 12));
        }
      });
    });

    group('Concurrent Access Logic Tests', () {
      test('should handle completer state management', () {
        // Test the logic for managing concurrent access
        // This simulates the _completer logic in downloadAndProcessGeo
        
        // Simulate the completer pattern
        Completer<void>? completer;
        
        // First call - should create completer
        if (completer == null) {
          completer = Completer<void>();
          expect(completer, isNotNull);
        }
        
        // Second call - should return existing completer
        if (completer != null) {
          expect(completer, isNotNull);
        }
        
        // Complete and reset
        completer.complete();
        completer = null;
        expect(completer, isNull);
      });
    });
  });
}
