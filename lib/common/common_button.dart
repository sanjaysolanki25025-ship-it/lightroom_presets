import 'package:flutter/material.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';

enum CommonButtonStyle { gradient, outlined }

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final CommonButtonStyle style;
  final Widget? icon;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final double borderRadius;
  final List<Color>? gradientColors;
  final Color? borderColor;

  const CommonButton({
    super.key,
    required this.text,
    required this.onTap,
    this.style = CommonButtonStyle.gradient,
    this.icon,
    this.width,
    this.height,
    this.textStyle,
    this.borderRadius = 16,
    this.gradientColors,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (style == CommonButtonStyle.gradient) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
            gradientColors ??
                [
                  AppColors.primaryContainer,
                  AppColors.secondaryContainer,
                ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderColor != null
              ? Border.all(
                  color: borderColor!,
                  width: 1.2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: (gradientColors?.first ?? AppColors.primaryContainer)
                  .withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonTextWidget(
                text: text,
                textStyle:
                textStyle ??
                    size16TextStyle(
                      textColor: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 10),
                icon!,
              ],
            ],
          ),
        ),
      );
    } else {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            side: BorderSide(
              color: borderColor ?? AppColors.outlineVariant,
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonTextWidget(
                text: text,
                textStyle:
                textStyle ??
                    size16TextStyle(
                      textColor: AppColors.onSurface,
                    ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 10),
                icon!,
              ],
            ],
          ),
        ),
      );
    }
  }
}