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

import 'dart:convert';
import 'dart:typed_data';

String decodeBase64(String str) {
  String padded = str;
  // Add padding if necessary
  switch (str.length % 4) {
    case 2:
      padded += '==';
      break;
    case 3:
      padded += '=';
      break;
  }
  return String.fromCharCodes(base64Decode(padded));
}

Uint8List decodeBase64Url(String encodedString) {
  // Add padding if needed
  final padded = base64.normalize(encodedString);

  // Decode the base64url string
  final bytes = base64Url.decode(padded);
  // Convert bytes to string
  return bytes;
}

List<int> stringToBytesUtf8(String str) {
  return utf8.encode(str);
}

bool isBase64(String str) {
  // Check if the string consists only of valid base64 characters
  final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');

  // 1. Basic check for valid characters
  if (!base64Regex.hasMatch(str)) {
    return false;
  }

  // 2. Check for valid length (must be multiple of 4)
  if (str.length % 4 != 0) {
    return false;
  }

  // 3. Try decoding and catch errors
  try {
    base64.decode(str);
    return true;
  } catch (e) {
    return false;
  }
}
