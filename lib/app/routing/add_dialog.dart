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

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:tm/protos/common/geo/geo.pb.dart';
import 'package:vx/common/net.dart';
import 'package:vx/main.dart';
import 'package:vx/widgets/circular_progress_indicator.dart';

class AddDialog extends StatefulWidget {
  const AddDialog({super.key, required this.domain});
  final bool domain;
  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  final TextEditingController _controller = TextEditingController();
  Domain_Type _type = Domain_Type.Plain;
  final _formKey = GlobalKey<FormState>();
  bool _parsingFile = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.add),
      content: _parsingFile
          ? const SizedBox(
              width: 50,
              height: 100,
              child: Center(child: mdCircularProgressIndicator))
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.domain
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText:
                                      AppLocalizations.of(context)!.domain),
                            ),
                            const Gap(10),
                            DropdownMenu<Domain_Type>(
                                label: Text(AppLocalizations.of(context)!.type),
                                initialSelection: _type,
                                requestFocusOnTap: false,
                                onSelected: (Domain_Type? t) {
                                  if (t != null) {
                                    _type = t;
                                  }
                                  setState(() {});
                                },
                                dropdownMenuEntries: Domain_Type.values
                                    .map((e) => DropdownMenuEntry(
                                        label: e.toLocalString(context),
                                        value: e))
                                    .toList()),
                          ],
                        )
                      : TextFormField(
                          controller: _controller,
                          validator: (value) {
                            if (value?.isNotEmpty ?? false) {
                              final lines = value!.split('\n');
                              for (var line in lines) {
                                if (line.isEmpty) {
                                  continue;
                                }
                                final segments = line.split('/');
                                if (segments.length == 1) {
                                  if (!isValidIp(segments[0])) {
                                    return AppLocalizations.of(context)!
                                        .invalidIp;
                                  }
                                  return null;
                                }
                                if (!isValidCidr(line)) {
                                  return AppLocalizations.of(context)!
                                      .invalidCidr;
                                }
                              }
                            }
                            return null;
                          },
                          maxLines: 5,
                          decoration: const InputDecoration(
                              hintText: "10.0.0.0/24",
                              border: OutlineInputBorder(),
                              labelText: "IP"),
                        ),
                ],
              )),
      actions: [
        FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              if (_controller.text.isNotEmpty) {
                if (widget.domain) {
                  Navigator.of(context).pop(Domain(
                    type: _type,
                    value: _controller.text,
                  ));
                } else {
                  final cidrs = <CIDR>[];
                  for (var line in _controller.text.split('\n')) {
                    if (line.isEmpty) {
                      continue;
                    }
                    final segments = line.split('/');
                    final ip = InternetAddress(segments[0]);
                    int prefix;
                    if (segments.length == 2) {
                      prefix = int.parse(segments[1]);
                    } else {
                      prefix = ip.type == InternetAddressType.IPv4 ? 32 : 128;
                    }
                    cidrs.add(CIDR(ip: ip.rawAddress, prefix: prefix));
                  }
                  Navigator.of(context).pop(cidrs);
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.add)),
      ],
    );
  }
}

extension DomainTypeExtension on Domain_Type {
  String toLocalString(BuildContext context) {
    switch (this) {
      case Domain_Type.Full:
        return AppLocalizations.of(context)!.exact;
      case Domain_Type.RootDomain:
        return AppLocalizations.of(context)!.rootDomain;
      case Domain_Type.Plain:
        return AppLocalizations.of(context)!.keyword;
      case Domain_Type.Regex:
        return AppLocalizations.of(context)!.regularExpression;
      default:
        return 'Unknown';
    }
  }
}
