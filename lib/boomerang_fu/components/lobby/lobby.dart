import 'package:flutter/material.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match_config/match_config.dart';
import 'components/bot_counter/bot_counter.dart';
import 'components/group_selector/group_selector.dart';
import 'components/lobby_actions/lobby_actions.dart';
import 'components/team_preview/team_preview.dart';

class Lobby extends StatefulWidget {
  final MatchConfig initialConfig;
  final ValueChanged<MatchConfig> onProceedToArena;

  const Lobby({
    super.key,
    required this.initialConfig,
    required this.onProceedToArena,
  });

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  late int _selectedGroups;
  late int _botsPerGroup;
  late int _playerTeamIndex;

  @override
  void initState() {
    super.initState();
    _selectedGroups = widget.initialConfig.numGroups;
    _botsPerGroup = widget.initialConfig.botsPerGroup;
    _playerTeamIndex = widget.initialConfig.playerTeamIndex;
  }

  void _onGroupsChanged(int count) {
    setState(() {
      _selectedGroups = count;
      if (_playerTeamIndex >= count) {
        _playerTeamIndex = 0;
      }
    });
  }

  void _onBotsChanged(int count) {
    setState(() {
      _botsPerGroup = count;
    });
  }

  void _onSelectPlayerTeam(int index) {
    setState(() {
      _playerTeamIndex = index;
    });
  }

  void _handleProceed() {
    final updatedConfig = widget.initialConfig.copyWith(
      numGroups: _selectedGroups,
      botsPerGroup: _botsPerGroup,
      playerTeamIndex: _playerTeamIndex,
    );
    widget.onProceedToArena(updatedConfig);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.sports_esports_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 10),
            Text(
              'Boomerang Fu 3D',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Match Setup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Configure teams and enemy bots before stepping into the arena.',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 24),
                GroupSelector(
                  selectedGroups: _selectedGroups,
                  onGroupsChanged: _onGroupsChanged,
                ),
                const SizedBox(height: 20),
                BotCounter(
                  botsPerGroup: _botsPerGroup,
                  onBotsChanged: _onBotsChanged,
                ),
                const SizedBox(height: 20),
                TeamPreview(
                  selectedGroups: _selectedGroups,
                  botsPerGroup: _botsPerGroup,
                  playerTeamIndex: _playerTeamIndex,
                  onSelectPlayerTeam: _onSelectPlayerTeam,
                ),
                const SizedBox(height: 32),
                LobbyActions(onProceed: _handleProceed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
