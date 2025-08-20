import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class InteractiveFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffix;
  final bool showSuccessAnimation;
  final String? helperText;
  
  const InteractiveFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.suffix,
    this.showSuccessAnimation = true,
    this.helperText,
  });

  @override
  State<InteractiveFormField> createState() => _InteractiveFormFieldState();
}

class _InteractiveFormFieldState extends State<InteractiveFormField>
    with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _focusController;
  late AnimationController _successController;
  late AnimationController _errorController;
  late AnimationController _iconController;
  
  late Animation<double> _focusAnimation;
  late Animation<double> _successAnimation;
  late Animation<double> _errorAnimation;
  late Animation<double> _iconRotation;
  late Animation<double> _iconScale;
  
  bool _isFocused = false;
  bool _hasError = false;
  bool _isValid = false;
  String? _errorText;
  
  @override
  void initState() {
    super.initState();
    
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    // Focus animation
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));
    
    // Success animation
    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));
    
    // Error animation
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _errorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _errorController,
      curve: Curves.elasticIn,
    ));
    
    // Icon animations
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _iconRotation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeInOut,
    ));
    _iconScale = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeInOut,
    ));
    
    // Add listener for text changes
    widget.controller.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    _focusController.dispose();
    _successController.dispose();
    _errorController.dispose();
    _iconController.dispose();
    super.dispose();
  }
  
  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _focusController.forward();
      _iconController.forward();
      HapticFeedback.selectionClick();
    } else {
      _focusController.reverse();
      _iconController.reverse();
      _validateField();
    }
  }
  
  void _onTextChanged() {
    if (widget.controller.text.isNotEmpty && _errorText != null) {
      setState(() {
        _errorText = null;
        _hasError = false;
      });
      _errorController.reverse();
    }
  }
  
  void _validateField() {
    if (widget.validator != null && widget.controller.text.isNotEmpty) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _errorText = error;
        _hasError = error != null;
        _isValid = error == null && widget.controller.text.isNotEmpty;
      });
      
      if (_hasError) {
        _errorController.forward();
        HapticFeedback.heavyImpact();
      } else if (_isValid && widget.showSuccessAnimation) {
        _successController.forward();
        HapticFeedback.mediumImpact();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated Label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: _isFocused
                ? AppColors.primaryGreen
                : _hasError
                    ? AppColors.error
                    : AppColors.secondaryText,
            fontSize: _isFocused ? 13 : 14,
            fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: _isFocused ? 0.5 : 0,
          ),
          child: Text(widget.label),
        ),
        const SizedBox(height: 8),
        
        // Animated Field Container
        AnimatedBuilder(
          animation: Listenable.merge([
            _focusAnimation,
            _errorAnimation,
            _successAnimation,
            _iconRotation,
            _iconScale,
          ]),
          builder: (context, child) {
            return Container(
              transform: Matrix4.identity()
                ..translate(
                  _hasError ? _errorAnimation.value * 5 * (1 - _errorAnimation.value) : 0.0,
                  0.0,
                ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _hasError
                      ? AppColors.error
                      : _isValid && !_isFocused
                          ? AppColors.success.withOpacity(0.5)
                          : _isFocused
                              ? AppColors.primaryGreen
                              : AppColors.darkGrey,
                  width: _isFocused ? 2.5 : 1.5,
                ),
                color: AppColors.charcoalGrey,
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: (_hasError
                                  ? AppColors.error
                                  : AppColors.primaryGreen)
                              .withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Animated Icon
                  if (widget.icon != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Transform.rotate(
                        angle: _iconRotation.value,
                        child: Transform.scale(
                          scale: _iconScale.value,
                          child: Icon(
                            widget.icon,
                            color: _isFocused
                                ? AppColors.primaryGreen
                                : _hasError
                                    ? AppColors.error
                                    : _isValid
                                        ? AppColors.success
                                        : AppColors.secondaryText.withOpacity(0.5),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  
                  // Text Field
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      inputFormatters: widget.inputFormatters,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: TextStyle(
                          color: AppColors.secondaryText.withOpacity(0.3),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: widget.icon == null ? 16 : 12,
                          vertical: 16,
                        ),
                      ),
                      onChanged: widget.onChanged,
                      cursorColor: AppColors.primaryGreen,
                      cursorWidth: 2.5,
                      cursorRadius: const Radius.circular(2),
                    ),
                  ),
                  
                  // Success/Error Indicator
                  if (_isValid && !_isFocused && widget.showSuccessAnimation)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: ScaleTransition(
                        scale: _successAnimation,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  
                  if (widget.suffix != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: widget.suffix,
                    ),
                ],
              ),
            );
          },
        ),
        
        // Helper/Error Text
        if (_errorText != null || widget.helperText != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                if (_errorText != null)
                  Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 14,
                  ),
                if (_errorText != null) const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorText ?? widget.helperText ?? '',
                    style: TextStyle(
                      color: _errorText != null
                          ? AppColors.error
                          : AppColors.secondaryText.withOpacity(0.6),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}