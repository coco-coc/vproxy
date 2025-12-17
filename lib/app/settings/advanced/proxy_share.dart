import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vx/common/net.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/main.dart';

class ProxyShareSettingScreen extends StatefulWidget {
  const ProxyShareSettingScreen({super.key, this.fullscreen = true});
  final bool fullscreen;

  @override
  State<ProxyShareSettingScreen> createState() =>
      _ProxyShareSettingScreenState();
}

class _ProxyShareSettingScreenState extends State<ProxyShareSettingScreen> {
  final _listenAddressController = TextEditingController();
  final _listenPortController = TextEditingController();
  final _socksUdpAccocisate = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _proxyShare = false;
  @override
  void initState() {
    _proxyShare = persistentStateRepo.proxyShare;
    // TODO: implement initState
    _listenAddressController.text = persistentStateRepo.proxyShareListenAddress;
    _listenPortController.text =
        persistentStateRepo.proxyShareListenPort.toString();
    super.initState();
  }

  @override
  void dispose() {
    _listenAddressController.dispose();
    _listenPortController.dispose();
    _socksUdpAccocisate.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      persistentStateRepo.setProxyShare(_proxyShare);
      persistentStateRepo
          .setProxyShareListenAddress(_listenAddressController.text);
      persistentStateRepo
          .setProxyShareListenPort(int.parse(_listenPortController.text));
      persistentStateRepo.setSocksUdpaccociateAddress(_socksUdpAccocisate.text);
      // notify xController
      xController.onSystemProxyChange();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.proxyShare),
        actions: [
          if (widget.fullscreen)
            TextButton(
              onPressed: _save,
              child: Text(AppLocalizations.of(context)!.save),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.proxyShare,
                            style: Theme.of(context).textTheme.titleMedium),
                        Switch(
                            value: _proxyShare,
                            onChanged: (value) {
                              setState(() {
                                _proxyShare = value;
                              });
                            }),
                      ],
                    ),
                    const Gap(10),
                    Text(AppLocalizations.of(context)!.proxyShareDesc,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ))
                  ],
                ),
              ),
              if (_proxyShare)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    maxLines: 1,
                    controller: _listenAddressController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.invalidAddress;
                      }
                      if (isValidIp(value)) {
                        return null;
                      }
                      return AppLocalizations.of(context)!.invalidIp;
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.address,
                      hintText: '0.0.0.0',
                    ),
                  ),
                ),
              if (_proxyShare)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    maxLines: 1,
                    controller: _listenPortController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.invalidPort;
                      }
                      if (Platform.isIOS && value == '1080') {
                        return AppLocalizations.of(context)!.doNotUse1080IOS;
                      }
                      if (isValidPort(value)) {
                        return null;
                      }
                      return AppLocalizations.of(context)!.invalidPort;
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.port,
                      hintText: '1080',
                    ),
                  ),
                ),
              if (_proxyShare)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: TextFormField(
                    maxLines: 1,
                    controller: _socksUdpAccocisate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      if (isValidIp(value)) {
                        return null;
                      }
                      return AppLocalizations.of(context)!.invalidIp;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Socks UDP Associate BND.ADDR',
                    ),
                  ),
                ),
              if (!widget.fullscreen)
                FilledButton(
                  onPressed: _save,
                  child: Text(AppLocalizations.of(context)!.save),
                )
            ],
          ),
        ),
      ),
    );
  }
}
