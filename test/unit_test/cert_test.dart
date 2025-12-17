import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vx/utils/cert.dart';

void main() {
  test('test generate cert', () async {
    final cert = await getCertificate();
    print(utf8.decode(cert.certificate));
    print(utf8.decode(cert.key));
  });
}
