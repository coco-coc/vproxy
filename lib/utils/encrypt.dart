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
