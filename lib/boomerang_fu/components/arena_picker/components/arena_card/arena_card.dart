import 'package:flutter/material.dart';

import '../arena_preview/arena_preview.dart';

class ArenaCard extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final bool isSelected;
  final VoidCallback onSelect;

  const ArenaCard({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white12,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amber.withAlpha(50),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            ArenaPreview(
              title: name,
              subtitle: description,
              icon: Icons.temple_buddhist_rounded,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E2C),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.crop_square_rounded, size: 16, color: Colors.white54),
                      SizedBox(width: 4),
                      Text('Size: 32x32m', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      SizedBox(width: 16),
                      Icon(Icons.shield_rounded, size: 16, color: Colors.white54),
                      SizedBox(width: 4),
                      Text('Ricochet Walls', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  Icon(Icons.check_circle_rounded, color: Colors.amber, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
