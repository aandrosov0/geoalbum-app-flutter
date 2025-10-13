import 'package:flutter/material.dart';

class Plank extends StatelessWidget {
  final String text;

  const Plank(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Container(
      padding: EdgeInsets.all(4),
      color: colorScheme.primary,
      child: Text(
        text,
        style: TextStyle(color: colorScheme.onPrimary),
        textAlign: TextAlign.center,
      ),
    );
  }
}
