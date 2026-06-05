import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lightroom_template/data/models/dino_game_models/player_data.dart';
import 'package:lightroom_template/screens/dino_game/game/audio_manager.dart';
import 'package:lightroom_template/screens/dino_game/game/dino_run.dart';
import 'package:lightroom_template/screens/dino_game/widgets/hud.dart';
import 'package:lightroom_template/screens/dino_game/widgets/main_menu.dart';
import 'package:provider/provider.dart';
import 'package:lightroom_template/core/constants/dino_game_asset_strings.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/common/dialog/common_dialog.dart';
import 'package:lightroom_template/data/helpers/ad_helper.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';




// This represents the game over overlay,
// displayed with dino runs out of lives.
class GameOverMenu extends StatelessWidget {
  // An unique identified for this overlay.
  static const id = 'GameOverMenu';

  // Reference to parent game.
  final DinoRun game;

  const GameOverMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: game.playerData,
      child: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.black.withAlpha(100),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 100,
                ),
                child: Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    const CommonTextWidget(
                      text: AppStrings.txtGameOver,
                      textStyle: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontFamily: DinoGameAssets.fontAudiowide,
                      ),
                    ),

                    Selector<PlayerData, int>(
                      selector: (_, playerData) => playerData.currentScore,
                      builder: (_, score, __) {
                        return CommonTextWidget(
                          text: "${AppStrings.txtYouScore}$score",
                          textStyle: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontFamily: DinoGameAssets.fontAudiowide,
                          ),
                        );
                      },
                    ),
                    ElevatedButton(
                      child: const CommonTextWidget(
                        text: AppStrings.txtRestart,
                        textStyle: TextStyle(
                          fontSize: 30,
                          fontFamily: DinoGameAssets.fontAudiowide,
                        ),
                      ),


                      onPressed: () {
                        CommonDialog.loaderDialog(context: context);
                        AdHelper.showInterstitialAd(
                          adUnitId: AppAdIdString.restartDinoInterstitialAd,
                          onComplete: () {
                            CommonDialog.closeDialog(context: context);
                            game.reset();
                            game.startGamePlay();
                            game.overlays.remove(GameOverMenu.id);
                            game.overlays.add(Hud.id);
                            game.resumeEngine();
                            AudioManager.instance.resumeBgm();
                          },
                        );
                      },
                    ),
                    ElevatedButton(
                      child: const CommonTextWidget(
                        text: AppStrings.txtExit,
                        textStyle: TextStyle(
                          fontSize: 30,
                          fontFamily: DinoGameAssets.fontAudiowide,
                        ),
                      ),

                      onPressed: () {
                        game.reset();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
