import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:vx/auth/auth_bloc.dart';
import 'package:vx/auth/auth_provider.dart';
import 'package:vx/auth/sign_in_page.dart';
import 'package:vx/main.dart';
import 'package:vx/theme.dart';
import 'package:vx/utils/activate.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/widgets/circular_progress_indicator.dart';
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
  bool _isActivating = false;
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

  Future<void> _activate() async {
    setState(() {
      _isActivating = true;
    });
    final authBloc = context.read<AuthBloc>();
    try {
      final token = supabase.auth.currentSession?.accessToken;
      if (token == null) {
        throw 'No Token';
      }
      String? uniqueId = await storage.read(key: uniqueIdKey);
      if (uniqueId == null) {
        uniqueId = const Uuid().v4();
        await storage.write(key: uniqueIdKey, value: uniqueId);
      }
      final response = await supabase.functions.invoke('licence',
          headers: {
            'Authorization': 'Bearer $token',
          },
          body: (await getConstDeviceInfo(uniqueId)).hash());
      if (response.status == 200) {
        await storage.write(key: 'licence', value: jsonEncode(response.data));
        print(response.data);
        if (await validateLicence(Licence.fromJson(response.data), uniqueId)) {
          authBloc.add(const AuthActivatedEvent());
        }
      }
    } catch (e) {
      logger.e('activate error: $e');
    } finally {
      setState(() {
        _isActivating = false;
      });
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
                    child: Row(
                      children: [
                        Chip(
                          avatar: proIcon,
                          label: Text(
                              AppLocalizations.of(context)!.lifetimeProAccount,
                              style: Theme.of(context).textTheme.bodySmall),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        const Gap(10),
                        if (state.isActivated)
                          const ActivatedIcon(),
                      ],
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
                Gap(20),
                if (!context.watch<AuthBloc>().state.isActivated)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton.icon(
                          onPressed: _activate,
                          icon: _isActivating
                              ? smallCircularProgressIndicator
                              : const Icon(Icons.verified_user, size: 20),
                          label: Text(AppLocalizations.of(context)!.activate),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const Gap(8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            AppLocalizations.of(context)!.activateDesc,
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      height: 1.4,
                                    ),
                          ),
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
