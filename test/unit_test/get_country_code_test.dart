import 'package:flutter_test/flutter_test.dart';
import 'package:vx/utils/geoip.dart';

void main() {
  test('get country code', () async {
    final countryCode = await getCountryCode('8.8.8.8');
    expect(countryCode, 'US');
  });
}
