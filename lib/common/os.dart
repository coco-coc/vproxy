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

String getCpuArch() {
  // Get the Dart VM version string which contains architecture information
  final vmVersion = Platform.version.toLowerCase();
  
  if (vmVersion.contains('arm64') || vmVersion.contains('aarch64')) {
    return 'arm64';
  } else if (vmVersion.contains('x64') || vmVersion.contains('x86_64') || vmVersion.contains('amd64')) {
    return 'amd64';
  } else if (vmVersion.contains('arm')) {
    return 'arm';
  } else if (vmVersion.contains('x86') || vmVersion.contains('ia32')) {
    return 'x86';
  } else {
    return 'unknown';
  }
}