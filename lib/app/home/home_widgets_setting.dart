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
import 'package:vx/l10n/app_localizations.dart';

/// Settings page to choose which home widgets are visible.
class HomeWidgetsSettingPage extends StatelessWidget {
  const HomeWidgetsSettingPage({super.key});

  static String _label(BuildContext context, HomeWidgetId id) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case HomeWidgetId.stats:
        return l10n.homeWidgetStats;
      case HomeWidgetId.nodesHelper:
        return l10n.homeWidgetNodesHelper;
      case HomeWidgetId.route:
        return l10n.routing;
      case HomeWidgetId.proxySelector:
        return l10n.nodeSelection;
      case HomeWidgetId.inbound:
        return l10n.inbound;
      case HomeWidgetId.subscription:
        return l10n.subscription;
      case HomeWidgetId.promotion:
        return l10n.promote;
      case HomeWidgetId.nodes:
        return l10n.homeWidgetNodes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibility = context.watch<HomeWidgetVisibilityNotifier>();
    final hidden = visibility.hiddenIds;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.customizeHomeWidgets),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              AppLocalizations.of(context)!.customizeHomeWidgetsDesc,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          ...HomeWidgetId.values.map((id) {
            final visible = !hidden.contains(id.id);
            return SwitchListTile(
              value: visible,
              onChanged: (value) {
                if (value) {
                  visibility.show(id.id);
                } else {
                  visibility.hide(id.id);
                }
              },
              title: Text(_label(context, id)),
            );
          }),
        ],
      ),
    );
  }
}
