import 'package:flutter/material.dart';

import 'components/arena_picker/arena_picker.dart';
import 'components/lobby/lobby.dart';
import 'components/match/match.dart';
import 'components/match_config/match_config.dart';

enum GameScreen { lobby, arenaPicker, match }

class BoomerangFuApp extends StatefulWidget {
  final VoidCallback? onExitToMenu;

  const BoomerangFuApp({super.key, this.onExitToMenu});

  @override
  State<BoomerangFuApp> createState() => _BoomerangFuAppState();
}

class _BoomerangFuAppState extends State<BoomerangFuApp> {
  GameScreen _currentScreen = GameScreen.lobby;
  MatchConfig _config = const MatchConfig();

  void _onProceedToArena(MatchConfig config) {
    setState(() {
      _config = config;
      _currentScreen = GameScreen.arenaPicker;
    });
  }

  void _onBackToLobby() {
    setState(() {
      _currentScreen = GameScreen.lobby;
    });
  }

  void _onStartMatch(MatchConfig config) {
    setState(() {
      _config = config;
      _currentScreen = GameScreen.match;
    });
  }

  void _onExitMatch() {
    setState(() {
      _currentScreen = GameScreen.lobby;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_currentScreen) {
      case GameScreen.lobby:
        content = Lobby(
          initialConfig: _config,
          onProceedToArena: _onProceedToArena,
        );
        break;
      case GameScreen.arenaPicker:
        content = ArenaPicker(
          matchConfig: _config,
          onBackToLobby: _onBackToLobby,
          onStartMatch: _onStartMatch,
        );
        break;
      case GameScreen.match:
        content = Match(
          matchConfig: _config,
          onExitMatch: _onExitMatch,
        );
        break;
    }

    if (widget.onExitToMenu != null && _currentScreen == GameScreen.lobby) {
      return Stack(
        children: [
          content,
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Menu'),
                  onPressed: widget.onExitToMenu,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return content;
  }
}
