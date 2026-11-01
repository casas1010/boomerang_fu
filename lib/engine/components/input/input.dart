import 'package:flutter/services.dart';

/// Polled keyboard state plus a virtual touch stick.
class Input {
  /// Virtual joystick, each axis in -1..1 (x = strafe right, y = forward).
  /// Written by the engine from touch input.
  double stickX = 0, stickY = 0;

  bool isDown(LogicalKeyboardKey key) =>
      HardwareKeyboard.instance.logicalKeysPressed.contains(key);

  /// -1, 0 or +1 depending on which of the two keys is held.
  double axis(LogicalKeyboardKey positive, LogicalKeyboardKey negative) =>
      (isDown(positive) ? 1.0 : 0.0) - (isDown(negative) ? 1.0 : 0.0);
}
