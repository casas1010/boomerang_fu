import 'dart:typed_data';

/// Indexed triangle mesh with per-vertex UVs.
class Mesh {
  final Float32List verts; // x,y,z
  final Float32List uvs; // u,v
  final Int32List faces; // triples of vertex indices

  Mesh(this.verts, this.uvs, this.faces);

  int get faceCount => faces.length ~/ 3;
}
