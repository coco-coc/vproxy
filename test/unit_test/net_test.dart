import 'package:flutter_test/flutter_test.dart';
import 'package:tm/protos/common/net/net.pb.dart';
import 'package:vx/common/net.dart';

void main() {
  test('test portRangesToString', () async {
    // get a response
    final response = portRangesToString([PortRange(from: 1, to: 10)]);
    expect(response, '1-10');

    final response2 = portRangesToString([PortRange(from: 1, to: 10), PortRange(from: 11, to: 20)]);
    expect(response2, '1-10,11-20');

    final response3 = portRangesToString([PortRange(from: 1, to: 10), PortRange(from: 11, to: 11)]);
    expect(response3, '1-10,11');

    final response4 = portRangesToString([]);
    expect(response4, '');

    final response5 = portRangesToString([PortRange(from: 1, to: 1)]);
    expect(response5, '1');
  });
}
