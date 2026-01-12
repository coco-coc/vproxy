import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vx/app/home/home.dart';
import 'package:vx/app/settings/ads.dart';
import 'package:vx/app/settings/debug.dart';
import 'package:vx/app/settings/general/general.dart';
import 'package:vx/iap/pro.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/app/settings/account.dart';
import 'package:vx/app/settings/advanced/advanced.dart';
import 'package:vx/app/settings/contact.dart';
import 'package:vx/app/settings/general/language.dart';
import 'package:vx/app/settings/open_source_software_notice_screen.dart';
import 'package:vx/app/settings/privacy.dart';
import 'package:vx/auth/auth_bloc.dart';
import 'package:vx/auth/user.dart';
import 'package:vx/main.dart';
import 'package:vx/pref_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vx/theme.dart';
import 'package:vx/utils/debug.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/utils/path.dart';
import 'package:vx/widgets/ad.dart';
import 'package:vx/widgets/pro_icon.dart';
import 'package:vx/widgets/pro_promotion.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:window_manager/window_manager.dart';

final InAppReview inAppReview = InAppReview.instance;

enum SettingItem {
  account(icon: Icon(Icons.person_rounded), pathSegment: 'account'),
  advanced(icon: Icon(Icons.engineering_rounded), pathSegment: 'advanced'),
  general(icon: Icon(Icons.settings), pathSegment: 'general'),
  privacyPolicy(icon: Icon(Icons.info), pathSegment: 'privacy'),
  contactUs(icon: Icon(Icons.email_outlined), pathSegment: 'contactUs'),
  openSourceSoftwareNotice(
      icon: Icon(Icons.code_rounded), pathSegment: 'openSourceSoftwareNotice'),
  debugLog(icon: Icon(Icons.bug_report_rounded), pathSegment: 'debugLog'),
  ads(
      icon: ImageIcon(
        AssetImage(
          'assets/icons/ad.png',
        ),
      ),
      pathSegment: 'ads');

  final Widget icon;
  final String pathSegment;

  const SettingItem({required this.icon, required this.pathSegment});

  static SettingItem? fromPathSegment(String pathSegment) {
    for (final se in SettingItem.values) {
      if (se.pathSegment == pathSegment) {
        return se;
      }
    }
    return null;
  }

  static SettingItem? fromFullPath(String fullPath) {
    for (final se in SettingItem.values) {
      if (fullPath.startsWith('/setting/${se.pathSegment}')) {
        return se;
      }
    }
    return null;
  }

  Widget getIcon(BuildContext context) {
    switch (this) {
      case SettingItem.account:
        return BlocBuilder<AuthBloc, AuthState>(builder: (ctx, state) {
          if (state.pro) {
            return proIcon;
          } else {
            return icon;
          }
        });
      default:
        return icon;
    }
  }

  Widget title(BuildContext context) {
    switch (this) {
      case SettingItem.account:
        return Text(AppLocalizations.of(context)!.account);
      case SettingItem.advanced:
        return Text(AppLocalizations.of(context)!.advanced);
      case SettingItem.general:
        return Text(AppLocalizations.of(context)!.general);
      case SettingItem.privacyPolicy:
        return Text(AppLocalizations.of(context)!.privacyPolicy);
      case SettingItem.contactUs:
        return Text(AppLocalizations.of(context)!.contactUs);
      case SettingItem.openSourceSoftwareNotice:
        return Text(AppLocalizations.of(context)!.openSourceSoftwareNotice);
      case SettingItem.ads:
        return Text(AppLocalizations.of(context)!.promote);
      case SettingItem.debugLog:
        return Text(AppLocalizations.of(context)!.debugLog);
    }
  }

  Widget? subtitle(BuildContext context) {
    switch (this) {
      case SettingItem.account:
        return context.read<AuthBloc>().state.user == null
            ? Text(AppLocalizations.of(context)!.newUserTrialText)
            : null;
      case SettingItem.advanced:
        return Text(AppLocalizations.of(context)!.advancedSettingDesc);
      case SettingItem.general:
        return null;
      case SettingItem.privacyPolicy:
        return null;
      case SettingItem.contactUs:
        return null;
      case SettingItem.openSourceSoftwareNotice:
        return null;
      case SettingItem.ads:
        return null;
      case SettingItem.debugLog:
        return null;
    }
  }
}

const String websiteUrl = 'https://vx.5vnetwork.com';

class LargeSettingSreen extends StatefulWidget {
  const LargeSettingSreen({super.key, this.settingItem});

  final SettingItem? settingItem;

  @override
  State<LargeSettingSreen> createState() => _LargeSettingSreenState();
}

class _LargeSettingSreenState extends State<LargeSettingSreen> {
  SettingItem? selectedItem;

  @override
  void initState() {
    selectedItem = widget.settingItem;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LargeSettingSreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settingItem != widget.settingItem) {
      selectedItem = widget.settingItem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final list = ListView(
      children: SettingItem.values.map<Widget>((se) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: ListTile(
            minTileHeight: 64,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            leading: se.getIcon(context),
            title: se.title(context),
            subtitle: se.subtitle(context),
            // trailing: context.watch<AuthBloc>().state.pro ||
            //         se != SettingItem.advanced
            //     ? const Icon(Icons.keyboard_arrow_right_rounded)
            //     : proIcon,
            selected: selectedItem == se,
            selectedTileColor: Theme.of(context).colorScheme.surfaceContainer,
            onTap: () async {
              setState(() {
                selectedItem = se;
              });
              context.go('/setting/${se.pathSegment}');
            },
          ),
        );
      }).toList()
        ..addAll(_getBottomButtons(context, user)),
    );

    late Widget detail;
    switch (selectedItem) {
      case SettingItem.general:
        // Use a nested Navigator for advanced settings
        detail = Navigator(
          onDidRemovePage: (page) {
            context.go('/setting');
          },
          pages: const [
            MaterialPage(child: GeneralSettingPage(showAppBar: false))
          ],
        );
      case SettingItem.privacyPolicy:
        detail = const PrivacyPolicyScreen(showAppBar: false);
      case SettingItem.contactUs:
        detail = const ContactScreen(showAppBar: false);
      case SettingItem.openSourceSoftwareNotice:
        detail = const OpenSourceSoftwareNoticeScreen(showAppBar: false);
      case SettingItem.advanced:
        // Use a nested Navigator for advanced settings
        detail = Navigator(
          onDidRemovePage: (page) {
            context.go('/setting');
          },
          pages: const [MaterialPage(child: AdvancedScreen(showAppBar: false))],
        );
      case SettingItem.account:
        detail = const AccountPage(showAppBar: false);
      case SettingItem.ads:
        detail = const PromotionPage(showAppBar: false);
      case SettingItem.debugLog:
        detail = const DebugLogPage(showAppBar: false);
      default:
        detail = const SizedBox.shrink();
    }

    return Material(
      child: Row(
        children: [
          Expanded(child: list),
          const VerticalDivider(),
          Expanded(child: detail)
        ],
      ),
    );
  }
}

List<Widget> _getBottomButtons(BuildContext context, User? user) {
  return [
    const SizedBox(
      height: 5,
    ),
    if (context.watch<AuthBloc>().state.isActivated)
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0, left: 5.0),
          child: const ActivatedIcon(),
        ),
      ),
    Row(
      children: [
        if ((user == null || (user.lifetimePro == false)) &&
            !context.watch<AuthBloc>().state.isActivated)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: OutlinedButton.icon(
                onPressed: () {
                  if (useStripe) {
                    launchUrl(
                        getProPaymentLink(user?.email ?? '', user?.id ?? ''));
                  } else {
                    showProPromotionDialog(context);
                  }
                },
                icon: Icon(Icons.stars_rounded,
                    color: Theme.of(context).colorScheme.primary),
                label: AutoSizeText(
                  AppLocalizations.of(context)!.upgradeToPermanentPro,
                  maxLines: 1,
                  minFontSize: 12,
                ),
              ),
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: OutlinedButton.icon(
              onPressed: () {
                launchUrl(Uri.parse(websiteUrl));
              },
              label: Text(AppLocalizations.of(context)!.website),
              icon: const Icon(Icons.link),
            ),
          ),
        ),
      ],
    ),
    SizedBox(
      height: 5,
    ),
    Row(
      children: [
        if ((!useStripe && (user == null || (user.lifetimePro == false))))
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: OutlinedButton.icon(
                onPressed: () {
                  if (user == null) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text(AppLocalizations.of(context)!
                                  .loginBeforePurchase),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                        AppLocalizations.of(context)!.close)),
                              ],
                            ));
                  } else {
                    context.read<ProPurchases>().restore();
                  }
                },
                icon: Icon(Icons.history_rounded,
                    color: Theme.of(context).colorScheme.primary),
                label: AutoSizeText(
                  AppLocalizations.of(context)!.restoreIAP,
                  maxLines: 1,
                  minFontSize: 12,
                ),
              ),
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: OutlinedButton.icon(
              onPressed: () async {
                if (await inAppReview.isAvailable()) {
                  inAppReview.requestReview();
                } else {
                  inAppReview.openStoreListing(
                      appStoreId: '6744701950',
                      microsoftStoreId: '9PHBCBZ9R1FX');
                }
              },
              label: Text(AppLocalizations.of(context)!.rateApp),
              icon: const Icon(Icons.rate_review_outlined),
            ),
          ),
        ),
      ],
    ),
    Gap(5),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: OutlinedButton.icon(
          onPressed: () {
            launchUrl(Uri.parse(adWantedUrl));
          },
          label: Text(AppLocalizations.of(context)!.adWanted),
          icon: Icon(Icons.campaign_rounded,
              color: Theme.of(context).colorScheme.primary)),
    ),
    const Version(),
    if (!isProduction())
      Row(
        children: [
          IconButton(
            onPressed: saveLogToApplicationDocumentsDir,
            icon: Icon(Icons.file_copy),
          ),
          IconButton(
            onPressed: () async {
              final dbPath = await getDbPath(context.read<SharedPreferences>());
              clearDatabase(dbPath);
            },
            icon: Icon(Icons.delete),
          ),
          TextButton(
            onPressed: () async {
              final dstDir = Platform.isAndroid
                  ? ('/storage/emulated/0/Documents/vx')
                  : (await getApplicationDocumentsDirectory()).path;
              if (!Directory(dstDir).existsSync()) {
                Directory(dstDir).createSync(recursive: true);
              }
              final newFile =
                  await File(await getDbPath(context.read<SharedPreferences>()))
                      .copy(join(dstDir, "db.sqlite"));
              print('copied, ${newFile.path}');
            },
            child: Text('Copy Database'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().unsetTestUser();
            },
            child: Text('Unset'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().setTestUser();
            },
            child: Text('Set'),
          ),
        ],
      ),
  ];
}

class CompactSettingScreen extends StatelessWidget {
  const CompactSettingScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(AppLocalizations.of(context)!.settings),
              leading: IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: Icon(Icons.arrow_back_rounded)),
              automaticallyImplyLeading: true,
            )
          : null,
      body: ListView(
        children: SettingItem.values.map<Widget>((se) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: ListTile(
              minTileHeight: 64,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading: se.getIcon(context),
              title: se.title(context),
              subtitle: se.subtitle(context),
              trailing: const Icon(Icons.keyboard_arrow_right_rounded),
              onTap: () async {
                final currentPath = GoRouterState.of(context).fullPath ??
                    GoRouter.of(context)
                        .routeInformationProvider
                        .value
                        .uri
                        .toString();
                final basePath = currentPath.endsWith('/')
                    ? currentPath.substring(0, currentPath.length - 1)
                    : currentPath;
                final newPath = '$basePath/${se.pathSegment}';
                GoRouter.of(context).push(newPath);
              },
            ),
          );
        }).toList()
          ..addAll(_getBottomButtons(context, user)),
      ),
    );
  }
}

class Version extends StatelessWidget {
  const Version({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return const SizedBox();
        } else {
          final packageInfo = snapshot.data!;
          int count = 0;
          return Center(
            child: StatefulBuilder(builder: (context, setState) {
              return GestureDetector(
                onTap: () async {
                  setState(() {
                    print('count: $count');
                    count++;
                  });
                  if (count >= 10) {
                    demo = true;
                    App.of(context)?.rebuildAllChildren();
                    if (Platform.isMacOS) {
                      await windowManager.setSize(Size(1280, 800));
                    }
                    context.read<RealtimeSpeedNotifier>().demo();
                  }
                },
                child: Text(
                    'Version: ${packageInfo.version} (${packageInfo.buildNumber})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
              );
            }),
          );
        }
      },
    );
  }
}

AppBar getAdaptiveAppBar(BuildContext context, Widget? title) {
  return AppBar(
    automaticallyImplyLeading: Platform.isMacOS ? false : true,
    title: title,
    actions: [
      if (Platform.isMacOS)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
    ],
  );
}
