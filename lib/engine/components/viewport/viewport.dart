import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../controller/controller.dart';

/// Renders the game frame using smooth anti-aliased scaling.
class EngineViewport extends StatelessWidget {
  final EngineController controller;
  final FilterQuality filterQuality;

  const EngineViewport({
    super.key,
    required this.controller,
    this.filterQuality = FilterQuality.medium,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: controller.width / controller.height,
        child: ValueListenableBuilder<ui.Image?>(
          valueListenable: controller.frameNotifier,
          builder: (context, frame, _) {
            if (frame == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return RawImage(
              image: frame,
              fit: BoxFit.fill,
              filterQuality: filterQuality,
            );
          },
        ),
      ),
    );
  }
}
