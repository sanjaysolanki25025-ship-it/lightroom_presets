import 'package:flutter/material.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/common/common_svg_image.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';

class SettingsItemWidget extends StatelessWidget {
  final IconData? icon;
  final String? assetIcon;
  final String title;
  final VoidCallback? onTap;

  const SettingsItemWidget({super.key, this.icon, this.assetIcon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            if (assetIcon != null)
              CommonSvgImage(assetName: assetIcon!, width: 24, height: 24, color: AppColors.onSurface)
            else if (icon != null)
              Icon(icon, color: AppColors.onSurface, size: 24),

            SBW15(),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonTextWidget(
                    text: title,
                    textStyle: size16TextStyle(fontWeight: FontWeight.w600, textColor: AppColors.whiteColor),
                  ),
                ],
              ),
            ),

            SBW10(),

            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.outlineVariant, size: 16),
          ],
        ),
      ),
    );
  }
}
