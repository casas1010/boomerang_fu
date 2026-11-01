import 'package:flutter/material.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/camera_controller/camera_controller.dart';

class ViewModeToggle extends StatelessWidget {
  final ViewMode mode;
  final VoidCallback onToggle;

  const ViewModeToggle({
    super.key,
    required this.mode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isTopDown = mode == ViewMode.topDown;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black.withAlpha(180),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.amber, width: 1.5),
        ),
      ),
      onPressed: onToggle,
      icon: Icon(
        isTopDown ? Icons.visibility_rounded : Icons.crop_free_rounded,
        color: Colors.amber,
        size: 18,
      ),
      label: Text(
        isTopDown ? 'View: Top-Down [C]' : 'View: First-Person [C]',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
