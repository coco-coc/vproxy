import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Future<String> getUniqueDeviceId() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'unique_device_id';

  // Check if we already have a stored device ID
  String? deviceId = prefs.getString(key);
  if (deviceId != null && deviceId.isNotEmpty) {
    return deviceId;
  }

  // Fallback to UUID if hardware ID is not available
  deviceId ??= const Uuid().v4();

  // Store for future use
  await prefs.setString(key, deviceId);
  return deviceId;
}
