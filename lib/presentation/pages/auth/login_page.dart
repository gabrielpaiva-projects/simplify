import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/auth/login_form.dart';
import '../../widgets/auth/login_header.dart';
import '../../widgets/shared/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  // Animações
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleLogin(String email, String password, bool rememberMe) {
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: email,
            password: password,
            rememberMe: rememberMe,
          ),
        );
  }

  void _handleForgotPassword() {
    HapticFeedback.lightImpact();
    context.showSnackBar(
      'Recuperação de senha em desenvolvimento',
      backgroundColor: AppColors.info,
    );
  }

  void _handleCreateAccount() {
    HapticFeedback.lightImpact();
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.showSuccessSnackBar('Login realizado com sucesso!');
          context.go('/home');
        } else if (state is AuthError) {
          context.showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: context.isDarkMode 
            ? AppColors.deepBlack 
            : AppColors.iceWhite,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: context.isDarkMode
                  ? [
                      AppColors.deepBlack,
                      AppColors.charcoalGrey.withValues(alpha: 0.5),
                    ]
                  : [
                      AppColors.iceWhite,
                      AppColors.lightGrey.withValues(alpha: 0.3),
                    ],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08,
                      ),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          
                          // Logo e Header
                          SlideTransition(
                            position: _slideAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: LoginHeader(
                                fadeAnimation: _fadeAnimation,
                                slideAnimation: Tween<double>(
                                  begin: 30.0,
                                  end: 0.0,
                                ).animate(_slideController),
                              ),
                            ),
                          ),
                          
                          const Spacer(flex: 3),
                          
                          // Formulário
                          SlideTransition(
                            position: _slideAnimation,
                            child: BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                
                                return LoginForm(
                                  onSubmit: _handleLogin,
                                  onForgotPassword: _handleForgotPassword,
                                  isLoading: isLoading,
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Botão de Login
                          ScaleTransition(
                            scale: _buttonScaleAnimation,
                            child: BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                
                                return CustomButton(
                                  text: 'Entrar',
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          // O formulário lidará com a submissão
                                        },
                                  type: ButtonType.primary,
                                  isLoading: isLoading,
                                  trailingIcon: Icons.arrow_forward_rounded,
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Links adicionais
                          _buildAdditionalLinks(),
                          
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalLinks() {
    return Column(
      children: [
        // Divisor elegante
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      context.isDarkMode
                          ? AppColors.lightGrey.withValues(alpha: 0.2)
                          : AppColors.lightGrey.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ou',
                style: TextStyle(
                  color: context.isDarkMode
                      ? AppColors.secondaryText.withValues(alpha: 0.5)
                      : AppColors.charcoalGrey.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.isDarkMode
                          ? AppColors.lightGrey.withValues(alpha: 0.2)
                          : AppColors.lightGrey.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Botão de criar conta
        CustomButton(
          text: 'Criar conta gratuita',
          onPressed: _handleCreateAccount,
          type: ButtonType.secondary,
        ),
      ],
    );
  }
}