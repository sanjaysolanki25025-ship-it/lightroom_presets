import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightroom_template/common/common_loader.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/screens/dng_image_preview/bloc/dng_conversion_bloc.dart';
import 'package:shimmer/shimmer.dart';

class DngImagePreview extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final bool isShimmer;

  const DngImagePreview({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.isShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DngConversionBloc()..add(ConvertDngEvent(imageUrl)),
      child: BlocBuilder<DngConversionBloc, DngConversionState>(
        builder: (context, state) {
          if (state.status == DngConversionStatus.loading) {
            /// Shimmer Loader
            if (isShimmer) {
              return Shimmer.fromColors(
                baseColor: AppColors.lightBlackColor,
                highlightColor: AppColors.offBlackColor,
                child: Container(color: AppColors.whiteColor),
              );
            }

            /// Circular Loader
            return Container(
              color: AppColors.surfaceContainer,
              child: const Center(child: CommonLoader(size: 30, strokeWidth: 3)),
            );
          }

          if (state.status == DngConversionStatus.FailureModel) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_rounded,
                    size: 80,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.2),
                  ),
                  SBH5(),
                  Text(
                    state.error ?? AppStrings.txtFailedToLoadImage,
                    style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 12),
                  ),
                ],
              ),
            );
          }

          if (state.status == DngConversionStatus.success && state.bytes != null) {
            return Image.memory(state.bytes!, fit: fit, gaplessPlayback: true);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
