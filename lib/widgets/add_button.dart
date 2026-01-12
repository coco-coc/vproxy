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
