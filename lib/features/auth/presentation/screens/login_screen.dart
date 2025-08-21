import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import 'welcome_registration_screen.dart';
import '../../data/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

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

    // Configuração das animações
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

    // Iniciar animações com delay
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });

    // Adicionar listeners para efeitos visuais
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-mail é obrigatório';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Digite um e-mail válido';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }

    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }

    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      // Adicionar pequena vibração de erro
      HapticFeedback.mediumImpact();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simular chamada de API
      await Future.delayed(const Duration(seconds: 2));

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Validação de exemplo
      if (email == 'user@example.com' && password == 'password123') {
        if (mounted) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text('Login realizado com sucesso!'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(20),
            ),
          );
        }
      } else {
        if (mounted) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text('E-mail ou senha incorretos'),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(20),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer login: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.deepBlack : AppColors.iceWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          
                          // Logo e Header
                          SlideTransition(
                            position: _slideAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: _buildModernHeader(isDarkMode),
                            ),
                          ),
                          
                          const Spacer(flex: 3),
                          
                          // Formulário
                          SlideTransition(
                            position: _slideAnimation,
                            child: _buildModernForm(isDarkMode),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Botão de Login
                          ScaleTransition(
                            scale: _buttonScaleAnimation,
                            child: _buildModernLoginButton(isDarkMode),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Links adicionais
                          _buildAdditionalLinks(isDarkMode),
                          
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo secundário
        Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/logo_secondary.png',
            height: 80,
            width: 80,
            errorBuilder: (context, error, stackTrace) {
              print('Erro ao carregar logo: $error');
              return Container(
                height: 80,
                width: 80,
                color: Colors.red.withValues(alpha: 0.3),
                child: const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 40,
                ),
              );
            },
          ),
        ),

        // Título com animação
        RichText(
          textAlign: TextAlign.left,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'SI',
                style: TextStyle(
                  fontFamily: 'TafelSansPro',
                  fontSize: 47,
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
                  fontSize: 47,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF256525),
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: 'PLIFY',
                style: TextStyle(
                  fontFamily: 'TafelSansPro',
                  fontSize: 47,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Subtítulo
        Text(
          'Faça login para continuar',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode
                ? AppColors.secondaryText.withValues(alpha: 0.8)
                : AppColors.charcoalGrey.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildModernForm(bool isDarkMode) {
    return Column(
      children: [
        // Campo de E-mail
        _buildModernInputField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          label: 'E-mail',
          hint: 'seu@email.com',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          isDarkMode: isDarkMode,
        ),
        
        const SizedBox(height: 20),
        
        // Campo de Senha
        _buildModernInputField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          label: 'Senha',
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          validator: _validatePassword,
          isDarkMode: isDarkMode,
        ),
        
        const SizedBox(height: 20),
        
        // Remember me e Esqueci senha
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Remember me com checkbox customizado
            GestureDetector(
              onTap: () {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
                HapticFeedback.selectionClick();
              },
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _rememberMe
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _rememberMe
                            ? AppColors.primaryGreen
                            : (isDarkMode
                                ? AppColors.lightGrey.withValues(alpha: 0.3)
                                : AppColors.charcoalGrey.withValues(alpha: 0.3)),
                        width: 2,
                      ),
                    ),
                    child: _rememberMe
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lembrar-me',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? AppColors.secondaryText
                          : AppColors.charcoalGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Esqueci senha
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Recuperação de senha em desenvolvimento'),
                    backgroundColor: AppColors.info,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(20),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: Text(
                'Esqueci a senha',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required bool isDarkMode,
  }) {
    final bool isFocused = focusNode.hasFocus;
    final bool hasText = controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label animado
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: isFocused || hasText ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: isFocused
                ? AppColors.primaryGreen
                : (isDarkMode
                    ? AppColors.secondaryText
                    : AppColors.charcoalGrey),
            letterSpacing: 0.5,
          ),
          child: Text(label),
        ),
        
        const SizedBox(height: 8),
        
        // Campo de input com design moderno
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.charcoalGrey.withValues(alpha: 0.3)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused
                  ? AppColors.primaryGreen
                  : (isDarkMode
                      ? AppColors.lightGrey.withValues(alpha: 0.1)
                      : AppColors.lightGrey.withValues(alpha: 0.5)),
              width: isFocused ? 2 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isPassword && !_isPasswordVisible,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(
              color: isDarkMode ? AppColors.primaryText : AppColors.deepBlack,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: AppColors.primaryGreen,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDarkMode
                    ? AppColors.secondaryText.withValues(alpha: 0.4)
                    : AppColors.charcoalGrey.withValues(alpha: 0.4),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: isFocused
                      ? AppColors.primaryGreen
                      : (isDarkMode
                          ? AppColors.secondaryText.withValues(alpha: 0.5)
                          : AppColors.charcoalGrey.withValues(alpha: 0.5)),
                  size: 24,
                ),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          key: ValueKey(_isPasswordVisible),
                          color: isDarkMode
                              ? AppColors.secondaryText.withValues(alpha: 0.5)
                              : AppColors.charcoalGrey.withValues(alpha: 0.5),
                          size: 22,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernLoginButton(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 56,
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
            color: AppColors.primaryGreen.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  _handleLogin();
                },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.iceWhite,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.iceWhite,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.iceWhite,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalLinks(bool isDarkMode) {
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
                      isDarkMode
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
                  color: isDarkMode
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
                      isDarkMode
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
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDarkMode
                ? AppColors.charcoalGrey.withValues(alpha: 0.3)
                : Colors.white,
            border: Border.all(
              color: isDarkMode
                  ? AppColors.lightGrey.withValues(alpha: 0.2)
                  : AppColors.lightGrey.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                
                // Navega para a nova tela de boas-vindas do cadastro
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const WelcomeRegistrationScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 600),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Text(
                  'Criar conta gratuita',
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
      ],
    );
  }
}