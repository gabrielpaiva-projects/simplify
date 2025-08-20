import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SloganText extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final String text;
  final double fontSize;

  const SloganText({
    super.key,
    required this.fadeAnimation,
    this.text = 'Simplificando sua limpeza e organização',
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w300,
          color: AppColors.secondaryText.withValues(alpha: 0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}