import 'package:flutter_game_engine/engine/engine.dart';
import 'package:flutter_game_engine/tutorial_game/tutorial_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tutorial Game: GemCollectorGame', () {
    test('Game initializes with default values and active gems', () {
      final game = GemCollectorGame();
      expect(game.score, 0);
      expect(game.gems.length, 8);
      expect(game.isGameWon, isFalse);
      expect(game.isGameOver, isFalse);
      expect(game.playerX, 0.0);
      expect(game.playerZ, 0.0);
    });

    test('Loads 3D meshes and textures without errors', () async {
      final game = GemCollectorGame();
      final renderer = Renderer(64, 36);
      await game.load(renderer);

      expect(renderer.skyColor, isNotNull);
      // Renders a frame cleanly
      renderer.clear();
      game.render(renderer);
      // Framebuffer shouldn't just be completely blank sky
      bool hasRenderedPixels = false;
      for (final px in renderer.framebuffer) {
        if (px != renderer.skyColor) {
          hasRenderedPixels = true;
          break;
        }
      }
      expect(hasRenderedPixels, isTrue);
    });

    test('Player moves on input and clamps within arena', () async {
      final game = GemCollectorGame();
      final renderer = Renderer(64, 36);
      await game.load(renderer);

      final input = Input()..stickX = 1.0; // Moving right (+X)
      game.update(0.1, input);

      expect(game.playerX, greaterThan(0.0));
      expect(game.playerYaw, greaterThan(0.0));

      // Simulate moving very far right
      for (int i = 0; i < 50; i++) {
        game.update(0.1, input);
      }
      // Should clamp to arena limit
      expect(game.playerX, closeTo(game.arenaLimit, 0.001));
    });

    test('Collecting a gem increments score and triggers win condition when all collected', () async {
      final game = GemCollectorGame();
      final renderer = Renderer(64, 36);
      await game.load(renderer);

      // Gem 0 is at [-6.0, -6.0]
      final firstGem = game.gems[0];
      expect(firstGem.collected, isFalse);

      // Teleport player near gem 0
      game.playerX = firstGem.x;
      game.playerZ = firstGem.z;

      final input = Input();
      game.update(0.016, input);

      expect(firstGem.collected, isTrue);
      expect(game.score, 1);

      // Collect all remaining gems
      for (final gem in game.gems) {
        gem.collected = true;
      }
      game.score = game.gems.length;
      game.update(0.016, input);
      expect(game.isGameWon, isTrue);

      // Reset works
      game.reset();
      expect(game.score, 0);
      expect(game.isGameWon, isFalse);
      expect(game.gems.every((g) => !g.collected), isTrue);
    });

    test('Hitting the hazard triggers game over', () async {
      final game = GemCollectorGame();
      final renderer = Renderer(64, 36);
      await game.load(renderer);

      // Move player into hazard position
      game.playerX = game.hazardX;
      game.playerZ = game.hazardZ;

      final input = Input();
      game.update(0.016, input);

      expect(game.isGameOver, isTrue);
    });
  });
}
