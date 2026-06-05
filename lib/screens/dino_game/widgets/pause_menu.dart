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



// This represents the pause menu overlay.
class PauseMenu extends StatelessWidget {
  // An unique identified for this overlay.
  static const id = 'PauseMenu';

  // Reference to parent game.
  final DinoRun game;

  const PauseMenu(this.game, {super.key});

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
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Selector<PlayerData, int>(
                        selector: (_, playerData) => playerData.currentScore,
                        builder: (_, score, __) {
                          return CommonTextWidget(
                            text: "${AppStrings.txtScore}$score",
                            textStyle: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontFamily: DinoGameAssets.fontAudiowide,
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        game.overlays.remove(PauseMenu.id);
                        game.overlays.add(Hud.id);
                        game.resumeEngine();
                        AudioManager.instance.resumeBgm();
                      },
                      child: const CommonTextWidget(
                        text: AppStrings.txtResume,
                        textStyle: TextStyle(
                          fontSize: 30,
                          fontFamily: DinoGameAssets.fontAudiowide,
                        ),
                      ),


                    ),
                    ElevatedButton(
                      onPressed: () {
                        game.reset();
                        game.startGamePlay();
                        game.overlays.remove(PauseMenu.id);
                        game.overlays.add(Hud.id);
                        game.resumeEngine();
                        AudioManager.instance.resumeBgm();
                      },
                      child: const CommonTextWidget(
                        text: AppStrings.txtRestart,
                        textStyle: TextStyle(
                          fontSize: 30,
                          fontFamily: DinoGameAssets.fontAudiowide,
                        ),
                      ),

                    ),
                    ElevatedButton(
                      onPressed: () {
                        game.reset();
                        Navigator.pop(context);
                      },
                      child: const CommonTextWidget(
                        text: AppStrings.txtExit,
                        textStyle: TextStyle(
                          fontSize: 30,
                          fontFamily: DinoGameAssets.fontAudiowide,
                        ),
                      ),

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
