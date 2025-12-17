import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vx/l10n/app_localizations.dart';

class DeleteMenuAnchor extends StatelessWidget {
  const DeleteMenuAnchor(
      {super.key, required this.child, required this.onDelete});
  final Widget child;
  final Function(BuildContext)? onDelete;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
        builder: (context, controller, child) {
          return GestureDetector(
            onSecondaryTap: () => controller.open(),
            onLongPress: () => controller.open(),
            child: child,
          );
        },
        menuChildren: [
          MenuItemButton(
              onPressed:
                  onDelete != null ? () => onDelete?.call(context) : null,
              child: Text(AppLocalizations.of(context)!.delete)),
        ],
        child: child);
  }
}
