import 'package:flutter/material.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double borderRadius;
  final List<Color>? gradientColors;
  final bool enabled;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 56,
    this.borderRadius = 16,
    this.gradientColors,
    this.enabled = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultGradient = [
      theme.primaryColor,
      theme.primaryColor.withOpacity(0.8),
    ];
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.enabled && !widget.isLoading ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: widget.enabled
                  ? LinearGradient(
                      colors: widget.gradientColors ?? defaultGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: !widget.enabled
                  ? theme.disabledColor.withOpacity(0.3)
                  : null,
              boxShadow: widget.enabled && !_isPressed
                  ? [
                      BoxShadow(
                        color: (widget.gradientColors?.first ?? theme.primaryColor)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.enabled && !widget.isLoading ? widget.onPressed : null,
                borderRadius: BorderRadius.circular(widget.borderRadius),
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
                                Colors.white.withOpacity(0.9),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                              ],
                              Text(
                                widget.text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
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
      ),
    );
  }
}