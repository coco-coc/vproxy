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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vx/app/home/home.dart';
import 'package:vx/app/home/home_widget_visibility.dart';
import 'package:vx/auth/auth_bloc.dart';
import 'package:vx/l10n/app_localizations.dart';

class HomeEditButton extends StatelessWidget {
  const HomeEditButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeWidgetVisibilityNotifier>(
        builder: (context, visibility, child) {
      return MenuAnchor(
        menuChildren: HomeWidgetId.values.map((id) {
          return MenuItemButton(
            leadingIcon: visibility.hiddenIds.contains(id.id)
                ? const Icon(Icons.visibility_off)
                : const Icon(Icons.visibility),
            closeOnActivate: false,
            child: Text(id.label(context)),
            onPressed: () {
              if (visibility.hiddenIds.contains(id.id)) {
                visibility.show(id.id);
              } else {
                visibility.hide(id.id);
              }
            },
          );
        }).toList(),
        builder: (context, controller, child) {
          return IconButton(
            onPressed: () => controller.open(),
            icon: const Icon(Icons.edit_rounded),
          );
        },
      );
    });
  }
}
