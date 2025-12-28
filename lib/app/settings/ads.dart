import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vx/app/control.dart';
import 'package:vx/app/settings/setting.dart';
import 'package:vx/common/common.dart';
import 'package:vx/data/ads_provider.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/widgets/ad.dart';

class PromotionPage extends StatelessWidget {
  const PromotionPage({super.key, this.showAppBar = true});
  final bool showAppBar;
  @override
  Widget build(BuildContext context) {
    final adsProvider = context.watch<AdsProvider>();
    return Scaffold(
      appBar: showAppBar
          ? getAdaptiveAppBar(
              context,
              Text(AppLocalizations.of(context)!.promote),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(builder: (ctx, c) {
          if (!adsProvider.running) {
            return FutureBuilder<List<Ad>>(
              future: adsProvider.fetchAllAds(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                return ListView.builder(
                    itemCount: snapshot.data!.length + 1,
                    itemBuilder: (context, index) {
                      if (index == snapshot.data!.length) {
                        return const AdWantedCard();
                      }
                      print(snapshot.data![index].toJson());
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AdWidget(
                            ad: snapshot.data![index],
                            maxHeight: c.maxHeight - 50),
                      );
                    });
              },
            );
          }

          return ListView.builder(
            itemCount: adsProvider.adsLen + 1,
            itemBuilder: (context, index) {
              if (index > adsProvider.adsLen) {
                return null;
              }
              if (index == adsProvider.adsLen) {
                return const AdWantedCard();
              }

              final ad = adsProvider.getNextAd();
              if (ad == null) {
                return const AdWantedCard();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AdWidget(
                    ad: adsProvider.getNextAd()!, maxHeight: c.maxHeight - 50),
              );
            },
          );
        }),
      ),
    );
  }
}
