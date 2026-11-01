import 'package:flutter/material.dart';

/// Architecture summary card displayed at the bottom of the launcher.
class EngineSummary extends StatelessWidget {
  const EngineSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161C26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school, color: Colors.amberAccent, size: 22),
              SizedBox(width: 10),
              Text(
                'How The Engine Works (Quick Summary)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBullet(
            '1. The Software Rasterizer',
            'Pure Dart CPU rendering into a raw Uint32 pixel buffer. No native GPU shaders required!',
          ),
          _buildBullet(
            '2. The Game Lifecycle',
            'Implement 4 methods: load() to create meshes, update(dt, input) for logic, render(renderer) to draw, and buildOverlay() for Flutter HUD.',
          ),
          _buildBullet(
            '3. 3D Coordinates',
            '+X is Right, +Y is Up, +Z is Forward. Meshes are built from triangles using MeshBuilder.',
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            TextSpan(text: body),
          ],
        ),
      ),
    );
  }
}
