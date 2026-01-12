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
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vx/auth/auth_bloc.dart';

import 'dart:io';

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
          return AdWidget(ad: ad);
        }, childCount: context.read<AdsProvider>().adsLen + 1),
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
        ));
  }
}

class AdWidget extends StatelessWidget {
  const AdWidget({super.key, required this.ad, this.maxHeight});
  final Ad ad;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: GestureDetector(
              onTap: () {
                launchUrl(Uri.parse(ad!.website));
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Image(
                  image: ad.imageProvider!,
                  fit: BoxFit.fitWidth,
                  width: ad.width.toDouble() * 2,
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
                SizedBox(width: 8),
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

// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class TestAdIdManager extends IAdIdManager {
//   const TestAdIdManager();

//   @override
//   AppAdIds? get admobAdIds => null;

//   @override
//   AppAdIds? get unityAdIds => AppAdIds(
//         appId: Platform.isAndroid ? '5923221' : '5923220',
//         bannerId: Platform.isAndroid ? 'Banner_Android' : 'Banner_iOS',
//         interstitialId:
//             Platform.isAndroid ? 'Interstitial_Android' : 'Interstitial_iOS',
//         rewardedId: Platform.isAndroid ? 'Rewarded_Android' : 'Rewarded_iOS',
//       );

//   @override
//   AppAdIds? get appLovinAdIds => null;

//   @override
//   AppAdIds? get fbAdIds => null;
// }

// class MyBannderAdWidget extends StatefulWidget {
//   MyBannderAdWidget({super.key, this.adSize = AdSize.fluid});

//   /// The requested size of the banner. Defaults to [AdSize.banner].
//   final AdSize adSize;

//   /// The AdMob ad unit to show.
//   ///
//   /// TODO: replace this test ad unit with your own ad unit
//   final String adUnitId = Platform.isAndroid
//       // Use this ad unit on Android...
//       ? androidAdUnitId
//       // ... or this one on iOS.
//       : iosAdUnitId;
//   @override
//   State<MyBannderAdWidget> createState() => _MyBannderAdWidgetState();
// }

// class _MyBannderAdWidgetState extends State<MyBannderAdWidget> {
//   BannerAd? _bannerAd;

//   @override
//   void initState() {
//     super.initState();
//     _loadAd();
//   }

//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SizedBox(
//         width: widget.adSize.width.toDouble(),
//         height: widget.adSize.height.toDouble(),
//         child: _bannerAd == null
//             // Nothing to render yet.
//             ? const SizedBox()
//             // The actual ad.
//             : AdWidget(ad: _bannerAd!),
//       ),
//     );
//   }

//   void _loadAd() {
//     final bannerAd = BannerAd(
//       size: widget.adSize,
//       adUnitId: widget.adUnitId,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         // Called when an ad is successfully received.
//         onAdLoaded: (ad) {
//           if (!mounted) {
//             ad.dispose();
//             return;
//           }
//           setState(() {
//             _bannerAd = ad as BannerAd;
//           });
//         },
//         // Called when an ad request failed.
//         onAdFailedToLoad: (ad, error) {
//           debugPrint('BannerAd failed to load: $error');
//           ad.dispose();
//         },
//       ),
//     );

//     // Start loading.
//     bannerAd.load();
//   }
// }

// const androidAdUnitId = 'ca-app-pub-5364901025165933/3926890225';
// const iosAdUnitId = 'ca-app-pub-5364901025165933/7390334969';

// class MyScrollingAdWidget extends StatefulWidget {
//   MyScrollingAdWidget({super.key, required this.width, required this.height});

//   /// The requested size of the banner. Defaults to [AdSize.banner].
//   final double width;
//   final double height;

//   /// The AdMob ad unit to show.
//   ///
//   /// TODO: replace this test ad unit with your own ad unit
//   final String adUnitId = Platform.isAndroid
//       // Use this ad unit on Android...
//       ? androidAdUnitId
//       // ... or this one on iOS.
//       : iosAdUnitId;
//   @override
//   State<MyScrollingAdWidget> createState() => _MyScrollingAdWidgetState();
// }

// class _MyScrollingAdWidgetState extends State<MyScrollingAdWidget> {
//   BannerAd? _bannerAd;
//   AdSize? _platformAdSize;
//   bool _isLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadAd();
//   }

//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isLoaded || _platformAdSize == null || _bannerAd == null) {
//       return const SizedBox();
//     }
//     return SafeArea(
//       child: SizedBox(
//         width: _platformAdSize!.width.toDouble(),
//         height: _platformAdSize!.height.toDouble(),
//         child: AdWidget(ad: _bannerAd!),
//       ),
//     );
//   }

//   Future<void> _loadAd() async {
//     await _bannerAd?.dispose();
//     setState(() {
//       _bannerAd = null;
//       _isLoaded = false;
//     });

//     AdSize size = AdSize.getInlineAdaptiveBannerAdSize(
//         widget.width.truncate(), widget.height.truncate());
//     final bannerAd = BannerAd(
//       size: size,
//       adUnitId: widget.adUnitId,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (Ad ad) async {
//           print('Inline adaptive banner loaded: ${ad.responseInfo}');

//           // After the ad is loaded, get the platform ad size and use it to
//           // update the height of the container. This is necessary because the
//           // height can change after the ad is loaded.
//           BannerAd bannerAd = (ad as BannerAd);
//           final AdSize? size = await bannerAd.getPlatformAdSize();
//           if (size == null) {
//             print('Error: getPlatformAdSize() returned null for $bannerAd');
//             return;
//           }

//           if (mounted) {
//             setState(() {
//               _bannerAd = bannerAd;
//               _isLoaded = true;
//               _platformAdSize = size;
//             });
//           }
//         },
//         onAdFailedToLoad: (Ad ad, LoadAdError error) {
//           print('Inline adaptive banner failedToLoad: $error');
//           ad.dispose();
//         },
//       ),
//     );

//     // Start loading.
//     await bannerAd.load();
//   }
// }

// class ControlAdsChangeNotifier extends ChangeNotifier {
//   final String adUnitId = Platform.isAndroid
//       // Use this ad unit on Android...
//       ? androidAdUnitId
//       // ... or this one on iOS.
//       : iosAdUnitId;
//   // int _scrollingAdWidth = 0;
//   // width will be 284 always
//   double? _controlAdHeight;
//   static const _controlAdWidth = 284;
//   // height will be 50 always
//   // int _topBannerAdWidth = 0;
//   // static const _topBannerAdHeight = 50;
//   // BannerAd? scrollingAd;
//   BannerAd? controlAd;
//   Timer? _timer;
//   late final StreamSubscription<AuthState> _authStateSubscription;
//   final AuthBloc _authBloc;

//   // BannerAd? topBannerAd;
//   ControlAdsChangeNotifier(this._authBloc) {
//     _authStateSubscription = _authBloc.stream.listen((state) {
//       if (state.isPro && _timer != null) {
//         _timer?.cancel();
//         _timer = null;
//       } else if (!state.isPro && _timer == null) {
//         _startTimer();
//       }
//     });
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
//       _load();
//     });
//     _load();
//   }

//   @override
//   void dispose() {
//     _authStateSubscription.cancel();
//     _timer?.cancel();
//     controlAd?.dispose();
//     super.dispose();
//   }

//   void _load() {
//     if (controlAd == null) {
//       print('loading control ad');
//       controlAd?.dispose();
//       controlAd = null;
//       controlAd = BannerAd(
//         size: AdSize(
//             width: _controlAdWidth, height: _controlAdHeight?.toInt() ?? 300),
//         adUnitId: adUnitId,
//         request: const AdRequest(),
//         listener: BannerAdListener(
//           // Called when an ad is successfully received.
//           onAdLoaded: (ad) {
//             ad.dispose();
//             return;
//           },
//           // Called when an ad request failed.
//           onAdFailedToLoad: (ad, error) {
//             debugPrint('BannerAd failed to load: $error');
//             ad.dispose();
//           },
//         ),
//       );
//       notifyListeners();
//     }
//   }

//   BannerAd? getControlAd(double height) {
//     print('getControlAd: $height');
//     if (_controlAdHeight != height) {
//       _controlAdHeight = height;
//       _load();
//     }
//     return controlAd;
//   }

  // void _reload() {
  //   if (scrollingAd != null && scrollingAd!.isMounted) {
  //     scrollingAd!.dispose();
  //     scrollingAd = null;
  //     scrollingAd = BannerAd(
  //       size: AdSize(width: _scrollingAdWidth, height: _controlAdHeight),
  //       adUnitId: adUnitId,
  //       request: const AdRequest(),
  //       listener: BannerAdListener(
  //         // Called when an ad is successfully received.
  //         onAdLoaded: (ad) {
  //           ad.dispose();
  //           return;
  //         },
  //         // Called when an ad request failed.
  //         onAdFailedToLoad: (ad, error) {
  //           debugPrint('BannerAd failed to load: $error');
  //           ad.dispose();
  //         },
  //       ),
  //     );
  //   }
  //   if (controlAd != null && controlAd!.isMounted) {
  //     controlAd!.dispose();
  //     controlAd = null;
  //   }
  //   if (topBannerAd != null && topBannerAd!.isMounted) {
  //     topBannerAd!.dispose();
  //     topBannerAd = null;
  //   }
  // }

  // void setScrollingAdWidth(int width) {
  //   if (_scrollingAdWidth == width) return;
  //   _scrollingAdWidth = width;
  //   scrollingAd?.dispose();
  //   scrollingAd = null;
  //   notifyListeners();
  // }

  // void setControlAdHeight(int height) {
  //   if (_controlAdHeight == height) return;
  //   _controlAdHeight = height;
  //   controlAd?.dispose();
  //   controlAd = null;
  //   notifyListeners();
  // }

  // void setTopBannerAdWidth(int width) {
  //   if (_topBannerAdWidth == width) return;
  //   _topBannerAdWidth = width;
  //   topBannerAd?.dispose();
  //   topBannerAd = null;
  //   notifyListeners();
  // }
// }
