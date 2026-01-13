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

part of 'outbound_handler_form.dart';

mixin TransportProtocolConfigGetter {
  Object get transportProtocolConfig;
}

class _TransportInput extends StatefulWidget {
  const _TransportInput({super.key, this.config, this.server = false});

  final TransportConfig? config;
  final bool server;

  @override
  State<_TransportInput> createState() => _TransportInputState();
}

class _TransportInputState extends State<_TransportInput>
    with TransportConfigGetter {
  late TransportConfig_Protocol _protocol;
  late TransportConfig_Security _security;
  final tlsConfig = TlsConfig();
  final realityConfig = RealityConfig();
  final _protocolWidgetKey = GlobalKey();

  @override
  TransportConfig? get transportConfig {
    final ret = TransportConfig();
    switch (_protocol) {
      case TransportConfig_Protocol.tcp:
        ret.tcp =
            (_protocolWidgetKey.currentState as TransportProtocolConfigGetter)
                .transportProtocolConfig as TcpConfig;
      case TransportConfig_Protocol.kcp:
        ret.kcp =
            (_protocolWidgetKey.currentState as TransportProtocolConfigGetter)
                .transportProtocolConfig as KcpConfig;
      case TransportConfig_Protocol.websocket:
        ret.websocket =
            (_protocolWidgetKey.currentState as TransportProtocolConfigGetter)
                .transportProtocolConfig as WebsocketConfig;
      case TransportConfig_Protocol.http:
        ret.http =
            (_protocolWidgetKey.currentState as TransportProtocolConfigGetter)
                .transportProtocolConfig as HttpConfig;
      case TransportConfig_Protocol.quic:
        ret.quic =
            (_protocolWidgetKey.currentState as TransportProtocolConfigGetter)
                .transportProtocolConfig as quic.QuicConfig;
      case TransportConfig_Protocol.grpc:
        ret.grpc =
            (_protocolWidgetKey.currentState as TransportProtocolConfigGetter)
                .transportProtocolConfig as GrpcConfig;
      case TransportConfig_Protocol.httpupgrade:
        ret.httpupgrade =
            (_protocolWidgetKey.currentState as TransportProtocolConfigGetter)
                .transportProtocolConfig as HttpUpgradeConfig;
      case TransportConfig_Protocol.splithttp:
        ret.splithttp =
            (_protocolWidgetKey.currentState as TransportProtocolConfigGetter)
                .transportProtocolConfig as SplitHttpConfig;
      default:
    }
    if (_security == TransportConfig_Security.tls) {
      ret.tls = tlsConfig;
    } else if (_security == TransportConfig_Security.reality) {
      ret.reality = realityConfig;
    }
    return ret;
  }

  final _dropdownMenuProtocolEntries = TransportConfig_Protocol.values
      .where((e) =>
          e != TransportConfig_Protocol.http &&
          e != TransportConfig_Protocol.quic)
      .map<DropdownMenuEntry<TransportConfig_Protocol>>(
          (TransportConfig_Protocol p) {
    return DropdownMenuEntry<TransportConfig_Protocol>(
      label: p.label,
      value: p,
    );
  }).toList();

  final _dropdownMenuSecurityEntries = TransportConfig_Security.values
      .map<DropdownMenuEntry<TransportConfig_Security>>(
          (TransportConfig_Security s) {
    return DropdownMenuEntry<TransportConfig_Security>(
      label: s.label,
      value: s,
    );
  }).toList();

  @override
  void initState() {
    // if (widget.config.whichProtocol() == TransportConfig_Protocol.notSet) {
    //   widget.config.tcp = TcpConfig();
    // }
    _protocol =
        widget.config?.whichProtocol() ?? TransportConfig_Protocol.notSet;
    _security =
        widget.config?.whichSecurity() ?? TransportConfig_Security.notSet;
    if (widget.config != null) {
      if (widget.config!.hasTls()) {
        tlsConfig.mergeFromMessage(widget.config!.tls);
      }
      if (widget.config!.hasReality()) {
        realityConfig.mergeFromMessage(widget.config!.reality);
      }
    }
    super.initState();
  }

  void _setProtocol(TransportConfig_Protocol? p) {
    setState(() {
      _protocol = p ?? TransportConfig_Protocol.notSet;
    });
  }

  void _setSecurity(TransportConfig_Security? s) {
    setState(() {
      _security = s ?? TransportConfig_Security.notSet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownMenu<TransportConfig_Protocol>(
              requestFocusOnTap: false,
              initialSelection: _protocol,
              onSelected: (TransportConfig_Protocol? l) => _setProtocol(l),
              label: Text(AppLocalizations.of(context)!.protocol),
              dropdownMenuEntries: _dropdownMenuProtocolEntries),
          const Gap(10),
          if (_protocol == TransportConfig_Protocol.tcp)
            _TransportProtocolTcp(
                initialConfig: widget.config?.tcp, key: _protocolWidgetKey),
          if (_protocol == TransportConfig_Protocol.kcp)
            _TransportProtocolKcp(
                initialConfig: widget.config?.kcp, key: _protocolWidgetKey),
          if (_protocol == TransportConfig_Protocol.websocket)
            _TransportProtocolWebsocket(
                initialConfig: widget.config?.websocket,
                key: _protocolWidgetKey),
          if (_protocol == TransportConfig_Protocol.grpc)
            _TransportProtocolGrpc(
                initialConfig: widget.config?.grpc, key: _protocolWidgetKey),
          if (_protocol == TransportConfig_Protocol.httpupgrade)
            _TransportProtocolHttpUpgrade(
                initialConfig: widget.config?.httpupgrade,
                key: _protocolWidgetKey),
          if (_protocol == TransportConfig_Protocol.splithttp)
            _TransportProtocolSplitHttp(
                config: widget.config?.splithttp,
                key: _protocolWidgetKey,
                server: widget.server),
          const Gap(10),
          DropdownMenu<TransportConfig_Security>(
              width: 160,
              requestFocusOnTap: false,
              initialSelection: _security,
              dropdownMenuEntries: _dropdownMenuSecurityEntries,
              onSelected: (TransportConfig_Security? s) => _setSecurity(s),
              label: const Text('Security')),
          const Gap(10),
          if (_security == TransportConfig_Security.tls)
            _TransportSecurityTls(config: tlsConfig, server: widget.server),
          if (_security == TransportConfig_Security.reality)
            _TransportSecurityReality(
                config: realityConfig, server: widget.server),
        ]);
  }
}

extension TransportProtocolLabelExtension on TransportConfig_Protocol {
  String get label {
    switch (this) {
      case TransportConfig_Protocol.notSet:
        return '';
      case TransportConfig_Protocol.tcp:
        return 'TCP';
      case TransportConfig_Protocol.kcp:
        return 'KCP';
      case TransportConfig_Protocol.websocket:
        return 'WebSocket';
      case TransportConfig_Protocol.http:
        return 'HTTP';
      case TransportConfig_Protocol.quic:
        return 'QUIC';
      case TransportConfig_Protocol.grpc:
        return 'gRPC';
      case TransportConfig_Protocol.httpupgrade:
        return 'HTTPUpgrade';
      case TransportConfig_Protocol.splithttp:
        return 'SplitHTTP';
    }
  }
}

extension TransportSecurityLabelExtension on TransportConfig_Security {
  String get label {
    switch (this) {
      case TransportConfig_Security.notSet:
        return '';
      case TransportConfig_Security.tls:
        return 'TLS';
      case TransportConfig_Security.reality:
        return 'Reality';
    }
  }
}

extension SplitHttpDownConfigSecurityLabelExtension on DownConfig_Security {
  String get label {
    switch (this) {
      case DownConfig_Security.notSet:
        return '';
      case DownConfig_Security.tls:
        return 'TLS';
      case DownConfig_Security.reality:
        return 'Reality';
    }
  }
}
