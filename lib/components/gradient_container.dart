import 'package:flutter/material.dart';

const List<Color> superGradientColors = [
  Color.fromARGB(255, 53, 53, 53),
  Color.fromARGB(227, 53, 53, 53)
];

class GradientContainer extends Container {
  GradientContainer({required List<Color> colors, Widget? child, super.key})
      : super(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: child,
        );
}
