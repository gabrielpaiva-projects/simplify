import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../data/models/address_model.dart';
import '../../data/services/cep_service.dart';

class UnifiedRegistrationScreen extends StatefulWidget {
  final UserType userType;
  
  const UnifiedRegistrationScreen({
    super.key,
    required this.userType,
  });

  @override
  State<UnifiedRegistrationScreen> createState() => _UnifiedRegistrationScreenState();
}

class _UnifiedRegistrationScreenState extends State<UnifiedRegistrationScreen>
    with TickerProviderStateMixin {
  // Controllers
  final PageController _pageController = PageController();
  
  // Common Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Client specific
  final _cpfController = TextEditingController();
  
  // Professional specific
  final _professionalDocController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  
  // Address Controllers
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  
  // Form Keys
  final _personalFormKey = GlobalKey<FormState>();
  final _credentialsFormKey = GlobalKey<FormState>();
  final _professionalFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  
  // Masks
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  final _cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  // Animation Controllers
  late AnimationController _progressController;
  late AnimationController _stepController;
  late AnimationController _floatingController;
  
  // Animations
  late Animation<double> _progressAnimation;
  late Animation<double> _stepFadeAnimation;
  late Animation<double> _stepSlideAnimation;
  late Animation<double> _floatingAnimation;
  
  // State
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  List<String> _selectedSpecialties = [];
  
  // Steps configuration based on user type
  late List<RegistrationStep> _steps;
  
  @override
  void initState() {
    super.initState();
    _initializeSteps();
    _initializeAnimations();
    _startAnimations();
  }
  
  void _initializeSteps() {
    if (widget.userType == UserType.client) {
      _steps = [
        RegistrationStep(
          title: 'Informações Pessoais',
          subtitle: 'Vamos começar com seus dados básicos',
          icon: Icons.person_rounded,
        ),
        RegistrationStep(
          title: 'Criar Senha',
          subtitle: 'Defina uma senha segura para sua conta',
          icon: Icons.lock_rounded,
        ),
        RegistrationStep(
          title: 'Endereço',
          subtitle: 'Onde você precisa de cuidados?',
          icon: Icons.location_on_rounded,
        ),
        RegistrationStep(
          title: 'Confirmação',
          subtitle: 'Revise seus dados e finalize',
          icon: Icons.check_circle_rounded,
        ),
      ];
    } else {
      _steps = [
        RegistrationStep(
          title: 'Informações Pessoais',
          subtitle: 'Seus dados básicos',
          icon: Icons.person_rounded,
        ),
        RegistrationStep(
          title: 'Dados Profissionais',
          subtitle: 'Suas qualificações e experiência',
          icon: Icons.medical_services_rounded,
        ),
        RegistrationStep(
          title: 'Criar Senha',
          subtitle: 'Defina uma senha segura',
          icon: Icons.lock_rounded,
        ),
        RegistrationStep(
          title: 'Endereço',
          subtitle: 'Sua área de atendimento',
          icon: Icons.location_on_rounded,
        ),
        RegistrationStep(
          title: 'Confirmação',
          subtitle: 'Revise e finalize seu cadastro',
          icon: Icons.check_circle_rounded,
        ),
      ];
    }
  }
  
  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _stepController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _stepFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _stepSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _stepController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _startAnimations() {
    _progressController.forward();
    _stepController.forward();
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _stepController.dispose();
    _floatingController.dispose();
    _pageController.dispose();
    
    // Dispose all controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cpfController.dispose();
    _professionalDocController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    
    super.dispose();
  }
  
  void _nextStep() async {
    // Validate current step
    bool isValid = false;
    
    if (widget.userType == UserType.client) {
      switch (_currentStep) {
        case 0:
          isValid = _personalFormKey.currentState?.validate() ?? false;
          break;
        case 1:
          isValid = _credentialsFormKey.currentState?.validate() ?? false;
          break;
        case 2:
          isValid = _addressFormKey.currentState?.validate() ?? false;
          break;
        case 3:
          // Final confirmation
          _submitRegistration();
          return;
      }
    } else {
      switch (_currentStep) {
        case 0:
          isValid = _personalFormKey.currentState?.validate() ?? false;
          break;
        case 1:
          isValid = _professionalFormKey.currentState?.validate() ?? false;
          break;
        case 2:
          isValid = _credentialsFormKey.currentState?.validate() ?? false;
          break;
        case 3:
          isValid = _addressFormKey.currentState?.validate() ?? false;
          break;
        case 4:
          // Final confirmation
          _submitRegistration();
          return;
      }
    }
    
    if (isValid) {
      HapticFeedback.lightImpact();
      
      // Reset animations
      _stepController.reset();
      
      setState(() {
        _currentStep++;
      });
      
      // Animate to next page
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      
      // Start animations
      _progressController.forward();
      _stepController.forward();
    } else {
      HapticFeedback.mediumImpact();
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      
      _stepController.reset();
      
      setState(() {
        _currentStep--;
      });
      
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      
      _stepController.forward();
    }
  }
  
  Future<void> _searchCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cep.length != 8) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final address = await CepService.fetchAddressByCep(cep);
      
      if (address != null) {
        setState(() {
          _streetController.text = address.logradouro;
          _neighborhoodController.text = address.bairro;
          _cityController.text = address.localidade;
          _stateController.text = address.uf;
        });
        
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _submitRegistration() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      // Navigate to success screen or home
      _showSuccessDialog();
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SuccessDialog(
        userType: widget.userType,
        onContinue: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background
          _buildBackground(size, isDarkMode),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(isDarkMode),
                
                // Progress Indicator
                _buildProgressIndicator(isDarkMode),
                
                // Step Info
                _buildStepInfo(isDarkMode),
                
                // Form Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _buildStepPages(isDarkMode),
                  ),
                ),
                
                // Navigation Buttons
                _buildNavigationButtons(isDarkMode),
              ],
            ),
          ),
          
          // Loading Overlay
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }
  
  Widget _buildBackground(Size size, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      AppColors.deepBlack,
                      AppColors.charcoalGrey.withOpacity(0.95),
                    ]
                  : [
                      Colors.white,
                      AppColors.lightGrey.withOpacity(0.1),
                    ],
            ),
          ),
          child: Stack(
            children: [
              // Floating circles
              Positioned(
                top: 100 + _floatingAnimation.value,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (widget.userType == UserType.professional
                                ? AppColors.primaryGreen
                                : AppColors.primaryGreen)
                            .withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 200 - _floatingAnimation.value,
                left: -80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (widget.userType == UserType.professional
                                ? AppColors.mediumGreen
                                : AppColors.mediumGreen)
                            .withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: _currentStep > 0 ? _previousStep : () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? AppColors.charcoalGrey.withOpacity(0.3)
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: isDarkMode ? AppColors.primaryText : AppColors.deepBlack,
              ),
            ),
          ),
          
          const Spacer(),
          
          // User Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: widget.userType == UserType.professional
                    ? [AppColors.primaryGreen, AppColors.mediumGreen]
                    : [AppColors.primaryGreen, AppColors.mediumGreen],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.userType == UserType.professional
                      ? Icons.medical_services_rounded
                      : Icons.favorite_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.userType == UserType.professional
                      ? 'Profissional'
                      : 'Cliente',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Progress Bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isDarkMode
                      ? AppColors.charcoalGrey.withOpacity(0.3)
                      : AppColors.lightGrey.withOpacity(0.3),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: constraints.maxWidth *
                              ((_currentStep + 1) / _steps.length),
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: widget.userType == UserType.professional
                                  ? [AppColors.primaryGreen, AppColors.mediumGreen]
                                  : [AppColors.primaryGreen, AppColors.mediumGreen],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // Step Counter
          Text(
            'Passo ${_currentStep + 1} de ${_steps.length}',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode
                  ? AppColors.secondaryText.withOpacity(0.6)
                  : AppColors.charcoalGrey.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepInfo(bool isDarkMode) {
    final currentStep = _steps[_currentStep];
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: _stepController,
        builder: (context, child) {
          return Opacity(
            opacity: _stepFadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _stepSlideAnimation.value),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: widget.userType == UserType.professional
                            ? [
                                AppColors.primaryGreen.withOpacity(0.1),
                                AppColors.mediumGreen.withOpacity(0.1),
                              ]
                            : [
                                AppColors.primaryGreen.withOpacity(0.1),
                                AppColors.mediumGreen.withOpacity(0.1),
                              ],
                      ),
                    ),
                    child: Icon(
                      currentStep.icon,
                      color: widget.userType == UserType.professional
                          ? AppColors.primaryGreen
                          : AppColors.primaryGreen,
                      size: 32,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    currentStep.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.primaryText : AppColors.deepBlack,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    currentStep.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? AppColors.secondaryText.withOpacity(0.7)
                          : AppColors.charcoalGrey.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  List<Widget> _buildStepPages(bool isDarkMode) {
    if (widget.userType == UserType.client) {
      return [
        _buildPersonalInfoStep(isDarkMode),
        _buildPasswordStep(isDarkMode),
        _buildAddressStep(isDarkMode),
        _buildConfirmationStep(isDarkMode),
      ];
    } else {
      return [
        _buildPersonalInfoStep(isDarkMode),
        _buildProfessionalInfoStep(isDarkMode),
        _buildPasswordStep(isDarkMode),
        _buildAddressStep(isDarkMode),
        _buildConfirmationStep(isDarkMode),
      ];
    }
  }
  
  Widget _buildPersonalInfoStep(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _personalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernTextField(
              controller: _nameController,
              label: 'Nome completo',
              hint: 'Digite seu nome completo',
              icon: Icons.person_outline_rounded,
              isDarkMode: isDarkMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nome é obrigatório';
                }
                if (value.length < 3) {
                  return 'Nome deve ter pelo menos 3 caracteres';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            _buildModernTextField(
              controller: _emailController,
              label: 'E-mail',
              hint: 'seu@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              isDarkMode: isDarkMode,
              validator: (value) {
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
              },
            ),
            
            const SizedBox(height: 20),
            
            _buildModernTextField(
              controller: _phoneController,
              label: 'Telefone',
              hint: '(00) 00000-0000',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [_phoneMask],
              isDarkMode: isDarkMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Telefone é obrigatório';
                }
                if (value.length < 15) {
                  return 'Digite um telefone válido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            if (widget.userType == UserType.client)
              _buildModernTextField(
                controller: _cpfController,
                label: 'CPF',
                hint: '000.000.000-00',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [_cpfMask],
                isDarkMode: isDarkMode,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'CPF é obrigatório';
                  }
                  if (value.length < 14) {
                    return 'Digite um CPF válido';
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfessionalInfoStep(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _professionalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernTextField(
              controller: _professionalDocController,
              label: 'Documento Profissional',
              hint: 'COREN, CRM, etc.',
              icon: Icons.verified_user_outlined,
              isDarkMode: isDarkMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Documento profissional é obrigatório';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            _buildSpecialtySelector(isDarkMode),
            
            const SizedBox(height: 20),
            
            _buildModernTextField(
              controller: _experienceController,
              label: 'Anos de Experiência',
              hint: 'Ex: 5 anos',
              icon: Icons.work_outline_rounded,
              keyboardType: TextInputType.number,
              isDarkMode: isDarkMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Experiência é obrigatória';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            _buildModernTextField(
              controller: _bioController,
              label: 'Sobre você',
              hint: 'Conte um pouco sobre sua experiência e especialidades',
              icon: Icons.description_outlined,
              maxLines: 4,
              isDarkMode: isDarkMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, escreva sobre você';
                }
                if (value.length < 50) {
                  return 'Escreva pelo menos 50 caracteres';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPasswordStep(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _credentialsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernTextField(
              controller: _passwordController,
              label: 'Senha',
              hint: 'Mínimo 8 caracteres',
              icon: Icons.lock_outline_rounded,
              obscureText: !_isPasswordVisible,
              isDarkMode: isDarkMode,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: isDarkMode
                      ? AppColors.secondaryText.withOpacity(0.5)
                      : AppColors.charcoalGrey.withOpacity(0.5),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Senha é obrigatória';
                }
                if (value.length < 8) {
                  return 'A senha deve ter pelo menos 8 caracteres';
                }
                if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
                  return 'A senha deve conter letras minúsculas';
                }
                if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                  return 'A senha deve conter letras maiúsculas';
                }
                if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                  return 'A senha deve conter números';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            _buildModernTextField(
              controller: _confirmPasswordController,
              label: 'Confirmar senha',
              hint: 'Digite a senha novamente',
              icon: Icons.lock_outline_rounded,
              obscureText: !_isConfirmPasswordVisible,
              isDarkMode: isDarkMode,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: isDarkMode
                      ? AppColors.secondaryText.withOpacity(0.5)
                      : AppColors.charcoalGrey.withOpacity(0.5),
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirmação de senha é obrigatória';
                }
                if (value != _passwordController.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            
            // Password Requirements
            _buildPasswordRequirements(isDarkMode),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddressStep(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _addressFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernTextField(
              controller: _cepController,
              label: 'CEP',
              hint: '00000-000',
              icon: Icons.location_searching_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [_cepMask],
              isDarkMode: isDarkMode,
              onChanged: (value) {
                if (value.replaceAll(RegExp(r'[^0-9]'), '').length == 8) {
                  _searchCep();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'CEP é obrigatório';
                }
                if (value.length < 9) {
                  return 'Digite um CEP válido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildModernTextField(
                    controller: _streetController,
                    label: 'Rua',
                    hint: 'Nome da rua',
                    icon: Icons.route_outlined,
                    isDarkMode: isDarkMode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Rua é obrigatória';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernTextField(
                    controller: _numberController,
                    label: 'Número',
                    hint: '000',
                    icon: Icons.numbers_rounded,
                    keyboardType: TextInputType.number,
                    isDarkMode: isDarkMode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            _buildModernTextField(
              controller: _complementController,
              label: 'Complemento (opcional)',
              hint: 'Apto, bloco, etc.',
              icon: Icons.home_outlined,
              isDarkMode: isDarkMode,
            ),
            
            const SizedBox(height: 20),
            
            _buildModernTextField(
              controller: _neighborhoodController,
              label: 'Bairro',
              hint: 'Nome do bairro',
              icon: Icons.location_city_rounded,
              isDarkMode: isDarkMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bairro é obrigatório';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildModernTextField(
                    controller: _cityController,
                    label: 'Cidade',
                    hint: 'Nome da cidade',
                    icon: Icons.location_city_outlined,
                    isDarkMode: isDarkMode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cidade é obrigatória';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernTextField(
                    controller: _stateController,
                    label: 'Estado',
                    hint: 'UF',
                    icon: Icons.map_outlined,
                    isDarkMode: isDarkMode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'UF';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConfirmationStep(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Success Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: widget.userType == UserType.professional
                    ? [AppColors.primaryGreen, AppColors.mediumGreen]
                    : [AppColors.primaryGreen, AppColors.mediumGreen],
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 50,
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Tudo pronto!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.primaryText : AppColors.deepBlack,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Revise seus dados antes de finalizar o cadastro',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode
                  ? AppColors.secondaryText.withOpacity(0.7)
                  : AppColors.charcoalGrey.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Summary Cards
          _buildSummaryCard(
            title: 'Dados Pessoais',
            items: [
              SummaryItem('Nome', _nameController.text),
              SummaryItem('E-mail', _emailController.text),
              SummaryItem('Telefone', _phoneController.text),
              if (widget.userType == UserType.client)
                SummaryItem('CPF', _cpfController.text),
            ],
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 16),
          
          if (widget.userType == UserType.professional) ...[
            _buildSummaryCard(
              title: 'Dados Profissionais',
              items: [
                SummaryItem('Documento', _professionalDocController.text),
                SummaryItem('Especialidades', _selectedSpecialties.join(', ')),
                SummaryItem('Experiência', _experienceController.text),
              ],
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),
          ],
          
          _buildSummaryCard(
            title: 'Endereço',
            items: [
              SummaryItem(
                'Endereço',
                '${_streetController.text}, ${_numberController.text}',
              ),
              SummaryItem('Bairro', _neighborhoodController.text),
              SummaryItem(
                'Cidade/Estado',
                '${_cityController.text}/${_stateController.text}',
              ),
            ],
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
  
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? AppColors.primaryText.withOpacity(0.9)
                : AppColors.deepBlack.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDarkMode
                ? AppColors.charcoalGrey.withOpacity(0.3)
                : Colors.white,
            border: Border.all(
              color: isDarkMode
                  ? AppColors.lightGrey.withOpacity(0.2)
                  : AppColors.lightGrey.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            obscureText: obscureText,
            maxLines: maxLines,
            validator: validator,
            onChanged: onChanged,
            style: TextStyle(
              color: isDarkMode ? AppColors.primaryText : AppColors.deepBlack,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDarkMode
                    ? AppColors.secondaryText.withOpacity(0.4)
                    : AppColors.charcoalGrey.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                icon,
                color: widget.userType == UserType.professional
                    ? AppColors.primaryGreen
                    : AppColors.primaryGreen,
                size: 22,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSpecialtySelector(bool isDarkMode) {
    final specialties = [
      'Enfermagem',
      'Fisioterapia',
      'Cuidador de Idosos',
      'Técnico em Enfermagem',
      'Psicologia',
      'Nutrição',
      'Fonoaudiologia',
      'Terapia Ocupacional',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Especialidades',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? AppColors.primaryText.withOpacity(0.9)
                : AppColors.deepBlack.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: specialties.map((specialty) {
            final isSelected = _selectedSpecialties.contains(specialty);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSpecialties.remove(specialty);
                  } else {
                    _selectedSpecialties.add(specialty);
                  }
                });
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.mediumGreen,
                          ],
                        )
                      : null,
                  color: !isSelected
                      ? (isDarkMode
                          ? AppColors.charcoalGrey.withOpacity(0.3)
                          : Colors.white)
                      : null,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDarkMode
                            ? AppColors.lightGrey.withOpacity(0.2)
                            : AppColors.lightGrey.withOpacity(0.3)),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode
                            ? AppColors.primaryText
                            : AppColors.deepBlack),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildPasswordRequirements(bool isDarkMode) {
    final password = _passwordController.text;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode
            ? AppColors.charcoalGrey.withOpacity(0.2)
            : AppColors.lightGrey.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requisitos da senha:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? AppColors.primaryText.withOpacity(0.9)
                  : AppColors.deepBlack.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          _buildRequirementItem(
            'Mínimo 8 caracteres',
            password.length >= 8,
            isDarkMode,
          ),
          _buildRequirementItem(
            'Uma letra maiúscula',
            RegExp(r'(?=.*[A-Z])').hasMatch(password),
            isDarkMode,
          ),
          _buildRequirementItem(
            'Uma letra minúscula',
            RegExp(r'(?=.*[a-z])').hasMatch(password),
            isDarkMode,
          ),
          _buildRequirementItem(
            'Um número',
            RegExp(r'(?=.*\d)').hasMatch(password),
            isDarkMode,
          ),
        ],
      ),
    );
  }
  
  Widget _buildRequirementItem(String text, bool isValid, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: isValid ? AppColors.primaryGreen : AppColors.lightGrey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode
                  ? AppColors.secondaryText.withOpacity(0.7)
                  : AppColors.charcoalGrey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard({
    required String title,
    required List<SummaryItem> items,
    required bool isDarkMode,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode
            ? AppColors.charcoalGrey.withOpacity(0.3)
            : Colors.white,
        border: Border.all(
          color: isDarkMode
              ? AppColors.lightGrey.withOpacity(0.2)
              : AppColors.lightGrey.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.userType == UserType.professional
                  ? AppColors.primaryGreen
                  : AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? AppColors.secondaryText.withOpacity(0.7)
                            : AppColors.charcoalGrey.withOpacity(0.7),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode
                              ? AppColors.primaryText
                              : AppColors.deepBlack,
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
  
  Widget _buildNavigationButtons(bool isDarkMode) {
    final isLastStep = _currentStep == _steps.length - 1;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.deepBlack.withOpacity(0.5)
            : Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: widget.userType == UserType.professional
                  ? [AppColors.primaryGreen, AppColors.mediumGreen]
                  : [AppColors.primaryGreen, AppColors.mediumGreen],
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.userType == UserType.professional
                        ? AppColors.primaryGreen
                        : AppColors.primaryGreen)
                    .withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _nextStep,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Text(
                  isLastStep ? 'Finalizar cadastro' : 'Continuar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.charcoalGrey
                : Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.userType == UserType.professional
                      ? AppColors.primaryGreen
                      : AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Processando...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Classes
class RegistrationStep {
  final String title;
  final String subtitle;
  final IconData icon;
  
  RegistrationStep({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class SummaryItem {
  final String label;
  final String value;
  
  SummaryItem(this.label, this.value);
}

// Success Dialog
class _SuccessDialog extends StatefulWidget {
  final UserType userType;
  final VoidCallback onContinue;
  
  const _SuccessDialog({
    required this.userType,
    required this.onContinue,
  });
  
  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
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
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: isDarkMode ? AppColors.charcoalGrey : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: widget.userType == UserType.professional
                          ? [AppColors.primaryGreen, AppColors.mediumGreen]
                          : [AppColors.primaryGreen, AppColors.mediumGreen],
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'Cadastro realizado!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.primaryText : AppColors.deepBlack,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Sua conta foi criada com sucesso.\nBem-vindo ao CareConnect!',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? AppColors.secondaryText.withOpacity(0.7)
                        : AppColors.charcoalGrey.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: widget.userType == UserType.professional
                          ? [AppColors.primaryGreen, AppColors.mediumGreen]
                          : [AppColors.primaryGreen, AppColors.mediumGreen],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onContinue,
                      borderRadius: BorderRadius.circular(12),
                      child: const Center(
                        child: Text(
                          'Começar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
    );
  }
}