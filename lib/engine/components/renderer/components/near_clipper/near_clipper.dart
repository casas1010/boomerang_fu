import 'dart:typed_data';

/// Sutherland-Hodgman clip of a polygon against the near plane (z = [near]).
/// Vertices are packed as 5 doubles: x, y, z (camera space), u, v.
class NearClipper {
  static const double near = 0.1;

  /// Result of the last [clip] call.
  final Float64List out = Float64List(5 * 8);

  /// Clips the first [n] vertices of [poly]; returns the output vertex count.
  int clip(Float64List poly, int n) {
    var o = 0;
    for (var i = 0; i < n; i++) {
      final a = i * 5, b = ((i + 1) % n) * 5;
      final az = poly[a + 2], bz = poly[b + 2];
      final ain = az >= near, bin = bz >= near;
      if (ain) {
        for (var k = 0; k < 5; k++) {
          out[o * 5 + k] = poly[a + k];
        }
        o++;
      }
      if (ain != bin) {
        final t = (near - az) / (bz - az);
        for (var k = 0; k < 5; k++) {
          out[o * 5 + k] = poly[a + k] + (poly[b + k] - poly[a + k]) * t;
        }
        out[o * 5 + 2] = near;
        o++;
      }
    }
    return o;
  }
}
