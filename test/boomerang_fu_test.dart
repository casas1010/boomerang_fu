import 'dart:typed_data';
import 'package:flutter/material.dart' hide Texture;
import 'package:flutter_game_engine/boomerang_fu/boomerang_fu_app.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match_config/match_config.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/camera_controller/camera_controller.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/components/entities/components/character/character.dart';
import 'package:flutter_game_engine/boomerang_fu/components/match/components/game_session/game_session.dart';
import 'package:flutter_game_engine/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Boomerang Fu Core Systems', () {
    test('MatchConfig produces valid team list and participant counts', () {
      const config = MatchConfig(
        numGroups: 3,
        botsPerGroup: 2,
        playerTeamIndex: 1,
      );

      expect(config.activeTeams.length, 3);
      expect(config.activeTeams[0].name, 'Team Red');
      expect(config.activeTeams[1].name, 'Team Blue');
      expect(config.activeTeams[2].name, 'Team Green');
    });

    test('Camera Controller toggles between Top-Down and FPV, setting pitch parallel to ground', () {
      final session = GameSession(config: const MatchConfig());
      expect(session.cameraController.mode, ViewMode.topDown);

      // Toggle to FPV
      session.toggleView();
      expect(session.cameraController.mode, ViewMode.firstPerson);
      // Pitch should be 0.0 (parallel with ground)
      expect(session.camera.pitch, 0.0);

      // Toggle back to Top-Down
      session.toggleView();
      expect(session.cameraController.mode, ViewMode.topDown);
      // Pitch should be angled downward for isometric view
      expect(session.camera.pitch, greaterThan(0.5));
    });

    test('Strafing in FPV does not rotate camera yaw', () async {
      final session = GameSession(config: const MatchConfig());
      final renderer = Renderer(64, 36);
      await session.load(renderer);

      // Switch to FPV
      session.toggleView();
      session.camera.yaw = 0.0;
      session.camera.pitch = 0.0;

      // Simulate holding 'A' key (strafe left)
      final input = Input()..stickX = -1.0;
      session.update(0.016, input);

      // Camera yaw must remain unchanged (no spin feedback loop)
      expect(session.camera.yaw, 0.0);
      expect(session.camera.pitch, 0.0);
    });

    test('Simulation processes characters, commands and bots', () async {
      final session = GameSession(config: const MatchConfig(numGroups: 2, botsPerGroup: 1));
      final renderer = Renderer(64, 36);
      await session.load(renderer);

      expect(session.entityManager.characters.length, 4); // 2 teams x 2 characters
      final player = session.entityManager.player;
      expect(player, isNotNull);
      expect(player!.isPlayer, isTrue);
      expect(player.hasBoomerang, isTrue);

      // Trigger throw
      session.triggerThrow();
      session.update(0.016, Input());

      // Boomerang should have been thrown
      expect(session.entityManager.boomerangs.length, 1);
      expect(player.hasBoomerang, isFalse);
    });

    test('Graphics engine supports smooth edges (no snap) and model rotation', () {
      final renderer = Renderer(64, 36);
      expect(renderer.snap, isFalse, reason: 'Vertex snapping disabled for smooth Nintendo Switch-like edges');

      // Test rotation in drawMesh
      final meshBuilder = MeshBuilder()
        ..addQuad([-1, -1, 0], [1, -1, 0], [1, 1, 0], [-1, 1, 0]);
      final mesh = meshBuilder.build();
      final tex = Texture(1, 1, Uint32List.fromList([Texture.rgb(255, 255, 255)]));
      final cam = Camera()..f = 30;

      // Draw facing camera vs rotated 90 degrees
      renderer.clear();
      renderer.drawMesh(mesh, tex, cam, pz: 3, rotY: 0.0);
      final centerPixelFront = renderer.framebuffer[18 * 64 + 32];
      expect(centerPixelFront, isNot(renderer.skyColor));

      // Characters rotate with yaw and render face/features without error
      final char = Character(id: 0, name: 'Hero', teamId: 0, isPlayer: true);
      char.yaw = 1.57; // 90 degrees
      renderer.clear();
      char.render(renderer, cam);
    });
  });

  group('Boomerang Fu UI Flow', () {
    testWidgets('Lobby screen renders team selector and navigates to ArenaPicker', (tester) async {
      tester.view.physicalSize = const Size(1024, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: BoomerangFuApp(),
        ),
      );

      // Verify Screen 1: Lobby elements
      expect(find.text('Boomerang Fu 3D'), findsOneWidget);
      expect(find.text('Match Setup'), findsOneWidget);
      expect(find.text('Number of Teams / Groups'), findsOneWidget);
      expect(find.text('Select Arena'), findsOneWidget);

      // Change teams to 3 Teams
      await tester.tap(find.text('3 Teams'));
      await tester.pumpAndSettle();

      // Ensure button is visible before tapping
      final selectArenaBtn = find.text('Select Arena');
      await tester.ensureVisible(selectArenaBtn);
      await tester.tap(selectArenaBtn);
      await tester.pumpAndSettle();

      // Verify Screen 2: Arena Picker
      expect(find.text('Select Battle Arena'), findsOneWidget);
      expect(find.text('The Stone Dojo Arena'), findsOneWidget);
      expect(find.text('START BATTLE'), findsOneWidget);
    });
  });
}
