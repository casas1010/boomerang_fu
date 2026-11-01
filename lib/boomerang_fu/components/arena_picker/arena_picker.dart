import 'package:flutter/material.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match_config/match_config.dart';
import 'components/arena_card/arena_card.dart';
import 'components/arena_picker_actions/arena_picker_actions.dart';

class ArenaPicker extends StatefulWidget {
  final MatchConfig matchConfig;
  final VoidCallback onBackToLobby;
  final ValueChanged<MatchConfig> onStartMatch;

  const ArenaPicker({
    super.key,
    required this.matchConfig,
    required this.onBackToLobby,
    required this.onStartMatch,
  });

  @override
  State<ArenaPicker> createState() => _ArenaPickerState();
}

class _ArenaPickerState extends State<ArenaPicker> {
  late String _selectedArenaId;

  @override
  void initState() {
    super.initState();
    _selectedArenaId = widget.matchConfig.arenaId;
  }

  void _handleStart() {
    widget.onStartMatch(
      widget.matchConfig.copyWith(arenaId: _selectedArenaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Select Battle Arena',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Choose where the battle takes place',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ArenaCard(
                  id: 'temple',
                  name: 'The Stone Dojo Arena',
                  description:
                      'A symmetrical dojo courtyard with solid perimeter walls, central stone pillars, and tight corner sightlines for tricky boomerang ricochets.',
                  isSelected: _selectedArenaId == 'temple',
                  onSelect: () => setState(() => _selectedArenaId = 'temple'),
                ),
                const Spacer(),
                ArenaPickerActions(
                  onBack: widget.onBackToLobby,
                  onStartMatch: _handleStart,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
