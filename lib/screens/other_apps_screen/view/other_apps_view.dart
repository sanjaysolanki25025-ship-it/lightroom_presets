import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lightroom_template/common/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import 'package:lightroom_template/common/common_app_bar.dart';
import 'package:lightroom_template/common/common_error_text.dart';
import 'package:lightroom_template/common/common_network_image.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/common/common_toast.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_string.dart';
import '../../../core/utils/app_text_style.dart';
import '../../../core/utils/common_functions.dart';
import '../bloc/other_apps_bloc.dart';

class OtherAppsView extends StatefulWidget {
  const OtherAppsView({super.key});

  @override
  State<OtherAppsView> createState() => _OtherAppsViewState();
}

class _OtherAppsViewState extends State<OtherAppsView> {
  bool shouldShowAd(int rowIndex) {
    return rowIndex % 2 == 0;
  }

  @override
  void initState() {
    super.initState();
    context.read<OtherAppsBloc>().add(FetchOtherAppsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CommonAppBar(
            title: AppStrings.txtExploreOurOtherApps,
           actions: [],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: BlocListener<OtherAppsBloc, OtherAppsState>(
            listener: (context, state) {
              if (state.status == OtherAppsStatus.error) {
                CommonToast.show(context, state.errorMessage ?? AppStrings.txtSomethingWentWrong);
              }
            },
            child: BlocBuilder<OtherAppsBloc, OtherAppsState>(
              builder: (context, state) {
                if (state.status == OtherAppsStatus.loading || state.status == OtherAppsStatus.initial) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (state.status == OtherAppsStatus.error) {
                  return Center(
                    child: CommonErrorText(
                      errorMessage: state.errorMessage ?? AppStrings.txtSomethingWentWrong,
                    ),
                  );
                }

                if (state.apps.isEmpty) {
                  return Center(
                    child: CommonTextWidget(
                      text: AppStrings.txtNoDataFound,
                      textStyle: size14TextStyle(textColor: AppColors.greyColor, fontWeight: FontWeight.w600),
                    ),
                  );
                }
                final filteredApps = state.apps.where((app) {
                  if (Platform.isAndroid) {
                    return app.isAndroid == true;
                  } else {
                    return app.isAndroid == false;
                  }
                }).toList();
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: filteredApps.length,
                  itemBuilder: (context, index) {
                    final app = filteredApps[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          CommonFunction.launchUrlLink(app.appLink);
                          // if (Platform.isAndroid) {
                          //   CommonFunction.launchUrlLink(app.appLink);
                          // } else {
                          //   CommonFunction.launchUrlLink("${AppStrings.txtIosAppLink}${app.appLink}");
                          // }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.lightBlackColor),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: SizedBox(
                              width: 56,
                              height: 56,
                              child: app.appLogo.isEmpty
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.offBlackColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.apps, color: AppColors.whiteColor),
                                    )
                                  : CommonImageForOtherApps(
                                      imageUrl: app.appLogo,
                                      width: 56,
                                      height: 56,
                                      radius: 12,
                                    ),
                            ),
                            title: CommonTextWidget(
                              text: app.appName,
                              textStyle: size16TextStyle(
                                textColor: AppColors.whiteColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: CommonTextWidget(
                              text: Platform.isAndroid
                                  ? AppStrings.txtOpenInPlayStore
                                  : AppStrings.txtOpenInAppStore,
                              textStyle: size12TextStyle(
                                textColor: AppColors.greyColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: const Icon(Icons.open_in_new_rounded, color: AppColors.primary),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: BlocProvider(
          create: (context) => BannerAdBloc(),
          child: BannerAdWidget(adId: AppAdIdString.otherAppBannerAd),
        ),
      ),
    );
  }
}
