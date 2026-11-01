import 'dart:typed_data';
import 'dart:ui' as ui;

/// Texture stored as packed 0xAABBGGRR (little-endian RGBA bytes), the same
/// layout as the framebuffer so texels are copied with no conversion.
class Texture {
  final int width, height;
  final Uint32List pixels;
  Texture(this.width, this.height, this.pixels);

  static Future<Texture> fromBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    final px = Uint32List.fromList(data!.buffer.asUint32List());
    for (var i = 0; i < px.length; i++) {
      px[i] |= 0xFF000000;
    }
    return Texture(img.width, img.height, px);
  }

  static int rgb(int r, int g, int b) => 0xFF000000 | (b << 16) | (g << 8) | r;
}
