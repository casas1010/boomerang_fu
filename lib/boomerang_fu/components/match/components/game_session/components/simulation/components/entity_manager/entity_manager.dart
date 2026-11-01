import 'dart:math' as math;
import 'package:flutter_game_engine/boomerang_fu/components/match_config/match_config.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/entities/components/boomerang/boomerang.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/entities/components/character/character.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/simulation/components/collision_system/collision_system.dart';

class EntityManager {
  final MatchConfig config;
  final List<Character> characters = [];
  final List<Boomerang> boomerangs = [];
  final Map<int, int> teamScores = {};

  final math.Random _random = math.Random();

  EntityManager({required this.config}) {
    _initializeTeamsAndCharacters();
  }

  void _initializeTeamsAndCharacters() {
    characters.clear();
    boomerangs.clear();
    teamScores.clear();

    for (final team in config.activeTeams) {
      teamScores[team.id] = 0;
    }

    int nextId = 0;

    // Symmetrical corner spawn points around the arena (size 18)
    final spawnPoints = [
      [-10.0, -10.0],
      [10.0, 10.0],
      [-10.0, 10.0],
      [10.0, -10.0],
    ];

    for (int t = 0; t < config.numGroups; t++) {
      final team = config.activeTeams[t];
      final baseSpawn = spawnPoints[t % spawnPoints.length];

      // Slot 1: Player if this is player's team, else Bot 1
      final isPlayerSlot = (t == config.playerTeamIndex);
      final char1 = Character(
        id: nextId++,
        name: isPlayerSlot ? 'Player' : '${team.name} Bot 1',
        teamId: team.id,
        isPlayer: isPlayerSlot,
      );
      char1.spawnAt(baseSpawn[0], baseSpawn[1], math.atan2(-baseSpawn[0], -baseSpawn[1]));
      characters.add(char1);

      // Subsequent bot allies
      for (int b = 0; b < config.botsPerGroup; b++) {
        final botChar = Character(
          id: nextId++,
          name: '${team.name} Bot ${b + 2}',
          teamId: team.id,
          isPlayer: false,
        );
        final spreadX = baseSpawn[0] + (b + 1) * 2.0 * (baseSpawn[0] > 0 ? -1 : 1);
        final spreadZ = baseSpawn[1];
        botChar.spawnAt(spreadX, spreadZ, math.atan2(-baseSpawn[0], -baseSpawn[1]));
        characters.add(botChar);
      }
    }
  }

  Character? get player => characters.firstWhere(
        (c) => c.isPlayer,
        orElse: () => characters.first,
      );

  Character? findCharacter(int id) {
    for (final c in characters) {
      if (c.id == id) return c;
    }
    return null;
  }

  void handleKills(List<KillEvent> kills) {
    for (final k in kills) {
      teamScores[k.killerTeamId] = (teamScores[k.killerTeamId] ?? 0) + 1;
    }
  }

  void checkRespawns() {
    for (final char in characters) {
      if (!char.isAlive && char.respawnTimer <= 0) {
        // Find safe spawn near original team area
        final tIndex = char.teamId % 4;
        final spawnPoints = [
          [-10.0, -10.0],
          [10.0, 10.0],
          [-10.0, 10.0],
          [10.0, -10.0],
        ];
        final p = spawnPoints[tIndex];
        final rx = p[0] + (_random.nextDouble() - 0.5) * 3.0;
        final rz = p[1] + (_random.nextDouble() - 0.5) * 3.0;

        char.spawnAt(rx, rz, math.atan2(-rx, -rz));
      }
    }
  }

  void cleanInactiveBoomerangs() {
    boomerangs.removeWhere((b) {
      if (!b.isActive) {
        // Return boomerang back to owner
        final owner = findCharacter(b.ownerId);
        if (owner != null && owner.isAlive) {
          owner.hasBoomerang = true;
        }
        return true;
      }
      return false;
    });
  }
}
