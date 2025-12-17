import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:vx/utils/auto_update_service.dart';
import 'package:vx/utils/download.dart';
import 'package:vx/pref_helper.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auto_update_service_test.mocks.dart';

@GenerateMocks([Downloader, PrefHelper])
void main() {
  test('test', () {
    final downloader = MockDownloader();
    when(downloader.downloadProxyFirst(any, any)).thenAnswer((_) async {
      return;
    });

    final prefHelper = MockPrefHelper();
    final autoUpdateService = AutoUpdateService(
        prefHelper: prefHelper,
        currentVersion: '1.0.0',
        downloader: downloader,
        checkForUpdate: (version, url) async {
          return ('1.0.0', 'https://example.com/vx-arm64-v8a.apk.zip');
        });
    autoUpdateService.checkAndUpdate();
  });
}
