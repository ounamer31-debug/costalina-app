import 'package:flutter/material.dart';

/// Four hairline L-shaped corner brackets overlaid on a hero image.
class CornerOrnaments extends StatelessWidget {
  const CornerOrnaments({super.key});

  @override
  Widget build(BuildContext context) {
    const arm = 14.0;
    const off = 14.0;
    const side = BorderSide(color: Color(0x73FFFFFF), width: 1);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: off, left: off,
          child: SizedBox(width: arm, height: arm,
            child: const DecoratedBox(
              decoration: BoxDecoration(border: Border(top: side, left: side)))),
        ),
        Positioned(
          top: off, right: off,
          child: SizedBox(width: arm, height: arm,
            child: const DecoratedBox(
              decoration: BoxDecoration(border: Border(top: side, right: side)))),
        ),
        Positioned(
          bottom: off, left: off,
          child: SizedBox(width: arm, height: arm,
            child: const DecoratedBox(
              decoration: BoxDecoration(border: Border(bottom: side, left: side)))),
        ),
        Positioned(
          bottom: off, right: off,
          child: SizedBox(width: arm, height: arm,
            child: const DecoratedBox(
              decoration: BoxDecoration(border: Border(bottom: side, right: side)))),
        ),
      ],
    );
  }
}