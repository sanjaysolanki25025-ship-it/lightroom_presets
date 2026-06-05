import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lightroom_template/common/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import 'package:lightroom_template/common/common_app_bar.dart';
import 'package:lightroom_template/common/common_button.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/common/common_text_field.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/common/common_toast.dart';
import 'package:lightroom_template/common/dialog/common_dialog.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/core/utils/app_validations.dart';
import 'package:lightroom_template/data/models/feedback_model.dart';
import 'package:lightroom_template/screens/feedback/widget/reference_image_card.dart';
import 'package:lightroom_template/screens/feedback/widget/selected_feedback_card.dart';
import '../bloc/feedback_bloc.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CommonAppBar(
            title: AppStrings.txtFeedbackCenter,
            actions: [

            ],
          ),
        ),
        body: BlocConsumer<FeedbackBloc, FeedbackState>(
          listener: (context, state) {
            if (state.status == FeedbackStatus.error) {
              CommonToast.show(context, state.errorMessage ?? AppStrings.txtSomethingWentWrong,);
            } else if (state.status == FeedbackStatus.submitLoading) {
              CommonDialog.loaderDialog(context: context);
            } else if (state.status == FeedbackStatus.submitLoaded) {
              CommonDialog.closeDialog(context: context);
              context.pop();
            } else if (state.status == FeedbackStatus.submitError) {
              CommonDialog.closeDialog(context: context);
              CommonToast.show(context, state.errorMessage ?? AppStrings.txtSomethingWentWrong,);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: context.read<FeedbackBloc>().formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SBH10(),

                    /// Title
                    CommonTextWidget(
                      text: AppStrings.txtWedLove,
                      textStyle: size26TextStyle(
                        textColor: AppColors.whiteColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SBH5(),
                    CommonTextWidget(
                      text: AppStrings.txtYourFeedback,
                      textStyle: size26TextStyle(
                        textColor: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SBH10(),

                    /// Subtitle
                    CommonTextWidget(
                      text: AppStrings
                          .txtWeValueYourFeedbackAndUseItToMakeTheAppBetter,
                      textStyle: size14TextStyle(
                        textColor: AppColors.whiteColor.withValues(alpha: 0.5),
                      ),
                    ),

                    SBH20(),

                    /// Radio Buttons
                    SelectedFeedbackCard(
                      isSelectedFeedback: state.selectedOption,
                    ),

                    SBH25(),

                    /// Feedback
                    CommonTextWidget(
                      text: AppStrings
                          .txtWhatTypeOfIssueAreYouFacingInThisCategory,
                      textStyle: size12TextStyle(
                        textColor: AppColors.whiteColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SBH5(),
                    CommonTextField(
                      controller: context
                          .read<FeedbackBloc>()
                          .facingIssueController,
                      hintText: AppStrings.feedback,
                      maxLines: 4,
                      validator: (value) {
                        return AppValidations.validateNotEmpty(
                          errorMessage: AppStrings.txtPleaseEnterThisField,
                          inputValue: value!,
                        );
                      },
                    ),

                    SBH15(),

                    /// Email
                    CommonTextWidget(
                      text: AppStrings.txtEmail,
                      textStyle: size12TextStyle(
                        textColor: AppColors.whiteColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SBH5(),
                    CommonTextField(
                      controller: context.read<FeedbackBloc>().emailController,
                      hintText: AppStrings.txtEnterYourEmail,
                      maxLines: 1,
                      validator: (value) {
                        if (value?.isEmpty == true) {
                          return AppValidations.validateNotEmpty(
                            errorMessage: AppStrings.txtPleaseEnterEmail,
                            inputValue: value!,
                          );
                        } else {
                          return AppValidations.validateEmail(
                            errorMessage: AppStrings.txtPleaseEnterValidEmail,
                            inputValue: value!,
                          );
                        }
                      },
                    ),
                    SBH10(),

                    /// Upload Label
                    CommonTextWidget(
                      text: AppStrings.txtUploadReferenceImage,
                      textStyle: size12TextStyle(
                        textColor: AppColors.whiteColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SBH5(),

                    /// reference image card
                    ReferenceImageCard(imageFile: state.imageFile),

                    /// Checkbox
                    SBH10(),
                    Row(
                      children: [
                        Checkbox(
                          value: state.isChecked,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            context.read<FeedbackBloc>().add(
                              CheckedTermConditionEvent(
                                isChecked: value ?? false,
                              ),
                            );
                          },
                        ),
                        SBW5(),
                        Expanded(
                          child: CommonTextWidget(
                            text: AppStrings
                                .txtIAcceptPrivacyPolicyAndTermsAndConditions,
                            textStyle: size12TextStyle(
                              textColor: AppColors.whiteColor.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SBH30(),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<FeedbackBloc, FeedbackState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonButton(
                  text: AppStrings.txtSubmit,
                  onTap: () {
                    if (context
                        .read<FeedbackBloc>()
                        .formKey
                        .currentState!
                        .validate()) {
                      final bloc = context.read<FeedbackBloc>();
                      final model = FeedbackModel(
                        email: bloc.emailController.text,
                        id: '',
                        feedBackCategory:
                        state.selectedOption ??
                            AppStrings.txtFeedbackAndIssue,
                        description: bloc.facingIssueController.text,
                        privacyPolicy: state.isChecked ?? false,
                        referenceImage: state.imageFile?.path,
                      );
                      bloc.add(SubmitFeedbackEvent(model: model));
                    }
                  },

                ),
                SBH5(),

                BlocProvider(
                  create: (context) => BannerAdBloc(),
                  child: BannerAdWidget(
                      adId: AppAdIdString.settingBannerAd
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
