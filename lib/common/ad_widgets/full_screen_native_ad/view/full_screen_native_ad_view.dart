import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lightroom_template/common/common_loader.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import '../bloc/full_screen_native_ad_bloc.dart';

class FullScreenNativeAdView extends StatelessWidget {
  final String? adId;
  const FullScreenNativeAdView({super.key, this.adId});

  static bool get _isUserSubscribed {
    return AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isUserSubscribed) {
      return const SizedBox();
    }

    final topPadding = MediaQuery.of(context).padding.top;
    const bottomPadding = 0.0;

    return BlocProvider(
      create: (context) => FullScreenNativeAdBloc()..add(LoadFullScreenNativeAdEvent(adId: adId)),
      child: BlocBuilder<FullScreenNativeAdBloc, FullScreenNativeAdState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Padding(
              padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
              child: Stack(
                children: [
                  if (state.isShowNative && state.nativeAd != null)
                    SizedBox.expand(
                      child: AdWidget(ad: state.nativeAd!),
                    )
                  else
                    const Center(child: CommonLoader()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
