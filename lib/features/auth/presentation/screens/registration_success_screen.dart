import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/animated_button.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  final String userName;
  final bool isProfessional;
  
  const RegistrationSuccessScreen({
    super.key,
    required this.userName,
    required this.isProfessional,
  });

  @override
  State<RegistrationSuccessScreen> createState() => _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _checkController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  
  // Animations
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _pulseAnimation;
  
  // Confetti particles
  final List<ConfettiParticle> _particles = [];
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _generateConfetti();
  }
  
  void _setupAnimations() {
    // Check mark animation
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    ));
    
    // Scale animation for the circle
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Fade animation for text
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_confettiController);
    
    // Pulse animation for the glow effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _checkController.forward();
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
  }
  
  void _generateConfetti() {
    final random = math.Random();
    final colors = [
      AppColors.primaryGreen,
      AppColors.mediumGreen,
      Colors.yellow,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.blue,
    ];
    
    for (int i = 0; i < 50; i++) {
      _particles.add(ConfettiParticle(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.5 - 0.5,
        size: random.nextDouble() * 8 + 4,
        color: colors[random.nextInt(colors.length)],
        speed: random.nextDouble() * 2 + 1,
        angle: random.nextDouble() * math.pi * 2,
      ));
    }
  }
  
  @override
  void dispose() {
    _checkController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _navigateToHome() {
    HapticFeedback.mediumImpact();
    // Navigate to home screen
    // Navigator.pushReplacementNamed(context, '/home');
  }
  
  void _navigateToProfile() {
    HapticFeedback.mediumImpact();
    // Navigate to profile setup
    // Navigator.pushNamed(context, '/profile-setup');
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.deepBlack,
                ],
              ),
            ),
          ),
          
          // Confetti Animation
          AnimatedBuilder(
            animation: _confettiAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: ConfettiPainter(
                  particles: _particles,
                  progress: _confettiAnimation.value,
                ),
              );
            },
          ),
          
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Success Animation
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _scaleAnimation,
                      _checkAnimation,
                      _pulseAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryGreen,
                                AppColors.mediumGreen,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(
                                  0.5 * _pulseAnimation.value,
                                ),
                                blurRadius: 40 * _pulseAnimation.value,
                                spreadRadius: 10 * _pulseAnimation.value,
                              ),
                            ],
                          ),
                          child: Center(
                            child: CustomPaint(
                              size: const Size(80, 80),
                              painter: CheckmarkPainter(
                                progress: _checkAnimation.value,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Success Text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Parabéns! 🎉',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bem-vindo(a), ${widget.userName.split(' ')[0]}!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.charcoalGrey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.darkGrey,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                widget.isProfessional
                                    ? Icons.work_rounded
                                    : Icons.shopping_bag_rounded,
                                color: AppColors.primaryGreen,
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.isProfessional
                                    ? 'Sua conta profissional foi criada com sucesso!'
                                    : 'Sua conta foi criada com sucesso!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.primaryText,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.isProfessional
                                    ? 'Agora você pode começar a oferecer seus serviços e conquistar novos clientes.'
                                    : 'Agora você pode explorar e contratar os melhores profissionais.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.secondaryText.withOpacity(0.8),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Action Buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        AnimatedButton(
                          onPressed: _navigateToHome,
                          text: 'Começar a Explorar',
                          icon: Icons.explore_rounded,
                        ),
                        const SizedBox(height: 16),
                        AnimatedButton(
                          onPressed: _navigateToProfile,
                          text: widget.isProfessional
                              ? 'Configurar Perfil Profissional'
                              : 'Completar Perfil',
                          isOutlined: true,
                          icon: Icons.person_rounded,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Checkmark Painter
class CheckmarkPainter extends CustomPainter {
  final double progress;
  
  CheckmarkPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    
    if (progress > 0) {
      // Draw the checkmark
      final firstLineProgress = (progress * 2).clamp(0.0, 1.0);
      final secondLineProgress = ((progress - 0.5) * 2).clamp(0.0, 1.0);
      
      // First line of checkmark
      if (firstLineProgress > 0) {
        path.moveTo(size.width * 0.2, size.height * 0.5);
        path.lineTo(
          size.width * (0.2 + 0.2 * firstLineProgress),
          size.height * (0.5 + 0.2 * firstLineProgress),
        );
      }
      
      // Second line of checkmark
      if (secondLineProgress > 0) {
        path.lineTo(
          size.width * (0.4 + 0.4 * secondLineProgress),
          size.height * (0.7 - 0.4 * secondLineProgress),
        );
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Confetti Particle
class ConfettiParticle {
  double x;
  double y;
  final double size;
  final Color color;
  final double speed;
  final double angle;
  
  ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.angle,
  });
}

// Confetti Painter
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;
  
  ConfettiPainter({
    required this.particles,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(1.0 - progress * 0.5)
        ..style = PaintingStyle.fill;
      
      // Update particle position
      final newY = particle.y + (progress * particle.speed);
      final newX = particle.x + (math.sin(progress * math.pi * 2 + particle.angle) * 0.02);
      
      // Draw particle
      canvas.save();
      canvas.translate(newX * size.width, newY * size.height);
      canvas.rotate(progress * particle.angle);
      
      // Draw rectangle confetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}