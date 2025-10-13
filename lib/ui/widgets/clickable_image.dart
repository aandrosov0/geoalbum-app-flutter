import 'package:flutter/material.dart';

class ClickableImage extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback? onPressed;

  const ClickableImage({super.key, required this.image, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Image(image: image, fit: BoxFit.cover)),
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
