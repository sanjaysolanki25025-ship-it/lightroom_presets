import 'package:flutter/material.dart';

class CommonImageAsset extends StatelessWidget {
  final String assetName;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double? borderRadius;
  final bool isCircle;

  const CommonImageAsset({
    super.key,
    required this.assetName,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetName,
      height: height,
      width: width,
      fit: fit,
    );

    if (isCircle) {
      return ClipOval(child: image);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: image,
    );
  }
}