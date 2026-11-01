import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_game_engine/engine/engine.dart';

class Boomerang {
  final int ownerId;
  final int teamId;

  double x;
  double y = 0.8;
  double z;

  double vx;
  double vz;

  double spin = 0.0;
  double flightTime = 0.0;
  int bouncesLeft = 3;
  bool isReturning = false;
  bool isActive = true;

  static Mesh? _boomerangMesh;
  static Texture? _boomerangTexture;

  Boomerang({
    required this.ownerId,
    required this.teamId,
    required this.x,
    required this.z,
    required this.vx,
    required this.vz,
  }) {
    _ensureMesh();
  }

  static void _ensureMesh() {
    if (_boomerangMesh != null) return;

    // Cross-blade spinning boomerang
    final b = MeshBuilder()
      // Blade 1
      ..addBox(-0.5, -0.05, -0.1, 0.5, 0.05, 0.1)
      // Blade 2
      ..addBox(-0.1, -0.05, -0.5, 0.1, 0.05, 0.5);
    _boomerangMesh = b.build();

    // Vibrant golden yellow/orange blade
    _boomerangTexture = Texture(1, 1, Uint32List.fromList([Texture.rgb(255, 190, 20)]));
  }

  void update(
    double dt, {
    required double ownerX,
    required double ownerZ,
    required bool ownerAlive,
  }) {
    if (!isActive) return;

    flightTime += dt;
    spin += dt * 20.0; // Rapid spin

    // After 0.65 seconds or when bouncing runs low, start curving back to owner
    if (flightTime > 0.65 || bouncesLeft <= 1) {
      isReturning = true;
    }

    if (isReturning && ownerAlive) {
      final dx = ownerX - x;
      final dz = ownerZ - z;
      final dist = math.sqrt(dx * dx + dz * dz);

      if (dist < 1.0) {
        // Caught by owner!
        isActive = false;
        return;
      }

      // Homing curve towards owner
      const returnSpeed = 16.0;
      final targetVx = (dx / dist) * returnSpeed;
      final targetVz = (dz / dist) * returnSpeed;

      // Smooth steer
      vx += (targetVx - vx) * dt * 5.0;
      vz += (targetVz - vz) * dt * 5.0;
    }

    x += vx * dt;
    z += vz * dt;

    // Bobbing height
    y = 0.8 + math.sin(flightTime * 8.0) * 0.1;

    // Timeout if lost or stuck
    if (flightTime > 5.0) {
      isActive = false;
    }
  }

  void onBounce(double newVx, double newVz) {
    vx = newVx * 0.95;
    vz = newVz * 0.95;
    bouncesLeft--;
    if (bouncesLeft <= 0) {
      isReturning = true;
    }
  }

  void render(Renderer renderer, Camera camera) {
    if (!isActive) return;

    // Draw the spinning boomerang
    renderer.drawMesh(
      _boomerangMesh!,
      _boomerangTexture!,
      camera,
      px: x,
      py: y,
      pz: z,
      rotY: spin,
    );
  }
}
