import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../data/services/cep_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/animated_step_indicator.dart';
import '../widgets/gradient_button.dart';
import 'registration_success_screen.dart';

class UnifiedRegistrationScreen extends StatefulWidget {
  final String userType;
  
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
  
  // Personal Data Controllers
  final _cpfController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rgController = TextEditingController(); // Only for professionals
  
  // Password Controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Address Controllers
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
  final _phoneFocusNode = FocusNode();
  final _rgFocusNode = FocusNode();
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
  
  // Animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Password strength
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;
  
  bool get isProfessional => widget.userType == 'professional';
  
  List<String> get stepTitles => [
    'Dados Pessoais',
    'Criar Senha',
    'Endereço',
    if (isProfessional) 'Documentos',
  ];
  
  List<IconData> get stepIcons => [
    Icons.person_rounded,
    Icons.lock_rounded,
    Icons.location_on_rounded,
    if (isProfessional) Icons.description_rounded,
  ];
  
  int get totalSteps => isProfessional ? 4 : 3;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
    
    // Add password strength listener
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    // Controllers
    _cpfController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rgController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    
    // Focus Nodes
    _cpfFocusNode.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _rgFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _cepFocusNode.dispose();
    _streetFocusNode.dispose();
    _numberFocusNode.dispose();
    _complementFocusNode.dispose();
    _neighborhoodFocusNode.dispose();
    _cityFocusNode.dispose();
    _stateFocusNode.dispose();
    
    // Animations
    _fadeController.dispose();
    _slideController.dispose();
    
    // Page Controller
    _pageController.dispose();
    
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    double strength = 0;
    
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0;
        _passwordStrengthText = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }
    
    // Check length
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;
    
    // Check for uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    
    // Check for numbers
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.125;
    
    // Check for special characters
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.125;
    
    setState(() {
      _passwordStrength = strength.clamp(0.0, 1.0);
      
      if (_passwordStrength <= 0.25) {
        _passwordStrengthText = 'Muito fraca';
        _passwordStrengthColor = Colors.red;
      } else if (_passwordStrength <= 0.5) {
        _passwordStrengthText = 'Fraca';
        _passwordStrengthColor = Colors.orange;
      } else if (_passwordStrength <= 0.75) {
        _passwordStrengthText = 'Boa';
        _passwordStrengthColor = Colors.amber;
      } else {
        _passwordStrengthText = 'Excelente';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  Future<void> _searchCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cep.length != 8) {
      _showSnackBar('CEP inválido', isError: true);
      return;
    }
    
    setState(() => _isSearchingCep = true);
    
    try {
      final address = await CepService.searchCep(cep);
      if (address != null) {
        setState(() {
          _streetController.text = address.street ?? '';
          _neighborhoodController.text = address.neighborhood ?? '';
          _cityController.text = address.city ?? '';
          _stateController.text = address.state ?? '';
        });
        
        // Focus on number field
        _numberFocusNode.requestFocus();
        
        _showSnackBar('Endereço encontrado!', isError: false);
      } else {
        _showSnackBar('CEP não encontrado', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erro ao buscar CEP', isError: true);
    } finally {
      setState(() => _isSearchingCep = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _nextStep() async {
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
        break;
      case 3:
        isValid = _acceptTerms;
        if (!isValid) {
          _showSnackBar('Você precisa aceitar os termos', isError: true);
        }
        break;
    }
    
    if (isValid) {
      HapticFeedback.lightImpact();
      
      if (_currentStep < totalSteps - 1) {
        setState(() => _currentStep++);
        
        await _fadeController.reverse();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
        _fadeController.forward();
      } else {
        _completeRegistration();
      }
    }
  }

  void _previousStep() async {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      
      setState(() => _currentStep--);
      
      await _fadeController.reverse();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _fadeController.forward();
    }
  }

  Future<void> _completeRegistration() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RegistrationSuccessScreen(
              userName: _nameController.text,
              userType: widget.userType,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.05),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _currentStep > 0 ? _previousStep : () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isProfessional ? 'Cadastro Profissional' : 'Cadastro Cliente',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.headlineSmall?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              // Step Indicator
              AnimatedStepIndicator(
                totalSteps: totalSteps,
                currentStep: _currentStep,
                stepTitles: stepTitles,
                stepIcons: stepIcons,
              ),
              
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
                        if (isProfessional) _buildDocumentsStep(),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: GradientButton(
                  text: _currentStep < totalSteps - 1 ? 'Continuar' : 'Finalizar Cadastro',
                  onPressed: _nextStep,
                  isLoading: _isLoading,
                  icon: _currentStep < totalSteps - 1 
                      ? Icons.arrow_forward_rounded 
                      : Icons.check_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalDataStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _personalDataFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Pessoais',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Preencha seus dados pessoais para criar sua conta',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            
            CustomTextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              label: 'Nome Completo',
              hint: 'Digite seu nome completo',
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu nome';
                }
                if (value.trim().split(' ').length < 2) {
                  return 'Por favor, insira seu nome completo';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            CustomTextField(
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
                final cpf = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (cpf.length != 11) {
                  return 'CPF inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            if (isProfessional) ...[
              CustomTextField(
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
            
            CustomTextField(
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
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'E-mail inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            CustomTextField(
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
    );
  }

  Widget _buildPasswordStep() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crie sua Senha',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha uma senha forte para proteger sua conta',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            
            CustomTextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              label: 'Senha',
              hint: 'Mínimo 8 caracteres',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.next,
              suffix: IconButton(
                icon: Icon(
                  _isPasswordVisible 
                      ? Icons.visibility_off_outlined 
                      : Icons.visibility_outlined,
                  color: theme.iconTheme.color?.withOpacity(0.5),
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira uma senha';
                }
                if (value.length < 8) {
                  return 'A senha deve ter pelo menos 8 caracteres';
                }
                return null;
              },
            ),
            
            // Password Strength Indicator
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Força da senha:',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      Text(
                        _passwordStrengthText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _passwordStrengthColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _passwordStrength,
                      backgroundColor: theme.dividerColor.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 20),
            
            CustomTextField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              label: 'Confirmar Senha',
              hint: 'Digite a senha novamente',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !_isConfirmPasswordVisible,
              textInputAction: TextInputAction.done,
              suffix: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible 
                      ? Icons.visibility_off_outlined 
                      : Icons.visibility_outlined,
                  color: theme.iconTheme.color?.withOpacity(0.5),
                ),
                onPressed: () {
                  setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
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
            
            const SizedBox(height: 32),
            
            // Password Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 20,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dicas para uma senha forte:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordTip('Use pelo menos 8 caracteres'),
                  _buildPasswordTip('Inclua letras maiúsculas e minúsculas'),
                  _buildPasswordTip('Adicione números e símbolos especiais'),
                  _buildPasswordTip('Evite informações pessoais óbvias'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Theme.of(context).primaryColor.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _addressFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Endereço',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Informe seu endereço completo',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            
            CustomTextField(
              controller: _cepController,
              focusNode: _cepFocusNode,
              label: 'CEP',
              hint: '00000-000',
              prefixIcon: Icons.location_on_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [_cepMask],
              textInputAction: TextInputAction.search,
              suffix: _isSearchingCep
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.search_rounded,
                        color: theme.primaryColor,
                      ),
                      onPressed: _searchCep,
                    ),
              onFieldSubmitted: (_) => _searchCep(),
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
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    controller: _streetController,
                    focusNode: _streetFocusNode,
                    label: 'Rua',
                    hint: 'Nome da rua',
                    prefixIcon: Icons.route_outlined,
                    textInputAction: TextInputAction.next,
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
                  child: CustomTextField(
                    controller: _numberController,
                    focusNode: _numberFocusNode,
                    label: 'Número',
                    hint: '123',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
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
            
            CustomTextField(
              controller: _complementController,
              focusNode: _complementFocusNode,
              label: 'Complemento (opcional)',
              hint: 'Apto, bloco, etc.',
              prefixIcon: Icons.home_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),
            
            CustomTextField(
              controller: _neighborhoodController,
              focusNode: _neighborhoodFocusNode,
              label: 'Bairro',
              hint: 'Nome do bairro',
              prefixIcon: Icons.location_city_outlined,
              textInputAction: TextInputAction.next,
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
                  child: CustomTextField(
                    controller: _cityController,
                    focusNode: _cityFocusNode,
                    label: 'Cidade',
                    hint: 'Nome da cidade',
                    prefixIcon: Icons.location_city_outlined,
                    textInputAction: TextInputAction.next,
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
                  child: CustomTextField(
                    controller: _stateController,
                    focusNode: _stateFocusNode,
                    label: 'Estado',
                    hint: 'UF',
                    textInputAction: TextInputAction.done,
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
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsStep() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documentação',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Envie seus documentos para validação',
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          
          // Document Upload Areas
          _buildDocumentUploadCard(
            title: 'Comprovante de Residência',
            description: 'Conta de luz, água ou telefone (últimos 3 meses)',
            icon: Icons.home_work_outlined,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          
          _buildDocumentUploadCard(
            title: 'Certificados e Diplomas',
            description: 'Documentos que comprovem sua qualificação profissional',
            icon: Icons.school_outlined,
            isRequired: false,
          ),
          const SizedBox(height: 32),
          
          // Terms and Conditions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: theme.iconTheme.color?.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Termos e Condições',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() => _acceptTerms = value ?? false);
                        },
                        activeColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _acceptTerms = !_acceptTerms);
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                            children: [
                              const TextSpan(text: 'Li e aceito os '),
                              TextSpan(
                                text: 'Termos de Uso',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' e a '),
                              TextSpan(
                                text: 'Política de Privacidade',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isRequired,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Implement file upload
            _showSnackBar('Funcionalidade em desenvolvimento', isError: false);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: theme.primaryColor,
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          if (isRequired) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Obrigatório',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.cloud_upload_outlined,
                  color: theme.iconTheme.color?.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}