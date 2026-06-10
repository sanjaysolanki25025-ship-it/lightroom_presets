import 'package:flutter/material.dart';
import 'package:lightroom_template/common/common_lottie_asset.dart';
import 'package:lightroom_template/common/common_network_image.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_image_string.dart';
import 'package:lightroom_template/core/constant/app_lotties_string.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/data/models/lr_preset_model.dart';
import 'package:lightroom_template/screens/home/widgets/common_action_button.dart';
import 'package:share_plus/share_plus.dart';

class ReelItemWidget extends StatelessWidget {
  final LrPresetModel entry;
  final VoidCallback onDownloadTap;
  final VoidCallback onOpenInLightroom;
  final VoidCallback onOpenDinoGame;
  final VoidCallback onFavouriteTap;
  final bool isFavourite;

  const ReelItemWidget({
    super.key,
    required this.entry,
    required this.onDownloadTap,
    required this.onOpenInLightroom,
    required this.onOpenDinoGame,
    required this.onFavouriteTap,
    required this.isFavourite,
  });

  @override
  Widget build(BuildContext context) {
    // final imageName = "test_dng.DNG";
    // String finalImageUrl = "${AppStrings.imageUrl}$imageName?index=$itemIndex";
    //
    // if (itemIndex >= 6) {
    //   finalImageUrl = finalImageUrl.replaceAll(RegExp(r'\.dng', caseSensitive: false), '.png');
    // }
    final String finalImageUrl =
        "${AppStrings.imageUrl}${entry.image.trim()}.png";
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2), width: 1),
          ),
          child: CommonNetworkImage(
            imageUrl: finalImageUrl,
            fit: BoxFit.contain,
          ),
        ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.transparent, AppColors.backgroundColor.withValues(alpha: 0.25)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Download Buttons (Using CommonActionButton)
        Positioned(
          right: 8,
          bottom: 120,
          child: Column(
            children: [
              entry.coin == 0
                  ? SizedBox.shrink()
                  : CommonActionButton(
                      assetPath: AppImagesString.imgPremium,
                      removeDecoration: true,
                      imageSize: 38,
                      fit: BoxFit.fill,
                    ),
              SBH10(),
              CommonActionButton(
                assetPath: AppImagesString.imgDino,
                onTap: onOpenDinoGame,
                imageSize: 45,
                removeDecoration: true,
                fit: BoxFit.fill,
              ),
              SBH10(),
              CommonActionButton(
                icon: isFavourite ? Icons.favorite_outlined : Icons.favorite_border_outlined,
                onTap: onFavouriteTap,
                imageSize: 20,
                iconColor: isFavourite ? AppColors.red : AppColors.whiteColor,
              ),
              SBH10(),
              CommonActionButton(assetPath: AppImagesString.imgLightroom, onTap: onOpenInLightroom),
              SBH10(),
              CommonActionButton(assetPath: AppImagesString.imgDownload, onTap: onDownloadTap),
              SBH10(),
              CommonActionButton(
                icon: Icons.share,
                onTap: () {
                  Share.share(AppStrings.txtShareMessage);
                },
                iconColor: AppColors.whiteColor,
                imageSize: 20,
              ),
            ],
          ),
        ),

        // Info Section
        Positioned(
          left: 16,
          bottom: 100,
          child: CommonTextWidget(
            text: entry.title,
            textStyle: size18TextStyle(textColor: AppColors.whiteColor, fontWeight: FontWeight.bold),
          ),

          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     CommonTextWidget(
          //       text: entry.name,
          //       textStyle: size18TextStyle(textColor: AppColors.whiteColor, fontWeight: FontWeight.bold),
          //     ),
          //     // SBH2(),
          //     // Wrap(
          //     //   spacing: 8,
          //     //   runSpacing: 8,
          //     //   children: List.generate(entry.categories.length, (index) {
          //     //     final category = entry.categories[index];
          //     //
          //     //     return Container(
          //     //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //     //       decoration: BoxDecoration(
          //     //         color: AppColors.surfaceContainerHighest.withValues(alpha: 0.6),
          //     //         borderRadius: BorderRadius.circular(12),
          //     //         border: Border.all(color: AppColors.outlineVariant, width: 1),
          //     //       ),
          //     //       child: CommonTextWidget(
          //     //         text: category,
          //     //         textStyle: size12TextStyle(
          //     //           textColor: AppColors.onSurfaceVariant,
          //     //           fontWeight: FontWeight.w500,
          //     //         ),
          //     //       ),
          //     //     );
          //     //   }),
          //     // ),
          //   ],
          // ),
        ),
      ],
    );
  }
}
