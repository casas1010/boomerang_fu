# Flutter Retro 3D Game Engine

A lightweight, retro PlayStation 1 (PS1) style 3D software rasterizer built natively in Dart and Flutter. It renders 3D polygonal scenes completely on the CPU into a raw pixel framebuffer, presented with authentic nearest-neighbor scaling and classic 5th-generation console aesthetics.

---

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Controls](#controls)
- [Architecture Overview](#architecture-overview)
  - [Composite Design & Modularity](#composite-design--modularity)
  - [High-Performance Reactive Notifiers](#high-performance-reactive-notifiers)
- [Step-by-Step Guide: Building a Game](#step-by-step-guide-building-a-game)
  - [1. Implement the `Game` Interface](#1-implement-the-game-interface)
  - [2. Host the Game with the `Engine` Widget](#2-host-the-game-with-the-engine-widget)
- [Core Components & API Reference](#core-components--api-reference)
  - [Engine](#engine)
  - [EngineController](#enginecontroller)
  - [Modular Engine UI Components](#modular-engine-ui-components)
  - [Renderer](#renderer)
  - [Camera](#camera)
  - [Mesh & MeshBuilder](#mesh--meshbuilder)
  - [Loading 3D Models (.obj)](#loading-3d-models-obj)
  - [Textures & Pixel Formats](#textures--pixel-formats)
  - [Input Handling](#input-handling)
  - [Flutter UI Overlays (HUD)](#flutter-ui-overlays-hud)
- [Project Structure](#project-structure)

---

## Features

- **Pure Dart Software Rasterizer**: No external 3D libraries or native shader pipelines required; runs everywhere Flutter runs (macOS, Windows, Linux, iOS, Android, Web).
- **Composite Architecture & Separation of Concerns (SoC)**: Built using clean composite UI design and reactive controller decoupling.
- **Granular Reactive Notifiers**: Zero top-level `setState()` calls during rendering. Fast 60 FPS updates only invalidate the exact leaf viewport, eliminating unnecessary widget tree rebuilds.
- **Iconic PS1 Visual Quirks**:
  - **Affine Texture Mapping**: Toggle between perspective-correct and affine texture mapping to recreate nostalgic texture warping.
  - **Vertex Jitter / Grid Snapping**: Simulates fixed-point geometry quantization by snapping screen-space projected vertices to whole pixels.
  - **Low-Resolution Framebuffer**: Renders at authentic low resolutions (default 480×270 or 320×240) scaled with zero filtering (`FilterQuality.none`).
- **Depth Buffering & Near-Plane Clipping**: Software $1/z$ depth buffer and geometric polygon clipper to prevent near-plane clipping artifacts.
- **Wavefront OBJ Support**: Minimal `.obj` loader supporting vertices, UV coordinates, and triangulated faces.
- **Procedural Geometry & Textures**: Built-in `MeshBuilder` for quads, boxes, and custom triangles with texture tiling, plus procedural texture synthesis.
- **Cross-Platform Input**: First-person keyboard and mouse-look for desktop, plus an automatic dual-touch virtual stick and swipe-to-look system for mobile devices.
- **Flutter Widget Overlay Integration**: Layer native Flutter widgets (HUD, menus, crosshairs) seamlessly over the 3D canvas.

---

## Quick Start

### 1. Run the Included PS1 Demo

Clone or open the repository and run the demo:

```bash
# Get dependencies
flutter pub get

# Run on macOS (or windows, linux, chrome, mobile)
flutter run -d macos
```

Run tests to verify the software rasterizer and modular engine widgets:

```bash
flutter test
```

---

## Controls

### Desktop Controls

| Action | Control |
|---|---|
| **Move (Forward / Back / Strafe)** | `W`, `A`, `S`, `D` |
| **Look Around** | Mouse movement (click inside window to capture cursor) |
| **Alternative Look** | Arrow Keys (`Up`, `Down`, `Left`, `Right`) |
| **Release Mouse Cursor** | `Esc` |
| **Toggle Affine Texture Warping** | `T` |
| **Toggle Vertex Grid Snapping (Jitter)** | `V` |
| **Toggle Free Fly Mode** | `F` |
| **Fly Up / Down (in Fly Mode)** | `Space` / `Left Shift` |

### Mobile Touch Controls

- **Left Half of Screen**: Drag anywhere to activate the virtual analog joystick (move & strafe).
- **Right Half of Screen**: Drag / swipe to look around.

---

## Architecture Overview

The engine follows **Separation of Concerns (SoC)** and **Composite Design**:

```
┌─────────────────────────────────────────────────────────────┐
│                        Engine Widget                        │
│                (Declarative Scaffold & Stack)               │
└──────────────────────────────┬──────────────────────────────┘
                               │
       ┌───────────────────────┼────────────────────────┐
       ▼                       ▼                        ▼
┌──────────────┐     ┌───────────────────┐    ┌──────────────────┐
│ EngineInput  │     │  EngineViewport   │    │  EngineJoystick  │
│  (Focus &    │     │ (ValueListenable: │    │(ValueListenable: │
│ Pointer Area)│     │  frameNotifier)   │    │ joystickNotifier)│
└──────────────┘     └───────────────────┘    └──────────────────┘
                               ▲
                               │
               ┌───────────────┴───────────────┐
               │       EngineController        │
               │ (Ticker Loop • Frame Decoding │
               │  Input Dispatch • Notifiers)  │
               └───────────────┬───────────────┘
                               │
                ┌──────────────┴──────────────┐
                ▼                             ▼
     ┌────────────────────┐        ┌────────────────────┐
     │   Game Contract    │        │ Software Renderer  │
     │  load()            │        │ framebuffer (RGBA) │
     │  update(dt, input) │ ──────>│ depth buffer (1/z) │
     │  render(renderer)  │        │ drawMesh(...)      │
     │  buildOverlay()    │        └────────────────────┘
     └────────────────────┘
```

### Composite Design & Modularity

The top-level `Engine` widget delegates each visual and interactive responsibility to dedicated modular components:
- **`EngineInputHandler`**: Encapsulates keyboard focus, mouse cursor capture, and pointer listeners.
- **`EngineViewport`**: Renders the letterboxed aspect ratio and nearest-neighbour `RawImage` frame.
- **`EngineOverlay`**: Binds the game's custom HUD overlay and propagates the live FPS counter.
- **`EngineJoystick`**: Renders the touch analog stick and knob circle only when active.

### High-Performance Reactive Notifiers

Rather than calling `setState()` on `_EngineState` every frame (which would needlessly dirty the entire widget subtree 60 times a second), state is separated into granular `ValueNotifier`s on `EngineController`:
- `frameNotifier`: Decoded `ui.Image?` frame.
- `fpsNotifier`: Real-time moving average frame rate.
- `loadedNotifier`: Initialization status.
- `mouseLookNotifier`: Mouse pointer capture & cursor visibility.
- `joystickNotifier`: Active touch stick geometry (`JoystickState?`).

Each component rebuilds only its own leaf elements via `ValueListenableBuilder`.

---

## Step-by-Step Guide: Building a Game

### 1. Implement the `Game` Interface

Create your game class implementing `Game`:

```dart
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_game_engine/engine/engine.dart';

class MySpinningCubeGame implements Game {
  @override
  final Camera camera = Camera();

  late final Mesh _cubeMesh;
  late final Texture _cubeTexture;
  double _rotation = 0;

  @override
  Future<void> load(Renderer renderer) async {
    // 1. Position camera
    camera.x = 0;
    camera.y = 1.5;
    camera.z = -4;

    // 2. Build procedural box mesh (size 1.5x1.5x1.5)
    final builder = MeshBuilder()
      ..addBox(-0.75, -0.75, -0.75, 0.75, 0.75, 0.75, tile: 1.0);
    _cubeMesh = builder.build();

    // 3. Create a simple 2x2 procedural checker texture
    _cubeTexture = Texture(
      2,
      2,
      Uint32List.fromList([
        Texture.rgb(255, 60, 60),
        Texture.rgb(60, 255, 60),
        Texture.rgb(60, 60, 255),
        Texture.rgb(255, 255, 255),
      ]),
    );

    // Optional: customize clear/sky color
    renderer.skyColor = Texture.rgb(30, 30, 40);
  }

  @override
  void update(double dt, Input input) {
    _rotation += dt;

    // Move camera with WASD or mobile touch stick
    final fwd = input.axis(LogicalKeyboardKey.keyW, LogicalKeyboardKey.keyS) + input.stickY;
    final str = input.axis(LogicalKeyboardKey.keyD, LogicalKeyboardKey.keyA) + input.stickX;
    camera.z += fwd * dt * 4;
    camera.x += str * dt * 4;
  }

  @override
  void render(Renderer renderer) {
    // Draw the mesh at origin (0, 0, 0)
    renderer.drawMesh(_cubeMesh, _cubeTexture, camera, px: 0, py: 0, pz: 0);
  }

  @override
  void onKeyDown(LogicalKeyboardKey key) {
    // Handle one-shot key presses
  }

  @override
  void onPrimaryAction() {
    // Primary action (e.g. mouse click / fire button)
  }

  @override
  Widget buildOverlay(BuildContext context, double fps) {
    // Optional Flutter widgets on top of the 3D frame
    return Positioned(
      top: 16,
      left: 16,
      child: Text(
        'FPS: ${fps.toStringAsFixed(0)}',
        style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
      ),
    );
  }
}
```

### 2. Host the Game with the `Engine` Widget

Set the game inside the `Engine` widget in your `main()` function:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_game_engine/engine/engine.dart';
import 'my_game.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Engine(
        game: MySpinningCubeGame(),
        width: 480,   // Framebuffer width in pixels
        height: 270,  // Framebuffer height in pixels
      ),
    ),
  );
}
```

---

## Core Components & API Reference

### Engine

```dart
Engine({
  Key? key,
  required Game game,
  int width = 480,
  int height = 270,
  EngineController? controller,
})
```

- **`width` & `height`**: Software framebuffer resolution. The engine scales this resolution up with aspect-ratio preservation and nearest-neighbor filtering to achieve the pixelated retro feel.
- **`controller`**: Optional custom `EngineController`. If omitted, `Engine` automatically instantiates and manages its own controller.
- **Declarative Composition**: Composes `EngineInputHandler`, `EngineViewport`, `EngineOverlay`, and `EngineJoystick`.

### EngineController

Owns the simulation loop, ticker, asynchronous frame presentation, and reactive notifiers:

- **`start(TickerProvider tickerProvider)`**: Starts game asset loading and begins the ticker loop.
- **`stop()` / `dispose()`**: Cleans up ticker, focus node, textures, and notifiers.
- **Notifiers**:
  - `ValueNotifier<ui.Image?> frameNotifier`
  - `ValueNotifier<double> fpsNotifier`
  - `ValueNotifier<bool> loadedNotifier`
  - `ValueNotifier<bool> mouseLookNotifier`
  - `ValueNotifier<JoystickState?> joystickNotifier`

### Modular Engine UI Components

- **`EngineViewport`**: Renders `AspectRatio` and `RawImage` (using `FilterQuality.none`) bound to `controller.frameNotifier`.
- **`EngineOverlay`**: Renders `game.buildOverlay(context, fps)` bound to `controller.fpsNotifier` and `loadedNotifier`.
- **`EngineJoystick`**: Renders the touch stick base ring and knob circle bound to `controller.joystickNotifier`.
- **`EngineInputHandler`**: Wraps the viewport with keyboard `Focus`, `Listener` (mouse look & touch gestures), and `MouseRegion` cursor styling.

### Renderer

Accessible via `game.load(renderer)` and `game.render(renderer)`:

- **`renderer.drawMesh(Mesh m, Texture tex, Camera cam, {double px = 0, double py = 0, double pz = 0})`**:
  Transforms the mesh vertices by world position `(px, py, pz)`, rotates/translates into camera space, clips triangles against the near plane, projects into screen space, and rasterizes polygons into the framebuffer with depth testing.
- **`renderer.affine` (`bool`, default `false`)**:
  When `true`, enables affine texture mapping (interpolating $u, v$ in screen-space), creating the iconic PS1 texture warping and distortion on angled surfaces.
- **`renderer.snap` (`bool`, default `true`)**:
  When `true`, snaps projected screen coordinates to whole integers (`roundToDouble()`), giving authentic PS1 vertex jitter/wobble.
- **`renderer.skyColor` (`int`)**:
  Packed 32-bit color (`0xAABBGGRR`) used when clearing the framebuffer each frame.

### Camera

First-person 3D camera:

- **`x`, `y`, `z`**: World coordinates.
- **`yaw`**: Horizontal rotation (radians). Yaw `0` points down $+Z$.
- **`pitch`**: Vertical rotation (radians, clamped to $\pm 89^\circ$).
- **`f`**: Focal length in pixels (default `285`).
- **`sense`**: Mouse-look sensitivity factor (default `0.0025`).
- **`look(double dx, double dy)`**: Updates yaw and pitch based on pointer deltas.

### Mesh & MeshBuilder

#### `Mesh`
Holds raw typed data arrays:
- `verts` (`Float32List`): Flat list of `[x, y, z, ...]` coordinates.
- `uvs` (`Float32List`): Flat list of `[u, v, ...]` texture coordinates.
- `faces` (`Int32List`): Triples of vertex indices.

#### `MeshBuilder`
Helper class for assembling geometry procedurally:

```dart
final builder = MeshBuilder();

// Add individual vertex
final idx = builder.addVertex(x, y, z, u, v);

// Add triangle using vertex indices
builder.addTriangle(i0, i1, i2);

// Add textured quad
builder.addQuad(
  [-1, 0, -1],
  [ 1, 0, -1],
  [ 1, 0,  1],
  [-1, 0,  1],
  uRep: 2.0, // Texture horizontal tiling
  vRep: 2.0, // Texture vertical tiling
);

// Add axis-aligned box (with 5 visible faces, omitting floor)
builder.addBox(minX, minY, minZ, maxX, maxY, maxZ, tile: 2.0);

final Mesh mesh = builder.build();
```

### Loading 3D Models (.obj)

Load standard Wavefront `.obj` files using `loadObj`:

1. Register your model in `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/demo.obj
       - assets/demo.png
   ```

2. Load the asset string in your `load()` method:
   ```dart
   import 'package:flutter/services.dart' show rootBundle;

   final objSource = await rootBundle.loadString('assets/demo.obj');
   final Mesh modelMesh = loadObj(objSource);
   ```

> [!NOTE]
> `loadObj` parses `v` (vertices), `vt` (UV texture coordinates), and `f` (faces). Polygons with 4 or more vertices are automatically fan-triangulated.

### Textures & Pixel Formats

Textures are stored as flat `Uint32List` arrays of packed `0xAABBGGRR` little-endian words, matching Flutter's raw RGBA byte format.

#### From Image Assets (PNG, JPEG, WebP)
```dart
final bytes = (await rootBundle.load('assets/demo.png')).buffer.asUint8List();
final Texture texture = await Texture.fromBytes(bytes);
```

#### Procedural Generation
```dart
// Generate a 16x16 gradient or pattern:
const w = 16, h = 16;
final pixels = Uint32List(w * h);

for (var y = 0; y < h; y++) {
  for (var x = 0; x < w; x++) {
    pixels[y * w + x] = Texture.rgb(x * 16, y * 16, 128);
  }
}

final Texture proceduralTex = Texture(w, h, pixels);
```

### Input Handling

The `Input` class gives access to keyboard queries and the mobile touch stick:

```dart
// Query held keys
final isJumping = input.isDown(LogicalKeyboardKey.space);

// Get axis value between two keys (-1.0, 0.0, or +1.0)
final forwardInput = input.axis(LogicalKeyboardKey.keyW, LogicalKeyboardKey.keyS);

// Virtual touch stick (on mobile, normalized -1.0 to 1.0)
final stickX = input.stickX;
final stickY = input.stickY;
```

### Flutter UI Overlays (HUD)

Return any Flutter widget tree from `buildOverlay(BuildContext context, double fps)` to render crisp vector graphics, text, or interactive buttons over the low-res 3D world:

```dart
@override
Widget buildOverlay(BuildContext context, double fps) {
  return Stack(
    children: [
      // Crosshair
      Center(
        child: Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
      // Stats HUD
      Positioned(
        top: 10,
        left: 10,
        child: Text(
          'FPS: ${fps.toStringAsFixed(0)}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    ],
  );
}
```

---

## Project Structure

```
lib/
├── main.dart                               # App entry point
├── engine/                                 # Core 3D engine composite package
│   ├── engine.dart                         # Declarative Engine widget & public exports
│   └── components/
│       ├── controller/                     # EngineController & reactive ValueNotifiers
│       │   └── controller.dart
│       ├── viewport/                       # Nearest-neighbour letterboxed viewport
│       │   └── viewport.dart
│       ├── overlay/                        # Dynamic HUD overlay integration
│       │   └── overlay.dart
│       ├── joystick/                       # Touch stick state & overlay rendering
│       │   └── joystick.dart
│       ├── input_handler/                  # Keyboard focus & pointer event capture
│       │   └── input_handler.dart
│       ├── camera/                         # First-person 3D camera
│       │   └── camera.dart
│       ├── game/                           # Game contract interface
│       │   └── game.dart
│       ├── input/                          # Polled input state (keys & joystick)
│       │   └── input.dart
│       ├── mesh/
│       │   ├── mesh.dart                   # Triangle mesh data structure
│       │   └── components/
│       │       ├── mesh_builder/           # Procedural box/quad mesh generator
│       │       │   └── mesh_builder.dart
│       │       └── obj_loader/             # Wavefront .obj file parser
│       │           └── obj_loader.dart
│       ├── renderer/
│       │   ├── renderer.dart               # PS1 software rasterizer (z-buffer, affine/snap)
│       │   └── components/
│       │       └── near_clipper/           # Near-plane geometric polygon clipping
│       │           └── near_clipper.dart
│       └── texture/                        # Packed 0xAABBGGRR texture decoding & creation
│           └── texture.dart
└── ps1/                                    # Example game demo implementation
    ├── game.dart                           # Demo Ps1Game implementing Game
    └── components/
        ├── hud/                            # Retro HUD overlay
        │   └── hud.dart
        ├── level/                          # Level geometry, collision & textures
        │   ├── level.dart
        │   └── components/
        │       ├── level_textures/level_textures.dart
        │       ├── placed_object/placed_object.dart
        │       └── wall/wall.dart
        └── player/                         # First-person movement and collision
            └── player.dart
```
# boomerang_fu
