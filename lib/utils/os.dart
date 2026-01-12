// Copyright (C) 2026 5V Network LLC <5vnetwork@proton.me>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

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