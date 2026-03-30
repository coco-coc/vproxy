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
import 'dart:math';

import 'package:tm/protos/vx/common/geo/geo.pb.dart';
import 'package:tm/protos/vx/common/net/net.pb.dart';
import 'package:tm/protos/vx/outbound/outbound.pb.dart';
import 'package:vx/common/const.dart';
import 'package:flutter_common/util/net.dart';

bool ipIsCfCdn(String ip) {
  return cfCdnIp4Ranges.any((range) => isIpInRange(ip, range)) ||
      cfCdnIp6Ranges.any((range) => isIpInRange(ip, range));
}

enum CDN {
  cloudflare();

  const CDN();
}

CDN? ipToCdn(String ip) {
  if (ipIsCfCdn(ip)) {
    return CDN.cloudflare;
  }
  return null;
}

CIDR ipToCidr(String ip) {
  final address = InternetAddress(ip);
  return CIDR(
    ip: address.rawAddress,
    prefix: address.type == InternetAddressType.IPv4 ? 32 : 128,
  );
}

String portString(OutboundHandlerConfig config) {
  final ret = portRangesToString(config.ports);
  if (ret.isNotEmpty) {
    return ret;
  }
  if (config.port != 0) {
    return config.port.toString();
  }
  return '';
}

String portRangesToString(List<PortRange> ranges) {
  final segments = <String>[];
  for (var range in ranges) {
    if (range.from == range.to) {
      segments.add('${range.from}');
    } else {
      segments.add('${range.from}-${range.to}');
    }
  }
  return segments.join(',');
}
