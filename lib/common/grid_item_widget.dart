import 'package:flutter/material.dart';
import 'package:lightroom_template/common/common_network_image.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_image_string.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/data/models/lr_preset_model.dart';

class GridItemWidget extends StatelessWidget {
  final LrPresetModel entry;
  final VoidCallback onFavourite;
  final VoidCallback? onTap;

  const GridItemWidget({super.key, required this.entry, required this.onFavourite, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 260,
        decoration: BoxDecoration(color: AppColors.lightBlackColor, borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CommonNetworkImage(
              isPreCache: false,
              imageUrl: "${AppStrings.imageUrl}${entry.image.trim()}.png",
              fit: BoxFit.cover,
              isShimmer: true,
            ),

            /// Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.backgroundColor.withValues(alpha: 0.55),
                      AppColors.transparent,
                      AppColors.backgroundColor.withValues(alpha: 0.75),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            /// Premium Badge
            if (entry.coin > 0)
              Positioned(
                top: 10,
                left: 10,
                child: Image.asset(AppImagesString.imgPremium, height: 30, width: 30),
              ),

            /// Heart Icon
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: onFavourite,
                child: Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceContainerHighest.withValues(alpha: 0.6),
                  ),
                  child: Icon(
                    entry.isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: entry.isFavourite ? AppColors.red : AppColors.whiteColor.withValues(alpha: 0.8),
                    size: 22,
                  ),
                ),
              ),
            ),

            /// Title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CommonTextWidget(
                  text: entry.title,
                  textStyle: size14TextStyle(textColor: AppColors.whiteColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
