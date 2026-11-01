import 'dart:math' as math;
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/entities/components/boomerang/boomerang.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/entities/components/character/character.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/simulation/components/command_dispatcher/command_dispatcher.dart';
import 'components/navigation/navigation.dart';
import 'components/target_finder/target_finder.dart';

class BotAiController {
  final TargetFinder targetFinder;
  final BotNavigation navigation;
  final math.Random _random = math.Random();

  final Map<int, double> _throwCooldowns = {};

  BotAiController({
    this.targetFinder = const TargetFinder(),
    this.navigation = const BotNavigation(),
  });

  List<GameCommand> updateBots({
    required double dt,
    required List<Character> allCharacters,
    required List<Boomerang> activeBoomerangs,
  }) {
    final commands = <GameCommand>[];

    for (final bot in allCharacters) {
      if (bot.isPlayer || !bot.isAlive) continue;

      // Update throw cooldown
      final cd = (_throwCooldowns[bot.id] ?? 0.0) - dt;
      _throwCooldowns[bot.id] = cd > 0 ? cd : 0.0;

      // 1. Check if need to dodge
      final dodge = navigation.computeDodgeDirection(
        bot: bot,
        activeBoomerangs: activeBoomerangs,
      );

      if (dodge != null) {
        commands.add(MoveCommand(
          characterId: bot.id,
          moveX: dodge[0],
          moveZ: dodge[1],
        ));
        continue;
      }

      // 2. Find closest enemy
      final target = targetFinder.findClosestEnemy(
        bot: bot,
        allCharacters: allCharacters,
      );

      if (target == null) continue;

      final dx = target.x - bot.x;
      final dz = target.z - bot.z;
      final dist = math.sqrt(dx * dx + dz * dz);
      final aimAngle = math.atan2(dx, dz);

      // Turn towards enemy
      bot.yaw = aimAngle;

      // 3. Melee range check (< 1.8m)
      if (dist < 1.8) {
        commands.add(SlashCommand(characterId: bot.id));
      }

      // 4. Throw check: in range (2.5m to 14m), has boomerang, cooldown ready
      if (bot.hasBoomerang && dist > 2.5 && dist < 14.0 && _throwCooldowns[bot.id]! <= 0) {
        // Slight random spread for organic gameplay
        final spread = (_random.nextDouble() - 0.5) * 0.15;
        final finalAngle = aimAngle + spread;

        commands.add(ThrowBoomerangCommand(
          characterId: bot.id,
          targetVx: math.sin(finalAngle) * 20.0,
          targetVz: math.cos(finalAngle) * 20.0,
        ));
        _throwCooldowns[bot.id] = 1.2 + _random.nextDouble() * 0.8;
      }

      // 5. Movement
      double moveSpeedFactor = 1.0;
      if (dist > 5.0) {
        // Approach
        final approach = navigation.computeApproachDirection(
          startX: bot.x,
          startZ: bot.z,
          targetX: target.x,
          targetZ: target.z,
        );
        commands.add(MoveCommand(
          characterId: bot.id,
          moveX: approach[0] * moveSpeedFactor,
          moveZ: approach[1] * moveSpeedFactor,
        ));
      } else if (dist < 3.0) {
        // Back off slightly if waiting for boomerang
        final retreat = navigation.computeApproachDirection(
          startX: target.x,
          startZ: target.z,
          targetX: bot.x,
          targetZ: bot.z,
        );
        commands.add(MoveCommand(
          characterId: bot.id,
          moveX: retreat[0] * 0.6,
          moveZ: retreat[1] * 0.6,
        ));
      }
    }

    return commands;
  }
}
