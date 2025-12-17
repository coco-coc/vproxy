import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:vx/auth/auth_bloc.dart';
import 'package:vx/auth/auth_provider.dart';
import 'package:vx/auth/sign_in_page.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/widgets/pro_icon.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, this.showAppBar = true});
  final bool showAppBar;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  DateTime? _lastRefreshTime;
  static const Duration _refreshCooldown = Duration(seconds: 5);

  bool get _canRefresh {
    if (_lastRefreshTime == null) return true;
    return DateTime.now().difference(_lastRefreshTime!) >= _refreshCooldown;
  }

  void _refreshUser() {
    if (_canRefresh) {
      logger.d('refresh user');
      _lastRefreshTime = DateTime.now();
      context.read<AuthProvider>().refreshUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(AppLocalizations.of(context)!.account))
          : null,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.user == null) {
            return const Center(
              child: SignInPage(),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(AppLocalizations.of(context)!.email,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AutoSizeText(state.user!.email,
                          maxLines: 2,
                          minFontSize: 12,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                  ],
                ),
                if (state.user!.lifetimePro == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Chip(
                      avatar: proIcon,
                      label: Text(AppLocalizations.of(context)!.lifetimeProAccount,
                          style: Theme.of(context).textTheme.bodySmall),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                if (state.user!.lifetimePro == false)
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.proExpiredAt,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(width: 10),
                      Text(
                          state.user!.proExpiredAt != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(state.user!.proExpiredAt!.toLocal())
                              : '',
                          style: Theme.of(context).textTheme.bodyLarge),
                      IconButton(
                        onPressed: _canRefresh ? _refreshUser : null,
                        icon: const Icon(Icons.refresh),
                      )
                    ],
                  ),
                const SizedBox(height: 10),
                Center(
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthProvider>().logOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                        ),
                        child: Text(AppLocalizations.of(context)!.logout),
                      ),
                      Gap(10),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                  AppLocalizations.of(context)!.deleteAccount),
                              content: Text(AppLocalizations.of(context)!
                                  .deleteAccountConfirm),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                        AppLocalizations.of(context)!.cancel)),
                                TextButton(
                                    onPressed: () {
                                      context
                                          .read<AuthProvider>()
                                          .deleteAccount();
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.delete))
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.errorContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        child:
                            Text(AppLocalizations.of(context)!.deleteAccount),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
