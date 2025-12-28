import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:vector_graphics/vector_graphics_compat.dart';
import 'package:vx/common/net.dart';
import 'package:vx/utils/logger.dart';

Future<String?> getCountryCode(String address, [http.Client? client]) async {
  final httpClient = client ?? http.Client();
  try {
    String ip = address;
    if (isDomain(address)) {
      final addresses = await InternetAddress.lookup(address);
      if (addresses.isNotEmpty) {
        ip = addresses.first.address;
      }
    }
    // https://free.freeipapi.com/api/json/{ip}
    final url = Uri.parse('https://free.freeipapi.com/api/json/$ip');
    final response = await httpClient.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final countryCode = jsonData['countryCode'] as String?;
      return countryCode;
    } else {
      logger.d('getCountryCode: HTTP ${response.statusCode}');
      return null;
    }
  } catch (e) {
    logger.d('getCountryCode error', error: e);
    return null;
  } finally {
    if (client == null) {
      httpClient.close();
    }
  }
}

Widget getCountryIcon(String countryCode) {
  return SvgPicture(
    height: 24,
    width: 24,
    AssetBytesLoader('assets/icons/flags/${countryCode.toLowerCase()}.svg.vec'),
  );
}
