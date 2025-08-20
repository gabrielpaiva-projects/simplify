import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/shared/loading_indicator.dart';
import '../../widgets/splash/animated_logo.dart';
import '../../widgets/splash/brand_name.dart';
import '../../widgets/splash/slogan_text.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _textController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _sloganFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupStatusBar();
    _setupAnimations();
    _startAnimations();
    _checkAuthStatus();
  }

  void _setupStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Logo animations
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

    // Text animations
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

    // Slogan animation
    _sloganFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
    ));
  }

  void _startAnimations() {
    _controller.forward();
    _textController.repeat();
  }

  void _checkAuthStatus() {
    // Adicionar evento para verificar status de autenticação
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthCheckRequested());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _navigateBasedOnAuthState(AuthState state) {
    if (!mounted) return;

    if (state is AuthAuthenticated) {
      context.go('/home');
    } else if (state is AuthUnauthenticated || state is AuthError) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Navegar após um pequeno delay para mostrar a animação
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateBasedOnAuthState(state);
        });
      },
      child: Scaffold(
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
                  // Logo animado
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return AnimatedLogo(
                        fadeAnimation: _logoFadeAnimation,
                        scaleAnimation: _logoScaleAnimation,
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Nome da marca
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return BrandName(
                        fadeAnimation: _textFadeAnimation,
                        slideAnimation: _textSlideAnimation,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Slogan
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return SloganText(
                        fadeAnimation: _sloganFadeAnimation,
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // Indicador de carregamento
                  const LoadingDots(
                    dotSize: 8,
                    color: AppColors.primaryGreen,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}