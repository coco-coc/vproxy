import 'package:flutter/material.dart';

class Clickable extends StatelessWidget {
  const Clickable(
      {super.key, required this.child, required this.onTap, this.menuChildren});
  final Widget child;
  final VoidCallback onTap;
  final List<Widget>? menuChildren;
  @override
  Widget build(BuildContext context) {
    final inkwell = InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onTap(),
      child: child,
    );
    if (menuChildren == null) {
      return inkwell;
    }
    return MenuAnchor(
      menuChildren: menuChildren!,
      builder: (context, controller, child) {
        return GestureDetector(
          onLongPressStart: (details) {
            controller.open(position: details.localPosition);
          },
          onSecondaryTapDown: (details) {
            controller.open(position: details.localPosition);
          },
          child: child,
        );
      },
      child: inkwell,
    );
  }
}
