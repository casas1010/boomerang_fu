import 'package:flutter/material.dart';

/// Top-right actions: Toggle Code Guide, Reset Game, and FPS counter.
class HudActions extends StatelessWidget {
  final double fps;
  final VoidCallback onToggleGuide;
  final VoidCallback onReset;

  const HudActions({
    super.key,
    required this.fps,
    required this.onToggleGuide,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Learn How This Works',
          icon: const Icon(Icons.menu_book, color: Colors.cyanAccent),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.7),
          ),
          onPressed: onToggleGuide,
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Reset Game (R)',
          icon: const Icon(Icons.refresh, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.7),
          ),
          onPressed: onReset,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${fps.toStringAsFixed(0)} FPS',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
