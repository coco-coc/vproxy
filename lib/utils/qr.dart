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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:vx/app/layout_provider.dart';
import 'package:vx/l10n/app_localizations.dart';

void shareQrCode(BuildContext context, String qrCodeData) async {
  final qrCode = Center(
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: PrettyQrView.data(
              data: qrCodeData,
              decoration: const PrettyQrDecoration(
                quietZone: PrettyQrQuietZone.standart,
              ),
            ),
          ),
          const Gap(16),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: qrCodeData));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.copiedToClipboard,
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: Text(AppLocalizations.of(context)!.copy),
          ),
        ],
      ),
    ),
  );
  if (Provider.of<MyLayout>(context, listen: false).fullScreen()) {
    Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
        builder: (ctx) => Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                leading: !Platform.isMacOS
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => ctx.pop(),
                      )
                    : null,
              ),
              body: SafeArea(
                child: qrCode,
              ),
            )));
  } else {
    showDialog(context: context, builder: (ctx) => qrCode);
  }
}
