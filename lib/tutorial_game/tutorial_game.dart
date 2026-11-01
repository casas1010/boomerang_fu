import 'package:flutter/material.dart';

import '../engine/engine.dart';
import 'components/gem_collector_game/gem_collector_game.dart';

export 'components/gem_collector_game/gem_collector_game.dart';

/// Top-level screen hosting the tutorial game.
/// Composes the 3D [Engine] with a back navigation button.
class TutorialGame extends StatefulWidget {
  final VoidCallback onExit;

  const TutorialGame({super.key, required this.onExit});

  @override
  State<TutorialGame> createState() => _TutorialGameState();
}

class _TutorialGameState extends State<TutorialGame> {
  late final GemCollectorGame _game;

  @override
  void initState() {
    super.initState();
    _game = GemCollectorGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The 3D Engine running our tutorial game
          Engine(
            game: _game,
            width: 480,
            height: 270,
          ),

          // Top back button to exit to the launcher
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                child: IconButton(
                  tooltip: 'Back to Menu',
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    padding: const EdgeInsets.all(8),
                  ),
                  onPressed: widget.onExit,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
