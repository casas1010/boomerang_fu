import 'dart:math' as math;

/// First-person camera. Yaw 0 looks down +Z, positive pitch looks down.
/// [f] is the focal length in pixels.
class Camera {
  double x = 0, y = 0, z = 0;
  double pitch = 0, yaw = 0;
  double f = 285;
  double sense = 0.0025;

  void look(double dx, double dy) {
    yaw += dx * sense;
    pitch = (pitch + dy * sense).clamp(-math.pi / 2 + 0.01, math.pi / 2 - 0.01);
  }
}
