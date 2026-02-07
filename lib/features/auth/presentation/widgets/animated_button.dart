import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final IconData? icon;
  final bool isOutlined;
  final Color? color;
  final double height;
  final double fontSize;
  final bool enabled;
  
  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
    this.color,
    this.height = 56,
    this.fontSize = 16,
    this.enabled = true,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
    HapticFeedback.lightImpact();
  }
  
  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }
  
  void _handleTapCancel() {
    if (!widget.enabled || widget.isLoading) return;
    
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? AppColors.primaryGreen;
    final isEnabled = widget.enabled && !widget.isLoading;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedOpacity(
              opacity: isEnabled ? _opacityAnimation.value : 0.5,
              duration: const Duration(milliseconds: 200),
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: !widget.isOutlined && isEnabled
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            buttonColor,
                            buttonColor.withOpacity(0.8),
                          ],
                        )
                      : null,
                  color: widget.isOutlined
                      ? Colors.transparent
                      : !isEnabled
                          ? AppColors.darkGrey
                          : null,
                  borderRadius: BorderRadius.circular(14),
                  border: widget.isOutlined
                      ? Border.all(
                          color: isEnabled
                              ? buttonColor
                              : AppColors.darkGrey,
                          width: 2,
                        )
                      : null,
                  boxShadow: !widget.isOutlined && isEnabled && _isPressed
                      ? [
                          BoxShadow(
                            color: buttonColor.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : !widget.isOutlined && isEnabled
                          ? [
                              BoxShadow(
                                color: buttonColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isEnabled ? widget.onPressed : null,
                    borderRadius: BorderRadius.circular(14),
                    splashColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.05),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Center(
                        child: widget.isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.isOutlined
                                        ? buttonColor
                                        : Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (widget.icon != null) ...[
                                    Icon(
                                      widget.icon,
                                      color: widget.isOutlined
                                          ? isEnabled
                                              ? buttonColor
                                              : AppColors.darkGrey
                                          : Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Text(
                                    widget.text,
                                    style: TextStyle(
                                      color: widget.isOutlined
                                          ? isEnabled
                                              ? buttonColor
                                              : AppColors.darkGrey
                                          : Colors.white,
                                      fontSize: widget.fontSize,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}