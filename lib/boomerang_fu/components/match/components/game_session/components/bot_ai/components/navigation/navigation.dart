import 'dart:math' as math;
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/entities/components/boomerang/boomerang.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/entities/components/character/character.dart';

class BotNavigation {
  const BotNavigation();

  /// Computes (dx, dz) direction to dodge an incoming hostile boomerang.
  /// Returns null if no immediate threat.
  List<double>? computeDodgeDirection({
    required Character bot,
    required List<Boomerang> activeBoomerangs,
  }) {
    for (final b in activeBoomerangs) {
      if (!b.isActive || b.teamId == bot.teamId) continue;

      final dx = b.x - bot.x;
      final dz = b.z - bot.z;
      final dist = math.sqrt(dx * dx + dz * dz);

      // If boomerang is within danger radius (5 meters) and heading towards bot
      if (dist < 5.0) {
        final dot = b.vx * (-dx) + b.vz * (-dz);
        if (dot > 0) {
          // Dodge perpendicular to trajectory
          final perpX = -b.vz / (dist + 0.01);
          final perpZ = b.vx / (dist + 0.01);
          return [perpX, perpZ];
        }
      }
    }
    return null;
  }

  /// Computes (moveX, moveZ) direction towards a target coordinate.
  List<double> computeApproachDirection({
    required double startX,
    required double startZ,
    required double targetX,
    required double targetZ,
  }) {
    final dx = targetX - startX;
    final dz = targetZ - startZ;
    final dist = math.sqrt(dx * dx + dz * dz);

    if (dist < 0.2) return [0.0, 0.0];
    return [dx / dist, dz / dist];
  }
}
