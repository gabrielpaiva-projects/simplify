import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';

class ProfessionalAnalysisScreen extends StatefulWidget {
  const ProfessionalAnalysisScreen({super.key});

  @override
  State<ProfessionalAnalysisScreen> createState() => _ProfessionalAnalysisScreenState();
}

class _ProfessionalAnalysisScreenState extends State<ProfessionalAnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _shimmerController;
  late AnimationController _floatController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _floatAnimation;
  
  final List<ConfettiParticle> _particles = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _confettiController = AnimationController(
      duration: const Duration(seconds: 8), // Mais lento
      vsync: this,
    )..repeat();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(_shimmerController);
    
    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
      _fadeController.forward();
    });
    
    // Generate premium confetti
    _generatePremiumConfetti();
  }
  
  void _generatePremiumConfetti() {
    final random = math.Random();
    for (int i = 0; i < 30; i++) { // Menos partículas para look mais clean
      _particles.add(
        ConfettiParticle(
          x: random.nextDouble(),
          y: random.nextDouble() * -0.5, // Começam mais próximas
          color: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withOpacity(0.7),
            AppColors.mediumGreen,
            Colors.white.withOpacity(0.9),
            const Color(0xFFFFD700), // Gold
            const Color(0xFFFFA500), // Orange gold
          ][random.nextInt(6)],
          size: random.nextDouble() * 8 + 4, // Menores e mais elegantes
          speed: random.nextDouble() * 0.5 + 0.3, // Muito mais lento
          rotation: random.nextDouble() * math.pi,
          shape: random.nextInt(3),
          shimmer: random.nextBool(),
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Premium gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0A0A),
                  Color(0xFF0F1F0F),
                  Color(0xFF0A0A0A),
                ],
              ),
            ),
          ),
          
          // Subtle pattern overlay
          Opacity(
            opacity: 0.03,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/pattern.png'),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          
          // Premium confetti animation
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: PremiumConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                ),
              );
            },
          ),
          
          // Main content with glassmorphism
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Premium success animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatAnimation.value),
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryGreen.withOpacity(0.3),
                                      blurRadius: 50,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer glow ring
                                    Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            AppColors.primaryGreen.withOpacity(0.3),
                                            AppColors.primaryGreen.withOpacity(0.1),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Inner premium circle
                                    Container(
                                      width: 120,
                                      height: 120,
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
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.verified,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Premium title with shimmer
                      AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: const [
                                  Colors.white,
                                  Color(0xFFFFD700),
                                  Colors.white,
                                ],
                                stops: [
                                  _shimmerAnimation.value - 0.3,
                                  _shimmerAnimation.value,
                                  _shimmerAnimation.value + 0.3,
                                ],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'Excelente!',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -2,
                                height: 1,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Elegant subtitle
                      Text(
                        'Seu cadastro foi recebido',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Premium glass card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Premium icon
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryGreen.withOpacity(0.2),
                                        AppColors.primaryGreen.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.mark_email_read_rounded,
                                    size: 36,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                const Text(
                                  'Próximos Passos',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                Text(
                                  'Nossa equipe especializada está revisando suas informações com todo cuidado.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.7),
                                    height: 1.6,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Premium divider
                                Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.2),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Email notification
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.notifications_active,
                                        size: 20,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Notificação por E-mail',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Você será notificado assim que a análise for concluída',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Process steps with premium design
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryGreen.withOpacity(0.05),
                              AppColors.primaryGreen.withOpacity(0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryGreen.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildPremiumStep(
                              '01',
                              'Verificação',
                              'Análise detalhada dos dados',
                              true,
                            ),
                            _buildPremiumStep(
                              '02',
                              'Validação',
                              'Confirmação das informações',
                              false,
                            ),
                            _buildPremiumStep(
                              '03',
                              'Ativação',
                              'Liberação do acesso completo',
                              false,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Premium action button
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
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
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryGreen,
                                    AppColors.mediumGreen,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'Entendido',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPremiumStep(String number, String title, String description, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Step number with premium style
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive 
                ? LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.mediumGreen,
                    ],
                  )
                : null,
              color: !isActive ? Colors.white.withOpacity(0.1) : null,
              border: Border.all(
                color: isActive 
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.hourglass_top_rounded,
                size: 16,
                color: AppColors.primaryGreen,
              ),
            ),
        ],
      ),
    );
  }
}

// Premium Confetti Particle
class ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  final double speed;
  final double rotation;
  final int shape;
  final bool shimmer;
  double opacity = 1.0;
  
  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.shape,
    required this.shimmer,
  });
}

// Premium Confetti Painter
class PremiumConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;
  
  PremiumConfettiPainter({
    required this.particles,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Movimento suave e lento
      particle.y = (particle.y + particle.speed * 0.002) % 1.2;
      
      // Movimento lateral suave tipo folha caindo
      particle.x = particle.x + math.sin(progress * math.pi * 2 + particle.rotation) * 0.001;
      
      // Fade out gradual quando chega no fim
      if (particle.y > 0.8) {
        particle.opacity = math.max(0, 1 - ((particle.y - 0.8) * 5));
      }
      
      // Só desenha se visível
      if (particle.y < 0 || particle.y > 1.1 || particle.opacity <= 0) continue;
      
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.7)
        ..style = PaintingStyle.fill;
      
      // Adiciona shimmer em algumas partículas
      if (particle.shimmer) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      }
      
      final position = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );
      
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(particle.rotation + progress * math.pi * 0.5); // Rotação mais lenta
      
      // Desenha formas premium
      switch (particle.shape) {
        case 0: // Círculo com gradiente
          final gradient = RadialGradient(
            colors: [
              particle.color,
              particle.color.withOpacity(0.3),
            ],
          );
          final rect = Rect.fromCircle(center: Offset.zero, radius: particle.size / 2);
          paint.shader = gradient.createShader(rect);
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
          
        case 1: // Quadrado arredondado
          final rrect = RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            Radius.circular(particle.size * 0.2),
          );
          canvas.drawRRect(rrect, paint);
          break;
          
        case 2: // Diamante
          final path = Path();
          path.moveTo(0, -particle.size / 2);
          path.lineTo(particle.size / 2, 0);
          path.lineTo(0, particle.size / 2);
          path.lineTo(-particle.size / 2, 0);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }
      
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(PremiumConfettiPainter oldDelegate) => true;
}