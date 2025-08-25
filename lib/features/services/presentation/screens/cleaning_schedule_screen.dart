import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/cleaning_config_provider.dart';
import '../widgets/config_loading_widget.dart';
import '../widgets/config_error_widget.dart';

class CleaningScheduleScreen extends StatefulWidget {
  final String serviceTitle;
  
  const CleaningScheduleScreen({
    Key? key,
    required this.serviceTitle,
  }) : super(key: key);

  @override
  State<CleaningScheduleScreen> createState() => _CleaningScheduleScreenState();
}

class _CleaningScheduleScreenState extends State<CleaningScheduleScreen>
    with TickerProviderStateMixin {
  // Providers
  late CleaningConfigProvider _configProvider;
  
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
  
  // State
  String _selectedResidence = 'apartment';
  int _rooms = 1; // Will be updated from Firestore min_rooms
  int _bathrooms = 1; // Will be updated from Firestore min_bathrooms
  bool _includeProducts = false;
  bool _includePets = false;
  DateTime? _selectedDate;
  String? _selectedTime;
  
  double _currentPrice = 0;
  double _targetPrice = 0; // Will be set from Firestore configuration
  int _estimatedTimeInMinutes = 0; // Will be set from Firestore configuration
  
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
    
    // Load configuration and calculate initial price
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configProvider = context.read<CleaningConfigProvider>();
      _configProvider.loadConfiguration().then((_) {
        // Set initial values from Firestore configuration
        if (_configProvider.hasConfig) {
          setState(() {
            _rooms = _configProvider.getMinRooms();
            _bathrooms = _configProvider.getMinBathrooms();
          });
        }
        _calculatePrice();
      });
    });
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
    if (!mounted) return;
    
    final provider = context.read<CleaningConfigProvider>();
    
    // Only calculate if configuration is loaded
    if (!provider.hasConfig) {
      print('Configuration not loaded yet');
      return;
    }
    
    try {
      // Calculate price using configuration from Firestore
      double base = provider.calculatePrice(
        residenceType: _selectedResidence,
        rooms: _rooms,
        bathrooms: _bathrooms,
        includeProducts: _includeProducts,
        includePets: _includePets,
      );
      
      // Calculate estimated time using configuration from Firestore
      int timeInMinutes = provider.calculateEstimatedTime(
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
    } catch (e) {
      print('Error calculating price: $e');
    }
  }

  void _goToNextPage() {
    if (_currentPage == 0) {
      setState(() {
        _currentPage = 1;
      });
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _pageTransitionController.forward();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage == 1) {
      setState(() {
        _currentPage = 0;
      });
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _pageTransitionController.reverse();
    }
  }

  @override
  void dispose() {
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      body: Consumer<CleaningConfigProvider>(
        builder: (context, configProvider, child) {
          // Show loading state
          if (configProvider.isLoading) {
            return const Center(
              child: ConfigLoadingWidget(
                message: 'Carregando configuração de preços...',
              ),
            );
          }
          
          // Show error state
          if (configProvider.error != null && !configProvider.hasConfig) {
            return Center(
              child: ConfigErrorWidget(
                error: configProvider.error,
                onRetry: () {
                  configProvider.loadConfiguration(forceRefresh: true);
                },
              ),
            );
          }
          
          // Show main content
          return Stack(
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
      );
        },
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
              if (_currentPage == 1) {
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
                Text(
                  _currentPage == 0 ? 'Configurar Serviço' : 'Agendar Horário',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  _currentPage == 0 ? 'Personalize sua limpeza' : 'Escolha data e hora',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Help button
          Container(
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
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
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
              return Transform.scale(
                scale: 0.8 + (0.2 * _pageTransitionAnimation.value),
                child: Opacity(
                  opacity: _pageTransitionAnimation.value,
                  child: _buildDateSection(),
                ),
              );
            },
          ),
          
          // Time Selection Section
          AnimatedBuilder(
            animation: _pageTransitionAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - _pageTransitionAnimation.value)),
                child: Opacity(
                  opacity: _pageTransitionAnimation.value,
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
          Consumer<CleaningConfigProvider>(
            builder: (context, configProvider, child) {
              if (!configProvider.hasConfig) {
                return Row(
                  children: [
                    _buildResidenceOption('studio', 'Studio', Icons.single_bed, '...'),
                    const SizedBox(width: 12),
                    _buildResidenceOption('apartment', 'Apto', Icons.apartment, '...'),
                    const SizedBox(width: 12),
                    _buildResidenceOption('house', 'Casa', Icons.house, '...'),
                  ],
                );
              }
              
              return Row(
                children: [
                  _buildResidenceOption(
                    'studio', 
                    'Studio', 
                    Icons.single_bed, 
                    'R\$ ${configProvider.getBasePrice('studio').toStringAsFixed(0)}'
                  ),
                  const SizedBox(width: 12),
                  _buildResidenceOption(
                    'apartment', 
                    'Apto', 
                    Icons.apartment, 
                    'R\$ ${configProvider.getBasePrice('apartment').toStringAsFixed(0)}'
                  ),
                  const SizedBox(width: 12),
                  _buildResidenceOption(
                    'house', 
                    'Casa', 
                    Icons.house, 
                    'R\$ ${configProvider.getBasePrice('house').toStringAsFixed(0)}'
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
            
            // Adjust rooms and bathrooms based on residence type and limits
            if (_configProvider.hasConfig) {
              // For studio, typically start with minimum rooms
              if (value == 'studio') {
                _rooms = _configProvider.getMinRooms();
                _bathrooms = _configProvider.getMinBathrooms();
              }
              // Ensure current values are within limits
              _rooms = _rooms.clamp(_configProvider.getMinRooms(), _configProvider.getMaxRooms());
              _bathrooms = _bathrooms.clamp(_configProvider.getMinBathrooms(), _configProvider.getMaxBathrooms());
            }
            
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
          Consumer<CleaningConfigProvider>(
            builder: (context, configProvider, child) {
              if (!configProvider.hasConfig) {
                return _buildCounterRow(
                  icon: Icons.weekend,
                  label: 'Cômodos',
                  value: _rooms,
                  color: Colors.indigo,
                  onDecrease: null,
                  onIncrease: null,
                );
              }
              
              final minRooms = configProvider.getMinRooms();
              final maxRooms = configProvider.getMaxRooms();
              
              return _buildCounterRow(
                icon: Icons.weekend,
                label: 'Cômodos',
                value: _rooms,
                color: Colors.indigo,
                onDecrease: _rooms > minRooms ? () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _rooms--;
                    _calculatePrice();
                  });
                } : null,
                onIncrease: _rooms < maxRooms ? () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _rooms++;
                    _calculatePrice();
                  });
                } : null,
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Bathroom counter
          Consumer<CleaningConfigProvider>(
            builder: (context, configProvider, child) {
              if (!configProvider.hasConfig) {
                return _buildCounterRow(
                  icon: Icons.bathtub,
                  label: 'Banheiros',
                  value: _bathrooms,
                  color: Colors.purple,
                  onDecrease: null,
                  onIncrease: null,
                );
              }
              
              final minBathrooms = configProvider.getMinBathrooms();
              final maxBathrooms = configProvider.getMaxBathrooms();
              
              return _buildCounterRow(
                icon: Icons.bathtub,
                label: 'Banheiros',
                value: _bathrooms,
                color: Colors.purple,
                onDecrease: _bathrooms > minBathrooms ? () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _bathrooms--;
                    _calculatePrice();
                  });
                } : null,
                onIncrease: _bathrooms < maxBathrooms ? () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _bathrooms++;
                    _calculatePrice();
                  });
                } : null,
              );
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
    VoidCallback? onIncrease,
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
                      color: onIncrease != null 
                          ? AppColors.primaryGreen
                          : const Color(0xFFCED4DA),
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
          _buildExtraOption(
            icon: Icons.cleaning_services,
            label: 'Produtos inclusos',
            description: 'Fornecemos todos os produtos de limpeza profissionais',
            price: '+ R\$ 40',
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
            price: '+ R\$ 25',
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
    final canContinue = _currentPage == 0 || (_selectedDate != null && _selectedTime != null);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.98),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Price and Time section with animation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGreen.withOpacity(0.1),
                                AppColors.primaryGreen.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withOpacity(0.1),
                                Colors.blue.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 10,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatEstimatedTime(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue[700],
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_includeProducts || _includePets) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${(_includeProducts ? 1 : 0) + (_includePets ? 1 : 0)} extra${((_includeProducts ? 1 : 0) + (_includePets ? 1 : 0)) > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    AnimatedBuilder(
                      animation: _priceAnimation,
                      builder: (context, child) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'R\$',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _priceAnimation.value.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryGreen,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              ',00',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryGreen.withOpacity(0.7),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // CTA Button with pulse animation
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: canContinue ? _pulseAnimation.value : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: canContinue
                            ? LinearGradient(
                                colors: [
                                  AppColors.primaryGreen,
                                  AppColors.primaryGreen.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: canContinue ? null : const Color(0xFFE8ECEF),
                        boxShadow: canContinue
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ]
                            : [],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: canContinue ? () {
                            HapticFeedback.mediumImpact();
                            if (_currentPage == 0) {
                              _goToNextPage();
                            } else {
                              _confirmSchedule();
                            }
                          } : null,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            child: Row(
                              children: [
                                Text(
                                  _currentPage == 0 ? 'Continuar' : 'Confirmar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: canContinue 
                                        ? Colors.white
                                        : const Color(0xFF74788D),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: canContinue 
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    _currentPage == 0 ? Icons.arrow_forward : Icons.check,
                                    size: 16,
                                    color: canContinue 
                                        ? Colors.white
                                        : const Color(0xFF74788D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
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

  void _confirmSchedule() {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(),
    );
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.primaryGreen.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Agendamento Confirmado!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3436),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Serviço agendado para ${_selectedDate?.day}/${_selectedDate?.month} às $_selectedTime',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Valor: R\$ ${_targetPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Ver detalhes',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Concluir',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}