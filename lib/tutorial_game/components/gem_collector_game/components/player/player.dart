import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../../../../../engine/engine.dart';

/// Represents the player entity: owns position, rotation, mesh, texture,
/// and input-driven movement physics.
class Player {
  double x = 0.0;
  double z = 0.0;
  double yaw = 0.0;
  final double speed;

  late final Mesh mesh;
  late final Texture texture;

  Player({this.speed = 8.5});

  void load() {
    // 3D Box for the character
    final b = MeshBuilder();
    b.addBox(-0.6, 0.0, -0.6, 0.6, 1.2, 0.6, tile: 1.0);
    mesh = b.build();

    // Vibrant orange texture
    texture = Texture(1, 1, Uint32List.fromList([Texture.rgb(255, 140, 0)]));
  }

  void reset() {
    x = 0.0;
    z = 0.0;
    yaw = 0.0;
  }

  void update(double dt, Input input, double arenaLimit) {
    double moveX = 0.0;
    double moveZ = 0.0;

    // Keyboard keys (WASD + Arrows)
    moveX += input.axis(LogicalKeyboardKey.keyD, LogicalKeyboardKey.keyA);
    moveX += input.axis(LogicalKeyboardKey.arrowRight, LogicalKeyboardKey.arrowLeft);

    moveZ += input.axis(LogicalKeyboardKey.keyW, LogicalKeyboardKey.keyS);
    moveZ += input.axis(LogicalKeyboardKey.arrowUp, LogicalKeyboardKey.arrowDown);

    // Mobile touch joystick
    if (input.stickX != 0 || input.stickY != 0) {
      moveX += input.stickX;
      moveZ += input.stickY;
    }

    // Normalize diagonal movement
    final len = math.sqrt(moveX * moveX + moveZ * moveZ);
    if (len > 0.001) {
      moveX /= len;
      moveZ /= len;

      x += moveX * speed * dt;
      z += moveZ * speed * dt;

      // Face direction of movement
      yaw = math.atan2(moveX, moveZ);
    }

    // Arena boundary clamp
    x = x.clamp(-arenaLimit, arenaLimit);
    z = z.clamp(-arenaLimit, arenaLimit);
  }

  void render(Renderer renderer, Camera camera) {
    renderer.drawMesh(
      mesh,
      texture,
      camera,
      px: x,
      py: 0.0,
      pz: z,
      rotY: yaw,
    );
  }
}
