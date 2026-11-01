import 'package:flutter_game_engine/engine/engine.dart';
import 'components/arena_builder/arena_builder.dart';
import 'components/arena_obstacles/arena_obstacles.dart';

class Arena {
  final List<ArenaObstacle> obstacles;
  final BuiltArenaGeometry geometry;

  const Arena({
    required this.obstacles,
    required this.geometry,
  });

  static Arena loadTemple() {
    final obstacles = ArenaObstacles.getTempleObstacles();
    final geometry = ArenaBuilder.build(obstacles);
    return Arena(obstacles: obstacles, geometry: geometry);
  }

  void render(Renderer renderer, Camera camera) {
    renderer.drawMesh(geometry.floorMesh, geometry.floorTexture, camera);
    renderer.drawMesh(geometry.wallsMesh, geometry.wallsTexture, camera);
    renderer.drawMesh(geometry.pillarsMesh, geometry.pillarsTexture, camera);
  }

  /// Collides a circle/point with all obstacles (axis-aligned sliding collision).
  List<double> collide(double x, double z, double dx, double dz, {double radius = 0.5}) {
    var nx = x + dx;
    // Check X move
    for (final obs in obstacles) {
      if (nx + radius > obs.x0 &&
          nx - radius < obs.x1 &&
          z + radius > obs.z0 &&
          z - radius < obs.z1) {
        nx = x; // Block X
        break;
      }
    }

    var finalZ = z + dz;
    // Check Z move
    for (final obs in obstacles) {
      if (nx + radius > obs.x0 &&
          nx - radius < obs.x1 &&
          finalZ + radius > obs.z0 &&
          finalZ - radius < obs.z1) {
        finalZ = z; // Block Z
        break;
      }
    }

    return [nx, finalZ];
  }

  /// Ray/sphere test against obstacle walls to bounce boomerangs.
  /// Returns [reflectedVx, reflectedVz] if a wall was hit, or null if clear.
  List<double>? testBounce(double x, double z, double nextX, double nextZ, double vx, double vz) {
    const r = 0.3;
    for (final obs in obstacles) {
      if (nextX + r > obs.x0 &&
          nextX - r < obs.x1 &&
          nextZ + r > obs.z0 &&
          nextZ - r < obs.z1) {
        // Determine whether horizontal or vertical wall face was struck
        final hitX = (x + r <= obs.x0 && nextX + r >= obs.x0) ||
            (x - r >= obs.x1 && nextX - r <= obs.x1);
        final hitZ = (z + r <= obs.z0 && nextZ + r >= obs.z0) ||
            (z - r >= obs.z1 && nextZ - r <= obs.z1);

        double newVx = vx;
        double newVz = vz;
        if (hitX) newVx = -vx;
        if (hitZ) newVz = -vz;
        if (!hitX && !hitZ) {
          // Corner hit
          newVx = -vx;
          newVz = -vz;
        }
        return [newVx, newVz];
      }
    }
    return null;
  }
}
