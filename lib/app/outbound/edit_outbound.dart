import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tm/protos/protos/outbound.pb.dart';
import 'package:vx/widgets/outbound_handler_form/outbound_handler_form.dart';
import 'package:vx/data/database.dart';
import 'package:vx/l10n/app_localizations.dart';

class EditOutboundDialog extends StatefulWidget {
  const EditOutboundDialog({super.key, this.handler});

  final OutboundHandler? handler;

  @override
  State<EditOutboundDialog> createState() => _EditOutboundDialogState();
}

class _EditOutboundDialogState extends State<EditOutboundDialog> {
  final _formKey = GlobalKey<FormState>();
  final _widgetKey = GlobalKey<OutboundHandlerFormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(AppLocalizations.of(context)!.edit),
        scrollable: true,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: OutboundHandlerForm(
            config: widget.handler?.config.outbound,
            formKey: _formKey,
            key: _widgetKey,
          ),
        ),
        actions: [
          FilledButton.tonal(
            style: FilledButton.styleFrom(
                fixedSize: const Size(100, 40), elevation: 1),
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                fixedSize: const Size(100, 40), elevation: 1),
            onPressed: () {
              final allGood = _formKey.currentState?.validate();
              if (allGood == true) {
                OutboundHandlerConfig config =
                    (_widgetKey.currentState as OutboundHandlerConfigGetter)
                        .outboundHandler;
                OutboundHandler handler =
                    OutboundHandler(config: HandlerConfig(outbound: config));
                if (widget.handler != null) {
                  final handlerAddressChanged =
                      widget.handler!.address != handler.address;
                  handler = handler.copyWith(
                    id: widget.handler!.id,
                    selected: widget.handler!.selected,
                    subId: widget.handler!.subId,
                    ping: handlerAddressChanged ? null : widget.handler!.ping,
                    speed: handlerAddressChanged ? null : widget.handler!.speed,
                  );
                }
                context.pop(handler);
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          )
        ]);
  }
}

class EditFullScreenDialog extends StatefulWidget {
  const EditFullScreenDialog({super.key, this.handler});

  final OutboundHandler? handler;

  @override
  State<EditFullScreenDialog> createState() => _EditFullScreenDialogState();
}

class _EditFullScreenDialogState extends State<EditFullScreenDialog> {
  final _formKey = GlobalKey<FormState>();
  final _widgetKey = GlobalKey<OutboundHandlerFormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          TextButton(
              onPressed: () {
                final allGood = _formKey.currentState?.validate();
                if (allGood == true) {
                  OutboundHandlerConfig config =
                      (_widgetKey.currentState as OutboundHandlerConfigGetter)
                          .outboundHandler;
                  OutboundHandler handler =
                      OutboundHandler(config: HandlerConfig(outbound: config));
                  if (widget.handler != null) {
                    // final destinationChanged = widget.handler!.config.address !=
                    //         handler.config.address ||
                    //     widget.handler!.config.ports != handler.config.ports;
                    handler = handler.copyWith(
                      id: widget.handler!.id,
                      selected: widget.handler!.selected,
                      subId: widget.handler!.subId,
                    );
                  }
                  context.pop(handler);
                }
              },
              child: Text(AppLocalizations.of(context)!.save))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: OutboundHandlerForm(
            config: widget.handler?.config.outbound,
            formKey: _formKey,
            key: _widgetKey,
          ),
        ),
      ),
    );
  }
}
