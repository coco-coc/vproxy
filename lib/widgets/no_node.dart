import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vx/app/outbound/add.dart';
import 'package:gap/gap.dart';
import 'package:vx/app/settings/contact.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/main.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.sourceCodeAvailable,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const Gap(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
                onPressed: () {
                  launchUrl(Uri.parse('https://github.com/5vnetwork/vx'));
                },
                icon: SvgPicture.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/icons/github-mark-white.svg'
                        : 'assets/icons/github-mark.svg',
                    width: 18,
                    height: 18),
                label: Text(
                  AppLocalizations.of(context)!.vxSourceCode,
                )),
            const Gap(10),
            OutlinedButton.icon(
                onPressed: () {
                  launchUrl(Uri.parse('https://github.com/5vnetwork/vx-core'));
                },
                icon: SvgPicture.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/icons/github-mark-white.svg'
                        : 'assets/icons/github-mark.svg',
                    width: 18,
                    height: 18),
                label: Text(
                  AppLocalizations.of(context)!.vxCoreSourceCode,
                )),
          ],
        ),
        const Gap(10),
        Text(
          AppLocalizations.of(context)!.howToUseVX,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const Gap(10),
        OutlinedButton.icon(
            onPressed: () {
              launchUrl(Uri.parse('https://www.youtube.com/@vproxy5vnetwork'));
            },
            icon:
                Image.asset('assets/icons/youtube.png', width: 24, height: 24),
            label: const Text(
              'VX代理客户端',
            )),
        const Gap(10),
        Text(
          AppLocalizations.of(context)!.contactUsFreely,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const Gap(10),
        Wrap(
          spacing: 10,
          runSpacing: 5,
          children: [
            OutlinedButton.icon(
                onPressed: () {
                  launchUrl(Uri.parse('https://x.com/vproxy5vnetwork'));
                },
                icon: Image.asset(
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? 'assets/icons/x_logo_white.png'
                      : 'assets/icons/x_logo_black.png',
                  width: 16,
                  height: 16,
                ),
                label: Text(' X')),
            OutlinedButton.icon(
              label: Text(AppLocalizations.of(context)!.email),
              onPressed: () {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: email,
                );
                launchUrl(emailLaunchUri);
              },
              icon: const Icon(Icons.email_outlined),
            ),
            OutlinedButton.icon(
                onPressed: () {
                  launchUrl(Uri.parse('https://t.me/vproxygroup'));
                },
                icon: Image.asset('assets/icons/telegram_icon.png',
                    width: 20, height: 20),
                label: Text(AppLocalizations.of(context)!.telegram)),
          ],
        )
      ],
    );
  }
}
