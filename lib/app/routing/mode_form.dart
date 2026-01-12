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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:tm/protos/common/geo/geo.pb.dart';
import 'package:tm/protos/common/net/net.pb.dart';
import 'package:tm/protos/protos/dns.pb.dart';
import 'package:tm/protos/protos/outbound.pb.dart';
import 'package:tm/protos/protos/router.pb.dart';
import 'package:vx/app/log/log_page.dart';
import 'package:vx/app/outbound/outbound_repo.dart';
import 'package:vx/app/routing/add_dialog.dart';
import 'package:vx/app/routing/mode_widget.dart';
import 'package:vx/app/routing/routing_page.dart';
import 'package:vx/common/config.dart';
import 'package:vx/common/net.dart';
import 'package:vx/data/database.dart';
import 'package:vx/data/database_provider.dart';
import 'package:vx/widgets/form_dialog.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/widgets/text_divider.dart';

enum OutboundType {
  node,
  selector,
  block,
}

final directHandler = OutboundHandler(
    id: -1,
    config:
        HandlerConfig(outbound: OutboundHandlerConfig(tag: directHandlerTag)));

final proxySelector =
    HandlerSelector(name: defaultProxySelectorTag, config: SelectorConfig());

class RouteRuleForm extends StatefulWidget {
  const RouteRuleForm({super.key, this.ruleConfig});
  final RuleConfig? ruleConfig;

  @override
  State<RouteRuleForm> createState() => _RouteRuleFormState();
}

enum Condition {
  fake,
  network,
  inbound,
  domain,
  ip,
  app,
  all;
}

class _RouteRuleFormState extends State<RouteRuleForm> with FormDataGetter {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ruleConfig = RuleConfig();
  final List<bool> _isExpanded = List.filled(5, false);
  final Map<Condition, bool> _nontrivial =
      Map.fromEntries(Condition.values.map((e) => MapEntry(e, false)));
  OutboundType _outboundType = OutboundType.node;

  List<OutboundHandler>? _outboundHandlers;
  OutboundHandler? _selectedOutboundHandler;
  String? nodeSelectError;

  List<HandlerSelector>? _selectors;
  HandlerSelector? _selectedSelector;
  String? selectorSelectError;

  @override
  Object? get formData {
    if (_formKey.currentState?.validate() ?? false) {
      if (_outboundType == OutboundType.node) {
        _ruleConfig.selectorTag = '';
        if (_selectedOutboundHandler == directHandler) {
          _ruleConfig.outboundTag = directHandlerTag;
        } else if (_selectedOutboundHandler == null) {
          setState(() {
            nodeSelectError =
                AppLocalizations.of(context)!.selectAtleastOneNode;
          });
          return null;
        } else {
          _ruleConfig.outboundTag = _selectedOutboundHandler!.id.toString();
        }
      } else if (_outboundType == OutboundType.block) {
        _ruleConfig.outboundTag = '';
        _ruleConfig.selectorTag = '';
      } else if (_outboundType == OutboundType.selector) {
        _ruleConfig.outboundTag = '';
        if (_selectedSelector == null) {
          setState(() {
            selectorSelectError =
                AppLocalizations.of(context)!.selectAtleastOneSelector;
          });
          return null;
        } else if (_selectedSelector == proxySelector) {
          _ruleConfig.selectorTag = defaultProxySelectorTag;
        } else {
          _ruleConfig.selectorTag = _selectedSelector!.name;
        }
      }
      _ruleConfig.ruleName = _nameController.text;
      return _ruleConfig;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.ruleConfig != null) {
      _nameController.text = widget.ruleConfig!.ruleName;
      _ruleConfig.mergeFromMessage(widget.ruleConfig!);
      if (_ruleConfig.selectorTag.isNotEmpty) {
        _outboundType = OutboundType.selector;
        if (_ruleConfig.selectorTag == defaultProxySelectorTag) {
          _selectedSelector = proxySelector;
        }
      }
      if (_ruleConfig.outboundTag == directHandlerTag) {
        _selectedOutboundHandler = directHandler;
      }
      if (_ruleConfig.outboundTag.isEmpty && _ruleConfig.selectorTag.isEmpty) {
        _outboundType = OutboundType.block;
      }
    }
    _updateNontrivial();
    context.read<OutboundRepo>().getAllHandlers().then((l) {
      _outboundHandlers = l;
      if (_outboundType == OutboundType.node) {
        setState(() {
          _selectedOutboundHandler ??= l
              .where((e) => e.id.toString() == _ruleConfig.outboundTag)
              .firstOrNull;
        });
      }
    });
    context
        .read<DatabaseProvider>()
        .database
        .managers
        .handlerSelectors
        .get()
        .then((l) {
      _selectors = l;
      if (_outboundType == OutboundType.selector) {
        setState(() {
          _selectedSelector ??=
              l.where((e) => e.name == _ruleConfig.selectorTag).firstOrNull;
        });
      }
    });
  }

  void _updateNontrivial() {
    _nontrivial[Condition.inbound] = _ruleConfig.inboundTags.isNotEmpty ||
        _ruleConfig.inboundTags.isNotEmpty;
    _nontrivial[Condition.domain] =
        _ruleConfig.geoDomains.isNotEmpty || _ruleConfig.domainTags.isNotEmpty;
    _nontrivial[Condition.ip] =
        _ruleConfig.dstCidrs.isNotEmpty || _ruleConfig.dstIpTags.isNotEmpty;
    _nontrivial[Condition.app] =
        _ruleConfig.appIds.isNotEmpty || _ruleConfig.appTags.isNotEmpty;
    _nontrivial[Condition.fake] = _ruleConfig.fakeIp;
    _nontrivial[Condition.all] = _ruleConfig.allTags.isNotEmpty;
    _nontrivial[Condition.network] = _ruleConfig.networks.isNotEmpty;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterRuleName;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.ruleName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const Gap(10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ChoiceChip(
                          label: Text(AppLocalizations.of(context)!.node),
                          selected: _outboundType == OutboundType.node,
                          onSelected: (value) {
                            if (value) {
                              setState(() {
                                _outboundType = OutboundType.node;
                              });
                            }
                          }),
                      const Gap(5),
                      ChoiceChip(
                          label: Text(AppLocalizations.of(context)!.selector),
                          selected: _outboundType == OutboundType.selector,
                          onSelected: (value) {
                            if (value) {
                              setState(() {
                                _outboundType = OutboundType.selector;
                              });
                            }
                          }),
                      const Gap(5),
                      ChoiceChip(
                          label: Text(AppLocalizations.of(context)!.block),
                          selected: _outboundType == OutboundType.block,
                          onSelected: (value) {
                            if (value) {
                              setState(() {
                                _outboundType = OutboundType.block;
                              });
                            }
                          }),
                    ],
                  ),
                  const Gap(10),
                  if (_outboundType == OutboundType.node)
                    DropdownMenu<OutboundHandler>(
                      label: Text(AppLocalizations.of(context)!.node),
                      initialSelection: _selectedOutboundHandler,
                      onSelected: (value) {
                        setState(() {
                          nodeSelectError = null;
                          _selectedOutboundHandler = value;
                        });
                      },
                      errorText: nodeSelectError,
                      dropdownMenuEntries: [
                        DropdownMenuEntry(
                            label: AppLocalizations.of(context)!.direct,
                            value: directHandler),
                        ..._outboundHandlers
                                ?.map((e) =>
                                    DropdownMenuEntry(label: e.name, value: e))
                                .toList() ??
                            [],
                      ],
                    ),
                  if (_outboundType == OutboundType.selector)
                    DropdownMenu<HandlerSelector>(
                      label: Text(AppLocalizations.of(context)!.selector),
                      initialSelection: _selectedSelector,
                      onSelected: (value) {
                        setState(() {
                          selectorSelectError = null;
                          _selectedSelector = value;
                        });
                      },
                      errorText: selectorSelectError,
                      dropdownMenuEntries: [
                        DropdownMenuEntry(
                            label: AppLocalizations.of(context)!
                                .defaultSelectorTag,
                            value: proxySelector),
                        ..._selectors
                                ?.where((e) => e.name != proxySelector.name)
                                .map((e) =>
                                    DropdownMenuEntry(label: e.name, value: e))
                                .toList() ??
                            [],
                      ],
                    ),
                ],
              ),
              const Gap(5),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.matchAll),
                  const Gap(5),
                  Switch(
                      value: _ruleConfig.matchAll,
                      onChanged: (value) {
                        setState(() {
                          _ruleConfig.matchAll = value;
                          if (_ruleConfig.matchAll) {
                            _ruleConfig.clear();
                            _ruleConfig.matchAll = true;
                            _updateNontrivial();
                          }
                        });
                      }),
                ],
              ),
              const Gap(10),
              if (!_ruleConfig.matchAll)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextDivider(text: AppLocalizations.of(context)!.condition),
                    const Gap(5),
                    Text(AppLocalizations.of(context)!.ruleMatchCondition,
                        style:
                            Theme.of(context).textTheme.labelMedium!.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                )),
                    const Gap(5),
                    Text(
                        AppLocalizations.of(context)!.enabledConditions(
                            _nontrivial.values.where((e) => e).length),
                        style:
                            Theme.of(context).textTheme.labelMedium!.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                )),
                    if (_nontrivial[Condition.domain]! &&
                        _nontrivial[Condition.ip]!)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                            AppLocalizations.of(context)!.conditaionWarn1,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  color: Colors.deepOrange,
                                )),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Row(
                        children: [
                          const Text('Fake IP'),
                          const Gap(3),
                          Checkbox(
                              value: _ruleConfig.fakeIp,
                              onChanged: (value) {
                                setState(() {
                                  _ruleConfig.fakeIp = value ?? false;
                                  _nontrivial[Condition.fake] = value ?? false;
                                });
                              }),
                        ],
                      ),
                    ),
                    const Gap(5),
                    Row(
                      children: [
                        const Text('Network'),
                        const Gap(10),
                        FilterChip(
                            label: const Text('TCP'),
                            selected:
                                _ruleConfig.networks.contains(Network.TCP),
                            onSelected: (value) {
                              setState(() {
                                value
                                    ? _ruleConfig.networks.add(Network.TCP)
                                    : _ruleConfig.networks.remove(Network.TCP);
                                _nontrivial[Condition.network] =
                                    _ruleConfig.networks.isNotEmpty;
                              });
                            }),
                        const Gap(10),
                        FilterChip(
                            label: const Text('UDP'),
                            selected:
                                _ruleConfig.networks.contains(Network.UDP),
                            onSelected: (value) {
                              setState(() {
                                value
                                    ? _ruleConfig.networks.add(Network.UDP)
                                    : _ruleConfig.networks.remove(Network.UDP);
                                _nontrivial[Condition.network] =
                                    _ruleConfig.networks.isNotEmpty;
                              });
                            }),
                      ],
                    ),
                    const Gap(10),
                    Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ExpansionPanelList(
                        expansionCallback: (panelIndex, isExpanded) {
                          setState(() {
                            _isExpanded[panelIndex] = !_isExpanded[panelIndex];
                          });
                        },
                        elevation: 0,
                        materialGapSize: 1,
                        expandedHeaderPadding: const EdgeInsets.all(0),
                        children: [
                          ExpansionPanel(
                              canTapOnHeader: true,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                              headerBuilder: (context, isExpanded) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                        AppLocalizations.of(context)!.inbound,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              color: _nontrivial[
                                                          Condition.inbound] ??
                                                      false
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : null,
                                            )),
                                  ),
                                );
                              },
                              isExpanded: _isExpanded[0],
                              body: InboundCondition(
                                  rule: _ruleConfig,
                                  onChanged: _updateNontrivial)),
                          ExpansionPanel(
                              canTapOnHeader: true,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                              headerBuilder: (context, isExpanded) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                        AppLocalizations.of(context)!.domain,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              color:
                                                  _nontrivial[Condition.domain]!
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : null,
                                            )),
                                  ),
                                );
                              },
                              isExpanded: _isExpanded[1],
                              body: DomainCondition(
                                  rule: _ruleConfig,
                                  onChanged: _updateNontrivial)),
                          ExpansionPanel(
                              canTapOnHeader: true,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                              headerBuilder: (context, isExpanded) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text('IP',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              color: _nontrivial[Condition.ip]!
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : null,
                                            )),
                                  ),
                                );
                              },
                              isExpanded: _isExpanded[2],
                              body: IPCondition(
                                  rule: _ruleConfig,
                                  onChanged: _updateNontrivial)),
                          ExpansionPanel(
                              canTapOnHeader: true,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                              headerBuilder: (context, isExpanded) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                        AppLocalizations.of(context)!.app,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              color: _nontrivial[Condition.app]!
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : null,
                                            )),
                                  ),
                                );
                              },
                              isExpanded: _isExpanded[3],
                              body: AppCondition(
                                  rule: _ruleConfig,
                                  onChanged: _updateNontrivial)),
                          ExpansionPanel(
                              canTapOnHeader: true,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                              headerBuilder: (context, isExpanded) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                        '${AppLocalizations.of(context)!.domain}/IP/${AppLocalizations.of(context)!.app}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              color: _nontrivial[Condition.all]!
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : null,
                                            )),
                                  ),
                                );
                              },
                              isExpanded: _isExpanded[4],
                              body: AllCondition(
                                  rule: _ruleConfig,
                                  onChanged: _updateNontrivial)),
                        ],
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}

class DnsRuleForm extends StatefulWidget {
  const DnsRuleForm({super.key, this.ruleConfig});
  final DnsRuleConfig? ruleConfig;

  @override
  State<DnsRuleForm> createState() => _DnsRuleFormState();
}

class _DnsRuleFormState extends State<DnsRuleForm> with FormDataGetter {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ruleConfig = DnsRuleConfig();
  final List<bool> _isExpanded = List.filled(1, false);
  final List<bool> _nontrivial = List.filled(2, false);

  List<DnsServer> _dnsServers = [/* ...defaultDnsServers */];
  DnsServer? _selectedDnsServer;
  String? dnsServerSelectError;

  @override
  Object? get formData {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDnsServer == null) {
        setState(() {
          dnsServerSelectError =
              AppLocalizations.of(context)!.selectAtleastOneDnsServer;
        });
        return null;
      }
      _ruleConfig.dnsServerName = _selectedDnsServer!.name;
      _ruleConfig.ruleName = _nameController.text;
      return _ruleConfig;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.ruleConfig != null) {
      _nameController.text = widget.ruleConfig!.ruleName;
      _ruleConfig.mergeFromMessage(widget.ruleConfig!);
      _selectedDnsServer = _dnsServers
          .where((e) => e.name == _ruleConfig.dnsServerName)
          .firstOrNull;
    }
    _updateNontrivial();
    context
        .read<DatabaseProvider>()
        .database
        .managers
        .dnsServers
        .get()
        .then((l) {
      _dnsServers = [/* ...defaultDnsServers */ ...l];
      setState(() {
        _selectedDnsServer ??=
            l.where((e) => e.name == _ruleConfig.dnsServerName).firstOrNull;
      });
    });
  }

  void _updateNontrivial() {
    _nontrivial[0] = _ruleConfig.includedTypes.isNotEmpty;
    _nontrivial[1] =
        _ruleConfig.domains.isNotEmpty || _ruleConfig.domainTags.isNotEmpty;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterRuleName;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.ruleName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const Gap(10),
              DropdownMenu<DnsServer>(
                label: Text(AppLocalizations.of(context)!.dnsServer),
                initialSelection: _selectedDnsServer,
                requestFocusOnTap: false,
                width: 180,
                onSelected: (value) {
                  setState(() {
                    dnsServerSelectError = null;
                    _selectedDnsServer = value;
                  });
                },
                errorText: dnsServerSelectError,
                dropdownMenuEntries: _dnsServers
                    .map((e) => DropdownMenuEntry(label: e.name, value: e))
                    .toList(),
              ),
              const Gap(5),
              Column(
                children: [
                  TextDivider(text: AppLocalizations.of(context)!.condition),
                  const Gap(5),
                  Text(
                      '${AppLocalizations.of(context)!.howDnsRuleMatch} ${AppLocalizations.of(context)!.enabledConditions(_nontrivial.where((e) => e).length)}',
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                  const Gap(10),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: DnsIncludedTypeCondition(
                          dnsRule: _ruleConfig, onChanged: _updateNontrivial)),
                  const Gap(10),
                  Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ExpansionPanelList(
                      expansionCallback: (panelIndex, isExpanded) {
                        setState(() {
                          _isExpanded[panelIndex] = !_isExpanded[panelIndex];
                        });
                      },
                      elevation: 0,
                      materialGapSize: 1,
                      expandedHeaderPadding: const EdgeInsets.all(0),
                      children: [
                        ExpansionPanel(
                            canTapOnHeader: true,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                            headerBuilder: (context, isExpanded) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                      AppLocalizations.of(context)!.domain,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            color: _nontrivial[1]
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : null,
                                          )),
                                ),
                              );
                            },
                            isExpanded: _isExpanded[0],
                            body: DomainCondition(
                                dnsRule: _ruleConfig,
                                onChanged: _updateNontrivial)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DnsIncludedTypeCondition extends StatelessWidget {
  const DnsIncludedTypeCondition(
      {super.key, required this.dnsRule, required this.onChanged});
  final DnsRuleConfig dnsRule;
  final Function() onChanged;
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: DnsType.values
          .map((e) => StatefulBuilder(builder: (ctx, setState) {
                return MenuItemButton(
                  leadingIcon: Checkbox(
                      value: dnsRule.includedTypes.contains(e),
                      onChanged: (value) async {
                        setState(() {
                          if (value ?? false) {
                            dnsRule.includedTypes.add(e);
                          } else {
                            dnsRule.includedTypes.remove(e);
                          }
                          onChanged();
                        });
                      }),
                  closeOnActivate: false,
                  onPressed: () {
                    setState(() {
                      if (dnsRule.includedTypes.contains(e)) {
                        dnsRule.includedTypes.remove(e);
                      } else {
                        dnsRule.includedTypes.add(e);
                      }
                      onChanged();
                    });
                  },
                  child: Text(e.name),
                );
              }))
          .toList(),
      builder: (context, controller, child) {
        return Tooltip(
          preferBelow: false,
          message: AppLocalizations.of(context)!.dnsTypeConditionDesc,
          child: ActionChip(
            label: Text(AppLocalizations.of(context)!.dnsType),
            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
            avatar: dnsRule.includedTypes.isNotEmpty
                ? const Icon(
                    Icons.check_box_outlined,
                  )
                : const Icon(
                    Icons.check_box_outline_blank_rounded,
                  ),
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
          ),
        );
      },
    );
  }
}

List<Widget> buildWrapChildrenForDomains(
    BuildContext context, List<Domain> geoDomains, Function(Domain)? onDelete) {
  final children = <Widget>[];
  children.add(WrapChild(
    shape: chipBorderRadius,
    text: AppLocalizations.of(context)!.keyword,
    backgroundColor: pinkColorTheme.secondaryContainer,
    foregroundColor: pinkColorTheme.onSecondaryContainer,
  ));
  children.addAll(geoDomains
      .where((domain) => domain.type == Domain_Type.Plain)
      .map((domain) => WrapChild(
            shape: chipBorderRadius,
            text: domain.value,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerLowest,
            onDelete: onDelete != null ? () => onDelete(domain) : null,
          )));

  children.add(WrapChild(
    shape: chipBorderRadius,
    text: AppLocalizations.of(context)!.rootDomain,
    backgroundColor: greenColorTheme.secondaryContainer,
    foregroundColor: greenColorTheme.onSecondaryContainer,
  ));
  children.addAll(geoDomains
      .where((domain) => domain.type == Domain_Type.RootDomain)
      .map((domain) => WrapChild(
            shape: chipBorderRadius,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerLowest,
            text: domain.value,
            onDelete: onDelete != null ? () => onDelete(domain) : null,
          )));
  children.add(WrapChild(
    shape: chipBorderRadius,
    text: AppLocalizations.of(context)!.exact,
    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
  ));
  children.addAll(geoDomains
      .where((domain) => domain.type == Domain_Type.Full)
      .map((domain) => WrapChild(
            shape: chipBorderRadius,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerLowest,
            text: domain.value,
            onDelete: onDelete != null ? () => onDelete(domain) : null,
          )));
  children.add(WrapChild(
    shape: chipBorderRadius,
    text: AppLocalizations.of(context)!.regularExpression,
    backgroundColor: purpleColorTheme.secondaryContainer,
    foregroundColor: purpleColorTheme.onSecondaryContainer,
  ));
  children.addAll(geoDomains
      .where((domain) => domain.type == Domain_Type.Regex)
      .map((domain) => WrapChild(
            shape: chipBorderRadius,
            text: domain.value,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerLowest,
            onDelete: onDelete != null ? () => onDelete(domain) : null,
          )));

  return children;
}

class InboundCondition extends StatefulWidget {
  const InboundCondition(
      {super.key, required this.rule, required this.onChanged});
  final RuleConfig rule;
  final Function() onChanged;
  @override
  State<InboundCondition> createState() => _InboundConditionState();
}

class _InboundConditionState extends State<InboundCondition> {
  final _inboundController = TextEditingController();
  @override
  void dispose() {
    _inboundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, bottom: 16.0, top: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.inbound,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const Gap(5),
          Wrap(
              runSpacing: 10,
              spacing: 10,
              children: widget.rule.inboundTags
                  .map((e) => WrapChild(
                        shape: chipBorderRadius,
                        text: e,
                        onDelete: () => setState(() {
                          widget.rule.inboundTags.remove(e);
                          widget.onChanged();
                        }),
                      ))
                  .toList()),
          const Gap(10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _inboundController,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      widget.rule.inboundTags.add(_inboundController.text);
                      _inboundController.clear();
                      setState(() {
                        widget.onChanged();
                      });
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.inbound,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              const Gap(5),
              IconButton.filledTonal(
                  onPressed: () {
                    if (_inboundController.text.isNotEmpty) {
                      widget.rule.inboundTags.add(_inboundController.text);
                      _inboundController.clear();
                      setState(() {
                        widget.onChanged();
                      });
                    }
                  },
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(Icons.add_rounded, size: 18))
            ],
          ),
        ],
      ),
    );
  }
}

class DomainCondition extends StatefulWidget {
  const DomainCondition(
      {super.key, this.rule, this.dnsRule, required this.onChanged});
  final RuleConfig? rule;
  final DnsRuleConfig? dnsRule;
  final Function() onChanged;
  @override
  State<DomainCondition> createState() => _DomainConditionState();
}

class _DomainConditionState extends State<DomainCondition> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, bottom: 16.0, top: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.domain,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const Gap(5),
          Wrap(
            runSpacing: 10,
            spacing: 10,
            children: buildWrapChildrenForDomains(
                context, widget.rule?.geoDomains ?? widget.dnsRule!.domains,
                (domain) {
              setState(() {
                widget.rule?.geoDomains.remove(domain);
                widget.dnsRule?.domains.remove(domain);
                widget.onChanged();
              });
            }),
          ),
          const Gap(10),
          DomainCollector(
            onAdd: (p0) {
              widget.rule?.geoDomains.add(p0);
              widget.dnsRule?.domains.add(p0);
              setState(() {
                widget.onChanged();
              });
            },
          ),
          const Gap(10),
          Text(AppLocalizations.of(context)!.domainSet,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const Gap(5),
          Wrap(
              runSpacing: 10,
              spacing: 10,
              children: (widget.rule?.domainTags ?? widget.dnsRule!.domainTags)
                  .map<Widget>((e) => MenuAnchor(
                        menuChildren: [
                          MenuItemButton(
                            onPressed: () {
                              widget.rule?.domainTags.remove(e);
                              widget.dnsRule?.domainTags.remove(e);
                              setState(() {
                                widget.onChanged();
                              });
                            },
                            child: Text(AppLocalizations.of(context)!.delete),
                          ),
                        ],
                        builder: (context, controller, child) =>
                            GestureDetector(
                          onDoubleTap: () {
                            widget.rule?.domainTags.remove(e);
                            widget.dnsRule?.domainTags.remove(e);
                            setState(() {
                              widget.onChanged();
                            });
                          },
                          onSecondaryTapDown: (details) {
                            controller.open(
                                position: Offset(details.localPosition.dx,
                                    details.localPosition.dy));
                          },
                          onLongPress: () {
                            controller.open();
                          },
                          child: Chip(
                            label: Text(e),
                          ),
                        ),
                      ))
                  .toList()
                ..add(DomainSetPicker(onChanged: (p0) {
                  widget.rule?.domainTags.add(p0);
                  widget.dnsRule?.domainTags.add(p0);
                  setState(() {
                    widget.onChanged();
                  });
                }))),
          if (widget.rule != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: CheckboxListTile(
                  value: !widget.rule!.skipSniff,
                  title: Text(
                      AppLocalizations.of(context)!.sniffDomainForIpConnection,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                  onChanged: (v) {
                    widget.rule!.skipSniff = !(v ?? false);
                    setState(() {
                      widget.onChanged();
                    });
                  }),
            )
        ],
      ),
    );
  }
}

class DomainSetPicker extends StatefulWidget {
  const DomainSetPicker({super.key, required this.onChanged});
  final Function(String) onChanged;
  @override
  State<DomainSetPicker> createState() => _DomainSetPickerState();
}

class _DomainSetPickerState extends State<DomainSetPicker> {
  Future<List<GreatDomainSet>>? _getGreatDomainSetsFuture;
  Future<List<AtomicDomainSet>>? _getAtomicDomainSetsFuture;
  @override
  void initState() {
    super.initState();
    final database = context.read<DatabaseProvider>().database;
    _getGreatDomainSetsFuture = database.managers.greatDomainSets.get();
    _getAtomicDomainSetsFuture = database.managers.atomicDomainSets.get();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        FutureBuilder(
            future: _getGreatDomainSetsFuture,
            builder: (ctx, snaoshot) {
              if (!snaoshot.hasData) {
                return const SizedBox.shrink();
              }
              final menuChildren = <Widget>[];
              for (final e in snaoshot.data!) {
                menuChildren.add(MenuItemButton(
                  onPressed: () {
                    widget.onChanged(e.set.name);
                  },
                  child: Text(localizedSetName(context, e.set.name)),
                ));
                if (e.set.oppositeName.isNotEmpty) {
                  menuChildren.add(MenuItemButton(
                    onPressed: () {
                      widget.onChanged(e.set.oppositeName);
                    },
                    child: Text(localizedSetName(context, e.set.oppositeName)),
                  ));
                }
              }
              return SubmenuButton(
                menuChildren: menuChildren,
                child: Text(AppLocalizations.of(context)!.greatDomainSet),
              );
            }),
        FutureBuilder(
            future: _getAtomicDomainSetsFuture,
            builder: (ctx, snaoshot) {
              if (!snaoshot.hasData) {
                return const SizedBox.shrink();
              }
              return SubmenuButton(
                menuChildren: snaoshot.data!
                    .map((e) => MenuItemButton(
                          onPressed: () {
                            widget.onChanged(e.name);
                          },
                          child: Text(localizedSetName(context, e.name)),
                        ))
                    .toList(),
                child: Text(AppLocalizations.of(context)!.atmoicDomainSet),
              );
            }),
      ],
      builder: (context, controller, child) => IconButton.filledTonal(
          onPressed: () => controller.open(),
          style: IconButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(0),
          ),
          icon: const Icon(Icons.add_rounded, size: 18)),
    );
  }
}

class IPCondition extends StatefulWidget {
  const IPCondition({super.key, required this.rule, required this.onChanged});
  final RuleConfig rule;
  final Function() onChanged;

  @override
  State<IPCondition> createState() => _IPConditionState();
}

class _IPConditionState extends State<IPCondition> {
  final _ipController = TextEditingController();
  Future<List<GreatIpSet>>? _getGreatIpSetsFuture;
  Future<List<AtomicIpSet>>? _getAtomicIpSetsFuture;
  @override
  void initState() {
    super.initState();
    final database = context.read<DatabaseProvider>().database;
    _getGreatIpSetsFuture = database.managers.greatIpSets.get();
    _getAtomicIpSetsFuture = database.managers.atomicIpSets.get();
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, bottom: 16.0, top: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IP',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const Gap(5),
          Wrap(
              runSpacing: 10,
              spacing: 10,
              children: widget.rule.dstCidrs
                  .map((e) => WrapChild(
                        shape: chipBorderRadius,
                        text: e,
                        onDelete: () => setState(() {
                          widget.rule.dstCidrs.remove(e);
                          widget.onChanged();
                        }),
                      ))
                  .toList()),
          const Gap(10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    labelText: 'IP',
                    hintText: '10.0.0.0/24',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              const Gap(5),
              IconButton.filledTonal(
                  onPressed: () {
                    if (_ipController.text.isNotEmpty) {
                      if (!isValidCidr(_ipController.text)) {
                        return;
                      }
                      widget.rule.dstCidrs.add(_ipController.text);
                      _ipController.clear();
                      setState(() {
                        widget.onChanged();
                      });
                    }
                  },
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(Icons.add_rounded, size: 18))
            ],
          ),
          const Gap(10),
          Text(AppLocalizations.of(context)!.ipSet,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const Gap(5),
          Wrap(
              runSpacing: 10,
              spacing: 10,
              children: widget.rule.dstIpTags
                  .map((e) => MenuAnchor(
                        menuChildren: [
                          MenuItemButton(
                            onPressed: () {
                              widget.rule.dstIpTags.remove(e);
                              setState(() {
                                widget.onChanged();
                              });
                            },
                            child: const Text('删除'),
                          ),
                        ],
                        builder: (context, controller, child) =>
                            GestureDetector(
                          onDoubleTap: () {
                            widget.rule.dstIpTags.remove(e);
                            setState(() {
                              widget.onChanged();
                            });
                          },
                          onSecondaryTapDown: (details) {
                            controller.open(
                                position: Offset(details.localPosition.dx,
                                    details.localPosition.dy));
                          },
                          onLongPress: () {
                            controller.open();
                          },
                          child: Chip(
                            label: Text(e),
                          ),
                        ),
                      ))
                  .toList()
                ..add(MenuAnchor(
                  menuChildren: [
                    FutureBuilder(
                        future: _getGreatIpSetsFuture,
                        builder: (ctx, snaoshot) {
                          if (!snaoshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          return SubmenuButton(
                            menuChildren: snaoshot.data!
                                .map((e) => MenuItemButton(
                                      onPressed: () {
                                        widget.rule.dstIpTags
                                            .add(e.greatIpSetConfig.name);
                                        setState(() {
                                          widget.onChanged();
                                        });
                                        widget.onChanged();
                                      },
                                      child: Text(e.greatIpSetConfig.name),
                                    ))
                                .toList(),
                            child:
                                Text(AppLocalizations.of(context)!.greatIpSet),
                          );
                        }),
                    FutureBuilder(
                        future: _getAtomicIpSetsFuture,
                        builder: (ctx, snaoshot) {
                          if (!snaoshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          return SubmenuButton(
                            menuChildren: snaoshot.data!
                                .map((e) => MenuItemButton(
                                      onPressed: () {
                                        widget.rule.dstIpTags.add(e.name);
                                        setState(() {
                                          widget.onChanged();
                                        });
                                        widget.onChanged();
                                      },
                                      child: Text(e.name),
                                    ))
                                .toList(),
                            child:
                                Text(AppLocalizations.of(context)!.atmoicIpSet),
                          );
                        }),
                  ],
                  builder: (context, controller, child) =>
                      IconButton.filledTonal(
                          onPressed: () => controller.open(),
                          style: IconButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(0),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18)),
                ))),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: CheckboxListTile(
                value: widget.rule.resolveDomain,
                title: Text(AppLocalizations.of(context)!.resolveDomain,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
                onChanged: (v) {
                  widget.rule.resolveDomain = v ?? false;
                  setState(() {
                    widget.onChanged();
                  });
                }),
          )
        ],
      ),
    );
  }
}

class AllCondition extends StatefulWidget {
  const AllCondition({super.key, required this.rule, required this.onChanged});
  final RuleConfig rule;
  final Function() onChanged;

  @override
  State<AllCondition> createState() => _AllConditionState();
}

class _AllConditionState extends State<AllCondition> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, bottom: 16.0, top: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.domainIpAppConditionDesc,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const Gap(5),
          Text(AppLocalizations.of(context)!.setName,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const Gap(5),
          Wrap(
              runSpacing: 10,
              spacing: 10,
              children: widget.rule.allTags
                  .map((e) => WrapChild(
                        shape: chipBorderRadius,
                        text: e,
                        onDelete: () {
                          setState(() {
                            widget.rule.allTags.remove(e);
                            widget.onChanged();
                          });
                        },
                      ))
                  .toList()),
          const Gap(10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      setState(() {
                        widget.rule.allTags.add(_controller.text);
                        _controller.clear();
                        widget.onChanged();
                      });
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.setName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              const Gap(5),
              IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      widget.rule.allTags.add(_controller.text);
                      _controller.clear();
                      widget.onChanged();
                    });
                  },
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(Icons.add_rounded, size: 18))
            ],
          ),
          const Gap(5),
          CheckboxListTile(
              value: widget.rule.resolveDomain,
              title: Text(AppLocalizations.of(context)!.resolveDomain,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )),
              onChanged: (v) {
                widget.rule.resolveDomain = v ?? false;
                setState(() {
                  widget.onChanged();
                });
              }),
          const Gap(5),
          CheckboxListTile(
              value: !widget.rule.skipSniff,
              title: Text(
                  AppLocalizations.of(context)!.sniffDomainForIpConnection,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )),
              onChanged: (v) {
                widget.rule.skipSniff = !(v ?? false);
                setState(() {
                  widget.onChanged();
                });
              }),
        ],
      ),
    );
  }
}

class AppCondition extends StatefulWidget {
  const AppCondition({super.key, required this.rule, required this.onChanged});
  final RuleConfig rule;
  final Function() onChanged;
  @override
  State<AppCondition> createState() => _AppConditionState();
}

class _AppConditionState extends State<AppCondition> {
  final _appController = TextEditingController();
  Future<List<AppSet>>? _getAppSetsFuture;
  AppId_Type _type = AppId_Type.Keyword;

  @override
  void initState() {
    super.initState();
    final database = context.read<DatabaseProvider>().database;
    _getAppSetsFuture = database.managers.appSets.get();
  }

  @override
  void dispose() {
    _appController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, bottom: 16.0, top: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.app,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const Gap(5),
          Column(
            children: widget.rule.appIds
                .map((e) => ListTile(
                      title: Text(e.value),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      shape: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      tileColor: Theme.of(context).colorScheme.surfaceContainer,
                      subtitle: Platform.isAndroid
                          ? null
                          : Text(e.type.toLocalString(context)),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            widget.rule.appIds.remove(e);
                            widget.onChanged();
                          });
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ))
                .toList(),
          ),
          const Gap(10),
          DropdownMenu<AppId_Type>(
            width: 120,
            label: Text(AppLocalizations.of(context)!.type),
            initialSelection: _type,
            requestFocusOnTap: false,
            onSelected: (AppId_Type? t) {
              if (t != null) {
                _type = t;
              }
              setState(() {});
            },
            dropdownMenuEntries: AppId_Type.values
                .map((e) => DropdownMenuEntry(
                    label: e.toLocalString(context), value: e))
                .toList(),
          ),
          const Gap(5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _appController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.app,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ),
              const Gap(5),
              IconButton.filledTonal(
                  onPressed: () {
                    widget.rule.appIds.add(AppId(
                      value: _appController.text,
                      type: _type,
                    ));
                    _appController.clear();
                    setState(() {
                      widget.onChanged();
                    });
                  },
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(Icons.add_rounded, size: 18))
            ],
          ),
          const Gap(10),
          Text(AppLocalizations.of(context)!.appSet,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const Gap(5),
          Wrap(
              runSpacing: 10,
              spacing: 10,
              children: widget.rule.appTags
                  .map<Widget>((e) => MenuAnchor(
                        menuChildren: [
                          MenuItemButton(
                            onPressed: () {
                              widget.rule.appTags.remove(e);
                              setState(() {
                                widget.onChanged();
                              });
                            },
                            child: Text(AppLocalizations.of(context)!.delete),
                          ),
                        ],
                        builder: (context, controller, child) =>
                            GestureDetector(
                          onDoubleTap: () {
                            widget.rule.appTags.remove(e);
                            setState(() {
                              widget.onChanged();
                            });
                          },
                          onSecondaryTapDown: (details) {
                            controller.open(
                                position: Offset(details.localPosition.dx,
                                    details.localPosition.dy));
                          },
                          onLongPress: () {
                            controller.open();
                          },
                          child: Chip(
                            label: Text(e),
                          ),
                        ),
                      ))
                  .toList()
                ..add(
                  FutureBuilder(
                      future: _getAppSetsFuture,
                      builder: (ctx, snaoshot) {
                        if (!snaoshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        return MenuAnchor(
                          menuChildren: snaoshot.data!
                              .map((e) => MenuItemButton(
                                    onPressed: () {
                                      widget.rule.appTags.add(e.name);
                                      setState(() {
                                        widget.onChanged();
                                      });
                                    },
                                    child: Text(e.name),
                                  ))
                              .toList(),
                          builder: (context, controller, child) =>
                              IconButton.filledTonal(
                                  onPressed: () => controller.open(),
                                  style: IconButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.all(0),
                                  ),
                                  icon:
                                      const Icon(Icons.add_rounded, size: 18)),
                        );
                      }),
                )),
        ],
      ),
    );
  }
}

class DomainCollector extends StatefulWidget {
  const DomainCollector({super.key, required this.onAdd});
  final Function(Domain) onAdd;
  @override
  State<DomainCollector> createState() => _DomainCollectorState();
}

class _DomainCollectorState extends State<DomainCollector> {
  Domain_Type _type = Domain_Type.Plain;
  final _domainController = TextEditingController();

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownMenu<Domain_Type>(
            width: 120,
            label: Text(
              AppLocalizations.of(context)!.type,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            initialSelection: _type,
            requestFocusOnTap: false,
            onSelected: (Domain_Type? t) {
              setState(() {
                if (t != null) {
                  _type = t;
                }
              });
            },
            dropdownMenuEntries: Domain_Type.values
                .map((e) => DropdownMenuEntry(
                    label: e.toLocalString(context), value: e))
                .toList()),
        const Gap(10),
        Expanded(
          child: TextFormField(
            controller: _domainController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.domain,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        const Gap(5),
        IconButton.filledTonal(
            onPressed: () {
              widget.onAdd(Domain(
                type: _type,
                value: _domainController.text,
              ));
              _domainController.clear();
            },
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(0),
            icon: const Icon(Icons.add_rounded, size: 18))
      ],
    );
  }
}
