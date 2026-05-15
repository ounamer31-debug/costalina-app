import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HairLine extends StatelessWidget {
  final Color color;
  final bool vertical;
  final double? extent;

  const HairLine({
    super.key,
    this.color = CColors.tealLineSoft,
    this.vertical = false,
    this.extent,
  });

  @override
  Widget build(BuildContext context) {
    final thickness = 1.0 / MediaQuery.devicePixelRatioOf(context);
    return vertical
        ? SizedBox(
            width: thickness,
            height: extent,
            child: ColoredBox(color: color),
          )
        : SizedBox(
            height: thickness,
            width: extent,
            child: ColoredBox(color: color),
          );
  }
}