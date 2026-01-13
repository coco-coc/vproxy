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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vx/app/settings/setting.dart';
import 'package:vx/main.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/l10n/app_localizations.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? getAdaptiveAppBar(
              context, Text(AppLocalizations.of(context)!.language))
          : null,
      body: Column(children: [
        ...Language.values.where((l) => !l.aiTranslated).map((l) {
          return RadioListTile(
            title: Text(l.localText),
            value: l,
            groupValue:
                Language.fromCode(Localizations.localeOf(context).languageCode),
            onChanged: (value) {
              context.read<SharedPreferences>().setLanguage(value);
              // change locale
              App.of(context)?.setLocale(value?.locale);
            },
          );
        }),
        Text(AppLocalizations.of(context)!.followingAiTranslated),
        ...Language.values.where((l) => l.aiTranslated).map((l) {
          return RadioListTile(
            title: Text(l.localText),
            value: l,
            groupValue:
                Language.fromCode(Localizations.localeOf(context).languageCode),
            onChanged: (value) {
              context.read<SharedPreferences>().setLanguage(value);
              // change locale
              App.of(context)?.setLocale(value?.locale);
            },
          );
        }),
      ]),
    );
  }
}
