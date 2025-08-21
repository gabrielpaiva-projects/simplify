import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../data/services/cep_service.dart';
import '../widgets/modern_text_field.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/animated_button.dart';
import 'registration_success_screen.dart';

class UnifiedRegistrationScreen extends StatefulWidget {
  final bool isProfessional;
  
  const UnifiedRegistrationScreen({
    super.key,
    required this.isProfessional,
  });

  @override
  State<UnifiedRegistrationScreen> createState() => _UnifiedRegistrationScreenState();
}

class _UnifiedRegistrationScreenState extends State<UnifiedRegistrationScreen>
    with TickerProviderStateMixin {
  // Page Controller
  final PageController _pageController = PageController();
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  
  // Focus Nodes
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _cpfFocusNode = FocusNode();
  final _rgFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  // Form Keys
  final _personalFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final _documentsFormKey = GlobalKey<FormState>();
  
  // Masks
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  final _rgMask = MaskTextInputFormatter(
    mask: '##.###.###-#',
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
  
  // States
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSearchingCep = false;
  bool _acceptTerms = false;
  
  // Documents (for professionals)
  File? _addressProofFile;
  String? _addressProofFileName;
  File? _profilePhotoFile;
  
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _progressController;
  late AnimationController _shakeController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _shakeAnimation;
  
  // Image Picker
  final ImagePicker _imagePicker = ImagePicker();
  
  // Steps
  late List<String> _stepTitles;
  late List<String> _stepSubtitles;
  late List<IconData> _stepIcons;
  
  @override
  void initState() {
    super.initState();
    _setupSteps();
    _setupAnimations();
    _startAnimations();
  }
  
  void _setupSteps() {
    if (widget.isProfessional) {
      _stepTitles = [
        'Informações Pessoais',
        'Segurança',
        'Endereço',
        'Documentos',
      ];
      _stepSubtitles = [
        'Seus dados básicos',
        'Crie uma senha forte',
        'Onde você atende',
        'Comprove sua identidade',
      ];
      _stepIcons = [
        Icons.person_rounded,
        Icons.lock_rounded,
        Icons.location_on_rounded,
        Icons.badge_rounded,
      ];
    } else {
      _stepTitles = [
        'Informações Pessoais',
        'Segurança',
        'Endereço',
      ];
      _stepSubtitles = [
        'Seus dados básicos',
        'Crie uma senha forte',
        'Para onde vamos',
      ];
      _stepIcons = [
        Icons.person_rounded,
        Icons.lock_rounded,
        Icons.location_on_rounded,
      ];
    }
  }
  
  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }
  
  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _progressController.forward();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _cpfFocusNode.dispose();
    _rgFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _progressController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
  
  Future<void> _searchCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) return;
    
    setState(() {
      _isSearchingCep = true;
    });
    
    try {
      final address = await CepService.searchCep(cep);
      if (address != null && mounted) {
        setState(() {
          _streetController.text = address.logradouro;
          _neighborhoodController.text = address.bairro;
          _cityController.text = address.localidade;
          _stateController.text = address.uf;
        });
        
        // Focus on number field
        FocusScope.of(context).requestFocus(FocusNode());
        await Future.delayed(const Duration(milliseconds: 100));
        FocusScope.of(context).requestFocus(FocusNode());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar CEP: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingCep = false;
        });
      }
    }
  }
  
  Future<void> _pickProfilePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      
      if (image != null && mounted) {
        setState(() {
          _profilePhotoFile = File(image.path);
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar foto: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  Future<void> _pickAddressProof() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      
      if (result != null && mounted) {
        setState(() {
          _addressProofFile = File(result.files.single.path!);
          _addressProofFileName = result.files.single.name;
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar documento: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  void _nextStep() async {
    bool isValid = false;
    
    switch (_currentStep) {
      case 0:
        isValid = _personalFormKey.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _passwordFormKey.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _addressFormKey.currentState?.validate() ?? false;
        break;
      case 3:
        isValid = _documentsFormKey.currentState?.validate() ?? false;
        break;
    }
    
    if (!isValid) {
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });
      HapticFeedback.heavyImpact();
      return;
    }
    
    HapticFeedback.mediumImpact();
    
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      
      // Reset animations for new step
      _slideController.reset();
      _fadeController.reset();
      _startAnimations();
    } else {
      // Final step - submit registration
      _submitRegistration();
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep--;
      });
      
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      
      // Reset animations for new step
      _slideController.reset();
      _fadeController.reset();
      _startAnimations();
    }
  }
  
  Future<void> _submitRegistration() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa aceitar os termos de uso'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              RegistrationSuccessScreen(
                userName: _nameController.text,
                isProfessional: widget.isProfessional,
              ),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.deepBlack,
                  AppColors.greyBlack,
                  AppColors.charcoalGrey.withOpacity(0.5),
                ],
              ),
            ),
          ),
          
          // Decorative Elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Step Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: StepProgressBar(
                    currentStep: _currentStep,
                    totalSteps: _stepTitles.length,
                    stepTitles: _stepTitles,
                    stepIcons: _stepIcons,
                    onStepTapped: (step) {
                      // Allow navigation to previous steps only
                      if (step < _currentStep) {
                        setState(() {
                          _currentStep = step;
                        });
                        _pageController.animateToPage(
                          step,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    },
                  ),
                ),
                
                // Form Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildPersonalInfoStep(),
                      _buildPasswordStep(),
                      _buildAddressStep(),
                      if (widget.isProfessional) _buildDocumentsStep(),
                    ],
                  ),
                ),
                
                // Bottom Navigation
                _buildBottomNavigation(),
              ],
            ),
          ),
          
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Criando sua conta...',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 16,
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
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              if (_currentStep > 0) {
                _previousStep();
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.charcoalGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.darkGrey,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryText,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stepTitles[_currentStep],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _stepSubtitles[_currentStep],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPersonalInfoStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _personalFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo (optional)
                if (widget.isProfessional) ...[
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfilePhoto,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.charcoalGrey,
                          border: Border.all(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            width: 2,
                          ),
                          image: _profilePhotoFile != null
                              ? DecorationImage(
                                  image: FileImage(_profilePhotoFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _profilePhotoFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_rounded,
                                    color: AppColors.primaryGreen,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Adicionar foto',
                                    style: TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                
                ModernTextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  label: 'Nome completo',
                  hint: 'Digite seu nome completo',
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome';
                    }
                    if (value.split(' ').length < 2) {
                      return 'Por favor, insira seu nome completo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                ModernTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  label: 'E-mail',
                  hint: 'seu@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu e-mail';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Por favor, insira um e-mail válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                ModernTextField(
                  controller: _cpfController,
                  focusNode: _cpfFocusNode,
                  label: 'CPF',
                  hint: '000.000.000-00',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cpfMask],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu CPF';
                    }
                    if (value.replaceAll(RegExp(r'[^0-9]'), '').length != 11) {
                      return 'CPF inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                if (widget.isProfessional) ...[
                  ModernTextField(
                    controller: _rgController,
                    focusNode: _rgFocusNode,
                    label: 'RG',
                    hint: '00.000.000-0',
                    prefixIcon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_rgMask],
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu RG';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                
                ModernTextField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  label: 'Telefone',
                  hint: '(00) 00000-0000',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneMask],
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu telefone';
                    }
                    if (value.replaceAll(RegExp(r'[^0-9]'), '').length != 11) {
                      return 'Telefone inválido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPasswordStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Security Tips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security_rounded,
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dica de Segurança',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use pelo menos 8 caracteres, incluindo letras maiúsculas, minúsculas, números e símbolos.',
                              style: TextStyle(
                                color: AppColors.secondaryText.withOpacity(0.8),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                ModernTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.secondaryText.withOpacity(0.5),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma senha';
                    }
                    if (value.length < 8) {
                      return 'A senha deve ter pelo menos 8 caracteres';
                    }
                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                      return 'Use letras maiúsculas, minúsculas e números';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 20),
                
                ModernTextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  label: 'Confirmar senha',
                  hint: 'Digite a senha novamente',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.secondaryText.withOpacity(0.5),
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme sua senha';
                    }
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Password Strength Indicator
                _buildPasswordStrengthIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    int strength = 0;
    String strengthText = 'Muito fraca';
    Color strengthColor = AppColors.error;
    
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#\$%\^&\*]').hasMatch(password)) strength++;
    
    switch (strength) {
      case 0:
      case 1:
        strengthText = 'Muito fraca';
        strengthColor = AppColors.error;
        break;
      case 2:
        strengthText = 'Fraca';
        strengthColor = Colors.orange;
        break;
      case 3:
        strengthText = 'Média';
        strengthColor = Colors.yellow;
        break;
      case 4:
        strengthText = 'Forte';
        strengthColor = AppColors.success;
        break;
      case 5:
        strengthText = 'Muito forte';
        strengthColor = AppColors.primaryGreen;
        break;
    }
    
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Força da senha',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: index < strength
                      ? strengthColor
                      : AppColors.darkGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          strengthText,
          style: TextStyle(
            color: strengthColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAddressStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _addressFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernTextField(
                  controller: _cepController,
                  label: 'CEP',
                  hint: '00000-000',
                  prefixIcon: Icons.location_on_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cepMask],
                  suffixIcon: _isSearchingCep
                      ? Container(
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGreen,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.search_rounded,
                            color: AppColors.primaryGreen,
                          ),
                          onPressed: _searchCep,
                        ),
                  onChanged: (value) {
                    if (value.replaceAll(RegExp(r'[^0-9]'), '').length == 8) {
                      _searchCep();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o CEP';
                    }
                    if (value.replaceAll(RegExp(r'[^0-9]'), '').length != 8) {
                      return 'CEP inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ModernTextField(
                        controller: _streetController,
                        label: 'Rua',
                        hint: 'Nome da rua',
                        prefixIcon: Icons.route_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernTextField(
                        controller: _numberController,
                        label: 'Número',
                        hint: '123',
                        keyboardType: TextInputType.number,
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
                
                ModernTextField(
                  controller: _complementController,
                  label: 'Complemento (opcional)',
                  hint: 'Apto, bloco, etc.',
                  prefixIcon: Icons.home_outlined,
                ),
                const SizedBox(height: 20),
                
                ModernTextField(
                  controller: _neighborhoodController,
                  label: 'Bairro',
                  hint: 'Nome do bairro',
                  prefixIcon: Icons.location_city_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o bairro';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ModernTextField(
                        controller: _cityController,
                        label: 'Cidade',
                        hint: 'Nome da cidade',
                        prefixIcon: Icons.location_city_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernTextField(
                        controller: _stateController,
                        label: 'Estado',
                        hint: 'UF',
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(2),
                        ],
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
        ),
      ),
    );
  }
  
  Widget _buildDocumentsStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _documentsFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.info,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Precisamos verificar sua identidade para garantir a segurança de todos os usuários.',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Address Proof Upload
                Text(
                  'Comprovante de Endereço',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Conta de luz, água, telefone ou extrato bancário',
                  style: TextStyle(
                    color: AppColors.secondaryText.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                
                GestureDetector(
                  onTap: _pickAddressProof,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.charcoalGrey,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _addressProofFile != null
                            ? AppColors.primaryGreen.withOpacity(0.5)
                            : AppColors.darkGrey,
                        width: 2,
                        style: _addressProofFile != null
                            ? BorderStyle.solid
                            : BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _addressProofFile != null
                              ? Icons.check_circle_rounded
                              : Icons.upload_file_rounded,
                          color: _addressProofFile != null
                              ? AppColors.primaryGreen
                              : AppColors.secondaryText.withOpacity(0.5),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _addressProofFile != null
                              ? _addressProofFileName ?? 'Arquivo selecionado'
                              : 'Clique para selecionar',
                          style: TextStyle(
                            color: _addressProofFile != null
                                ? AppColors.primaryGreen
                                : AppColors.secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_addressProofFile == null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'PDF, JPG ou PNG (máx. 5MB)',
                            style: TextStyle(
                              color: AppColors.secondaryText.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Terms and Conditions
                Row(
                  children: [
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                          HapticFeedback.lightImpact();
                        },
                        activeColor: AppColors.primaryGreen,
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptTerms = !_acceptTerms;
                          });
                          HapticFeedback.lightImpact();
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: 'Li e aceito os '),
                              TextSpan(
                                text: 'Termos de Uso',
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: ' e a '),
                              TextSpan(
                                text: 'Política de Privacidade',
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomNavigation() {
    final isLastStep = _currentStep == _stepTitles.length - 1;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.greyBlack,
        border: Border(
          top: BorderSide(
            color: AppColors.darkGrey,
            width: 1,
          ),
        ),
      ),
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: AnimatedButton(
              onPressed: _nextStep,
              text: isLastStep ? 'Criar Conta' : 'Continuar',
              isLoading: _isLoading,
              icon: isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded,
            ),
          );
        },
      ),
    );
  }
}