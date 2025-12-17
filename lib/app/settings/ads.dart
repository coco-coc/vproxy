import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vx/app/control.dart';
import 'package:vx/app/settings/setting.dart';
import 'package:vx/common/common.dart';
import 'package:vx/l10n/app_localizations.dart';

class PromotionPage extends StatelessWidget {
  const PromotionPage({super.key, this.showAppBar = true});
  final bool showAppBar;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? getAdaptiveAppBar(
              context,
              Text(AppLocalizations.of(context)!.promote),
            )
          : null,
      body: Platform.isMacOS && !isPkg ? null : const Promotion(),
    );
  }
}
