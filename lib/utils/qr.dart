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
