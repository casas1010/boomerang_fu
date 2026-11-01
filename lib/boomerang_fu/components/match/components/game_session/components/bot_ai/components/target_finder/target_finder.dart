import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/entities/components/character/character.dart';

class TargetFinder {
  const TargetFinder();

  Character? findClosestEnemy({
    required Character bot,
    required List<Character> allCharacters,
  }) {
    Character? closest;
    double closestDist = double.infinity;

    for (final char in allCharacters) {
      if (!char.isAlive || char.teamId == bot.teamId || char.id == bot.id) {
        continue;
      }
      final dx = char.x - bot.x;
      final dz = char.z - bot.z;
      final d2 = dx * dx + dz * dz;

      if (d2 < closestDist) {
        closestDist = d2;
        closest = char;
      }
    }
    return closest;
  }
}
