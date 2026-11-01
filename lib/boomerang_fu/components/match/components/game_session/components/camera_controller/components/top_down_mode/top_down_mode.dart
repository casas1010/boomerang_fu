import 'package:flutter_game_engine/engine/engine.dart';

class TopDownMode {
  final double elevation;
  final double zOffset;
  final double pitchAngle;

  const TopDownMode({
    this.elevation = 22.0,
    this.zOffset = -14.0,
    this.pitchAngle = 1.05, // ~60 degrees tilt down
  });

  void updateCamera({
    required Camera camera,
    required double targetX,
    required double targetZ,
    double arenaRadius = 24.0,
  }) {
    // Smoothly anchor camera above and slightly behind player looking towards target
    final clampedX = targetX.clamp(-arenaRadius * 0.7, arenaRadius * 0.7);
    final clampedZ = targetZ.clamp(-arenaRadius * 0.7, arenaRadius * 0.7);

    camera.x = clampedX;
    camera.y = elevation;
    camera.z = clampedZ + zOffset;
    camera.yaw = 0.0; // Facing +Z
    camera.pitch = pitchAngle;
  }
}
