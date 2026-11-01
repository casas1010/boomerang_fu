import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../camera/camera.dart';
import '../input/input.dart';
import '../renderer/renderer.dart';

/// Contract between the engine and a game. The engine owns the loop,
/// framebuffer, input capture and presentation; the game owns content.
abstract class Game {
  Camera get camera;

  /// Load assets. [renderer] is provided so the game can tweak render settings.
  Future<void> load(Renderer renderer);

  /// Advance the simulation by [dt] seconds.
  void update(double dt, Input input);

  /// Draw the scene into [renderer] (already cleared).
  void render(Renderer renderer);

  void onKeyDown(LogicalKeyboardKey key) {}

  void onPrimaryAction() {}

  /// Optional widget layered over the frame. [fps] is the current frame rate.
  Widget buildOverlay(BuildContext context, double fps) =>
      const SizedBox.shrink();
}
