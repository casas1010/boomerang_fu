import 'package:flutter/material.dart';

class TouchControls extends StatelessWidget {
  final VoidCallback onThrow;
  final VoidCallback onSlash;
  final VoidCallback onDash;
  final bool hasBoomerang;

  const TouchControls({
    super.key,
    required this.onThrow,
    required this.onSlash,
    required this.onDash,
    required this.hasBoomerang,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Slash Button
        FloatingActionButton.small(
          heroTag: 'hud_slash',
          backgroundColor: Colors.blueGrey.shade800.withAlpha(200),
          foregroundColor: Colors.cyanAccent,
          onPressed: onSlash,
          tooltip: 'Slash / Deflect [F]',
          child: const Icon(Icons.flash_on_rounded),
        ),
        const SizedBox(width: 12),
        // Dash Button
        FloatingActionButton.small(
          heroTag: 'hud_dash',
          backgroundColor: Colors.blueGrey.shade800.withAlpha(200),
          foregroundColor: Colors.white,
          onPressed: onDash,
          tooltip: 'Dash [Shift]',
          child: const Icon(Icons.fast_forward_rounded),
        ),
        const SizedBox(width: 12),
        // Throw Boomerang Button
        FloatingActionButton(
          heroTag: 'hud_throw',
          backgroundColor: hasBoomerang ? Colors.amber.shade700 : Colors.grey.shade800,
          foregroundColor: Colors.white,
          onPressed: onThrow,
          tooltip: 'Throw Boomerang [Space]',
          child: const Icon(Icons.change_circle_rounded, size: 30),
        ),
      ],
    );
  }
}
