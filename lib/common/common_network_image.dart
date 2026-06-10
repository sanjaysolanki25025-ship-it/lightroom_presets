import 'package:flutter/material.dart';
import 'package:lightroom_template/common/common_loader.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class CommonImageForOtherApps extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;
  final bool isShimmer;
  final double radius;

  const CommonImageForOtherApps({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.isShimmer = false,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        imageUrl,
        fit: fit,
        height: height,
        width: width,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          /// Shimmer Loader
          if (isShimmer) {
            return Shimmer.fromColors(
              baseColor: AppColors.lightBlackColor,
              highlightColor: AppColors.offBlackColor,
              child: Container(
                height: height ?? double.infinity,
                width: width ?? double.infinity,
                color: AppColors.whiteColor,
              ),
            );
          }

          /// Circular Loader
          return const Center(
            child: CommonLoader(
              size: 24,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            alignment: Alignment.center,
            color: AppColors.lightBlackColor,
            child: Icon(
              Icons.image_not_supported_rounded,
              size: 40,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          );
        },
      ),
    );
  }
}

// class CommonNetworkImage extends StatelessWidget {
//   final String imageUrl;
//   final BoxFit fit;
//   final double? height;
//   final double? width;
//   final bool isShimmer;
//
//   const CommonNetworkImage({
//     super.key,
//     required this.imageUrl,
//     this.fit = BoxFit.cover,
//     this.height,
//     this.width,
//     this.isShimmer = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (imageUrl.toLowerCase().contains('.dng')) {
//       return DngImagePreview(imageUrl: imageUrl, fit: fit, isShimmer: isShimmer);
//     }
//
//     return Image.network(
//       imageUrl,
//       fit: fit,
//       height: height,
//       width: width,
//       loadingBuilder: (context, child, loadingProgress) {
//         if (loadingProgress == null) return child;
//
//         /// Shimmer Loader
//         if (isShimmer) {
//           return Shimmer.fromColors(
//             baseColor: AppColors.lightBlackColor,
//             highlightColor: AppColors.offBlackColor,
//             child: Container(
//               height: height ?? double.infinity,
//               width: width ?? double.infinity,
//               color: AppColors.whiteColor,
//             ),
//           );
//         }
//
//         /// Circular Loader
//         return const Center(child: CommonLoader(size: 24, strokeWidth: 2));
//       },
//       errorBuilder: (context, error, stackTrace) {
//         return Center(
//           child: Icon(
//             Icons.image_not_supported_rounded,
//             size: 40,
//             color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
//           ),
//         );
//       },
//     );
//   }
// }

class CommonNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;
  final bool isShimmer;
  final bool isPreCache;

  const CommonNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.isShimmer = false,
    this.isPreCache = true,
  });

  @override
  Widget build(BuildContext context) {
    /// Direct image load
    return Image.network(
      imageUrl,
      fit: fit,
      height: height,
      width: width,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        if (isShimmer) {
          return Shimmer.fromColors(
            baseColor: AppColors.lightBlackColor,
            highlightColor: AppColors.offBlackColor,
            child: Container(
              height: height ?? double.infinity,
              width: width ?? double.infinity,
              color: AppColors.whiteColor,
            ),
          );
        }

        return const Center(
          child: CommonLoader(size: 24, strokeWidth: 2),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            Icons.image_not_supported_rounded,
            size: 40,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        );
      },
    );
  }
}