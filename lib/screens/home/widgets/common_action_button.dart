import 'package:flutter/material.dart';
import 'package:lightroom_template/common/common_image_asset.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';

class CommonActionButton extends StatelessWidget {
  final String? assetPath;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool removeDecoration;
  final double imageSize;
  final BoxFit fit;
  final EdgeInsetsGeometry? padding;
  final Color? iconColor;

  const CommonActionButton({
    super.key,
    this.assetPath,
    this.icon,
    this.onTap,
    this.removeDecoration = false,
    this.imageSize = 28,
    this.fit = BoxFit.cover,
    this.padding,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        padding: removeDecoration
            ? EdgeInsets.zero
            : (padding ?? const EdgeInsets.all(12)),
        decoration: removeDecoration
            ? null
            : BoxDecoration(
          shape: BoxShape.circle,
          color:
          AppColors.surfaceContainerHighest.withValues(alpha: 0.6),
        ),
        child: assetPath != null
            ? CommonImageAsset(
          assetName: assetPath!,
          width: imageSize,
          height: imageSize,
          fit: fit,
          isCircle: true,
        )
            : Icon(
          icon,
          size: imageSize,
          color: iconColor ?? AppColors.whiteColor,
        ),
      ),
    );
  }
}