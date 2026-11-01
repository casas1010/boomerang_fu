import 'package:flutter/material.dart';

import '../controller/controller.dart';

/// Renders the optional game HUD overlay and passes the live FPS counter.
class EngineOverlay extends StatelessWidget {
  final EngineController controller;

  const EngineOverlay({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.loadedNotifier,
      builder: (context, loaded, _) {
        if (!loaded) return const SizedBox.shrink();
        return ValueListenableBuilder<double>(
          valueListenable: controller.fpsNotifier,
          builder: (context, fps, _) {
            return controller.game.buildOverlay(context, fps);
          },
        );
      },
    );
  }
}
