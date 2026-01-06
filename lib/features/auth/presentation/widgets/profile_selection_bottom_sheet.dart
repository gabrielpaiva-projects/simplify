import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';

class ProfileSelectionBottomSheet extends StatefulWidget {
  const ProfileSelectionBottomSheet({super.key});

  static Future<UserType?> show(BuildContext context) async {
    return await showModalBottomSheet<UserType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => const ProfileSelectionBottomSheet(),
    );
  }

  @override
  State<ProfileSelectionBottomSheet> createState() => _ProfileSelectionBottomSheetState();
}

class _ProfileSelectionBottomSheetState extends State<ProfileSelectionBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.deepBlack,
                    AppColors.charcoalGrey.withOpacity(0.95),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryGreen.withOpacity(0.2),
                                    AppColors.mediumGreen.withOpacity(0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_add_alt_1_rounded,
                                color: AppColors.primaryGreen,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 20),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Escolha seu ',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Perfil',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreen,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Como você deseja usar o Simplify?',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.secondaryText.withOpacity(0.8),
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        _ProfileOptionCard(
                          index: 0,
                          icon: Icons.shopping_bag_outlined,
                          title: 'Cliente',
                          description: 'Quero contratar serviços e encontrar profissionais qualificados',
                          gradient: [
                            AppColors.primaryGreen,
                            AppColors.mediumGreen,
                          ],
                          isSelected: _selectedOption == 0,
                          onTap: () {
                            setState(() => _selectedOption = 0);
                            HapticFeedback.lightImpact();
                            Future.delayed(const Duration(milliseconds: 200), () {
                              Navigator.pop(context, UserType.client);
                            });
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _ProfileOptionCard(
                          index: 1,
                          icon: Icons.work_outline_rounded,
                          title: 'Profissional',
                          description: 'Quero oferecer meus serviços e encontrar novos clientes',
                          gradient: [
                            const Color(0xFF256525),
                            AppColors.mediumGreen,
                          ],
                          isSelected: _selectedOption == 1,
                          onTap: () {
                            setState(() => _selectedOption = 1);
                            HapticFeedback.lightImpact();
                            Future.delayed(const Duration(milliseconds: 200), () {
                              Navigator.pop(context, UserType.professional);
                            });
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Voltar',
                            style: TextStyle(
                              color: AppColors.secondaryText.withOpacity(0.6),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileOptionCard extends StatefulWidget {
  final int index;
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileOptionCard({
    required this.index,
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ProfileOptionCard> createState() => _ProfileOptionCardState();
}

class _ProfileOptionCardState extends State<_ProfileOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onTap();
            },
            onTapCancel: () => _controller.reverse(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(colors: widget.gradient)
                    : null,
                color: !widget.isSelected
                    ? AppColors.charcoalGrey.withOpacity(0.5)
                    : null,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.transparent
                      : AppColors.lightGrey.withOpacity(0.1),
                  width: 2,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.gradient[0].withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? Colors.white.withOpacity(0.2)
                          : widget.gradient[0].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isSelected
                          ? Colors.white
                          : widget.gradient[0],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.9),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.isSelected
                                ? Colors.white.withOpacity(0.9)
                                : AppColors.secondaryText.withOpacity(0.6),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: widget.isSelected
                          ? Colors.white
                          : AppColors.secondaryText.withOpacity(0.3),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}