import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  final bool isProfessional;
  
  const RegistrationSuccessScreen({
    super.key,
    this.isProfessional = false,
  });

  @override
  State<RegistrationSuccessScreen> createState() => _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _confettiController;
  late Animation<double> _checkAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));

    // Start animations in sequence
    Future.delayed(const Duration(milliseconds: 200), () {
      _checkController.forward();
      HapticFeedback.mediumImpact();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _fadeController.forward();
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _confettiController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.isProfessional
        ? [const Color(0xFF256525), AppColors.mediumGreen]
        : [AppColors.primaryGreen, AppColors.mediumGreen];

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              gradientColors[0].withOpacity(0.1),
              AppColors.deepBlack,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Confetti Animation
              AnimatedBuilder(
                animation: _confettiAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ConfettiPainter(
                      progress: _confettiAnimation.value,
                      color: gradientColors[0],
                    ),
                    size: Size.infinite,
                  );
                },
              ),
              
              // Main Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success Icon
                      AnimatedBuilder(
                        animation: _checkAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _checkAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradientColors,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: gradientColors[0].withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Success Message
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    gradientColors[0],
                                    gradientColors[1],
                                    Colors.white,
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'Parabéns!',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Cadastro realizado',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Text(
                                'com sucesso!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                widget.isProfessional
                                    ? 'Sua conta profissional foi criada.\nAgora você pode começar a receber propostas!'
                                    : 'Sua conta foi criada.\nAgora você pode encontrar os melhores profissionais!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.secondaryText.withOpacity(0.8),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Features List
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              _buildFeatureItem(
                                Icons.verified_user_outlined,
                                widget.isProfessional
                                    ? 'Perfil verificado'
                                    : 'Acesso completo',
                                gradientColors[0],
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(
                                Icons.notifications_active_outlined,
                                widget.isProfessional
                                    ? 'Notificações de propostas'
                                    : 'Alertas personalizados',
                                gradientColors[0],
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(
                                Icons.star_outline_rounded,
                                widget.isProfessional
                                    ? 'Sistema de avaliações'
                                    : 'Profissionais qualificados',
                                gradientColors[0],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom CTA
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: gradientColors[0].withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              // Navigate to home or dashboard
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/home',
                                (route) => false,
                              );
                            },
                            child: const Center(
                              child: Text(
                                'Começar a usar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          // Navigate to profile completion
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/complete-profile',
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Completar perfil mais tarde',
                          style: TextStyle(
                            color: AppColors.secondaryText.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Icon(
          Icons.check_circle_outline,
          color: color,
          size: 20,
        ),
      ],
    );
  }
}

// Custom Painter for Confetti Effect
class ConfettiPainter extends CustomPainter {
  final double progress;
  final Color color;

  ConfettiPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..style = PaintingStyle.fill;

    final random = List.generate(30, (index) {
      final x = (index * 37 % size.width);
      final startY = -20.0;
      final endY = size.height + 20.0;
      final y = startY + (endY - startY) * progress;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      final rotation = progress * 2 * 3.14159 * (index % 3);
      final scale = 0.5 + (index % 5) * 0.2;

      return {
        'x': x,
        'y': y,
        'opacity': opacity,
        'rotation': rotation,
        'scale': scale,
        'color': index % 3,
      };
    });

    for (final particle in random) {
      canvas.save();
      canvas.translate(particle['x'] as double, particle['y'] as double);
      canvas.rotate(particle['rotation'] as double);
      canvas.scale(particle['scale'] as double);

      final particleColor = particle['color'] == 0
          ? color
          : particle['color'] == 1
              ? color.withOpacity(0.7)
              : color.withOpacity(0.5);

      paint.color = particleColor.withOpacity(particle['opacity'] as double);

      // Draw different shapes
      if (particle['color'] == 0) {
        // Circle
        canvas.drawCircle(Offset.zero, 4, paint);
      } else if (particle['color'] == 1) {
        // Square
        canvas.drawRect(
          const Rect.fromLTWH(-4, -4, 8, 8),
          paint,
        );
      } else {
        // Triangle
        final path = Path()
          ..moveTo(0, -4)
          ..lineTo(-4, 4)
          ..lineTo(4, 4)
          ..close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}