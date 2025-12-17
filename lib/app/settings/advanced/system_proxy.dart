import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/main.dart';

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
    _dynamicSystemProxyPorts = persistentStateRepo.dynamicSystemProxyPorts;
    _socksPortController.text = persistentStateRepo.socksPort.toString();
    _httpPortController.text = persistentStateRepo.httpPort.toString();
    super.initState();
  }

  void _toggleDynamicSystemProxyPorts(bool value) {
    persistentStateRepo.setDynamicSystemProxyPorts(value);
    setState(() {
      _dynamicSystemProxyPorts = value;
    });
  }

  void _toggleSocksPort(String value) {
    persistentStateRepo.setSocksPort(int.parse(value));
    setState(() {
      _socksPortController.text = value;
    });
  }

  void _toggleHttpPort(String value) {
    persistentStateRepo.setHttpPort(int.parse(value));
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
              Gap(10),
              ChoiceChip(
                  label: Text(AppLocalizations.of(context)!.staticPorts),
                  selected: !_dynamicSystemProxyPorts,
                  onSelected: (_) {
                    _toggleDynamicSystemProxyPorts(false);
                  })
            ],
          ),
          Gap(10),
          if (!_dynamicSystemProxyPorts)
            Row(
              children: [
                Expanded(
                  child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'SOCKS',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _socksPortController,
                      onChanged: _toggleSocksPort),
                ),
                Gap(10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
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
