import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class CostalinaMark extends StatelessWidget {
  final double size;
  final Color color;
  const CostalinaMark({super.key, this.size = 28, this.color = CColors.tealDark});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/brand/costalina-mark.svg',
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
}