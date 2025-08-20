import 'package:flutter/material.dart';

class AnimatedStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final List<String> stepTitles;
  final List<IconData> stepIcons;

  const AnimatedStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.stepTitles,
    required this.stepIcons,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Progress Bar
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: theme.dividerColor.withOpacity(0.2),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                      width: constraints.maxWidth * ((currentStep + 1) / totalSteps),
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          // Step Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;
              final isUpcoming = index > currentStep;
              
              return Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: isCurrent ? 56 : 48,
                      height: isCurrent ? 56 : 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? theme.primaryColor
                            : isCurrent
                                ? theme.primaryColor.withOpacity(0.15)
                                : theme.dividerColor.withOpacity(0.1),
                        border: Border.all(
                          color: isCurrent
                              ? theme.primaryColor
                              : isCompleted
                                  ? theme.primaryColor
                                  : theme.dividerColor.withOpacity(0.3),
                          width: isCurrent ? 3 : 2,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isCompleted
                              ? Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: isCurrent ? 28 : 24,
                                  key: ValueKey('check_$index'),
                                )
                              : Icon(
                                  stepIcons[index],
                                  color: isCurrent
                                      ? theme.primaryColor
                                      : isUpcoming
                                          ? theme.iconTheme.color?.withOpacity(0.4)
                                          : Colors.white,
                                  size: isCurrent ? 28 : 24,
                                  key: ValueKey('icon_$index'),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: isCurrent ? 14 : 12,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent
                            ? theme.primaryColor
                            : isCompleted
                                ? theme.primaryColor.withOpacity(0.8)
                                : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      ),
                      child: Text(
                        stepTitles[index],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}