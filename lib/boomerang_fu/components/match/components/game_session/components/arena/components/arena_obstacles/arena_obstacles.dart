class ArenaObstacle {
  final double x0, z0, x1, z1;
  final double height;
  final String type; // 'wall', 'pillar', 'border'

  const ArenaObstacle({
    required this.x0,
    required this.z0,
    required this.x1,
    required this.z1,
    this.height = 3.0,
    this.type = 'wall',
  });
}

class ArenaObstacles {
  static const double halfSize = 18.0;
  static const double wallHeight = 3.5;
  static const double borderThickness = 0.8;

  /// Layout for The Stone Dojo Arena
  static List<ArenaObstacle> getTempleObstacles() {
    final list = <ArenaObstacle>[];
    const s = halfSize;
    const t = borderThickness;
    const h = wallHeight;

    // 4 Outer boundary walls
    list.add(const ArenaObstacle(x0: -s, z0: -s, x1: s, z1: -s + t, height: h, type: 'border'));
    list.add(const ArenaObstacle(x0: -s, z0: s - t, x1: s, z1: s, height: h, type: 'border'));
    list.add(const ArenaObstacle(x0: -s, z0: -s, x1: -s + t, z1: s, height: h, type: 'border'));
    list.add(const ArenaObstacle(x0: s - t, z0: -s, x1: s, z1: s, height: h, type: 'border'));

    // 4 Symmetrical inner pillars/blocks (great for ricochets)
    const pillarSize = 1.6;
    const offset = 7.0;

    for (final ox in [-offset, offset]) {
      for (final oz in [-offset, offset]) {
        list.add(ArenaObstacle(
          x0: ox - pillarSize,
          z0: oz - pillarSize,
          x1: ox + pillarSize,
          z1: oz + pillarSize,
          height: 3.0,
          type: 'pillar',
        ));
      }
    }

    // Central obstacle (low decorative shrine block with gap)
    list.add(const ArenaObstacle(x0: -2.0, z0: -2.0, x1: 2.0, z1: 2.0, height: 1.5, type: 'pillar'));

    // Corner ricochet walls
    list.add(const ArenaObstacle(x0: -12.0, z0: -2.0, x1: -10.5, z1: 2.0, height: 2.5, type: 'wall'));
    list.add(const ArenaObstacle(x0: 10.5, z0: -2.0, x1: 12.0, z1: 2.0, height: 2.5, type: 'wall'));

    return list;
  }
}
