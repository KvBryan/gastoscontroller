import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: size * 0.05, // Responsive border thickness
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '\$',
        style: TextStyle(
          fontSize: size * 0.55, // Responsive text size
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'Montserrat',
          height: 1.1,
        ),
      ),
    );
  }
}
