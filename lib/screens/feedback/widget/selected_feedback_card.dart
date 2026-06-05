import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/screens/feedback/bloc/feedback_bloc.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_string.dart';

class SelectedFeedbackCard extends StatelessWidget {
  final String? isSelectedFeedback;

  const SelectedFeedbackCard({super.key, required this.isSelectedFeedback});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                selectedTileColor: AppColors.primary,
                title: CommonTextWidget(
                  text: AppStrings.txtFeedbackAndIssue,
                  textStyle: size12TextStyle(textColor: AppColors.whiteColor),
                ),
                value: AppStrings.txtFeedbackAndIssue,
                groupValue: isSelectedFeedback,
                onChanged: (value) {
                  context.read<FeedbackBloc>().add(SelectedFeedbackOptionEvent(selectedOption: value!));
                },
              ),
            ),

            Expanded(
              child: RadioListTile<String>(
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                title: CommonTextWidget(
                  text: AppStrings.txtContentIssue,
                  textStyle: size12TextStyle(textColor: AppColors.whiteColor),
                ),
                value: AppStrings.txtContentIssue,
                groupValue: isSelectedFeedback,
                onChanged: (value) {
                  context.read<FeedbackBloc>().add(SelectedFeedbackOptionEvent(selectedOption: value!));
                },
              ),
            ),
          ],
        ),

        RadioListTile<String>(
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          title: CommonTextWidget(
            text: AppStrings.txtFeatureIssue,
            textStyle: size12TextStyle(textColor: AppColors.whiteColor),
          ),
          value: AppStrings.txtFeatureIssue,
          groupValue: isSelectedFeedback,
          onChanged: (value) {
            context.read<FeedbackBloc>().add(SelectedFeedbackOptionEvent(selectedOption: value!));
          },
        ),
      ],
    );
  }
}
