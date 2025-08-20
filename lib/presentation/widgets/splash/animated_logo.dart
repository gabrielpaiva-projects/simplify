import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AnimatedLogo extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final double size;

  const AnimatedLogo({
    super.key,
    required this.fadeAnimation,
    required this.scaleAnimation,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Transform.scale(
        scale: scaleAnimation.value,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 10,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.deepBlack.withValues(alpha: 0.5),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Image.asset(
                'assets/logo_secondary.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.cleaning_services_rounded,
                    size: size * 0.6,
                    color: AppColors.primaryGreen,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}