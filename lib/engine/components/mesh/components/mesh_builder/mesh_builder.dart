import 'dart:typed_data';

import '../../mesh.dart';

/// Incrementally builds a [Mesh].
class MeshBuilder {
  final List<double> _v = [];
  final List<double> _uv = [];
  final List<int> _f = [];

  int addVertex(double x, double y, double z, double u, double v) {
    _v.addAll([x, y, z]);
    _uv.addAll([u, v]);
    return _uv.length ~/ 2 - 1;
  }

  void addTriangle(int a, int b, int c) => _f.addAll([a, b, c]);

  /// Quad a,b,c,d; [uRep]/[vRep] tile the texture.
  void addQuad(
    List<double> a,
    List<double> b,
    List<double> c,
    List<double> d, {
    double uRep = 1,
    double vRep = 1,
  }) {
    final i0 = addVertex(a[0], a[1], a[2], 0, vRep);
    final i1 = addVertex(b[0], b[1], b[2], uRep, vRep);
    final i2 = addVertex(c[0], c[1], c[2], uRep, 0);
    final i3 = addVertex(d[0], d[1], d[2], 0, 0);
    addTriangle(i0, i1, i2);
    addTriangle(i0, i2, i3);
  }

  /// Axis aligned box (no bottom face) with textures tiled every [tile] units.
  void addBox(
    double x0,
    double y0,
    double z0,
    double x1,
    double y1,
    double z1, {
    double tile = 2,
  }) {
    final w = (x1 - x0).abs() / tile, h = (y1 - y0).abs() / tile;
    final d = (z1 - z0).abs() / tile;
    addQuad(
      [x0, y0, z0],
      [x1, y0, z0],
      [x1, y1, z0],
      [x0, y1, z0],
      uRep: w,
      vRep: h,
    );
    addQuad(
      [x1, y0, z1],
      [x0, y0, z1],
      [x0, y1, z1],
      [x1, y1, z1],
      uRep: w,
      vRep: h,
    );
    addQuad(
      [x0, y0, z1],
      [x0, y0, z0],
      [x0, y1, z0],
      [x0, y1, z1],
      uRep: d,
      vRep: h,
    );
    addQuad(
      [x1, y0, z0],
      [x1, y0, z1],
      [x1, y1, z1],
      [x1, y1, z0],
      uRep: d,
      vRep: h,
    );
    addQuad(
      [x0, y1, z0],
      [x1, y1, z0],
      [x1, y1, z1],
      [x0, y1, z1],
      uRep: w,
      vRep: d,
    );
  }

  /// Creates a rounded/chamfered box with 8 beveled vertical faces and beveled top.
  void addRoundedBox(
    double x0,
    double y0,
    double z0,
    double x1,
    double y1,
    double z1, {
    double chamfer = 0.08,
    double topBevel = 0.04,
  }) {
    // 8 points around base (y0)
    final bx = [
      [x1 - chamfer, z1],
      [x1, z1 - chamfer],
      [x1, z0 + chamfer],
      [x1 - chamfer, z0],
      [x0 + chamfer, z0],
      [x0, z0 + chamfer],
      [x0, z1 - chamfer],
      [x0 + chamfer, z1],
    ];

    // 8 points at top edge (y1)
    final tx = [
      [x1 - chamfer - topBevel, z1 - topBevel],
      [x1 - topBevel, z1 - chamfer - topBevel],
      [x1 - topBevel, z0 + chamfer + topBevel],
      [x1 - chamfer - topBevel, z0 + topBevel],
      [x0 + chamfer + topBevel, z0 + topBevel],
      [x0 + topBevel, z0 + chamfer + topBevel],
      [x0 + topBevel, z1 - chamfer - topBevel],
      [x0 + chamfer + topBevel, z1 - topBevel],
    ];

    // 8 vertical side quads
    for (int i = 0; i < 8; i++) {
      final next = (i + 1) % 8;
      addQuad(
        [bx[i][0], y0, bx[i][1]],
        [bx[next][0], y0, bx[next][1]],
        [tx[next][0], y1, tx[next][1]],
        [tx[i][0], y1, tx[i][1]],
      );
    }

    // Top cap (fan triangles around center)
    final cx = (x0 + x1) * 0.5;
    final cz = (z0 + z1) * 0.5;
    final topCenterIdx = addVertex(cx, y1, cz, 0.5, 0.5);
    final topIndices = <int>[];
    for (int i = 0; i < 8; i++) {
      topIndices.add(addVertex(tx[i][0], y1, tx[i][1], 0, 0));
    }
    for (int i = 0; i < 8; i++) {
      final next = (i + 1) % 8;
      addTriangle(topCenterIdx, topIndices[next], topIndices[i]);
    }
  }

  Mesh build() => Mesh(
    Float32List.fromList(_v),
    Float32List.fromList(_uv),
    Int32List.fromList(_f),
  );
}
