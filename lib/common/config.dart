import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:tm/protos/google/protobuf/any.pb.dart';
import 'package:tm/protos/common/net/net.pb.dart';
import 'package:tm/protos/protos/proxy/anytls.pb.dart';
import 'package:tm/protos/protos/proxy/dokodemo.pb.dart';
import 'package:tm/protos/protos/proxy/hysteria.pb.dart';
import 'package:tm/protos/protos/proxy/shadowsocks.pb.dart';
import 'package:tm/protos/protos/proxy/socks.pb.dart';
import 'package:tm/protos/protos/proxy/trojan.pb.dart';
import 'package:tm/protos/protos/proxy/vless.pb.dart';
import 'package:tm/protos/protos/proxy/vmess.pb.dart';
import 'package:tm/protos/protos/tls/tls.pb.dart';
import 'package:vx/theme.dart';
import 'package:vx/widgets/outbound_handler_form/outbound_handler_form.dart';

ProxyProtocolLabel getProtocolTypeFromAny(Any any) {
  // unpack the any to the specific config type
  switch (any.typeUrl) {
    case 'type.googleapis.com/x.proxy.ShadowsocksClientConfig' ||
          'type.googleapis.com/x.proxy.ShadowsocksServerConfig':
      return ProxyProtocolLabel.shadowsocks;
    case 'type.googleapis.com/x.proxy.VmessClientConfig' ||
          'type.googleapis.com/x.proxy.VmessServerConfig':
      return ProxyProtocolLabel.vmess;
    case 'type.googleapis.com/x.proxy.TrojanClientConfig' ||
          'type.googleapis.com/x.proxy.TrojanServerConfig':
      return ProxyProtocolLabel.trojan;
    case 'type.googleapis.com/x.proxy.SocksClientConfig' ||
          'type.googleapis.com/x.proxy.SocksServerConfig':
      return ProxyProtocolLabel.socks;
    case 'type.googleapis.com/x.proxy.VlessClientConfig' ||
          'type.googleapis.com/x.proxy.VlessServerConfig':
      return ProxyProtocolLabel.vless;
    case 'type.googleapis.com/x.proxy.Hysteria2ClientConfig' ||
          'type.googleapis.com/x.proxy.Hysteria2ServerConfig':
      return ProxyProtocolLabel.hysteria2;
    case 'type.googleapis.com/x.proxy.AnytlsClientConfig' ||
          'type.googleapis.com/x.proxy.AnytlsServerConfig':
      return ProxyProtocolLabel.anytls;
    case 'type.googleapis.com/x.proxy.DokodemoConfig':
      return ProxyProtocolLabel.dokodemo;
    default:
      throw Exception('unknown protocol: ${any.typeUrl}');
  }
}

final greenColorTheme = ColorScheme.fromSeed(seedColor: ShimmerGreen);
final pinkColorTheme = ColorScheme.fromSeed(seedColor: XPink);
final purpleColorTheme = ColorScheme.fromSeed(seedColor: ShimmerPurple);

enum ProxyProtocolLabel {
  vmess('VMess'),
  trojan('Trojan'),
  vless('VLESS'),
  shadowsocks('Shadowsocks'),
  socks('Socks'),
  hysteria2('Hysteria2'),
  anytls('AnyTLS'),
  dokodemo('Dokodemo');

  const ProxyProtocolLabel(this.label);
  final String label;

  @override
  String toString() {
    return label;
  }

  GeneratedMessage serverConfig() {
    switch (this) {
      case ProxyProtocolLabel.vmess:
        return VmessServerConfig();
      case ProxyProtocolLabel.trojan:
        return TrojanServerConfig();
      case ProxyProtocolLabel.vless:
        return VlessServerConfig();
      case ProxyProtocolLabel.shadowsocks:
        return ShadowsocksServerConfig();
      case ProxyProtocolLabel.socks:
        return SocksServerConfig();
      case ProxyProtocolLabel.hysteria2:
        return getDefaultHysteriaServerConfig();
      case ProxyProtocolLabel.anytls:
        return AnytlsServerConfig();
      case ProxyProtocolLabel.dokodemo:
        return DokodemoConfig();
    }
  }
}

/// [ports] should be in format of "123,5000-6000"
/// Return a non empty list if ports is valid, otherwise return null.
List<PortRange>? tryParsePorts(String ports) {
  List<PortRange> pr = [];
  final ranges = ports.split(',');
  for (var r in ranges) {
    if (r.contains('-')) {
      final range = r.split('-');
      if (range.length != 2) {
        return null;
      }
      final from = int.tryParse(range[0]);
      final to = int.tryParse(range[1]);
      if (from == null || to == null) {
        return null;
      }
      pr.add(PortRange(from: from, to: to));
    } else {
      final port = int.tryParse(r);
      if (port == null) {
        return null;
      }
      pr.add(PortRange(from: port, to: port));
    }
  }
  if (pr.isEmpty) {
    return null;
  }
  return pr;
}
