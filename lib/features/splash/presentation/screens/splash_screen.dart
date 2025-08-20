import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideUpAnimation;
  late Animation<Offset> _slideDownAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controlador principal para fade e scale
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Controlador para rotação contínua
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Controlador para efeito de pulso
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Controlador para slide de elementos
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Configuração das animações
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ));

    _slideDownAnimation = Tween<Offset>(
      begin: const Offset(0, -2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeIn),
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.linear,
    ));

    // Iniciar animações
    _mainController.forward();
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _slideController.forward();

    // Navegar para a tela de login após 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Stack(
        children: [
          // Background com gradiente animado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.deepBlack,
                  AppColors.charcoalGrey.withValues(alpha: 0.8),
                  AppColors.darkGrey.withValues(alpha: 0.6),
                  AppColors.deepBlack,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          
          // Padrão de fundo animado
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: BackgroundPatternPainter(
                  rotation: _rotationAnimation.value,
                  opacity: 0.05,
                ),
              );
            },
          ),
          
          // Conteúdo principal
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _mainController,
                _pulseController,
                _slideController,
              ]),
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo principal com efeitos
                    SlideTransition(
                      position: _slideDownAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow effect
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primaryGreen.withValues(alpha: 0.3),
                                      AppColors.primaryGreen.withValues(alpha: 0.1),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                              // Logo principal
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryGreen.withValues(alpha: 0.5),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/logo.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Logo secundário com animação
                    FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: SlideTransition(
                        position: _slideUpAnimation,
                        child: Container(
                          width: 200,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/logo_secondary.png',
                                  fit: BoxFit.contain,
                                ),
                                // Efeito shimmer
                                AnimatedBuilder(
                                  animation: _shimmerAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment(-1.0 + 2.0 * _shimmerAnimation.value, 0),
                                          end: Alignment(-0.5 + 2.0 * _shimmerAnimation.value, 0),
                                          colors: [
                                            Colors.transparent,
                                            Colors.white.withValues(alpha: 0.1),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Texto e slogan com animação
                    SlideTransition(
                      position: _slideUpAnimation,
                      child: FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  AppColors.primaryGreen,
                                  AppColors.primaryGreen.withValues(alpha: 0.8),
                                  AppColors.iceWhite,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                'Simplify',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'TafelSansPro',
                                  color: Colors.white,
                                  letterSpacing: 3,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primaryGreen.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            Text(
                              'Simplifique sua vida',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.secondaryText.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 80),
                    
                    // Indicador de carregamento customizado
                    FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Círculo externo
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryGreen.withValues(alpha: 0.3),
                              ),
                              strokeWidth: 2,
                            ),
                          ),
                          // Círculo interno
                          SizedBox(
                            width: 35,
                            height: 35,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryGreen,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                          // Ponto central pulsante
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryGreen,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.8),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Partículas decorativas
          ...List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                final delay = index * 0.2;
                final opacity = (_mainController.value - delay).clamp(0.0, 1.0);
                return Positioned(
                  left: size.width * (0.1 + index * 0.2),
                  top: size.height * (0.1 + (index % 2) * 0.7),
                  child: Opacity(
                    opacity: opacity * 0.3,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreen,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

// Custom painter para o padrão de fundo
class BackgroundPatternPainter extends CustomPainter {
  final double rotation;
  final double opacity;

  BackgroundPatternPainter({
    required this.rotation,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.4;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    // Desenhar padrão geométrico
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi * 2 / 6) * i;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      
      canvas.drawCircle(Offset(x, y), 50, paint);
      
      // Linhas conectoras
      if (i < 5) {
        final nextAngle = (math.pi * 2 / 6) * (i + 1);
        final nextX = radius * math.cos(nextAngle);
        final nextY = radius * math.sin(nextAngle);
        canvas.drawLine(Offset(x, y), Offset(nextX, nextY), paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) {
    return rotation != oldDelegate.rotation || opacity != oldDelegate.opacity;
  }
}