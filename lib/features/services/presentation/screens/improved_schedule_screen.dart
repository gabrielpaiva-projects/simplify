import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/cleaning_pricing_provider.dart';
import '../../data/models/cleaning_pricing_model.dart';
import '../../data/enums/cleaning_type.dart';
import 'payment_screen.dart';

class ImprovedScheduleScreen extends StatefulWidget {
  final String serviceTitle;
  final CleaningType cleaningType;
  
  const ImprovedScheduleScreen({
    Key? key,
    required this.serviceTitle,
    this.cleaningType = CleaningType.standard,
  }) : super(key: key);

  @override
  State<ImprovedScheduleScreen> createState() => _ImprovedScheduleScreenState();
}

class _ImprovedScheduleScreenState extends State<ImprovedScheduleScreen>
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
  late AnimationController _calendarController;
  
  // Animations
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _footerSlideAnimation;
  late Animation<double> _priceAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _pageTransitionAnimation;
  late Animation<double> _calendarAnimation;
  
  // Staggered animations for cards
  final List<AnimationController> _cardAnimationControllers = [];
  final List<Animation<double>> _cardAnimations = [];
  
  // Page Controller
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
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
  int _estimatedTimeInMinutes = 120;
  
  final ScrollController _scrollController = ScrollController();
  
  // Calendar view
  late DateTime _focusedMonth;
  late List<DateTime> _availableDates;
  
  // Time slots with availability
  final Map<String, List<TimeSlot>> _timeSlots = {
    'morning': [
      TimeSlot('07:00', true),
      TimeSlot('08:00', true),
      TimeSlot('09:00', true),
      TimeSlot('10:00', false),
      TimeSlot('11:00', true),
    ],
    'afternoon': [
      TimeSlot('12:00', true),
      TimeSlot('13:00', true),
      TimeSlot('14:00', true),
      TimeSlot('15:00', false),
      TimeSlot('16:00', true),
      TimeSlot('17:00', true),
    ],
    'evening': [
      TimeSlot('18:00', true),
      TimeSlot('19:00', true),
      TimeSlot('20:00', false),
      TimeSlot('21:00', true),
    ],
  };

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _initializeDates();
    _initializeAnimations();
    
    _pricingProvider = CleaningPricingProvider(
      initialType: widget.cleaningType,
    );
    _pricingProvider.addListener(_onPricingDataChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPricingData();
    });
  }

  void _initializeDates() {
    _availableDates = List.generate(
      30,
      (index) => DateTime.now().add(Duration(days: index)),
    );
  }

  void _initializeAnimations() {
    // Header animation
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );
    
    // Card animation
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );
    
    // Footer animation
    _footerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _footerSlideAnimation = CurvedAnimation(
      parent: _footerController,
      curve: Curves.easeOutCubic,
    );
    
    // Price animation
    _priceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _priceAnimation = Tween<double>(
      begin: 0,
      end: _targetPrice,
    ).animate(CurvedAnimation(
      parent: _priceController,
      curve: Curves.easeInOut,
    ));
    
    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
    
    // Page transition animation
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pageTransitionAnimation = CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    );
    
    // Calendar animation
    _calendarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _calendarAnimation = CurvedAnimation(
      parent: _calendarController,
      curve: Curves.easeOutBack,
    );
    
    // Initialize staggered card animations
    for (int i = 0; i < 3; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + (i * 100)),
      );
      _cardAnimationControllers.add(controller);
      _cardAnimations.add(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ));
    }
    
    // Start initial animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _headerController.forward();
      _footerController.forward();
      for (final controller in _cardAnimationControllers) {
        controller.forward();
      }
    });
  }

  void _onPricingDataChanged() {
    if (_pricingProvider.hasData) {
      _calculatePrice();
    }
  }

  Future<void> _loadPricingData() async {
    await _pricingProvider.loadPricingData(type: widget.cleaningType);
    if (mounted) {
      _calculatePrice();
    }
  }

  void _calculatePrice() {
    if (!_pricingProvider.hasData) return;
    
    final basePrice = _pricingProvider.getBasePrice(_selectedResidence);
    final roomPrice = _pricingProvider.getRoomPrice(_rooms);
    final bathroomPrice = _pricingProvider.getBathroomPrice(_bathrooms);
    final productsPrice = _includeProducts ? _pricingProvider.getProductsPrice() : 0;
    final petsPrice = _includePets ? _pricingProvider.getPetsPrice() : 0;
    
    final newPrice = basePrice + roomPrice + bathroomPrice + productsPrice + petsPrice;
    
    setState(() {
      _targetPrice = newPrice;
      _estimatedTimeInMinutes = _calculateEstimatedTime();
    });
    
    _animatePrice(newPrice);
  }

  int _calculateEstimatedTime() {
    int baseTime = 90;
    baseTime += _rooms * 20;
    baseTime += _bathrooms * 25;
    if (_includePets) baseTime += 15;
    if (_selectedResidence == 'house') baseTime += 30;
    return baseTime;
  }

  void _animatePrice(double newPrice) {
    _priceController.stop();
    _priceAnimation = Tween<double>(
      begin: _currentPrice,
      end: newPrice,
    ).animate(CurvedAnimation(
      parent: _priceController,
      curve: Curves.easeInOut,
    ));
    _priceController.forward(from: 0).then((_) {
      _currentPrice = newPrice;
    });
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    _pageTransitionController.forward();
    _calendarController.forward();
  }

  void _goToPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    _pageTransitionController.reverse();
    _calendarController.reverse();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardController.dispose();
    _footerController.dispose();
    _priceController.dispose();
    _pulseController.dispose();
    _pageTransitionController.dispose();
    _calendarController.dispose();
    for (final controller in _cardAnimationControllers) {
      controller.dispose();
    }
    _pageController.dispose();
    _scrollController.dispose();
    _pricingProvider.removeListener(_onPricingDataChanged);
    _pricingProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryGreen.withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildModernHeader(),
                _buildProgressIndicator(),
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
                      _buildServiceConfigurationPage(),
                      _buildImprovedDateTimePage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Modern footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _footerSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 100 * (1 - _footerSlideAnimation.value)),
                  child: _buildModernFooter(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _headerAnimation.value),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: _goToPreviousPage,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.serviceTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentPage == 0 
                              ? 'Configure seu serviço'
                              : 'Escolha data e horário',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _currentPage >= index
                      ? AppColors.primaryGreen
                      : AppColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
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
          _buildAnimatedCard(0, _buildResidenceSection()),
          _buildAnimatedCard(1, _buildRoomDetailsSection()),
          _buildAnimatedCard(2, _buildExtrasSection()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildImprovedDateTimePage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Modern Calendar View
          AnimatedBuilder(
            animation: _calendarAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.9 + (0.1 * _calendarAnimation.value),
                child: Opacity(
                  opacity: _calendarAnimation.value,
                  child: _buildModernCalendar(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Enhanced Time Selection
          AnimatedBuilder(
            animation: _pageTransitionAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - _pageTransitionAnimation.value)),
                child: Opacity(
                  opacity: _pageTransitionAnimation.value,
                  child: _buildEnhancedTimeSelection(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildModernCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple,
                          Colors.deepPurple.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecione a Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      Text(
                        '${_getMonthName(_focusedMonth)} ${_focusedMonth.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month - 1,
                        );
                      });
                    },
                    icon: Icon(
                      Icons.chevron_left,
                      color: Colors.grey[600],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month + 1,
                        );
                      });
                    },
                    icon: Icon(
                      Icons.chevron_right,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                .map((day) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          
          const SizedBox(height: 12),
          
          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = lastDay.day;
    
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    List<Widget> dayWidgets = [];
    
    // Add empty spaces for days before month starts
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }
    
    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isToday = date.year == todayDate.year && 
                      date.month == todayDate.month && 
                      date.day == todayDate.day;
      final isSelected = _selectedDate != null &&
                        date.year == _selectedDate!.year &&
                        date.month == _selectedDate!.month &&
                        date.day == _selectedDate!.day;
      final isPast = date.isBefore(todayDate);
      final isAvailable = !isPast && _isDateAvailable(date);
      
      dayWidgets.add(
        GestureDetector(
          onTap: isAvailable ? () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedDate = date;
            });
          } : null,
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(2),
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
                  : isToday 
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : isAvailable 
                          ? Colors.transparent
                          : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? AppColors.primaryGreen
                    : isToday 
                        ? AppColors.primaryGreen.withOpacity(0.3)
                        : Colors.transparent,
                width: isToday ? 2 : 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected 
                          ? Colors.white
                          : isPast 
                              ? Colors.grey[400]
                              : const Color(0xFF2D3436),
                    ),
                  ),
                  if (isAvailable && !isSelected && !isPast)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: dayWidgets,
    );
  }

  Widget _buildEnhancedTimeSelection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyan,
                      Colors.cyan.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Escolha o Horário',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Time period tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTimePeriodTab('Manhã', Icons.wb_sunny, 'morning'),
                _buildTimePeriodTab('Tarde', Icons.wb_cloudy, 'afternoon'),
                _buildTimePeriodTab('Noite', Icons.nightlight, 'evening'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Time slots grid
          _buildTimeSlotGrid(),
          
          // Quick time suggestion
          if (_selectedDate != null && _isWeekend(_selectedDate!))
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Final de semana! Que tal agendar pela manhã para aproveitar o dia?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _selectedPeriod = 'morning';
  
  Widget _buildTimePeriodTab(String label, IconData icon, String period) {
    final isSelected = _selectedPeriod == period;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected 
                    ? AppColors.primaryGreen
                    : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? AppColors.primaryGreen
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    final slots = _timeSlots[_selectedPeriod] ?? [];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = _selectedTime == slot.time;
        
        return GestureDetector(
          onTap: slot.isAvailable ? () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedTime = slot.time;
            });
          } : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
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
                  : slot.isAvailable 
                      ? const Color(0xFFF8FAFB)
                      : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? AppColors.primaryGreen
                    : slot.isAvailable 
                        ? const Color(0xFFE8ECEF)
                        : const Color(0xFFE8ECEF),
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slot.time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected 
                          ? Colors.white
                          : slot.isAvailable 
                              ? const Color(0xFF2D3436)
                              : const Color(0xFFCED4DA),
                    ),
                  ),
                  if (!slot.isAvailable)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 10,
                        color: Colors.red[400],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
          
          Row(
            children: [
              _buildResidenceOption(
                'apartment',
                'Apartamento',
                Icons.apartment,
              ),
              const SizedBox(width: 12),
              _buildResidenceOption(
                'house',
                'Casa',
                Icons.house,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResidenceOption(String value, String label, IconData icon) {
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.1),
                      AppColors.primaryGreen.withOpacity(0.05),
                    ],
                  )
                : null,
            color: isSelected ? null : const Color(0xFFF8FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primaryGreen
                  : const Color(0xFFE8ECEF),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected 
                    ? AppColors.primaryGreen
                    : Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? AppColors.primaryGreen
                      : const Color(0xFF2D3436),
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
                  Icons.meeting_room,
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
          
          _buildCounterRow(
            'Quartos',
            Icons.bed,
            _rooms,
            (value) {
              setState(() {
                _rooms = value;
                _calculatePrice();
              });
            },
          ),
          const SizedBox(height: 16),
          _buildCounterRow(
            'Banheiros',
            Icons.bathroom,
            _bathrooms,
            (value) {
              setState(() {
                _bathrooms = value;
                _calculatePrice();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow(
    String label,
    IconData icon,
    int value,
    Function(int) onChanged,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: value > 1 ? () {
                  HapticFeedback.lightImpact();
                  onChanged(value - 1);
                } : null,
                icon: Icon(
                  Icons.remove,
                  size: 18,
                  color: value > 1 
                      ? AppColors.primaryGreen
                      : Colors.grey[400],
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ),
              IconButton(
                onPressed: value < 10 ? () {
                  HapticFeedback.lightImpact();
                  onChanged(value + 1);
                } : null,
                icon: Icon(
                  Icons.add,
                  size: 18,
                  color: value < 10 
                      ? AppColors.primaryGreen
                      : Colors.grey[400],
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
                    price: '+ R\$ ${provider.getProductsPrice().toStringAsFixed(0)}',
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
                    price: '+ R\$ ${provider.getPetsPrice().toStringAsFixed(0)}',
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
                              _navigateToPayment();
                            }
                          } : null,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            child: Row(
                              children: [
                                Text(
                                  _currentPage == 0 ? 'Continuar' : 'Ir para Pagamento',
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
                                    _currentPage == 0 ? Icons.arrow_forward : Icons.payment,
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

  void _navigateToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          serviceTitle: widget.serviceTitle,
          totalAmount: _targetPrice,
          selectedDate: _selectedDate!,
          selectedTime: _selectedTime!,
          serviceDetails: {
            'residence': _selectedResidence,
            'rooms': _rooms,
            'bathrooms': _bathrooms,
            'includeProducts': _includeProducts,
            'includePets': _includePets,
            'estimatedTime': _estimatedTimeInMinutes,
          },
        ),
      ),
    );
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

  bool _isDateAvailable(DateTime date) {
    // Mock availability logic
    return !date.isBefore(DateTime.now()) && 
           date.weekday != DateTime.sunday;
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || 
           date.weekday == DateTime.sunday;
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[date.month - 1];
  }
}

class TimeSlot {
  final String time;
  final bool isAvailable;

  TimeSlot(this.time, this.isAvailable);
}