import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:io';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/cep_service.dart';
import '../widgets/terms_and_conditions_step.dart';

class ModernProfessionalRegistration extends StatefulWidget {
  const ModernProfessionalRegistration({super.key});

  @override
  State<ModernProfessionalRegistration> createState() => 
      _ModernProfessionalRegistrationState();
}

class _ModernProfessionalRegistrationState 
    extends State<ModernProfessionalRegistration>
    with TickerProviderStateMixin {
  // Controllers
  final PageController _pageController = PageController();
  
  // Step 1: Dados Pessoais
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
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
  final _personalFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final _documentsFormKey = GlobalKey<FormState>();
  final _termsFormKey = GlobalKey<FormState>();
  
  // Terms acceptance state
  bool _termsAccepted = false;
  
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
  File? _addressProofFile;
  String? _addressProofFileName;
  
  // Animation Controllers
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late List<AnimationController> _stepControllers;
  
  // Animations
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Image Picker
  final ImagePicker _imagePicker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    
    _stepControllers = List.generate(
      5, // 5 steps (including terms)
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start initial animations
    _fadeController.forward();
    _slideController.forward();
    _stepControllers[0].forward();
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    
    // Dispose text controllers
    _nameController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _emailController.dispose();
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
    
    _pageController.dispose();
    
    super.dispose();
  }
  
  void _nextStep() async {
    // Validate current step
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
        isValid = _addressProofFile != null;
        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, anexe o comprovante de residência'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
      case 4:
        // Validate terms acceptance
        isValid = _termsAccepted;
        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Você deve aceitar os termos e condições para continuar'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
    }
    
    if (isValid) {
      if (_currentStep < 4) {
        // Animate to next step
        await _stepControllers[_currentStep].reverse();
        
        setState(() {
          _currentStep++;
        });
        
        _progressController.forward();
        _stepControllers[_currentStep].forward();
        
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        // Complete registration
        _completeRegistration();
      }
    }
  }
  
  void _previousStep() async {
    if (_currentStep > 0) {
      await _stepControllers[_currentStep].reverse();
      
      setState(() {
        _currentStep--;
      });
      
      _progressController.reverse();
      _stepControllers[_currentStep].forward();
      
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _completeRegistration() async {
    setState(() {
      _isLoading = true;
    });
    
    // TODO: Implement registration logic
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
    });
    
    _showSuccessDialog();
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.charcoalGrey,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryGreen.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.2),
                      AppColors.mediumGreen.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.access_time_filled,
                  size: 40,
                  color: AppColors.primaryGreen,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Cadastro em Análise',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                'Seu cadastro foi recebido com sucesso!\n\nNossa equipe irá analisar suas informações e você receberá um e-mail em até 48 horas com o resultado.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Entendi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _searchCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cep.length != 8) return;
    
    setState(() {
      _isSearchingCep = true;
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
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isSearchingCep = false;
      });
    }
  }
  
  Future<void> _pickDocument() async {
    // Show options dialog
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.charcoalGrey,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escolha uma opção',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primaryGreen),
              title: const Text(
                'Tirar foto',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _imagePicker.pickImage(
                  source: ImageSource.camera,
                );
                if (photo != null) {
                  setState(() {
                    _addressProofFile = File(photo.path);
                    _addressProofFileName = photo.name;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primaryGreen),
              title: const Text(
                'Escolher da galeria',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _imagePicker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setState(() {
                    _addressProofFile = File(image.path);
                    _addressProofFileName = image.name;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.file_present, color: AppColors.primaryGreen),
              title: const Text(
                'Escolher arquivo PDF',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                if (result != null) {
                  setState(() {
                    _addressProofFile = File(result.files.single.path!);
                    _addressProofFileName = result.files.single.name;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black,
                  AppColors.charcoalGrey.withOpacity(0.5),
                ],
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Progress indicator
                _buildProgressIndicator(),
                
                // Form content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildPersonalDataStep(),
                          _buildPasswordStep(),
                          _buildAddressStep(),
                          _buildDocumentsStep(),
                          TermsAndConditionsStep(
                            animationController: _stepControllers[4],
                            formKey: _termsFormKey,
                            onAcceptanceChanged: (accepted) {
                              setState(() {
                                _termsAccepted = accepted;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Navigation buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
          
          // Loading overlay
          if (_isLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () {
              if (_currentStep > 0) {
                _previousStep();
              } else {
                Navigator.pop(context);
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cadastro Profissional',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStepTitle(),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Step indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentStep + 1}/5',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Dados Pessoais';
      case 1:
        return 'Criar Senha';
      case 2:
        return 'Endereço';
      case 3:
        return 'Comprovante de Residência';
      case 4:
        return 'Termos e Condições';
      default:
        return '';
    }
  }
  
  Widget _buildProgressIndicator() {
    return Container(
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (_currentStep + _progressAnimation.value) / 5,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryGreen,
              ),
              minHeight: 6,
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPersonalDataStep() {
    return AnimatedBuilder(
      animation: _stepControllers[0],
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_stepControllers[0].value * 0.1),
          child: Opacity(
            opacity: _stepControllers[0].value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _personalFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Name field
                    _ModernTextField(
                      controller: _nameController,
                      label: 'Nome completo',
                      icon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome completo';
                        }
                        if (value.split(' ').length < 2) {
                          return 'Por favor, insira seu nome completo';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // RG field
                    _ModernTextField(
                      controller: _rgController,
                      label: 'RG',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_rgMask],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu RG';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // CPF field
                    _ModernTextField(
                      controller: _cpfController,
                      label: 'CPF',
                      icon: Icons.credit_card_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_cpfMask],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu CPF';
                        }
                        final cpf = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (cpf.length != 11) {
                          return 'CPF inválido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Phone field
                    _ModernTextField(
                      controller: _phoneController,
                      label: 'Telefone para contato',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_phoneMask],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu telefone';
                        }
                        final phone = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (phone.length != 11) {
                          return 'Telefone inválido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Email field
                    _ModernTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu e-mail';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'E-mail inválido';
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
      },
    );
  }
  
  Widget _buildPasswordStep() {
    return AnimatedBuilder(
      animation: _stepControllers[1],
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_stepControllers[1].value * 0.1),
          child: Opacity(
            opacity: _stepControllers[1].value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _passwordFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Crie uma senha segura',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Mínimo de 8 caracteres com letras e números',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Password field
                    _ModernTextField(
                      controller: _passwordController,
                      label: 'Senha',
                      icon: Icons.lock_outline_rounded,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira uma senha';
                        }
                        if (value.length < 8) {
                          return 'A senha deve ter pelo menos 8 caracteres';
                        }
                        if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$').hasMatch(value)) {
                          return 'A senha deve conter letras e números';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Trigger rebuild for password strength indicator
                        setState(() {});
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Password strength indicator
                    _buildPasswordStrengthIndicator(),
                    
                    const SizedBox(height: 20),
                    
                    // Confirm password field
                    _ModernTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirmar senha',
                      icon: Icons.lock_outline_rounded,
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    int strength = 0;
    String strengthText = 'Muito fraca';
    Color strengthColor = Colors.red;
    
    if (password.isNotEmpty) {
      if (password.length >= 8) strength++;
      if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
      if (RegExp(r'[a-z]').hasMatch(password)) strength++;
      if (RegExp(r'[0-9]').hasMatch(password)) strength++;
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
      
      switch (strength) {
        case 1:
          strengthText = 'Fraca';
          strengthColor = Colors.orange;
          break;
        case 2:
          strengthText = 'Regular';
          strengthColor = Colors.yellow;
          break;
        case 3:
          strengthText = 'Boa';
          strengthColor = Colors.lightGreen;
          break;
        case 4:
        case 5:
          strengthText = 'Forte';
          strengthColor = AppColors.primaryGreen;
          break;
      }
    }
    
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: password.isEmpty ? 0.0 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: strength / 5,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                strengthText,
                style: TextStyle(
                  fontSize: 12,
                  color: strengthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddressStep() {
    return AnimatedBuilder(
      animation: _stepControllers[2],
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_stepControllers[2].value * 0.1),
          child: Opacity(
            opacity: _stepControllers[2].value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _addressFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    
                    // CEP field with search
                    _ModernTextField(
                      controller: _cepController,
                      label: 'CEP',
                      icon: Icons.location_on_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_cepMask],
                      suffixIcon: _isSearchingCep
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.search,
                                color: AppColors.primaryGreen,
                              ),
                              onPressed: _searchCep,
                            ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o CEP';
                        }
                        final cep = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (cep.length != 8) {
                          return 'CEP inválido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.replaceAll(RegExp(r'[^0-9]'), '').length == 8) {
                          _searchCep();
                        }
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Street field
                    _ModernTextField(
                      controller: _streetController,
                      label: 'Rua',
                      icon: Icons.home_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a rua';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Number and complement row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _ModernTextField(
                            controller: _numberController,
                            label: 'Número',
                            icon: Icons.numbers,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: _ModernTextField(
                            controller: _complementController,
                            label: 'Complemento',
                            icon: Icons.home_work_outlined,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Neighborhood field
                    _ModernTextField(
                      controller: _neighborhoodController,
                      label: 'Bairro',
                      icon: Icons.location_city_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o bairro';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // City field
                    _ModernTextField(
                      controller: _cityController,
                      label: 'Cidade',
                      icon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a cidade';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // State field
                    _ModernTextField(
                      controller: _stateController,
                      label: 'Estado',
                      icon: Icons.map_outlined,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2),
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o estado';
                        }
                        if (value.length != 2) {
                          return 'Use a sigla do estado (ex: SP)';
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
      },
    );
  }
  
  Widget _buildDocumentsStep() {
    return AnimatedBuilder(
      animation: _stepControllers[3],
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_stepControllers[3].value * 0.1),
          child: Opacity(
            opacity: _stepControllers[3].value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _documentsFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Title
                    const Text(
                      'Comprovante de Residência',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Anexe um comprovante de residência recente (últimos 3 meses)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Upload area
                    GestureDetector(
                      onTap: _pickDocument,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 200,
                        decoration: BoxDecoration(
                          color: _addressProofFile != null
                              ? AppColors.primaryGreen.withOpacity(0.1)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _addressProofFile != null
                                ? AppColors.primaryGreen
                                : Colors.white.withOpacity(0.2),
                            width: 2,
                            style: _addressProofFile != null
                                ? BorderStyle.solid
                                : BorderStyle.none,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                _addressProofFile != null
                                    ? Icons.check_circle
                                    : Icons.cloud_upload_outlined,
                                key: ValueKey(_addressProofFile != null),
                                color: _addressProofFile != null
                                    ? AppColors.primaryGreen
                                    : Colors.white.withOpacity(0.5),
                                size: 64,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _addressProofFile != null
                                  ? 'Arquivo anexado com sucesso!'
                                  : 'Clique para anexar arquivo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _addressProofFile != null
                                    ? AppColors.primaryGreen
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_addressProofFile != null && _addressProofFileName != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  _addressProofFileName!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            else
                              Text(
                                'PDF, JPG, JPEG ou PNG',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primaryGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Aceitamos: Conta de luz, água, telefone ou internet',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (_addressProofFile != null) ...[
                      const SizedBox(height: 16),
                      // Remove file button
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _addressProofFile = null;
                            _addressProofFileName = null;
                          });
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Remover arquivo',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: _ModernButton(
                onPressed: _previousStep,
                text: 'Voltar',
                isOutlined: true,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _ModernButton(
              onPressed: _isLoading ? null : _nextStep,
              text: _currentStep == 4 ? 'Finalizar Cadastro' : 'Continuar',
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Text Field Widget
class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final TextCapitalization textCapitalization;
  final int maxLines;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.suffixIcon,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.6),
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryGreen.withOpacity(0.7),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primaryGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}

// Modern Button Widget
class _ModernButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isOutlined;
  final bool isLoading;

  const _ModernButton({
    required this.onPressed,
    required this.text,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: !isOutlined
                ? LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.mediumGreen,
                    ],
                  )
                : null,
            color: isOutlined ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(16),
            border: isOutlined
                ? Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  )
                : null,
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}