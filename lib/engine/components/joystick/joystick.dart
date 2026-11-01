import 'package:flutter/material.dart';

import '../controller/controller.dart';

/// State of the virtual touch joystick.
class JoystickState {
  final Offset origin;
  final Offset position;
  final double radius;

  const JoystickState({
    required this.origin,
    required this.position,
    required this.radius,
  });
}

/// Renders the virtual touch joystick overlay (base ring and knob).
class EngineJoystick extends StatelessWidget {
  final EngineController controller;

  const EngineJoystick({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<JoystickState?>(
      valueListenable: controller.joystickNotifier,
      builder: (context, state, _) {
        if (state == null) return const SizedBox.shrink();
        return Stack(
          children: [
            Positioned(
              left: state.origin.dx - state.radius,
              top: state.origin.dy - state.radius,
              child: IgnorePointer(
                child: SizedBox(
                  width: state.radius * 2,
                  height: state.radius * 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                      border: Border.all(color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: state.position.dx - 20,
              top: state.position.dy - 20,
              child: const IgnorePointer(
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white54,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
