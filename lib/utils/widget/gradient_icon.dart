import 'package:flutter/material.dart';

class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const GradientIcon(this.icon, {required this.size});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Color(0xFF000000),
          Color(0xFF000000),
          Color(0xFF000000),
          Color(0xFF000000),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Icon(
        icon,
        size: size,
        color: Colors.white, // Placeholder color, gets overridden by gradient
      ),
    );
  }
}
