import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class ModernTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final bool enabled;
  final int? maxLines;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final String? errorText;
  final bool showCounter;
  final int? maxLength;
  
  const ModernTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.enabled = true,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.errorText,
    this.showCounter = false,
    this.maxLength,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;
  String? _errorText;
  
  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_onFocusChange);
    _animationController.dispose();
    super.dispose();
  }
  
  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null || _errorText != null;
    final displayError = widget.errorText ?? _errorText;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: _isFocused
                ? AppColors.primaryGreen
                : hasError
                    ? AppColors.error
                    : AppColors.secondaryText,
            fontSize: 14,
            fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: _isFocused ? 0.3 : 0,
          ),
          child: Text(widget.label),
        ),
        const SizedBox(height: 8),
        
        // Text Field Container
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError
                      ? AppColors.error.withOpacity(0.5)
                      : _isFocused
                          ? AppColors.primaryGreen
                          : AppColors.darkGrey,
                  width: _isFocused ? 2 : 1,
                ),
                color: widget.enabled
                    ? AppColors.charcoalGrey
                    : AppColors.greyBlack,
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                textInputAction: widget.textInputAction,
                enabled: widget.enabled,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                textCapitalization: widget.textCapitalization,
                autofocus: widget.autofocus,
                maxLength: widget.maxLength,
                style: TextStyle(
                  color: widget.enabled
                      ? AppColors.primaryText
                      : AppColors.secondaryText.withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: AppColors.secondaryText.withOpacity(0.3),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _isFocused
                              ? AppColors.primaryGreen
                              : AppColors.secondaryText.withOpacity(0.5),
                          size: 22,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: widget.prefixIcon == null ? 16 : 0,
                    vertical: 16,
                  ),
                  border: InputBorder.none,
                  errorStyle: const TextStyle(height: 0),
                  counterText: widget.showCounter ? null : '',
                  counterStyle: TextStyle(
                    color: AppColors.secondaryText.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                validator: (value) {
                  if (widget.validator != null) {
                    final error = widget.validator!(value);
                    setState(() {
                      _errorText = error;
                    });
                    return error;
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_errorText != null) {
                    setState(() {
                      _errorText = null;
                    });
                  }
                  widget.onChanged?.call(value);
                },
                onFieldSubmitted: widget.onFieldSubmitted,
                cursorColor: AppColors.primaryGreen,
                cursorWidth: 2,
                cursorRadius: const Radius.circular(2),
              ),
            );
          },
        ),
        
        // Error Text
        if (hasError) ...[
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    displayError!,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}