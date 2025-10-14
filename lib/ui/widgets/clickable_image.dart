import 'package:flutter/material.dart';

class ClickableImage extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback? onPressed;

  final FilterQuality filterQuality;

  final int? cacheWidth;
  final int? cacheHeight;

  const ClickableImage({
    super.key,
    required this.image,
    this.onPressed,
    this.filterQuality = FilterQuality.medium,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image(
            image: ResizeImage(image, width: cacheWidth, height: cacheHeight),
            fit: BoxFit.cover,
            filterQuality: filterQuality,
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: onPressed),
          ),
        ),
      ],
    );
  }
}
