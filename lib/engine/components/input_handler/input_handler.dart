import 'package:flutter/material.dart';

import '../controller/controller.dart';

/// Captures keyboard focus and pointer events (mouse look & touch stick)
/// for the engine.
class EngineInputHandler extends StatelessWidget {
  final EngineController controller;
  final Widget child;

  const EngineInputHandler({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: controller.focusNode,
      autofocus: true,
      onKeyEvent: controller.onKey,
      child: Listener(
        onPointerDown: (e) =>
            controller.pointerDown(e, MediaQuery.sizeOf(context).width),
        onPointerHover: controller.pointerHover,
        onPointerMove: controller.pointerMove,
        onPointerUp: controller.pointerUp,
        onPointerCancel: controller.pointerUp,
        child: ValueListenableBuilder<bool>(
          valueListenable: controller.mouseLookNotifier,
          builder: (context, mouseLook, childWidget) {
            return MouseRegion(
              cursor: mouseLook ? SystemMouseCursors.none : MouseCursor.defer,
              child: childWidget,
            );
          },
          child: child,
        ),
      ),
    );
  }
}
