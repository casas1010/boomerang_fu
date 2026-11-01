import 'dart:typed_data';

import 'package:flutter/material.dart' hide Texture;
import 'package:flutter_game_engine/engine/engine.dart';
import 'package:flutter_game_engine/main.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockGame implements Game {
  @override
  final Camera camera = Camera();

  @override
  Future<void> load(Renderer renderer) async {}

  @override
  void update(double dt, Input input) {}

  @override
  void render(Renderer renderer) {}

  @override
  void onKeyDown(dynamic key) {}

  @override
  void onPrimaryAction() {}

  @override
  Widget buildOverlay(BuildContext context, double fps) =>
      Text('FPS: ${fps.toStringAsFixed(0)}');
}

void main() {
  test('engine renders a quad in front of the camera', () {
    final r = Renderer(64, 36);
    final b = MeshBuilder()
      ..addQuad([-1, -1, 3], [1, -1, 3], [1, 1, 3], [-1, 1, 3]);
    final tex = Texture(2, 2, Uint32List.fromList([1, 1, 1, 1]));
    final cam = Camera()..f = 30;
    r.clear();
    r.drawMesh(b.build(), tex, cam);
    expect(r.framebuffer[18 * 64 + 32], isNot(r.skyColor));
    expect(r.framebuffer[0], r.skyColor);
  });

  testWidgets('Engine widget mounts and composes modular components',
      (tester) async {
    final game = _MockGame();
    await tester.pumpWidget(
      MaterialApp(
        home: Engine(game: game, width: 64, height: 36),
      ),
    );

    // Verify sub-components are present in the composite tree
    expect(find.byType(EngineInputHandler), findsOneWidget);
    expect(find.byType(EngineViewport), findsOneWidget);
    expect(find.byType(EngineOverlay), findsOneWidget);
    expect(find.byType(EngineJoystick), findsOneWidget);

    // Initial state before frame is ready shows circular progress indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('EngineJoystick only renders when joystick state is active',
      (tester) async {
    final game = _MockGame();
    final controller = EngineController(game: game, width: 64, height: 36);

    await tester.pumpWidget(
      MaterialApp(
        home: Engine(game: game, controller: controller),
      ),
    );

    // Initially joystick is null, so no circle avatar
    expect(find.byType(CircleAvatar), findsNothing);

    // Activate joystick notifier
    controller.joystickNotifier.value = const JoystickState(
      origin: Offset(100, 100),
      position: Offset(110, 110),
      radius: 60,
    );
    await tester.pump();

    // Circle avatar knob should now be visible
    expect(find.byType(CircleAvatar), findsOneWidget);

    // Deactivate joystick
    controller.joystickNotifier.value = null;
    await tester.pump();
    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('GameLauncher mounts and can open tutorial game', (tester) async {
    tester.view.physicalSize = const Size(1024, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: GameLauncher(),
      ),
    );

    expect(find.text('Tutorial: Gem Collector 3D'), findsOneWidget);
    expect(find.text('Boomerang Fu 3D'), findsOneWidget);

    // Tap tutorial game button
    await tester.tap(find.text('Play Tutorial Game'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Engine is mounted
    expect(find.byType(Engine), findsOneWidget);
  });
}
