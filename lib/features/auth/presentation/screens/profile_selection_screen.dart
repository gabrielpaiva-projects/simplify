import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late AnimationController _cardController;
  late AnimationController _pulseController;
  
  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _card1Animation;
  late Animation<double> _card2Animation;
  late Animation<double> _pulseAnimation;
  
  // State
  UserType? _selectedType;
  bool _isAnimating = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimations();
  }
  
  void _initializeAnimations() {
    // Background animation
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Content animations
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Card animations
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Pulse animation for selected card
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Define animations
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    ));
    
    _subtitleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    ));
    
    _card1Animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));
    
    _card2Animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOutBack),
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _startEntryAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _backgroundController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _contentController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardController.forward();
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _selectProfile(UserType type) async {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
      _selectedType = type;
    });
    
    HapticFeedback.mediumImpact();
    
    // Wait for selection animation
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      Navigator.pushNamed(
        context,
        '/registration',
        arguments: type,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(size, isDarkMode),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Back Button
                _buildBackButton(isDarkMode),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        
                        // Title Section
                        _buildTitleSection(isDarkMode),
                        
                        const SizedBox(height: 60),
                        
                        // Profile Cards
                        Expanded(
                          child: _buildProfileCards(isDarkMode),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground(Size size, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      AppColors.deepBlack,
                      AppColors.charcoalGrey.withOpacity(0.95),
                      AppColors.deepBlack,
                    ]
                  : [
                      Colors.white,
                      AppColors.lightGrey.withOpacity(0.3),
                      Colors.white,
                    ],
            ),
          ),
          child: CustomPaint(
            painter: BackgroundPatternPainter(
              animation: _backgroundAnimation,
              isDarkMode: isDarkMode,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildBackButton(bool isDarkMode) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode
                  ? AppColors.charcoalGrey.withOpacity(0.3)
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: isDarkMode ? AppColors.primaryText : AppColors.deepBlack,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTitleSection(bool isDarkMode) {
    return Column(
      children: [
        // Title
        FadeTransition(
          opacity: _titleAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
            ).animate(_titleAnimation),
            child: Text(
              'Escolha seu perfil',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.primaryText : AppColors.deepBlack,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Subtitle
        FadeTransition(
          opacity: _subtitleAnimation,
          child: Text(
            'Como você deseja usar o CareConnect?',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode
                  ? AppColors.secondaryText.withOpacity(0.8)
                  : AppColors.charcoalGrey.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  Widget _buildProfileCards(bool isDarkMode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Client Card
        ScaleTransition(
          scale: _card1Animation,
          child: _buildProfileCard(
            type: UserType.client,
            title: 'Quero contratar',
            subtitle: 'Encontre profissionais qualificados para cuidar de quem você ama',
            icon: Icons.favorite_rounded,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGreen.withOpacity(0.9),
                AppColors.mediumGreen.withOpacity(0.9),
              ],
            ),
            features: const [
              'Busque por especialidade',
              'Avalie profissionais',
              'Agende com facilidade',
              'Histórico completo',
            ],
            isDarkMode: isDarkMode,
            animation: _card1Animation,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Professional Card
        ScaleTransition(
          scale: _card2Animation,
          child: _buildProfileCard(
            type: UserType.professional,
            title: 'Sou profissional',
            subtitle: 'Ofereça seus serviços e conecte-se com quem precisa de cuidados',
            icon: Icons.medical_services_rounded,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGreen,
                AppColors.mediumGreen,
              ],
            ),
            features: const [
              'Gerencie sua agenda',
              'Receba avaliações',
              'Aumente sua visibilidade',
              'Pagamentos seguros',
            ],
            isDarkMode: isDarkMode,
            animation: _card2Animation,
          ),
        ),
      ],
    );
  }
  
  Widget _buildProfileCard({
    required UserType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required List<String> features,
    required bool isDarkMode,
    required Animation<double> animation,
  }) {
    final isSelected = _selectedType == type;
    
    return AnimatedBuilder(
      animation: isSelected ? _pulseAnimation : animation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () => _selectProfile(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: isSelected ? gradient : null,
                color: !isSelected
                    ? (isDarkMode
                        ? AppColors.charcoalGrey.withOpacity(0.3)
                        : Colors.white)
                    : null,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDarkMode
                          ? AppColors.lightGrey.withOpacity(0.2)
                          : AppColors.lightGrey.withOpacity(0.5)),
                  width: 2,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectProfile(type),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : gradient.colors.first.withOpacity(0.1),
                              ),
                              child: Icon(
                                icon,
                                color: isSelected
                                    ? Colors.white
                                    : gradient.colors.first,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDarkMode
                                              ? AppColors.primaryText
                                              : AppColors.deepBlack),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.9)
                                          : (isDarkMode
                                              ? AppColors.secondaryText.withOpacity(0.7)
                                              : AppColors.charcoalGrey.withOpacity(0.7)),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const Spacer(),
                        
                        // Features
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: features.take(2).map((feature) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : gradient.colors.first.withOpacity(0.1),
                              ),
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : gradient.colors.first,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
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

// Custom Painter for animated background pattern
class BackgroundPatternPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDarkMode;
  
  BackgroundPatternPainter({
    required this.animation,
    required this.isDarkMode,
  }) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;
    
    // Draw animated circles
    for (int i = 0; i < 5; i++) {
      final progress = (animation.value + i * 0.2) % 1.0;
      final opacity = (1.0 - progress) * 0.1;
      
      paint.color = (isDarkMode
              ? AppColors.primaryGreen
              : AppColors.primaryGreen)
          .withOpacity(opacity);
      
      final radius = 100 + progress * 200;
      final center = Offset(
        size.width * (0.2 + i * 0.2),
        size.height * (0.3 + i * 0.1),
      );
      
      canvas.drawCircle(center, radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        isDarkMode != oldDelegate.isDarkMode;
  }
}