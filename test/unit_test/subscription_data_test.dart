import 'package:flutter_test/flutter_test.dart';
import 'package:vx/app/outbound/subscription_page.dart';

void main() {
  group('SubscriptionData.parse', () {
    group('Standard format', () {
      test('should parse standard format with all fields', () {
        const description =
            'STATUS=🚀↑:1.42GB,↓:4.48GB,TOT:200GB💡Expires:2025-12-04';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '200GB');
        expect(result.usedData, '5.90GB');
        expect(result.remainingData, '194.10GB');
        expect(result.expirationDate, DateTime(2025, 12, 4));
        expect(result.usagePercentage, closeTo(0.0295, 0.001));
      });

      test('should parse standard format with different units', () {
        const description = '↑:100MB,↓:200MB,TOT:1GB';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '1GB');
        // Note: The parser doesn't convert units, it just adds numeric values
        expect(result.usedData, '300.00GB');
        expect(result.remainingData, '-299.00GB');
      });

      test('should parse standard format with KB units', () {
        const description = '↑:100KB,↓:200KB,TOT:1MB';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '1MB');
        // Note: The parser doesn't convert units, it just adds numeric values
        expect(result.usedData, '300.00GB');
        expect(result.remainingData, '-299.00GB');
      });

      test('should parse standard format with decimal values', () {
        const description = '↑:1.5GB,↓:2.75GB,TOT:10GB';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '10GB');
        expect(result.usedData, '4.25GB');
        expect(result.remainingData, '5.75GB');
        expect(result.usagePercentage, closeTo(0.425, 0.001));
      });

      test('should parse standard format without expiration date', () {
        const description = '↑:1GB,↓:2GB,TOT:10GB';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '10GB');
        expect(result.usedData, '3.00GB');
        expect(result.remainingData, '7.00GB');
        expect(result.expirationDate, isNull);
      });

      test('should parse standard format with "Expire" (singular)', () {
        const description = '↑:1GB,↓:2GB,TOT:10GB Expire:2025-12-04';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.expirationDate, DateTime(2025, 12, 4));
      });

      test('should parse standard format with only TOT field', () {
        const description = 'TOT:100GB';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '100GB');
        expect(result.usedData, isNull);
        expect(result.remainingData, isNull);
      });
    });

    group('Chinese format', () {
      test('should parse Chinese format with remaining data and expiration',
          () {
        const description = '剩余流量: 12.165GB。到期: 2025年11月20日 15时。';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.remainingData, '12.165GB');
        expect(result.expirationDate, DateTime(2025, 11, 20));
      });

      test('should parse Chinese format with colon separator', () {
        const description = '剩余流量: 5.5GB。到期: 2024年1月5日';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.remainingData, '5.5GB');
        expect(result.expirationDate, DateTime(2024, 1, 5));
      });

      test('should parse Chinese format with full-width colon', () {
        const description = '剩余流量：10GB。到期：2025年12月31日';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.remainingData, '10GB');
        expect(result.expirationDate, DateTime(2025, 12, 31));
      });

      test('should parse Chinese format with no expiration date', () {
        const description = '剩余流量：10GB。到期：不过期';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.remainingData, '10GB');
        expect(result.expirationDate, DateTime(9999, 12, 31));
      });

      test('should parse Chinese format with different units', () {
        const description = '剩余流量: 500MB。到期: 2025年1月1日';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.remainingData, '500MB');
        expect(result.expirationDate, DateTime(2025, 1, 1));
      });

      test('should parse Chinese format with only remaining data', () {
        const description = '剩余流量: 10GB。';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.remainingData, '10GB');
        expect(result.expirationDate, isNull);
      });

      test('should parse Chinese format with single digit month and day', () {
        const description = '剩余流量: 5GB。到期: 2025年1月5日';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.expirationDate, DateTime(2025, 1, 5));
      });
    });

    group('Key-value format', () {
      test('should parse key-value format with all fields', () {
        const description =
            'upload=1234; download=2234; total=1024000; expire=2218532293';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        // 1024000 bytes = 1000KB
        expect(result!.totalData, '1000.00KB');
        // 1234 + 2234 = 3468 bytes = 3.39KB
        expect(result.usedData, '3.39KB');
        // 1024000 - 3468 = 1020532 bytes = 996.61KB
        expect(result.remainingData, '996.61KB');
        expect(result.expirationDate, isNotNull);
        expect(result.usagePercentage, closeTo(0.0034, 0.001));
      });

      test('should parse key-value format with large values in GB', () {
        // 10GB = 10 * 1024 * 1024 * 1024 bytes
        const totalBytes = 10 * 1024 * 1024 * 1024;
        const uploadBytes = 2 * 1024 * 1024 * 1024;
        const downloadBytes = 3 * 1024 * 1024 * 1024;
        const expireTimestamp = 1735689600; // 2025-01-01 00:00:00 UTC

        const description =
            'upload=$uploadBytes; download=$downloadBytes; total=$totalBytes; expire=$expireTimestamp';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '10.00GB');
        expect(result.usedData, '5.00GB');
        expect(result.remainingData, '5.00GB');
        expect(
            result.expirationDate,
            DateTime.fromMillisecondsSinceEpoch(expireTimestamp * 1000,
                isUtc: true));
        expect(result.usagePercentage, closeTo(0.5, 0.01));
      });

      test('should parse key-value format with MB values', () {
        // 100MB = 100 * 1024 * 1024 bytes
        const totalBytes = 100 * 1024 * 1024;
        const uploadBytes = 20 * 1024 * 1024;
        const downloadBytes = 30 * 1024 * 1024;
        const expireTimestamp = 1735689600;

        const description =
            'upload=$uploadBytes; download=$downloadBytes; total=$totalBytes; expire=$expireTimestamp';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '100.00MB');
        expect(result.usedData, '50.00MB');
        expect(result.remainingData, '50.00MB');
        expect(result.usagePercentage, closeTo(0.5, 0.01));
      });

      test('should parse key-value format with KB values', () {
        // 1MB = 1024 * 1024 bytes
        const totalBytes = 1024 * 1024;
        const uploadBytes = 200 * 1024;
        const downloadBytes = 300 * 1024;
        const expireTimestamp = 1735689600;

        const description =
            'upload=$uploadBytes; download=$downloadBytes; total=$totalBytes; expire=$expireTimestamp';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '1.00MB');
        expect(result.usedData, '500.00KB');
        expect(result.remainingData, '524.00KB');
      });

      test('should parse key-value format with TB values', () {
        // 1TB = 1024 * 1024 * 1024 * 1024 bytes
        const totalBytes = 1024 * 1024 * 1024 * 1024;
        const uploadBytes = 200 * 1024 * 1024 * 1024;
        const downloadBytes = 300 * 1024 * 1024 * 1024;
        const expireTimestamp = 1735689600;

        const description =
            'upload=$uploadBytes; download=$downloadBytes; total=$totalBytes; expire=$expireTimestamp';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '1.00TB');
        expect(result.usedData, '500.00GB');
        expect(result.remainingData, '524.00GB');
      });

      test('should parse key-value format with whitespace variations', () {
        const description =
            'upload = 1234 ; download = 2234 ; total = 1024000 ; expire = 2218532293';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '1000.00KB');
        expect(result.usedData, '3.39KB');
      });

      test('should parse key-value format without spaces', () {
        const description =
            'upload=1234;download=2234;total=1024000;expire=2218532293';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '1000.00KB');
        expect(result.usedData, '3.39KB');
      });

      test('should parse key-value format with zero expire timestamp', () {
        const description =
            'upload=1000000; download=2000000; total=10000000; expire=0';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        // 10000000 bytes = 9.54MB
        expect(result!.totalData, '9.54MB');
        expect(result.expirationDate, isNull);
      });

      test('should parse key-value format case-insensitively', () {
        const description =
            'UPLOAD=1234; DOWNLOAD=2234; TOTAL=1024000; EXPIRE=2218532293';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '1000.00KB');
        expect(result.usedData, '3.39KB');
      });
    });

    group('Edge cases', () {
      test('should return SubscriptionData with null fields for empty string',
          () {
        const description = '';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, isNull);
        expect(result.usedData, isNull);
        expect(result.remainingData, isNull);
        expect(result.expirationDate, isNull);
        expect(result.usagePercentage, isNull);
      });

      test('should return SubscriptionData with null fields for invalid format',
          () {
        const description = 'This is not a valid subscription description';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, isNull);
        expect(result.usedData, isNull);
        expect(result.remainingData, isNull);
        expect(result.expirationDate, isNull);
        expect(result.usagePercentage, isNull);
      });

      test('should handle standard format with missing upload field', () {
        const description = '↓:2GB,TOT:10GB';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '10GB');
        expect(result.usedData, isNull);
        expect(result.remainingData, isNull);
      });

      test('should handle standard format with missing download field', () {
        const description = '↑:1GB,TOT:10GB';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '10GB');
        expect(result.usedData, isNull);
        expect(result.remainingData, isNull);
      });

      test('should calculate usage percentage correctly when total is zero',
          () {
        const description = 'upload=0; download=0; total=0; expire=2218532293';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.usagePercentage, 0.0);
      });

      test('should handle very large byte values', () {
        // 100TB
        const totalBytes = 100 * 1024 * 1024 * 1024 * 1024;
        const uploadBytes = 10 * 1024 * 1024 * 1024 * 1024;
        const downloadBytes = 20 * 1024 * 1024 * 1024 * 1024;
        const expireTimestamp = 1735689600;

        const description =
            'upload=$uploadBytes; download=$downloadBytes; total=$totalBytes; expire=$expireTimestamp';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '100.00TB');
        expect(result.usedData, '30.00TB');
        expect(result.remainingData, '70.00TB');
        expect(result.usagePercentage, closeTo(0.3, 0.01));
      });

      test('should handle small byte values', () {
        const description =
            'upload=100; download=200; total=1000; expire=2218532293';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '1000B');
        expect(result.usedData, '300B');
        expect(result.remainingData, '700B');
      });
    });

    group('Format priority', () {
      test('should prioritize Chinese format over key-value format', () {
        const description =
            '剩余流量: 10GB。到期: 2025年1月1日 upload=1234; download=2234; total=1024000; expire=2218532293';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        // Should use Chinese format
        expect(result!.remainingData, '10GB');
        expect(result.expirationDate, DateTime(2025, 1, 1));
        // Should not parse key-value format
        expect(result.totalData, isNull);
        expect(result.usedData, isNull);
      });

      test('should use key-value format when Chinese format does not match',
          () {
        const description =
            'upload=10737418240; download=21474836480; total=107374182400; expire=1735689600';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '100.00GB');
        expect(result.usedData, '30.00GB');
        expect(result.remainingData, '70.00GB');
      });

      test(
          'should fall back to standard format when key-value format does not match',
          () {
        const description = '↑:1GB,↓:2GB,TOT:10GB';
        final result = SubscriptionData.parse(description);

        expect(result, isNotNull);
        expect(result!.totalData, '10GB');
        expect(result.usedData, '3.00GB');
        expect(result.remainingData, '7.00GB');
      });
    });
  });
}
