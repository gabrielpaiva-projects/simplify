import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:mask_text_input_formatter/mask_text_input_formatter.dart";
import "package:animate_do/animate_do.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:flutter_spinkit/flutter_spinkit.dart";
import "package:google_fonts/google_fonts.dart";
import "dart:ui";
import "dart:math" as math;

class ModernClientRegistration extends StatefulWidget {
  const ModernClientRegistration({super.key});

  @override
  State<ModernClientRegistration> createState() => _ModernClientRegistrationState();
}

class _ModernClientRegistrationState extends State<ModernClientRegistration> 
    with TickerProviderStateMixin {
  // Controllers
  final PageController _pageController = PageController();
  late AnimationController _backgroundAnimationController;
  late AnimationController _floatingAnimationController;
  
  // Step 1: Dados Pessoais
  final _cpfController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Step 2: Senha
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Step 3: Endereço
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  
  // Form Keys
  final _personalDataFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  
  // Masks
  final _cpfMask = MaskTextInputFormatter(
    mask: "###.###.###-##",
    filter: {"#": RegExp(r"[0-9]")},
  );
  
  final _cepMask = MaskTextInputFormatter(
    mask: "#####-###",
    filter: {"#": RegExp(r"[0-9]")},
  );
  
  // States
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  double _passwordStrength = 0;
  
  // Modern Theme Colors
  static const Color primaryGradientStart = Color(0xFF6B46C1);
  static const Color primaryGradientEnd = Color(0xFF4C7EF3);
  static const Color backgroundDark = Color(0xFF0A0E21);
  static const Color backgroundLight = Color(0xFF1A1F36);
  static const Color cardBackground = Color(0xFF1E2336);
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8BCC8);
  static const Color accentCyan = Color(0xFF48BFE3);
  static const Color successGreen = Color(0xFF00C9A7);
  static const Color errorRed = Color(0xFFFF4757);
  
  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _passwordController.addListener(_calculatePasswordStrength);
    
    // Haptic feedback on focus
    HapticFeedback.selectionClick();
  }
  
  void _calculatePasswordStrength() {
    String password = _passwordController.text;
    double strength = 0;
    
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r"[A-Z]"))) strength += 0.25;
    if (password.contains(RegExp(r"[0-9]"))) strength += 0.25;
    if (password.contains(RegExp(r\"[!@#\$%^&*(),.?\":{}|<>]\"))) strength += 0.25;
    
    setState(() {
      _passwordStrength = strength;
    });
  }
  
  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _floatingAnimationController.dispose();
    _pageController.dispose();
    _cpfController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      math.sin(_backgroundAnimationController.value * 2 * math.pi),
                      math.cos(_backgroundAnimationController.value * 2 * math.pi),
                    ),
                    end: Alignment(
                      -math.sin(_backgroundAnimationController.value * 2 * math.pi),
                      -math.cos(_backgroundAnimationController.value * 2 * math.pi),
                    ),
                    colors: const [
                      backgroundDark,
                      backgroundLight,
                      Color(0xFF2A2F45),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Modern App Bar
                _buildModernAppBar(),
                
                // Progress Indicator
                _buildProgressIndicator(),
                
                // Form Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                      HapticFeedback.lightImpact();
                    },
                    children: [
                      _buildPersonalDataStep(),
                      _buildPasswordStep(),
                      _buildAddressStep(),
                    ],
                  ),
                ),
                
                // Navigation Buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
          
          // Loading Overlay
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }
  
  // ... Rest of the methods would continue here
  
  Widget _buildModernAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (_currentStep > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: glassWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: glassBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: textPrimary,
                size: 20,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Criar Conta",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0),
                const SizedBox(height: 4),
                Text(
                  _getStepTitle(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    return Container();
  }
  
  Widget _buildPersonalDataStep() {
    return Container();
  }
  
  Widget _buildPasswordStep() {
    return Container();
  }
  
  Widget _buildAddressStep() {
    return Container();
  }
  
  Widget _buildNavigationButtons() {
    return Container();
  }
  
  Widget _buildLoadingOverlay() {
    return Container();
  }
  
  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return "Passo 1 de 3 - Informações Pessoais";
      case 1:
        return "Passo 2 de 3 - Segurança";
      case 2:
        return "Passo 3 de 3 - Localização";
      default:
        return "";
    }
  }
}
