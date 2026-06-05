import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/screens/feedback/bloc/feedback_bloc.dart';

class ReferenceImageCard extends StatelessWidget {
  final File? imageFile;

  const ReferenceImageCard({super.key, this.imageFile});

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageFile != null && imageFile!.path.isNotEmpty;
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Stack(
        children: [
          /// Main tap area
          Center(
            child: GestureDetector(
              onTap: () {
                if (!hasImage) {
                  context.read<FeedbackBloc>().add(SelectedUploadImageEvent());
                }
              },
              child: hasImage
                  ? Image.file(imageFile!, fit: BoxFit.contain)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          color: AppColors.primary,
                          size: 40,
                        ),
                        CommonTextWidget(
                          text: AppStrings.txtUploadIssueRelatedImage,
                          textStyle: size14TextStyle(
                            textColor: AppColors.greyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          /// Close button (no longer removes image)
          if (hasImage)
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  context.read<FeedbackBloc>().add(RemoveReferenceImageEvent());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.whiteColor,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
