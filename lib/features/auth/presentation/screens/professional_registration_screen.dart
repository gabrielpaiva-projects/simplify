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
  // Controllers
  final PageController _pageController = PageController();
  
  // Step 1: Dados Pessoais
  final _cpfController = TextEditingController();
  final _nameController = TextEditingController();
  final _rgController = TextEditingController();
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
  
  // States
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSearchingCep = false;
  File? _addressProofFile;
  String? _addressProofFileName;
  
  // Animation
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  // Image Picker
  final ImagePicker _imagePicker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    // Listener para buscar CEP automaticamente
    _cepController.addListener(_onCepChanged);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
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
    _progressController.dispose();
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
          FocusScope.of(context).nextFocus();
        }
      }
    }
  }
  
  Future<void> _pickAddressProof() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Escolha o tipo de arquivo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: AppColors.primary),
              ),
              title: const Text('Tirar Foto'),
              subtitle: const Text('Use a câmera para capturar o documento'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library, color: AppColors.secondary),
              ),
              title: const Text('Escolher da Galeria'),
              subtitle: const Text('Selecione uma foto existente'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.orange),
              ),
              title: const Text('Escolher PDF'),
              subtitle: const Text('Selecione um arquivo PDF'),
              onTap: () {
                Navigator.pop(context);
                _pickPdfFile();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao capturar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar arquivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _removeAddressProof() {
    setState(() {
      _addressProofFile = null;
      _addressProofFileName = null;
    });
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, anexe o comprovante de endereço'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        _submitRegistration();
        return;
    }
    
    if (isValid && _currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
    }
  }
  
  void _updateProgress() {
    final progress = (_currentStep + 1) / 4;
    _progressController.animateTo(progress);
  }
  
  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);
    
    // Simula envio para API
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cadastro de Profissional',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          // Form Steps
          Expanded(
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
          
          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepIndicator(0, 'Dados'),
              _buildStepConnector(0),
              _buildStepIndicator(1, 'Senha'),
              _buildStepConnector(1),
              _buildStepIndicator(2, 'Endereço'),
              _buildStepConnector(2),
              _buildStepIndicator(3, 'Documento'),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: (_currentStep + 1) / 4,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                minHeight: 4,
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepIndicator(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive || isCompleted ? AppColors.secondary : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.secondary : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepConnector(int step) {
    return Container(
      height: 2,
      width: 24,
      color: step < _currentStep ? AppColors.secondary : Colors.grey[300],
      margin: const EdgeInsets.only(bottom: 24),
    );
  }
  
  Widget _buildPersonalDataStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _personalDataFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dados Pessoais',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Preencha seus dados pessoais e documentos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            
            // CPF
            TextFormField(
              controller: _cpfController,
              inputFormatters: [_cpfMask],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'CPF',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
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
            const SizedBox(height: 16),
            
            // Nome Completo
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nome Completo',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
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
            const SizedBox(height: 16),
            
            // RG
            TextFormField(
              controller: _rgController,
              inputFormatters: [_rgMask],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'RG',
                prefixIcon: const Icon(Icons.credit_card_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
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
            const SizedBox(height: 16),
            
            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-mail',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
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
          ],
        ),
      ),
    );
  }
  
  Widget _buildPasswordStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Crie sua Senha',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha uma senha segura para sua conta',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            
            // Senha
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
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
            const SizedBox(height: 16),
            
            // Confirmar Senha
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirmar Senha',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
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
            const SizedBox(height: 24),
            
            // Dicas de senha
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dicas para uma senha forte:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordTip('Mínimo de 6 caracteres'),
                  _buildPasswordTip('Use letras maiúsculas e minúsculas'),
                  _buildPasswordTip('Inclua números'),
                  _buildPasswordTip('Adicione caracteres especiais'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPasswordTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            tip,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _addressFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Endereço',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Informe seu endereço completo',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            
            // CEP
            TextFormField(
              controller: _cepController,
              inputFormatters: [_cepMask],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'CEP',
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: _isSearchingCep
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                helperText: 'Digite o CEP para buscar o endereço automaticamente',
              ),
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
            const SizedBox(height: 16),
            
            // Rua
            TextFormField(
              controller: _streetController,
              decoration: InputDecoration(
                labelText: 'Rua',
                prefixIcon: const Icon(Icons.home_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a rua';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Número e Complemento
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Número',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
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
                  child: TextFormField(
                    controller: _complementController,
                    decoration: InputDecoration(
                      labelText: 'Complemento (opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Bairro
            TextFormField(
              controller: _neighborhoodController,
              decoration: InputDecoration(
                labelText: 'Bairro',
                prefixIcon: const Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o bairro';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Cidade e Estado
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'Cidade',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
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
                  child: TextFormField(
                    controller: _stateController,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: InputDecoration(
                      labelText: 'UF',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
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
  
  Widget _buildDocumentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Comprovante de Endereço',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anexe um comprovante de endereço recente',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Área de Upload
          if (_addressProofFile == null)
            InkWell(
              onTap: _pickAddressProof,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.secondary.withOpacity(0.05),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 64,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Clique para anexar documento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PDF ou Imagem (JPG, PNG)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                color: Colors.green.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _addressProofFileName?.endsWith('.pdf') ?? false
                          ? Icons.picture_as_pdf
                          : Icons.image,
                      color: Colors.green,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Arquivo anexado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _addressProofFileName ?? 'documento',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: _removeAddressProof,
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Informações sobre o documento
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Documentos aceitos:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Conta de luz, água ou gás\n• Fatura de cartão ou extrato bancário\n• Contrato de aluguel\n• Documento emitido há menos de 3 meses',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botão para trocar documento
          if (_addressProofFile != null)
            OutlinedButton.icon(
              onPressed: _pickAddressProof,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Trocar Documento'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.secondary),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.secondary),
                ),
                child: const Text(
                  'Voltar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep == 3 ? 'Finalizar Cadastro' : 'Próximo',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}