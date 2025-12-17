import 'dart:io';

bool isRpm()  {
  print('isrpm $_rpm');
  return _rpm || isRpmBasedSystem();
}

const _rpm = bool.fromEnvironment('RPM');

bool isRpmBasedSystem() {
  // Define paths to RPM-based system release files
  List<String> rpmReleaseFiles = [
    '/etc/redhat-release',
    '/etc/fedora-release',
    '/etc/centos-release',
    '/etc/rocky-release',
    '/etc/slackware-release',
    '/etc/oracle-release'
  ];

  for (var releaseFile in rpmReleaseFiles) {
    if (File(releaseFile).existsSync()) {
      return true;
    }
  }
  return false;
}

Future<String> arch() async {
  if (Platform.isLinux || Platform.isMacOS) {
    final result = await Process.run('uname', ['-m']);
    if (result.exitCode == 0) {
      return result.stdout.toString().trim();
    }
  } else if (Platform.isWindows) {
    return Platform.environment['PROCESSOR_ARCHITECTURE'] ?? 'unknown';
  }
  return 'unknown';
}