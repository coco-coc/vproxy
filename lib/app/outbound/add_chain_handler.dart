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
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vx/app/outbound/outbound_repo.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tm/protos/protos/outbound.pb.dart';
import 'package:vx/widgets/outbound_handler_form/outbound_handler_form.dart';
import 'package:vx/app/outbound/outbounds_bloc.dart';
import 'package:vx/data/database.dart';
import 'package:vx/main.dart';

class AddEditChainHandlerDialog extends StatefulWidget {
  const AddEditChainHandlerDialog(
      {super.key, this.fullScreen = false, this.config});

  final bool fullScreen;
  final ChainHandlerConfig? config;
  @override
  State<AddEditChainHandlerDialog> createState() =>
      _AddEditChainHandlerDialogState();
}

class _AddEditChainHandlerDialogState extends State<AddEditChainHandlerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _widgetKey = GlobalKey<ChainHandlerFormState>();

  void _onSave(BuildContext context) async {
    final allGood = _formKey.currentState?.validate();
    if (allGood == true) {
      try {
        ChainHandlerConfig config =
            (_widgetKey.currentState as ChainHandlerFormState).config;
        if (config.handlers.length <= 1) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 5),
              content: Text(AppLocalizations.of(context)!.atLeastTwoNodes)));
          return;
        }
        context.pop(config);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 5), content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.fullScreen
        ? ScaffoldMessenger(
            child: Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.chainProxy),
                leading: !Platform.isMacOS
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context.pop(),
                      )
                    : null,
                actions: [
                  if (Platform.isMacOS)
                    TextButton(
                        onPressed: () => context.pop(),
                        child: Text(AppLocalizations.of(context)!.cancel)),
                  Builder(builder: (context) {
                    return TextButton(
                        onPressed: () => _onSave(context),
                        child: Text(AppLocalizations.of(context)!.save));
                  })
                ],
              ),
              body: ChainHandlerForm(
                  formKey: _formKey, key: _widgetKey, config: widget.config),
            ),
          )
        : ScaffoldMessenger(
            child: Dialog(
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Scaffold(
                    body: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.chainProxy,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                                child: ChainHandlerForm(
                                    formKey: _formKey,
                                    key: _widgetKey,
                                    config: widget.config)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                      fixedSize: const Size(100, 40),
                                      elevation: 1),
                                  onPressed: () => context.pop(),
                                  child: Text(
                                      AppLocalizations.of(context)!.cancel),
                                ),
                                const SizedBox(width: 10),
                                Builder(builder: (context) {
                                  return FilledButton(
                                    style: FilledButton.styleFrom(
                                        fixedSize: const Size(100, 40),
                                        elevation: 1),
                                    onPressed: () => _onSave(context),
                                    child: Text(
                                        AppLocalizations.of(context)!.save),
                                  );
                                })
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
              // actions: [
              //   TextButton(
              //       onPressed: () => context.pop(),
              //       child: Text(AppLocalizations.of(context)!.cancel)),
              //   TextButton(
              //       onPressed: _onSave,
              //       child: Text(AppLocalizations.of(context)!.save))
              // ],
            ),
          );
  }
}

class ChainHandlerForm extends StatefulWidget {
  const ChainHandlerForm({super.key, this.config, required this.formKey});
  final ChainHandlerConfig? config;
  final GlobalKey<FormState> formKey;
  @override
  State<ChainHandlerForm> createState() => ChainHandlerFormState();
}

class ChainHandlerFormState extends State<ChainHandlerForm> {
  final _nameController = TextEditingController();
  late List<NodeGroup> _groups;
  List<(ExpansionHandler, GlobalKey<_ExpansionHandlerState>)> _handlers = [];
  final Map<String, List<OutboundHandlerConfig>> _handlersByGroup = {};

  ChainHandlerConfig get config {
    return ChainHandlerConfig(
      tag: _nameController.text,
      handlers: _handlers.map((e) {
        final c = e.$2.currentState!.config;
        if (c == null) {
          throw Exception('config is null');
        }
        return c;
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _groups = context.read<OutboundBloc>().state.groups;
    Future.wait(_groups.map((e) async {
      final handlers =
          await context.read<OutboundRepo>().getHandlersByNodeGroup(e);
      _handlersByGroup[e.name] = handlers
          .where((e) => e.config.hasOutbound())
          .map((e) => e.config.outbound)
          .toList();
    })).then((_) {
      setState(() {});
    });

    if (widget.config != null) {
      _nameController.text = widget.config!.tag;
      _handlers = widget.config!.handlers.map((e) {
        final gk = GlobalKey<_ExpansionHandlerState>();
        return (
          ExpansionHandler(
              key: gk,
              config: e,
              onDelete: (key) {
                setState(() {
                  _handlers.removeWhere((e) => e.$2 == key);
                });
              }),
          gk
        );
      }).toList();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    super.dispose();
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              labelText: AppLocalizations.of(context)!.name,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.devices_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.yourDevices,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          )),
                ],
              ),
              const Gap(2),
              ArrowDownAddButton(
                  handlers: _handlers,
                  groups: _groups,
                  handlersByGroup: _handlersByGroup,
                  formKey: widget.formKey,
                  index: 0,
                  setState: setState),
              const Gap(2),
            ],
          ),
          if (_handlers.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ReorderableListView(
                proxyDecorator: proxyDecorator,
                buildDefaultDragHandles: false,
                shrinkWrap: true,
                children: _handlers.indexed.map((e) {
                  return Column(
                    key: ObjectKey(e.$1),
                    children: [
                      ReorderableDragStartListener(index: e.$1, child: e.$2.$1),
                      const Gap(2),
                      ArrowDownAddButton(
                          handlers: _handlers,
                          groups: _groups,
                          handlersByGroup: _handlersByGroup,
                          formKey: widget.formKey,
                          index: e.$1 + 1,
                          setState: setState)
                    ],
                  );
                }).toList(),
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final (
                      ExpansionHandler,
                      GlobalKey<_ExpansionHandlerState>
                    ) item = _handlers.removeAt(oldIndex);
                    _handlers.insert(newIndex, item);
                  });
                },
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.destination,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      )),
            ],
          ),
        ],
      ),
    );
  }
}

class ExpansionHandler extends StatefulWidget {
  const ExpansionHandler(
      {super.key, required this.config, required this.onDelete});

  final OutboundHandlerConfig? config;
  final Function(GlobalKey<_ExpansionHandlerState> key) onDelete;
  @override
  State<ExpansionHandler> createState() => _ExpansionHandlerState();
}

class _ExpansionHandlerState extends State<ExpansionHandler> {
  String title = '';
  OutboundHandlerConfig? _config;
  final _key = GlobalKey<OutboundHandlerFormState>();
  final _formKey = GlobalKey<FormState>();
  OutboundHandlerConfig? get config {
    if (_formKey.currentState?.validate() == false) {
      return null;
    }
    return _key.currentState?.outboundHandler ?? _config;
  }

  @override
  void initState() {
    super.initState();
    title = widget.config?.tag ?? '';
    _config = widget.config;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      collapsedShape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      leading: IconButton(
        icon: const Icon(Icons.delete_outline_rounded),
        onPressed: () {
          widget.onDelete(widget.key as GlobalKey<_ExpansionHandlerState>);
        },
      ),
      title: Text(title),
      subtitle: Text(_config?.getDisplayProtocol() ?? ''),
      showTrailingIcon: true,
      onExpansionChanged: (value) {
        if (!value) {
          _config = _key.currentState?.outboundHandler;
        }
      },
      iconColor: null,
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutboundHandlerForm(
              key: _key,
              formKey: _formKey,
              config: _config,
              onNameChanged: (value) {
                setState(() {
                  title = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ArrowDownAddButton extends StatelessWidget {
  const ArrowDownAddButton(
      {super.key,
      required this.handlers,
      required this.groups,
      required this.handlersByGroup,
      required this.formKey,
      required this.index,
      required this.setState});
  final List<(ExpansionHandler, GlobalKey<_ExpansionHandlerState>)> handlers;
  final List<NodeGroup> groups;
  final Map<String, List<OutboundHandlerConfig>> handlersByGroup;
  final GlobalKey<FormState> formKey;
  final int index;
  final Function(void Function() fn) setState;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 32),
        Icon(
          Icons.arrow_downward_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              child: Text(AppLocalizations.of(context)!.addNewNode),
              onPressed: () {
                setState(() {
                  final k = GlobalKey<_ExpansionHandlerState>();
                  handlers.insert(index, (
                    ExpansionHandler(
                        key: k,
                        config: null,
                        onDelete: (key) {
                          setState(() {
                            handlers.removeWhere((e) => e.$2 == key);
                          });
                        }),
                    k
                  ));
                });
              },
            ),
            SubmenuButton(
                menuChildren: groups.map((e) {
                  return SubmenuButton(
                    menuChildren: handlersByGroup[e.name]
                            ?.map((e) => MenuItemButton(
                                child: Text(e.tag),
                                onPressed: () {
                                  setState(() {
                                    final k =
                                        GlobalKey<_ExpansionHandlerState>();
                                    handlers.insert(index, (
                                      ExpansionHandler(
                                          key: k,
                                          config: e,
                                          onDelete: (key) {
                                            setState(() {
                                              handlers.removeWhere(
                                                  (e) => e.$2 == key);
                                            });
                                          }),
                                      k
                                    ));
                                  });
                                }))
                            .toList() ??
                        [],
                    child: Text(e.name),
                  );
                }).toList(),
                child: Text(AppLocalizations.of(context)!.useExistingNode))
          ],
          builder: (context, controller, child) => IconButton(
              onPressed: () => controller.open(),
              style: IconButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(0),
              ),
              icon: const Icon(
                Icons.add,
                size: 18,
              )),
        ),
      ],
    );
  }
}
