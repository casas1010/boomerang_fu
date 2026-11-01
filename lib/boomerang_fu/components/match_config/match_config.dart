import 'package:flutter/material.dart';

/// Representation of a team in Boomerang Fu.
class TeamConfig {
  final int id;
  final String name;
  final Color color;
  final int colorRgb;

  const TeamConfig({
    required this.id,
    required this.name,
    required this.color,
    required this.colorRgb,
  });

  static const List<TeamConfig> predefinedTeams = [
    TeamConfig(
      id: 0,
      name: 'Team Red',
      color: Color(0xFFE53935),
      colorRgb: 0xFFE53935,
    ),
    TeamConfig(
      id: 1,
      name: 'Team Blue',
      color: Color(0xFF1E88E5),
      colorRgb: 0xFF1E88E5,
    ),
    TeamConfig(
      id: 2,
      name: 'Team Green',
      color: Color(0xFF43A047),
      colorRgb: 0xFF43A047,
    ),
    TeamConfig(
      id: 3,
      name: 'Team Yellow',
      color: Color(0xFFFDD835),
      colorRgb: 0xFFFDD835,
    ),
  ];
}

/// Global settings passed from Lobby & Arena Picker into the Match.
class MatchConfig {
  final int numGroups;
  final int botsPerGroup;
  final int playerTeamIndex;
  final String arenaId;

  const MatchConfig({
    this.numGroups = 2,
    this.botsPerGroup = 1,
    this.playerTeamIndex = 0,
    this.arenaId = 'temple',
  });

  List<TeamConfig> get activeTeams =>
      TeamConfig.predefinedTeams.take(numGroups).toList();

  int get totalParticipants => numGroups * (botsPerGroup + (botsPerGroup == 0 ? 1 : 1));

  MatchConfig copyWith({
    int? numGroups,
    int? botsPerGroup,
    int? playerTeamIndex,
    String? arenaId,
  }) {
    return MatchConfig(
      numGroups: numGroups ?? this.numGroups,
      botsPerGroup: botsPerGroup ?? this.botsPerGroup,
      playerTeamIndex: playerTeamIndex ?? this.playerTeamIndex,
      arenaId: arenaId ?? this.arenaId,
    );
  }
}
