import 'package:flutter/material.dart';

Widget getSmallAddButton({
  required Function() onPressed,
}) {
  return IconButton.filledTonal(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.all(0),
      ),
      icon: const Icon(Icons.add_rounded, size: 18));
}
