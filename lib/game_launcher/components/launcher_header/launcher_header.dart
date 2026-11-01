import 'package:flutter/material.dart';

/// Header section with badge, main title, and description.
class LauncherHeader extends StatelessWidget {
  const LauncherHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4)),
            ),
            child: const Text(
              '🎮 FLUTTER 3D RETRO GAME ENGINE',
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Learn 3D Game Development in Flutter',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Choose the simple step-by-step tutorial game to understand the engine, or play the full Boomerang Fu 3D demo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
