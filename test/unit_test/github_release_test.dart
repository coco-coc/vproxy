import 'package:flutter_test/flutter_test.dart';
import 'package:vx/utils/github_release.dart';

void main() {
  group('GitHubReleaseService', () {
    test('should check for updates', () async {
      final versionAndUrl = await GitHubReleaseService.checkForUpdates('1.0.0');
      expect(versionAndUrl, isNotNull);
    });
  });
}
