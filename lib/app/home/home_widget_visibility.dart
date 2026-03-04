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

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vx/pref_helper.dart';

/// Notifier for home widget visibility. When [hide] is called, updates prefs
/// and notifies so [HomePage] can rebuild.
class HomeWidgetVisibilityNotifier extends ChangeNotifier {
  HomeWidgetVisibilityNotifier(this._prefs);

  final SharedPreferences _prefs;

  Set<String> get hiddenIds => _prefs.hiddenHomeWidgetIds;

  void hide(String widgetId) {
    final next = Set<String>.from(hiddenIds)..add(widgetId);
    _prefs.setHiddenHomeWidgetIds(next);
    notifyListeners();
  }

  void show(String widgetId) {
    final next = Set<String>.from(hiddenIds)..remove(widgetId);
    _prefs.setHiddenHomeWidgetIds(next);
    notifyListeners();
  }
}
