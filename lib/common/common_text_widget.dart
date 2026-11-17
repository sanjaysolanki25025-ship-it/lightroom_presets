import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_localization/flutter_localization.dart';

class CommonTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final int? maxLine;
  final double? height;
  final double? minFontSize;
  final bool? isUnderline;
  final bool? isStrikeThrough;
  final Color? underlineColor;

  const CommonTextWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.overflow,
    this.textAlign,
    this.maxLine,
    this.height,
    this.minFontSize,
    this.isUnderline,
    this.isStrikeThrough,
    this.underlineColor,
  });

  @override
  Widget build(BuildContext context) {
    String displayText = text;
    try {
      final translated = text.getString(context);
      if (translated.isNotEmpty && !translated.endsWith(' not found')) {
        displayText = translated;
      }
    } catch (_) {
      displayText = text;
    }

    return AutoSizeText(
      displayText,
      style: (textStyle ?? const TextStyle()).copyWith(
        height: height,
        decoration: isStrikeThrough == true
            ? TextDecoration.lineThrough
            : isUnderline == true
            ? TextDecoration.underline
            : null,
        decorationColor: underlineColor,
        decorationThickness: 2,
      ),
      overflow: overflow,
      textAlign: textAlign,
      maxLines: maxLine,
      minFontSize: (minFontSize ?? 12).floorToDouble(),
    );
  }
}
