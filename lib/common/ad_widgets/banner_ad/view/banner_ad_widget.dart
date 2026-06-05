import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:lightroom_template/core/utils/banner_ad_manager.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';

class BannerAdWidget extends StatefulWidget {
  final String adId;

  const BannerAdWidget({super.key, required this.adId});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _didLoadOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isSubscribed =
        AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;
    if (isSubscribed) return;

    if (!_didLoadOnce) {
      _didLoadOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadBannerAd();
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() async {
    final isSubscribed =
        AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;
    if (isSubscribed) return;

    _bannerAd = BannerAdManager().getBannerAd(widget.adId);

    if (_bannerAd != null) {
      // Only use the cached ad if it has actually finished loading
      if (_bannerAd!.responseInfo != null && mounted) {
        context.read<BannerAdBloc>().add(
          ShowBannerAdEvent(isShowBanner: true, bannerAd: _bannerAd!),
        );
      }
      return;
    }

    final AdSize? adaptiveSize =
    await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());

    _bannerAd = BannerAd(
      adUnitId: widget.adId,
      request: const AdRequest(),
      size: adaptiveSize ?? AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            context.read<BannerAdBloc>().add(
              ShowBannerAdEvent(
                isShowBanner: true,
                bannerAd: ad as BannerAd,
              ),
            );
          }
          BannerAdManager().preCacheAd(widget.adId);
        },
        onAdFailedToLoad: (ad, error) {
          if (mounted) {
            context.read<BannerAdBloc>().add(
              ShowBannerAdEvent(isShowBanner: false, bannerAd: null),
            );
          }
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    final isSubscribed =
        AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;

    if (isSubscribed) return const SizedBox();

    return BlocBuilder<BannerAdBloc, BannerAdState>(
      builder: (context, state) {
        final ad = state.bannerAd;

        // Guard: only show AdWidget when the ad is fully loaded
        if (state.isShowBanner == true &&
            ad != null &&
            ad.responseInfo != null) {
          return SizedBox(
            height: ad.size.height.toDouble(),
            width: double.infinity,
            child: AdWidget(ad: ad),
          );
        }

        return const SizedBox();
      },
    );
  }
}