import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../splash/brand_name.dart';

class LoginHeader extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> slideAnimation;

  const LoginHeader({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo secundário
        Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/logo_secondary.png',
            height: 80,
            width: 80,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.cleaning_services_rounded,
                  color: AppColors.primaryGreen,
                  size: 40,
                ),
              );
            },
          ),
        ),

        // Título com animação
        BrandName(
          fadeAnimation: fadeAnimation,
          slideAnimation: slideAnimation,
          fontSize: 47,
          textAlign: TextAlign.left,
        ),
        
        const SizedBox(height: 12),
        
        // Subtítulo
        Text(
          'Faça login para continuar',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 16,
            color: context.isDarkMode
                ? AppColors.secondaryText.withValues(alpha: 0.8)
                : AppColors.charcoalGrey.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}