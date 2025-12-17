import 'dart:io';
import 'dart:math';

import 'package:tm/protos/common/geo/geo.pb.dart';
import 'package:tm/protos/common/net/net.pb.dart';
import 'package:tm/protos/protos/outbound.pb.dart';
import 'package:vx/common/const.dart';

/// Check if an IP is in a CIDR range.
bool isIpInRange(String ip, String cidr) {
  final parts = cidr.split('/');
  final ipAddress = InternetAddress(ip);
  final networkAddress = InternetAddress(parts[0]);
  final prefixLength = int.parse(parts[1]);

  switch (ipAddress.type) {
    case InternetAddressType.IPv4:
      final ipInt = ipv4ToInt(ipAddress.rawAddress);
      final networkInt = ipv4ToInt(networkAddress.rawAddress);
      final mask = ~((1 << (32 - prefixLength)) - 1);
      return (ipInt & mask) == (networkInt & mask);
    case InternetAddressType.IPv6:
      final ipBytes = ipAddress.rawAddress;
      final networkBytes = networkAddress.rawAddress;
      for (var i = 0; i < 16; i++) {
        final bitOffset = i * 8;
        final remainingBits = prefixLength - bitOffset;
        if (remainingBits <= 0) break;
        final mask =
            remainingBits >= 8 ? 0xFF : (0xFF00 >> remainingBits) & 0xFF;
        if ((ipBytes[i] & mask) != (networkBytes[i] & mask)) {
          return false;
        }
      }
      return true;
    default:
      throw ArgumentError('Invalid IP address');
  }
}

int ipv4ToInt(List<int> bytes) {
  return (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
}

bool ipIsCfCdn(String ip) {
  return cfCdnIp4Ranges.any((range) => isIpInRange(ip, range)) ||
      cfCdnIp6Ranges.any((range) => isIpInRange(ip, range));
}

int getRandomPort() {
  return Random().nextInt(65535 - 1024) + 1024;
}

/// Get an unused port.
///
/// https://stackoverflow.com/questions/14093628/how-can-i-find-an-unused-tcp-port-in-dart
Future<int> getUnusedPort([InternetAddress? address]) {
  return ServerSocket.bind(address ?? InternetAddress.anyIPv4, 0)
      .then((socket) async {
    var port = socket.port;
    await socket.close();
    return port;
  });
}

// TODO
bool isDomain(String domain) {
  final domainRegExp =
      RegExp(r'^(?!\-)([a-zA-Z0-9\-]{1,63}\.?)+(?!\-)([a-zA-Z]{2,})$');
  return domainRegExp.hasMatch(domain);
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

double bytesToMbps(int bytes) {
  return bytes / 1024 / 1024 * 8;
}

int mbpsToBytes(double mbps) {
  return (mbps * 1024 * 1024 / 8).toInt();
}

bool isValidIp(String ip) {
  return InternetAddress.tryParse(ip) != null;
}

bool isValidPort(String port) {
  final portInt = int.tryParse(port);
  return portInt != null && portInt >= 0 && portInt <= 65535;
}

bool isValidPorts(String portRange) {
  final segments = portRange.split(',');
  for (var segment in segments) {
    if (!isValidPort(segment)) {
      return false;
    }
  }
  return true;
}

CIDR ipToCidr(String ip) {
  final address = InternetAddress(ip);
  return CIDR(
      ip: address.rawAddress,
      prefix: address.type == InternetAddressType.IPv4 ? 32 : 128);
}

bool isValidAddressPort(String addressPort) {
  final segments = addressPort.split(':');
  if (segments.length != 2) {
    return false;
  }
  return (isValidIp(segments[0]) || isDomain(segments[0])) &&
      isValidPort(segments[1]);
}

bool isValidCidr(String cidr) {
  final segments = cidr.split('/');
  if (segments.length != 2) {
    return false;
  }
  if (!isValidIp(segments[0])) {
    return false;
  }
  final ip = InternetAddress(segments[0]);
  final prefix = int.tryParse(segments[1]);
  if (prefix == null) {
    return false;
  }
  if (ip.type == InternetAddressType.IPv4) {
    return prefix >= 0 && prefix <= 32;
  } else {
    return prefix >= 0 && prefix <= 128;
  }
}

/// Convert bytes to a human-readable string.
String bytesToReadable(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).round()} KB';
  } else if (bytes < 1024 * 1024 * 1024) {
    final mb = bytes / 1024 / 1024;
    if (mb < 10) {
      return '${mb.toStringAsFixed(1)} MB';
    }
    return '${mb.round()} MB';
  } else {
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }
}

String bytesToReadableCompact(int bytes) {
  if (bytes < 1024) {
    return '${bytes}B';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).round()}KB';
  } else if (bytes < 1024 * 1024 * 1024) {
    final mb = bytes / 1024 / 1024;
    if (mb < 10) {
      return '${mb.toStringAsFixed(1)}MB';
    }
    return '${mb.round()}MB';
  } else {
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)}GB';
  }
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

bool isValidHttpHttpsUrl(String url) {
  // Check if string starts with https://
  if (!url.startsWith('https://')) {
    return false;
  }

  try {
    // Parse the URL and validate it
    final uri = Uri.parse(url);

    // Check for required components
    return uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.host
            .contains('.'); // Basic domain validation (has at least one dot)
  } catch (e) {
    return false;
  }
}
