import 'package:flutter/material.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/theme.dart';

const proIcon = Icon(Icons.stars_rounded, color: XBlue);
const proIconExtraSmall = Icon(Icons.stars_rounded, color: XBlue, size: 16);
const proIconSmall = Icon(Icons.stars_rounded, color: XBlue, size: 18);
const largeProIcon = Icon(Icons.stars_rounded, color: XBlue, size: 32);

class ActivatedIcon extends StatelessWidget {
  const ActivatedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(
        Icons.verified_user_rounded,
        color: XBlue,
      ),
      label: Text(AppLocalizations.of(context)!.activated,
          style: Theme.of(context).textTheme.bodySmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    );
  }
}
