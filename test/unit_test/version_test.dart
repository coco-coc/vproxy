import 'package:flutter_test/flutter_test.dart';
import 'package:vx/common/version.dart';

void main() {
  group('versionNewerThan', () {
    test('should return true when version1 is newer than version2', () {
      expect(versionNewerThan('2.0.0', '1.0.0'), isTrue);
      expect(versionNewerThan('1.2.0', '1.1.0'), isTrue);
      expect(versionNewerThan('1.1.1', '1.1.0'), isTrue);
      expect(versionNewerThan('10.0.0', '9.9.9'), isTrue);
    });

    test('should return false when version1 is older than version2', () {
      expect(versionNewerThan('1.0.0', '2.0.0'), isFalse);
      expect(versionNewerThan('1.1.0', '1.2.0'), isFalse);
      expect(versionNewerThan('1.1.0', '1.1.1'), isFalse);
      expect(versionNewerThan('9.9.9', '10.0.0'), isFalse);
    });

    test('should return false when versions are equal', () {
      expect(versionNewerThan('1.0.0', '1.0.0'), isFalse);
      expect(versionNewerThan('2.1.3', '2.1.3'), isFalse);
      expect(versionNewerThan('0.0.0', '0.0.0'), isFalse);
    });


    test('should handle single segment versions', () {
      expect(versionNewerThan('2', '1'), isTrue);
      expect(versionNewerThan('1', '2'), isFalse);
      expect(versionNewerThan('1', '1'), isFalse);
    });

    test('should handle two segment versions', () {
      expect(versionNewerThan('2.1', '2.0'), isTrue);
      expect(versionNewerThan('2.0', '2.1'), isFalse);
      expect(versionNewerThan('2.0', '2.0'), isFalse);
    });

    test('should handle large version numbers', () {
      expect(versionNewerThan('999.999.999', '998.999.999'), isTrue);
      expect(versionNewerThan('1000.0.0', '999.999.999'), isTrue);
    });

    test('should handle zero versions', () {
      expect(versionNewerThan('0.1.0', '0.0.0'), isTrue);
      expect(versionNewerThan('0.0.0', '0.1.0'), isFalse);
      expect(versionNewerThan('0.0.0', '0.0.0'), isFalse);
    });

    test('should handle very long version strings', () {
      expect(versionNewerThan('1.2.3.4.5.6.7.8.9.10', '1.2.3.4.5.6.7.8.9.9'), isTrue);
      expect(versionNewerThan('1.2.3.4.5.6.7.8.9.9', '1.2.3.4.5.6.7.8.9.10'), isFalse);
    });

    test('should handle semantic versioning examples', () {
      // Major version differences
      expect(versionNewerThan('2.0.0', '1.9.9'), isTrue);
      expect(versionNewerThan('1.9.9', '2.0.0'), isFalse);
      
      // Minor version differences
      expect(versionNewerThan('1.2.0', '1.1.9'), isTrue);
      expect(versionNewerThan('1.1.9', '1.2.0'), isFalse);
      
      // Patch version differences
      expect(versionNewerThan('1.1.2', '1.1.1'), isTrue);
      expect(versionNewerThan('1.1.1', '1.1.2'), isFalse);
    });
  });
}
