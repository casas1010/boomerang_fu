import 'dart:typed_data';

import '../../../../../engine/engine.dart';

/// Manages the 3D geometry and textures for the tutorial arena (floor and walls).
class Arena {
  late final Mesh floorMesh;
  late final Mesh wallMesh;
  late final Texture floorTexture;
  late final Texture wallTexture;

  final double limit;
  final double wallHeight;

  Arena({
    this.limit = 12.0,
    this.wallHeight = 0.8,
  });

  /// Builds the floor quad, boundary walls, and textures procedurally.
  void load(Renderer renderer) {
    renderer.skyColor = Texture.rgb(135, 206, 250); // Fresh sky blue

    // 1. Floor: A large flat horizontal quad
    final floorBuilder = MeshBuilder();
    floorBuilder.addQuad(
      [-limit, 0.0, -limit],
      [limit, 0.0, -limit],
      [limit, 0.0, limit],
      [-limit, 0.0, limit],
      uRep: 6.0,
      vRep: 6.0,
    );
    floorMesh = floorBuilder.build();

    // 2. Perimeter Walls: 4 low boundary boxes around the edges
    final wallBuilder = MeshBuilder();
    const t = 0.5; // thickness
    // North wall
    wallBuilder.addBox(-limit, 0, limit - t, limit, wallHeight, limit, tile: 2.0);
    // South wall
    wallBuilder.addBox(-limit, 0, -limit, limit, wallHeight, -limit + t, tile: 2.0);
    // West wall
    wallBuilder.addBox(-limit, 0, -limit, -limit + t, wallHeight, limit, tile: 2.0);
    // East wall
    wallBuilder.addBox(limit - t, 0, -limit, limit, wallHeight, limit, tile: 2.0);
    wallMesh = wallBuilder.build();

    // 3. Textures
    floorTexture = _createCheckerboardTexture(
      color1: Texture.rgb(60, 179, 113), // Medium sea green
      color2: Texture.rgb(46, 139, 87),  // Dark sea green
    );
    wallTexture = Texture(1, 1, Uint32List.fromList([Texture.rgb(105, 105, 105)]));
  }

  void render(Renderer renderer, Camera camera) {
    renderer.drawMesh(floorMesh, floorTexture, camera);
    renderer.drawMesh(wallMesh, wallTexture, camera);
  }

  Texture _createCheckerboardTexture({required int color1, required int color2}) {
    const size = 16;
    final pixels = Uint32List(size * size);
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final isColor1 = ((x ~/ 8) + (y ~/ 8)) % 2 == 0;
        pixels[y * size + x] = isColor1 ? color1 : color2;
      }
    }
    return Texture(size, size, pixels);
  }
}
