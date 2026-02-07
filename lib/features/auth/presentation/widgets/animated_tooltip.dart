import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AnimatedTooltip extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final bool show;
  
  const AnimatedTooltip({
    super.key,
    required this.message,
    required this.icon,
    this.backgroundColor,
    this.show = true,
  });

  @override
  State<AnimatedTooltip> createState() => _AnimatedTooltipState();
}

class _AnimatedTooltipState extends State<AnimatedTooltip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    if (widget.show) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(AnimatedTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.primaryGreen.withOpacity(0.1);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.backgroundColor?.withOpacity(0.3) ?? 
                       AppColors.primaryGreen.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: widget.backgroundColor ?? AppColors.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: AppColors.primaryText.withOpacity(0.9),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}