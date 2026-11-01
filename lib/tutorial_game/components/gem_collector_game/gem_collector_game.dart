import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../engine/engine.dart';
import '../tutorial_hud/tutorial_hud.dart';
import 'components/arena/arena.dart';
import 'components/gem/gem.dart';
import 'components/hazard/hazard.dart';
import 'components/player/player.dart';

/// ============================================================================
/// 🎓 GAME TUTORIAL: Gem Collector 3D
/// ============================================================================
///
/// Implements [Game] using Composite Design and Separation of Concerns (SoC).
/// Content is separated into modular components:
/// - [Arena]: Floor and boundary walls geometry & textures.
/// - [Player]: Player box mesh, orange texture, and input-based movement.
/// - [GemManager]: Diamond gem meshes, rotation animations, and collection.
/// - [Hazard]: Patrolling obstacle cube and damage checks.
/// - [TutorialHud]: Flutter composite HUD overlay.
/// ============================================================================
class GemCollectorGame implements Game {
  @override
  final Camera camera = Camera();

  // Modular components
  final Arena arena = Arena();
  final Player player = Player();
  final GemManager gemManager = GemManager();
  final Hazard hazard = Hazard();

  // Game state
  int score = 0;
  bool isGameOver = false;
  bool isGameWon = false;
  double totalTime = 0.0;

  VoidCallback? onGameStateChanged;

  GemCollectorGame({this.onGameStateChanged});

  // Expose gems list and arena limit for test compatibility
  List<GemItem> get gems => gemManager.gems;
  double get arenaLimit => arena.limit - 1.0;
  double get playerX => player.x;
  set playerX(double val) => player.x = val;
  double get playerZ => player.z;
  set playerZ(double val) => player.z = val;
  double get playerYaw => player.yaw;
  double get hazardX => hazard.x;
  double get hazardZ => hazard.z;

  void reset() {
    player.reset();
    gemManager.reset();
    hazard.reset();
    score = 0;
    isGameOver = false;
    isGameWon = false;
    totalTime = 0.0;
    onGameStateChanged?.call();
  }

  @override
  Future<void> load(Renderer renderer) async {
    arena.load(renderer);
    player.load();
    gemManager.load();
    hazard.load();
  }

  @override
  void update(double dt, Input input) {
    if (isGameOver || isGameWon) return;

    totalTime += dt;

    // 1. Update entities
    player.update(dt, input, arenaLimit);
    hazard.update(dt);
    gemManager.update(dt);

    // 2. Check collisions
    if (gemManager.checkCollisions(player.x, player.z)) {
      score = gemManager.collectedCount;
      onGameStateChanged?.call();
    }

    if (gemManager.allCollected && !isGameWon) {
      isGameWon = true;
      onGameStateChanged?.call();
    }

    if (hazard.checkCollision(player.x, player.z)) {
      isGameOver = true;
      onGameStateChanged?.call();
    }

    // 3. Update Camera to follow player smoothly from above/behind
    camera.x = player.x * 0.3;
    camera.y = 16.0;
    camera.z = player.z - 13.0;
    camera.yaw = 0.0;
    camera.pitch = 0.95;
  }

  @override
  void render(Renderer renderer) {
    arena.render(renderer, camera);
    player.render(renderer, camera);
    gemManager.render(renderer, camera, totalTime);
    hazard.render(renderer, camera, totalTime);
  }

  @override
  void onKeyDown(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.keyR) {
      reset();
    }
  }

  @override
  void onPrimaryAction() {}

  @override
  Widget buildOverlay(BuildContext context, double fps) {
    return TutorialHud(
      score: score,
      totalGems: gemManager.count,
      fps: fps,
      totalTime: totalTime,
      isGameWon: isGameWon,
      isGameOver: isGameOver,
      onReset: reset,
    );
  }
}
