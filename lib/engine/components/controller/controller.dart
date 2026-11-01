import 'dart:ui' as ui;

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/game.dart';
import '../input/input.dart';
import '../joystick/joystick.dart';
import '../renderer/renderer.dart';

/// Drives the engine loop, manages input processing, renders frames,
/// and notifies listeners of state updates without dirtying the widget tree.
class EngineController {
  final Game game;
  final int width;
  final int height;

  late final Renderer renderer;
  final Input input;
  final FocusNode focusNode;

  Ticker? _ticker;
  Duration _lastTick = Duration.zero;
  bool _decoding = false;
  bool _disposed = false;

  // Touch joystick tracking
  static const double stickRadius = 60.0;
  int? _stickId;
  int? _lookId;
  Offset _stickOrigin = Offset.zero;

  // Reactive notifiers for granular leaf widget rebuilds
  final ValueNotifier<ui.Image?> frameNotifier = ValueNotifier<ui.Image?>(null);
  final ValueNotifier<double> fpsNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> loadedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> mouseLookNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<JoystickState?> joystickNotifier =
      ValueNotifier<JoystickState?>(null);

  EngineController({
    required this.game,
    this.width = 480,
    this.height = 270,
    Input? input,
    FocusNode? focusNode,
    Renderer? renderer,
  })  : input = input ?? Input(),
        focusNode = focusNode ?? FocusNode() {
    this.renderer = renderer ?? Renderer(width, height);
  }

  /// Initializes the game and starts the ticker.
  void start(TickerProvider tickerProvider) {
    game.load(renderer).then((_) {
      if (!_disposed) loadedNotifier.value = true;
    });
    _ticker = tickerProvider.createTicker(_tick)..start();
  }

  void _tick(Duration now) {
    if (!loadedNotifier.value) return;

    final dt = _lastTick == Duration.zero
        ? 0.016
        : ((now - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _lastTick = now;

    if (dt > 0) {
      final currentFps = fpsNotifier.value;
      fpsNotifier.value = currentFps * 0.9 + (1 / dt) * 0.1;
    }

    // Arrow keys look around in addition to the mouse
    final turn = 600 * dt;
    game.camera.look(
      input.axis(LogicalKeyboardKey.arrowRight, LogicalKeyboardKey.arrowLeft) *
          turn,
      input.axis(LogicalKeyboardKey.arrowDown, LogicalKeyboardKey.arrowUp) *
          turn,
    );

    game.update(dt, input);
    _present();
  }

  void _present() {
    if (_decoding) return;
    renderer.clear();
    game.render(renderer);
    _decoding = true;

    final bytes = Uint8List.fromList(renderer.framebuffer.buffer.asUint8List());
    ui.decodeImageFromPixels(
      bytes,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (img) {
        if (_disposed) {
          img.dispose();
          return;
        }
        final oldFrame = frameNotifier.value;
        frameNotifier.value = img;
        oldFrame?.dispose();
        _decoding = false;
      },
    );
  }

  void pointerDown(PointerDownEvent e, double screenWidth) {
    focusNode.requestFocus();
    if (e.kind != PointerDeviceKind.touch) {
      mouseLookNotifier.value = true;
      return;
    }

    if (e.position.dx < screenWidth / 2) {
      if (_stickId != null) return;
      _stickId = e.pointer;
      _stickOrigin = e.position;
      joystickNotifier.value = JoystickState(
        origin: _stickOrigin,
        position: _stickOrigin,
        radius: stickRadius,
      );
    } else {
      _lookId ??= e.pointer;
    }
  }

  void pointerHover(PointerHoverEvent e) {
    if (mouseLookNotifier.value) {
      game.camera.look(e.delta.dx, e.delta.dy);
    }
  }

  void pointerMove(PointerMoveEvent e) {
    if (e.kind != PointerDeviceKind.touch) {
      game.camera.look(e.delta.dx, e.delta.dy);
    } else if (e.pointer == _stickId) {
      var d = e.position - _stickOrigin;
      if (d.distance > stickRadius) {
        d = d / d.distance * stickRadius;
      }
      input.stickX = d.dx / stickRadius;
      input.stickY = -d.dy / stickRadius;
      joystickNotifier.value = JoystickState(
        origin: _stickOrigin,
        position: _stickOrigin + d,
        radius: stickRadius,
      );
    } else if (e.pointer == _lookId) {
      game.camera.look(e.delta.dx, e.delta.dy);
    }
  }

  void pointerUp(PointerEvent e) {
    if (e.pointer == _stickId) {
      _stickId = null;
      input.stickX = 0;
      input.stickY = 0;
      joystickNotifier.value = null;
    } else if (e.pointer == _lookId) {
      _lookId = null;
    }
  }

  KeyEventResult onKey(FocusNode node, KeyEvent e) {
    if (e is KeyDownEvent) {
      if (e.logicalKey == LogicalKeyboardKey.escape) {
        mouseLookNotifier.value = false;
      }
      game.onKeyDown(e.logicalKey);
    }
    return KeyEventResult.handled;
  }

  void stop() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
  }

  void dispose() {
    _disposed = true;
    stop();
    focusNode.dispose();
    frameNotifier.value?.dispose();
    frameNotifier.dispose();
    fpsNotifier.dispose();
    loadedNotifier.dispose();
    mouseLookNotifier.dispose();
    joystickNotifier.dispose();
  }
}
