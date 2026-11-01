import 'dart:typed_data';
import 'package:flutter_game_engine/engine/engine.dart';
import '../arena_obstacles/arena_obstacles.dart';

class BuiltArenaGeometry {
  final Mesh floorMesh;
  final Mesh wallsMesh;
  final Mesh pillarsMesh;
  final Texture floorTexture;
  final Texture wallsTexture;
  final Texture pillarsTexture;

  const BuiltArenaGeometry({
    required this.floorMesh,
    required this.wallsMesh,
    required this.pillarsMesh,
    required this.floorTexture,
    required this.wallsTexture,
    required this.pillarsTexture,
  });
}

class ArenaBuilder {
  static BuiltArenaGeometry build(List<ArenaObstacle> obstacles) {
    const s = ArenaObstacles.halfSize;

    // 1. Build Floor
    final floorBuilder = MeshBuilder()
      ..addQuad(
        [-s, 0, -s],
        [-s, 0, s],
        [s, 0, s],
        [s, 0, -s],
        uRep: s / 2,
        vRep: s / 2,
      );

    // 2. Build Walls & Pillars
    final wallBuilder = MeshBuilder();
    final pillarBuilder = MeshBuilder();

    for (final obs in obstacles) {
      if (obs.type == 'pillar') {
        pillarBuilder.addBox(obs.x0, 0, obs.z0, obs.x1, obs.height, obs.z1);
      } else {
        wallBuilder.addBox(obs.x0, 0, obs.z0, obs.x1, obs.height, obs.z1);
      }
    }

    // Textures (Checkerboard warm tile for floor, clean dojo stone for walls, vibrant vermilion lacquer for pillars)
    final floorTex = _createCheckerTexture(
      color1: Texture.rgb(232, 224, 208), // Warm tatami/sandstone
      color2: Texture.rgb(212, 202, 184),
    );
    final wallTex = _createNoiseTexture(
      baseColor: Texture.rgb(115, 110, 130), // Clean dojo slate
    );
    final pillarTex = _createNoiseTexture(
      baseColor: Texture.rgb(215, 60, 50), // Vibrant Torii red lacquer
    );

    return BuiltArenaGeometry(
      floorMesh: floorBuilder.build(),
      wallsMesh: wallBuilder.build(),
      pillarsMesh: pillarBuilder.build(),
      floorTexture: floorTex,
      wallsTexture: wallTex,
      pillarsTexture: pillarTex,
    );
  }

  static Texture _createCheckerTexture({required int color1, required int color2}) {
    const size = 16;
    final pixels = Uint32List(size * size);
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final isAlt = ((x ~/ 4) + (y ~/ 4)) % 2 == 0;
        pixels[y * size + x] = isAlt ? color1 : color2;
      }
    }
    return Texture(size, size, pixels);
  }

  static Texture _createNoiseTexture({required int baseColor}) {
    const size = 8;
    final pixels = Uint32List(size * size);
    for (int i = 0; i < pixels.length; i++) {
      final variation = (i % 3) * 6;
      final r = ((baseColor) & 0xFF) + variation;
      final g = ((baseColor >> 8) & 0xFF) + variation;
      final b = ((baseColor >> 16) & 0xFF) + variation;
      pixels[i] = Texture.rgb(r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
    }
    return Texture(size, size, pixels);
  }
}
