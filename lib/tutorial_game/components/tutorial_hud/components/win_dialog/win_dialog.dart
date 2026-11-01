import 'package:flutter/material.dart';

/// Victory banner presented when all gems are collected.
class WinDialog extends StatelessWidget {
  final int totalGems;
  final double time;
  final VoidCallback onPlayAgain;

  const WinDialog({
    super.key,
    required this.totalGems,
    required this.time,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2A4A).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 4),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉 YOU WIN! 🎉',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Collected all $totalGems gems in ${time.toStringAsFixed(1)}s!',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.replay),
              label: const Text(
                'Play Again',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: onPlayAgain,
            ),
          ],
        ),
      ),
    );
  }
}
