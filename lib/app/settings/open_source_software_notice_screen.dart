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
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vx/app/settings/setting.dart';
import 'package:vx/oss_licenses.dart';
import 'package:vx/widgets/text_divider.dart';

const String githubRepositoryUrl = 'https://github.com/5vnetwork/vx';

const List<(String, String)> openSourceSoftwareList = [
  ('v2ray-core', 'assets/oss/v2ray'),
  ('bloom', 'assets/oss/bloom'),
  ('hysteria', 'assets/oss/hys'),
  ('Xray-core', 'assets/oss/xray'),
  ('miekg/dns', 'assets/oss/miek'),
  ('protobuf', 'assets/oss/protobuf'),
  ('cuckoofilter', 'assets/oss/cuckoofilter'),
  ('tailscale', 'assets/oss/tailscale'),
  ('websocket', 'assets/oss/websocket'),
  ('utls', 'assets/oss/utls'),
  ('gopacket', 'assets/oss/gopacket'),
  ('sqlite', 'assets/oss/sqlite'),
  ('gorm', 'assets/oss/gorm'),
  ('quic-go', 'assets/oss/quic-go'),
  ('zerolog', 'assets/oss/zerolog'),
  ('wireguard', 'assets/oss/wireguard'),
  ('blake', 'assets/oss/blake3'),
  ('quic-go', 'assets/oss/quic-go'),
  ('gvisor', 'assets/oss/gvisor'),
  ('reality', 'assets/oss/reality'),
  ('gopsutil', 'assets/oss/gopsutil'),
  ('golang', 'assets/oss/golang'),
  ('go-proxyproto', 'assets/oss/go-proxyproto'),
];

class OpenSourceSoftwareNoticeScreen extends StatelessWidget {
  const OpenSourceSoftwareNoticeScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  Future<void> _showLicenseDialog(
      BuildContext context, String name, String licenseText) async {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    try {
      if (isLargeScreen) {
        // Show dialog on large screens
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Container(
              width: 600,
              height: 500,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SelectableText(
                        licenseText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // Show full screen on small screens
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => LicenseDetailScreen(
              name: name,
              licenseText: licenseText,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load license: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? getAdaptiveAppBar(context,
              Text(AppLocalizations.of(context)!.openSourceSoftwareNotice))
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Gap(10),
            FilledButton(
              onPressed: () {
                launchUrl(Uri.parse(githubRepositoryUrl));
              },
              child: Text(AppLocalizations.of(context)!.sourceCodeUrl),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  ...dependencies.map((package) => ListTile(
                        title: Text(package.name),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showLicenseDialog(
                            context,
                            package.name,
                            package.license ??
                                package.repository ??
                                package.homepage ??
                                ''),
                      )),
                  const TextDivider(text: '内核'),
                  ...openSourceSoftwareList.map((item) {
                    final (name, assetPath) = item;
                    return ListTile(
                      title: Text(name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        _showLicenseDialog(context, name,
                            await rootBundle.loadString(assetPath));
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LicenseDetailScreen extends StatelessWidget {
  final String name;
  final String licenseText;

  const LicenseDetailScreen({
    super.key,
    required this.name,
    required this.licenseText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          licenseText,
        ),
      ),
    );
  }
}
