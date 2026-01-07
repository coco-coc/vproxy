import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vx/auth/auth_provider.dart';
import 'package:vx/common/common.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/widgets/count_down_timer.dart';

class EmailAuth extends StatefulWidget {
  const EmailAuth({super.key, this.fullScreen = false});
  final bool fullScreen;
  @override
  State<EmailAuth> createState() => _EmailAuthState();
}

class _EmailAuthState extends State<EmailAuth> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isCounting = false;
  bool _isSendingOtp = false;
  bool _isLoggingIn = false;
  String? _sendOtpError;
  String? _emailError;
  Set<String> _disposableEmailDomains = {};

  @override
  initState() {
    super.initState();
    _loadDisposableEmailBlocklist();
    _emailController.addListener(_validateEmail);
  }

  Future<void> _loadDisposableEmailBlocklist() async {
    try {
      final content = await rootBundle.loadString(
        'assets/disposable_email_blocklist.conf',
      );
      final domains = content
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toSet();
      setState(() {
        _disposableEmailDomains = domains;
      });
    } catch (e) {
      // If blocklist fails to load, continue without blocking
    }
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = null);
      return;
    }

    if (!emailRegExp.hasMatch(email)) {
      setState(() => _emailError = null);
      return;
    }

    // Extract domain from email
    final domain = email.split('@').last.toLowerCase();
    
    if (_disposableEmailDomains.contains(domain)) {
      setState(() {
        _emailError = AppLocalizations.of(context)!.pleaseUseAnotherEmail;
      });
    } else {
      setState(() => _emailError = null);
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  List<Widget> _buildContent() {
    return [
      TextField(
        controller: _emailController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.email,
          errorText: _emailError,
          errorMaxLines: 2,
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _otpController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.verificationCode,
          errorText: _sendOtpError,
          errorMaxLines: 10,
          suffixIcon: _isCounting
              ? Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: Center(
                      child: CountdownTimer(
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                        onFinished: () {
                          setState(() => _isCounting = !_isCounting);
                        },
                      ),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () async {
                    if (_emailController.text.isNotEmpty &&
                        emailRegExp.hasMatch(_emailController.text) &&
                        _emailError == null) {
                      setState(() {
                        _isSendingOtp = true;
                        _sendOtpError = null;
                      });
                      try {
                        await context
                            .read<AuthProvider>()
                            .signInWithEmailOtp(_emailController.text);
                      } catch (e) {
                        setState(() => _sendOtpError = e.toString());
                      }
                      setState(() {
                        _isCounting = true;
                        _isSendingOtp = false;
                      });
                    }
                  },
                  child: _isSendingOtp
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.send)),
        ),
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: () async {
          if (_emailController.text.isNotEmpty &&
              emailRegExp.hasMatch(_emailController.text) &&
              _emailError == null &&
              _otpController.text.isNotEmpty &&
              numericRegExp.hasMatch(_otpController.text)) {
            setState(() => _isLoggingIn = true);
            try {
              await context
                  .read<AuthProvider>()
                  .verifyEmailOtp(_emailController.text, _otpController.text);
              context.pop();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            } finally {
              setState(() => _isLoggingIn = false);
            }
          }
        },
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
        child: _isLoggingIn
            ? SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : Text(AppLocalizations.of(context)!.login),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fullScreen) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.login),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: _buildContent(),
          ),
        ),
      );
    }
    return AlertDialog(
      title: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: Text(AppLocalizations.of(context)!.login),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildContent(),
      ),
    );
  }
}
