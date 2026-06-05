import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lightroom_template/screens/dino_game/game/dino_run.dart';
import 'package:lightroom_template/screens/dino_game/widgets/game_over_menu.dart';
import 'package:lightroom_template/screens/dino_game/widgets/hud.dart';
import 'package:lightroom_template/screens/dino_game/widgets/main_menu.dart';
import 'package:lightroom_template/screens/dino_game/widgets/pause_menu.dart';
import 'package:lightroom_template/screens/dino_game/widgets/settings_menu.dart';

class DinoView extends StatefulWidget {
  const DinoView({super.key});

  @override
  State<DinoView> createState() => _DinoViewState();
}

class _DinoViewState extends State<DinoView> {
  @override
  void initState() {
    super.initState();
    // Set orientation to landscape when entering the game.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Reset orientation to portrait when exiting the game.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<DinoRun>.controlled(
        // This will display a loading bar until [DinoRun] completes
        // its onLoad method.
        loadingBuilder: (context) => const Center(
          child: SizedBox(width: 200, child: LinearProgressIndicator()),
        ),
        // Register all the overlays that will be used by this game.
        overlayBuilderMap: {
          MainMenu.id: (_, game) => MainMenu(game),
          PauseMenu.id: (_, game) => PauseMenu(game),
          Hud.id: (_, game) => Hud(game),
          GameOverMenu.id: (_, game) => GameOverMenu(game),
          SettingsMenu.id: (_, game) => SettingsMenu(game),
        },
        // By default MainMenu overlay will be active.
        initialActiveOverlays: const [MainMenu.id],
        gameFactory: () => DinoRun(
          // Use a fixed resolution camera to avoid manually
          // scaling and handling different screen sizes.
          camera: CameraComponent.withFixedResolution(
            width: 360,
            height: 180,
          ),
        ),
      ),
    );
  }
}
