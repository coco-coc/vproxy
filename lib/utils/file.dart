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

import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'dart:io';

/// Encrypt a file using AES-256
Future<File> encryptFile(File inputFile, String password) async {
  // Read the file
  final bytes = await inputFile.readAsBytes();

  // Encrypt the bytes
  final encryptedBytes = encryptBytes(bytes, password);

  // Create output file
  final outputPath = '${inputFile.path}.encrypted';
  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(encryptedBytes);

  return outputFile;
}

/// Decrypt a file using AES-256
Future<File> decryptFile(File inputFile, String password) async {
  // Read the encrypted file
  final bytes = await inputFile.readAsBytes();

  // Decrypt the bytes
  final decryptedBytes = decryptBytes(bytes, password);

  // Create output file
  final outputPath = inputFile.path.replaceAll('.encrypted', '.decrypted');
  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(decryptedBytes);

  return outputFile;
}

/// Encrypt bytes using AES-256
/// Returns: [salt (16 bytes)] + [IV (16 bytes)] + [encrypted data]
Uint8List encryptBytes(Uint8List data, String password) {
  // Generate a random salt and IV
  final random = Random.secure();
  final salt =
      Uint8List.fromList(List<int>.generate(16, (i) => random.nextInt(256)));
  final iv = encrypt.IV.fromSecureRandom(16);

  // Derive encryption key from password
  final key = _deriveKeyFromPassword(password, salt);

  // Encrypt the data
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  final encrypted = encrypter.encryptBytes(data, iv: iv);

  // Combine: [salt (16 bytes)] + [IV (16 bytes)] + [encrypted data]
  final output = BytesBuilder();
  output.add(salt);
  output.add(iv.bytes);
  output.add(encrypted.bytes);

  return output.toBytes();
}

/// Decrypt bytes using AES-256
/// Input format: [salt (16 bytes)] + [IV (16 bytes)] + [encrypted data]
Uint8List decryptBytes(Uint8List encryptedData, String password) {
  if (encryptedData.length < 32) {
    throw Exception('Invalid encrypted data: too small');
  }

  // Extract salt, IV, and encrypted data
  final salt = Uint8List.fromList(encryptedData.sublist(0, 16));
  final iv = encrypt.IV(Uint8List.fromList(encryptedData.sublist(16, 32)));
  final ciphertext = encryptedData.sublist(32);

  // Derive decryption key from password
  final key = _deriveKeyFromPassword(password, salt);

  // Decrypt the data
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  final decrypted = encrypter.decryptBytes(
      encrypt.Encrypted(Uint8List.fromList(ciphertext)), iv: iv);

  return Uint8List.fromList(decrypted);
}

/// Generate encryption key from password using PBKDF2
encrypt.Key _deriveKeyFromPassword(String password, Uint8List salt) {
  // Use PBKDF2 to derive a secure key from password
  final bytes = utf8.encode(password);
  final hmac = Hmac(sha256, salt);

  // Simple PBKDF2 implementation (for production, use a proper PBKDF2 library)
  var result = hmac.convert(bytes).bytes;
  for (int i = 1; i < 10000; i++) {
    result = hmac.convert(result).bytes;
  }

  return encrypt.Key(Uint8List.fromList(result));
}
