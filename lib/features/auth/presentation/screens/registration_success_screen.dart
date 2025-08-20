import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  final String userName;
  final String userType;
  
  const RegistrationSuccessScreen({
    super.key,
    required this.userName,
    required this.userType,
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
  
  final List<_ConfettiParticle> _particles = [];
  
  bool get isProfessional => widget.userType == 'professional';

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
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
      begin: const Offset(0, 0.5),
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
    
    // Generate confetti particles
    _generateConfetti();
    
    // Start animations
    _startAnimations();
    
    // Haptic feedback
    HapticFeedback.heavyImpact();
  }

  void _generateConfetti() {
    final random = math.Random();
    final colors = [
      AppColors.primaryGreen,
      AppColors.mediumGreen,
      Colors.yellow,
      Colors.green,
      Colors.pink,
      Colors.purple,
      Colors.orange,
    ];
    
    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.5 - 0.5,
        size: random.nextDouble() * 10 + 5,
        color: colors[random.nextInt(colors.length)],
        velocity: random.nextDouble() * 2 + 1,
        angle: random.nextDouble() * math.pi * 2,
      ));
    }
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _checkController.forward();
    _fadeController.forward();
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _confettiController.forward();
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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  theme.scaffoldBackgroundColor,
                  theme.primaryColor.withOpacity(0.05),
                ],
              ),
            ),
          ),
          
          // Confetti
          AnimatedBuilder(
            animation: _confettiAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiAnimation.value,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Spacer(),
                  
                  // Success Icon
                  ScaleTransition(
                    scale: _checkAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Success Message
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Parabéns, ${widget.userName.split(' ').first}!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: theme.textTheme.headlineLarge?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sua conta foi criada com sucesso',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Onboarding Cards
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'O que você pode fazer agora:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        if (isProfessional) ...[
                          _OnboardingCard(
                            icon: Icons.person_outline_rounded,
                            title: 'Complete seu perfil',
                            description: 'Adicione fotos e informações sobre seus serviços',
                            delay: 100,
                          ),
                          const SizedBox(height: 12),
                          _OnboardingCard(
                            icon: Icons.star_outline_rounded,
                            title: 'Defina seus serviços',
                            description: 'Liste os serviços que você oferece e seus preços',
                            delay: 200,
                          ),
                          const SizedBox(height: 12),
                          _OnboardingCard(
                            icon: Icons.calendar_month_outlined,
                            title: 'Configure sua agenda',
                            description: 'Defina seus horários de atendimento',
                            delay: 300,
                          ),
                        ] else ...[
                          _OnboardingCard(
                            icon: Icons.search_rounded,
                            title: 'Busque profissionais',
                            description: 'Encontre os melhores profissionais da sua região',
                            delay: 100,
                          ),
                          const SizedBox(height: 12),
                          _OnboardingCard(
                            icon: Icons.calendar_today_outlined,
                            title: 'Agende serviços',
                            description: 'Marque horários de forma rápida e prática',
                            delay: 200,
                          ),
                          const SizedBox(height: 12),
                          _OnboardingCard(
                            icon: Icons.favorite_outline_rounded,
                            title: 'Favorite profissionais',
                            description: 'Salve seus profissionais preferidos',
                            delay: 300,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Action Buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _AnimatedButton(
                          text: 'Começar a usar',
                          onPressed: () {
                            // TODO: Navigate to home when implemented
                            // For now, navigate to login
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          },
                          isPrimary: true,
                          delay: 400,
                        ),
                        const SizedBox(height: 12),
                        _AnimatedButton(
                          text: 'Completar perfil mais tarde',
                          onPressed: () {
                            // TODO: Navigate to home when implemented
                            // For now, navigate to login
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          },
                          isPrimary: false,
                          delay: 500,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final int delay;

  const _OnboardingCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.delay,
  });

  @override
  State<_OnboardingCard> createState() => _OnboardingCardState();
}

class _OnboardingCardState extends State<_OnboardingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    Future.delayed(Duration(milliseconds: 800 + widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: theme.primaryColor,
                  size: 22,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final int delay;

  const _AnimatedButton({
    required this.text,
    required this.onPressed,
    required this.isPrimary,
    required this.delay,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    Future.delayed(Duration(milliseconds: 800 + widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: widget.isPrimary
              ? ElevatedButton(
                  onPressed: widget.onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: theme.primaryColor.withOpacity(0.3),
                  ),
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : OutlinedButton(
                  onPressed: widget.onPressed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(
                      color: theme.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double velocity;
  final double angle;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.velocity,
    required this.angle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (final particle in particles) {
      final opacity = (1 - progress).clamp(0.0, 1.0);
      paint.color = particle.color.withOpacity(opacity * 0.8);
      
      final x = particle.x * size.width + 
          math.sin(particle.angle) * progress * 100 * particle.velocity;
      final y = particle.y * size.height + 
          progress * size.height * particle.velocity;
      
      final rotation = progress * particle.angle * 2;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
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
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}