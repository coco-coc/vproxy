import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vx/app/layout_provider.dart';
import 'package:vx/app/settings/privacy.dart';
import 'package:vx/auth/auth_bloc.dart';
import 'package:vx/auth/auth_provider.dart';
import 'package:vx/auth/email_auth.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/logger.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isLoggingIn = false;

  Widget getUserAgreement(BuildContext context) {
    final style = TextButton.styleFrom(
        overlayColor: Colors.transparent,
        padding: EdgeInsets.zero,
        alignment: Alignment.bottomCenter,
        minimumSize: Size(0, 17));
    switch (Localizations.localeOf(context).languageCode) {
      case 'zh':
        return Text.rich(
          softWrap: true,
          style: Theme.of(context).textTheme.bodySmall,
          TextSpan(
            children: [
              TextSpan(text: '登录即表示您同意'),
              WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: TextButton(
                      style: style,
                      onPressed: () {
                        launchUrl(Uri.parse(termOfServiceUrl));
                      },
                      child: Text('用户协议',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              )))),
              TextSpan(text: '并确认已阅读'),
              WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: TextButton(
                      style: style,
                      onPressed: () {
                        launchUrl(Uri.parse(privacyPolicyUrl));
                      },
                      child: Text('隐私政策',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              )))),
            ],
          ),
        );
      case 'en':
        return Text.rich(
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
          TextSpan(
            children: [
              TextSpan(text: 'By logging in, you agree to the '),
              WidgetSpan(
                  child: TextButton(
                      style: style,
                      onPressed: () {
                        launchUrl(Uri.parse(termOfServiceUrl));
                      },
                      child: Text('Term of Service',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              )))),
              TextSpan(text: ' and acknowledge that you have read our '),
              WidgetSpan(
                  child: TextButton(
                      style: style,
                      onPressed: () {
                        launchUrl(Uri.parse(privacyPolicyUrl));
                      },
                      child: Text('Privacy Policy',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              )))),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<bool> getUserConsent() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final result = await showDialog<bool?>(
          context: context,
          builder: (context) => AlertDialog(
                content: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      AppLocalizations.of(context)!.userConsend,
                      maxLines: 10,
                    )),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(AppLocalizations.of(context)!.disagree)),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(AppLocalizations.of(context)!.okay)),
                ],
              ));
      return result ?? false;
    }
    return true;
  }

  bool get _showGoogle {
    if (!Platform.isWindows) {
      return true;
    }
    return !isRunningAsAdmin;
  }

  bool get _showMicrosoft {
    if (!Platform.isWindows) {
      return true;
    }
    return !isRunningAsAdmin;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state.user != null) {
        context.go('/setting/account');
      }
    }, builder: (context, state) {
      if (state.isAuthenticated) {
        return Center(
          child: Text(
            AppLocalizations.of(context)!.loginSuccess,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        );
      }
      return _isLoggingIn
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.login,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    if (!await getUserConsent()) {
                      return;
                    }
                    if (Provider.of<MyLayout>(context, listen: false)
                        .fullScreen()) {
                      await Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(
                              builder: (ctx) =>
                                  const EmailAuth(fullScreen: true)));
                    } else {
                      await showDialog(
                          context: context,
                          barrierLabel:
                              AppLocalizations.of(context)!.emailLogin,
                          barrierDismissible: false,
                          builder: (context) => const EmailAuth());
                    }
                  },
                  icon: const Icon(Icons.email_outlined, size: 24),
                  label: Text(AppLocalizations.of(context)!.email),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(270, 50),
                  ),
                ),
                if (_showGoogle)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: FilledButton.tonalIcon(
                      onPressed: () async {
                        if (!await getUserConsent()) {
                          return;
                        }
                        setState(() {
                          _isLoggingIn = true;
                        });
                        try {
                          await context.read<AuthProvider>().signInWithGoogle();
                        } catch (e) {
                          snack(e.toString());
                        } finally {
                          setState(() {
                            _isLoggingIn = false;
                          });
                        }
                      },
                      icon: Image.asset('assets/icons/google.png',
                          width: 24, height: 24),
                      label: Text(AppLocalizations.of(context)!.google),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(270, 50),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                if ((Platform.isMacOS && appFlavor != 'pkg') || Platform.isIOS)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FilledButton.tonalIcon(
                      onPressed: () async {
                        if (!await getUserConsent()) {
                          return;
                        }
                        setState(() {
                          _isLoggingIn = true;
                        });
                        try {
                          await context.read<AuthProvider>().signInWithApple();
                        } catch (e) {
                          snack(e.toString());
                        } finally {
                          setState(() {
                            _isLoggingIn = false;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.apple_rounded,
                        size: 24,
                      ),
                      label: Text(AppLocalizations.of(context)!.apple),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(270, 50),
                      ),
                    ),
                  ),
                if (_showMicrosoft)
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      if (!await getUserConsent()) {
                        return;
                      }
                      setState(() {
                        _isLoggingIn = true;
                      });
                      try {
                        context.read<AuthProvider>().signInWithMicrosoft();
                      } catch (e) {
                        snack(e.toString());
                      } finally {
                        setState(() {
                          _isLoggingIn = false;
                        });
                      }
                    },
                    icon: Image.asset('assets/icons/microsoft_logo.png',
                        width: 24, height: 24),
                    label: Text(AppLocalizations.of(context)!.microsoft),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(270, 50),
                    ),
                  ),
                const SizedBox(height: 5),
                getUserAgreement(context),
                const SizedBox(height: 5),
                Text(AppLocalizations.of(context)!.newUserProTrial,
                    style: Theme.of(context).textTheme.bodySmall),
                if (!isProduction())
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: FilledButton(
                      onPressed: () async {
                        await context.read<AuthProvider>().signInWithTest();
                      },
                      child: const Text('Test'),
                    ),
                  ),
              ],
            );
    });
  }
}
