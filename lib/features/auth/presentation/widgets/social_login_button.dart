import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class SocialLoginButton extends StatefulWidget {
  final VoidCallback onPressed;
  final SocialProvider provider;
  final bool isLoading;
  
  const SocialLoginButton({
    super.key,
    required this.onPressed,
    required this.provider,
    this.isLoading = false,
  });

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton>
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
    if (widget.isLoading) return;
    
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
    HapticFeedback.lightImpact();
  }
  
  void _handleTapUp(TapUpDetails details) {
    if (widget.isLoading) return;
    
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }
  
  void _handleTapCancel() {
    if (widget.isLoading) return;
    
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final providerConfig = _getProviderConfig();
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedOpacity(
              opacity: widget.isLoading ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.charcoalGrey,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isPressed
                        ? providerConfig.color.withOpacity(0.5)
                        : AppColors.darkGrey,
                    width: _isPressed ? 2 : 1,
                  ),
                  boxShadow: _isPressed
                      ? [
                          BoxShadow(
                            color: providerConfig.color.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.isLoading ? null : widget.onPressed,
                    borderRadius: BorderRadius.circular(14),
                    splashColor: providerConfig.color.withOpacity(0.1),
                    highlightColor: providerConfig.color.withOpacity(0.05),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: widget.isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    providerConfig.color,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Provider Icon/Logo
                                  Container(
                                    width: 24,
                                    height: 24,
                                    child: _buildProviderIcon(providerConfig),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    providerConfig.text,
                                    style: TextStyle(
                                      color: AppColors.primaryText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
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
  
  Widget _buildProviderIcon(ProviderConfig config) {
    if (config.iconData != null) {
      return Icon(
        config.iconData,
        color: config.color,
        size: 24,
      );
    }
    
    // For custom logos, you would typically use Image.asset
    // For now, we'll use icons as placeholders
    return Container(
      decoration: BoxDecoration(
        color: config.color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          config.text[0],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  ProviderConfig _getProviderConfig() {
    switch (widget.provider) {
      case SocialProvider.google:
        return ProviderConfig(
          text: 'Continuar com Google',
          color: const Color(0xFF4285F4),
          iconData: Icons.g_mobiledata_rounded,
        );
      case SocialProvider.apple:
        return ProviderConfig(
          text: 'Continuar com Apple',
          color: Colors.white,
          iconData: Icons.apple_rounded,
        );
      case SocialProvider.facebook:
        return ProviderConfig(
          text: 'Continuar com Facebook',
          color: const Color(0xFF1877F2),
          iconData: Icons.facebook_rounded,
        );
    }
  }
}

enum SocialProvider {
  google,
  apple,
  facebook,
}

class ProviderConfig {
  final String text;
  final Color color;
  final IconData? iconData;
  
  ProviderConfig({
    required this.text,
    required this.color,
    this.iconData,
  });
}