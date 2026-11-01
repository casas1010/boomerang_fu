import 'package:flutter/material.dart';

/// Game Over banner presented when touching the hazard.
class GameOverDialog extends StatelessWidget {
  final VoidCallback onTryAgain;

  const GameOverDialog({super.key, required this.onTryAgain});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF3A1A1A).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 4),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '💥 HIT BY HAZARD!',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Watch out for the red patrolling cube!',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: onTryAgain,
            ),
          ],
        ),
      ),
    );
  }
}
