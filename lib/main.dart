import 'package:flutter/material.dart';

import 'game_launcher/game_launcher.dart';

export 'game_launcher/game_launcher.dart';

void main() => runApp(
  const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Flutter 3D Game Engine',
    home: GameLauncher(),
  ),
);
