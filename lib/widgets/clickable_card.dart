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
