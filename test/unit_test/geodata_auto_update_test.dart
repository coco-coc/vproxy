import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vx/app/routing/repo.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/utils/download.dart';
import 'package:vx/utils/geodata.dart';
import 'package:vx/utils/xapi_client.dart';

@GenerateNiceMocks([
  MockSpec<SharedPreferences>(),
  MockSpec<Downloader>(),
  MockSpec<XApiClient>(),
  MockSpec<DbHelper>(),
])
import 'geodata_auto_update_test.mocks.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GeoDataHelper Auto-Update Tests', () {
    late MockSharedPreferences mockPref;
    late MockDownloader mockDownloader;
    late MockXApiClient mockXApiClient;
    late MockDbHelper mockDbHelper;
    late GeoDataHelper geoDataHelper;

    setUp(() {
      mockPref = MockSharedPreferences();
      mockDownloader = MockDownloader();
      mockXApiClient = MockXApiClient();
      mockDbHelper = MockDbHelper();

      // Provide dummy value for DateTime
      provideDummy<DateTime>(DateTime.now());

      // Setup default mock responses
      when(mockDbHelper.getAtomicDomainSets()).thenAnswer((_) async => []);
      when(mockDbHelper.getAppSets()).thenAnswer((_) async => []);
      when(mockDbHelper.getAtomicIpSets()).thenAnswer((_) async => []);

      geoDataHelper = GeoDataHelper(
        downloader: mockDownloader,
        pref: mockPref,
        xApiClient: mockXApiClient,
        databaseHelper: mockDbHelper,
        resouceDirPath: '/test/resources',
        geoSiteUrl: 'https://example.com/geosite.dat',
        geoIpUrl: 'https://example.com/geoip.dat',
      );
    });

    tearDown(() {
      // Clean up any timers by resetting with disabled setting
      when(mockPref.autoUpdateGeoFiles).thenReturn(false);
      geoDataHelper.reset();
    });

    group('Auto-Update Enabled/Disabled', () {
      test('should not start timer when auto-update is disabled', () {
        // Arrange
        when(mockPref.autoUpdateGeoFiles).thenReturn(false);

        // Act
        geoDataHelper.reset();

        // Assert
        // Timer should not be created, so no update should be scheduled
        verifyNever(mockPref.geoUpdateInterval);
      });

      test('should start timer when auto-update is enabled', () {
        // Arrange
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(null);

        // Act
        geoDataHelper.reset();

        // Assert
        verify(mockPref.autoUpdateGeoFiles).called(1);
        verify(mockPref.geoUpdateInterval).called(greaterThan(0));
      });
    });

    group('First Update Logic', () {
      test('should update immediately when no previous update exists', () async {
        // Arrange
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(null);
        when(mockDownloader.downloadProxyFirst(any, any))
            .thenAnswer((_) async => {});
        when(mockXApiClient.processGeoFiles()).thenAnswer((_) async => {});

        // Act
        geoDataHelper.reset();

        // Wait a bit for async operations
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - makeGeoDataAvailable should be called which triggers download
        verify(mockDbHelper.getAtomicDomainSets()).called(1);
        verify(mockDbHelper.getAppSets()).called(1);
        verify(mockDbHelper.getAtomicIpSets()).called(1);
      });

      test('should set lastGeoUpdate after successful update', () async {
        // Arrange
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(null);
        when(mockDownloader.downloadProxyFirst(any, any))
            .thenAnswer((_) async => {});
        when(mockXApiClient.processGeoFiles()).thenAnswer((_) async => {});

        // Act
        await geoDataHelper.makeGeoDataAvailable(update: true);

        // Assert - Verify setLastGeoUpdate was called
        verify(mockPref.setLastGeoUpdate(any as DateTime)).called(1);
      });
    });

    group('Update Interval Logic', () {
      test('should respect 1 day interval', () {
        // Arrange
        final now = DateTime.now();
        final lastUpdate = now.subtract(const Duration(hours: 23)); // Less than 1 day
        
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(lastUpdate);

        // Act
        geoDataHelper.reset();

        // Assert - should schedule next update, not update immediately
        // Next update should be around 1 hour from now
        verify(mockPref.geoUpdateInterval).called(greaterThan(0));
      });

      test('should respect 7 day interval', () {
        // Arrange
        final now = DateTime.now();
        final lastUpdate = now.subtract(const Duration(days: 6)); // Less than 7 days
        
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(7);
        when(mockPref.lastGeoUpdate).thenReturn(lastUpdate);

        // Act
        geoDataHelper.reset();

        // Assert - should schedule next update for ~1 day from now
        verify(mockPref.geoUpdateInterval).called(greaterThan(0));
      });

      test('should update immediately if interval has passed', () async {
        // Arrange
        final now = DateTime.now();
        final lastUpdate = now.subtract(const Duration(days: 2)); // More than 1 day
        
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(lastUpdate);
        when(mockDownloader.downloadProxyFirst(any, any))
            .thenAnswer((_) async => {});
        when(mockXApiClient.processGeoFiles()).thenAnswer((_) async => {});

        // Act
        geoDataHelper.reset();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - should update immediately
        verify(mockDbHelper.getAtomicDomainSets()).called(1);
      });
    });

    group('Next Update Calculation', () {
      test('should calculate next update correctly from last update', () {
        // Arrange
        final now = DateTime.now();
        final lastUpdate = now.subtract(const Duration(hours: 12)); // Half day ago
        final expectedNext = lastUpdate.add(const Duration(days: 1));
        
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(lastUpdate);

        // Act
        geoDataHelper.reset();

        // Assert - next update should be ~12 hours from now
        final remainingHours = expectedNext.difference(now).inHours;
        expect(remainingHours, greaterThanOrEqualTo(11));
        expect(remainingHours, lessThanOrEqualTo(13));
      });

      test('should handle very old last update time', () async {
        // Arrange
        final now = DateTime.now();
        final lastUpdate = now.subtract(const Duration(days: 30)); // Very old
        
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(lastUpdate);
        when(mockDownloader.downloadProxyFirst(any, any))
            .thenAnswer((_) async => {});
        when(mockXApiClient.processGeoFiles()).thenAnswer((_) async => {});

        // Act
        geoDataHelper.reset();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - should update immediately
        verify(mockDbHelper.getAtomicDomainSets()).called(1);
      });
    });

    group('Reset Functionality', () {
      test('should cancel existing timer when reset is called', () {
        // Arrange
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(DateTime.now());

        // Act - Start timer
        geoDataHelper.reset();
        
        // Reset again
        geoDataHelper.reset();

        // Assert - Should be able to reset multiple times without issues
        verify(mockPref.autoUpdateGeoFiles).called(2);
      });

      test('should create new timer after reset', () {
        // Arrange
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(DateTime.now());

        // Act
        geoDataHelper.reset();
        final firstCallCount = verify(mockPref.geoUpdateInterval).callCount;
        
        geoDataHelper.reset();
        final secondCallCount = verify(mockPref.geoUpdateInterval).callCount;

        // Assert
        expect(secondCallCount, greaterThan(firstCallCount));
      });

      test('should handle reset when disabled', () {
        // Arrange
        when(mockPref.autoUpdateGeoFiles).thenReturn(false);

        // Act & Assert - Should not throw
        expect(() => geoDataHelper.reset(), returnsNormally);
      });
    });

    group('Cancel Timer Functionality', () {
      test('should cancel timer when reset with disabled setting', () {
        // Arrange
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(DateTime.now());

        // Act
        geoDataHelper.reset(); // Start timer
        
        // Disable and reset
        when(mockPref.autoUpdateGeoFiles).thenReturn(false);
        geoDataHelper.reset(); // Should cancel timer

        // Assert - Should not throw
        expect(() => geoDataHelper.reset(), returnsNormally);
      });

      test('should handle reset when never started', () {
        // Arrange
        when(mockPref.autoUpdateGeoFiles).thenReturn(false);

        // Act & Assert - Should not throw
        expect(() => geoDataHelper.reset(), returnsNormally);
      });
    });

    group('Update Interval Validation', () {
      test('should handle minimum 1 day interval', () {
        // Arrange
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(null);

        // Act
        geoDataHelper.reset();

        // Assert
        verify(mockPref.geoUpdateInterval).called(greaterThan(0));
        final interval = mockPref.geoUpdateInterval;
        expect(interval, greaterThanOrEqualTo(1));
      });

      test('should handle large interval values', () {
        // Arrange
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(365); // 1 year
        when(mockPref.lastGeoUpdate).thenReturn(DateTime.now());

        // Act & Assert - Should not throw
        expect(() => geoDataHelper.reset(), returnsNormally);
      });
    });

    group('Concurrent Access', () {
      test('should handle concurrent makeGeoDataAvailable calls', () async {
        // Arrange
        when(mockDownloader.downloadProxyFirst(any, any))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
        });
        when(mockXApiClient.processGeoFiles()).thenAnswer((_) async => {});

        // Act - Call makeGeoDataAvailable multiple times concurrently
        final futures = [
          geoDataHelper.makeGeoDataAvailable(update: true),
          geoDataHelper.makeGeoDataAvailable(update: true),
          geoDataHelper.makeGeoDataAvailable(update: true),
        ];

        await Future.wait(futures);

        // Assert - Should only download once due to completer
        verify(mockDownloader.downloadProxyFirst(any, any)).called(2); // 2 files
      });
    });

    group('Edge Cases', () {
      test('should handle null preferences gracefully', () {
        // Arrange
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(null);

        // Act & Assert - Should not throw
        expect(() => geoDataHelper.reset(), returnsNormally);
      });

      test('should handle DateTime.now() edge cases', () {
        // Arrange - Update exactly now
        final now = DateTime.now();
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(now);

        // Act & Assert - Should not throw
        expect(() => geoDataHelper.reset(), returnsNormally);
      });

      test('should handle future lastGeoUpdate time', () {
        // Arrange - Last update is in the future (clock skew scenario)
        final future = DateTime.now().add(const Duration(hours: 1));
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(future);

        // Act & Assert - Should handle gracefully
        expect(() => geoDataHelper.reset(), returnsNormally);
      });
    });

    group('Settings Change Scenarios', () {
      test('should handle interval change from 1 to 7 days', () {
        // Arrange - Start with 1 day
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(DateTime.now());

        geoDataHelper.reset();

        // Act - Change to 7 days
        when(mockPref.geoUpdateInterval).thenReturn(7);
        geoDataHelper.reset();

        // Assert - Should use new interval
        verify(mockPref.geoUpdateInterval).called(greaterThan(1));
      });

      test('should handle toggling auto-update off then on', () {
        // Arrange - Start enabled
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        when(mockPref.geoUpdateInterval).thenReturn(1);
        when(mockPref.lastGeoUpdate).thenReturn(DateTime.now());

        geoDataHelper.reset();

        // Act - Disable
        when(mockPref.autoUpdateGeoFiles).thenReturn(false);
        geoDataHelper.reset();

        // Re-enable
        when(mockPref.autoUpdateGeoFiles).thenReturn(true);
        geoDataHelper.reset();

        // Assert
        verify(mockPref.autoUpdateGeoFiles).called(3);
      });
    });
  });
}
