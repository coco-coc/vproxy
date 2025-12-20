import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tm/protos/protos/tun.pb.dart';
import 'package:vx/app/settings/advanced/system_proxy.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vx/app/settings/advanced/proxy_share.dart';
import 'package:vx/auth/auth_bloc.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/auto_update_service.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/widgets/circular_progress_indicator.dart';
import 'package:vx/widgets/divider.dart';
import 'package:vx/widgets/pro_promotion.dart';
import 'package:vx/xconfig_helper.dart';

class AdvancedScreen extends StatelessWidget {
  const AdvancedScreen({super.key, this.showAppBar = true});
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(AppLocalizations.of(context)!.advanced),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.only(top: 8, right: 8),
        child: ListView(
          children: [
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(AppLocalizations.of(context)!.proxyShare,
                  style: Theme.of(context).textTheme.bodyLarge),
              trailing: const Icon(Icons.keyboard_arrow_right_rounded),
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(builder: (ctx) {
                  return ProxyShareSettingScreen(
                    fullscreen: showAppBar,
                  );
                }));
              },
            ),
            const Divider(),
            const SniffSetting(),
            const Divider(),
            const FallbackSetting(),
            const Divider(),
            const Padding(
              padding:
                  EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
              child: TunIpv6Settings(),
            ),
            const Divider(),
            const SystemProxySetting(),
            const Divider(),
            const RejectQuicHysteriaSetting(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class SniffSetting extends StatefulWidget {
  const SniffSetting({super.key});

  @override
  State<SniffSetting> createState() => _SniffSettingState();
}

class _SniffSettingState extends State<SniffSetting> {
  bool _sniffing = false;

  @override
  void initState() {
    super.initState();
    _sniffing = persistentStateRepo.sniff;
  }

  void _toggleSniffing(bool value) {
    persistentStateRepo.setSniff(value);
    setState(() {
      _sniffing = value;
    });
    xController.restart();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.sniff,
                  style: Theme.of(context).textTheme.bodyLarge),
              Switch(
                value: _sniffing,
                onChanged: _toggleSniffing,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FallbackSetting extends StatefulWidget {
  const FallbackSetting({super.key});

  @override
  State<FallbackSetting> createState() => _FallbackSettingState();
}

class _FallbackSettingState extends State<FallbackSetting> {
  bool _fallbackToProxy = false;
  bool _fallbackRetryDomain = false;
  @override
  void initState() {
    super.initState();
    _fallbackToProxy = persistentStateRepo.fallbackToProxy;
    _fallbackRetryDomain = persistentStateRepo.fallbackRetryDomain;
  }

  void _toggleFallbackToProxy(bool value) {
    persistentStateRepo.setFallbackToProxy(value);
    setState(() {
      _fallbackToProxy = value;
    });
    xController.restart();
  }

  void _toggleFallbackRetryDomain(bool value) {
    persistentStateRepo.setFallbackRetryDomain(value);
    setState(() {
      _fallbackRetryDomain = value;
    });
    xController.restart();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.fallbackToProxy,
                  style: Theme.of(context).textTheme.bodyLarge),
              Switch(
                value: _fallbackToProxy,
                onChanged: _toggleFallbackToProxy,
              ),
            ],
          ),
          const Gap(5),
          Text(AppLocalizations.of(context)!.fallbackToProxySetting,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.fallbackRetryDomain,
                  style: Theme.of(context).textTheme.bodyLarge),
              Switch(
                value: _fallbackRetryDomain,
                onChanged: _toggleFallbackRetryDomain,
              ),
            ],
          ),
          const Gap(5),
          Text(AppLocalizations.of(context)!.fallbackRetryDomainDesc,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ))
        ],
      ),
    );
  }
}

class TunIpv6Settings extends StatefulWidget {
  const TunIpv6Settings({super.key});

  @override
  State<TunIpv6Settings> createState() => _TunIpv6SettingsState();
}

class _TunIpv6SettingsState extends State<TunIpv6Settings> {
  TunConfig_TUN46Setting _tun46Setting = TunConfig_TUN46Setting.DYNAMIC;

  @override
  void initState() {
    super.initState();
    _tun46Setting = persistentStateRepo.tun46Setting;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.tunIpv6Settings,
            style: Theme.of(context).textTheme.bodyLarge),
        const Gap(10),
        DropdownMenu<TunConfig_TUN46Setting>(
            initialSelection: _tun46Setting,
            requestFocusOnTap: false,
            dropdownMenuEntries: [
              DropdownMenuEntry(
                  value: TunConfig_TUN46Setting.FOUR_ONLY,
                  label: AppLocalizations.of(context)!.tun46SettingIpv4Only),
              DropdownMenuEntry(
                  value: TunConfig_TUN46Setting.BOTH,
                  label: AppLocalizations.of(context)!.tun46SettingIpv4AndIpv6),
              DropdownMenuEntry(
                  value: TunConfig_TUN46Setting.DYNAMIC,
                  label: AppLocalizations.of(context)!.dependsOnDefaultNic),
            ],
            onSelected: (value) {
              persistentStateRepo
                  .setTun46Setting(value ?? TunConfig_TUN46Setting.DYNAMIC);
              setState(() {
                _tun46Setting = value ?? TunConfig_TUN46Setting.DYNAMIC;
              });
              xController.restart();
            }),
        const Gap(10),
        if (_tun46Setting == TunConfig_TUN46Setting.DYNAMIC)
          Text(AppLocalizations.of(context)!.dependsOnDefaultNicDesc,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ))
        else if (_tun46Setting == TunConfig_TUN46Setting.FOUR_ONLY)
          Text(AppLocalizations.of(context)!.tunIpv4Desc,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ))
      ],
    );
  }
}

class RejectQuicHysteriaSetting extends StatefulWidget {
  const RejectQuicHysteriaSetting({super.key});

  @override
  State<RejectQuicHysteriaSetting> createState() =>
      _RejectQuicHysteriaSettingState();
}

class _RejectQuicHysteriaSettingState extends State<RejectQuicHysteriaSetting> {
  bool _rejectQuicHysteria = false;

  @override
  void initState() {
    super.initState();
    _rejectQuicHysteria = persistentStateRepo.rejectQuicHysteria;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppLocalizations.of(context)!.hysteriaRejectQuic,
              style: Theme.of(context).textTheme.bodyLarge),
          const Gap(10),
          Switch(
            value: _rejectQuicHysteria,
            onChanged: (value) {
              persistentStateRepo.setRejectQuicHysteria(value);
              setState(() {
                _rejectQuicHysteria = value;
              });
              xController.restart();
            },
          ),
        ],
      ),
    );
  }
}
