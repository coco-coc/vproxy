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

/// config is modified directly. Some fields are saved when validating the form.
class _TransportSecurityTls extends StatefulWidget {
  const _TransportSecurityTls({
    required this.config,
    this.showAlpn = true,
    this.server = false,
  });

  final TlsConfig config;
  final bool showAlpn;
  final bool server;

  @override
  State<_TransportSecurityTls> createState() => _TransportSecurityTlsState();
}

class _TransportSecurityTlsState extends State<_TransportSecurityTls> {
  final TextEditingController _nextProtocolController = TextEditingController();
  final TextEditingController _serverNameController = TextEditingController();
  final TextEditingController _peerSHA256HashControlller =
      TextEditingController();
  final List<TextEditingController> _CAControllers = [];
  final _fingerprintController = TextEditingController();
  final _echConfigController = TextEditingController();

  // New controllers for missing fields
  final _masterKeyLogController = TextEditingController();
  final _echKeyController = TextEditingController();
  final _echConfigGenerateController = TextEditingController();
  String? _echConfigGenerateError;
  String? _noCertErrorMessage;

  @override
  void initState() {
    super.initState();
    _serverNameController.text = widget.config.serverName;
    _nextProtocolController.text = widget.config.nextProtocol.join(',');
    if (widget.config.pinnedPeerCertificateChainSha256.isNotEmpty) {
      _peerSHA256HashControlller.text =
          hex.encode(widget.config.pinnedPeerCertificateChainSha256.first);
    }
    // Initialize multiple Root CAs
    for (var cert in widget.config.rootCas) {
      final controller = TextEditingController(
        text: utf8.decode(cert),
      );
      _CAControllers.add(controller);
    }
    if (widget.config.echConfig.isNotEmpty) {
      _echConfigController.text = hex.encode(widget.config.echConfig);
    }
    _fingerprintController.text = widget.config.imitate;
    _masterKeyLogController.text = widget.config.masterKeyLog;
    if (widget.config.echKey.isNotEmpty) {
      _echKeyController.text = hex.encode(widget.config.echKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Basic TLS Configuration
        if (!widget.server)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextFormField(
              controller: _serverNameController,
              decoration: const InputDecoration(label: Text('Server Name')),
              validator: (value) {
                widget.config.serverName = _serverNameController.text;

                return null;
              },
            ),
          ),
        if (widget.showAlpn)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextFormField(
                controller: _nextProtocolController,
                decoration: const InputDecoration(
                    label: Text('Next Protocol'), hintText: 'h2,http/1.1'),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    List<String> protocols = value.split(',');
                    widget.config.nextProtocol.clear();
                    widget.config.nextProtocol.addAll(protocols);
                  } else {
                    widget.config.nextProtocol.clear();
                  }
                  return null;
                }),
          ),
        // Multiple Certificates Section
        _CertificateCollection(
          title: 'Certificate',
          errorMessage: _noCertErrorMessage,
          description: AppLocalizations.of(context)!.certToBeProvidedToPeer,
          certificates: widget.config.certificates,
          server: widget.server,
        ),
        const Gap(10),
        // Multiple Root CAs Section
        ExpansionTile(
            title:
                Text('Root CA', style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(AppLocalizations.of(context)!.verifyPeerCertDesc,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
            collapsedBackgroundColor:
                Theme.of(context).colorScheme.surfaceContainerLow,
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            childrenPadding: const EdgeInsets.all(10),
            children: [
              ..._CAControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          maxLines: 5,
                          decoration: InputDecoration(
                            label: Text('Root CA ${index + 1}'),
                          ),
                          validator: (value) {
                            // Validation happens globally for all Root CAs
                            if (index == 0) {
                              // Only validate once for all Root CAs
                              widget.config.rootCas.clear();
                              for (var ctrl in _CAControllers) {
                                if (ctrl.text.isNotEmpty) {
                                  widget.config.rootCas
                                      .add(utf8.encode(ctrl.text));
                                }
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      if (_CAControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              controller.dispose();
                              _CAControllers.removeAt(index);
                            });
                          },
                          tooltip: 'Remove Root CA',
                        ),
                    ],
                  ),
                );
              }),
              IconButton.filledTonal(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _CAControllers.add(TextEditingController());
                  });
                },
                tooltip: 'Add Root CA',
              ),
              const Gap(10),
            ]),

        const Gap(10),
        // Multiple Issue CAs Section
        if (widget.server)
          _CertificateCollection(
            title: 'Issue CA',
            description: AppLocalizations.of(context)!.issueCADesc,
            certificates: widget.config.issueCas,
            server: widget.server,
          ),
        const Gap(10),
        TextFormField(
            maxLines: 2,
            controller: _peerSHA256HashControlller,
            decoration: InputDecoration(
                label: const Text('SHA256(hex)'),
                helperText: AppLocalizations.of(context)!.verifyPeerCertDesc),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                try {
                  widget.config.pinnedPeerCertificateChainSha256.clear();
                  widget.config.pinnedPeerCertificateChainSha256
                      .add(hex.decode(_peerSHA256HashControlller.text));
                } catch (e) {
                  return 'Invalid';
                }
              } else {
                widget.config.pinnedPeerCertificateChainSha256.clear();
              }
              return null;
            }),
        if (!widget.server)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Text('Allow Insecure',
                    style: Theme.of(context).textTheme.titleMedium),
                const Gap(10),
                Switch(
                  value: widget.config.allowInsecure,
                  onChanged: (value) =>
                      setState(() => widget.config.allowInsecure = value),
                ),
              ],
            ),
          ),
        const Gap(10),
        Row(
          children: [
            Text('Disable System Root CAs',
                style: Theme.of(context).textTheme.titleMedium),
            const Gap(10),
            Switch(
              value: widget.config.disableSystemRoot,
              onChanged: (value) =>
                  setState(() => widget.config.disableSystemRoot = value),
            ),
          ],
        ),
        const Gap(10),
        Row(
          children: [
            Text('Enable Session Resumption',
                style: Theme.of(context).textTheme.titleMedium),
            const Gap(10),
            Switch(
              value: widget.config.enableSessionResumption,
              onChanged: (value) =>
                  setState(() => widget.config.enableSessionResumption = value),
            ),
          ],
        ),
        const Gap(10),
        if (widget.server)
          Row(
            children: [
              Text('Verify Client Certificate',
                  style: Theme.of(context).textTheme.titleMedium),
              const Gap(10),
              Switch(
                value: widget.config.verifyClientCertificate,
                onChanged: (value) => setState(
                    () => widget.config.verifyClientCertificate = value),
              ),
            ],
          ),
        const Gap(10),
        if (widget.server)
          TextFormField(
              controller: _echKeyController,
              maxLines: 3,
              decoration: const InputDecoration(
                  label: Text('ECH Key'),
                  helperText: 'Server ECH private key (hex encoded)'),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  try {
                    widget.config.echKey = hex.decode(_echKeyController.text);
                  } catch (e) {
                    return 'Invalid hex';
                  }
                } else {
                  widget.config.echKey = [];
                }
                return null;
              }),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TextFormField(
              controller: _echConfigController,
              decoration: const InputDecoration(
                  label: Text('ECH Config'),
                  helperText: 'Client ECH config (hex encoded)'),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  try {
                    widget.config.echConfig =
                        hex.decode(_echConfigController.text);
                  } catch (e) {
                    return 'Invalid hex';
                  }
                } else {
                  widget.config.echConfig = [];
                }
                return null;
              }),
        ),
        if (!widget.server)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SwitchListTile(
                title: Text(AppLocalizations.of(context)!.lookupEch),
                subtitle: Text(AppLocalizations.of(context)!.lookupEchDesc,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                value: widget.config.enableEch,
                onChanged: (value) =>
                    setState(() => widget.config.enableEch = value)),
          ),
        if (widget.server)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FormContainer(children: [
              TextFormField(
                controller: _echConfigGenerateController,
                decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.echDomain),
                    errorText: _echConfigGenerateError,
                    errorMaxLines: 3,
                    helperText: AppLocalizations.of(context)!.echDomainDesc),
                validator: (value) {
                  return null;
                },
              ),
              const Gap(5),
              FilledButton.tonal(
                onPressed: () async {
                  try {
                    if (_echConfigGenerateController.text.trim().isEmpty) {
                      setState(() {
                        _echConfigGenerateError =
                            AppLocalizations.of(context)!.fieldRequired;
                      });
                      return;
                    }
                    setState(() {
                      _echConfigGenerateError = null;
                    });
                    final response = await context
                        .read<XApiClient>()
                        .generateECHResponse(_echConfigGenerateController.text);
                    _echConfigController.text = hex.encode(response.config);
                    _echKeyController.text = hex.encode(response.key);
                  } catch (e) {
                    logger.e(e);
                    setState(() {
                      _echConfigGenerateError = e.toString();
                    });
                  }
                },
                child: Text(AppLocalizations.of(context)!.generateEchConfig),
              ),
            ]),
          ),
        const Gap(10),
        if (!widget.server)
          FormContainer(children: [
            Text('uTls Settings',
                style: Theme.of(context).textTheme.titleMedium),
            const Gap(10),
            TextFormField(
                controller: _fingerprintController,
                decoration: const InputDecoration(
                    label: Text('Fingerprint'),
                    helperText: 'uTLS fingerprint to imitate'),
                validator: (value) {
                  widget.config.imitate = _fingerprintController.text;
                  return null;
                }),
            const Gap(10),
            DropdownButtonFormField<ForceALPN>(
              initialValue: widget.config.forceAlpn,
              decoration: const InputDecoration(
                  label: Text('Force ALPN'),
                  helperText: 'Force ALPN behavior (uTLS)'),
              items: ForceALPN.values.map((ForceALPN value) {
                String displayName;
                switch (value) {
                  case ForceALPN.TRANSPORT_PREFERENCE_TAKE_PRIORITY:
                    displayName = 'Transport Preference';
                    break;
                  case ForceALPN.NO_ALPN:
                    displayName = 'No ALPN';
                    break;
                  case ForceALPN.UTLS_PRESET:
                    displayName = 'uTLS Preset';
                    break;
                  default:
                    displayName = value.name;
                }
                return DropdownMenuItem<ForceALPN>(
                  value: value,
                  child: Text(displayName),
                );
              }).toList(),
              onChanged: (ForceALPN? newValue) {
                if (newValue != null) {
                  setState(() => widget.config.forceAlpn = newValue);
                }
              },
            ),
            SwitchListTile(
              value: widget.config.noSNI,
              onChanged: (value) => setState(() => widget.config.noSNI = value),
              title: const Text('No SNI'),
            ),
          ]),
        // Hidden FormField to trigger validation listener
        FormField<String>(
          initialValue: '',
          builder: (field) => const SizedBox.shrink(),
          validator: (value) {
            if (widget.server &&
                widget.config.certificates.isEmpty &&
                widget.config.issueCas.isEmpty) {
              setState(() {
                _noCertErrorMessage =
                    'One of certificates or issue cas must be provided';
              });
              return 'One of certificates or issue cas must be provided';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _serverNameController.dispose();
    _nextProtocolController.dispose();
    _peerSHA256HashControlller.dispose();
    _echConfigGenerateController.dispose();
    // Dispose all CA controllers
    for (var controller in _CAControllers) {
      controller.dispose();
    }
    _fingerprintController.dispose();
    _echConfigController.dispose();
    _masterKeyLogController.dispose();
    _echKeyController.dispose();
    super.dispose();
  }
}

/// certificates is modified directly, some fields are saved when validating
class _CertificateCollection extends StatefulWidget {
  const _CertificateCollection({
    required this.title,
    required this.description,
    required this.certificates,
    required this.server,
    this.errorMessage,
  });

  final String title;
  final String description;
  final List<Certificate> certificates;
  final bool server;
  final String? errorMessage;

  @override
  State<_CertificateCollection> createState() => _CertificateCollectionState();
}

class _CertificateCollectionState extends State<_CertificateCollection> {
  final List<TextEditingController> _certControllers = [];
  final List<TextEditingController> _keyControllers = [];
  final List<TextEditingController> _certPathControllers = [];
  final List<TextEditingController> _keyPathControllers = [];
  final TextEditingController _domainController = TextEditingController();
  String? _domainError;
  String? _certError;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var cert in widget.certificates) {
      _certControllers.add(TextEditingController(
        text: cert.certificate.isNotEmpty ? utf8.decode(cert.certificate) : '',
      ));
      _keyControllers.add(TextEditingController(
        text: cert.key.isNotEmpty ? utf8.decode(cert.key) : '',
      ));
      _certPathControllers.add(TextEditingController(
        text: cert.certificateFilepath,
      ));
      _keyPathControllers.add(TextEditingController(
        text: cert.keyFilepath,
      ));
    }
  }

  void _addEmptyControllers() {
    widget.certificates.add(Certificate());
    _certControllers.add(TextEditingController());
    _keyControllers.add(TextEditingController());
    _certPathControllers.add(TextEditingController());
    _keyPathControllers.add(TextEditingController());
  }

  void _removeControllers(int index) {
    widget.certificates.removeAt(index);
    _certControllers[index].dispose();
    _keyControllers[index].dispose();
    _certPathControllers[index].dispose();
    _keyPathControllers[index].dispose();
    _certControllers.removeAt(index);
    _keyControllers.removeAt(index);
    _certPathControllers.removeAt(index);
    _keyPathControllers.removeAt(index);
  }

  @override
  void dispose() {
    for (var controller in _certControllers) {
      controller.dispose();
    }
    for (var controller in _keyControllers) {
      controller.dispose();
    }
    for (var controller in _certPathControllers) {
      controller.dispose();
    }
    for (var controller in _keyPathControllers) {
      controller.dispose();
    }
    _domainController.dispose();
    super.dispose();
  }

  Future<void> _generateCertificate() async {
    if (_domainController.text.trim().isEmpty) {
      setState(() {
        _domainError = AppLocalizations.of(context)!.fieldRequired;
      });
      return;
    }
    final domain = _domainController.text.trim();
    setState(() {
      _domainError = null;
      _isGenerating = true;
    });

    try {
      final cert = await context.read<XApiClient>().generateCert(domain);
      setState(() {
        widget.certificates.add(Certificate(
          certificate: cert.cert,
          key: cert.key,
        ));
        _certControllers.add(TextEditingController(
          text: utf8.decode(cert.cert),
        ));
        _keyControllers.add(TextEditingController(
          text: utf8.decode(cert.key),
        ));
        _certPathControllers.add(TextEditingController());
        _keyPathControllers.add(TextEditingController());
        _domainController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate certificate: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<String?> _extractDomainFromCert(String cert) async {
    return await context.read<XApiClient>().extractCertDomain(cert);
  }

  void _validateCertificates() {
    for (var i = 0; i < _certControllers.length; i++) {
      if (widget.server) {
        if ((_certControllers[i].text.isEmpty &&
                _certPathControllers[i].text.isEmpty) ||
            (_keyControllers[i].text.isEmpty &&
                _keyPathControllers[i].text.isEmpty)) {
          setState(() {
            _certError =
                'Certificate and certificate file path cannot be empty at the same time';
          });
          return;
        } else {
          if (widget.certificates[i].certificate.isEmpty ||
              widget.certificates[i].key.isEmpty) {
            setState(() {
              _certError = 'Certificate and key cannot be empty';
            });
          }
          return;
        }
      }
    }
    setState(() {
      _certError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title:
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: _certError != null || widget.errorMessage != null
            ? Text(_certError != null ? _certError! : widget.errorMessage!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Theme.of(context).colorScheme.error))
            : Text(widget.description,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
        onExpansionChanged: (value) {
          if (!value) {
            _validateCertificates();
          }
        },
        initiallyExpanded: widget.server,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        collapsedBackgroundColor:
            Theme.of(context).colorScheme.surfaceContainerLow,
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        childrenPadding: const EdgeInsets.all(10),
        children: [
          ..._certControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final certController = entry.value;
            final keyController = _keyControllers[index];
            final certPathController = _certPathControllers[index];
            final keyPathController = _keyPathControllers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: certController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            label: Text('${widget.title} ${index + 1}'),
                            errorMaxLines: 3,
                            helper: certController.text.isNotEmpty
                                ? FutureBuilder<String?>(
                                    future: _extractDomainFromCert(
                                        certController.text),
                                    builder: (context, snapshot) {
                                      return snapshot.hasData &&
                                              snapshot.data!.isNotEmpty
                                          ? Text(
                                              '${AppLocalizations.of(context)!.domain}: ${snapshot.data}')
                                          : const SizedBox.shrink();
                                    },
                                  )
                                : null,
                          ),
                          onEditingComplete: () {
                            // Trigger rebuild to update domain display
                            setState(() {});
                          },
                          onChanged: (value) {
                            widget.certificates[index].certificate =
                                utf8.encode(value);
                          },
                          validator: (value) {
                            final cert = _certControllers[index];
                            final certPath = _certPathControllers[index];
                            if (widget.server &&
                                cert.text.isEmpty &&
                                certPath.text.isEmpty) {
                              return 'Certificate and certificate file path cannot be empty at the same time';
                            } else if (!widget.server && cert.text.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .fieldRequired;
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _removeControllers(index);
                          });
                        },
                        tooltip: 'Remove ${widget.title}',
                      ),
                    ],
                  ),
                  const Gap(10),
                  TextFormField(
                    controller: keyController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      label: Text('Private Key ${index + 1}'),
                      helperText: 'Private key (PEM format)',
                    ),
                    onChanged: (value) {
                      widget.certificates[index].key = utf8.encode(value);
                    },
                    validator: (value) {
                      final key = _keyControllers[index];
                      final keyPath = _keyPathControllers[index];
                      if (widget.server &&
                          key.text.isEmpty &&
                          keyPath.text.isEmpty) {
                        return 'Key and key file path cannot be empty at the same time';
                      } else if (!widget.server && key.text.isEmpty) {
                        return AppLocalizations.of(context)!.fieldRequired;
                      }
                      return null;
                    },
                  ),
                  if (widget.server) ...[
                    const Gap(10),
                    TextFormField(
                      controller: certPathController,
                      decoration: InputDecoration(
                        label: Text('${widget.title} ${index + 1} File Path'),
                        helperText: 'Path to certificate file on server',
                      ),
                      onChanged: (value) {
                        widget.certificates[index].certificateFilepath = value;
                      },
                    ),
                    const Gap(10),
                    TextFormField(
                      controller: keyPathController,
                      decoration: InputDecoration(
                        label: Text('Key ${index + 1} File Path'),
                        helperText: 'Path to private key file on server',
                      ),
                      onChanged: (value) {
                        widget.certificates[index].keyFilepath = value;
                      },
                    ),
                  ],
                ],
              ),
            );
          }),
          const Gap(10),
          if (_certControllers.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Divider(),
            ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _domainController,
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.domain),
                    errorText: _domainError,
                    helperText:
                        AppLocalizations.of(context)!.generateSelfSignedCert,
                    suffixIcon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.add_box_outlined),
                            onPressed:
                                _isGenerating ? null : _generateCertificate,
                            tooltip: AppLocalizations.of(context)!
                                .generateSelfSignedCert,
                          ),
                  ),
                  enabled: !_isGenerating,
                ),
              ),
            ],
          ),
          const Gap(10),
          const TextDivider(text: 'OR'),
          const Gap(10),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _addEmptyControllers();
                });
              },
              label: Text(AppLocalizations.of(context)!.add),
            ),
          ),
          const Gap(10),
        ]);
  }
}

class _TransportSecurityReality extends StatefulWidget {
  const _TransportSecurityReality({required this.config, this.server = false});

  final RealityConfig config;
  final bool server;

  @override
  State<_TransportSecurityReality> createState() =>
      __TransportSecurityRealityState();
}

class __TransportSecurityRealityState extends State<_TransportSecurityReality> {
  final _serverNameController = TextEditingController();
  final _fingerprintController = TextEditingController();
  final _publicKeyController = TextEditingController();
  final _privateKeyController = TextEditingController();
  final _shortIdController = TextEditingController();
  final _spiderXController = TextEditingController();
  String? _serverNamesError;
  String? _shortIdError;

  // Server-only fields
  final List<TextEditingController> _shortIdsControllers = [];
  final List<TextEditingController> _serverNamesControllers = [];
  final TextEditingController _destController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _serverNameController.text = widget.config.serverName;
    _fingerprintController.text = widget.config.fingerprint;
    if (widget.config.publicKey.isNotEmpty) {
      _publicKeyController.text = base64.encode(widget.config.publicKey);
    } else {
      _publicKeyController.text = widget.config.pbk;
    }
    if (widget.config.shortId.isNotEmpty) {
      _shortIdController.text = hex.encode(widget.config.shortId);
    } else {
      _shortIdController.text = widget.config.sid;
    }
    if (widget.config.privateKey.isNotEmpty) {
      _privateKeyController.text = base64UrlEncode(widget.config.privateKey);
    }
    if (widget.config.publicKey.isNotEmpty) {
      _publicKeyController.text = base64UrlEncode(widget.config.publicKey);
    }
    _spiderXController.text = widget.config.spiderX;

    // Initialize server-only fields
    if (widget.server) {
      // Initialize shortIds
      if (widget.config.shortIds.isNotEmpty) {
        for (var shortId in widget.config.shortIds) {
          _shortIdsControllers.add(TextEditingController(
            text: shortId.isNotEmpty ? hex.encode(shortId) : '',
          ));
        }
      } else {
        // Add at least one empty controller
        widget.config.shortIds.add([]);
        _shortIdsControllers.add(TextEditingController());
      }

      // Initialize serverNames
      if (widget.config.serverNames.isNotEmpty) {
        for (var serverName in widget.config.serverNames) {
          _serverNamesControllers.add(TextEditingController(text: serverName));
        }
      } else {
        // Add at least one empty controller
        widget.config.serverNames.add('');
        _serverNamesControllers.add(TextEditingController());
      }

      // Initialize dest
      _destController.text = widget.config.dest;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _serverNameController.dispose();
    _fingerprintController.dispose();
    _publicKeyController.dispose();
    _shortIdController.dispose();
    _spiderXController.dispose();
    _privateKeyController.dispose();
    _destController.dispose();
    for (var controller in _shortIdsControllers) {
      controller.dispose();
    }
    for (var controller in _serverNamesControllers) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _serverNameController,
          decoration: InputDecoration(
            label: const Text(
              'Server Name',
            ),
            helperText: AppLocalizations.of(context)!.clientOnly,
          ),
          validator: (value) {
            if (value != null) {
              widget.config.serverName = value;
            } else {
              widget.config.serverName = '';
            }
            return null;
          },
        ),
        const Gap(10),
        TextFormField(
          controller: _fingerprintController,
          decoration: const InputDecoration(label: Text('Fingerprint')),
          validator: (value) {
            widget.config.fingerprint = _fingerprintController.text;
            return null;
          },
        ),
        const Gap(10),
        TextFormField(
          controller: _publicKeyController,
          maxLines: 2,
          decoration: const InputDecoration(
              label: Text('Public Key(base64URL)'),
              errorMaxLines: 2,
              helperMaxLines: 2),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              try {
                final normalized = base64Url.normalize(value.trim());
                widget.config.publicKey = base64Url.decode(normalized);
              } catch (e) {
                return 'Invalid base64URL format: ${e.toString()}';
              }
            } else {
              if (widget.server) return null;
              return AppLocalizations.of(context)!.empty;
            }
            return null;
          },
        ),
        const Gap(10),
        if (widget.server)
          Column(
            children: [
              TextFormField(
                controller: _privateKeyController,
                maxLines: 2,
                decoration: const InputDecoration(
                  label: Text('Private Key(base64URL)'),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    try {
                      final normalized = base64Url.normalize(value.trim());
                      widget.config.privateKey = base64Url.decode(normalized);
                    } catch (e) {
                      return 'Invalid base64URL format: ${e.toString()}';
                    }
                  } else {
                    return AppLocalizations.of(context)!.empty;
                  }
                  return null;
                },
              ),
              const Gap(2),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () async {
                      final (publicKey, privateKey) = await context
                          .read<XApiClient>()
                          .generateX25519KeyPair();
                      _publicKeyController.text = publicKey;
                      _privateKeyController.text = privateKey;
                    },
                    child: Text(AppLocalizations.of(context)!.generate)),
              ),
              const Gap(2),
            ],
          ),
        TextFormField(
          controller: _shortIdController,
          decoration: InputDecoration(
              label: const Text('Short ID(hex)'),
              helperText: AppLocalizations.of(context)!.clientOnly),
          validator: (value) {
            value = value ?? '';
            // if (value.length > 16) {
            //   return 'Invalid';
            // }
            // value = value.padRight(16, '0');
            // widget.config.shortId = hex.decode(value);
            widget.config.sid = value;
            return null;
          },
        ),
        const Gap(10),
        TextFormField(
          controller: _spiderXController,
          decoration: const InputDecoration(label: Text('SpiderX')),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (value[0] != '/') {
                return 'Invalid';
              }
              widget.config.spiderX = value;
            } else {
              widget.config.spiderX = '';
            }
            return null;
          },
        ),
        const Gap(10),
        // Server-only fields
        if (widget.server) ...[
          ExpansionTile(
            title: Text('Short IDs',
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: _shortIdError != null
                ? Text(_shortIdError!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Theme.of(context).colorScheme.error))
                : null,
            initiallyExpanded: true,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
            collapsedBackgroundColor:
                Theme.of(context).colorScheme.surfaceContainerLow,
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            onExpansionChanged: (value) {
              if (!value) {
                if (_shortIdsControllers
                        .any((controller) => controller.text.isEmpty) ||
                    _shortIdsControllers.isEmpty) {
                  setState(() {
                    _shortIdError = AppLocalizations.of(context)!.fieldRequired;
                  });
                }
              }
            },
            childrenPadding: const EdgeInsets.all(10),
            children: [
              ..._shortIdsControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            label: Text('Short ID ${index + 1}'),
                            hintText: '0',
                            helperText: 'Hex encoded',
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              try {
                                if (value.length > 16) {
                                  return 'Invalid';
                                }
                                value = value.padRight(16, '0');
                                widget.config.shortIds[index] =
                                    hex.decode(value);
                              } catch (e) {
                                return 'Invalid hex';
                              }
                            } else {
                              return AppLocalizations.of(context)!
                                  .fieldRequired;
                            }
                            return null;
                          },
                        ),
                      ),
                      if (_shortIdsControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              controller.dispose();
                              widget.config.shortIds.removeAt(index);
                              _shortIdsControllers.removeAt(index);
                            });
                          },
                          tooltip: 'Remove Short ID',
                        ),
                    ],
                  ),
                );
              }),
              IconButton.filledTonal(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    widget.config.shortIds.add([]);
                    _shortIdsControllers.add(TextEditingController());
                  });
                },
                tooltip: 'Add Short ID',
              ),
              const Gap(10),
            ],
          ),
          const Gap(10),
          if (widget.server)
            ExpansionTile(
              title: Text('Server Names',
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: _serverNamesError != null
                  ? Text(_serverNamesError!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Theme.of(context).colorScheme.error))
                  : Text('Server names for reality server',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              collapsedBackgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              initiallyExpanded: true,
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              onExpansionChanged: (value) {
                if (!value) {
                  if (_serverNamesControllers
                          .any((controller) => controller.text.isEmpty) ||
                      _serverNamesControllers.isEmpty) {
                    setState(() {
                      _serverNamesError =
                          AppLocalizations.of(context)!.fieldRequired;
                    });
                  } else {
                    setState(() {
                      _serverNamesError = null;
                    });
                  }
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              childrenPadding: const EdgeInsets.all(10),
              children: [
                ..._serverNamesControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              label: Text('Server Name ${index + 1}'),
                              helperText: 'Domain name for server',
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!isDomain(value)) {
                                  return 'Invalid';
                                }
                                widget.config.serverNames[index] = value;
                              } else {
                                return AppLocalizations.of(context)!
                                    .fieldRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_serverNamesControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                controller.dispose();
                                widget.config.serverNames.removeAt(index);
                                _serverNamesControllers.removeAt(index);
                              });
                            },
                            tooltip: 'Remove Server Name',
                          ),
                      ],
                    ),
                  );
                }),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      widget.config.serverNames.add('');
                      _serverNamesControllers.add(TextEditingController());
                    });
                  },
                  tooltip: 'Add Server Name',
                ),
                const Gap(10),
              ],
            ),
          const Gap(10),
          TextFormField(
            controller: _destController,
            decoration: const InputDecoration(
              label: Text('Destination'),
              helperText: 'Destination address (e.g., example.com:443)',
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                widget.config.dest = value;
              } else {
                return AppLocalizations.of(context)!.fieldRequired;
              }
              return null;
            },
          ),
          const Gap(10),
        ],
      ],
    );
  }
}
