import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';

enum ButtonType { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final IconData? trailingIcon;
  final Color? customColor;
  final Color? customTextColor;
  final double? borderRadius;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.trailingIcon,
    this.customColor,
    this.customTextColor,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Definir altura baseada no tamanho
    final height = switch (size) {
      ButtonSize.small => 40.0,
      ButtonSize.medium => 56.0,
      ButtonSize.large => 64.0,
    };

    // Definir tamanho da fonte
    final fontSize = switch (size) {
      ButtonSize.small => 14.0,
      ButtonSize.medium => 16.0,
      ButtonSize.large => 18.0,
    };

    // Definir padding
    final buttonPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: switch (size) {
            ButtonSize.small => 16.0,
            ButtonSize.medium => 24.0,
            ButtonSize.large => 32.0,
          },
        );

    // Definir cores baseadas no tipo
    Color backgroundColor;
    Color textColor;
    Color? borderColor;
    List<Color>? gradientColors;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = customColor ?? AppColors.primaryGreen;
        textColor = customTextColor ?? AppColors.iceWhite;
        gradientColors = [
          AppColors.primaryGreen,
          AppColors.mediumGreen,
        ];
        break;
      case ButtonType.secondary:
        backgroundColor = customColor ??
            (isDarkMode
                ? AppColors.charcoalGrey.withValues(alpha: 0.3)
                : Colors.white);
        textColor = customTextColor ??
            (isDarkMode ? AppColors.primaryText : AppColors.deepBlack);
        borderColor = isDarkMode
            ? AppColors.lightGrey.withValues(alpha: 0.2)
            : AppColors.lightGrey.withValues(alpha: 0.5);
        break;
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor = customTextColor ?? AppColors.primaryGreen;
        borderColor = customColor ?? AppColors.primaryGreen;
        break;
      case ButtonType.text:
        backgroundColor = Colors.transparent;
        textColor = customTextColor ?? AppColors.primaryGreen;
        break;
    }

    Widget buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !isLoading) ...[
          Icon(
            icon,
            color: textColor,
            size: fontSize + 4,
          ),
          const SizedBox(width: 8),
        ],
        if (isLoading)
          SizedBox(
            width: fontSize + 4,
            height: fontSize + 4,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        else
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: 8),
          Icon(
            trailingIcon,
            color: textColor,
            size: fontSize + 4,
          ),
        ],
      ],
    );

    Widget button = Container(
      width: isFullWidth ? double.infinity : null,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        gradient: type == ButtonType.primary && gradientColors != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              )
            : null,
        color: type != ButtonType.primary ? backgroundColor : null,
        border: borderColor != null
            ? Border.all(
                color: borderColor,
                width: type == ButtonType.outline ? 2 : 1.5,
              )
            : null,
        boxShadow: type == ButtonType.primary
            ? [
                BoxShadow(
                  color: (customColor ?? AppColors.primaryGreen)
                      .withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : type == ButtonType.secondary
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () {
            HapticFeedback.mediumImpact();
            onPressed?.call();
          },
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          child: Padding(
            padding: buttonPadding,
            child: Center(child: buttonChild),
          ),
        ),
      ),
    );

    return AnimatedOpacity(
      opacity: onPressed == null || isLoading ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: button,
    );
  }
}