import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../data/services/cep_service.dart';
import 'registration_success_screen.dart';

class NewProfessionalRegistrationScreen extends StatefulWidget {
  const NewProfessionalRegistrationScreen({super.key});

  @override
  State<NewProfessionalRegistrationScreen> createState() => _NewProfessionalRegistrationScreenState();
}

class _NewProfessionalRegistrationScreenState extends State<NewProfessionalRegistrationScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  
  // Step 1: Basic Info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Step 2: Security
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Step 3: Professional Data
  final _cpfCnpjController = TextEditingController();
  final _phoneController = TextEditingController();
  final _professionController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Step 4: Services
  final List<String> _selectedServices = [];
  final _customServiceController = TextEditingController();
  
  // Step 5: Address
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  
  // Form Keys
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _securityFormKey = GlobalKey<FormState>();
  final _professionalDataFormKey = GlobalKey<FormState>();
  final _servicesFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  
  // Masks
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  final _cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
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
  bool _isCpf = true;
  double _serviceRadius = 10.0;
  
  // Animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<String> _stepTitles = [
    'Informações Básicas',
    'Segurança',
    'Dados Profissionais',
    'Serviços Oferecidos',
    'Localização',
  ];
  
  final List<String> _stepSubtitles = [
    'Como podemos te chamar?',
    'Proteja sua conta',
    'Conte sobre você',
    'O que você faz?',
    'Onde você atende?',
  ];
  
  final List<IconData> _stepIcons = [
    Icons.person_outline_rounded,
    Icons.lock_outline_rounded,
    Icons.badge_outlined,
    Icons.work_outline_rounded,
    Icons.location_on_outlined,
  ];
  
  final List<Map<String, dynamic>> _availableServices = [
    {'name': 'Eletricista', 'icon': Icons.electrical_services_outlined},
    {'name': 'Encanador', 'icon': Icons.plumbing_outlined},
    {'name': 'Pintor', 'icon': Icons.format_paint_outlined},
    {'name': 'Pedreiro', 'icon': Icons.construction_outlined},
    {'name': 'Marceneiro', 'icon': Icons.carpenter_outlined},
    {'name': 'Jardineiro', 'icon': Icons.grass_outlined},
    {'name': 'Diarista', 'icon': Icons.cleaning_services_outlined},
    {'name': 'Mecânico', 'icon': Icons.build_outlined},
    {'name': 'Técnico em Informática', 'icon': Icons.computer_outlined},
    {'name': 'Designer', 'icon': Icons.design_services_outlined},
    {'name': 'Fotógrafo', 'icon': Icons.camera_alt_outlined},
    {'name': 'Personal Trainer', 'icon': Icons.fitness_center_outlined},
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
    
    _cepController.addListener(_onCepChanged);
  }
  
  void _onCepChanged() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length == 8 && !_isSearchingCep) {
      setState(() => _isSearchingCep = true);
      
      try {
        final address = await CepService.fetchAddress(cep);
        if (address != null && mounted) {
          setState(() {
            _streetController.text = address.street;
            _neighborhoodController.text = address.neighborhood;
            _cityController.text = address.city;
            _stateController.text = address.state;
          });
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
          setState(() => _isSearchingCep = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cpfCnpjController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    _descriptionController.dispose();
    _customServiceController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  void _nextStep() {
    bool isValid = false;
    
    switch (_currentStep) {
      case 0:
        isValid = _basicInfoFormKey.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _securityFormKey.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _professionalDataFormKey.currentState?.validate() ?? false;
        break;
      case 3:
        isValid = _selectedServices.isNotEmpty;
        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecione pelo menos um serviço'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        break;
      case 4:
        isValid = (_addressFormKey.currentState?.validate() ?? false) && _acceptTerms;
        if (!_acceptTerms && isValid == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Você precisa aceitar os termos para continuar'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        break;
    }
    
    if (isValid) {
      if (_currentStep < 4) {
        HapticFeedback.lightImpact();
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _slideController.reset();
        _slideController.forward();
      } else {
        _submitRegistration();
      }
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _slideController.reset();
      _slideController.forward();
    }
  }
  
  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const RegistrationSuccessScreen(isProfessional: true),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF256525).withOpacity(0.1),
              AppColors.deepBlack,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Progress Indicator
              _buildProgressIndicator(),
              
              // Form Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildBasicInfoStep(),
                        _buildSecurityStep(),
                        _buildProfessionalDataStep(),
                        _buildServicesStep(),
                        _buildAddressStep(),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom Navigation
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: _currentStep > 0 ? _previousStep : () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.charcoalGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.lightGrey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF256525),
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _stepTitles[_currentStep],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _stepSubtitles[_currentStep],
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: isActive || isCompleted
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF256525),
                                AppColors.mediumGreen,
                              ],
                            )
                          : null,
                      color: !isActive && !isCompleted
                          ? AppColors.charcoalGrey.withOpacity(0.5)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive || isCompleted
                            ? Colors.transparent
                            : AppColors.lightGrey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            )
                          : Icon(
                              _stepIcons[index],
                              color: isActive
                                  ? Colors.white
                                  : AppColors.secondaryText.withOpacity(0.5),
                              size: 20,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive || isCompleted
                          ? const Color(0xFF256525)
                          : AppColors.secondaryText.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _basicInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: 'Nome Completo',
              icon: Icons.person_outline_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu nome';
                }
                if (value.length < 3) {
                  return 'Nome deve ter pelo menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _emailController,
              label: 'E-mail',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu e-mail';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Por favor, insira um e-mail válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSecurityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _securityFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              label: 'Senha',
              icon: Icons.lock_outline_rounded,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.secondaryText.withOpacity(0.5),
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira uma senha';
                }
                if (value.length < 6) {
                  return 'A senha deve ter pelo menos 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirmar Senha',
              icon: Icons.lock_outline_rounded,
              obscureText: !_isConfirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.secondaryText.withOpacity(0.5),
                ),
                onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
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
            const SizedBox(height: 32),
            _buildPasswordStrengthIndicator(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfessionalDataStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _professionalDataFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Toggle CPF/CNPJ
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _isCpf = true;
                      _cpfCnpjController.clear();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: _isCpf
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF256525),
                                  AppColors.mediumGreen,
                                ],
                              )
                            : null,
                        color: !_isCpf ? AppColors.charcoalGrey.withOpacity(0.3) : null,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isCpf
                              ? Colors.transparent
                              : AppColors.lightGrey.withOpacity(0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Pessoa Física',
                          style: TextStyle(
                            color: _isCpf ? Colors.white : AppColors.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _isCpf = false;
                      _cpfCnpjController.clear();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: !_isCpf
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF256525),
                                  AppColors.mediumGreen,
                                ],
                              )
                            : null,
                        color: _isCpf ? AppColors.charcoalGrey.withOpacity(0.3) : null,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_isCpf
                              ? Colors.transparent
                              : AppColors.lightGrey.withOpacity(0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Pessoa Jurídica',
                          style: TextStyle(
                            color: !_isCpf ? Colors.white : AppColors.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _cpfCnpjController,
              label: _isCpf ? 'CPF' : 'CNPJ',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [_isCpf ? _cpfMask : _cnpjMask],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _isCpf ? 'Por favor, insira seu CPF' : 'Por favor, insira seu CNPJ';
                }
                final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (_isCpf && numbers.length != 11) {
                  return 'CPF inválido';
                }
                if (!_isCpf && numbers.length != 14) {
                  return 'CNPJ inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
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
                if (phone.length < 11) {
                  return 'Telefone inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _professionController,
              label: 'Profissão/Título',
              icon: Icons.work_outline_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira sua profissão';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 500,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Conte um pouco sobre você e seus serviços...',
                labelStyle: TextStyle(
                  color: AppColors.secondaryText.withOpacity(0.7),
                  fontSize: 14,
                ),
                hintStyle: TextStyle(
                  color: AppColors.secondaryText.withOpacity(0.3),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.charcoalGrey.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.lightGrey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF256525),
                    width: 2,
                  ),
                ),
                counterStyle: TextStyle(
                  color: AppColors.secondaryText.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildServicesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _servicesFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecione seus serviços',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha os serviços que você oferece',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableServices.map((service) {
                final isSelected = _selectedServices.contains(service['name']);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedServices.remove(service['name']);
                      } else {
                        _selectedServices.add(service['name']);
                      }
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF256525),
                                AppColors.mediumGreen,
                              ],
                            )
                          : null,
                      color: !isSelected ? AppColors.charcoalGrey.withOpacity(0.3) : null,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.lightGrey.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          service['icon'],
                          size: 18,
                          color: isSelected ? Colors.white : AppColors.secondaryText,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          service['name'],
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.white : AppColors.secondaryText,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _customServiceController,
              label: 'Outro serviço (opcional)',
              icon: Icons.add_circle_outline,
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.add,
                  color: Color(0xFF256525),
                ),
                onPressed: () {
                  if (_customServiceController.text.isNotEmpty) {
                    setState(() {
                      _selectedServices.add(_customServiceController.text);
                      _customServiceController.clear();
                    });
                    HapticFeedback.lightImpact();
                  }
                },
              ),
            ),
            if (_selectedServices.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Serviços selecionados:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedServices.map((service) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF256525).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF256525).withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          service,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF256525),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedServices.remove(service);
                            });
                            HapticFeedback.selectionClick();
                          },
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF256525),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _addressFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Radius Slider
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.charcoalGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.lightGrey.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.radar_outlined,
                        color: Color(0xFF256525),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Raio de atendimento',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_serviceRadius.toInt()} km',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF256525),
                    ),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFF256525),
                      inactiveTrackColor: AppColors.charcoalGrey,
                      thumbColor: const Color(0xFF256525),
                      overlayColor: const Color(0xFF256525).withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _serviceRadius,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      onChanged: (value) => setState(() => _serviceRadius = value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _cepController,
                    label: 'CEP',
                    icon: Icons.location_on_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_cepMask],
                    suffixIcon: _isSearchingCep
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF256525)),
                              ),
                            ),
                          )
                        : null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira o CEP';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _numberController,
                    label: 'Número',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Número';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _streetController,
              label: 'Rua',
              icon: Icons.home_outlined,
              enabled: !_isSearchingCep,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a rua';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _complementController,
              label: 'Complemento (opcional)',
              icon: Icons.apartment_outlined,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _neighborhoodController,
                    label: 'Bairro',
                    enabled: !_isSearchingCep,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira o bairro';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _stateController,
                    label: 'UF',
                    enabled: !_isSearchingCep,
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
            const SizedBox(height: 20),
            _buildTextField(
              controller: _cityController,
              label: 'Cidade',
              icon: Icons.location_city_outlined,
              enabled: !_isSearchingCep,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a cidade';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            _buildTermsCheckbox(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: enabled,
      validator: validator,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.secondaryText.withOpacity(0.7),
          fontSize: 14,
        ),
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: const Color(0xFF256525),
                size: 22,
              )
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.charcoalGrey.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.lightGrey.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF256525),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.lightGrey.withOpacity(0.05),
            width: 1,
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
    
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    
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
        strengthColor = AppColors.mediumGreen;
        break;
      case 5:
        strengthText = 'Muito forte';
        strengthColor = const Color(0xFF256525);
        break;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Força da senha: $strengthText',
          style: TextStyle(
            fontSize: 12,
            color: strengthColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: index < strength
                      ? strengthColor
                      : AppColors.charcoalGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
  
  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _acceptTerms = !_acceptTerms),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: _acceptTerms
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF256525),
                        AppColors.mediumGreen,
                      ],
                    )
                  : null,
              color: !_acceptTerms ? AppColors.charcoalGrey.withOpacity(0.5) : null,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _acceptTerms
                    ? Colors.transparent
                    : AppColors.lightGrey.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: _acceptTerms
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Li e aceito os ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText.withOpacity(0.7),
                ),
                children: const [
                  TextSpan(
                    text: 'Termos de Uso',
                    style: TextStyle(
                      color: Color(0xFF256525),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ' e a '),
                  TextSpan(
                    text: 'Política de Privacidade',
                    style: TextStyle(
                      color: Color(0xFF256525),
                      decoration: TextDecoration.underline,
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
  
  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(
                    color: Color(0xFF256525),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Voltar',
                  style: TextStyle(
                    color: Color(0xFF256525),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF256525),
                    AppColors.mediumGreen,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF256525).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _isLoading ? null : _nextStep,
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _currentStep < 4 ? 'Continuar' : 'Finalizar Cadastro',
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
        ],
      ),
    );
  }
}