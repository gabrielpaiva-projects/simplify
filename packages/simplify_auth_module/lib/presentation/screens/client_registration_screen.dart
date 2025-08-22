import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/cep_service.dart';

class ClientRegistrationScreen extends StatefulWidget {
  const ClientRegistrationScreen({super.key});

  @override
  State<ClientRegistrationScreen> createState() => _ClientRegistrationScreenState();
}

class _ClientRegistrationScreenState extends State<ClientRegistrationScreen> 
    with TickerProviderStateMixin {
  // Controllers
  final PageController _pageController = PageController();
  
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
  
  // Focus Nodes
  final _cpfFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _cepFocusNode = FocusNode();
  final _streetFocusNode = FocusNode();
  final _numberFocusNode = FocusNode();
  final _complementFocusNode = FocusNode();
  final _neighborhoodFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();
  final _stateFocusNode = FocusNode();
  
  // Form Keys
  final _personalDataFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  
  // Masks
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
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
  
  // Animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Configuração das animações
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.33,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar animações
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    
    // Listener para buscar CEP automaticamente
    _cepController.addListener(_onCepChanged);
    
    // Listeners para focus nodes
    _setupFocusListeners();
  }
  
  void _setupFocusListeners() {
    final focusNodes = [
      _cpfFocusNode, _nameFocusNode, _emailFocusNode,
      _passwordFocusNode, _confirmPasswordFocusNode,
      _cepFocusNode, _streetFocusNode, _numberFocusNode,
      _complementFocusNode, _neighborhoodFocusNode,
      _cityFocusNode, _stateFocusNode,
    ];
    
    for (var node in focusNodes) {
      node.addListener(() => setState(() {}));
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    
    // Dispose controllers
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
    
    // Dispose focus nodes
    _cpfFocusNode.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _cepFocusNode.dispose();
    _streetFocusNode.dispose();
    _numberFocusNode.dispose();
    _complementFocusNode.dispose();
    _neighborhoodFocusNode.dispose();
    _cityFocusNode.dispose();
    _stateFocusNode.dispose();
    
    super.dispose();
  }
  
  void _onCepChanged() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length == 8 && !_isSearchingCep) {
      setState(() => _isSearchingCep = true);
      
      final address = await CepService.fetchAddressByCep(cep);
      
      if (mounted) {
        setState(() => _isSearchingCep = false);
        
        if (address != null && address.isValid) {
          _streetController.text = address.logradouro;
          _neighborhoodController.text = address.bairro;
          _cityController.text = address.localidade;
          _stateController.text = address.uf;
          
          // Foca no campo número após preencher o endereço
          FocusScope.of(context).requestFocus(_numberFocusNode);
        }
      }
    }
  }
  
  void _nextStep() {
    bool isValid = false;
    
    switch (_currentStep) {
      case 0:
        isValid = _personalDataFormKey.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _passwordFormKey.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _addressFormKey.currentState?.validate() ?? false;
        if (isValid) {
          _submitRegistration();
          return;
        }
        break;
    }
    
    if (isValid && _currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      
      // Reset animations for new page
      _fadeController.reset();
      _slideController.reset();
      _fadeController.forward();
      _slideController.forward();
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      
      // Reset animations for new page
      _fadeController.reset();
      _slideController.reset();
      _fadeController.forward();
      _slideController.forward();
    }
  }
  
  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);
    
    // Simula envio para API
    await Future.delayed(const Duration(seconds: 2));
    
    final client = ClientModel(
      cpf: _cpfController.text,
      fullName: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      cep: _cepController.text,
      street: _streetController.text,
      number: _numberController.text,
      complement: _complementController.text,
      neighborhood: _neighborhoodController.text,
      city: _cityController.text,
      state: _stateController.text,
    );
    
    print('Cliente registrado: ${client.toJson()}');
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      // Mostra sucesso com animação
      _showSuccessDialog();
    }
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
            color: AppColors.deepBlack,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.3),
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
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primaryGreen,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Cadastro Realizado!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sua conta foi criada com sucesso.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Fazer Login',
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
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = true; // Always dark for registration
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.deepBlack,
              AppColors.charcoalGrey.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header with Back Button
              _buildModernHeader(),
              
              // Progress Indicator
              _buildModernProgressIndicator(),
              
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
                        _buildPersonalDataStep(),
                        _buildPasswordStep(),
                        _buildAddressStep(),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Modern Navigation Buttons
              _buildModernNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.charcoalGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.lightGrey.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                if (_currentStep > 0) {
                  _previousStep();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          const SizedBox(width: 20),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Cadastro ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: 'Cliente',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStepTitle(),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Informações pessoais';
      case 1:
        return 'Crie sua senha de acesso';
      case 2:
        return 'Endereço completo';
      default:
        return '';
    }
  }
  
  Widget _buildModernProgressIndicator() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...[
            _buildStepDot(i),
            if (i < 2) _buildStepConnector(i),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStepDot(int step) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    final isDarkMode = true;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 48 : 40,
      height: isActive ? 48 : 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive || isCompleted
            ? LinearGradient(
                colors: [
                  AppColors.primaryGreen,
                  AppColors.mediumGreen,
                ],
              )
            : null,
        color: !isActive && !isCompleted
            ? AppColors.charcoalGrey.withOpacity(0.5)
            : null,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 20,
              )
            : Text(
                '${step + 1}',
                style: TextStyle(
                  color: isActive || isCompleted
                      ? Colors.white
                      : AppColors.secondaryText.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  fontSize: isActive ? 18 : 16,
                ),
              ),
      ),
    );
  }
  
  Widget _buildStepConnector(int step) {
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.mediumGreen,
                  ],
                )
              : null,
          color: !isCompleted
              ? AppColors.charcoalGrey.withOpacity(0.3)
              : null,
        ),
      ),
    );
  }
  
  Widget _buildPersonalDataStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _personalDataFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // CPF Field
            _buildModernInputField(
              controller: _cpfController,
              focusNode: _cpfFocusNode,
              label: 'CPF',
              hint: '000.000.000-00',
              icon: Icons.badge_outlined,
              inputFormatters: [_cpfMask],
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu CPF';
                }
                if (value.length < 14) {
                  return 'CPF inválido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Nome Field
            _buildModernInputField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              label: 'Nome Completo',
              hint: 'João da Silva',
              icon: Icons.person_outline_rounded,
              textCapitalization: TextCapitalization.words,
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
            
            // Email Field
            _buildModernInputField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              label: 'E-mail',
              hint: 'seu@email.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu e-mail';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'E-mail inválido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPasswordStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // Password Field
            _buildModernInputField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              label: 'Senha',
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
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
            
            // Confirm Password Field
            _buildModernInputField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              label: 'Confirmar Senha',
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
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
            
            // Password Tips
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.1),
                    AppColors.mediumGreen.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dicas para uma senha forte',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordTip('Mínimo de 6 caracteres', true),
                  _buildPasswordTip('Use letras maiúsculas e minúsculas', false),
                  _buildPasswordTip('Inclua números', false),
                  _buildPasswordTip('Adicione caracteres especiais', false),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPasswordTip(String tip, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRequired 
                  ? AppColors.primaryGreen.withOpacity(0.2)
                  : Colors.transparent,
              border: Border.all(
                color: isRequired 
                    ? AppColors.primaryGreen
                    : AppColors.secondaryText.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: isRequired
                ? Icon(
                    Icons.check,
                    size: 12,
                    color: AppColors.primaryGreen,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            tip,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddressStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _addressFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // CEP Field with auto-complete
            _buildModernInputField(
              controller: _cepController,
              focusNode: _cepFocusNode,
              label: 'CEP',
              hint: '00000-000',
              icon: Icons.location_on_outlined,
              inputFormatters: [_cepMask],
              keyboardType: TextInputType.number,
              suffixWidget: _isSearchingCep
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen,
                        ),
                      ),
                    )
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o CEP';
                }
                if (value.length < 9) {
                  return 'CEP inválido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Street Field
            _buildModernInputField(
              controller: _streetController,
              focusNode: _streetFocusNode,
              label: 'Rua',
              hint: 'Nome da rua',
              icon: Icons.home_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a rua';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Number and Complement Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildModernInputField(
                    controller: _numberController,
                    focusNode: _numberFocusNode,
                    label: 'Número',
                    hint: '123',
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
                  child: _buildModernInputField(
                    controller: _complementController,
                    focusNode: _complementFocusNode,
                    label: 'Complemento',
                    hint: 'Apto, Bloco (opcional)',
                    icon: Icons.add_home_outlined,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Neighborhood Field
            _buildModernInputField(
              controller: _neighborhoodController,
              focusNode: _neighborhoodFocusNode,
              label: 'Bairro',
              hint: 'Nome do bairro',
              icon: Icons.location_city_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o bairro';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // City and State Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildModernInputField(
                    controller: _cityController,
                    focusNode: _cityFocusNode,
                    label: 'Cidade',
                    hint: 'Nome da cidade',
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
                  child: _buildModernInputField(
                    controller: _stateController,
                    focusNode: _stateFocusNode,
                    label: 'UF',
                    hint: 'SP',
                    icon: Icons.map_outlined,
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
            
            const SizedBox(height: 40),
          ],
        ),
      ),
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
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffixWidget,
  }) {
    final bool isFocused = focusNode.hasFocus;
    final bool hasText = controller.text.isNotEmpty;
    final isDarkMode = true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated Label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: isFocused || hasText ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: isFocused
                ? AppColors.primaryGreen
                : AppColors.secondaryText,
            letterSpacing: 0.5,
          ),
          child: Text(label),
        ),
        
        const SizedBox(height: 8),
        
        // Input Container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.charcoalGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused
                  ? AppColors.primaryGreen
                  : AppColors.lightGrey.withOpacity(0.1),
              width: isFocused ? 2 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isPassword && !_isPasswordVisible,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.secondaryText.withOpacity(0.3),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: isFocused
                    ? AppColors.primaryGreen
                    : AppColors.secondaryText.withOpacity(0.5),
                size: 22,
              ),
              suffixIcon: suffixWidget ?? (isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.secondaryText.withOpacity(0.5),
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : null),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
  
  Widget _buildModernNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.charcoalGrey.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: AppColors.lightGrey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: _buildSecondaryButton(
                onPressed: _previousStep,
                label: 'Voltar',
                icon: Icons.arrow_back_ios_new,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: _buildPrimaryButton(
              onPressed: _isLoading ? null : _nextStep,
              label: _currentStep == 2 ? 'Finalizar' : 'Próximo',
              icon: _currentStep == 2 ? Icons.check : Icons.arrow_forward_ios,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    bool isLoading = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: onPressed != null
              ? [AppColors.primaryGreen, AppColors.mediumGreen]
              : [
                  AppColors.charcoalGrey.withOpacity(0.5),
                  AppColors.charcoalGrey.withOpacity(0.5),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.charcoalGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: AppColors.secondaryText,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                    letterSpacing: 0.5,
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