import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StepProgressBar extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final List<IconData> stepIcons;
  final Function(int)? onStepTapped;
  
  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    required this.stepIcons,
    this.onStepTapped,
  });

  @override
  State<StepProgressBar> createState() => _StepProgressBarState();
}

class _StepProgressBarState extends State<StepProgressBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _dotControllers;
  late List<AnimationController> _lineControllers;
  late List<Animation<double>> _dotAnimations;
  late List<Animation<double>> _lineAnimations;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animateToCurrentStep();
  }
  
  void _initializeAnimations() {
    // Initialize dot animations
    _dotControllers = List.generate(
      widget.totalSteps,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    
    _dotAnimations = _dotControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ));
    }).toList();
    
    // Initialize line animations
    _lineControllers = List.generate(
      widget.totalSteps - 1,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    
    _lineAnimations = _lineControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();
  }
  
  void _animateToCurrentStep() {
    // Animate completed steps
    for (int i = 0; i <= widget.currentStep; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted && i < _dotControllers.length) {
          _dotControllers[i].forward();
        }
      });
    }
    
    // Animate completed lines
    for (int i = 0; i < widget.currentStep; i++) {
      Future.delayed(Duration(milliseconds: i * 100 + 50), () {
        if (mounted && i < _lineControllers.length) {
          _lineControllers[i].forward();
        }
      });
    }
  }
  
  @override
  void didUpdateWidget(StepProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentStep != widget.currentStep) {
      if (widget.currentStep > oldWidget.currentStep) {
        // Moving forward
        for (int i = oldWidget.currentStep + 1; i <= widget.currentStep; i++) {
          if (i < _dotControllers.length) {
            _dotControllers[i].forward();
          }
          if (i - 1 < _lineControllers.length && i > 0) {
            _lineControllers[i - 1].forward();
          }
        }
      } else {
        // Moving backward
        for (int i = oldWidget.currentStep; i > widget.currentStep; i--) {
          if (i < _dotControllers.length) {
            _dotControllers[i].reverse();
          }
          if (i - 1 < _lineControllers.length && i > 0) {
            _lineControllers[i - 1].reverse();
          }
        }
      }
    }
  }
  
  @override
  void dispose() {
    for (var controller in _dotControllers) {
      controller.dispose();
    }
    for (var controller in _lineControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Progress Bar
          SizedBox(
            height: 60,
            child: Row(
              children: List.generate(
                widget.totalSteps * 2 - 1,
                (index) {
                  if (index.isEven) {
                    // Step dot
                    final stepIndex = index ~/ 2;
                    return _buildStepDot(stepIndex);
                  } else {
                    // Connecting line
                    final lineIndex = index ~/ 2;
                    return _buildConnectingLine(lineIndex);
                  }
                },
              ),
            ),
          ),
          
          // Step Labels
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.totalSteps, (index) {
              return Expanded(
                child: _buildStepLabel(index),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepDot(int index) {
    final isActive = index <= widget.currentStep;
    final isCurrent = index == widget.currentStep;
    final isCompleted = index < widget.currentStep;
    final isClickable = index <= widget.currentStep && widget.onStepTapped != null;
    
    return GestureDetector(
      onTap: isClickable ? () => widget.onStepTapped!(index) : null,
      child: AnimatedBuilder(
        animation: _dotAnimations[index],
        builder: (context, child) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.primaryGreen.withOpacity(_dotAnimations[index].value)
                  : AppColors.darkGrey,
              border: Border.all(
                color: isCurrent
                    ? AppColors.primaryGreen
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.4),
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
                        size: 20,
                      )
                    : Text(
                        '${index + 1}',
                        key: ValueKey('number_$index'),
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : AppColors.secondaryText.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildConnectingLine(int index) {
    final isActive = index < widget.currentStep;
    
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: AnimatedBuilder(
          animation: _lineAnimations[index],
          builder: (context, child) {
            return LinearProgressIndicator(
              value: isActive ? _lineAnimations[index].value : 0.0,
              backgroundColor: AppColors.darkGrey,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryGreen,
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildStepLabel(int index) {
    final isActive = index <= widget.currentStep;
    final isCurrent = index == widget.currentStep;
    
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isActive ? 1.0 : 0.5,
      child: Column(
        children: [
          Icon(
            widget.stepIcons[index],
            color: isActive
                ? AppColors.primaryGreen
                : AppColors.secondaryText.withOpacity(0.3),
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            widget.stepTitles[index],
            style: TextStyle(
              color: isCurrent
                  ? AppColors.primaryGreen
                  : isActive
                      ? AppColors.primaryText
                      : AppColors.secondaryText.withOpacity(0.5),
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}