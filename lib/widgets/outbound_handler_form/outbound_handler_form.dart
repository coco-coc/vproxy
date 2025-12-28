import 'dart:convert';
import 'dart:io';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:protobuf/protobuf.dart';
import 'package:provider/provider.dart';
import 'package:tm/protos/common/net/net.pb.dart';
import 'package:tm/protos/google/protobuf/any.pb.dart';
import 'package:tm/protos/protos/inbound.pb.dart';
import 'package:tm/protos/protos/proxy/anytls.pb.dart';
import 'package:tm/protos/protos/proxy/dokodemo.pb.dart';
import 'package:tm/protos/protos/proxy/dokodemo.pbjson.dart';
import 'package:tm/protos/protos/proxy/http.pb.dart';
import 'package:tm/protos/protos/proxy/hysteria.pb.dart';
import 'package:tm/protos/protos/proxy/shadowsocks.pb.dart';
import 'package:tm/protos/protos/proxy/socks.pb.dart';
import 'package:tm/protos/protos/proxy/trojan.pb.dart';
import 'package:tm/protos/protos/proxy/vless.pb.dart';
import 'package:tm/protos/protos/proxy/vmess.pb.dart';
import 'package:tm/protos/protos/user.pb.dart';
import 'package:tm/protos/protos/tls/certificate.pb.dart';
import 'package:tm/protos/transport/protocols/grpc/config.pb.dart';
import 'package:tm/protos/transport/protocols/http/config.pb.dart';
import 'package:tm/protos/transport/protocols/httpupgrade/config.pb.dart';
import 'package:tm/protos/transport/protocols/kcp/config.pb.dart';
import 'package:tm/protos/transport/protocols/quic/config.pb.dart' as quic;
import 'package:tm/protos/transport/protocols/tcp/config.pb.dart';
import 'package:tm/protos/transport/protocols/websocket/config.pb.dart';
import 'package:tm/protos/transport/security/reality/config.pb.dart';
import 'package:tm/protos/protos/outbound.pb.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:tm/protos/protos/transport.pb.dart';
import 'package:vx/app/routing/routing_page.dart';
import 'package:vx/common/config.dart';
import 'package:vx/common/const.dart';
import 'package:vx/common/net.dart';
import 'package:vx/theme.dart';
import 'package:uuid/uuid.dart';
import 'package:tm/protos/transport/headers/http/config.pb.dart' as http_header;
import 'package:tm/protos/transport/headers/noop/config.pb.dart' as noop_header;
import 'package:tm/protos/transport/headers/wireguard/config.pb.dart'
    as wireguard_header;
import 'package:tm/protos/transport/headers/wechat/config.pb.dart'
    as wechat_header;
import 'package:tm/protos/transport/headers/utp/config.pb.dart' as utp_header;
import 'package:tm/protos/transport/headers/srtp/config.pb.dart' as srtp_header;
import 'package:tm/protos/transport/headers/tls/config.pb.dart' as tls_header;
import 'package:tm/protos/transport/protocols/splithttp/config.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:tm/protos/protos/tls/tls.pb.dart';
import 'package:vx/utils/error.dart';
import 'package:vx/utils/xapi_client.dart';
import 'package:vx/widgets/add_button.dart';
import 'package:vx/widgets/delete_menu_anchor.dart';
import 'package:vx/widgets/form_container.dart';
import 'package:vx/widgets/form_dialog.dart';
import 'package:vx/widgets/text_divider.dart';

part 'transport.dart';
part 'transport_header.dart';
part 'transport_protocol.dart';
part 'transport_security.dart';
part 'proxy.dart';
part 'inbound_form.dart';

/// Collect some fields of OutboundHandler.
class OutboundHandlerForm extends StatefulWidget {
  const OutboundHandlerForm({
    super.key,
    this.config,
    required this.formKey,
    this.onNameChanged,
  });
  final OutboundHandlerConfig? config;
  final GlobalKey<FormState> formKey;
  final Function(String)? onNameChanged;

  @override
  State<OutboundHandlerForm> createState() => OutboundHandlerFormState();
}

class OutboundHandlerFormState extends State<OutboundHandlerForm>
    with OutboundHandlerConfigGetter {
  ProxyProtocolLabel _selectedProtocolLabel = ProxyProtocolLabel.vmess;
  late DropdownMenu<ProxyProtocolLabel> _menu;
  VmessClientConfig _vmessConfig =
      VmessClientConfig(security: SecurityType.SecurityType_AUTO);
  TrojanClientConfig _trojanConfig = TrojanClientConfig();
  VlessClientConfig _vlessConfig = VlessClientConfig(encryption: "none");
  ShadowsocksClientConfig _shadowsocksConfig = ShadowsocksClientConfig();
  SocksClientConfig _socksConfig = SocksClientConfig();
  AnytlsClientConfig _anytlsConfig = AnytlsClientConfig();
  Hysteria2ClientConfig _hysteriaConfig = _getDefaultHysteriaConfig();
  HttpClientConfig _httpConfig = HttpClientConfig(account: Account());

  TextFormField? _name;
  final _nameController = TextEditingController();
  final _serverAddress = TextEditingController();
  final _port = TextEditingController();
  final _muxConcurrencyController = TextEditingController();
  final _muxConnectionController = TextEditingController();
  bool _enableMux = false;

  bool _enableUdpOverTcp = false;
  final _transportInputGlobalKey = GlobalKey<_TransportInputState>();
  late DomainStrategy _domainStrategy;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.config?.tag ?? '';
    _serverAddress.text = widget.config?.address ?? '';
    _port.text = portString(widget.config ?? OutboundHandlerConfig());
    // if (widget.handler?.config.transport != null) {
    //   _transportConfig.mergeFromMessage(widget.handler!.config.transport);
    // }
    _enableMux = widget.config?.enableMux ?? false;
    _enableUdpOverTcp = widget.config?.uot ?? false;
    _domainStrategy =
        widget.config?.domainStrategy ?? DomainStrategy.PreferIPv4;
    if (widget.config?.muxConfig != null) {
      _muxConcurrencyController.text =
          (widget.config!.muxConfig.maxConcurrency == 0
              ? '2'
              : widget.config!.muxConfig.maxConcurrency.toString());
      _muxConnectionController.text =
          (widget.config!.muxConfig.maxConnection == 0
              ? '16'
              : widget.config!.muxConfig.maxConnection.toString());
    } else {
      _muxConcurrencyController.text = '2';
      _muxConnectionController.text = '16';
    }
    if (widget.config?.protocol != null) {
      final any = widget.config!.protocol;
      _selectedProtocolLabel = getProtocolTypeFromAny(any);
      switch (_selectedProtocolLabel) {
        case ProxyProtocolLabel.vmess:
          _vmessConfig = any.unpackInto(_vmessConfig);
        case ProxyProtocolLabel.trojan:
          _trojanConfig = any.unpackInto(_trojanConfig);
        case ProxyProtocolLabel.vless:
          _vlessConfig = any.unpackInto(_vlessConfig);
        case ProxyProtocolLabel.shadowsocks:
          _shadowsocksConfig = any.unpackInto(_shadowsocksConfig);
        case ProxyProtocolLabel.socks:
          _socksConfig = any.unpackInto(_socksConfig);
        case ProxyProtocolLabel.hysteria2:
          _hysteriaConfig = any.unpackInto(_hysteriaConfig);
          // make it writable
          _hysteriaConfig.tlsConfig = _hysteriaConfig.tlsConfig.deepCopy();
        case ProxyProtocolLabel.anytls:
          _anytlsConfig = any.unpackInto(_anytlsConfig);
        case ProxyProtocolLabel.http:
          _httpConfig = any.unpackInto(_httpConfig);
        default:
          throw Exception('Unexpected protocol: ${_selectedProtocolLabel}');
      }
    }
  }

  @override
  OutboundHandlerConfig get outboundHandler {
    late final Any protocol;
    switch (_selectedProtocolLabel) {
      case ProxyProtocolLabel.vmess:
        protocol = Any.pack(_vmessConfig);
      case ProxyProtocolLabel.trojan:
        protocol = Any.pack(_trojanConfig);
      case ProxyProtocolLabel.vless:
        protocol = Any.pack(_vlessConfig);
      case ProxyProtocolLabel.shadowsocks:
        protocol = Any.pack(_shadowsocksConfig);
      case ProxyProtocolLabel.socks:
        protocol = Any.pack(_socksConfig);
      case ProxyProtocolLabel.hysteria2:
        protocol = Any.pack(_hysteriaConfig);
      case ProxyProtocolLabel.anytls:
        protocol = Any.pack(_anytlsConfig);
      case ProxyProtocolLabel.http:
        protocol = Any.pack(_httpConfig);
      default:
        throw Exception('Unexpected protocol: ${_selectedProtocolLabel}');
      // _transportConfig.clear();
    }
    return OutboundHandlerConfig(
      tag: _nameController.text,
      address: _serverAddress.text,
      // port: int.tryParse(_port.text),
      ports: tryParsePorts(_port.text),
      domainStrategy: _domainStrategy,
      enableMux: _enableMux,
      uot: _enableUdpOverTcp,
      transport: _transportInputGlobalKey.currentState?.transportConfig,
      protocol: protocol,
      muxConfig: _enableMux
          ? MuxConfig(
              maxConcurrency: int.parse(_muxConcurrencyController.text),
              maxConnection: int.parse(_muxConnectionController.text),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serverAddress.dispose();
    _muxConcurrencyController.dispose();
    _muxConnectionController.dispose();
    _port.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _name = TextFormField(
      controller: _nameController,
      onChanged: widget.onNameChanged,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (value == directEN || value == 'dns') {
            return 'Name cannot be "direct" or "dns"';
          }
        }
        return null;
      },
      decoration: InputDecoration(
        constraints: const BoxConstraints(maxWidth: 200),
        labelText: AppLocalizations.of(context)!.name,
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
    _menu = DropdownMenu<ProxyProtocolLabel>(
        textStyle: const TextStyle(color: XBlue),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: XBlue),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: XBlue, width: 1.5),
          ),
        ),
        requestFocusOnTap: false,
        initialSelection: _selectedProtocolLabel,
        label: Text(AppLocalizations.of(context)!.protocol),
        onSelected: (ProxyProtocolLabel? l) {
          if (l != null) {
            _selectedProtocolLabel = l;
            // if (l == ProxyProtocolLabel.hysteria2) {
            //   _transportConfig.clear();
            // }
          }
          setState(() {});
        },
        dropdownMenuEntries: ProxyProtocolLabel.values
            .where((p) => p != ProxyProtocolLabel.dokodemo)
            .map<DropdownMenuEntry<ProxyProtocolLabel>>((ProxyProtocolLabel p) {
          return DropdownMenuEntry<ProxyProtocolLabel>(
            label: p.label,
            value: p,
          );
        }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _menu,
                const Gap(10),
                Expanded(child: _name!),
              ],
            ),
            boxH10,
            TextFormField(
              controller: _serverAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Server address cannot be empty';
                }
                _serverAddress.text = value;
                return null;
              },
              decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.address,
                      hintText: AppLocalizations.of(context)!.ipOrDomain)
                  .applyDefaults(Theme.of(context).inputDecorationTheme),
            ),
            boxH10,
            TextFormField(
              controller: _port,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Port cannot be empty';
                }
                if (int.tryParse(value) != null) {
                  return null;
                }
                if (tryParsePorts(value) != null) {
                  return null;
                }
                return 'Invalid port';
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.port,
                      hintText: '443')
                  .applyDefaults(Theme.of(context).inputDecorationTheme),
            ),
            const Gap(10),
            DropdownMenu(
                label: Text('Domain Strategy'),
                initialSelection: _domainStrategy,
                onSelected: (value) {
                  setState(() {
                    _domainStrategy = value!;
                  });
                },
                dropdownMenuEntries: DomainStrategy.values
                    .map(
                        (e) => DropdownMenuEntry(label: e.toString(), value: e))
                    .toList()),
            const Gap(4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(AppLocalizations.of(context)!.domainStrategyDesc,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )),
            ),
            const Gap(10),
            if (_selectedProtocolLabel != ProxyProtocolLabel.hysteria2)
              Column(
                children: [
                  SwitchListTile(
                    title: Text('Mux',
                        style: Theme.of(context).textTheme.titleMedium),
                    value: _enableMux,
                    onChanged: (v) {
                      setState(() {
                        _enableMux = v;
                      });
                    },
                  ),
                  if (_enableMux)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _muxConcurrencyController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .fieldRequired;
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Max Concurrency',
                                helperText: AppLocalizations.of(context)!
                                    .maxConcurrency,
                              ),
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: TextFormField(
                              controller: _muxConnectionController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .fieldRequired;
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Max Connection',
                                helperText:
                                    AppLocalizations.of(context)!.maxConnection,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_selectedProtocolLabel == ProxyProtocolLabel.vmess ||
                      _selectedProtocolLabel == ProxyProtocolLabel.socks ||
                      _selectedProtocolLabel ==
                          ProxyProtocolLabel.shadowsocks ||
                      _selectedProtocolLabel == ProxyProtocolLabel.vless)
                    SwitchListTile(
                      title: Text('UDP over TCP',
                          style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(AppLocalizations.of(context)!.uotDesc,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  )),
                      value: _enableUdpOverTcp,
                      onChanged: (v) {
                        setState(() {
                          _enableUdpOverTcp = v;
                        });
                      },
                    ),
                  const Gap(10),
                ],
              ),
            if (_selectedProtocolLabel == ProxyProtocolLabel.vmess)
              _VmessClient(config: _vmessConfig),
            if (_selectedProtocolLabel == ProxyProtocolLabel.trojan)
              _TrojanClient(config: _trojanConfig),
            if (_selectedProtocolLabel == ProxyProtocolLabel.vless)
              _VlessClient(config: _vlessConfig),
            if (_selectedProtocolLabel == ProxyProtocolLabel.shadowsocks)
              _ShadowsocksClient(config: _shadowsocksConfig),
            if (_selectedProtocolLabel == ProxyProtocolLabel.socks)
              _SocksClient(config: _socksConfig),
            if (_selectedProtocolLabel == ProxyProtocolLabel.hysteria2)
              HysteriaClient(config: _hysteriaConfig),
            if (_selectedProtocolLabel == ProxyProtocolLabel.anytls)
              _AnytlsClient(config: _anytlsConfig),
            if (_selectedProtocolLabel == ProxyProtocolLabel.http)
              _HttpClient(config: _httpConfig),
            const Gap(10),
            if (_selectedProtocolLabel != ProxyProtocolLabel.hysteria2)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                          child: Divider(
                        height: 1,
                      )),
                      const Gap(10),
                      Text('Stream',
                          style: Theme.of(context).textTheme.titleSmall),
                      const Gap(10),
                      const Expanded(
                          child: Divider(
                        height: 1,
                      )),
                    ],
                  ),
                  const Gap(10),
                  _TransportInput(
                      key: _transportInputGlobalKey,
                      config: widget.config?.transport)
                ],
              ),
          ],
        ),
      ),
    );
  }
}

enum TransportHeaderLabel {
  srtp('SRTP'),
  utp('UTP'),
  wechatvideo('WeChat Video'),
  dtls('DTLS'),
  wireguard('WireGuard'),
  http('HTTP'),
  tls('TLS');

  const TransportHeaderLabel(this.label);
  final String label;
}

mixin OutboundHandlerConfigGetter {
  OutboundHandlerConfig get outboundHandler;
}

mixin TransportConfigGetter {
  TransportConfig? get transportConfig;
}
