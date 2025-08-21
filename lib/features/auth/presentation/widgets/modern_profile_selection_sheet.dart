import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';

class ModernProfileSelectionSheet extends StatefulWidget {
  const ModernProfileSelectionSheet({super.key});

  static Future<UserType?> show(BuildContext context) async {
    return await showModalBottomSheet<UserType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black87,
      builder: (context) => const ModernProfileSelectionSheet(),
    );
  }

  @override
  State<ModernProfileSelectionSheet> createState() => _ModernProfileSelectionSheetState();
}

class _ModernProfileSelectionSheetState extends State<ModernProfileSelectionSheet>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _optionController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _blurAnimation;
  late List<Animation<double>> _itemAnimations;
  
  UserType? _selectedType;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _optionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _blurAnimation = Tween<double>(
      begin: 10.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    ));
    
    // Animações individuais para cada item
    _itemAnimations = List.generate(
      3,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _mainController,
        curve: Interval(
          0.3 + (index * 0.1),
          0.6 + (index * 0.1),
          curve: Curves.easeOutBack,
        ),
      )),
    );
    
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _optionController.dispose();
    super.dispose();
  }

  void _selectProfile(UserType type) async {
    if (_isSelecting) return;
    
    setState(() {
      _isSelecting = true;
      _selectedType = type;
    });
    
    HapticFeedback.mediumImpact();
    _optionController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (mounted) {
      Navigator.pop(context, type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _optionController]),
      builder: (context, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _blurAnimation.value,
            sigmaY: _blurAnimation.value,
          ),
          child: Transform.translate(
            offset: Offset(0, size.height * _slideAnimation.value),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.85,
                  minHeight: size.height * 0.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  child: Stack(
                    children: [
                      // Background gradient effect
                      Positioned(
                        top: -100,
                        left: -100,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primaryGreen.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -150,
                        right: -150,
                        child: Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                AppColors.mediumGreen.withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Content
                      SafeArea(
                        child: Column(
                          children: [
                            // Handle
                            Container(
                              margin: const EdgeInsets.only(top: 12, bottom: 8),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            
                            // Header
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              child: ScaleTransition(
                                scale: _itemAnimations[0],
                                child: Column(
                                  children: [
                                    // Animated Icon
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 800),
                                      builder: (context, value, child) {
                                        return Transform.rotate(
                                          angle: value * 0.1,
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppColors.primaryGreen.withOpacity(0.2),
                                                  AppColors.mediumGreen.withOpacity(0.1),
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.primaryGreen.withOpacity(0.2),
                                                  blurRadius: 30,
                                                  spreadRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.rocket_launch_rounded,
                                              color: AppColors.primaryGreen,
                                              size: 40,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // Title with gradient
                                    ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        colors: [
                                          Colors.white,
                                          AppColors.primaryGreen,
                                        ],
                                      ).createShader(bounds),
                                      child: const Text(
                                        'Vamos começar!',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Escolha como deseja usar o Simplify',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.6),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Options
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  children: [
                                    // Cliente Option
                                    ScaleTransition(
                                      scale: _itemAnimations[1],
                                      child: _ProfileOption(
                                        title: 'Sou Cliente',
                                        subtitle: 'Encontre os melhores profissionais',
                                        description: 'Contrate serviços com segurança e praticidade',
                                        icon: Icons.person_outline_rounded,
                                        gradient: const [
                                          Color(0xFF00D4AA),
                                          Color(0xFF00AA88),
                                        ],
                                        isSelected: _selectedType == UserType.client,
                                        isSelecting: _isSelecting,
                                        animationValue: _optionController.value,
                                        onTap: () => _selectProfile(UserType.client),
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Profissional Option
                                    ScaleTransition(
                                      scale: _itemAnimations[2],
                                      child: _ProfileOption(
                                        title: 'Sou Profissional',
                                        subtitle: 'Ofereça seus serviços',
                                        description: 'Conecte-se com clientes e expanda seu negócio',
                                        icon: Icons.work_outline_rounded,
                                        gradient: const [
                                          Color(0xFF2E7D32),
                                          Color(0xFF1B5E20),
                                        ],
                                        isSelected: _selectedType == UserType.professional,
                                        isSelecting: _isSelecting,
                                        animationValue: _optionController.value,
                                        onTap: () => _selectProfile(UserType.professional),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Bottom Section
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  // Terms text
                                  Text(
                                    'Ao continuar, você concorda com nossos',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // TODO: Open terms
                                        },
                                        child: Text(
                                          'Termos de Uso',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primaryGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        ' e ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // TODO: Open privacy
                                        },
                                        child: Text(
                                          'Política de Privacidade',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primaryGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileOption extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final bool isSelected;
  final bool isSelecting;
  final double animationValue;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.isSelected,
    required this.isSelecting,
    required this.animationValue,
    required this.onTap,
  });

  @override
  State<_ProfileOption> createState() => _ProfileOptionState();
}

class _ProfileOptionState extends State<_ProfileOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOtherSelected = widget.isSelecting && !widget.isSelected;
    final scale = widget.isSelected ? 1.0 + (widget.animationValue * 0.05) : 1.0;
    final opacity = isOtherSelected ? 0.3 : 1.0;

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isSelecting) {
          _hoverController.forward();
        }
      },
      onTapUp: (_) {
        _hoverController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: scale * _hoverAnimation.value,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: opacity,
              child: Container(
                constraints: const BoxConstraints(minHeight: 140),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isSelected
                        ? widget.gradient
                        : [
                            Colors.grey.shade900,
                            Colors.grey.shade800,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.isSelected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    width: widget.isSelected ? 2 : 1,
                  ),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: widget.gradient[0].withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Animated background pattern
                      if (widget.isSelected)
                        Positioned(
                          right: -30,
                          top: -30,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            builder: (context, value, child) {
                              return Transform.rotate(
                                angle: value * 0.5,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: widget.isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                widget.icon,
                                color: widget.isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Text
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: widget.isSelected
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.subtitle,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: widget.isSelected
                                          ? Colors.white.withOpacity(0.9)
                                          : Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Flexible(
                                    child: Text(
                                      widget.description,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: widget.isSelected
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.white.withOpacity(0.3),
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Arrow
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: widget.isSelected ? 32 : 28,
                              height: widget.isSelected ? 32 : 28,
                              decoration: BoxDecoration(
                                color: widget.isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: widget.isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                                size: widget.isSelected ? 18 : 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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