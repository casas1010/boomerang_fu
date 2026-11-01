import 'package:flutter/material.dart';

import 'components/code_guide/code_guide.dart';
import 'components/controls_hint/controls_hint.dart';
import 'components/game_over_dialog/game_over_dialog.dart';
import 'components/hud_actions/hud_actions.dart';
import 'components/score_badge/score_badge.dart';
import 'components/win_dialog/win_dialog.dart';

/// Composite HUD overlay displayed directly on top of the 3D software canvas.
/// Follows strict Composite Design by composing atomic UI components.
class TutorialHud extends StatefulWidget {
  final int score;
  final int totalGems;
  final double fps;
  final double totalTime;
  final bool isGameWon;
  final bool isGameOver;
  final VoidCallback onReset;

  const TutorialHud({
    super.key,
    required this.score,
    required this.totalGems,
    required this.fps,
    required this.totalTime,
    required this.isGameWon,
    required this.isGameOver,
    required this.onReset,
  });

  @override
  State<TutorialHud> createState() => _TutorialHudState();
}

class _TutorialHudState extends State<TutorialHud> {
  bool _showCodeGuide = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top HUD Bar: Score and Actions
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ScoreBadge(score: widget.score, total: widget.totalGems),
                HudActions(
                  fps: widget.fps,
                  onToggleGuide: () => setState(() => _showCodeGuide = !_showCodeGuide),
                  onReset: widget.onReset,
                ),
              ],
            ),
          ),
        ),

        // Bottom Controls Hint
        const Positioned(
          bottom: 16,
          left: 16,
          child: ControlsHint(),
        ),

        // Win Dialog
        if (widget.isGameWon)
          WinDialog(
            totalGems: widget.totalGems,
            time: widget.totalTime,
            onPlayAgain: widget.onReset,
          ),

        // Game Over Dialog
        if (widget.isGameOver)
          GameOverDialog(onTryAgain: widget.onReset),

        // Interactive Code Guide
        if (_showCodeGuide)
          CodeGuide(onClose: () => setState(() => _showCodeGuide = false)),
      ],
    );
  }
}
