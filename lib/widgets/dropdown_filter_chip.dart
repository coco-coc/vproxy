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

class ChipDropdownMenu<T> extends StatelessWidget {
  const ChipDropdownMenu(
      {super.key,
      required this.selected,
      required this.items,
      required this.onChanged});

  final T? selected;
  final List<T> items;
  final Function(T?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      requestFocusOnTap: false,
      width: 100,
      textStyle: Theme.of(context).textTheme.bodyMedium,
      trailingIcon: Transform.translate(
        offset: const Offset(-1, -1),
        child: const Icon(Icons.arrow_drop_down),
      ),
      selectedTrailingIcon: Transform.translate(
        offset: const Offset(-1, -1),
        child: const Icon(Icons.arrow_drop_up),
      ),
      initialSelection: selected,
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        isDense: true,
        suffixIconConstraints: const BoxConstraints(
            minHeight: 40, maxHeight: 40, minWidth: 40, maxWidth: 40),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
        constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      dropdownMenuEntries: items.map((e) {
        return DropdownMenuEntry(
          value: e,
          label: e.toString(),
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(200, 48)),
          ),
        );
      }).toList(),
      onSelected: onChanged,
    );
  }
}

