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

class _TransportProtocolTcp extends StatefulWidget {
  const _TransportProtocolTcp({required this.initialConfig, super.key});
  final TcpConfig? initialConfig;
  @override
  State<_TransportProtocolTcp> createState() => _TransportProtocolTcpState();
}

class _TransportProtocolTcpState extends State<_TransportProtocolTcp>
    with TransportProtocolConfigGetter {
  String? _headerType;
  final GlobalKey<_TcpHeaderHttpState> _httpHeaderKey = GlobalKey();
  final GlobalKey<_TcpHeaderSrtpState> _srtpHeaderKey = GlobalKey();
  final GlobalKey<_TcpHeaderUtpState> _utpHeaderKey = GlobalKey();

  @override
  Object get transportProtocolConfig {
    Any? headerSettings;

    if (_headerType == 'http' && _httpHeaderKey.currentState != null) {
      final httpConfig = _httpHeaderKey.currentState!.getConfig();
      headerSettings = Any.pack(httpConfig);
    } else if (_headerType == 'noop') {
      headerSettings = Any.pack(noop_header.Config());
    } else if (_headerType == 'wireguard') {
      headerSettings = Any.pack(wireguard_header.WireguardConfig());
    } else if (_headerType == 'wechat') {
      headerSettings = Any.pack(wechat_header.VideoConfig());
    } else if (_headerType == 'utp' && _utpHeaderKey.currentState != null) {
      final utpConfig = _utpHeaderKey.currentState!.getConfig();
      headerSettings = Any.pack(utpConfig);
    } else if (_headerType == 'srtp' && _srtpHeaderKey.currentState != null) {
      final srtpConfig = _srtpHeaderKey.currentState!.getConfig();
      headerSettings = Any.pack(srtpConfig);
    } else if (_headerType == 'tls') {
      headerSettings = Any.pack(tls_header.PacketConfig());
    }

    return TcpConfig(
      headerSettings: headerSettings,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null &&
        widget.initialConfig!.hasHeaderSettings()) {
      final typeUrl = widget.initialConfig!.headerSettings.typeUrl;
      if (typeUrl.contains('headers.http')) {
        _headerType = 'http';
      } else if (typeUrl.contains('headers.noop')) {
        _headerType = 'noop';
      } else if (typeUrl.contains('headers.wireguard')) {
        _headerType = 'wireguard';
      } else if (typeUrl.contains('headers.wechat')) {
        _headerType = 'wechat';
      } else if (typeUrl.contains('headers.utp')) {
        _headerType = 'utp';
      } else if (typeUrl.contains('headers.srtp')) {
        _headerType = 'srtp';
      } else if (typeUrl.contains('headers.tls')) {
        _headerType = 'tls';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu<String?>(
          initialSelection: _headerType,
          label: Text('Header Type'),
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: null, label: 'None'),
            DropdownMenuEntry(value: 'http', label: 'HTTP'),
            DropdownMenuEntry(value: 'wireguard', label: 'WireGuard'),
            DropdownMenuEntry(value: 'wechat', label: 'WeChat Video'),
            DropdownMenuEntry(value: 'utp', label: 'uTP'),
            DropdownMenuEntry(value: 'srtp', label: 'SRTP'),
            DropdownMenuEntry(value: 'tls', label: 'TLS'),
          ],
          onSelected: (value) {
            setState(() {
              _headerType = value;
            });
          },
        ),
        const Gap(10),
        if (_headerType == 'http')
          _TcpHeaderHttp(
            key: _httpHeaderKey,
            initialConfig: widget.initialConfig?.hasHeaderSettings() == true &&
                    widget.initialConfig!.headerSettings.typeUrl
                        .contains('headers.http')
                ? widget.initialConfig!.headerSettings
                : null,
          ),
        if (_headerType == 'wireguard')
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('WireGuard header - no configuration needed'),
          ),
        if (_headerType == 'wechat')
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('WeChat Video header - no configuration needed'),
          ),
        if (_headerType == 'utp')
          _TcpHeaderUtp(
            key: _utpHeaderKey,
            initialConfig: widget.initialConfig?.hasHeaderSettings() == true &&
                    widget.initialConfig!.headerSettings.typeUrl
                        .contains('headers.utp')
                ? widget.initialConfig!.headerSettings
                : null,
          ),
        if (_headerType == 'srtp')
          _TcpHeaderSrtp(
            key: _srtpHeaderKey,
            initialConfig: widget.initialConfig?.hasHeaderSettings() == true &&
                    widget.initialConfig!.headerSettings.typeUrl
                        .contains('headers.srtp')
                ? widget.initialConfig!.headerSettings
                : null,
          ),
        if (_headerType == 'tls')
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('TLS packet header - no configuration needed'),
          ),
      ],
    );
  }
}

// HTTP Header Configuration Widget
class _TcpHeaderHttp extends StatefulWidget {
  const _TcpHeaderHttp({super.key, this.initialConfig});

  final Any? initialConfig;

  @override
  State<_TcpHeaderHttp> createState() => _TcpHeaderHttpState();
}

class _TcpHeaderHttpState extends State<_TcpHeaderHttp> {
  final TextEditingController _versionController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _pathController = TextEditingController();
  final List<Map<String, TextEditingController>> _headers = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      try {
        final config =
            http_header.Config.fromBuffer(widget.initialConfig!.value);
        if (config.hasRequest()) {
          if (config.request.hasVersion()) {
            _versionController.text = config.request.version.value;
          }
          if (config.request.hasMethod()) {
            _methodController.text = config.request.method.value;
          }
          if (config.request.uri.isNotEmpty) {
            _pathController.text = config.request.uri.first;
          }
          for (var header in config.request.header) {
            _headers.add({
              'name': TextEditingController(text: header.name),
              'value': TextEditingController(
                  text: header.value.isNotEmpty ? header.value.first : ''),
            });
          }
        }
      } catch (e) {
        // Invalid config, ignore
      }
    }

    // Add one empty header if none exist
    if (_headers.isEmpty) {
      _addHeader();
    }
  }

  void _addHeader() {
    setState(() {
      _headers.add({
        'name': TextEditingController(),
        'value': TextEditingController(),
      });
    });
  }

  void _removeHeader(int index) {
    setState(() {
      _headers[index]['name']!.dispose();
      _headers[index]['value']!.dispose();
      _headers.removeAt(index);
    });
  }

  http_header.Config getConfig() {
    final headers = <http_header.Header>[];
    for (var header in _headers) {
      final name = header['name']!.text;
      final value = header['value']!.text;
      if (name.isNotEmpty) {
        headers.add(http_header.Header(
          name: name,
          value: value.isNotEmpty ? [value] : [],
        ));
      }
    }

    return http_header.Config(
      request: http_header.RequestConfig(
        version: _versionController.text.isNotEmpty
            ? http_header.Version(value: _versionController.text)
            : null,
        method: _methodController.text.isNotEmpty
            ? http_header.Method(value: _methodController.text)
            : null,
        uri: _pathController.text.isNotEmpty ? [_pathController.text] : [],
        header: headers,
      ),
    );
  }

  @override
  void dispose() {
    _versionController.dispose();
    _methodController.dispose();
    _pathController.dispose();
    for (var header in _headers) {
      header['name']!.dispose();
      header['value']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(
      children: [
        Text('HTTP Header Configuration',
            style: Theme.of(context).textTheme.titleMedium),
        const Gap(10),
        TextFormField(
          controller: _versionController,
          decoration: const InputDecoration(
            labelText: 'HTTP Version',
            helperText: 'e.g., 1.1 or 2.0',
          ),
        ),
        const Gap(10),
        TextFormField(
          controller: _methodController,
          decoration: const InputDecoration(
            labelText: 'HTTP Method',
            helperText: 'e.g., GET, POST, CONNECT',
          ),
        ),
        const Gap(10),
        TextFormField(
          controller: _pathController,
          decoration: const InputDecoration(
            labelText: 'Path/URI',
            helperText: 'e.g., /, /login.php',
          ),
        ),
        const Gap(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Headers', style: Theme.of(context).textTheme.titleSmall),
            IconButton.filledTonal(
              icon: const Icon(Icons.add),
              onPressed: _addHeader,
              tooltip: 'Add Header',
            ),
          ],
        ),
        const Gap(10),
        ..._headers.asMap().entries.map((entry) {
          final index = entry.key;
          final header = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: header['name'],
                    decoration: const InputDecoration(
                      labelText: 'Header Name',
                      hintText: 'e.g., User-Agent',
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: header['value'],
                    decoration: const InputDecoration(
                      labelText: 'Header Value',
                      hintText: 'e.g., Mozilla/5.0',
                    ),
                  ),
                ),
                if (_headers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeHeader(index),
                    tooltip: 'Remove Header',
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// SRTP Header Configuration Widget
class _TcpHeaderSrtp extends StatefulWidget {
  const _TcpHeaderSrtp({super.key, this.initialConfig});

  final Any? initialConfig;

  @override
  State<_TcpHeaderSrtp> createState() => _TcpHeaderSrtpState();
}

class _TcpHeaderSrtpState extends State<_TcpHeaderSrtp> {
  final TextEditingController _versionController = TextEditingController();
  final TextEditingController _csrcCountController = TextEditingController();
  final TextEditingController _payloadTypeController = TextEditingController();
  bool _padding = false;
  bool _extension = false;
  bool _marker = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      try {
        final config =
            srtp_header.Config.fromBuffer(widget.initialConfig!.value);
        if (config.hasVersion()) {
          _versionController.text = config.version.toString();
        }
        _padding = config.padding;
        _extension = config.extension_3;
        if (config.hasCsrcCount()) {
          _csrcCountController.text = config.csrcCount.toString();
        }
        _marker = config.marker;
        if (config.hasPayloadType()) {
          _payloadTypeController.text = config.payloadType.toString();
        }
      } catch (e) {
        // Invalid config, ignore
      }
    }
  }

  srtp_header.Config getConfig() {
    return srtp_header.Config(
      version: _versionController.text.isNotEmpty
          ? int.parse(_versionController.text)
          : 0,
      padding: _padding,
      extension_3: _extension,
      csrcCount: _csrcCountController.text.isNotEmpty
          ? int.parse(_csrcCountController.text)
          : 0,
      marker: _marker,
      payloadType: _payloadTypeController.text.isNotEmpty
          ? int.parse(_payloadTypeController.text)
          : 0,
    );
  }

  @override
  void dispose() {
    _versionController.dispose();
    _csrcCountController.dispose();
    _payloadTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(
      children: [
        Text('SRTP Header Configuration',
            style: Theme.of(context).textTheme.titleMedium),
        const Gap(10),
        TextFormField(
          controller: _versionController,
          decoration: const InputDecoration(
            labelText: 'Version',
            helperText: 'SRTP version (default: 2)',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null &&
                value.isNotEmpty &&
                int.tryParse(value) == null) {
              return 'Invalid number';
            }
            return null;
          },
        ),
        const Gap(10),
        TextFormField(
          controller: _csrcCountController,
          decoration: const InputDecoration(
            labelText: 'CSRC Count',
            helperText: 'Contributing source count',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null &&
                value.isNotEmpty &&
                int.tryParse(value) == null) {
              return 'Invalid number';
            }
            return null;
          },
        ),
        const Gap(10),
        TextFormField(
          controller: _payloadTypeController,
          decoration: const InputDecoration(
            labelText: 'Payload Type',
            helperText: 'RTP payload type',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null &&
                value.isNotEmpty &&
                int.tryParse(value) == null) {
              return 'Invalid number';
            }
            return null;
          },
        ),
        const Gap(10),
        SwitchListTile(
          title: const Text('Padding'),
          subtitle: const Text('Enable padding bit'),
          value: _padding,
          onChanged: (value) => setState(() => _padding = value),
        ),
        SwitchListTile(
          title: const Text('Extension'),
          subtitle: const Text('Enable extension bit'),
          value: _extension,
          onChanged: (value) => setState(() => _extension = value),
        ),
        SwitchListTile(
          title: const Text('Marker'),
          subtitle: const Text('Enable marker bit'),
          value: _marker,
          onChanged: (value) => setState(() => _marker = value),
        ),
      ],
    );
  }
}

// uTP Header Configuration Widget
class _TcpHeaderUtp extends StatefulWidget {
  const _TcpHeaderUtp({super.key, this.initialConfig});

  final Any? initialConfig;

  @override
  State<_TcpHeaderUtp> createState() => _TcpHeaderUtpState();
}

class _TcpHeaderUtpState extends State<_TcpHeaderUtp> {
  final TextEditingController _versionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      try {
        final config =
            utp_header.Config.fromBuffer(widget.initialConfig!.value);
        if (config.hasVersion()) {
          _versionController.text = config.version.toString();
        }
      } catch (e) {
        // Invalid config, ignore
      }
    }
  }

  utp_header.Config getConfig() {
    return utp_header.Config(
      version: _versionController.text.isNotEmpty
          ? int.parse(_versionController.text)
          : 0,
    );
  }

  @override
  void dispose() {
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(
      children: [
        Text('uTP Header Configuration',
            style: Theme.of(context).textTheme.titleMedium),
        const Gap(10),
        TextFormField(
          controller: _versionController,
          decoration: const InputDecoration(
            labelText: 'Version',
            helperText: 'uTP protocol version (default: 1)',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null &&
                value.isNotEmpty &&
                int.tryParse(value) == null) {
              return 'Invalid number';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _TransportProtocolKcp extends StatefulWidget {
  final KcpConfig? initialConfig;

  const _TransportProtocolKcp({
    required this.initialConfig,
    super.key,
  });

  @override
  _TransportProtocolKcpState createState() => _TransportProtocolKcpState();
}

class _TransportProtocolKcpState extends State<_TransportProtocolKcp>
    with TransportProtocolConfigGetter {
  late TextEditingController _mtuController;
  late TextEditingController _ttiController;
  late TextEditingController _uplinkCapacityController;
  late TextEditingController _downlinkCapacityController;
  late TextEditingController _readBufferSizeController;
  late TextEditingController _writeBufferSizeController;

  @override
  Object get transportProtocolConfig {
    return KcpConfig(
      mtu: _mtuController.text.isNotEmpty
          ? int.parse(_mtuController.text)
          : null,
      tti: _ttiController.text.isNotEmpty
          ? int.parse(_ttiController.text)
          : null,
      uplinkCapacity: _uplinkCapacityController.text.isNotEmpty
          ? int.parse(_uplinkCapacityController.text)
          : null,
      downlinkCapacity: _downlinkCapacityController.text.isNotEmpty
          ? int.parse(_downlinkCapacityController.text)
          : null,
      readBuffer: _readBufferSizeController.text.isNotEmpty
          ? int.parse(_readBufferSizeController.text)
          : null,
      writeBuffer: _writeBufferSizeController.text.isNotEmpty
          ? int.parse(_writeBufferSizeController.text)
          : null,
    );
  }

  @override
  void initState() {
    super.initState();
    _mtuController = TextEditingController();
    _ttiController = TextEditingController();
    _uplinkCapacityController = TextEditingController();
    _downlinkCapacityController = TextEditingController();
    _readBufferSizeController = TextEditingController();
    _writeBufferSizeController = TextEditingController();
    if (widget.initialConfig != null) {
      _mtuController.text = widget.initialConfig!.mtu != 0
          ? widget.initialConfig!.mtu.toString()
          : '';
      _ttiController.text = widget.initialConfig!.tti != 0
          ? widget.initialConfig!.tti.toString()
          : '';
      _uplinkCapacityController.text = widget.initialConfig!.uplinkCapacity != 0
          ? widget.initialConfig!.uplinkCapacity.toString()
          : '';
      _downlinkCapacityController.text =
          widget.initialConfig!.downlinkCapacity != 0
              ? widget.initialConfig!.downlinkCapacity.toString()
              : '';
      _readBufferSizeController.text = widget.initialConfig!.readBuffer != 0
          ? widget.initialConfig!.readBuffer.toString()
          : '';
      _writeBufferSizeController.text = widget.initialConfig!.writeBuffer != 0
          ? widget.initialConfig!.writeBuffer.toString()
          : '';
    }
  }

  @override
  void didUpdateWidget(covariant _TransportProtocolKcp oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _mtuController,
                decoration: const InputDecoration(labelText: 'MTU'),
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    int? i = int.tryParse(_mtuController.text);
                    if (i == null) {
                      return 'Not an integer';
                    }
                  }
                  return null;
                },
              ),
            ),
            const Gap(10),
            Expanded(
              child: TextFormField(
                controller: _ttiController,
                decoration: const InputDecoration(labelText: 'TTI'),
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    int? i = int.tryParse(_ttiController.text);
                    if (i == null) {
                      return 'Not an integer';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const Gap(10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _uplinkCapacityController,
                decoration: const InputDecoration(labelText: 'Uplink Capacity'),
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    int? i = int.tryParse(_uplinkCapacityController.text);
                    if (i == null) {
                      return 'Not an integer';
                    }
                  }
                  return null;
                },
              ),
            ),
            const Gap(10),
            Expanded(
              child: TextFormField(
                controller: _downlinkCapacityController,
                decoration:
                    const InputDecoration(labelText: 'Downlink Capacity'),
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    int? i = int.tryParse(value);
                    if (i == null) {
                      return 'Not an integer';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const Gap(10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _readBufferSizeController,
                decoration:
                    const InputDecoration(labelText: 'Read Buffer Size'),
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    int? i = int.tryParse(value);
                    if (i == null) {
                      return 'Not an integer';
                    }
                  }
                  return null;
                },
              ),
            ),
            const Gap(10),
            Expanded(
              child: TextFormField(
                controller: _writeBufferSizeController,
                decoration:
                    const InputDecoration(labelText: 'Write Buffer Size'),
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    int? i = int.tryParse(value);
                    if (i == null) {
                      return 'Not an integer';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        // _TransportHeaderSelector(),
      ],
    );
  }

  @override
  void dispose() {
    _mtuController.dispose();
    _ttiController.dispose();
    _uplinkCapacityController.dispose();
    _downlinkCapacityController.dispose();
    _readBufferSizeController.dispose();
    _writeBufferSizeController.dispose();
    super.dispose();
  }
}

class _TransportProtocolWebsocket extends StatefulWidget {
  const _TransportProtocolWebsocket({
    required this.initialConfig,
    super.key,
  });
  final WebsocketConfig? initialConfig;
  @override
  _TransportProtocolWebsocketState createState() =>
      _TransportProtocolWebsocketState();
}

class _TransportProtocolWebsocketState
    extends State<_TransportProtocolWebsocket>
    with TransportProtocolConfigGetter {
  final TextEditingController _pathController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _maxEarlyDataController = TextEditingController();
  final TextEditingController _earlyDataHeaderNameController =
      TextEditingController();
  final TextEditingController _headerKeyController = TextEditingController();
  final TextEditingController _headerValueControllr = TextEditingController();
  final _headers = <Header>[];

  @override
  Object get transportProtocolConfig {
    if (_headerKeyController.text.isNotEmpty) {
      _headers.add(Header(
          key: _headerKeyController.text, value: _headerValueControllr.text));
    }
    return WebsocketConfig(
      path: _pathController.text,
      host: _hostController.text,
      maxEarlyData: _maxEarlyDataController.text.isNotEmpty
          ? int.parse(_maxEarlyDataController.text)
          : null,
      earlyDataHeaderName: _earlyDataHeaderNameController.text,
      header: _headers,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      _pathController.text = widget.initialConfig!.path;
      _maxEarlyDataController.text = widget.initialConfig!.maxEarlyData != 0
          ? widget.initialConfig!.maxEarlyData.toString()
          : '';
      _earlyDataHeaderNameController.text =
          widget.initialConfig!.earlyDataHeaderName;
      _hostController.text = widget.initialConfig!.host;
      _headers.addAll(widget.initialConfig!.header);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _pathController,
          decoration: const InputDecoration(labelText: 'Path'),
          validator: (value) {
            return null;
          },
        ),
        const Gap(10),
        TextFormField(
          controller: _hostController,
          decoration: const InputDecoration(labelText: 'Host'),
          validator: (value) {
            return null;
          },
        ),
        const Gap(10),
        TextFormField(
          controller: _maxEarlyDataController,
          decoration: const InputDecoration(labelText: 'Max Early Data'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              int? i = int.tryParse(value);
              if (i == null) {
                return 'Not an integer';
              }
            }
            return null;
          },
        ),
        const Gap(10),
        TextFormField(
          controller: _earlyDataHeaderNameController,
          decoration:
              const InputDecoration(labelText: 'Early Data Header Name'),
          validator: (value) {
            return null;
          },
        ),
        // Gap(10),
        Row(
          children: [
            Text('Headers', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
                onPressed: _addNewHeader,
                icon: const Icon(Icons.add_box_outlined))
          ],
        ),
        ..._buildHeaderFields(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _headerKeyController,
                decoration: const InputDecoration(labelText: 'Key'),
                validator: (value) {
                  return null;
                },
              ),
            ),
            const Gap(10),
            Expanded(
              child: TextFormField(
                controller: _headerValueControllr,
                decoration: const InputDecoration(labelText: 'Value'),
              ),
            )
          ],
        ),
        const Gap(10),
      ],
    );
  }

  List<Widget> _buildHeaderFields() {
    return _headers.asMap().entries.map((entry) {
      int index = entry.key;
      Header header = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: header.key,
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  _headers[index].key = value;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: header.value,
                decoration: const InputDecoration(labelText: 'Value'),
                onChanged: (value) {
                  _headers[index].value = value;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeHeader(index),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _addNewHeader() {
    if (_headerKeyController.text.isEmpty &&
        _headerValueControllr.text.isEmpty) {
      return;
    }
    setState(() {
      _headers.add(Header(
          key: _headerKeyController.text, value: _headerValueControllr.text));
      _headerKeyController.clear();
      _headerValueControllr.clear();
    });
  }

  void _removeHeader(int index) {
    setState(() {
      _headers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _pathController.dispose();
    _hostController.dispose();
    _maxEarlyDataController.dispose();
    _earlyDataHeaderNameController.dispose();
    _headerKeyController.dispose();
    _headerValueControllr.dispose();
    super.dispose();
  }
}

class HeadersForm extends StatefulWidget {
  const HeadersForm({super.key, required this.headers});
  final PbMap<String, String> headers;
  @override
  State<HeadersForm> createState() => _HeadersFormState();
}

class _HeadersFormState extends State<HeadersForm> {
  final TextEditingController _headerKeyController = TextEditingController();
  final TextEditingController _headerValueControllr = TextEditingController();

  @override
  void dispose() {
    _headerKeyController.dispose();
    _headerValueControllr.dispose();
    super.dispose();
  }

  void _addNewHeader() {
    if (_headerKeyController.text.isEmpty &&
        _headerValueControllr.text.isEmpty) {
      return;
    }
    setState(() {
      widget.headers[_headerKeyController.text] = _headerValueControllr.text;
      _headerKeyController.clear();
      _headerValueControllr.clear();
    });
  }

  List<Widget> _buildHeaderFields() {
    return widget.headers.entries.map((entry) {
      String key = entry.key;
      String value = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: key,
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  widget.headers.remove(key);
                  widget.headers[value] = value;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: value,
                decoration: const InputDecoration(labelText: 'Value'),
                onChanged: (value) {
                  widget.headers[key] = value;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeHeader(key),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _removeHeader(String key) {
    setState(() {
      widget.headers.remove(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('Headers', style: Theme.of(context).textTheme.titleSmall),
            IconButton(
                onPressed: _addNewHeader,
                icon: const Icon(Icons.add_box_outlined))
          ],
        ),
        ..._buildHeaderFields(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _headerKeyController,
                decoration: const InputDecoration(labelText: 'Key'),
                validator: (value) {
                  if (value?.isNotEmpty ??
                      false || _headerValueControllr.text.isNotEmpty) {
                    widget.headers[value!] = _headerValueControllr.text;
                  }
                  return null;
                },
              ),
            ),
            const Gap(10),
            Expanded(
              child: TextFormField(
                controller: _headerValueControllr,
                decoration: const InputDecoration(labelText: 'Value'),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class _TransportProtocolGrpc extends StatefulWidget {
  const _TransportProtocolGrpc({required this.initialConfig, super.key});
  final GrpcConfig? initialConfig;
  @override
  State<_TransportProtocolGrpc> createState() => __TransportProtocolGrpcState();
}

class __TransportProtocolGrpcState extends State<_TransportProtocolGrpc>
    with TransportProtocolConfigGetter {
  final TextEditingController _authorityController = TextEditingController();
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _idleTimeoutController = TextEditingController();
  final TextEditingController _healthCheckTimeoutController =
      TextEditingController();
  final TextEditingController _initialWindowsSizeController =
      TextEditingController();
  final TextEditingController _userAgentController = TextEditingController();
  bool _multiMode = false;
  bool _permitWithoutStream = false;

  @override
  Object get transportProtocolConfig {
    return GrpcConfig(
      authority: _authorityController.text,
      serviceName: _serviceNameController.text,
      multiMode: _multiMode,
      idleTimeout: _idleTimeoutController.text.isNotEmpty
          ? int.parse(_idleTimeoutController.text)
          : 0,
      healthCheckTimeout: _healthCheckTimeoutController.text.isNotEmpty
          ? int.parse(_healthCheckTimeoutController.text)
          : 0,
      permitWithoutStream: _permitWithoutStream,
      initialWindowsSize: _initialWindowsSizeController.text.isNotEmpty
          ? int.parse(_initialWindowsSizeController.text)
          : 0,
      userAgent: _userAgentController.text,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      _authorityController.text = widget.initialConfig!.authority;
      _serviceNameController.text = widget.initialConfig!.serviceName;
      _multiMode = widget.initialConfig!.multiMode;
      if (widget.initialConfig!.idleTimeout != 0) {
        _idleTimeoutController.text =
            widget.initialConfig!.idleTimeout.toString();
      }
      if (widget.initialConfig!.healthCheckTimeout != 0) {
        _healthCheckTimeoutController.text =
            widget.initialConfig!.healthCheckTimeout.toString();
      }
      _permitWithoutStream = widget.initialConfig!.permitWithoutStream;
      if (widget.initialConfig!.initialWindowsSize != 0) {
        _initialWindowsSizeController.text =
            widget.initialConfig!.initialWindowsSize.toString();
      }
      _userAgentController.text = widget.initialConfig!.userAgent;
    }
  }

  @override
  void dispose() {
    _authorityController.dispose();
    _serviceNameController.dispose();
    _idleTimeoutController.dispose();
    _healthCheckTimeoutController.dispose();
    _initialWindowsSizeController.dispose();
    _userAgentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _authorityController,
          decoration: const InputDecoration(
            labelText: 'Authority',
            helperText: 'gRPC authority header',
          ),
        ),
        const Gap(10),
        TextFormField(
          controller: _serviceNameController,
          decoration: const InputDecoration(
            labelText: 'Service Name',
            helperText: 'gRPC service name',
          ),
        ),
        const Gap(10),
        TextFormField(
          controller: _userAgentController,
          decoration: const InputDecoration(
            labelText: 'User Agent',
            helperText: 'Custom user agent string',
          ),
        ),
        const Gap(10),
        TextFormField(
          controller: _idleTimeoutController,
          decoration: const InputDecoration(
            labelText: 'Idle Timeout (seconds)',
            helperText: 'Connection idle timeout',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (int.tryParse(value) == null) {
                return 'Invalid number';
              }
            }
            return null;
          },
        ),
        const Gap(10),
        TextFormField(
          controller: _healthCheckTimeoutController,
          decoration: const InputDecoration(
            labelText: 'Health Check Timeout (seconds)',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (int.tryParse(value) == null) {
                return 'Invalid number';
              }
            }
            return null;
          },
        ),
        const Gap(10),
        TextFormField(
          controller: _initialWindowsSizeController,
          decoration: const InputDecoration(
            labelText: 'Initial Window Size (bytes)',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (int.tryParse(value) == null) {
                return 'Invalid number';
              }
            }
            return null;
          },
        ),
        const Gap(10),
        SwitchListTile(
          title: const Text('Multi Mode'),
          value: _multiMode,
          onChanged: (value) => setState(() => _multiMode = value),
        ),
        SwitchListTile(
          title: const Text('Permit Without Stream'),
          value: _permitWithoutStream,
          onChanged: (value) => setState(() => _permitWithoutStream = value),
        ),
      ],
    );
  }
}

class _TransportProtocolSplitHttp extends StatefulWidget {
  const _TransportProtocolSplitHttp(
      {required this.config,
      this.inDownConfig = false,
      this.server = false,
      super.key});
  final SplitHttpConfig? config;
  final bool inDownConfig;
  final bool server;
  @override
  State<_TransportProtocolSplitHttp> createState() =>
      __TransportProtocolSplitHttpState();
}

enum SplitHttpMode {
  auto(display: 'auto'),
  packetUp(display: 'packet-up'),
  streamOne(display: 'stream-one'),
  streamUp(display: 'stream-up');

  final String display;

  const SplitHttpMode({required this.display});

  static SplitHttpMode fromName(String name) {
    return SplitHttpMode.values.firstWhere((e) => e.display == name);
  }
}

class __TransportProtocolSplitHttpState
    extends State<_TransportProtocolSplitHttp>
    with TransportProtocolConfigGetter {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _pathController = TextEditingController();
  final TextEditingController _hKeepAlivePeriod = TextEditingController();
  final _xmux = XmuxConfig(
    maxConcurrency: RangeConfig(),
    maxConnections: RangeConfig(),
    cMaxReuseTimes: RangeConfig(),
    hMaxRequestTimes: RangeConfig(),
    hMaxReusableSecs: RangeConfig(),
  );
  final _scMaxEachPostBytes = RangeConfig();
  final _scMinPostsIntervalMs = RangeConfig();
  SplitHttpMode _mode = SplitHttpMode.auto;
  final _headers = PbMap<String, String>(1, 2);
  final _xPaddingBytes = RangeConfig();
  bool _noGRPCHeader = false;
  final _downConfigKey = GlobalKey<__SplitHttpDownConfigState>();
  bool _showXmux = false;
  bool _noSSEHeader = false;
  final TextEditingController _scMaxBufferedPosts = TextEditingController();
  final _scStreamUpServerSecs = RangeConfig();

  @override
  Object get transportProtocolConfig {
    DownConfig? downConfig;
    if (_mode == SplitHttpMode.streamUp && !widget.inDownConfig) {
      downConfig = _downConfigKey.currentState?.downConfig;
    }
    if (_hKeepAlivePeriod.text.isNotEmpty) {
      _xmux.hKeepAlivePeriod = Int64(int.parse(_hKeepAlivePeriod.text));
    }
    return SplitHttpConfig(
      scMaxEachPostBytes: _scMaxEachPostBytes,
      scMinPostsIntervalMs: _scMinPostsIntervalMs,
      host: _hostController.text,
      path: _pathController.text,
      headers: _headers.entries.map((e) => MapEntry(e.key, e.value)).toList(),
      xPaddingBytes: _xPaddingBytes,
      xmux: _xmux,
      mode: _mode.display,
      noGRPCHeader: _noGRPCHeader,
      noSSEHeader: _noSSEHeader,
      scMaxBufferedPosts: _scMaxBufferedPosts.text.isNotEmpty
          ? Int64(int.parse(_scMaxBufferedPosts.text))
          : null,
      scStreamUpServerSecs: _scStreamUpServerSecs,
      downloadSettings: downConfig,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.config != null) {
      _hostController.text = widget.config!.host;
      _pathController.text = widget.config!.path;

      _headers.addAll(widget.config!.headers);

      _xPaddingBytes.from = widget.config!.xPaddingBytes.from;
      _xPaddingBytes.to = widget.config!.xPaddingBytes.to;
      _scMaxEachPostBytes.mergeFromMessage(widget.config!.scMaxEachPostBytes);
      _scMinPostsIntervalMs
          .mergeFromMessage(widget.config!.scMinPostsIntervalMs);
      _xmux.mergeFromMessage(widget.config!.xmux);
      if (widget.config!.xmux.hKeepAlivePeriod != 0) {
        _hKeepAlivePeriod.text =
            widget.config!.xmux.hKeepAlivePeriod.toString();
      }
      if (!widget.inDownConfig && widget.config!.mode.isNotEmpty) {
        _mode = SplitHttpMode.fromName(widget.config!.mode);
      }
      _noGRPCHeader = widget.config!.noGRPCHeader;
      _noSSEHeader = widget.config!.noSSEHeader;
      if (widget.config!.scMaxBufferedPosts != 0) {
        _scMaxBufferedPosts.text = widget.config!.scMaxBufferedPosts.toString();
      }
      _scStreamUpServerSecs
          .mergeFromMessage(widget.config!.scStreamUpServerSecs);
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _pathController.dispose();
    _hKeepAlivePeriod.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _hostController,
          decoration: const InputDecoration(labelText: 'Host'),
          validator: (value) {
            return null;
          },
        ),
        const Gap(10),
        TextFormField(
          controller: _pathController,
          decoration: const InputDecoration(labelText: 'Path'),
          validator: (value) {
            return null;
          },
        ),
        HeadersForm(headers: _headers),
        const Gap(10),
        RangeConfigCollect(config: _xPaddingBytes, label: 'xPaddingBytes'),
        if (!widget.inDownConfig)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownMenu<SplitHttpMode>(
                      requestFocusOnTap: false,
                      initialSelection: _mode,
                      label: const Text('Mode'),
                      onSelected: (SplitHttpMode? m) {
                        if (m != null) {
                          setState(() {
                            _mode = m;
                          });
                        }
                      },
                      dropdownMenuEntries: SplitHttpMode.values
                          .map<DropdownMenuEntry<SplitHttpMode>>(
                              (SplitHttpMode m) {
                        return DropdownMenuEntry<SplitHttpMode>(
                            value: m, label: m.display);
                      }).toList()),
                ),
                if (_mode == SplitHttpMode.packetUp ||
                    _mode == SplitHttpMode.auto)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RangeConfigCollect(
                        config: _scMaxEachPostBytes,
                        label: 'scMaxEachPostBytes'),
                  ),
                if (_mode == SplitHttpMode.packetUp ||
                    _mode == SplitHttpMode.auto)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RangeConfigCollect(
                        config: _scMinPostsIntervalMs,
                        label: 'scMinPostsIntervalMs'),
                  ),
                if ((_mode == SplitHttpMode.packetUp ||
                        _mode == SplitHttpMode.auto) &&
                    widget.server)
                  TextFormField(
                    controller: _scMaxBufferedPosts,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration:
                        const InputDecoration(labelText: 'scMaxBufferedPosts'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      return null;
                    },
                  ),
                if ((_mode == SplitHttpMode.streamUp ||
                        _mode == SplitHttpMode.auto) &&
                    widget.server)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RangeConfigCollect(
                        config: _scStreamUpServerSecs,
                        label: 'scStreamUpServerSecs'),
                  ),
                if (_mode != SplitHttpMode.packetUp ||
                    _mode == SplitHttpMode.auto)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Text('noGRPCHeader'),
                        const Gap(10),
                        Switch(
                            value: _noGRPCHeader,
                            onChanged: (value) {
                              setState(() {
                                _noGRPCHeader = value;
                              });
                            })
                      ],
                    ),
                  ),
                if (widget.server)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Text('noSSEHeader'),
                        const Gap(10),
                        Switch(
                            value: _noSSEHeader,
                            onChanged: (value) {
                              setState(() {
                                _noSSEHeader = value;
                              });
                            })
                      ],
                    ),
                  ),
                if (_mode == SplitHttpMode.streamUp ||
                    _mode == SplitHttpMode.auto)
                  _SplitHttpDownConfig(
                      key: _downConfigKey,
                      config: widget.config?.downloadSettings),
              ],
            ),
          ),
        const Gap(10),
        Row(
          children: [
            Text('Xmux', style: Theme.of(context).textTheme.titleSmall),
            TextButton(
                onPressed: () => setState(() {
                      _showXmux = !_showXmux;
                    }),
                child: Text(_showXmux ? '隐藏' : '显示'))
          ],
        ),
        const Gap(10),
        if (_showXmux)
          Column(
            children: [
              RangeConfigCollect(
                  config: _xmux.maxConcurrency, label: 'maxConcurrency'),
              const Gap(10),
              RangeConfigCollect(
                  config: _xmux.maxConnections, label: 'maxConnections'),
              const Gap(10),
              RangeConfigCollect(
                  config: _xmux.cMaxReuseTimes, label: 'cMaxReuseTimes'),
              const Gap(10),
              RangeConfigCollect(
                  config: _xmux.hMaxRequestTimes, label: 'hMaxRequestTimes'),
              const Gap(10),
              RangeConfigCollect(
                  config: _xmux.hMaxReusableSecs, label: 'hMaxReusableSecs'),
              const Gap(10),
              TextFormField(
                controller: _hKeepAlivePeriod,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'hKeepAlivePeriod'),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final parsed = int.tryParse(value);
                    if (parsed == null) {
                      return 'Not an integer';
                    }
                  }
                  return null;
                },
              ),
              const Gap(10),
            ],
          )
      ],
    );
  }
}

class _SplitHttpDownConfig extends StatefulWidget {
  const _SplitHttpDownConfig({super.key, required this.config});
  final DownConfig? config;
  @override
  State<_SplitHttpDownConfig> createState() => __SplitHttpDownConfigState();
}

class __SplitHttpDownConfigState extends State<_SplitHttpDownConfig> {
  final TextEditingController _address = TextEditingController();
  final TextEditingController _port = TextEditingController();
  DownConfig_Security _security = DownConfig_Security.notSet;
  final _tls = TlsConfig();
  final _reality = RealityConfig();
  final _splitHttpConfigKey = GlobalKey<__TransportProtocolSplitHttpState>();

  DownConfig get downConfig {
    return DownConfig(
      address: _address.text,
      port: int.parse(_port.text),
      xhttpConfig: _splitHttpConfigKey.currentState?.transportProtocolConfig
          as SplitHttpConfig,
      tls: _security == DownConfig_Security.tls ? _tls : null,
      reality: _security == DownConfig_Security.reality ? _reality : null,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.config != null) {
      _address.text = widget.config!.address;
      if (widget.config!.port != 0) {
        _port.text = widget.config!.port.toString();
      }
      _security = widget.config!.whichSecurity();
      if (widget.config!.hasTls()) {
        _tls.mergeFromMessage(widget.config!.tls);
      }
      if (widget.config!.hasReality()) {
        _reality.mergeFromMessage(widget.config!.reality);
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _address.dispose();
    _port.dispose();
    super.dispose();
  }

  void _setSecurity(DownConfig_Security? s) {
    setState(() {
      _security = s ?? DownConfig_Security.notSet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Download Settings',
              style: Theme.of(context).textTheme.titleSmall),
          const Gap(10),
          TextFormField(
            controller: _address,
            validator: (value) {
              return null;
            },
            decoration: const InputDecoration(labelText: 'Address'),
          ),
          const Gap(10),
          TextFormField(
            controller: _port,
            validator: (value) {
              final parsedPort = int.tryParse(value ?? '');
              if (parsedPort == 0 || parsedPort == null) {
                return 'Port is required';
              }
              return null;
            },
            decoration: const InputDecoration(labelText: 'Port'),
          ),
          const Gap(10),
          _TransportProtocolSplitHttp(
            key: _splitHttpConfigKey,
            config: widget.config?.xhttpConfig,
            inDownConfig: true,
          ),
          const Gap(10),
          DropdownMenu<DownConfig_Security>(
              requestFocusOnTap: false,
              initialSelection: _security,
              dropdownMenuEntries: DownConfig_Security.values
                  .map<DropdownMenuEntry<DownConfig_Security>>(
                      (DownConfig_Security s) {
                return DropdownMenuEntry<DownConfig_Security>(
                  label: s.label,
                  value: s,
                );
              }).toList(),
              onSelected: (DownConfig_Security? s) => _setSecurity(s),
              label: const Text('Download Security')),
          const Gap(10),
          if (_security == DownConfig_Security.tls)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TransportSecurityTls(config: _tls),
            ),
          if (_security == DownConfig_Security.reality)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _TransportSecurityReality(config: _reality),
            ),
        ],
      ),
    );
  }
}

class RangeConfigCollect extends StatefulWidget {
  const RangeConfigCollect(
      {super.key, required this.config, required this.label, this.fromMin});
  final RangeConfig config;
  final String label;
  final int? fromMin;

  @override
  State<RangeConfigCollect> createState() => _RangeConfigCollectState();
}

class _RangeConfigCollectState extends State<RangeConfigCollect> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startController.text = widget.config.from.toString();
    _endController.text = widget.config.to.toString();
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
        const Gap(10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: _startController,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final parsed = int.tryParse(value);
                    if (parsed == null) {
                      return 'Not an integer';
                    }
                    if (parsed < 0) {
                      return 'Must be greater than 0';
                    }
                    if (int.tryParse(_endController.text) != null) {
                      if (parsed > int.parse(_endController.text)) {
                        return 'Must be less than ${_endController.text}';
                      }
                    }
                    if (widget.fromMin != null && parsed <= widget.fromMin!) {
                      return 'Must be bigger than ${widget.fromMin}';
                    }
                    widget.config.from = parsed;
                  } else {
                    widget.config.from = 0;
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'From'),
              ),
            ),
            const Gap(10),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: _endController,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final parsed = int.tryParse(value);
                    if (parsed == null) {
                      return 'Not an integer';
                    }
                    if (parsed < 0) {
                      return 'Must be greater than 0';
                    }
                    if (int.tryParse(_startController.text) != null) {
                      if (parsed < int.parse(_startController.text)) {
                        return 'Must be greater than ${_startController.text}';
                      }
                    }
                    widget.config.to = parsed;
                  } else {
                    widget.config.to = 0;
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'To'),
              ),
            )
          ],
        )
      ],
    );
  }
}

class _TransportProtocolHttpUpgrade extends StatefulWidget {
  const _TransportProtocolHttpUpgrade({super.key, required this.initialConfig});
  final HttpUpgradeConfig? initialConfig;

  @override
  State<_TransportProtocolHttpUpgrade> createState() =>
      _TransportProtocolHttpUpgradeState();
}

class _TransportProtocolHttpUpgradeState
    extends State<_TransportProtocolHttpUpgrade>
    with TransportProtocolConfigGetter {
  final _websocketConfigKey = GlobalKey<_TransportProtocolWebsocketState>();

  @override
  Object get transportProtocolConfig {
    return HttpUpgradeConfig(
      config: _websocketConfigKey.currentState?.transportProtocolConfig
          as WebsocketConfig,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _TransportProtocolWebsocket(
        initialConfig: widget.initialConfig?.config, key: _websocketConfigKey);
  }
}
