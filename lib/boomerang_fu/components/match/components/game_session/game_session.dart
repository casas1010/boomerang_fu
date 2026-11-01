import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Simulation;

import 'package:flutter_game_engine/engine/engine.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match_config/match_config.dart';
import 'components/arena/arena.dart';
import 'components/bot_ai/bot_ai.dart';
import 'components/camera_controller/camera_controller.dart';
import 'components/simulation/components/command_dispatcher/command_dispatcher.dart';
import 'components/simulation/components/entity_manager/entity_manager.dart';
import 'components/simulation/simulation.dart';

class GameSession implements Game {
  final MatchConfig config;

  @override
  final Camera camera = Camera();

  late final Arena _arena;
  late final EntityManager _entityManager;
  late final CommandDispatcher _commandDispatcher;
  late final MatchSimulation _simulation;
  late final BotAiController _botAi;
  late final CameraController cameraController;

  // Track key actions
  bool _throwTriggered = false;
  bool _slashTriggered = false;
  bool _dashTriggered = false;

  GameSession({required this.config}) {
    cameraController = CameraController(camera: camera);
    _arena = Arena.loadTemple();
    _commandDispatcher = CommandDispatcher();
    _entityManager = EntityManager(config: config);
    _simulation = MatchSimulation(
      arena: _arena,
      entityManager: _entityManager,
      commandDispatcher: _commandDispatcher,
    );
    _botAi = BotAiController();
    camera.f = 260;
  }

  EntityManager get entityManager => _entityManager;
  MatchSimulation get simulation => _simulation;

  @override
  Future<void> load(Renderer renderer) async {
    // Engine load hook
  }

  void toggleView() {
    cameraController.toggleViewMode(player: _entityManager.player);
  }

  @override
  void update(double dt, Input input) {
    final player = _entityManager.player;
    if (player != null && player.isAlive) {
      final isFpv = cameraController.mode == ViewMode.firstPerson;

      // In FPV, keep player body aim aligned with camera
      if (isFpv) {
        player.yaw = camera.yaw;
        player.pitch = camera.pitch;
      }

      // 1. Gather player movement
      final fwd = (input.axis(LogicalKeyboardKey.keyW, LogicalKeyboardKey.keyS) +
              input.stickY)
          .clamp(-1.0, 1.0);
      final str = (input.axis(LogicalKeyboardKey.keyD, LogicalKeyboardKey.keyA) +
              input.stickX)
          .clamp(-1.0, 1.0);

      double moveX = 0;
      double moveZ = 0;

      if (isFpv) {
        // In FPV, movement is relative to camera yaw (W=fwd, S=back, D=right, A=left)
        final s = math.sin(camera.yaw);
        final c = math.cos(camera.yaw);
        moveX = s * fwd + c * str;
        moveZ = c * fwd - s * str;
      } else {
        // In Top-down, W is up (+Z), S is down (-Z), D is right (+X), A is left (-X)
        moveX = str;
        moveZ = fwd;
      }

      if (moveX.abs() > 0.05 || moveZ.abs() > 0.05) {
        _commandDispatcher.enqueue(MoveCommand(
          characterId: player.id,
          moveX: moveX,
          moveZ: moveZ,
          // Only update character's yaw from velocity in Top-Down mode!
          // In FPV mode, camera look controls yaw so strafing left/right won't spin the camera.
          updateYaw: !isFpv,
        ));
      }

      // 2. Gather Player Actions
      if (_throwTriggered) {
        _throwTriggered = false;
        double aimX = math.sin(player.yaw);
        double aimZ = math.cos(player.yaw);
        _commandDispatcher.enqueue(ThrowBoomerangCommand(
          characterId: player.id,
          targetVx: aimX * 22.0,
          targetVz: aimZ * 22.0,
        ));
      }

      if (_slashTriggered) {
        _slashTriggered = false;
        _commandDispatcher.enqueue(SlashCommand(characterId: player.id));
      }

      if (_dashTriggered) {
        _dashTriggered = false;
        final dashX = math.sin(player.yaw);
        final dashZ = math.cos(player.yaw);
        _commandDispatcher.enqueue(DashCommand(
          characterId: player.id,
          dirX: dashX,
          dirZ: dashZ,
        ));
      }
    }

    // 3. AI Bot updates
    final botCommands = _botAi.updateBots(
      dt: dt,
      allCharacters: _entityManager.characters,
      activeBoomerangs: _entityManager.boomerangs,
    );
    _commandDispatcher.enqueueAll(botCommands);

    // 4. Step physics simulation
    _simulation.step(dt);

    // 5. Update Camera
    if (player != null) {
      cameraController.update(
        playerX: player.x,
        playerY: player.y,
        playerZ: player.z,
      );
    }
  }

  @override
  void render(Renderer renderer) {
    // 1. Draw arena floor, walls and pillars
    _arena.render(renderer, camera);

    // 2. Draw characters (other than the local player if in FPV)
    for (final char in _entityManager.characters) {
      if (cameraController.mode == ViewMode.firstPerson && char.isPlayer) {
        continue; // Don't draw player's own body in front of their eyes
      }
      char.render(renderer, camera);
    }

    // 3. Draw active boomerangs
    for (final b in _entityManager.boomerangs) {
      b.render(renderer, camera);
    }
  }

  @override
  void onKeyDown(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.keyC) {
      // Toggle Camera Mode: FPV vs Top-Down
      toggleView();
    } else if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.keyE) {
      // Throw Boomerang
      triggerThrow();
    } else if (key == LogicalKeyboardKey.keyF || key == LogicalKeyboardKey.keyQ) {
      // Melee Slash / Deflect
      triggerSlash();
    } else if (key == LogicalKeyboardKey.shiftLeft || key == LogicalKeyboardKey.shiftRight) {
      // Dash
      triggerDash();
    }
  }

  @override
  void onPrimaryAction() {
    // Click or primary tap
    triggerThrow();
  }

  void triggerThrow() => _throwTriggered = true;
  void triggerSlash() => _slashTriggered = true;
  void triggerDash() => _dashTriggered = true;

  @override
  Widget buildOverlay(BuildContext context, double fps) {
    return const SizedBox.shrink(); // Handled by Match HUD
  }
}
