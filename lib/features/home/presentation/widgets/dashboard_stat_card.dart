import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final bool isDarkMode;
  final Animation<double>? animation;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    required this.isDarkMode,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.charcoalGrey : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: change.startsWith('+')
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: change.startsWith('+')
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.deepBlack,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppColors.charcoalGrey.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (animation != null) {
      return AnimatedBuilder(
        animation: animation!,
        builder: (context, child) {
          return Transform.scale(
            scale: animation!.value,
            child: card,
          );
        },
      );
    }

    return card;
  }
}