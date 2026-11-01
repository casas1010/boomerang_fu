import 'package:flutter/material.dart';

import '../boomerang_fu/boomerang_fu_app.dart';
import '../tutorial_game/tutorial_game.dart';
import 'components/engine_summary/engine_summary.dart';
import 'components/game_card/game_card.dart';
import 'components/launcher_header/launcher_header.dart';

enum SelectedApp { launcher, tutorialGame, boomerangFu }

/// Main launcher screen following Composite Design.
/// Composes [LauncherHeader], [GameCard], and [EngineSummary] sub-components.
class GameLauncher extends StatefulWidget {
  const GameLauncher({super.key});

  @override
  State<GameLauncher> createState() => _GameLauncherState();
}

class _GameLauncherState extends State<GameLauncher> {
  SelectedApp _current = SelectedApp.launcher;

  @override
  Widget build(BuildContext context) {
    switch (_current) {
      case SelectedApp.tutorialGame:
        return TutorialGame(
          onExit: () => setState(() => _current = SelectedApp.launcher),
        );
      case SelectedApp.boomerangFu:
        return BoomerangFuApp(
          onExitToMenu: () => setState(() => _current = SelectedApp.launcher),
        );
      case SelectedApp.launcher:
        return Scaffold(
          backgroundColor: const Color(0xFF0F141C),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const LauncherHeader(),
                      const SizedBox(height: 36),
                      _buildCards(context),
                      const SizedBox(height: 40),
                      const EngineSummary(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }

  Widget _buildCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;
        final cards = [
          GameCard(
            title: 'Tutorial: Gem Collector 3D',
            tag: 'RECOMMENDED FOR BEGINNERS',
            tagColor: Colors.amberAccent,
            icon: '💎',
            description:
                'A clean, simple 3D game designed specifically as a tutorial. '
                'Features player movement, gem collection, a patrolling hazard, and an in-game code guide.',
            buttonText: 'Play Tutorial Game',
            buttonColor: Colors.amberAccent,
            textColor: Colors.black,
            onPressed: () => setState(() => _current = SelectedApp.tutorialGame),
          ),
          GameCard(
            title: 'Boomerang Fu 3D',
            tag: 'FULL GAME DEMO',
            tagColor: Colors.cyanAccent,
            icon: '🪃',
            description:
                'The complete multiplayer arena game with AI bot navigation, '
                'ricochet boomerang physics, team picker, and top-down / first-person camera modes.',
            buttonText: 'Play Boomerang Fu',
            buttonColor: Colors.cyanAccent,
            textColor: Colors.black,
            onPressed: () => setState(() => _current = SelectedApp.boomerangFu),
          ),
        ];

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 24),
              Expanded(child: cards[1]),
            ],
          );
        } else {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 20),
              cards[1],
            ],
          );
        }
      },
    );
  }
}
