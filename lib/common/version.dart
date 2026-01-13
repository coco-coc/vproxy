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

bool versionNewerThan(String version1, String version2) {
  final version1Parts = version1.split('.');
  final version2Parts = version2.split('.');
  for (int i = 0; i < version1Parts.length; i++) {
    if (int.parse(version1Parts[i]) > int.parse(version2Parts[i])) {
      return true;
    } else if (int.parse(version1Parts[i]) < int.parse(version2Parts[i])) {
      return false;
    }
  }
  return false;
}
