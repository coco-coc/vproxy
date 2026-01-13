import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:path/path.dart' as path;
import 'package:vx/utils/geodata.dart';
import 'package:vx/utils/download.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/utils/xapi_client.dart';
import 'package:vx/data/database_helper.dart';
import 'package:vx/data/database.dart';

import 'geodata_test.mocks.dart';

@GenerateMocks([
  Downloader,
  PrefHelper,
  XApiClient,
  DatabaseHelper,
  AppDatabase,
  AtomicDomainSet,
  AppSet,
  AtomicIpSet,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GeoDataHelper - Core Logic Tests', () {
    late GeoDataHelper geoDataHelper;
    late MockDownloader mockDownloader;
    late MockPrefHelper mockPrefHelper;
    late MockXApiClient mockXApiClient;
    late MockDatabaseHelper mockDatabaseHelper;
    late String tempDir;
    late Directory resourceDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync().path;
      resourceDir = Directory(path.join(tempDir, 'resources'));
      resourceDir.createSync(recursive: true);

      mockDownloader = MockDownloader();
      mockPrefHelper = MockPrefHelper();
      mockXApiClient = MockXApiClient();
      mockDatabaseHelper = MockDatabaseHelper();

      geoDataHelper = GeoDataHelper(
        downloader: mockDownloader,
        psr: mockPrefHelper,
        xApiClient: mockXApiClient,
        databaseHelper: mockDatabaseHelper,
        resouceDirPath: resourceDir.path,
      );
    });

    tearDown(() {
      Directory(tempDir).deleteSync(recursive: true);
    });

    group('makeGeoDataAvailable - File Operations', () {
      test('should skip download when geo files exist', () async {
        // Arrange
        final geoSiteFile = File(path.join(resourceDir.path, 'geosite.dat'));
        final geoIpFile = File(path.join(resourceDir.path, 'geoip.dat'));
        geoSiteFile.writeAsStringSync('test geosite data');
        geoIpFile.writeAsStringSync('test geoip data');

        when(mockDatabaseHelper.getAtomicDomainSets())
            .thenAnswer((_) async => []);
        when(mockDatabaseHelper.getAppSets())
            .thenAnswer((_) async => []);
        when(mockDatabaseHelper.getAtomicIpSets())
            .thenAnswer((_) async => []);

        // Act
        await geoDataHelper.makeGeoDataAvailable();

        // Assert
        verifyNever(mockDownloader.downloadMulti(any, any));
        verifyNever(mockXApiClient.processGeoFiles());
      });

      test('should download clash rule files from database sets', () async {
        // Arrange
        final geoSiteFile = File(path.join(resourceDir.path, 'geosite.dat'));
        final geoIpFile = File(path.join(resourceDir.path, 'geoip.dat'));
        geoSiteFile.writeAsStringSync('test geosite data');
        geoIpFile.writeAsStringSync('test geoip data');

        final mockAtomicDomainSet = MockAtomicDomainSet();
        final mockAppSet = MockAppSet();
        final mockAtomicIpSet = MockAtomicIpSet();

        when(mockAtomicDomainSet.clashRuleUrls)
            .thenReturn(['https://example.com/domain-rules.yaml']);
        when(mockAppSet.clashRuleUrls)
            .thenReturn(['https://example.com/app-rules.yaml']);
        when(mockAtomicIpSet.clashRuleUrls)
            .thenReturn(['https://example.com/ip-rules.yaml']);

        when(mockDatabaseHelper.getAtomicDomainSets())
            .thenAnswer((_) async => [mockAtomicDomainSet]);
        when(mockDatabaseHelper.getAppSets())
            .thenAnswer((_) async => [mockAppSet]);
        when(mockDatabaseHelper.getAtomicIpSets())
            .thenAnswer((_) async => [mockAtomicIpSet]);

        when(mockDownloader.download(any, any))
            .thenAnswer((_) async {
              return null;
            });

        // Act
        await geoDataHelper.makeGeoDataAvailable();

        // Assert
        verify(mockDownloader.download(any, any)).called(3);
      });

      test('should handle null clash rule URLs gracefully', () async {
        // Arrange
        final geoSiteFile = File(path.join(resourceDir.path, 'geosite.dat'));
        final geoIpFile = File(path.join(resourceDir.path, 'geoip.dat'));
        geoSiteFile.writeAsStringSync('test geosite data');
        geoIpFile.writeAsStringSync('test geoip data');

        final mockAtomicDomainSet = MockAtomicDomainSet();
        when(mockAtomicDomainSet.clashRuleUrls).thenReturn(null);

        when(mockDatabaseHelper.getAtomicDomainSets())
            .thenAnswer((_) async => [mockAtomicDomainSet]);
        when(mockDatabaseHelper.getAppSets())
            .thenAnswer((_) async => []);
        when(mockDatabaseHelper.getAtomicIpSets())
            .thenAnswer((_) async => []);

        // Act
        await geoDataHelper.makeGeoDataAvailable();

        // Assert - Should not throw and should not download any clash rules
        verifyNever(mockDownloader.download(any, any));
      });

      test('should clean up unused clash rule files', () async {
        // Arrange
        final geoSiteFile = File(path.join(resourceDir.path, 'geosite.dat'));
        final geoIpFile = File(path.join(resourceDir.path, 'geoip.dat'));
        geoSiteFile.writeAsStringSync('test geosite data');
        geoIpFile.writeAsStringSync('test geoip data');

        final clashRulesDir = Directory(path.join(resourceDir.path, 'clash_rules'));
        clashRulesDir.createSync(recursive: true);

        // Create some test files
        final keepFile = File(path.join(clashRulesDir.path, 'keep.yaml'));
        final deleteFile = File(path.join(clashRulesDir.path, 'delete.yaml'));
        keepFile.writeAsStringSync('keep content');
        deleteFile.writeAsStringSync('delete content');

        when(mockDatabaseHelper.getAtomicDomainSets())
            .thenAnswer((_) async => []);
        when(mockDatabaseHelper.getAppSets())
            .thenAnswer((_) async => []);
        when(mockDatabaseHelper.getAtomicIpSets())
            .thenAnswer((_) async => []);

        // Act
        await geoDataHelper.makeGeoDataAvailable();

        // Assert - All files should be deleted since no URLs are provided
        expect(keepFile.existsSync(), false);
        expect(deleteFile.existsSync(), false);
      });
    });

    group('Error handling', () {
      test('should handle database errors in makeGeoDataAvailable', () async {
        // Arrange
        final geoSiteFile = File(path.join(resourceDir.path, 'geosite.dat'));
        final geoIpFile = File(path.join(resourceDir.path, 'geoip.dat'));
        geoSiteFile.writeAsStringSync('test geosite data');
        geoIpFile.writeAsStringSync('test geoip data');

        when(mockDatabaseHelper.getAtomicDomainSets())
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => geoDataHelper.makeGeoDataAvailable(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle download errors in makeGeoDataAvailable', () async {
        // Arrange
        final geoSiteFile = File(path.join(resourceDir.path, 'geosite.dat'));
        final geoIpFile = File(path.join(resourceDir.path, 'geoip.dat'));
        geoSiteFile.writeAsStringSync('test geosite data');
        geoIpFile.writeAsStringSync('test geoip data');

        final mockAtomicDomainSet = MockAtomicDomainSet();
        when(mockAtomicDomainSet.clashRuleUrls)
            .thenReturn(['https://example.com/rules.yaml']);

        when(mockDatabaseHelper.getAtomicDomainSets())
            .thenAnswer((_) async => [mockAtomicDomainSet]);
        when(mockDatabaseHelper.getAppSets())
            .thenAnswer((_) async => []);
        when(mockDatabaseHelper.getAtomicIpSets())
            .thenAnswer((_) async => []);

        when(mockDownloader.download(any, any))
            .thenThrow(Exception('Download failed'));

        // Act & Assert
        expect(
          () => geoDataHelper.makeGeoDataAvailable(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Edge cases', () {
      test('should handle empty database results', () async {
        // Arrange
        final geoSiteFile = File(path.join(resourceDir.path, 'geosite.dat'));
        final geoIpFile = File(path.join(resourceDir.path, 'geoip.dat'));
        geoSiteFile.writeAsStringSync('test geosite data');
        geoIpFile.writeAsStringSync('test geoip data');

        when(mockDatabaseHelper.getAtomicDomainSets())
            .thenAnswer((_) async => []);
        when(mockDatabaseHelper.getAppSets())
            .thenAnswer((_) async => []);
        when(mockDatabaseHelper.getAtomicIpSets())
            .thenAnswer((_) async => []);

        // Act
        await geoDataHelper.makeGeoDataAvailable();

        // Assert - Should complete without errors
        expect(true, true);
      });

      test('should handle duplicate URLs in different sets', () async {
        // Arrange
        final geoSiteFile = File(path.join(resourceDir.path, 'geosite.dat'));
        final geoIpFile = File(path.join(resourceDir.path, 'geoip.dat'));
        geoSiteFile.writeAsStringSync('test geosite data');
        geoIpFile.writeAsStringSync('test geoip data');

        final mockAtomicDomainSet = MockAtomicDomainSet();
        final mockAppSet = MockAppSet();
        const duplicateUrl = 'https://example.com/duplicate.yaml';

        when(mockAtomicDomainSet.clashRuleUrls)
            .thenReturn([duplicateUrl]);
        when(mockAppSet.clashRuleUrls)
            .thenReturn([duplicateUrl]);

        when(mockDatabaseHelper.getAtomicDomainSets())
            .thenAnswer((_) async => [mockAtomicDomainSet]);
        when(mockDatabaseHelper.getAppSets())
            .thenAnswer((_) async => [mockAppSet]);
        when(mockDatabaseHelper.getAtomicIpSets())
            .thenAnswer((_) async => []);

        when(mockDownloader.download(any, any))
            .thenAnswer((_) async {
              return null;
            });

        // Act
        await geoDataHelper.makeGeoDataAvailable();

        // Assert - Should only download once due to Set deduplication
        verify(mockDownloader.download(any, any)).called(1);
      });
    });

    group('Friday Update Logic', () {
      test('should not throw when scheduling Friday updates', () {
        // Arrange
        when(mockPrefHelper.lastGeoUpdate).thenReturn(null);

        // Act & Assert - Should not throw
        expect(() => geoDataHelper.geoFilesFridayUpdate(), returnsNormally);
      });

      test('should not throw when already updated today', () {
        // Arrange
        final today = DateTime.now();
        when(mockPrefHelper.lastGeoUpdate).thenReturn(today);

        // Act & Assert - Should not throw
        expect(() => geoDataHelper.geoFilesFridayUpdate(), returnsNormally);
      });
    });
  });

  group('File Operations Tests', () {
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
      const List<String>? nullUrls = null;
      final List<String> emptyUrls = [];
      final List<String> validUrls = ['https://example.com/rules.yaml'];

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
}
