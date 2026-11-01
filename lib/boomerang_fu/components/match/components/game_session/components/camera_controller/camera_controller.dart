import 'package:flutter_game_engine/engine/engine.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/entities/components/character/character.dart';
import 'components/fpv_mode/fpv_mode.dart';
import 'components/top_down_mode/top_down_mode.dart';

enum ViewMode { topDown, firstPerson }

class CameraController {
  final Camera camera;
  final FpvMode fpvMode;
  final TopDownMode topDownMode;

  ViewMode mode;

  CameraController({
    required this.camera,
    this.mode = ViewMode.topDown,
    this.fpvMode = const FpvMode(),
    this.topDownMode = const TopDownMode(),
  });

  void toggleViewMode({Character? player}) {
    if (mode == ViewMode.topDown) {
      mode = ViewMode.firstPerson;
      // Face parallel with the ground (pitch = 0.0)
      camera.pitch = 0.0;
      if (player != null) {
        camera.yaw = player.yaw;
        player.pitch = 0.0;
      }
    } else {
      mode = ViewMode.topDown;
      camera.pitch = topDownMode.pitchAngle;
      camera.yaw = 0.0;
    }
  }

  void update({
    required double playerX,
    required double playerY,
    required double playerZ,
  }) {
    if (mode == ViewMode.firstPerson) {
      fpvMode.updateCamera(
        camera: camera,
        targetX: playerX,
        targetY: playerY + 1.2,
        targetZ: playerZ,
      );
    } else {
      topDownMode.updateCamera(
        camera: camera,
        targetX: playerX,
        targetZ: playerZ,
      );
    }
  }
}
