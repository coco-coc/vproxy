import 'package:flutter_test/flutter_test.dart';
import 'package:vx/utils/desktop_installed_apps.dart';


void main() {
  test('DesktopInstalledApps', () async {
    final apps = await DesktopInstalledApps.getInstalledApps();
    print(apps);
  });
}