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
