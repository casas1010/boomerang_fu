import 'package:flutter/material.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/camera_controller/camera_controller.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/game_session.dart';
import 'components/crosshair/crosshair.dart';
import 'components/score_tracker/score_tracker.dart';
import 'components/touch_controls/touch_controls.dart';
import 'components/view_mode_toggle/view_mode_toggle.dart';

class MatchHud extends StatelessWidget {
  final GameSession session;
  final VoidCallback onExitMatch;
  final VoidCallback onToggleView;

  const MatchHud({
    super.key,
    required this.session,
    required this.onExitMatch,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    final player = session.entityManager.player;
    final hasBoomerang = player?.hasBoomerang ?? false;
    final mode = session.cameraController.mode;

    return Stack(
      children: [
        // Center Crosshair (FPV mode only)
        Crosshair(visible: mode == ViewMode.firstPerson),

        // Top bar: Exit, Score Tracker, and View Toggle
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Exit match button
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withAlpha(160),
                  foregroundColor: Colors.white,
                ),
                tooltip: 'Exit to Setup',
                onPressed: onExitMatch,
                icon: const Icon(Icons.arrow_back_rounded),
              ),

              // Live Team Scores
              ScoreTracker(
                teams: session.config.activeTeams,
                scores: session.entityManager.teamScores,
              ),

              // View Mode Toggle (Top-Down vs FPV)
              ViewModeToggle(
                mode: mode,
                onToggle: onToggleView,
              ),
            ],
          ),
        ),

        // Bottom right touch/mouse action controls
        Positioned(
          bottom: 24,
          right: 24,
          child: TouchControls(
            onThrow: session.triggerThrow,
            onSlash: session.triggerSlash,
            onDash: session.triggerDash,
            hasBoomerang: hasBoomerang,
          ),
        ),

        // Status indicator if dead / respawning
        if (player != null && !player.isAlive)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade900.withAlpha(220),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white38),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SLICED!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Respawning in ${player.respawnTimer.toStringAsFixed(1)}s...',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
