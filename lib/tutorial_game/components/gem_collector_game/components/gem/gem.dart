import 'dart:math' as math;
import 'dart:typed_data';

import '../../../../../engine/engine.dart';

/// Single collectible gem in 3D space.
class GemItem {
  final double x;
  final double z;
  final double bobPhase;
  bool collected;
  double spinAngle;

  GemItem({
    required this.x,
    required this.z,
    required this.bobPhase,
    this.collected = false,
    this.spinAngle = 0.0,
  });
}

/// Manages all collectible gems: mesh, texture, spinning animation, and collection logic.
class GemManager {
  static const List<List<double>> defaultLocations = [
    [-6.0, -6.0],
    [0.0, -7.0],
    [6.0, -6.0],
    [-7.0, 0.0],
    [7.0, 0.0],
    [-6.0, 6.0],
    [0.0, 7.0],
    [6.0, 6.0],
  ];

  final List<GemItem> gems = [];
  late final Mesh mesh;
  late final Texture texture;

  int get count => gems.length;
  int get collectedCount => gems.where((g) => g.collected).length;
  bool get allCollected => collectedCount == gems.length && gems.isNotEmpty;

  GemManager() {
    reset();
  }

  void reset() {
    gems.clear();
    for (int i = 0; i < defaultLocations.length; i++) {
      gems.add(GemItem(
        x: defaultLocations[i][0],
        z: defaultLocations[i][1],
        bobPhase: i * 0.8,
      ));
    }
  }

  void load() {
    mesh = _buildDiamondMesh();
    texture = Texture(1, 1, Uint32List.fromList([Texture.rgb(255, 215, 0)])); // Shiny gold
  }

  void update(double dt) {
    for (final gem in gems) {
      if (!gem.collected) {
        gem.spinAngle += dt * 3.0; // Spin speed
      }
    }
  }

  /// Checks if player is close enough to collect any gem. Returns true if a gem was collected.
  bool checkCollisions(double playerX, double playerZ, {double radius = 1.2}) {
    bool collectedAny = false;
    for (final gem in gems) {
      if (!gem.collected) {
        final dx = playerX - gem.x;
        final dz = playerZ - gem.z;
        final dist = math.sqrt(dx * dx + dz * dz);
        if (dist < radius) {
          gem.collected = true;
          collectedAny = true;
        }
      }
    }
    return collectedAny;
  }

  void render(Renderer renderer, Camera camera, double totalTime) {
    for (final gem in gems) {
      if (!gem.collected) {
        final bobY = 0.8 + math.sin(totalTime * 3.5 + gem.bobPhase) * 0.2;
        renderer.drawMesh(
          mesh,
          texture,
          camera,
          px: gem.x,
          py: bobY,
          pz: gem.z,
          rotY: gem.spinAngle,
          scale: 0.8,
        );
      }
    }
  }

  Mesh _buildDiamondMesh() {
    final b = MeshBuilder();
    const r = 0.5;
    const h = 0.7;

    final top = b.addVertex(0, h, 0, 0.5, 1.0);
    final p0 = b.addVertex(r, 0, 0, 1.0, 0.5);
    final p1 = b.addVertex(0, 0, r, 0.5, 0.0);
    final p2 = b.addVertex(-r, 0, 0, 0.0, 0.5);
    final p3 = b.addVertex(0, 0, -r, 0.5, 1.0);
    final bottom = b.addVertex(0, -h, 0, 0.5, 0.0);

    // Top pyramid
    b.addTriangle(top, p1, p0);
    b.addTriangle(top, p2, p1);
    b.addTriangle(top, p3, p2);
    b.addTriangle(top, p0, p3);

    // Bottom pyramid
    b.addTriangle(bottom, p0, p1);
    b.addTriangle(bottom, p1, p2);
    b.addTriangle(bottom, p2, p3);
    b.addTriangle(bottom, p3, p0);

    return b.build();
  }
}
