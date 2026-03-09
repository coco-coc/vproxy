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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_common/common.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vx/common/extension.dart';
import 'package:vx/data/ads_provider.dart';
import 'package:vx/l10n/app_localizations.dart';

class Ads extends StatefulWidget {
  const Ads({super.key});

  @override
  State<Ads> createState() => _AdsState();
}

class _AdsState extends State<Ads> {
  final Map<int, Ad> _ads = {};
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 300), (timer) {
      setState(() {
        _ads.clear();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Ads build');

    final size = MediaQuery.of(context).size;
    late final int crossAxisCount;
    if (size.isCompact) {
      crossAxisCount = 1;
    } else if (size.isMedium) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    final adsProvider = context.watch<AdsProvider>();
    return SliverMasonryGrid(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index > adsProvider.adsLen) {
            return null;
          }
          if (index == adsProvider.adsLen) {
            return const AdWantedCard();
          }

          Ad? ad = _ads[index];
          if (ad == null) {
            ad = adsProvider.getNextAd();
            if (ad != null) {
              _ads[index] = ad;
            }
          }
          if (ad == null) {
            return const AdWantedCard();
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              return AdWidget(ad: ad!, maxWidth: constraints.maxWidth);
            },
          );
        }, childCount: context.read<AdsProvider>().adsLen + 1),
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
        ));
  }
}

class AdWidget extends StatelessWidget {
  const AdWidget({
    super.key,
    required this.ad,
    this.maxHeight,
    this.maxWidth,
  });
  final Ad ad;
  final double? maxHeight;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final fittedSize = ad.fittedSize(
      maxHeight: maxHeight,
      maxWidth: maxWidth,
    );
    return Stack(
      children: [
        SizedBox(
          width: fittedSize.width,
          height: fittedSize.height,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: GestureDetector(
              onTap: () {
                launchUrl(Uri.parse(ad.website));
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Image(
                  image: ad.imageProvider!,
                  fit: BoxFit.fill,
                  width: fittedSize.width,
                  height: fittedSize.height,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.85),
                  Theme.of(context).colorScheme.primary.withOpacity(0.65),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              AppLocalizations.of(context)!.ad,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const adWantedUrl = 'https://vx.5vnetwork.com/advertise';

class AdWantedCard extends StatelessWidget {
  const AdWantedCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (applePlatform) {
      return const SizedBox();
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => launchUrl(Uri.parse(adWantedUrl)),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: SizedBox(
            height: 80,
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign,
                    size: 24, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.adWanted,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ))),
      ),
    );
  }
}

class Promotion extends StatelessWidget {
  const Promotion({super.key, this.maxHeight, this.maxWidth});
  final double? maxHeight;
  final double? maxWidth;
  @override
  Widget build(BuildContext context) {
    final ad = context
        .watch<AdsProvider>()
        .getNextAd(maxHeight: maxHeight, maxWidth: maxWidth);
    if (ad == null) {
      return const SizedBox.shrink();
    }
    return AdWidget(ad: ad, maxHeight: maxHeight, maxWidth: maxWidth);
  }
}