import 'dart:math' as math;
import 'dart:typed_data';

import '../camera/camera.dart';
import '../mesh/mesh.dart';
import '../texture/texture.dart';
import 'components/near_clipper/near_clipper.dart';

/// Smooth cel-shaded 3D software renderer supporting modern anti-aliased graphics
/// with directional sun lighting, sub-pixel rasterization, and arbitrary mesh transformations.
class Renderer {
  final int width, height;
  final Uint32List framebuffer;
  final Float32List depth; // stores 1/z, 0 = empty
  int skyColor = Texture.rgb(130, 205, 245); // Fresh Nintendo sky blue

  /// Affine (PS1 warping) vs perspective-correct texture mapping.
  bool affine = false;

  /// Snap projected vertices to whole pixels (false for smooth sub-pixel rendering like Boomerang Fu).
  bool snap = false;

  // Directional sun light in world space (normalized warm sun from upper-left: -0.38, 0.83, -0.42)
  static const double _sunLightX = -0.384;
  static const double _sunLightY = 0.829;
  static const double _sunLightZ = -0.419;

  double _camLightX = 0;
  double _camLightY = 0;
  double _camLightZ = 0;

  final _clipper = NearClipper();
  final _poly = Float64List(5 * 8);
  Float32List _cs = Float32List(0); // reused camera-space vertex buffer
  double _focal = 285;

  Renderer(this.width, this.height)
    : framebuffer = Uint32List(width * height),
      depth = Float32List(width * height);

  void clear() {
    framebuffer.fillRange(0, framebuffer.length, skyColor);
    depth.fillRange(0, depth.length, 0);
  }

  /// Draws [m] textured with [tex], transformed by translation, rotation, and scale.
  void drawMesh(
    Mesh m,
    Texture tex,
    Camera cam, {
    double px = 0,
    double py = 0,
    double pz = 0,
    double rotY = 0,
    double rotX = 0,
    double rotZ = 0,
    double scale = 1.0,
    bool enableLighting = true,
    bool alphaTest = false,
  }) {
    _focal = cam.f;
    final nv = m.verts.length ~/ 3;
    if (_cs.length < nv * 3) _cs = Float32List(nv * 3);
    final cs = _cs;
    final cy = math.cos(-cam.yaw), sy = math.sin(-cam.yaw);
    final cp = math.cos(-cam.pitch), sp = math.sin(-cam.pitch);

    // Transform sun light direction to camera space for efficient shading
    if (enableLighting) {
      final ltx = _sunLightX * cy + _sunLightZ * sy;
      final ltz = -_sunLightX * sy + _sunLightZ * cy;
      _camLightX = ltx;
      _camLightY = _sunLightY * cp - ltz * sp;
      _camLightZ = _sunLightY * sp + ltz * cp;
    }

    final hasRot = rotY != 0 || rotX != 0 || rotZ != 0;
    final isScaled = scale != 1.0;

    if (!hasRot && !isScaled) {
      // Fast path: pure translation
      for (var i = 0; i < nv; i++) {
        final tx = m.verts[i * 3] + px - cam.x;
        final ty = m.verts[i * 3 + 1] + py - cam.y;
        final tz = m.verts[i * 3 + 2] + pz - cam.z;
        final rx = tx * cy + tz * sy;
        final rz = -tx * sy + tz * cy;
        cs[i * 3] = rx;
        cs[i * 3 + 1] = ty * cp - rz * sp;
        cs[i * 3 + 2] = ty * sp + rz * cp;
      }
    } else {
      // Rotation & scale path
      final cosRy = rotY != 0 ? math.cos(rotY) : 1.0;
      final sinRy = rotY != 0 ? math.sin(rotY) : 0.0;
      final cosRx = rotX != 0 ? math.cos(rotX) : 1.0;
      final sinRx = rotX != 0 ? math.sin(rotX) : 0.0;
      final cosRz = rotZ != 0 ? math.cos(rotZ) : 1.0;
      final sinRz = rotZ != 0 ? math.sin(rotZ) : 0.0;

      for (var i = 0; i < nv; i++) {
        var vx = m.verts[i * 3];
        var vy = m.verts[i * 3 + 1];
        var vz = m.verts[i * 3 + 2];

        if (isScaled) {
          vx *= scale;
          vy *= scale;
          vz *= scale;
        }

        // Rotate around X (pitch)
        if (rotX != 0) {
          final ry = vy * cosRx - vz * sinRx;
          final rz = vy * sinRx + vz * cosRx;
          vy = ry;
          vz = rz;
        }
        // Rotate around Y (yaw)
        if (rotY != 0) {
          final rx = vx * cosRy + vz * sinRy;
          final rz = -vx * sinRy + vz * cosRy;
          vx = rx;
          vz = rz;
        }
        // Rotate around Z (roll)
        if (rotZ != 0) {
          final rx = vx * cosRz - vy * sinRz;
          final ry = vx * sinRz + vy * cosRz;
          vx = rx;
          vy = ry;
        }

        final tx = vx + px - cam.x;
        final ty = vy + py - cam.y;
        final tz = vz + pz - cam.z;
        final rx = tx * cy + tz * sy;
        final rz = -tx * sy + tz * cy;
        cs[i * 3] = rx;
        cs[i * 3 + 1] = ty * cp - rz * sp;
        cs[i * 3 + 2] = ty * sp + rz * cp;
      }
    }

    for (var fi = 0; fi < m.faces.length; fi += 3) {
      for (var k = 0; k < 3; k++) {
        final vi = m.faces[fi + k];
        _poly[k * 5] = cs[vi * 3];
        _poly[k * 5 + 1] = cs[vi * 3 + 1];
        _poly[k * 5 + 2] = cs[vi * 3 + 2];
        _poly[k * 5 + 3] = m.uvs[vi * 2];
        _poly[k * 5 + 4] = m.uvs[vi * 2 + 1];
      }
      const near = NearClipper.near;
      if (_poly[2] < near && _poly[7] < near && _poly[12] < near) continue;

      double shade = 1.0;
      if (enableLighting) {
        final e1x = _poly[5] - _poly[0];
        final e1y = _poly[6] - _poly[1];
        final e1z = _poly[7] - _poly[2];
        final e2x = _poly[10] - _poly[0];
        final e2y = _poly[11] - _poly[1];
        final e2z = _poly[12] - _poly[2];

        final nx = e1y * e2z - e1z * e2y;
        final ny = e1z * e2x - e1x * e2z;
        final nz = e1x * e2y - e1y * e2x;
        final nlen = math.sqrt(nx * nx + ny * ny + nz * nz);

        if (nlen > 1e-6) {
          final dot = (nx * _camLightX + ny * _camLightY + nz * _camLightZ) / nlen;
          final diffuse = dot.clamp(0.0, 1.0);
          shade = (0.60 + 0.40 * diffuse).clamp(0.25, 1.0);
        }
      }

      final count = _clipper.clip(_poly, 3);
      for (var k = 1; k < count - 1; k++) {
        _triangle(tex, _clipper.out, 0, k, k + 1, shade: shade, alphaTest: alphaTest);
      }
    }
  }

  void _triangle(
    Texture tex,
    Float64List p,
    int i0,
    int i1,
    int i2, {
    double shade = 1.0,
    bool alphaTest = false,
  }) {
    final f = _focal;
    final cx = width * 0.5, cy = height * 0.5;
    final z0 = p[i0 * 5 + 2], z1 = p[i1 * 5 + 2], z2 = p[i2 * 5 + 2];
    var x0 = p[i0 * 5] / z0 * f + cx, y0 = -p[i0 * 5 + 1] / z0 * f + cy;
    var x1 = p[i1 * 5] / z1 * f + cx, y1 = -p[i1 * 5 + 1] / z1 * f + cy;
    var x2 = p[i2 * 5] / z2 * f + cx, y2 = -p[i2 * 5 + 1] / z2 * f + cy;
    if (snap) {
      x0 = x0.roundToDouble();
      y0 = y0.roundToDouble();
      x1 = x1.roundToDouble();
      y1 = y1.roundToDouble();
      x2 = x2.roundToDouble();
      y2 = y2.roundToDouble();
    }

    final area = (x2 - x0) * (y1 - y0) - (y2 - y0) * (x1 - x0);
    if (area == 0) return; // degenerate; both windings are drawn

    final u0 = p[i0 * 5 + 3], v0 = p[i0 * 5 + 4];
    final u1 = p[i1 * 5 + 3], v1 = p[i1 * 5 + 4];
    final u2 = p[i2 * 5 + 3], v2 = p[i2 * 5 + 4];

    final minx = math.max(0, math.min(x0, math.min(x1, x2)).floor());
    final maxx = math.min(width - 1, math.max(x0, math.max(x1, x2)).ceil());
    final miny = math.max(0, math.min(y0, math.min(y1, y2)).floor());
    final maxy = math.min(height - 1, math.max(y0, math.max(y1, y2)).ceil());
    if (minx > maxx || miny > maxy) return;

    final inv = 1.0 / area; // dividing by signed area handles either winding
    final iz0 = 1.0 / z0, iz1 = 1.0 / z1, iz2 = 1.0 / z2;
    final uz0 = u0 * iz0, vz0 = v0 * iz0;
    final uz1 = u1 * iz1, vz1 = v1 * iz1;
    final uz2 = u2 * iz2, vz2 = v2 * iz2;

    final a0 = (y2 - y1) * inv, b0 = (x1 - x2) * inv;
    final a1 = (y0 - y2) * inv, b1 = (x2 - x0) * inv;
    final a2 = (y1 - y0) * inv, b2 = (x0 - x1) * inv;

    final sx = minx + 0.5, sy = miny + 0.5;
    var w0r = ((sx - x1) * (y2 - y1) - (sy - y1) * (x2 - x1)) * inv;
    var w1r = ((sx - x2) * (y0 - y2) - (sy - y2) * (x0 - x2)) * inv;
    var w2r = ((sx - x0) * (y1 - y0) - (sy - y0) * (x1 - x0)) * inv;

    final tw = tex.width, th = tex.height, tp = tex.pixels;
    final fb = framebuffer, zb = depth;
    const eps = -1e-9;

    // Fast path: 1x1 solid-color texture (skip UV interpolation and per-pixel texture lookup)
    if (tw == 1 && th == 1) {
      final baseColor = tp[0];
      int solidColor = baseColor;
      if (shade < 0.99 || shade > 1.01) {
        final r = (((baseColor & 0xFF) * shade).toInt()).clamp(0, 255);
        final g = ((((baseColor >> 8) & 0xFF) * shade).toInt()).clamp(0, 255);
        final b = ((((baseColor >> 16) & 0xFF) * shade).toInt()).clamp(0, 255);
        solidColor = 0xFF000000 | (b << 16) | (g << 8) | r;
      }

      for (var y = miny; y <= maxy; y++) {
        var w0 = w0r, w1 = w1r, w2 = w2r;
        var idx = y * width + minx;
        for (var x = minx; x <= maxx; x++, idx++) {
          if (w0 >= eps && w1 >= eps && w2 >= eps) {
            final iz = w0 * iz0 + w1 * iz1 + w2 * iz2;
            if (iz > zb[idx]) {
              fb[idx] = solidColor;
              zb[idx] = iz;
            }
          }
          w0 += a0;
          w1 += a1;
          w2 += a2;
        }
        w0r += b0;
        w1r += b1;
        w2r += b2;
      }
      return;
    }

    // Textured path with cel lighting and alpha cutout testing
    final shadeI = (shade * 256).toInt().clamp(0, 256);
    final needShade = shadeI < 254;

    for (var y = miny; y <= maxy; y++) {
      var w0 = w0r, w1 = w1r, w2 = w2r;
      var idx = y * width + minx;
      for (var x = minx; x <= maxx; x++, idx++) {
        if (w0 >= eps && w1 >= eps && w2 >= eps) {
          final iz = w0 * iz0 + w1 * iz1 + w2 * iz2;
          if (iz > zb[idx]) {
            double u, v;
            if (affine) {
              u = w0 * u0 + w1 * u1 + w2 * u2;
              v = w0 * v0 + w1 * v1 + w2 * v2;
            } else {
              final r = 1.0 / iz;
              u = (w0 * uz0 + w1 * uz1 + w2 * uz2) * r;
              v = (w0 * vz0 + w1 * vz1 + w2 * vz2) * r;
            }
            final tx = (u * tw).floor() % tw;
            final ty = (v * th).floor() % th;
            final pixel = tp[ty * tw + tx];
            // Alpha test: skip transparent cutout texels if alphaTest is enabled
            if (!alphaTest || (pixel & 0x80000000) != 0) {
              if (needShade) {
                final r = (((pixel & 0xFF) * shadeI) >> 8);
                final g = ((((pixel >> 8) & 0xFF) * shadeI) >> 8);
                final b = ((((pixel >> 16) & 0xFF) * shadeI) >> 8);
                fb[idx] = 0xFF000000 | (b << 16) | (g << 8) | r;
              } else {
                fb[idx] = pixel;
              }
              zb[idx] = iz;
            }
          }
        }
        w0 += a0;
        w1 += a1;
        w2 += a2;
      }
      w0r += b0;
      w1r += b1;
      w2r += b2;
    }
  }
}
