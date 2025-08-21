import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  late AnimationController _floatingController;
  late AnimationController _shimmerController;
  
  // Animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _primaryButtonAnimation;
  late Animation<double> _secondaryButtonAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _shimmerAnimation;
  
  // Page Controller for background slides
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _startBackgroundSlideshow();
  }
  
  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Button animations
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Floating animation for decorative elements
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    // Shimmer effect
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // Define animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoRotateAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));
    
    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _subtitleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));
    
    _primaryButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));
    
    _secondaryButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOutBack),
    ));
    
    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
  }
  
  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _buttonController.forward();
  }
  
  void _startBackgroundSlideshow() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentPage = (_currentPage + 1) % 3;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _startBackgroundSlideshow();
      }
    });
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    _floatingController.dispose();
    _shimmerController.dispose();
    _pageController.dispose();
    super.dispose();
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
          
          // Floating Decorative Elements
          _buildFloatingElements(size, isDarkMode),
          
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Logo Section
                  _buildLogoSection(isDarkMode),
                  
                  const SizedBox(height: 48),
                  
                  // Text Section
                  _buildTextSection(isDarkMode),
                  
                  const Spacer(flex: 3),
                  
                  // Buttons Section
                  _buildButtonsSection(isDarkMode),
                  
                  const SizedBox(height: 40),
                  
                  // Terms Text
                  _buildTermsText(isDarkMode),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground(Size size, bool isDarkMode) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [
                        AppColors.deepBlack,
                        AppColors.charcoalGrey.withOpacity(0.95),
                      ]
                    : [
                        Colors.white,
                        AppColors.lightGrey.withOpacity(0.2),
                      ],
              ),
            ),
          ),
          
          // Animated Gradient Overlay
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildGradientOverlay(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.mediumGreen.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              _buildGradientOverlay(
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.1),
                  const Color(0xFF764BA2).withOpacity(0.05),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              _buildGradientOverlay(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.mediumGreen.withOpacity(0.05),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildGradientOverlay({
    required List<Color> colors,
    required Alignment begin,
    required Alignment end,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
        ),
      ),
    );
  }
  
  Widget _buildFloatingElements(Size size, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Top Left Circle
            Positioned(
              top: 100 + _floatingAnimation.value,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.1),
                      AppColors.primaryGreen.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            
            // Top Right Circle
            Positioned(
              top: 50 - _floatingAnimation.value,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF667EEA).withOpacity(0.1),
                      const Color(0xFF667EEA).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Center Circle
            Positioned(
              bottom: 150 + _floatingAnimation.value * 0.5,
              left: size.width / 2 - 75,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.mediumGreen.withOpacity(0.08),
                      AppColors.mediumGreen.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildLogoSection(bool isDarkMode) {
    return ScaleTransition(
      scale: _logoScaleAnimation,
      child: RotationTransition(
        turns: _logoRotateAnimation,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGreen,
                AppColors.mediumGreen,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shimmer Effect
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment(-1 + _shimmerAnimation.value, -1),
                        end: Alignment(1 + _shimmerAnimation.value, 1),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              // Icon
              const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextSection(bool isDarkMode) {
    return Column(
      children: [
        // Title
        FadeTransition(
          opacity: _titleAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(_titleAnimation),
            child: Text(
              'CareConnect',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.primaryText : AppColors.deepBlack,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Subtitle
        FadeTransition(
          opacity: _subtitleAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(_subtitleAnimation),
            child: Text(
              'Conectando cuidadores e famílias\ncom amor e profissionalismo',
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
        ),
      ],
    );
  }
  
  Widget _buildButtonsSection(bool isDarkMode) {
    return Column(
      children: [
        // Primary Button - Get Started
        ScaleTransition(
          scale: _primaryButtonAnimation,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGreen,
                  AppColors.mediumGreen,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pushNamed(context, '/profile-selection');
                },
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Começar agora',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Secondary Button - Login
        ScaleTransition(
          scale: _secondaryButtonAnimation,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDarkMode
                  ? AppColors.charcoalGrey.withOpacity(0.3)
                  : Colors.white,
              border: Border.all(
                color: isDarkMode
                    ? AppColors.lightGrey.withOpacity(0.2)
                    : AppColors.lightGrey.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
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
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/login');
                },
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    'Já tenho uma conta',
                    style: TextStyle(
                      color: isDarkMode
                          ? AppColors.primaryText
                          : AppColors.deepBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTermsText(bool isDarkMode) {
    return FadeTransition(
      opacity: _subtitleAnimation,
      child: Text(
        'Ao continuar, você concorda com nossos\nTermos de Uso e Política de Privacidade',
        style: TextStyle(
          fontSize: 12,
          color: isDarkMode
              ? AppColors.secondaryText.withOpacity(0.5)
              : AppColors.charcoalGrey.withOpacity(0.5),
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}