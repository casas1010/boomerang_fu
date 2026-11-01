import 'dart:math' as math;
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/arena/arena.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/entities/components/boomerang/boomerang.dart';
import 'components/collision_system/collision_system.dart';
import 'components/command_dispatcher/command_dispatcher.dart';
import 'components/entity_manager/entity_manager.dart';

class MatchSimulation {
  final Arena arena;
  final EntityManager entityManager;
  final CommandDispatcher commandDispatcher;
  final CollisionSystem collisionSystem;

  final List<KillEvent> recentKills = [];

  MatchSimulation({
    required this.arena,
    required this.entityManager,
    required this.commandDispatcher,
    this.collisionSystem = const CollisionSystem(),
  });

  void step(double dt) {
    // 1. Process all incoming commands
    final commands = commandDispatcher.drain();
    for (final cmd in commands) {
      _applyCommand(cmd, dt);
    }

    // 2. Update characters
    for (final char in entityManager.characters) {
      char.update(dt);
    }

    // 3. Update boomerangs
    for (final b in entityManager.boomerangs) {
      final owner = entityManager.findCharacter(b.ownerId);
      b.update(
        dt,
        ownerX: owner?.x ?? b.x,
        ownerZ: owner?.z ?? b.z,
        ownerAlive: owner?.isAlive ?? false,
      );
    }

    // 4. Collision processing
    final kills = collisionSystem.processCollisions(
      arena: arena,
      characters: entityManager.characters,
      boomerangs: entityManager.boomerangs,
    );

    if (kills.isNotEmpty) {
      recentKills.addAll(kills);
      entityManager.handleKills(kills);
    }

    // 5. Lifecycle & Respawns
    entityManager.cleanInactiveBoomerangs();
    entityManager.checkRespawns();
  }

  void _applyCommand(GameCommand cmd, double dt) {
    final char = entityManager.findCharacter(cmd.characterId);
    if (char == null || !char.isAlive) return;

    if (cmd is MoveCommand) {
      const speed = 7.0;
      final len = math.sqrt(cmd.moveX * cmd.moveX + cmd.moveZ * cmd.moveZ);
      if (len > 0.01) {
        final normX = cmd.moveX / len;
        final normZ = cmd.moveZ / len;
        final dx = normX * speed * dt;
        final dz = normZ * speed * dt;

        // Arena collision sliding
        final newPos = arena.collide(char.x, char.z, dx, dz, radius: 0.5);
        char.x = newPos[0];
        char.z = newPos[1];

        // Face movement direction only if allowed (in FPV, camera look drives yaw)
        if (cmd.updateYaw) {
          char.yaw = math.atan2(normX, normZ);
        }
      }
    } else if (cmd is ThrowBoomerangCommand) {
      if (char.hasBoomerang) {
        char.hasBoomerang = false;
        final b = Boomerang(
          ownerId: char.id,
          teamId: char.teamId,
          x: char.x + math.sin(char.yaw) * 0.7,
          z: char.z + math.cos(char.yaw) * 0.7,
          vx: cmd.targetVx,
          vz: cmd.targetVz,
        );
        entityManager.boomerangs.add(b);
      }
    } else if (cmd is SlashCommand) {
      if (char.slashCooldown <= 0) {
        char.slashCooldown = 0.45;
        char.slashActiveTimer = 0.2; // 200ms active parry/slash window
      }
    } else if (cmd is DashCommand) {
      const dashDistance = 3.5;
      final newPos = arena.collide(
        char.x,
        char.z,
        cmd.dirX * dashDistance,
        cmd.dirZ * dashDistance,
        radius: 0.5,
      );
      char.x = newPos[0];
      char.z = newPos[1];
    }
  }
}
