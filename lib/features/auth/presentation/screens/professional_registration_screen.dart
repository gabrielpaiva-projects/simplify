import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/cep_service.dart';

class ProfessionalRegistrationScreen extends StatefulWidget {
  const ProfessionalRegistrationScreen({super.key});

  @override
  State<ProfessionalRegistrationScreen> createState() => _ProfessionalRegistrationScreenState();
}

class _ProfessionalRegistrationScreenState extends State<ProfessionalRegistrationScreen> 
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  
  final _cpfController = TextEditingController();
  final _nameController = TextEditingController();
  final _rgController = TextEditingController();
  final _emailController = TextEditingController();
  
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  
  final _cpfFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _rgFocusNode = FocusNode();
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
  
  final _personalDataFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  final _rgMask = MaskTextInputFormatter(
    mask: '##.###.###-#',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  final _cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSearchingCep = false;
  File? _addressProofFile;
  String? _addressProofFileName;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  final ImagePicker _imagePicker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    
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
    
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    
    _cepController.addListener(_onCepChanged);
    
    _setupFocusListeners();
  }
  
  void _setupFocusListeners() {
    final focusNodes = [
      _cpfFocusNode, _nameFocusNode, _rgFocusNode, _emailFocusNode,
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
    
    _cpfController.dispose();
    _nameController.dispose();
    _rgController.dispose();
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
    
    _cpfFocusNode.dispose();
    _nameFocusNode.dispose();
    _rgFocusNode.dispose();
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
          
          FocusScope.of(context).requestFocus(_numberFocusNode);
        }
      }
    }
  }
  
  Future<void> _pickAddressProof() async {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildFilePickerBottomSheet(),
    );
  }
  
  Widget _buildFilePickerBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.deepBlack,
            AppColors.charcoalGrey.withOpacity(0.95),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          
          const Text(
            'Escolha como enviar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione o método para anexar o comprovante',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          _FilePickerOption(
            icon: Icons.camera_alt_rounded,
            title: 'Tirar Foto',
            subtitle: 'Use a câmera do dispositivo',
            gradient: [AppColors.primaryGreen, AppColors.mediumGreen],
            onTap: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
          ),
          const SizedBox(height: 12),
          
          _FilePickerOption(
            icon: Icons.photo_library_rounded,
            title: 'Galeria',
            subtitle: 'Escolha uma imagem salva',
            gradient: [const Color(0xFF256525), AppColors.mediumGreen],
            onTap: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
          ),
          const SizedBox(height: 12),
          
          _FilePickerOption(
            icon: Icons.picture_as_pdf_rounded,
            title: 'Arquivo PDF',
            subtitle: 'Selecione um documento PDF',
            gradient: [Colors.orange.shade700, Colors.orange.shade500],
            onTap: () {
              Navigator.pop(context);
              _pickPdfFile();
            },
          ),
          
          const SizedBox(height: 24),
          
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: AppColors.secondaryText.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
  
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _addressProofFile = File(image.path);
          _addressProofFileName = image.name;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao capturar imagem');
    }
  }
  
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _addressProofFile = File(image.path);
          _addressProofFileName = image.name;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao selecionar imagem');
    }
  }
  
  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      
      if (result != null && result.files.single.path != null) {
        setState(() {
          _addressProofFile = File(result.files.single.path!);
          _addressProofFileName = result.files.single.name;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao selecionar arquivo');
    }
  }
  
  void _removeAddressProof() {
    HapticFeedback.lightImpact();
    setState(() {
      _addressProofFile = null;
      _addressProofFileName = null;
    });
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(20),
      ),
    );
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
        break;
      case 3:
        if (_addressProofFile == null) {
          _showErrorSnackBar('Por favor, anexe o comprovante de endereço');
          return;
        }
        _submitRegistration();
        return;
    }
    
    if (isValid && _currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      
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
      
      _fadeController.reset();
      _slideController.reset();
      _fadeController.forward();
      _slideController.forward();
    }
  }
  
  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(seconds: 2));
    
    final professional = ProfessionalModel(
      cpf: _cpfController.text,
      fullName: _nameController.text,
      rg: _rgController.text,
      email: _emailController.text,
      password: _passwordController.text,
      cep: _cepController.text,
      street: _streetController.text,
      number: _numberController.text,
      complement: _complementController.text,
      neighborhood: _neighborhoodController.text,
      city: _cityController.text,
      state: _stateController.text,
      addressProofPath: _addressProofFile?.path,
    );
    
    print('Profissional registrado: ${professional.toJson()}');
    
    setState(() => _isLoading = false);
    
    if (mounted) {
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
                color: const Color(0xFF256525).withOpacity(0.3),
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
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF256525).withOpacity(0.2),
                      AppColors.mediumGreen.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF256525),
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
                'Sua conta profissional foi criada com sucesso.',
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF256525), AppColors.mediumGreen],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: const Center(
                        child: Text(
                          'Fazer Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
    );
  }
  
  @override
  Widget build(BuildContext context) {
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
              _buildModernHeader(),
              _buildModernProgressIndicator(),
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
                        _buildDocumentStep(),
                      ],
                    ),
                  ),
                ),
              ),
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
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
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
                        text: 'Profissional',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF256525),
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
        return 'Informações pessoais e documentos';
      case 1:
        return 'Crie sua senha de acesso';
      case 2:
        return 'Endereço completo';
      case 3:
        return 'Comprovante de endereço';
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
          for (int i = 0; i < 4; i++) ...[
            _buildStepDot(i),
            if (i < 3) _buildStepConnector(i),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStepDot(int step) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 44 : 36,
      height: isActive ? 44 : 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive || isCompleted
            ? const LinearGradient(
                colors: [Color(0xFF256525), AppColors.mediumGreen],
              )
            : null,
        color: !isActive && !isCompleted
            ? AppColors.charcoalGrey.withOpacity(0.5)
            : null,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF256525).withOpacity(0.4),
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
                size: 18,
              )
            : Text(
                '${step + 1}',
                style: TextStyle(
                  color: isActive || isCompleted
                      ? Colors.white
                      : AppColors.secondaryText.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  fontSize: isActive ? 16 : 14,
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
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? const LinearGradient(
                  colors: [Color(0xFF256525), AppColors.mediumGreen],
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
            
            _buildModernInputField(
              controller: _rgController,
              focusNode: _rgFocusNode,
              label: 'RG',
              hint: '00.000.000-0',
              icon: Icons.credit_card_outlined,
              inputFormatters: [_rgMask],
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu RG';
                }
                if (value.length < 12) {
                  return 'RG inválido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
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
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF256525).withOpacity(0.1),
                    AppColors.mediumGreen.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF256525).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF256525),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Dicas para uma senha forte',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF256525),
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
                  ? const Color(0xFF256525).withOpacity(0.2)
                  : Colors.transparent,
              border: Border.all(
                color: isRequired 
                    ? const Color(0xFF256525)
                    : AppColors.secondaryText.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: isRequired
                ? const Icon(
                    Icons.check,
                    size: 12,
                    color: Color(0xFF256525),
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
            
            _buildModernInputField(
              controller: _cepController,
              focusNode: _cepFocusNode,
              label: 'CEP',
              hint: '00000-000',
              icon: Icons.location_on_outlined,
              inputFormatters: [_cepMask],
              keyboardType: TextInputType.number,
              suffixWidget: _isSearchingCep
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF256525),
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
                    hint: 'Apto, Bloco',
                    icon: Icons.add_home_outlined,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
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
  
  Widget _buildDocumentStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.info.withOpacity(0.1),
                  AppColors.info.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.info.withOpacity(0.2),
                width: 1,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Documentos aceitos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Conta de luz, água, gás, telefone ou extrato bancário dos últimos 3 meses',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          if (_addressProofFile == null)
            GestureDetector(
              onTap: _pickAddressProof,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF256525).withOpacity(0.05),
                      AppColors.mediumGreen.withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF256525).withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF256525), AppColors.mediumGreen],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Clique para anexar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PDF, JPG ou PNG',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(0.1),
                    AppColors.success.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _addressProofFileName?.endsWith('.pdf') ?? false
                          ? Icons.picture_as_pdf_rounded
                          : Icons.image_rounded,
                      color: AppColors.success,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Arquivo anexado com sucesso',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _addressProofFileName ?? 'documento',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText.withOpacity(0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _removeAddressProof,
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColors.error,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          if (_addressProofFile != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickAddressProof,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('Trocar Documento'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF256525),
                side: const BorderSide(color: Color(0xFF256525)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 40),
        ],
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: isFocused || hasText ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: isFocused
                ? const Color(0xFF256525)
                : AppColors.secondaryText,
            letterSpacing: 0.5,
          ),
          child: Text(label),
        ),
        
        const SizedBox(height: 8),
        
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.charcoalGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused
                  ? const Color(0xFF256525)
                  : AppColors.lightGrey.withOpacity(0.1),
              width: isFocused ? 2 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFF256525).withOpacity(0.1),
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
                    ? const Color(0xFF256525)
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
              label: _currentStep == 3 ? 'Finalizar' : 'Próximo',
              icon: _currentStep == 3 ? Icons.check : Icons.arrow_forward_ios,
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
              ? [const Color(0xFF256525), AppColors.mediumGreen]
              : [
                  AppColors.charcoalGrey.withOpacity(0.5),
                  AppColors.charcoalGrey.withOpacity(0.5),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: const Color(0xFF256525).withOpacity(0.3),
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
                ? const SizedBox(
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

class _FilePickerOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _FilePickerOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.charcoalGrey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.lightGrey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.secondaryText.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}