import 'dart:math' as math;
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/arena/arena.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/entities/components/boomerang/boomerang.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/entities/components/character/character.dart';

class KillEvent {
  final int killerId;
  final int killerTeamId;
  final int victimId;
  final int victimTeamId;
  final String weapon; // 'boomerang' or 'slash'

  const KillEvent({
    required this.killerId,
    required this.killerTeamId,
    required this.victimId,
    required this.victimTeamId,
    required this.weapon,
  });
}

class CollisionSystem {
  const CollisionSystem();

  List<KillEvent> processCollisions({
    required Arena arena,
    required List<Character> characters,
    required List<Boomerang> boomerangs,
  }) {
    final kills = <KillEvent>[];

    // 1. Boomerang vs Obstacles (Wall Ricochet)
    for (final b in boomerangs) {
      if (!b.isActive) continue;

      final nextX = b.x + b.vx * 0.016;
      final nextZ = b.z + b.vz * 0.016;
      final bounce = arena.testBounce(b.x, b.z, nextX, nextZ, b.vx, b.vz);
      if (bounce != null) {
        b.onBounce(bounce[0], bounce[1]);
      }
    }

    // 2. Character Melee Slash vs Boomerang (Deflection / Parry)
    for (final char in characters) {
      if (!char.isAlive || char.slashActiveTimer <= 0) continue;

      for (final b in boomerangs) {
        if (!b.isActive || b.ownerId == char.id) continue;

        final dx = b.x - char.x;
        final dz = b.z - char.z;
        final dist = math.sqrt(dx * dx + dz * dz);

        if (dist < 1.8) {
          // Deflect boomerang away with high velocity!
          b.vx = -b.vx * 1.2;
          b.vz = -b.vz * 1.2;
          b.onBounce(b.vx, b.vz);
        }
      }
    }

    // 3. Boomerang vs Character (Slice Hit)
    for (final b in boomerangs) {
      if (!b.isActive) continue;

      for (final char in characters) {
        if (!char.isAlive) continue;
        // Don't hit owner right after throw (allow 0.25s clearance)
        if (char.id == b.ownerId && b.flightTime < 0.25) continue;
        // Friendly fire disabled by default
        if (char.teamId == b.teamId && char.id != b.ownerId) continue;

        final dx = char.x - b.x;
        final dz = char.z - b.z;
        final dist = math.sqrt(dx * dx + dz * dz);

        if (dist < 0.75) {
          // Hit!
          char.kill();
          b.isActive = false; // Destroy / drop boomerang

          kills.add(KillEvent(
            killerId: b.ownerId,
            killerTeamId: b.teamId,
            victimId: char.id,
            victimTeamId: char.teamId,
            weapon: 'boomerang',
          ));
          break;
        }
      }
    }

    // 4. Character Melee Slash vs Enemy Character
    for (final char in characters) {
      if (!char.isAlive || char.slashActiveTimer <= 0) continue;

      for (final target in characters) {
        if (!target.isAlive || target.id == char.id || target.teamId == char.teamId) {
          continue;
        }

        final dx = target.x - char.x;
        final dz = target.z - char.z;
        final dist = math.sqrt(dx * dx + dz * dz);

        if (dist < 1.6) {
          target.kill();
          kills.add(KillEvent(
            killerId: char.id,
            killerTeamId: char.teamId,
            victimId: target.id,
            victimTeamId: target.teamId,
            weapon: 'slash',
          ));
        }
      }
    }

    return kills;
  }
}
