import 'package:flutter/material.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:lightroom_template/data/models/dino_game_models/player_data.dart';
import 'package:lightroom_template/screens/dino_game/game/audio_manager.dart';
import 'package:lightroom_template/screens/dino_game/game/dino_run.dart';
import 'package:lightroom_template/screens/dino_game/widgets/pause_menu.dart';
import 'package:provider/provider.dart';
import 'package:lightroom_template/core/constants/dino_game_asset_strings.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_string.dart';

// This represents the head up display in game.
// It consists of current score, high score, and a pause button.
class Hud extends StatelessWidget {
  // An unique identified for this overlay.
  static const id = 'Hud';

  // Reference to parent game.
  final DinoRun game;

  const Hud(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: game.playerData,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Selector<PlayerData, int>(
                  selector: (_, playerData) => playerData.currentScore,
                  builder: (_, score, __) {
                    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
                    final newCoinTotal = totalCoin + score;
                    AppPreferences().setInt(AppPreferences.coin, newCoinTotal);
                    return CommonTextWidget(
                      text: "${AppStrings.txtScore}$score",
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: DinoGameAssets.fontAudiowide,
                      ),
                    );
                  },
                ),
                Selector<PlayerData, int>(
                  selector: (_, playerData) => playerData.highScore,
                  builder: (_, highScore, __) {
                    return CommonTextWidget(
                      text: "${AppStrings.txtHigh}$highScore",
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontFamily: DinoGameAssets.fontAudiowide,
                      ),
                    );
                  },
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                game.overlays.remove(Hud.id);
                game.overlays.add(PauseMenu.id);
                game.pauseEngine();
                AudioManager.instance.pauseBgm();
              },
              child: const Icon(Icons.pause, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
