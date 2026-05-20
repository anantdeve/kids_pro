import 'dart:ui';
import 'package:flutter/material.dart';

class MagicalBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  const MagicalBlob({
    super.key,
    required this.size,
    required this.color,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
