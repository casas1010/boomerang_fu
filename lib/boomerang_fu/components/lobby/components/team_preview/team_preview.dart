import 'package:flutter/material.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match_config/match_config.dart';

class TeamPreview extends StatelessWidget {
  final int selectedGroups;
  final int botsPerGroup;
  final int playerTeamIndex;
  final ValueChanged<int> onSelectPlayerTeam;

  const TeamPreview({
    super.key,
    required this.selectedGroups,
    required this.botsPerGroup,
    required this.playerTeamIndex,
    required this.onSelectPlayerTeam,
  });

  @override
  Widget build(BuildContext context) {
    final teams = TeamConfig.predefinedTeams.take(selectedGroups).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teams Overview (Tap a team to join it)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: teams.asMap().entries.map((entry) {
              final index = entry.key;
              final team = entry.value;
              final isPlayerTeam = index == playerTeamIndex;

              return InkWell(
                onTap: () => onSelectPlayerTeam(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 175,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPlayerTeam
                        ? team.color.withAlpha(50)
                        : const Color(0xFF2B2B3D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPlayerTeam ? team.color : Colors.white10,
                      width: isPlayerTeam ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: team.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              team.name,
                              style: TextStyle(
                                color: team.color,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Roster listing
                      Row(
                        children: [
                          Icon(
                            isPlayerTeam
                                ? Icons.person_rounded
                                : Icons.smart_toy_rounded,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              isPlayerTeam ? 'You (P1)' : 'Bot 1',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      for (int b = 0; b < botsPerGroup; b++)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.smart_toy_rounded,
                                size: 16,
                                color: Colors.white54,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  isPlayerTeam ? 'Bot Ally ${b + 1}' : 'Bot ${b + 2}',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
