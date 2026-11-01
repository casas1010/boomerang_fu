import 'package:flutter/material.dart';

class BotCounter extends StatelessWidget {
  final int botsPerGroup;
  final ValueChanged<int> onBotsChanged;

  const BotCounter({
    super.key,
    required this.botsPerGroup,
    required this.onBotsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.smart_toy_rounded, color: Colors.cyanAccent, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Bots per Group',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'AI enemies added to each team',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          Row(
            children: [
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF2B2B3D),
                  foregroundColor: Colors.white,
                ),
                onPressed: botsPerGroup > 0 ? () => onBotsChanged(botsPerGroup - 1) : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 44),
                alignment: Alignment.center,
                child: Text(
                  '$botsPerGroup',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF2B2B3D),
                  foregroundColor: Colors.white,
                ),
                onPressed: botsPerGroup < 4 ? () => onBotsChanged(botsPerGroup + 1) : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
