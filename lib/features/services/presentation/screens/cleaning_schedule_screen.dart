import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/cleaning_pricing_provider.dart';
import '../../data/models/cleaning_pricing_model.dart';
import '../../data/enums/cleaning_type.dart';
import 'payment_confirmation_screen.dart';
import 'pix_payment_screen.dart';
import '../../../../services/payment_service.dart';
import '../../../../models/payment_response.dart';
import '../../../../utils/card_validator.dart';

class CleaningScheduleScreen extends StatefulWidget {
  final String serviceTitle;
  final CleaningType cleaningType;
  
  const CleaningScheduleScreen({
    Key? key,
    required this.serviceTitle,
    this.cleaningType = CleaningType.standard,
  }) : super(key: key);

  @override
  State<CleaningScheduleScreen> createState() => _CleaningScheduleScreenState();
}

class _CleaningScheduleScreenState extends State<CleaningScheduleScreen>
    with TickerProviderStateMixin {
  // Pricing Provider
  late CleaningPricingProvider _pricingProvider;
  
  // Animation Controllers
  late AnimationController _headerController;
  late AnimationController _cardController;
  late AnimationController _footerController;
  late AnimationController _priceController;
  late AnimationController _pulseController;
  late AnimationController _pageTransitionController;
  
  // Animations
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _footerSlideAnimation;
  late Animation<double> _priceAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _pageTransitionAnimation;
  
  // Staggered animations for cards
  final List<AnimationController> _cardAnimationControllers = [];
  final List<Animation<double>> _cardAnimations = [];
  
  // Page Controller
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Payment related
  String _selectedPaymentMethod = 'credit_card';
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  String _pixCode = '';
  bool _pixCodeGenerated = false;
  bool _pixCopied = false;
  bool _isProcessingPix = false;
  
  // State
  String _selectedResidence = 'apartment';
  int _rooms = 2;
  int _bathrooms = 1;
  bool _includeProducts = false;
  bool _includePets = false;
  DateTime? _selectedDate;
  String? _selectedTime;
  
  double _currentPrice = 0;
  double _targetPrice = 149.0;
  int _estimatedTimeInMinutes = 120; // Base time in minutes
  
  final ScrollController _scrollController = ScrollController();
  
  // Available dates (next 14 days)
  late List<DateTime> _availableDates;
  
  // Time slots
  final List<String> _morningSlots = ['08:00', '09:00', '10:00', '11:00'];
  final List<String> _afternoonSlots = ['14:00', '15:00', '16:00', '17:00', '18:00'];

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _initializeAnimations();
    
    // Initialize pricing provider with the correct cleaning type
    _pricingProvider = CleaningPricingProvider(
      initialType: widget.cleaningType,
    );
    _pricingProvider.addListener(_onPricingDataChanged);
    
    // Load pricing data and calculate initial price
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPricingData();
    });
  }
  
  void _onPricingDataChanged() {
    if (_pricingProvider.hasData) {
      _calculatePrice();
    }
  }
  
  Future<void> _loadPricingData() async {
    await _pricingProvider.loadPricingData(type: widget.cleaningType);
    if (_pricingProvider.hasData) {
      _calculatePrice();
    }
  }

  void _initializeDates() {
    final now = DateTime.now();
    _availableDates = List.generate(14, (index) => now.add(Duration(days: index)));
    _selectedDate = _availableDates[0];
  }

  void _initializeAnimations() {
    // Header animation
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerAnimation = Tween<double>(
      begin: -50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));
    
    // Main card animation
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));
    
    // Footer animation
    _footerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _footerSlideAnimation = Tween<double>(
      begin: 100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _footerController,
      curve: Curves.easeOutCubic,
    ));
    
    // Price animation
    _priceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _priceAnimation = Tween<double>(
      begin: _currentPrice,
      end: _targetPrice,
    ).animate(CurvedAnimation(
      parent: _priceController,
      curve: Curves.easeInOut,
    ));
    
    // Pulse animation for CTA button
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Page transition animation
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pageTransitionAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize staggered card animations
    for (int i = 0; i < 6; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 400 + (i * 100)),
        vsync: this,
      );
      _cardAnimationControllers.add(controller);
      _cardAnimations.add(
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        )),
      );
    }
    
    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardController.forward();
    
    for (var controller in _cardAnimationControllers) {
      controller.forward();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    await Future.delayed(const Duration(milliseconds: 300));
    _footerController.forward();
  }

  void _calculatePrice() {
    if (!_pricingProvider.hasData) {
      // If pricing data is not loaded yet, skip calculation
      return;
    }
    
    // Calculate price using the provider
    double base = _pricingProvider.calculatePrice(
      residenceType: _selectedResidence,
      rooms: _rooms,
      bathrooms: _bathrooms,
      includeProducts: _includeProducts,
      includePets: _includePets,
    );
    
    // Calculate time using the provider
    int timeInMinutes = _pricingProvider.calculateTime(
      residenceType: _selectedResidence,
      rooms: _rooms,
      bathrooms: _bathrooms,
      includePets: _includePets,
    );
    
    setState(() {
      _currentPrice = _targetPrice;
      _targetPrice = base;
      _estimatedTimeInMinutes = timeInMinutes;
      _priceAnimation = Tween<double>(
        begin: _currentPrice,
        end: _targetPrice,
      ).animate(CurvedAnimation(
        parent: _priceController,
        curve: Curves.easeInOut,
      ));
      _priceController.forward(from: 0);
    });
  }

  void _goToNextPage() {
    if (_currentPage < 2) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _pageTransitionController.forward();
      
      // Generate PIX code when entering payment page
      if (_currentPage == 2 && _selectedPaymentMethod == 'pix' && !_pixCodeGenerated) {
        _generatePixCode();
      }
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      // Ensure animation is properly set for previous pages
      if (_currentPage > 0) {
        _pageTransitionController.forward();
      } else {
        _pageTransitionController.reverse();
      }
    }
  }
  
  void _generatePixCode() {
    setState(() {
      _pixCodeGenerated = true;
      _pixCode = '00020126360014BR.GOV.BCB.PIX0114+5511999999999520400005303986540${_targetPrice.toStringAsFixed(2)}5802BR5925NOME DO RECEBEDOR6009SAO PAULO62070503***6304A1B2';
    });
  }

  @override
  void dispose() {
    _pricingProvider.removeListener(_onPricingDataChanged);
    _pricingProvider.dispose();
    _headerController.dispose();
    _cardController.dispose();
    _footerController.dispose();
    _priceController.dispose();
    _pulseController.dispose();
    _pageTransitionController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    for (var controller in _cardAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _pricingProvider,
      child: Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  const Color(0xFFF8FAFB),
                ],
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Animated Header
                AnimatedBuilder(
                  animation: _headerAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _headerAnimation.value),
                      child: _buildHeader(),
                    );
                  },
                ),
                
                // Progress Bar
                _buildProgressBar(),
                
                // Page View
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      // First Page - Service Configuration
                      _buildServiceConfigurationPage(),
                      // Second Page - Date and Time Selection
                      _buildDateTimePage(),
                      // Third Page - Payment
                      _buildPaymentPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Animated Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _footerSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _footerSlideAnimation.value),
                  child: _buildModernFooter(),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              if (_currentPage > 0) {
                _goToPreviousPage();
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: Color(0xFF2D3436),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentPage == 0 ? 'Configurar Serviço' : 'Agendar Horário',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3436),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _currentPage == 0 
                              ? 'Personalize sua limpeza' 
                              : _currentPage == 1 
                                  ? 'Escolha data e hora'
                                  : 'Finalizar pagamento',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (widget.cleaningType == CleaningType.heavy) ...[  
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'PESADA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange[700],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Help button
          GestureDetector(
            onTap: _showHelpModal,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.1),
                    AppColors.primaryGreen.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.help_outline,
                size: 20,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildHelpModal(),
    );
  }

  Widget _buildHelpModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen,
                  AppColors.primaryGreen.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x4DFFFFFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Como funciona',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Entenda como agendar seu serviço',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFFE6FFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0x33FFFFFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1
                  _buildHelpStep(
                    step: 1,
                    title: 'Configure seu serviço',
                    description: 'Personalize sua limpeza escolhendo o tipo de imóvel, quantidade de cômodos e serviços extras.',
                    icon: Icons.cleaning_services,
                    color: Colors.indigo,
                  ),

                  const SizedBox(height: 24),

                  // Step 2
                  _buildHelpStep(
                    step: 2,
                    title: 'Escolha data e horário',
                    description: 'Selecione a data disponível e o horário que melhor se adapta à sua agenda.',
                    icon: Icons.calendar_today,
                    color: Colors.deepPurple,
                  ),

                  const SizedBox(height: 24),

                  // Step 3
                  _buildHelpStep(
                    step: 3,
                    title: 'Finalize o pagamento',
                    description: 'Escolha entre cartão de crédito ou PIX para efetuar o pagamento de forma segura.',
                    icon: Icons.payment,
                    color: Colors.teal,
                  ),

                  const SizedBox(height: 32),

                  // Additional Information
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE8ECEF),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Informações importantes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(
                          '⏰',
                          'Serviços disponíveis das 8h às 18h',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoItem(
                          '📅',
                          'Agendamentos com até 24h de antecedência',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoItem(
                          '💳',
                          'Pagamento seguro via cartão ou PIX',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoItem(
                          '🔄',
                          'Cancelamento gratuito até 2h antes',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Contact
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.support_agent,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Precisa de ajuda?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Entre em contato conosco através do WhatsApp ou email para tirar dúvidas sobre o agendamento.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
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

  Widget _buildHelpStep({
    required int step,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String emoji, String text) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Step 1 - Configuração
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Step 2 - Data e Hora
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: _currentPage >= 1 
                    ? AppColors.primaryGreen 
                    : AppColors.primaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Step 3 - Pagamento
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: _currentPage >= 2 
                    ? AppColors.primaryGreen 
                    : AppColors.primaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceConfigurationPage() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Residence Type Section
          _buildAnimatedCard(0, _buildResidenceSection()),
          
          // Room Details Section
          _buildAnimatedCard(1, _buildRoomDetailsSection()),
          
          // Extra Services Section
          _buildAnimatedCard(2, _buildExtrasSection()),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDateTimePage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Date Selection Section
          AnimatedBuilder(
            animation: _pageTransitionAnimation,
            builder: (context, child) {
              // Ensure content is always visible when on this page
              final animationValue = _currentPage == 1 ? 1.0 : _pageTransitionAnimation.value;
              return Transform.scale(
                scale: 0.8 + (0.2 * animationValue),
                child: Opacity(
                  opacity: animationValue,
                  child: _buildDateSection(),
                ),
              );
            },
          ),

          // Time Selection Section
          AnimatedBuilder(
            animation: _pageTransitionAnimation,
            builder: (context, child) {
              // Ensure content is always visible when on this page
              final animationValue = _currentPage == 1 ? 1.0 : _pageTransitionAnimation.value;
              return Transform.translate(
                offset: Offset(0, 50 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: _buildTimeSection(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(int index, Widget child) {
    if (index >= _cardAnimations.length) return child;
    
    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (context, _) {
        return Transform.scale(
          scale: _cardAnimations[index].value,
          child: Opacity(
            opacity: _cardAnimations[index].value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildResidenceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryGreen.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tipo de Imóvel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Residence options
          Consumer<CleaningPricingProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              if (provider.error != null) {
                return Center(
                  child: Column(
                    children: [
                      Text(
                        'Erro ao carregar preços',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => provider.reloadPricingData(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                );
              }
              
              if (!provider.hasData) {
                return const Center(
                  child: Text('Nenhum dado de preço disponível'),
                );
              }
              
              return Row(
                children: [
                  _buildResidenceOption(
                    'studio',
                    'Studio',
                    Icons.single_bed,
                    _formatCurrency(provider.getBasePriceForResidence('studio'))
                  ),
                  const SizedBox(width: 12),
                  _buildResidenceOption(
                    'apartment',
                    'Apto',
                    Icons.apartment,
                    _formatCurrency(provider.getBasePriceForResidence('apartment'))
                  ),
                  const SizedBox(width: 12),
                  _buildResidenceOption(
                    'house',
                    'Casa',
                    Icons.house,
                    _formatCurrency(provider.getBasePriceForResidence('house'))
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResidenceOption(String value, String label, IconData icon, String price) {
    final isSelected = _selectedResidence == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedResidence = value;
            _calculatePrice();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryGreen.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : const Color(0xFFF8FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primaryGreen
                  : const Color(0xFFE8ECEF),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF74788D),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected 
                      ? Colors.white.withOpacity(0.9)
                      : const Color(0xFF74788D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.blue.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.door_sliding_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Detalhes do Imóvel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Room counter
          _buildCounterRow(
            icon: Icons.weekend,
            label: 'Cômodos',
            value: _rooms,
            color: Colors.indigo,
            onDecrease: _rooms > 1 ? () {
              HapticFeedback.lightImpact();
              setState(() {
                _rooms--;
                _calculatePrice();
              });
            } : null,
            onIncrease: () {
              HapticFeedback.lightImpact();
              setState(() {
                _rooms++;
                _calculatePrice();
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Bathroom counter
          _buildCounterRow(
            icon: Icons.bathtub,
            label: 'Banheiros',
            value: _bathrooms,
            color: Colors.purple,
            onDecrease: _bathrooms > 1 ? () {
              HapticFeedback.lightImpact();
              setState(() {
                _bathrooms--;
                _calculatePrice();
              });
            } : null,
            onIncrease: () {
              HapticFeedback.lightImpact();
              setState(() {
                _bathrooms++;
                _calculatePrice();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
    VoidCallback? onDecrease,
    required VoidCallback onIncrease,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3436),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDecrease,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.remove,
                      color: onDecrease != null 
                          ? const Color(0xFF2D3436)
                          : const Color(0xFFCED4DA),
                      size: 18,
                    ),
                  ),
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onIncrease,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add,
                      color: AppColors.primaryGreen,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExtrasSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.orange.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Serviços Extras',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Extra options
          Consumer<CleaningPricingProvider>(
            builder: (context, provider, child) {
              if (!provider.hasData) {
                return const SizedBox.shrink();
              }
              
              return Column(
                children: [
                  _buildExtraOption(
                    icon: Icons.cleaning_services,
                    label: 'Produtos inclusos',
                    description: 'Fornecemos todos os produtos de limpeza profissionais',
                    price: '+ ${_formatCurrency(provider.getProductsPrice())}',
                    isSelected: _includeProducts,
                    color: Colors.teal,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _includeProducts = !_includeProducts;
                        _calculatePrice();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildExtraOption(
                    icon: Icons.pets,
                    label: 'Tenho pets',
                    description: 'Cuidado especial com pelos e odores de animais',
                    price: '+ ${_formatCurrency(provider.getPetsPrice())}',
                    isSelected: _includePets,
                    color: Colors.pink,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _includePets = !_includePets;
                        _calculatePrice();
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExtraOption({
    required IconData icon,
    required String label,
    required String price,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
    String? description,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.05)
              : const Color(0xFFF8FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? color.withOpacity(0.3)
                : const Color(0xFFE8ECEF),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : const Color(0xFFCED4DA),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple,
                      Colors.deepPurple.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Escolha a Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Date grid
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableDates.length,
              itemBuilder: (context, index) {
                final date = _availableDates[index];
                final isSelected = _selectedDate?.day == date.day;
                final isToday = index == 0;
                
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                AppColors.primaryGreen,
                                AppColors.primaryGreen.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : const Color(0xFFF8FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primaryGreen
                            : const Color(0xFFE8ECEF),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isToday ? 'Hoje' : _getWeekday(date),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isSelected 
                                ? Colors.white.withOpacity(0.8)
                                : const Color(0xFF74788D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isSelected 
                                ? Colors.white
                                : const Color(0xFF2D3436),
                          ),
                        ),
                        Text(
                          _getMonth(date),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected 
                                ? Colors.white.withOpacity(0.8)
                                : const Color(0xFF74788D),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyan,
                      Colors.cyan.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Escolha o Horário',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Morning slots
          const Text(
            'Manhã',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF74788D),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _morningSlots.map((time) => _buildTimeSlot(time)).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Afternoon slots
          const Text(
            'Tarde',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF74788D),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _afternoonSlots.map((time) => _buildTimeSlot(time)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String time) {
    final isSelected = _selectedTime == time;
    final isAvailable = !['11:00', '16:00'].contains(time);
    
    return GestureDetector(
      onTap: isAvailable ? () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedTime = time;
        });
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.primaryGreen.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected 
              ? null 
              : isAvailable 
                  ? const Color(0xFFF8FAFB)
                  : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected 
                ? AppColors.primaryGreen
                : isAvailable 
                    ? const Color(0xFFE8ECEF)
                    : const Color(0xFFE8ECEF),
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected 
                ? Colors.white
                : isAvailable 
                    ? const Color(0xFF2D3436)
                    : const Color(0xFFCED4DA),
          ),
        ),
      ),
    );
  }



  Widget _buildModernFooter() {
    // Verifica se pode continuar baseado na página e método de pagamento
    bool canContinue = false;

    if (_currentPage == 2) {
      // Página de pagamento
      if (_selectedPaymentMethod == 'pix') {
        canContinue = true; // Sempre pode prosseguir com PIX
      } else {
        // Cartão: só se todos os campos estiverem preenchidos
        canContinue = _cardNumberController.text.length >= 16 &&
                     _cardHolderController.text.isNotEmpty &&
                     _expiryDateController.text.length >= 5 &&
                     _cvvController.text.length >= 3;
      }
    } else {
      // Páginas anteriores
      canContinue = _currentPage == 0 || (_selectedDate != null && _selectedTime != null);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // Price display
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedBuilder(
                      animation: _priceAnimation,
                      builder: (context, child) {
                        return Text(
                          _formatCurrency(_priceAnimation.value),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                            letterSpacing: -0.4,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // CTA Button - Smaller size
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: canContinue && !_isProcessingPix
                      ? LinearGradient(
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.primaryGreen.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: (canContinue && !_isProcessingPix) ? null : const Color(0xFFE8ECEF),
                  boxShadow: (canContinue && !_isProcessingPix)
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: (canContinue && !_isProcessingPix) ? () {
                      HapticFeedback.mediumImpact();
                      if (_currentPage < 2) {
                        _goToNextPage();
                      } else {
                        // Página de pagamento - sempre chama _confirmSchedule que já tem a lógica correta
                        _confirmSchedule();
                      }
                    } : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isProcessingPix) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Gerando código...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: canContinue
                                    ? Colors.white
                                    : const Color(0xFF74788D),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ] else ...[
                            Text(
                              _currentPage == 2
                                  ? 'Confirmar'
                                  : 'Próximo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: canContinue
                                    ? Colors.white
                                    : const Color(0xFF74788D),
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (_currentPage < 2) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: canContinue
                                    ? Colors.white
                                    : const Color(0xFF74788D),
                              ),
                            ] else ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: canContinue
                                    ? Colors.white
                                    : const Color(0xFF74788D),
                              ),
                            ],
                          ],
                        ],
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

  String _getWeekday(DateTime date) {
    const weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return weekdays[date.weekday % 7];
  }

  String _getMonth(DateTime date) {
    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return months[date.month - 1];
  }

  String _formatEstimatedTime() {
    final hours = _estimatedTimeInMinutes ~/ 60;
    final minutes = _estimatedTimeInMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }

  String _formatCurrency(double value) {
    // Formatar para Real brasileiro: R$ 1.234,56
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  void _processPixPayment() async {
    HapticFeedback.mediumImpact();

    setState(() {
      _isProcessingPix = true;
    });

    try {
      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      // Process PIX payment via API
      final response = await PaymentService.processPixPayment(
        userId: currentUser.uid,
        amount: _targetPrice,
        description: 'Agendamento: ${widget.serviceTitle}',
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _pixCode = response.data!.qrCode;
          _pixCodeGenerated = true;
          _isProcessingPix = false;
        });
        
        // Navigate to PIX payment screen with real data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PixPaymentScreen(
              pixCode: response.data!.qrCode,
              amount: _targetPrice,
              serviceTitle: widget.serviceTitle,
              selectedDate: _selectedDate ?? DateTime.now(),
              selectedTime: _selectedTime ?? '09:00',
            ),
          ),
        );
      } else {
        setState(() {
          _isProcessingPix = false;
        });
        _showErrorMessage(response.error ?? 'Erro ao gerar código PIX');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingPix = false;
        });
        _showErrorMessage('Erro: ${e.toString()}');
      }
    }
  }
  
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showPixPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPixPaymentModal(),
    );
  }
  
  void _showPixPaymentModalWithData(PixPaymentResponse pixResponse) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00BFA5),
                    const Color(0xFF00BFA5).withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.pix,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PIX Gerado com Sucesso!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${pixResponse.paymentId}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // QR Code
                    if (pixResponse.qrCodeBase64.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00BFA5).withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.memory(
                          base64Decode(pixResponse.qrCodeBase64),
                          width: 250,
                          height: 250,
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Amount
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Valor a pagar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF74788D),
                            ),
                          ),
                          Text(
                            'R\$ ${pixResponse.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF00BFA5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // PIX Code
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE8ECEF),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.content_copy, size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                'Código PIX Copia e Cola',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            pixResponse.qrCode,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Color(0xFF2D3436),
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Copy button
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: pixResponse.qrCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Código PIX copiado!'),
                            backgroundColor: Color(0xFF00BFA5),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF00BFA5),
                              const Color(0xFF00BFA5).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00BFA5).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.copy, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Copiar Código PIX',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Expiration info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer, size: 16, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Este código expira em ${_formatExpirationTime(pixResponse.expirationDate)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Confirm button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmSchedule();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirmar Agendamento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatExpirationTime(String expirationDate) {
    try {
      final expiration = DateTime.parse(expirationDate);
      final now = DateTime.now();
      final difference = expiration.difference(now);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutos';
      } else {
        final hours = difference.inHours;
        return '$hours ${hours == 1 ? 'hora' : 'horas'}';
      }
    } catch (e) {
      return '30 minutos';
    }
  }

  void _confirmSchedule() async {
    HapticFeedback.mediumImpact();
    
    // For credit card payment
    if (_selectedPaymentMethod == 'credit_card') {
      print('=== INICIANDO PAGAMENTO COM CARTÃO ===');
      
      // Validate card fields
      if (_cardNumberController.text.length < 16 ||
          _cardHolderController.text.isEmpty ||
          _expiryDateController.text.length < 5 ||
          _cvvController.text.length < 3) {
        print('ERRO: Campos do cartão incompletos');
        print('Número do cartão: ${_cardNumberController.text.length} caracteres');
        print('Nome do titular: ${_cardHolderController.text.isEmpty ? "vazio" : "preenchido"}');
        print('Validade: ${_expiryDateController.text.length} caracteres');
        print('CVV: ${_cvvController.text.length} caracteres');
        _showErrorMessage('Por favor, preencha todos os campos do cartão');
        return;
      }
      
      setState(() {
        _isProcessingPix = true; // Using same flag for loading state
      });
      
      try {
        // Get current user
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          print('ERRO: Usuário não autenticado');
          throw Exception('Usuário não autenticado');
        }
        
        print('Usuário autenticado: ${currentUser.uid}');
        
        // Extract expiry date parts
        final expiryParts = _expiryDateController.text.split('/');
        final expiryMonth = expiryParts[0];
        final expiryYear = '20${expiryParts[1]}'; // Convert YY to YYYY
        
        // Log card data (masking sensitive info)
        final maskedCardNumber = _cardNumberController.text.replaceAll(' ', '');
        print('=== DADOS DO CARTÃO ===');
        print('Número do cartão: ${maskedCardNumber.substring(0, 4)}****${maskedCardNumber.substring(maskedCardNumber.length - 4)}');
        print('Nome do titular: ${_cardHolderController.text}');
        print('Validade: $expiryMonth/$expiryYear');
        print('CVV: ${_cvvController.text.length} dígitos');
        print('Valor: R\$ $_targetPrice');
        print('Parcelas: 1');
        print('Descrição: Agendamento: ${widget.serviceTitle}');
        print('=======================');
        
        // Process card payment via API
        print('Chamando PaymentService.processCardPayment()...');
        final response = await PaymentService.processCardPayment(
          userId: currentUser.uid,
          amount: _targetPrice,
          cardNumber: _cardNumberController.text.replaceAll(' ', ''),
          expirationYear: expiryYear,
          expirationMonth: expiryMonth,
          securityCode: _cvvController.text,
          installments: 1,
          description: 'Agendamento: ${widget.serviceTitle}',
        );
        
        if (!mounted) return;
        
        print('=== RESPOSTA DA API ===');
        print('Success: ${response.success}');
        print('Error: ${response.error}');
        print('Message: ${response.message}');
        if (response.data != null) {
          print('Payment ID: ${response.data!.paymentId}');
          print('Status: ${response.data!.status}');
          print('Status Detail: ${response.data!.statusDetail}');
          print('Is Approved: ${response.data!.isApproved}');
        }
        print('=======================');
        
        setState(() {
          _isProcessingPix = false;
        });
        
        if (response.success && response.data != null) {
          if (response.data!.isApproved) {
            print('SUCESSO: Pagamento aprovado!');
            // Payment approved - navigate to confirmation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentConfirmationScreen(
                  serviceTitle: widget.serviceTitle,
                  totalAmount: _targetPrice,
                  selectedDate: _selectedDate ?? DateTime.now(),
                  selectedTime: _selectedTime ?? '',
                  paymentMethod: _selectedPaymentMethod,
                ),
              ),
            );
          } else {
            print('ERRO: Pagamento recusado - ${response.data!.statusDetail}');
            _showErrorMessage('Pagamento recusado: ${response.data!.statusDetail}');
          }
        } else {
          print('ERRO: ${response.error ?? "Erro desconhecido"}');
          _showErrorMessage(response.error ?? 'Erro ao processar pagamento');
        }
      } catch (e) {
        print('EXCEÇÃO CAPTURADA: ${e.toString()}');
        print('Stack trace: ${StackTrace.current}');
        if (mounted) {
          setState(() {
            _isProcessingPix = false;
          });
          _showErrorMessage('Erro: ${e.toString()}');
        }
      }
    } else if (_selectedPaymentMethod == 'pix') {
      // For PIX payment, process the PIX first
      _processPixPayment();
    }
  }
  
  Widget _buildPaymentPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Title Section
            _buildTitleSection(),

            const SizedBox(height: 32),

            // Service Summary
            _buildServiceSummary(),

            const SizedBox(height: 32),

            // Payment Methods
            _buildPaymentMethodSelector(),

            const SizedBox(height: 32),

            // Payment Content - Only show if credit card is selected
            if (_selectedPaymentMethod == 'credit_card') ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: Container(
                  key: const ValueKey('card'),
                  child: _buildCreditCardContent(),
                ),
              ),
            ] else if (_selectedPaymentMethod == 'pix') ...[
              // Clean and compact PIX card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00BFA5).withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00BFA5).withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Compact header with icon and title
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BFA5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.pix,
                              size: 24,
                              color: Color(0xFF00BFA5),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PIX Selecionado',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D3436),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pagamento instantâneo e sem taxas',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Compact instructions
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Como funciona:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ao confirmar, você receberá o código PIX para pagamento',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Compact benefits
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCompactPixBenefit(Icons.flash_on, 'Instantâneo'),
                          _buildCompactPixBenefit(Icons.security, 'Seguro'),
                          _buildCompactPixBenefit(Icons.attach_money, 'Sem taxas'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Finalizar Agendamento',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436),
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha como deseja pagar pelo serviço',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Service info
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.cleaning_services,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.serviceTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_selectedDate?.day}/${_selectedDate?.month}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedTime ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFE8E8E8)),

            const SizedBox(height: 20),

            // Total price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatCurrency(_targetPrice),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalValueCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total a pagar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${_targetPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTotalInfoItem(Icons.cleaning_services, widget.serviceTitle),
                Container(width: 1, height: 20, color: Colors.white.withOpacity(0.3)),
                _buildTotalInfoItem(Icons.calendar_today, '${_selectedDate?.day}/${_selectedDate?.month}'),
                Container(width: 1, height: 20, color: Colors.white.withOpacity(0.3)),
                _buildTotalInfoItem(Icons.access_time, _selectedTime ?? '--:--'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTotalInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withOpacity(0.9)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPaymentMethodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Método de Pagamento',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPaymentMethodCard('credit_card', 'Cartão', Icons.credit_card, 'Crédito ou Débito'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPaymentMethodCard('pix', 'PIX', Icons.qr_code_2, 'Pagamento instantâneo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentMethodCard(String method, String title, IconData icon, String subtitle) {
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedPaymentMethod = method;
          if (method == 'pix' && !_pixCodeGenerated) {
            _generatePixCode();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen.withOpacity(0.1)
                    : const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primaryGreen : const Color(0xFF9B9B9B),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primaryGreen : const Color(0xFF2D3436),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCreditCardContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Form Fields
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE8ECEF),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card number field with icon
                _buildEnhancedInput(
                  controller: _cardNumberController,
                  label: 'Número do cartão',
                  hint: '0000 0000 0000 0000',
                  prefixIcon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  onChanged: (value) {
                    final cleanValue = value.replaceAll(' ', '');
                    final buffer = StringBuffer();
                    for (int i = 0; i < cleanValue.length && i < 16; i++) {
                      if (i > 0 && i % 4 == 0) {
                        buffer.write(' ');
                      }
                      buffer.write(cleanValue[i]);
                    }
                    final formatted = buffer.toString();
                    if (formatted != value) {
                      _cardNumberController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                ),
                
                const SizedBox(height: 20),

                // Card holder name field
                _buildEnhancedInput(
                  controller: _cardHolderController,
                  label: 'Nome do titular',
                  hint: 'NOME COMPLETO',
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.characters,
                ),
                
                const SizedBox(height: 20),

                // Expiry date and CVV in row
                Row(
                  children: [
                    Expanded(
                      child: _buildEnhancedInput(
                        controller: _expiryDateController,
                        label: 'Validade',
                        hint: 'MM/AA',
                        prefixIcon: Icons.calendar_month,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        onChanged: (value) {
                          final cleanValue = value.replaceAll('/', '');
                          if (cleanValue.length >= 2) {
                            final formatted = '${cleanValue.substring(0, min(2, cleanValue.length))}/${cleanValue.substring(min(2, cleanValue.length))}';
                            if (formatted != value) {
                              _expiryDateController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(offset: formatted.length),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildEnhancedInput(
                        controller: _cvvController,
                        label: 'CVV',
                        hint: '123',
                        prefixIcon: Icons.lock_outline,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        helperText: 'Código de segurança',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Security badges
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.security, size: 18, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      'Pagamento 100% seguro',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSecurityBadge(Icons.https, '256-bit'),
                    _buildSecurityBadge(Icons.verified_user, 'PCI DSS'),
                    _buildSecurityBadge(Icons.shield, 'Protegido'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPixContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PIX Header
          Row(
            children: [
              Icon(Icons.pix, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                'Pagamento via PIX',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // PIX Code Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8ECEF)),
            ),
            child: Column(
              children: [
                // PIX Code Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE8ECEF),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pix,
                            size: 24,
                            color: const Color(0xFF00BFA5),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Código PIX Copia e Cola',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D3436),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _pixCode.isNotEmpty
                            ? _pixCode
                            : 'Gerando código PIX...',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Color(0xFF2D3436),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Copie o código acima e cole no app do seu banco',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Copy PIX Code button
          GestureDetector(
            onTap: () {
              if (_pixCode.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: _pixCode));
                HapticFeedback.mediumImpact();
                setState(() {
                  _pixCopied = true;
                });
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      _pixCopied = false;
                    });
                  }
                });
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: _pixCopied ? AppColors.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _pixCopied ? AppColors.primaryGreen : const Color(0xFFE8ECEF),
                  width: 1.5,
                ),
                boxShadow: _pixCopied ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _pixCopied ? Icons.check_circle : Icons.copy,
                    size: 20,
                    color: _pixCopied ? Colors.white : const Color(0xFF74788D),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _pixCopied ? 'Código copiado com sucesso!' : 'Copiar código PIX',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _pixCopied ? Colors.white : const Color(0xFF2D3436),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Timer and Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer,
                      size: 18,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Código válido por 30 minutos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Após copiar, abra seu app bancário e procure por "PIX Copia e Cola"',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          cursorColor: AppColors.primaryGreen,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryGreen,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    int? maxLength,
    String? helperText,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
            cursorColor: AppColors.primaryGreen,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
              filled: true,
              fillColor: Colors.white,
              counterText: '',
              helperText: helperText,
              helperStyle: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFE8ECEF),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFE8ECEF),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.red[400]!,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildSecurityBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryGreen),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
  
  int min(int a, int b) => a < b ? a : b;
  
  String _formatCardNumber(String value) {
    final cleanValue = value.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleanValue.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanValue[i]);
    }
    return buffer.toString();
  }



  Widget _buildPixPaymentModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Minimal Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.pix,
                        color: Color(0xFF00BFA5),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pagamento via PIX',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D3436),
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Código para pagamento',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF74788D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey[600],
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compact Value Display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00BFA5).withOpacity(0.05),
                          const Color(0xFF00BFA5).withOpacity(0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00BFA5).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Valor Total',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatCurrency(_targetPrice),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00BFA5),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${_selectedDate?.day}/${_selectedDate?.month}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                _selectedTime ?? '',
                                style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Compact Instructions
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Como realizar o pagamento',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInstructionStep('1', 'Copie o código PIX abaixo'),
                        const SizedBox(height: 8),
                        _buildInstructionStep('2', 'Abra o app do seu banco'),
                        const SizedBox(height: 8),
                        _buildInstructionStep('3', 'Use a opção PIX Copia e Cola'),
                        const SizedBox(height: 8),
                        _buildInstructionStep('4', 'Confirme o pagamento aqui'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PIX Code Section - Cleaner design
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE8ECEF),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.qr_code_2, size: 18, color: const Color(0xFF00BFA5)),
                            const SizedBox(width: 8),
                            Text(
                              'Código PIX Copia e Cola',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            _pixCode,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Color(0xFF2D3436),
                              height: 1.3,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Copy button integrated
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: _pixCode));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    Text('Código PIX copiado!'),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF00BFA5),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BFA5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF00BFA5).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.copy, size: 16, color: const Color(0xFF00BFA5)),
                                const SizedBox(width: 6),
                                Text(
                                  'Copiar código',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF00BFA5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Confirm button
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _confirmSchedule();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGreen,
                                  AppColors.primaryGreen.withOpacity(0.9),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 18, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  'Confirmar Pagamento',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPixBenefit(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00BFA5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00BFA5).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF00BFA5),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00BFA5),
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPixBenefit(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF00BFA5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: const Color(0xFF00BFA5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF00BFA5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF00BFA5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}