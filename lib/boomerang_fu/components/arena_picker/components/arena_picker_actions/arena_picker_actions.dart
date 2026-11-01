import 'package:flutter/material.dart';

class ArenaPickerActions extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onStartMatch;

  const ArenaPickerActions({
    super.key,
    required this.onBack,
    required this.onStartMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back to Lobby'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
          ),
          onPressed: onStartMatch,
          icon: const Icon(Icons.play_arrow_rounded, size: 28),
          label: const Text(
            'START BATTLE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
