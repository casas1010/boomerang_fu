import 'package:flutter/material.dart';

/// Full-screen overlay explaining the core architecture of the 3D engine.
class CodeGuide extends StatelessWidget {
  final VoidCallback onClose;

  const CodeGuide({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text('How the 3D Engine Works 💡'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    _GuideCard(
                      step: '1. What is this Engine?',
                      description:
                          'This is a software 3D rasterizer written in 100% pure Dart. '
                          'Instead of talking to GPU shaders (like OpenGL or Vulkan), the CPU loops through 3D triangles, '
                          'projects them onto a 2D screen, and writes colors directly into a raw byte framebuffer '
                          'represented as an array of Uint32 pixel colors.',
                    ),
                    _GuideCard(
                      step: '2. Composite Design & Modularity',
                      description:
                          'Notice how this game is built!\n'
                          '• Arena: owns ground and perimeter walls.\n'
                          '• Player: owns position, box mesh, and movement physics.\n'
                          '• GemManager: owns diamond meshes, rotation animations, and collection.\n'
                          '• Hazard: owns patrolling movement and damage checks.\n'
                          'Everything is separated into clean, modular components.',
                    ),
                    _GuideCard(
                      step: '3. 3D Coordinates & Camera',
                      description:
                          '• +X goes Right\n'
                          '• +Y goes Up\n'
                          '• +Z goes Forward (into the screen)\n'
                          'The Camera has position (x, y, z) and rotation (pitch, yaw). '
                          'The engine subtracts the camera position from every vertex to calculate where it appears on screen.',
                    ),
                    _GuideCard(
                      step: '4. Collisions in 3D',
                      description:
                          'In this tutorial, we use simple 2D distance checks on the ground:\n'
                          'dist = sqrt((playerX - targetX)^2 + (playerZ - targetZ)^2)\n'
                          'If dist < 1.2 units, the entities are touching!',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final String step;
  final String description;

  const _GuideCard({
    required this.step,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E2330),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step,
              style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
