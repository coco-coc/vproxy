// import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:vx/data/database_provider.dart';
import 'package:vx/data/sync.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:vx/common/net.dart';
import 'package:vx/data/database.dart';
import 'package:vx/data/ssh_server.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/geoip.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/utils/random.dart';

class AddEditServerDialog extends StatefulWidget {
  const AddEditServerDialog({super.key, this.server, this.fullScreen = false});
  final SshServer? server;
  final bool fullScreen;
  @override
  State<AddEditServerDialog> createState() => _AddEditServerDialogState();
}

enum AuthMethod {
  password,
  sshKey;

  String localize(BuildContext context) {
    switch (this) {
      case AuthMethod.password:
        return AppLocalizations.of(context)!.password;
      case AuthMethod.sshKey:
        return AppLocalizations.of(context)!.sshKey;
    }
  }
}

class _AddEditServerDialogState extends State<AddEditServerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serverAddressController = TextEditingController();
  final _portController = TextEditingController();
  late AuthMethod _authMethod;
  final _userController = TextEditingController();
  final _sudoPasswordController = TextEditingController();
  bool _loading = true;
  SshServerSecureStorage _serverSecureStorage = SshServerSecureStorage();
  final _serverPubKeyController = TextEditingController();
  late final FlutterSecureStorage storage;

  @override
  void initState() {
    super.initState();
    storage = context.read<FlutterSecureStorage>();
    _nameController.text = widget.server?.name ?? '';
    _serverAddressController.text = widget.server?.address ?? '';
    _authMethod = widget.server?.authMethod ?? AuthMethod.password;
    if (widget.server == null) {
      _loading = false;
    } else {
      Future(() async {
        final jsonString = await storage.read(key: widget.server!.storageKey);
        if (jsonString == null) {
          setState(() {
            _loading = false;
          });
          logger.d('Server not found: ${widget.server!.storageKey}');
          return;
        }
        final map = jsonDecode(jsonString);
        _serverSecureStorage = SshServerSecureStorage.fromJson(map);
        _portController.text = _serverSecureStorage.port.toString();
        _userController.text = _serverSecureStorage.user;
        _serverPubKeyController.text = _serverSecureStorage.pubKey ?? '';
        _sudoPasswordController.text = _serverSecureStorage.password ?? '';
        setState(() {
          _loading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serverAddressController.dispose();
    _portController.dispose();
    _sudoPasswordController.dispose();
    _userController.dispose();
    _serverPubKeyController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) async {
    final syncService = context.read<SyncService>();
    bool? allGood = _formKey.currentState?.validate();
    final database = context.read<DatabaseProvider>().database;

    if ((_authMethod == AuthMethod.sshKey) &&
        _serverSecureStorage.sshKey == null &&
        _serverSecureStorage.sshKeyPath == null &&
        _serverSecureStorage.globalSshKeyName == null) {
      allGood = false;
    }
    if (allGood == true) {
      try {
        late int id;
        if (widget.server == null) {
          final storageKey =
              'server_${_nameController.text}_${Random().nextInt(1000000)}';
          await storage.write(
              key: storageKey,
              value: jsonEncode(_serverSecureStorage.toJson()));
          final server = await database
              .into(database.sshServers)
              .insertReturning(SshServersCompanion(
                id: Value(SnowflakeId.generate()),
                name: Value(_nameController.text),
                address: Value(_serverAddressController.text),
                storageKey: Value(storageKey),
                authMethod: Value(_authMethod),
              ));
          id = server.id;
          syncService.addServerOperation(
              server, _serverSecureStorage, storageKey);
        } else {
          id = widget.server!.id;
          // if a user changes the address, delete the existing pubkey
          if (widget.server!.address != _serverAddressController.text) {
            _serverSecureStorage.pubKey = null;
          }
          await storage.write(
              key: widget.server!.storageKey,
              value: jsonEncode(_serverSecureStorage.toJson()));
          final server = (await (database.update(database.sshServers)
                    ..where((f) => f.id.equals(id)))
                  .writeReturning(SshServersCompanion(
            name: Value(_nameController.text),
            address: Value(_serverAddressController.text),
            authMethod: Value(_authMethod),
            updatedAt: Value(DateTime.now()),
          )))
              .single;
          syncService.updateServerOperation(
              server, _serverSecureStorage, widget.server!.storageKey);
        }
        getCountryCode(_serverAddressController.text).then((value) {
          (database.update(database.sshServers)..where((t) => t.id.equals(id)))
              .write(SshServersCompanion(
            country: Value(value),
          ));
        });
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      } catch (e) {
        logger.d('save server error', error: e);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _loading
        ? const Center(child: CircularProgressIndicator())
        : Theme(
            data: Theme.of(context).copyWith(
                inputDecorationTheme:
                    const InputDecorationTheme(border: OutlineInputBorder())),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Gap(10),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.name,
                    ),
                  ),
                  const Gap(10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _serverAddressController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .fieldRequired;
                            }
                            if (!isValidIp(value) && !isDomain(value)) {
                              return AppLocalizations.of(context)!
                                  .invalidAddress;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.address,
                          ),
                        ),
                      ),
                      const Gap(10),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _portController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .fieldRequired;
                            }
                            if (!isValidPort(value)) {
                              return AppLocalizations.of(context)!.invalidPort;
                            }
                            _serverSecureStorage.port = int.parse(value);
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.port,
                          ),
                        ),
                      )
                    ],
                  ),
                  const Gap(10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _userController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .fieldRequired;
                            }
                            _serverSecureStorage.user = value;
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'User',
                          ),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: TextFormField(
                          controller: _sudoPasswordController,
                          validator: (value) {
                            if (_authMethod == AuthMethod.password &&
                                _sudoPasswordController.text.isEmpty) {
                              return '若无SSH密钥，此项为必填项';
                            }
                            _serverSecureStorage.password = value;
                            return null;
                          },
                          decoration: InputDecoration(
                              helperStyle: const TextStyle(fontSize: 10),
                              labelText: AppLocalizations.of(context)!.password,
                              errorMaxLines: 2),
                        ),
                      )
                    ],
                  ),
                  const Gap(10),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.useSshKey),
                      const Gap(10),
                      Switch(
                          value: _authMethod == AuthMethod.sshKey,
                          onChanged: (value) {
                            setState(() {
                              _authMethod = value
                                  ? AuthMethod.sshKey
                                  : AuthMethod.password;
                              if (_authMethod == AuthMethod.password) {
                                _serverSecureStorage.globalSshKeyName = null;
                                _serverSecureStorage.sshKey = null;
                                _serverSecureStorage.sshKeyPath = null;
                                _serverSecureStorage.passphrase = null;
                              }
                            });
                          })
                    ],
                  ),
                  const Gap(10),
                  // if (_authMethod == AuthMethod.password)
                  //   TextFormField(
                  //     controller: _authPasswordController,
                  //     obscureText: true,
                  //     validator: (value) {
                  //       if (value == null || value.isEmpty) {
                  //         return AppLocalizations.of(context)!.fieldRequired;
                  //       }
                  //       _server.sshPassword = value;
                  //       return null;
                  //     },
                  //     decoration: InputDecoration(
                  //       labelText: AppLocalizations.of(context)!.password,
                  //     ),
                  //   ),
                  if (_authMethod == AuthMethod.sshKey)
                    SshKeyCredentialGetter(sshServerJ: _serverSecureStorage),
                  const Gap(10),
                  TextFormField(
                    controller: _serverPubKeyController,
                    maxLines: 5,
                    validator: (value) {
                      _serverSecureStorage.pubKey = value;
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.serverPubKey,
                        helperText:
                            AppLocalizations.of(context)!.serverPubKeyHelper,
                        hintText: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQD...',
                        helperMaxLines: 10),
                  ),
                ],
              ),
            ),
          );
    if (widget.fullScreen) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
                onPressed: () => _save(context),
                child: Text(AppLocalizations.of(context)!.save))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(child: child),
        ),
      );
    }
    return AlertDialog(
      scrollable: true,
      title: Text(widget.server == null
          ? AppLocalizations.of(context)!.addServer
          : AppLocalizations.of(context)!.editServer),
      content: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 350, maxWidth: 350),
          child: child),
      actions: [
        OutlinedButton(
            style: FilledButton.styleFrom(
                fixedSize: const Size(100, 40), elevation: 1),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(
            style: FilledButton.styleFrom(
                fixedSize: const Size(100, 40), elevation: 1),
            onPressed: () => _save(context),
            child: Text(AppLocalizations.of(context)!.save))
      ],
    );
  }
}

class SshKeyCredentialGetter extends StatefulWidget {
  const SshKeyCredentialGetter({super.key, required this.sshServerJ});
  final SshServerSecureStorage sshServerJ;

  @override
  State<SshKeyCredentialGetter> createState() => _SshKeyCredentialGetterState();
}

enum HowToGetSshKey {
  content,
  // file,
  global;

  String localize(BuildContext context) {
    switch (this) {
      case HowToGetSshKey.content:
        return AppLocalizations.of(context)!.addCommonSshKey;
      // case HowToGetSshKey.file:
      //   return AppLocalizations.of(context)!.sshKeyPath;
      case HowToGetSshKey.global:
        return AppLocalizations.of(context)!.useCommonSshKey;
    }
  }
}

class _SshKeyCredentialGetterState extends State<SshKeyCredentialGetter> {
  final _sshKeyController = TextEditingController();
  // final _sshKeyPathController = TextEditingController();
  final _passphraseController = TextEditingController();
  late HowToGetSshKey _how;
  List<CommonSshKey> _commonSshKeys = [];

  @override
  void initState() {
    super.initState();
    Future(() async {
      final database = context.read<DatabaseProvider>().database;
      _commonSshKeys = await database.select(database.commonSshKeys).get();
      setState(() {});
    });
    _passphraseController.text = widget.sshServerJ.passphrase ?? '';
    _sshKeyController.text = widget.sshServerJ.sshKey ?? '';
    // _sshKeyPathController.text = widget.sshServerJ.sshKeyPath ?? '';
    if (widget.sshServerJ.sshKey != null &&
        widget.sshServerJ.sshKey!.isNotEmpty) {
      _how = HowToGetSshKey.content;
    } else if (widget.sshServerJ.sshKeyPath != null &&
        widget.sshServerJ.sshKeyPath!.isNotEmpty) {
      // _how = HowToGetSshKey.file;
    } else if (widget.sshServerJ.globalSshKeyName != null &&
        widget.sshServerJ.globalSshKeyName!.isNotEmpty) {
      _how = HowToGetSshKey.global;
    } else {
      _how = HowToGetSshKey.content;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SegmentedButton<HowToGetSshKey>(
                  segments: [
                    ButtonSegment(
                      value: HowToGetSshKey.content,
                      label: Text(HowToGetSshKey.content.localize(context)),
                    ),
                    ButtonSegment(
                        value: HowToGetSshKey.global,
                        label: Text(HowToGetSshKey.global.localize(context)))
                  ],
                  selected: {
                    _how
                  },
                  onSelectionChanged: (Set<HowToGetSshKey> set) => setState(() {
                        _how = set.first;
                        if (_how == HowToGetSshKey.content) {
                          // _sshKeyPathController.text = '';
                          widget.sshServerJ.globalSshKeyName = null;
                        }
                        // else if (_how == HowToGetSshKey.file) {
                        //   _sshKeyController.text = '';
                        //   widget.sshServerJ.globalSshKeyName = null;
                        // }
                        else {
                          _sshKeyController.text = '';
                          _passphraseController.text = '';
                          widget.sshServerJ.sshKey = null;
                          widget.sshServerJ.sshKeyPath = null;
                          widget.sshServerJ.passphrase = null;
                          // _sshKeyPathController.text = '';
                        }
                      }))),
        ),
        if (_how == HowToGetSshKey.content)
          TextFormField(
            controller: _sshKeyController,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.fieldRequired;
              }
              widget.sshServerJ.sshKey = value;
              return null;
            },
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.sshKey,
            ),
          ),
        // if (_how == HowToGetSshKey.file)
        //   TextFormField(
        //     controller: _sshKeyPathController,
        //     decoration: InputDecoration(
        //       labelText: AppLocalizations.of(context)!.sshKeyPath,
        //     ),
        //     validator: (value) {
        //       if (value == null || value.isEmpty) {
        //         return AppLocalizations.of(context)!.fieldRequired;
        //       }
        //       widget.sshServerJ.sshKeyPath = value;
        //       return null;
        //     },
        //   ),
        if (_how == HowToGetSshKey.content)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                      type: FileType.any,
                      // allowedExtensions: ['pem', 'key', 'txt'],
                      withData: true);
                  if (result != null && result.files.single.bytes != null) {
                    _sshKeyController.text =
                        utf8.decode(result.files.single.bytes!);
                  }
                },
                icon: const Icon(Icons.folder),
                label: Text(AppLocalizations.of(context)!.selectFromFile)),
          ),
        if (_how == HowToGetSshKey.content)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextFormField(
              controller: _passphraseController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.keyPassphrase,
              ),
              validator: (value) {
                widget.sshServerJ.passphrase = value;
                return null;
              },
            ),
          ),
        if (_how == HowToGetSshKey.global)
          DropdownMenu<CommonSshKey>(
            width: 200,
            initialSelection: _commonSshKeys.indexWhere(
                        (e) => e.name == widget.sshServerJ.globalSshKeyName) !=
                    -1
                ? _commonSshKeys[_commonSshKeys.indexWhere(
                    (e) => e.name == widget.sshServerJ.globalSshKeyName)]
                : null,
            requestFocusOnTap: false,
            dropdownMenuEntries: _commonSshKeys
                .map<DropdownMenuEntry<CommonSshKey>>(
                  (e) => DropdownMenuEntry<CommonSshKey>(
                    label: e.name,
                    value: e,
                  ),
                )
                .toList(),
            onSelected: (value) {
              setState(() {
                widget.sshServerJ.globalSshKeyName = value?.name;
              });
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    _sshKeyController.dispose();
    // _sshKeyPathController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }
}
