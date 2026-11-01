import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_game_engine/engine/engine.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match_config/match_config.dart';
import 'components/game_session/game_session.dart';
import 'components/match_hud/match_hud.dart';

class Match extends StatefulWidget {
  final MatchConfig matchConfig;
  final VoidCallback onExitMatch;

  const Match({
    super.key,
    required this.matchConfig,
    required this.onExitMatch,
  });

  @override
  State<Match> createState() => _MatchState();
}

class _MatchState extends State<Match> {
  late final GameSession _session;
  Timer? _hudTimer;

  @override
  void initState() {
    super.initState();
    _session = GameSession(config: widget.matchConfig);
    // Refresh HUD at 15Hz to display updated score counters and view state
    _hudTimer = Timer.periodic(const Duration(milliseconds: 66), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _hudTimer?.cancel();
    super.dispose();
  }

  void _handleToggleView() {
    setState(() {
      _session.toggleView();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 3D Engine Viewport
          Engine(game: _session),

          // Match HUD Overlay
          MatchHud(
            session: _session,
            onExitMatch: widget.onExitMatch,
            onToggleView: _handleToggleView,
          ),
        ],
      ),
    );
  }
}
