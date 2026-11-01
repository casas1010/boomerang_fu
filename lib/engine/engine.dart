import 'package:flutter/material.dart';

import 'components/controller/controller.dart';
import 'components/game/game.dart';
import 'components/input_handler/input_handler.dart';
import 'components/joystick/joystick.dart';
import 'components/overlay/overlay.dart';
import 'components/viewport/viewport.dart';

export 'components/camera/camera.dart';
export 'components/controller/controller.dart';
export 'components/game/game.dart';
export 'components/input/input.dart';
export 'components/input_handler/input_handler.dart';
export 'components/joystick/joystick.dart';
export 'components/mesh/components/mesh_builder/mesh_builder.dart';
export 'components/mesh/components/obj_loader/obj_loader.dart';
export 'components/mesh/mesh.dart';
export 'components/overlay/overlay.dart';
export 'components/renderer/renderer.dart';
export 'components/texture/texture.dart';
export 'components/viewport/viewport.dart';

/// Hosts a [Game]: runs the loop, owns the software framebuffer, captures
/// keyboard/mouse input and presents the frame with smooth anti-aliased scaling.
class Engine extends StatefulWidget {
  final Game game;
  final int width, height;
  final EngineController? controller;

  const Engine({
    super.key,
    required this.game,
    this.width = 640,
    this.height = 360,
    this.controller,
  });

  @override
  State<Engine> createState() => _EngineState();
}

class _EngineState extends State<Engine> with SingleTickerProviderStateMixin {
  late final EngineController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = EngineController(
        game: widget.game,
        width: widget.width,
        height: widget.height,
      );
      _ownsController = true;
    }
    _controller.start(this);
  }

  @override
  void dispose() {
    _controller.stop();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: EngineInputHandler(
        controller: _controller,
        child: Stack(
          fit: StackFit.expand,
          children: [
            EngineViewport(controller: _controller),
            EngineOverlay(controller: _controller),
            EngineJoystick(controller: _controller),
          ],
        ),
      ),
    );
  }
}
