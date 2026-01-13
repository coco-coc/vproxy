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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tm/protos/protos/dns.pb.dart';
import 'package:vx/app/log/log_page.dart';
import 'package:vx/app/routing/repo.dart';
import 'package:vx/common/net.dart';
import 'package:vx/data/database.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/main.dart';
import 'package:vx/widgets/form_dialog.dart';

class DnsServersWidget extends StatefulWidget {
  const DnsServersWidget({super.key});

  @override
  State<DnsServersWidget> createState() => _DnsServersWidgetState();
}

// final defaultDnsServers = [
//   DnsServer(
//       id: 0,
//       name: dnsServerFake,
//       dnsServer: DnsServerConfig(
//         fakeDnsServer: FakeDnsServer(
//           poolConfigs: XConfigHelper.fakednsPools,
//         ),
//       )),
//   DnsServer(
//       id: 0,
//       name: dnsServerProxy,
//       dnsServer: DnsServerConfig(
//         plainDnsServer: PlainDnsServer(
//           addresses: ['1.1.1.1:53'],
//         ),
//       )),
//   DnsServer(
//       id: 0,
//       name: dnsServerDirect,
//       dnsServer: DnsServerConfig(
//         plainDnsServer: PlainDnsServer(
//             addresses: ['223.5.5.5:53', '1.1.1.1:53'], useDefaultDns: true),
//       )),
// ];

class _DnsServersWidgetState extends State<DnsServersWidget>
    with AutomaticKeepAliveClientMixin<DnsServersWidget> {
  final width = 300;

  List<DnsServer> _servers = [/* ...defaultDnsServers */];
  late DnsRepo _dnsRepo;
  StreamSubscription? _dnsServersSubscription;


  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dnsRepo = Provider.of<DnsRepo>(context, listen: true);
    _dnsServersSubscription?.cancel();
    _dnsServersSubscription = _dnsRepo.getDnsServersStream().listen((value) {
      setState(() {
        _servers = [/* ...defaultDnsServers */];
        _servers.addAll(value);
      });
    });
  }

  @override
  void dispose() {
    _dnsServersSubscription?.cancel();
    super.dispose();
  }

  void _onAdd() async {
    final k = GlobalKey();
    final config = await showMyAdaptiveDialog<DnsServerConfig?>(
      context,
      _DnsServerForm(key: k),
      title: AppLocalizations.of(context)!.addDnsServer,
      onSave: (BuildContext context) {
        final formData = (k.currentState as FormDataGetter).formData;
        if (formData != null) {
          context.pop(formData);
        }
      },
    );
    if (config != null) {
      if (_servers.any((e) => e.name == config.name)) {
        snack(rootLocalizations()?.duplicateDnsServerName);
        return;
      }
      final ds = await _dnsRepo.addDnsServer(config.name, config);
      setState(() {
        _servers.add(ds);
      });
    }
  }

  void _onEdit(int index) async {
    final k = GlobalKey();
    final config = await showMyAdaptiveDialog<DnsServerConfig?>(
      context,
      _DnsServerForm(key: k, dnsServer: _servers[index]),
      title: AppLocalizations.of(context)!.edit,
      onSave: (BuildContext context) {
        final formData = (k.currentState as FormDataGetter).formData;
        if (formData != null) {
          context.pop(formData);
        }
      },
    );
    if (config != null) {
      await _dnsRepo.updateDnsServer(_servers[index],
          dnsServerName: config.name, dnsServer: config);
      setState(() {
        _servers[index] = DnsServer(
            id: _servers[index].id, name: config.name, dnsServer: config);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final count = constraints.maxWidth ~/ width;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.tonal(
              onPressed: _onAdd,
              child: Text(AppLocalizations.of(context)!.addDnsServer)),
          const SizedBox(height: 5),
          Expanded(
            child: MasonryGridView.count(
              padding: const EdgeInsets.only(bottom: 70),
              crossAxisCount: count,
              itemCount: _servers.length,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      _onEdit(index);
                    },
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _servers[index].name,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _getDnsServerType(_servers[index]).name,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              _getDnsServerWidget(context, _servers[index]),
                              if (_servers[index].dnsServer.clientIp.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                      'Client IP',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 5),
                                    Chip(
                                        shape: chipBorderRadius,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerLow,
                                        label: Text(_servers[index]
                                            .dnsServer
                                            .clientIp)),
                                    // Text(
                                    //   _servers[index].dnsServer.clientIp,
                                    //   style: Theme.of(context)
                                    //       .textTheme
                                    //       .bodyMedium,
                                    // ),
                                  ],
                                )
                            ],
                          ),
                        ),
                        Positioned(
                          right: 5,
                          top: 5,
                          child: IconButton(
                              onPressed: () async {
                                await _dnsRepo.removeDnsServer(_servers[index]);
                                _servers.removeAt(index);
                                // xController.dnsServerChange(_servers[index].config);
                                setState(() {});
                              },
                              icon: const Icon(Icons.delete_outline)),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

DnsServerType _getDnsServerType(DnsServer server) {
  if (server.dnsServer.hasFakeDnsServer()) {
    return DnsServerType.fake;
  } else if (server.dnsServer.hasPlainDnsServer()) {
    return DnsServerType.plain;
  } else if (server.dnsServer.hasDohDnsServer()) {
    return DnsServerType.doh;
  } else if (server.dnsServer.hasTlsDnsServer()) {
    return DnsServerType.tls;
  } else if (server.dnsServer.hasQuicDnsServer()) {
    return DnsServerType.quic;
  }
  return DnsServerType.plain;
}

Widget _getDnsServerWidget(BuildContext context, DnsServer server) {
  if (server.dnsServer.hasFakeDnsServer()) {
    return _FakeDns(fakeDnsServer: server.dnsServer.fakeDnsServer);
  } else if (server.dnsServer.hasPlainDnsServer()) {
    return _PlainTlsDnsServer(
        addresses: server.dnsServer.plainDnsServer.addresses,
        useDefaultDns: server.dnsServer.plainDnsServer.useDefaultDns);
  } else if (server.dnsServer.hasTlsDnsServer()) {
    return _PlainTlsDnsServer(
      addresses: server.dnsServer.tlsDnsServer.addresses,
    );
  } else if (server.dnsServer.hasDohDnsServer()) {
    return _PlainTlsDnsServer(
      addresses: [server.dnsServer.dohDnsServer.url],
    );
  } else if (server.dnsServer.hasQuicDnsServer()) {
    return _PlainTlsDnsServer(
      addresses: [server.dnsServer.quicDnsServer.address],
    );
  }
  return const SizedBox.shrink();
}

class _FakeDns extends StatelessWidget {
  const _FakeDns({required this.fakeDnsServer});
  final FakeDnsServer fakeDnsServer;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pool',
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 5),
        Wrap(
          runSpacing: 5,
          spacing: 5,
          children: fakeDnsServer.poolConfigs
              .map((e) => Chip(
                  shape: chipBorderRadius,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerLow,
                  label: Text(e.cidr)))
              .toList(),
        )
      ],
    );
  }
}

class _PlainTlsDnsServer extends StatelessWidget {
  const _PlainTlsDnsServer(
      {required this.addresses, this.useDefaultDns});
  final Iterable<String> addresses;
  final bool? useDefaultDns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.address,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        if (useDefaultDns != null && useDefaultDns!)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              AppLocalizations.of(context)!.useDefaultNicDnsServer,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        const SizedBox(height: 5),
        Wrap(
          runSpacing: 5,
          spacing: 5,
          children: addresses
              .map((e) => Chip(
                  shape: chipBorderRadius,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerLow,
                  label: Text(e)))
              .toList(),
        )
      ],
    );
  }
}

class _DnsServerForm extends StatefulWidget {
  const _DnsServerForm({super.key, this.dnsServer});
  final DnsServer? dnsServer;
  @override
  State<_DnsServerForm> createState() => __DnsServerFormState();
}

class __DnsServerFormState extends State<_DnsServerForm> with FormDataGetter {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fakeDnsPoolController = TextEditingController();
  final _lruSizeController = TextEditingController(text: '6666');
  final _dnsServerAddressController = TextEditingController();
  final _clientIpController = TextEditingController();
  final _cacheDurationController = TextEditingController();
  bool _useDefaultDns = false;
  DnsServerType? _type = DnsServerType.plain;

  @override
  Object? get formData {
    if (_type == null) {
      return null;
    }
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return null;
    }
    if (_type == DnsServerType.fake) {
      return DnsServerConfig(
          name: _nameController.text,
          fakeDnsServer: FakeDnsServer(
              poolConfigs: _fakeDnsPoolController.text
                  .split(',')
                  .map((e) => FakeDnsServer_PoolConfig(
                      cidr: e, lruSize: int.parse(_lruSizeController.text)))
                  .toList()));
    }
    if (_type == DnsServerType.plain) {
      return DnsServerConfig(
          name: _nameController.text,
          cacheDuration: int.tryParse(_cacheDurationController.text),
          clientIp: _clientIpController.text,
          plainDnsServer: PlainDnsServer(
              useDefaultDns: _useDefaultDns,
              addresses: _dnsServerAddressController.text.split(',').toList()));
    }
    if (_type == DnsServerType.tls) {
      return DnsServerConfig(
          name: _nameController.text,
          cacheDuration: int.tryParse(_cacheDurationController.text),
          clientIp: _clientIpController.text,
          tlsDnsServer: TlsDnsServer(
              addresses: _dnsServerAddressController.text.split(',').toList()));
    }
    if (_type == DnsServerType.doh) {
      return DnsServerConfig(
          name: _nameController.text,
          clientIp: _clientIpController.text,
          cacheDuration: int.tryParse(_cacheDurationController.text),
          dohDnsServer: DohDnsServer(url: _dnsServerAddressController.text));
    }
    if (_type == DnsServerType.quic) {
      return DnsServerConfig(
          name: _nameController.text,
          clientIp: _clientIpController.text,
          cacheDuration: int.tryParse(_cacheDurationController.text),
          quicDnsServer:
              QuicDnsServer(address: _dnsServerAddressController.text));
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.dnsServer != null) {
      _nameController.text = widget.dnsServer!.name;
      _type = _getDnsServerType(widget.dnsServer!);
      _clientIpController.text = widget.dnsServer!.dnsServer.clientIp;
      _cacheDurationController.text =
          widget.dnsServer!.dnsServer.cacheDuration != 0
              ? widget.dnsServer!.dnsServer.cacheDuration.toString()
              : '';
      if (widget.dnsServer!.dnsServer.hasFakeDnsServer()) {
        _fakeDnsPoolController.text = widget
            .dnsServer!.dnsServer.fakeDnsServer.poolConfigs
            .map((e) => e.cidr)
            .join(',');
        _lruSizeController.text = widget.dnsServer!.dnsServer.fakeDnsServer
                .poolConfigs.firstOrNull?.lruSize
                .toString() ??
            '6666';
      } else if (widget.dnsServer!.dnsServer.hasPlainDnsServer()) {
        _useDefaultDns =
            widget.dnsServer!.dnsServer.plainDnsServer.useDefaultDns;
        _dnsServerAddressController.text =
            widget.dnsServer!.dnsServer.plainDnsServer.addresses.join(',');
      } else if (widget.dnsServer!.dnsServer.hasDohDnsServer()) {
        _dnsServerAddressController.text =
            widget.dnsServer!.dnsServer.dohDnsServer.url;
      } else if (widget.dnsServer!.dnsServer.hasTlsDnsServer()) {
        _dnsServerAddressController.text =
            widget.dnsServer!.dnsServer.tlsDnsServer.addresses.join(',');
      } else if (widget.dnsServer!.dnsServer.hasQuicDnsServer()) {
        _dnsServerAddressController.text =
            widget.dnsServer!.dnsServer.quicDnsServer.address;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fakeDnsPoolController.dispose();
    _dnsServerAddressController.dispose();
    _lruSizeController.dispose();
    _clientIpController.dispose();
    super.dispose();
  }

  String? validAddressPorts(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.empty;
    }
    final addressPorts = value.split(',');
    for (var addressPort in addressPorts) {
      if (!isValidAddressPort(addressPort)) {
        return AppLocalizations.of(context)!.invalidAddress;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.empty;
                }
                return null;
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  labelText: AppLocalizations.of(context)!.name)),
          const SizedBox(height: 10),
          DropdownMenu<DnsServerType>(
              label: Text(AppLocalizations.of(context)!.type),
              initialSelection: _type,
              onSelected: (value) {
                setState(() {
                  _type = value;
                });
              },
              dropdownMenuEntries: DnsServerType.values
                  .map((e) => DropdownMenuEntry(value: e, label: e.name))
                  .toList()),
          const SizedBox(height: 10),
          if (_type == DnsServerType.fake)
            Column(
              children: [
                TextFormField(
                    controller: _fakeDnsPoolController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.empty;
                      }
                      final cidrs = value.split(',');
                      for (var cidr in cidrs) {
                        if (!isValidCidr(cidr)) {
                          return AppLocalizations.of(context)!.invalidCidr;
                        }
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: '198.18.0.0/15,fc00::/18',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        labelText: 'Pools')),
                const SizedBox(height: 10),
                TextFormField(
                    controller: _lruSizeController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.empty;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'LRU Size',
                        helperMaxLines: 2,
                        helperText: AppLocalizations.of(context)!.lruSizeDesc)),
              ],
            ),
          if (_type == DnsServerType.plain)
            Column(
              children: [
                TextFormField(
                    controller: _dnsServerAddressController,
                    validator: validAddressPorts,
                    decoration: InputDecoration(
                        helperText:
                            AppLocalizations.of(context)!.addDnsAddressHint,
                        helperMaxLines: 5,
                        hintText: '1.1.1.1:53,8.8.8.8:53',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        labelText: 'Addresses')),
                const SizedBox(height: 10),
                CheckboxListTile(
                  value: _useDefaultDns,
                  onChanged: (value) {
                    setState(() {
                      _useDefaultDns = value ?? false;
                    });
                  },
                  title: Text(
                    AppLocalizations.of(context)!.useDefaultDnsServer,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          if (_type == DnsServerType.doh)
            Column(
              children: [
                TextFormField(
                    controller: _dnsServerAddressController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.empty;
                      }
                      final uri = Uri.tryParse(value);
                      if (uri == null) {
                        return AppLocalizations.of(context)!.invalidUrl;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'https://1.1.1.1/dns-query',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        labelText: 'Address')),
              ],
            ),
          if (_type == DnsServerType.tls)
            Column(
              children: [
                TextFormField(
                    controller: _dnsServerAddressController,
                    validator: validAddressPorts,
                    decoration: InputDecoration(
                        hintText: '1.1.1.1:853,8.8.8.8:853',
                        helperText:
                            AppLocalizations.of(context)!.addDnsAddressHint,
                        helperMaxLines: 3,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        labelText: 'Addresses')),
              ],
            ),
          if (_type == DnsServerType.quic)
            Column(
              children: [
                TextFormField(
                    controller: _dnsServerAddressController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.empty;
                      }
                      if (!isValidAddressPort(value)) {
                        return AppLocalizations.of(context)!.invalidAddress;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'dns.adguard.com:853',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        labelText: 'Address')),
              ],
            ),
          if (_type != DnsServerType.fake)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                      controller: _clientIpController,
                      validator: (value) {
                        if (value?.isNotEmpty ?? false) {
                          if (!isValidIp(value!)) {
                            return AppLocalizations.of(context)!.invalidIp;
                          }
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          hintText: '123.123.123.123',
                          labelText: 'Client IP')),
                ),
                const SizedBox(height: 10),
                TextFormField(
                    controller: _cacheDurationController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.empty;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: '3600',
                        suffixText: 's',
                        labelText: AppLocalizations.of(context)!.cacheDuration,
                        helperText:
                            AppLocalizations.of(context)!.cacheDurationDesc,
                        helperMaxLines: 2)),
              ],
            ),
        ],
      ),
    );
  }
}

enum DnsServerType {
  fake(
    'Fake',
  ),
  plain(
    'UDP/TCP',
  ),
  doh(
    'HTTPS',
  ),
  tls(
    'TLS',
  ),
  quic(
    'QUIC',
  );

  const DnsServerType(this.name);

  final String name;
}
