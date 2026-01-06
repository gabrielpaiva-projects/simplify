import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../../../core/constants/app_colors.dart';
import '../../../../services/biometric_auth_service.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../services/presentation/screens/services_screen.dart';
import '../../../professional/presentation/screens/professional_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _textController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _sloganFadeAnimation;
  late Animation<double> _dotAnimation;

  @override
  void initState() {
    super.initState();
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
    ));

    _textSlideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
    ));

    _sloganFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
    ));

    _dotAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.linear,
    ));

    _controller.forward();
    _textController.repeat();

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;
    
    final currentUser = FirebaseAuth.instance.currentUser;
    
    Widget targetScreen;
    
    if (currentUser != null) {
      final biometricAuthenticated = await _authenticateWithBiometrics();
      
      if (!biometricAuthenticated) {
        final authProvider = context.read<AuthProvider>();
        await authProvider.signOut();
        targetScreen = const LoginScreen();
      } else {
        final authProvider = context.read<AuthProvider>();
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (authProvider.userType == UserType.client) {
          targetScreen = const ServicesScreen();
        } else if (authProvider.userType == UserType.professional) {
          targetScreen = const ProfessionalHomeScreen();
        } else {
          targetScreen = const LoginScreen();
        }
      }
    } else {
      targetScreen = const LoginScreen();
    }
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }
  
  Future<bool> _authenticateWithBiometrics() async {
    try {
      final bool isAvailable = await BiometricAuthService.isBiometricAvailable();
      
      if (!isAvailable) {
        print('Biometria não disponível, continuando sem autenticação biométrica');
        return true;
      }
      
      final result = await BiometricAuthService.authenticate(
        reason: 'Confirme sua identidade para acessar o aplicativo',
      );
      
      if (result.isAuthenticated) {
        return true;
      }
      
      if (result.error == BiometricError.notEnrolled || 
          result.error == BiometricError.notAvailable ||
          result.error == BiometricError.passcodeNotSet) {
        print('Biometria não configurada: ${result.message}');
        return true; // Permite continuar sem biometria
      }
      
      return false;
    } catch (e) {
      print('Erro ao verificar biometria: $e');
      return true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.deepBlack,
              AppColors.charcoalGrey.withValues(alpha: 0.3),
              AppColors.deepBlack,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.deepBlack.withValues(alpha: 0.5),
                                border: Border.all(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Image.asset(
                                'assets/logo_secondary.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _textSlideAnimation.value),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'SI',
                                style: TextStyle(
                                  fontFamily: 'TafelSansPro',
                                  fontSize: 52,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                              ),
                              TextSpan(
                                text: 'M',
                                style: TextStyle(
                                  fontFamily: 'TafelSansPro',
                                  fontSize: 52,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryGreen,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                              ),
                              TextSpan(
                                text: 'PLIFY',
                                style: TextStyle(
                                  fontFamily: 'TafelSansPro',
                                  fontSize: 52,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _sloganFadeAnimation,
                      child: Text(
                        'Simplificando sua limpeza e organização',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: AppColors.secondaryText.withValues(alpha: 0.8),
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        final delay = index * 0.2;
                        final value = (_dotAnimation.value - delay) % 1.0;
                        final opacity = value < 0.5 ? value * 2 : 2 - value * 2;
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.3 + opacity * 0.7,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}