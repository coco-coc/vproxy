import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vx/utils/os.dart';


void checkDesktopArchitecture() {
  // Check the operating system
  print('Operating System: ${Platform.operatingSystem}');

  // Check the operating system version
  print('OS Version: ${Platform.operatingSystemVersion}');

  // Check the architecture
  print('Architecture: ${Platform.localHostname}');

  if (Platform.isLinux) {
    print('Linux Architecture: ${Platform.environment['PROCESSOR_ARCHITECTURE']}');
  } else if (Platform.isMacOS) {
    print('MacOS Architecture: ${Platform.environment['PROCESSOR_ARCHITECTURE']}');
  } else if (Platform.isWindows) {
    print('Windows Architecture: ${Platform.environment['PROCESSOR_ARCHITECTURE']}');
  }
}


void main() {
  test('test', () async {
    final a = await arch();
    print('Architecture: $a');
  });
}
