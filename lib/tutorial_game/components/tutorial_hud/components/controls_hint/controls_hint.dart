import 'package:flutter/material.dart';

/// Bottom-left controls tip informing the user of keyboard and touch controls.
class ControlsHint extends StatelessWidget {
  const ControlsHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '🎮 Move: WASD / Arrow Keys or Touch Drag',
        style: TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }
}
