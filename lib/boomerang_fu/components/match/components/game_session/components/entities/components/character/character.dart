import 'dart:typed_data';
import 'package:flutter_game_engine/boomerang_fu/components/match_config/match_config.dart';
import 'package:flutter_game_engine/engine/engine.dart';

class Character {
  final int id;
  final String name;
  final int teamId;
  final bool isPlayer;

  double x = 0;
  double y = 0.8;
  double z = 0;
  double yaw = 0;
  double pitch = 0;

  bool isAlive = true;
  bool hasBoomerang = true;
  double respawnTimer = 0.0;
  double slashCooldown = 0.0;
  double slashActiveTimer = 0.0;

  // Visual meshes
  static Mesh? _bodyMesh;
  static Mesh? _headbandMesh;
  static Mesh? _faceMesh;
  static Mesh? _headbandKnotMesh;
  static Mesh? _trailingRibbonsMesh;
  static Mesh? _aimArrowMesh;
  static Mesh? _heldBoomerangMesh;

  static final Map<int, Texture> _teamTextures = {};
  static final Map<int, Texture> _teamFaceTextures = {};
  static Texture? _bodyTexture;
  static Texture? _heldBoomerangTexture;

  Character({
    required this.id,
    required this.name,
    required this.teamId,
    this.isPlayer = false,
  }) {
    _ensureMeshes();
  }

  void spawnAt(double startX, double startZ, double startYaw) {
    x = startX;
    z = startZ;
    yaw = startYaw;
    isAlive = true;
    hasBoomerang = true;
    respawnTimer = 0.0;
    slashCooldown = 0.0;
    slashActiveTimer = 0.0;
  }

  void kill() {
    isAlive = false;
    hasBoomerang = false;
    respawnTimer = 3.0; // 3 seconds respawn
  }

  void update(double dt) {
    if (slashCooldown > 0) slashCooldown -= dt;
    if (slashActiveTimer > 0) slashActiveTimer -= dt;

    if (!isAlive) {
      respawnTimer -= dt;
    }
  }

  static void _ensureMeshes() {
    if (_bodyMesh != null) return;

    // 1. Smooth food-like body with beveled vertical edges and beveled top (Boomerang Fu style)
    final bodyB = MeshBuilder()
      ..addRoundedBox(-0.38, 0.0, -0.38, 0.38, 1.10, 0.38, chamfer: 0.08, topBevel: 0.04);
    _bodyMesh = bodyB.build();

    // 2. Team martial arts headband wrapped around the upper head
    final headbandB = MeshBuilder()
      ..addRoundedBox(-0.395, 0.90, -0.395, 0.395, 1.12, 0.395, chamfer: 0.08, topBevel: 0.02);
    _headbandMesh = headbandB.build();

    // 3. Kawaii expressive cartoon face on front (+Z), subtly tilted back to face top-down 60° camera
    final faceB = MeshBuilder()
      ..addQuad(
        [-0.36, 0.22, 0.39],
        [0.36, 0.22, 0.39],
        [0.36, 1.08, 0.34],
        [-0.36, 1.08, 0.34],
      );
    _faceMesh = faceB.build();

    // 4. Martial arts headband knot on the BACK of head (-Z)
    final knotB = MeshBuilder()
      ..addBox(-0.08, 0.88, -0.47, 0.08, 1.04, -0.39);
    _headbandKnotMesh = knotB.build();

    // 5. Two dynamic cloth ribbon tails streaming backwards from the knot
    final ribbonB = MeshBuilder()
      // Left ribbon tail fluttering back-left and downward
      ..addQuad(
        [-0.04, 0.98, -0.45],
        [-0.14, 0.98, -0.45],
        [-0.22, 0.65, -0.72],
        [-0.12, 0.65, -0.72],
      )
      // Right ribbon tail fluttering back-right and downward
      ..addQuad(
        [0.14, 0.98, -0.45],
        [0.04, 0.98, -0.45],
        [0.12, 0.62, -0.75],
        [0.22, 0.62, -0.75],
      );
    _trailingRibbonsMesh = ribbonB.build();

    // 6. Forward aim indicator chevron on the floor
    final arrowB = MeshBuilder()
      ..addQuad(
        [-0.22, 0.02, 0.40],
        [0.22, 0.02, 0.40],
        [0.0, 0.02, 0.95],
        [0.0, 0.02, 0.95],
      );
    _aimArrowMesh = arrowB.build();

    // 7. Boomerang held ready in forward-right hand
    final heldB = MeshBuilder()
      ..addBox(0.22, 0.50, 0.12, 0.46, 0.56, 0.28)
      ..addBox(0.28, 0.50, 0.04, 0.40, 0.56, 0.36);
    _heldBoomerangMesh = heldB.build();

    // Textures
    _bodyTexture = Texture(1, 1, Uint32List.fromList([Texture.rgb(250, 248, 242)]));
    _heldBoomerangTexture = Texture(1, 1, Uint32List.fromList([Texture.rgb(255, 195, 25)]));
  }

  static Texture _getTeamTexture(int teamId) {
    if (!_teamTextures.containsKey(teamId)) {
      final team = TeamConfig.predefinedTeams.firstWhere(
        (t) => t.id == teamId,
        orElse: () => TeamConfig.predefinedTeams[0],
      );
      _teamTextures[teamId] = Texture(1, 1, Uint32List.fromList([team.colorRgb]));
    }
    return _teamTextures[teamId]!;
  }

  static Texture _getTeamFaceTexture(int teamId) {
    if (!_teamFaceTextures.containsKey(teamId)) {
      final team = TeamConfig.predefinedTeams.firstWhere(
        (t) => t.id == teamId,
        orElse: () => TeamConfig.predefinedTeams[0],
      );
      _teamFaceTextures[teamId] = _generateFaceTexture(team.colorRgb);
    }
    return _teamFaceTextures[teamId]!;
  }

  /// Generates a high-definition 64x64 cartoon face texture with big glossy eyes,
  /// sparkle specular catchlights, blushing cheeks, smile, and team headband.
  static Texture _generateFaceTexture(int teamColorRgb) {
    const w = 64;
    const h = 64;
    final px = Uint32List(w * h);

    // Warm kawaii cream body base color
    final baseCol = Texture.rgb(250, 248, 242);
    px.fillRange(0, px.length, baseCol);

    // Martial arts headband at top (y: 2..16)
    final bandCol = teamColorRgb;
    for (int y = 2; y <= 16; y++) {
      for (int x = 0; x < w; x++) {
        px[y * w + x] = bandCol;
      }
    }
    // Headband shadow trim line
    final bandShadow = Texture.rgb(
      ((teamColorRgb & 0xFF) * 0.75).toInt(),
      (((teamColorRgb >> 8) & 0xFF) * 0.75).toInt(),
      (((teamColorRgb >> 16) & 0xFF) * 0.75).toInt(),
    );
    for (int x = 0; x < w; x++) {
      px[17 * w + x] = bandShadow;
    }

    // Facial feature palette
    final eyeWhite = Texture.rgb(255, 255, 255);
    final eyeBlack = Texture.rgb(22, 22, 28);
    final blush = Texture.rgb(255, 145, 160);
    final smileCol = Texture.rgb(32, 28, 35);
    final smileTongue = Texture.rgb(245, 110, 125);

    // Draw cartoon eye with pupil and double sparkle highlights
    void drawEye(int cx, int cy) {
      // 1. Sclera (White eye background: 8x10 oval)
      for (int y = cy - 10; y <= cy + 10; y++) {
        for (int x = cx - 8; x <= cx + 8; x++) {
          final dx = (x - cx) / 8.0;
          final dy = (y - cy) / 10.0;
          if (dx * dx + dy * dy <= 1.0) {
            px[y * w + x] = eyeWhite;
          }
        }
      }
      // 2. Pupil (Dark glossy iris looking forward: 5.5x7.5 oval)
      for (int y = cy - 8; y <= cy + 8; y++) {
        for (int x = cx - 6; x <= cx + 6; x++) {
          final dx = (x - cx) / 5.5;
          final dy = (y - cy) / 7.5;
          if (dx * dx + dy * dy <= 1.0) {
            px[y * w + x] = eyeBlack;
          }
        }
      }
      // 3. Primary Specular Catchlight (large white shine in top-left)
      final hx1 = cx - 2;
      final hy1 = cy - 4;
      for (int y = hy1 - 2; y <= hy1 + 2; y++) {
        for (int x = hx1 - 2; x <= hx1 + 2; x++) {
          final dx = x - hx1;
          final dy = y - hy1;
          if (dx * dx + dy * dy <= 4.5) {
            px[y * w + x] = eyeWhite;
          }
        }
      }
      // 4. Secondary Specular Shine (small white dot in bottom-right)
      final hx2 = cx + 2;
      final hy2 = cy + 3;
      px[hy2 * w + hx2] = eyeWhite;
      px[(hy2 + 1) * w + hx2] = eyeWhite;
    }

    drawEye(20, 32); // Left eye
    drawEye(44, 32); // Right eye

    // Blushing cheeks: cute soft pink ovals below eyes
    void drawCheek(int cx, int cy) {
      for (int y = cy - 3; y <= cy + 3; y++) {
        for (int x = cx - 5; x <= cx + 5; x++) {
          final dx = (x - cx) / 5.0;
          final dy = (y - cy) / 3.0;
          if (dx * dx + dy * dy <= 1.0) {
            px[y * w + x] = blush;
          }
        }
      }
    }
    drawCheek(12, 44);
    drawCheek(52, 44);

    // Cheerful cute open smile with tongue
    for (int y = 46; y <= 54; y++) {
      for (int x = 24; x <= 40; x++) {
        final dx = (x - 32) / 8.0;
        final dy = (y - 46) / 8.0;
        if (dx * dx + dy * dy <= 1.0 && y >= 46) {
          px[y * w + x] = (y >= 50 && dx.abs() < 0.6) ? smileTongue : smileCol;
        }
      }
    }
    // Smile outline arc
    for (int x = 23; x <= 41; x++) {
      final dx = (x - 32) / 9.0;
      final y = (46 + (dx * dx) * 7.5).round();
      if (y < h) {
        px[y * w + x] = smileCol;
        if (y + 1 < h) px[(y + 1) * w + x] = smileCol;
      }
    }

    return Texture(w, h, px);
  }

  void render(Renderer renderer, Camera camera) {
    if (!isAlive) return;

    final teamTex = _getTeamTexture(teamId);
    final faceTex = _getTeamFaceTexture(teamId);

    // 1. Draw smooth rounded main body (rotates in 3D with character yaw!)
    renderer.drawMesh(
      _bodyMesh!,
      _bodyTexture!,
      camera,
      px: x,
      py: 0,
      pz: z,
      rotY: yaw,
    );

    // 2. Draw team martial arts headband
    renderer.drawMesh(
      _headbandMesh!,
      teamTex,
      camera,
      px: x,
      py: 0,
      pz: z,
      rotY: yaw,
    );

    // 3. Draw high-definition expressive kawaii face on the front (+Z)
    renderer.drawMesh(
      _faceMesh!,
      faceTex,
      camera,
      px: x,
      py: 0,
      pz: z,
      rotY: yaw,
    );

    // 4. Draw headband knot on the BACK (-Z)
    renderer.drawMesh(
      _headbandKnotMesh!,
      teamTex,
      camera,
      px: x,
      py: 0,
      pz: z,
      rotY: yaw,
    );

    // 5. Draw fluttering ribbon tails on the back
    renderer.drawMesh(
      _trailingRibbonsMesh!,
      teamTex,
      camera,
      px: x,
      py: 0,
      pz: z,
      rotY: yaw,
    );

    // 6. Draw forward aim indicator on floor
    renderer.drawMesh(
      _aimArrowMesh!,
      teamTex,
      camera,
      px: x,
      py: 0,
      pz: z,
      rotY: yaw,
    );

    // 7. Draw held boomerang ready in hand (when holding weapon)
    if (hasBoomerang && _heldBoomerangMesh != null) {
      renderer.drawMesh(
        _heldBoomerangMesh!,
        _heldBoomerangTexture!,
        camera,
        px: x,
        py: 0,
        pz: z,
        rotY: yaw,
      );
    }
  }
}
