import 'dart:math' as math;
import 'dart:typed_data';

import '../../../../../engine/engine.dart';

/// Represents a patrolling red obstacle in the arena.
class Hazard {
  double x = -8.0;
  double z = 3.0;
  double direction = 1.0;
  final double speed;
  final double range;

  late final Mesh mesh;
  late final Texture texture;

  Hazard({
    this.speed = 6.0,
    this.range = 8.0,
  });

  void reset() {
    x = -range;
    direction = 1.0;
  }

  void load() {
    final b = MeshBuilder();
    b.addBox(-0.7, 0.0, -0.7, 0.7, 1.4, 0.7, tile: 1.0);
    mesh = b.build();

    // Crimson danger red
    texture = Texture(1, 1, Uint32List.fromList([Texture.rgb(220, 20, 60)]));
  }

  void update(double dt) {
    x += direction * speed * dt;
    if (x > range) {
      x = range;
      direction = -1.0;
    } else if (x < -range) {
      x = -range;
      direction = 1.0;
    }
  }

  /// Returns true if the player touches the hazard.
  bool checkCollision(double playerX, double playerZ, {double radius = 1.2}) {
    final dx = playerX - x;
    final dz = playerZ - z;
    return math.sqrt(dx * dx + dz * dz) < radius;
  }

  void render(Renderer renderer, Camera camera, double totalTime) {
    renderer.drawMesh(
      mesh,
      texture,
      camera,
      px: x,
      py: 0.0,
      pz: z,
      rotY: totalTime * 2.0, // Continuous rotation
    );
  }
}
