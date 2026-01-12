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
import 'package:vx/data/sync.pb.dart';
import 'package:vx/utils/file.dart';

/// Encrypt raw bytes to base64 string (general purpose)
String encryptToBase64(Uint8List data, String password) {
  final encryptedBytes = encryptBytes(data, password);
  return base64Encode(encryptedBytes);
}

/// Decrypt base64 string back to raw bytes (general purpose)
Uint8List decryptFromBase64(String encryptedBase64, String password) {
  final encryptedBytes = base64Decode(encryptedBase64);
  return decryptBytes(encryptedBytes, password);
}
