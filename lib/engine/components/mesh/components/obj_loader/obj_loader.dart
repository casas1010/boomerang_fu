import '../../mesh.dart';
import '../mesh_builder/mesh_builder.dart';

/// Minimal Wavefront OBJ loader (v / vt / f, polygons are fan-triangulated).
/// Vertices are split per unique (position, uv) pair.
Mesh loadObj(String source) {
  final pos = <List<double>>[];
  final tex = <List<double>>[];
  final b = MeshBuilder();
  final cache = <String, int>{};

  for (final raw in source.split('\n')) {
    final line = raw.trim();
    if (line.startsWith('v ')) {
      final p = line.split(RegExp(r'\s+'));
      pos.add([double.parse(p[1]), double.parse(p[2]), double.parse(p[3])]);
    } else if (line.startsWith('vt ')) {
      final p = line.split(RegExp(r'\s+'));
      // OBJ v origin is bottom-left; image origin is top-left.
      tex.add([double.parse(p[1]), 1.0 - double.parse(p[2])]);
    } else if (line.startsWith('f ')) {
      final idx = <int>[];
      for (final tok in line.substring(2).trim().split(RegExp(r'\s+'))) {
        idx.add(
          cache.putIfAbsent(tok, () {
            final parts = tok.split('/');
            final p = pos[int.parse(parts[0]) - 1];
            var u = 0.0, v = 0.0;
            if (parts.length > 1 && parts[1].isNotEmpty) {
              final t = tex[int.parse(parts[1]) - 1];
              u = t[0];
              v = t[1];
            }
            return b.addVertex(p[0], p[1], p[2], u, v);
          }),
        );
      }
      for (var i = 1; i < idx.length - 1; i++) {
        b.addTriangle(idx[0], idx[i], idx[i + 1]);
      }
    }
  }
  return b.build();
}
