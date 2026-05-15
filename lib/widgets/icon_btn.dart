import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IconBtn extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final bool light;

  const IconBtn({super.key, required this.icon, this.onTap, this.light = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              color: light ? Colors.white : CColors.ink,
              size: 20,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}