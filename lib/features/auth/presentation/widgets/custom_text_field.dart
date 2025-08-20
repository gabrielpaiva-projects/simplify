import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final int? maxLines;
  final bool enabled;
  final String? helperText;
  final Color? fillColor;
  final bool showCounter;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.enabled = true,
    this.helperText,
    this.fillColor,
    this.showCounter = false,
    this.maxLength,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode?.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                readOnly: widget.readOnly,
                enabled: widget.enabled,
                textInputAction: widget.textInputAction,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                maxLength: widget.maxLength,
                onFieldSubmitted: widget.onFieldSubmitted,
                onTap: widget.onTap,
                onChanged: (value) {
                  widget.onChanged?.call(value);
                  if (_hasError && widget.validator != null) {
                    setState(() {
                      _errorText = widget.validator!(value);
                      _hasError = _errorText != null;
                    });
                  }
                },
                validator: (value) {
                  final error = widget.validator?.call(value);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _errorText = error;
                        _hasError = error != null;
                      });
                    }
                  });
                  return error;
                },
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hint,
                  helperText: widget.helperText,
                  helperMaxLines: 2,
                  counterText: widget.showCounter ? null : '',
                  labelStyle: TextStyle(
                    fontSize: _isFocused ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: _isFocused 
                        ? theme.primaryColor 
                        : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                  ),
                  errorStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: widget.fillColor ?? 
                      (_isFocused 
                          ? theme.primaryColor.withOpacity(0.03)
                          : theme.cardColor),
                  prefixIcon: widget.prefixIcon != null
                      ? AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.only(left: 16, right: 12),
                          child: Icon(
                            widget.prefixIcon,
                            size: 22,
                            color: _isFocused
                                ? theme.primaryColor
                                : theme.iconTheme.color?.withOpacity(0.5),
                          ),
                        )
                      : null,
                  suffixIcon: widget.suffix,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
            ),
            if (_hasError && _errorText != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.only(left: 20, top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _errorText!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}