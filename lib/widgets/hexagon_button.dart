import 'dart:math';
import 'package:flutter/material.dart';

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double width = size.width;
    final double height = size.height;
    final double h = height;
    final double w = width;

    final path = Path();
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HexagonButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  final double size;
  final bool wrong;
  final bool correct;
  final Color? color;

  

  const HexagonButton({
    super.key,
    required this.text,
    required this.selected,
    required this.wrong,
    required this.correct,
    required this.onTap,
    this.size = 70,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double width = sqrt(3) / 2 * size;
    final Color backgroundColor = correct
        ? Colors.greenAccent
        : wrong
            ? Colors.red
            : selected
                ? Colors.blue
                : color ?? const Color.fromARGB(255, 227, 236, 250);

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: ClipPath(
          clipper: HexagonClipper(),
          child: Container(
            width: width,
            height: size,
            color: backgroundColor,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: FittedBox(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
