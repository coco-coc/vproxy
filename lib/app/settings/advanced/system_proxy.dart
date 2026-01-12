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

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/pref_helper.dart';

class SystemProxySetting extends StatefulWidget {
  const SystemProxySetting({super.key});

  @override
  State<SystemProxySetting> createState() => _SystemProxySettingState();
}

class _SystemProxySettingState extends State<SystemProxySetting> {
  bool _dynamicSystemProxyPorts = false;
  final _socksPortController = TextEditingController();
  final _httpPortController = TextEditingController();
  @override
  void initState() {
    final pref = context.read<SharedPreferences>();
    _dynamicSystemProxyPorts = pref.dynamicSystemProxyPorts;
    _socksPortController.text = pref.socksPort.toString();
    _httpPortController.text = pref.httpPort.toString();
    super.initState();
  }

  void _toggleDynamicSystemProxyPorts(bool value) {
    context.read<SharedPreferences>().setDynamicSystemProxyPorts(value);
    setState(() {
      _dynamicSystemProxyPorts = value;
    });
  }

  void _toggleSocksPort(String value) {
    context.read<SharedPreferences>().setSocksPort(int.parse(value));
    setState(() {
      _socksPortController.text = value;
    });
  }

  void _toggleHttpPort(String value) {
    context.read<SharedPreferences>().setHttpPort(int.parse(value));
    setState(() {
      _httpPortController.text = value;
    });
  }

  @override
  void dispose() {
    _socksPortController.dispose();
    _httpPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.systemProxyPortSetting,
              style: Theme.of(context).textTheme.bodyLarge),
          const Gap(10),
          Row(
            children: [
              ChoiceChip(
                  label: Text(AppLocalizations.of(context)!.randomPorts),
                  selected: _dynamicSystemProxyPorts,
                  onSelected: (_) {
                    _toggleDynamicSystemProxyPorts(true);
                  }),
              const Gap(10),
              ChoiceChip(
                  label: Text(AppLocalizations.of(context)!.staticPorts),
                  selected: !_dynamicSystemProxyPorts,
                  onSelected: (_) {
                    _toggleDynamicSystemProxyPorts(false);
                  })
            ],
          ),
          const Gap(10),
          if (!_dynamicSystemProxyPorts)
            Row(
              children: [
                Expanded(
                  child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'SOCKS',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _socksPortController,
                      onChanged: _toggleSocksPort),
                ),
                const Gap(10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'HTTP',
                    ),
                    keyboardType: TextInputType.number,
                    controller: _httpPortController,
                    onChanged: _toggleHttpPort,
                  ),
                )
              ],
            )
        ],
      ),
    );
  }
}
