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
  
  // Personal Data
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  

  
  // Password
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Address
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  
  // Form Keys
  final _personalFormKey = GlobalKey<FormState>();
  final _professionalFormKey = GlobalKey<FormState>();
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
  
  // Files
  File? _profileImage;
  File? _rgFrontImage;
  File? _rgBackImage;
  File? _addressProofFile;
  List<File> _certificateFiles = [];
  
  // Selected categories
  final Set<String> _selectedCategories = {};
  
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
  
  // Categories
  final List<String> _availableCategories = [
    'Eletricista',
    'Encanador',
    'Pintor',
    'Pedreiro',
    'Marceneiro',
    'Jardineiro',
    'Mecânico',
    'Técnico em Informática',
    'Diarista',
    'Cozinheiro',
    'Personal Trainer',
    'Professor Particular',
    'Cuidador',
    'Motorista',
    'Segurança',
    'Outros',
  ];
  
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
      4, // 4 steps: Dados, Senha, Endereço, Comprovante
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
        isValid = _documentsFormKey.currentState?.validate() ?? false;
        break;
    }
    
    if (isValid) {
      if (_currentStep < 3) {
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
    
    // Show success and navigate
    if (mounted) {
      _showSuccessDialog();
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AnalysisDialog(
        onContinue: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        },
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
  
  Future<void> _pickImage(String type) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        switch (type) {
          case 'profile':
            _profileImage = File(image.path);
            break;
          case 'rg_front':
            _rgFrontImage = File(image.path);
            break;
          case 'rg_back':
            _rgBackImage = File(image.path);
            break;
        }
      });
    }
  }
  
  Future<void> _pickDocument(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    
    if (result != null) {
      setState(() {
        switch (type) {
          case 'address':
            _addressProofFile = File(result.files.single.path!);
            break;
          case 'certificate':
            if (_certificateFiles.length < 5) {
              _certificateFiles.add(File(result.files.single.path!));
            }
            break;
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient with animation
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
          
          // Animated background elements
          Positioned(
            top: -150,
            left: -150,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 3),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 0.3,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                                        gradient: RadialGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                    ),
                  ),
                );
              },
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
                          _buildProfessionalDataStep(),
                          _buildPasswordStep(),
                          _buildAddressStep(),
                          _buildDocumentsStep(),
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
              '${_currentStep + 1}/4',
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
              value: (_currentStep + _progressAnimation.value) / 4,
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
                    // Profile Image Picker
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGreen.withOpacity(0.2),
                                  AppColors.mediumGreen.withOpacity(0.1),
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.primaryGreen.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: _profileImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      _profileImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person_outline_rounded,
                                    size: 48,
                                    color: AppColors.primaryGreen.withOpacity(0.5),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _pickImage('profile'),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF2E7D32),
                                      Color(0xFF1B5E20),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Name field
                    _ModernTextField(
                      controller: _nameController,
                      label: 'Nome completo',
                      icon: Icons.person_outline_rounded,
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
                    
                    // CPF field
                    _ModernTextField(
                      controller: _cpfController,
                      label: 'CPF',
                      icon: Icons.badge_outlined,
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
                    
                    // RG field
                    _ModernTextField(
                      controller: _rgController,
                      label: 'RG',
                      icon: Icons.credit_card_outlined,
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
                    
                    const SizedBox(height: 20),
                    
                    // Phone field
                    _ModernTextField(
                      controller: _phoneController,
                      label: 'Telefone',
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildProfessionalDataStep() {
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
                key: _professionalFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Categories selection
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.category_outlined,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Categorias de Serviço',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableCategories.map((category) {
                              final isSelected = _selectedCategories.contains(category);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedCategories.remove(category);
                                    } else {
                                      _selectedCategories.add(category);
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF2E7D32),
                                              Color(0xFF1B5E20),
                                            ],
                                          )
                                        : null,
                                    color: !isSelected
                                        ? Colors.white.withOpacity(0.1)
                                        : null,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.7),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Profession field
                    _ModernTextField(
                      controller: _professionController,
                      label: 'Profissão Principal',
                      icon: Icons.work_outline_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua profissão';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Experience field
                    _ModernTextField(
                      controller: _experienceController,
                      label: 'Anos de Experiência',
                      icon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seus anos de experiência';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description field
                    _ModernTextField(
                      controller: _descriptionController,
                      label: 'Sobre você e seus serviços',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, descreva seus serviços';
                        }
                        if (value.length < 50) {
                          return 'Mínimo de 50 caracteres';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen.withOpacity(0.1),
                            AppColors.mediumGreen.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppColors.primaryGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Uma boa descrição ajuda a conseguir mais clientes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
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
      animation: _stepControllers[2],
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_stepControllers[2].value * 0.1),
          child: Opacity(
            opacity: _stepControllers[2].value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _passwordFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Security icon with animation
                    Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryGreen.withOpacity(0.2),
                                    AppColors.mediumGreen.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.security_rounded,
                                color: AppColors.primaryGreen,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Password strength indicator
                    _PasswordStrengthIndicator(
                      password: _passwordController.text,
                    ),
                    
                    const SizedBox(height: 24),
                    
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
                        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)')
                            .hasMatch(value)) {
                          return 'Use letras maiúsculas, minúsculas e números';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    
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
  
  Widget _buildAddressStep() {
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : IconButton(
                              icon: const Icon(
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
                    
                    // Number and complement
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
                            icon: Icons.add_home_outlined,
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
                    
                    // City and state
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _ModernTextField(
                            controller: _cityController,
                            label: 'Cidade',
                            icon: Icons.location_city,
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
                          flex: 1,
                          child: _ModernTextField(
                            controller: _stateController,
                            label: 'UF',
                            icon: Icons.map_outlined,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(2),
                              FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
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
      },
    );
  }
  
  Widget _buildDocumentsStep() {
    return AnimatedBuilder(
      animation: _stepControllers[4],
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_stepControllers[4].value * 0.1),
          child: Opacity(
            opacity: _stepControllers[4].value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _documentsFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Document upload cards
                    _DocumentUploadCard(
                      title: 'RG - Frente',
                      subtitle: 'Foto da frente do documento',
                      icon: Icons.badge_outlined,
                      file: _rgFrontImage,
                      onTap: () => _pickImage('rg_front'),
                      isRequired: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _DocumentUploadCard(
                      title: 'RG - Verso',
                      subtitle: 'Foto do verso do documento',
                      icon: Icons.badge_outlined,
                      file: _rgBackImage,
                      onTap: () => _pickImage('rg_back'),
                      isRequired: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _DocumentUploadCard(
                      title: 'Comprovante de Endereço',
                      subtitle: 'Conta de luz, água ou telefone',
                      icon: Icons.home_work_outlined,
                      file: _addressProofFile,
                      onTap: () => _pickDocument('address'),
                      isRequired: true,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Certificates section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.school_outlined,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Certificados (Opcional)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Adicione certificados para aumentar sua credibilidade',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Certificate list
                          if (_certificateFiles.isNotEmpty)
                            ...List.generate(
                              _certificateFiles.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.insert_drive_file_outlined,
                                        color: AppColors.primaryGreen,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Certificado ${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _certificateFiles.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          
                          // Add certificate button
                          if (_certificateFiles.length < 5)
                            GestureDetector(
                              onTap: () => _pickDocument('certificate'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primaryGreen.withOpacity(0.3),
                                    style: BorderStyle.solid,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.primaryGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Adicionar Certificado',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
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
  
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: _ModernButton(
                onPressed: _previousStep,
                text: 'Voltar',
                isOutlined: true,
                isProfessional: true,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _ModernButton(
              onPressed: _isLoading ? null : _nextStep,
              text: _currentStep == 4 ? 'Finalizar Cadastro' : 'Continuar',
              isLoading: _isLoading,
              isProfessional: true,
            ),
          ),
        ],
      ),
    );
  }
}

// Document Upload Card Widget
class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final File? file;
  final VoidCallback onTap;
  final bool isRequired;

  const _DocumentUploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.file,
    required this.onTap,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: file != null
              ? AppColors.primaryGreen.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: file != null
                ? AppColors.primaryGreen.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: file != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: file != null
                    ? AppColors.primaryGreen.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                file != null ? Icons.check_circle : icon,
                color: file != null
                    ? AppColors.primaryGreen
                    : Colors.white.withOpacity(0.5),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (isRequired)
                        const Text(
                          ' *',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file != null ? 'Documento anexado' : subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: file != null
                          ? AppColors.primaryGreen
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              file != null ? Icons.edit_outlined : Icons.upload_outlined,
              color: Colors.white.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
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
  final bool isProfessional;

  const _ModernButton({
    required this.onPressed,
    required this.text,
    this.isOutlined = false,
    this.isLoading = false,
    this.isProfessional = false,
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

// Password Strength Indicator Widget
class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const _PasswordStrengthIndicator({
    required this.password,
  });

  int _calculateStrength() {
    if (password.isEmpty) return 0;
    
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    
    return (strength * 100 / 6).round();
  }

  String _getStrengthText() {
    final strength = _calculateStrength();
    if (strength < 30) return 'Fraca';
    if (strength < 50) return 'Regular';
    if (strength < 70) return 'Boa';
    if (strength < 90) return 'Forte';
    return 'Muito forte';
  }

  Color _getStrengthColor() {
    final strength = _calculateStrength();
    if (strength < 30) return Colors.red;
    if (strength < 50) return Colors.orange;
    if (strength < 70) return Colors.yellow;
    if (strength < 90) return AppColors.primaryGreen;
    return AppColors.primaryGreen;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength();
    final color = _getStrengthColor();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Força da senha',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            if (password.isNotEmpty)
              Text(
                _getStrengthText(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strength / 100,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// Success Dialog Widget
class _SuccessDialog extends StatefulWidget {
  final VoidCallback onContinue;

  const _SuccessDialog({
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
      curve: Curves.easeOutBack,
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.deepBlack,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success icon with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF2E7D32),
                                  Color(0xFF1B5E20),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Cadastro realizado!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Sua conta profissional foi criada.\nAgora você pode começar a oferecer seus serviços!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    _ModernButton(
                      onPressed: widget.onContinue,
                      text: 'Começar',
                      isProfessional: true,
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
}