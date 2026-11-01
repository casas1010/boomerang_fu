import 'package:flutter_game_engine/engine/engine.dart';

class FpvMode {
  const FpvMode();

  void updateCamera({
    required Camera camera,
    required double targetX,
    required double targetY,
    required double targetZ,
  }) {
    camera.x = targetX;
    camera.y = targetY; // Eye level
    camera.z = targetZ;
    // Yaw and pitch are driven directly by Camera.look (mouse/arrow keys)
  }
}
