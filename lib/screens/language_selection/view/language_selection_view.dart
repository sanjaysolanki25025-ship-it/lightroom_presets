import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lightroom_template/common/common_app_bar.dart';
import 'package:lightroom_template/common/common_button.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/data/helpers/ad_helper.dart';
import 'package:lightroom_template/routes/app_route_string.dart';
import 'package:lightroom_template/screens/language_selection/bloc/language_selection_bloc.dart';
import 'package:lightroom_template/screens/language_selection/widgets/language_item_widget.dart';

class LanguageSelectionView extends StatefulWidget {
  final bool isFromSettings;

  const LanguageSelectionView({
    super.key,
    this.isFromSettings = false,
  });

  @override
  State<LanguageSelectionView> createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<LanguageSelectionView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<LanguageSelectionBloc>().add(LanguageSelectionInitialEvent());
    AdHelper.precacheAppOpenAd();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    context.read<LanguageSelectionBloc>().add(
      ConfirmLanguageEvent(
        onCompleted: () {
          AdHelper.showAppOpenAd(
            onComplete: () {
              if (widget.isFromSettings && Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go(AppRoutesString.dashboardView);
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CommonAppBar(
          title: AppStrings.txtLanguageSelection,
          centerTitle: true,
          leading: widget.isFromSettings && Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: AppColors.whiteColor),
                  onPressed: () => context.pop(),
                )
              : const SizedBox.shrink(),
        ),
        body: Column(
          children: [
            SizedBox(height: 8.h),

            /// Header Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CommonTextWidget(
                  text: AppStrings.txtChooseYourPreferredLanguage,
                  textStyle: size14TextStyle(
                    textColor: AppColors.greyColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            /// Search Input Field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context
                        .read<LanguageSelectionBloc>()
                        .add(SearchLanguageEvent(value));
                  },
                  style: size14TextStyle(
                    textColor: AppColors.whiteColor,
                    fontWeight: FontWeight.w400,
                  ),
                  cursorColor: AppColors.primaryContainer,
                  decoration: InputDecoration(
                    hintText: AppStrings.txtSearchLanguage,
                    hintStyle: size14TextStyle(
                      textColor: AppColors.greyColor,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.greyColor,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.greyColor,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<LanguageSelectionBloc>()
                                  .add(SearchLanguageEvent(''));
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            /// Languages List
            Expanded(
              child: BlocBuilder<LanguageSelectionBloc, LanguageSelectionState>(
                builder: (context, state) {
                  if (state.filteredLanguages.isEmpty) {
                    return Center(
                      child: CommonTextWidget(
                        text: AppStrings.txtNoDataFound,
                        textStyle: size14TextStyle(
                          textColor: AppColors.greyColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 4.h,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.filteredLanguages.length,
                    itemBuilder: (context, index) {
                      final language = state.filteredLanguages[index];
                      final isSelected =
                          language.languageCode == state.selectedLanguageCode;

                      return LanguageItemWidget(
                        language: language,
                        isSelected: isSelected,
                        onTap: () {
                          context
                              .read<LanguageSelectionBloc>()
                              .add(SelectLanguageEvent(language.languageCode));
                        },
                      );
                    },
                  );
                },
              ),
            ),

            /// Bottom Action Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: CommonButton(
                width: double.infinity,
                text: widget.isFromSettings
                    ? AppStrings.txtConfirm
                    : AppStrings.txtContinue,
                height: 52.h,
                onTap: _onConfirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
