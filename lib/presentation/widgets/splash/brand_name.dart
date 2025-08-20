import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class BrandName extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> slideAnimation;
  final double fontSize;
  final TextAlign textAlign;

  const BrandName({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
    this.fontSize = 52,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, slideAnimation.value),
        child: RichText(
          textAlign: textAlign,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'SI',
                style: TextStyle(
                  fontFamily: 'TafelSansPro',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: 'M',
                style: TextStyle(
                  fontFamily: 'TafelSansPro',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: 'PLIFY',
                style: TextStyle(
                  fontFamily: 'TafelSansPro',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}