import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StepIndicator extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> titles;
  final List<IconData> icons;
  
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.titles,
    required this.icons,
  });

  @override
  State<StepIndicator> createState() => _StepIndicatorState();
}

class _StepIndicatorState extends State<StepIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }
  
  void _setupAnimations() {
    _controllers = List.generate(
      widget.totalSteps,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();
    
    // Start animations for completed steps
    for (int i = 0; i <= widget.currentStep; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }
  
  @override
  void didUpdateWidget(StepIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentStep != widget.currentStep) {
      // Animate to new step
      if (widget.currentStep > oldWidget.currentStep) {
        // Moving forward
        for (int i = oldWidget.currentStep + 1; i <= widget.currentStep; i++) {
          if (i < _controllers.length) {
            _controllers[i].forward();
          }
        }
      } else {
        // Moving backward
        for (int i = oldWidget.currentStep; i > widget.currentStep; i--) {
          if (i < _controllers.length) {
            _controllers[i].reverse();
          }
        }
      }
    }
  }
  
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Row(
        children: List.generate(widget.totalSteps, (index) {
          final isActive = index <= widget.currentStep;
          final isCurrent = index == widget.currentStep;
          final isCompleted = index < widget.currentStep;
          
          return Expanded(
            child: Row(
              children: [
                // Step Circle
                AnimatedBuilder(
                  animation: _animations[index],
                  builder: (context, child) {
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isActive
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryGreen.withOpacity(
                                    _animations[index].value,
                                  ),
                                  AppColors.mediumGreen.withOpacity(
                                    _animations[index].value,
                                  ),
                                ],
                              )
                            : null,
                        color: !isActive ? AppColors.darkGrey : null,
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.primaryGreen
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isCompleted
                              ? Icon(
                                  Icons.check_rounded,
                                  key: ValueKey('check_$index'),
                                  color: Colors.white,
                                  size: 24,
                                )
                              : Icon(
                                  widget.icons[index],
                                  key: ValueKey('icon_$index'),
                                  color: isActive
                                      ? Colors.white.withOpacity(
                                          _animations[index].value,
                                        )
                                      : AppColors.secondaryText.withOpacity(0.3),
                                  size: 24,
                                ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Connector Line
                if (index < widget.totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: AnimatedBuilder(
                        animation: _animations[index],
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: isCompleted ? 1.0 : 0.0,
                            backgroundColor: AppColors.darkGrey,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGreen.withOpacity(
                                _animations[index].value,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}