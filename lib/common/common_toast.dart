import 'package:flutter/material.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';

class CommonToast {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryContainer, AppColors.secondaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.whiteColor, size: 20),
              const SBW10(),
              Expanded(
                child: CommonTextWidget(
                  text: message,
                  textStyle: size12TextStyle(
                    textColor: AppColors.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
