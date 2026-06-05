import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CommonLottieAsset extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? padding;
  final Color? backgroundColor;

  const CommonLottieAsset({
    super.key,
    required this.assetName,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Lottie.asset(
        assetName,
        fit: fit,
      ),
    );
  }
}