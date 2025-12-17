import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vector_graphics/vector_graphics_compat.dart';
import 'package:vx/common/net.dart';
import 'package:tm/protos/app/api/api.pb.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/logger.dart';

Future<String?> getCountryCode(String address) async {
  try {
    String ip = address;
    if (isDomain(address)) {
      final addresses = await InternetAddress.lookup(address);
      if (addresses.isNotEmpty) {
        ip = addresses.first.address;
      }
    }
    final geoIPRsp = await xApiClient.geoIP(GeoIPRequest(ips: [ip]));
    return geoIPRsp.countries.isNotEmpty ? geoIPRsp.countries[0] : null;
  } catch (e) {
    logger.d('getCountryCode error', error: e);
    return null;
  }
}

Widget getCountryIcon(String countryCode) {
  return SvgPicture(
    height: 24,
    width: 24,
    AssetBytesLoader('assets/icons/flags/${countryCode.toLowerCase()}.svg.vec'),
  );
}
