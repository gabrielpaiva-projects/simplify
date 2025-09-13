import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/cleaning_pricing_provider.dart';
import '../../data/models/cleaning_pricing_model.dart';
import '../../data/enums/cleaning_type.dart';
import 'payment_confirmation_screen.dart';
import 'pix_payment_screen.dart';
import '../../../../services/payment_service.dart';
import '../../../../models/payment_response.dart';
import '../../../../models/badge_payload_models.dart';
import '../../../../utils/card_validator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
  
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  // Page Controller
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // State - Property Details
  String _selectedResidence = 'apartment';
  int _rooms = 2;
  int _bathrooms = 1;
  bool _includeProducts = false;
  bool _includePets = false;
  
  // State - Schedule
  DateTime? _selectedDate;
  String? _selectedTime;
  
  // State - Payment
  String _selectedPaymentMethod = 'pix';
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  
  // Pricing
  double _basePrice = 149.0;
  double _totalPrice = 149.0;
  int _estimatedTimeInMinutes = 120;
  
  // Available dates and times
  late List<DateTime> _availableDates;
  final List<String> _morningSlots = ['08:00', '09:00', '10:00', '11:00'];
  final List<String> _afternoonSlots = ['14:00', '15:00', '16:00', '17:00'];
  final List<String> _eveningSlots = ['19:00', '20:00'];
  
  @override
  void initState() {
    super.initState();
    _initializeDates();
    _initializeAnimations();
    _calculatePrice();
  }
  
  void _initializeDates() {
    _availableDates = List.generate(
      14,
      (index) => DateTime.now().add(Duration(days: index + 1)),
    );
  }
  
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
    
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }
  
  void _calculatePrice() {
    double price = _basePrice;
    int time = 120; // Base time in minutes
    
    // Room pricing
    if (_rooms > 2) {
      price += (_rooms - 2) * 25;
      time += (_rooms - 2) * 20;
    }
    
    // Bathroom pricing
    if (_bathrooms > 1) {
      price += (_bathrooms - 1) * 20;
      time += (_bathrooms - 1) * 15;
    }
    
    // House vs Apartment
    if (_selectedResidence == 'house') {
      price += 30;
      time += 30;
    }
    
    // Additional services
    if (_includeProducts) {
      price += 35;
    }
    
    if (_includePets) {
      price += 25;
      time += 15;
    }
    
    setState(() {
      _totalPrice = price;
      _estimatedTimeInMinutes = time;
    });
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pageController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildModernHeader(),
            
            // Progress Indicator
            _buildProgressIndicator(),
            
            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPropertyDetailsStep(),
                    _buildScheduleStep(),
                    _buildPaymentStep(),
                    _buildConfirmationStep(),
                  ],
                ),
              ),
            ),
            
            // Bottom Navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: Color(0xFF1A1A1A),
                ),
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
                  widget.serviceTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStepTitle(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          // Price Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00D4AA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00D4AA).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'R\$',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF00D4AA).withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _totalPrice.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00D4AA),
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
        return 'Detalhes do imóvel';
      case 1:
        return 'Escolha data e horário';
      case 2:
        return 'Forma de pagamento';
      case 3:
        return 'Confirmação';
      default:
        return '';
    }
  }
  
  Widget _buildProgressIndicator() {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: constraints.maxWidth * ((_currentStep + 1) / 4),
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00D4AA),
                      Color(0xFF00A88A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildPropertyDetailsStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Residence Type
            _buildSectionTitle('Tipo de Imóvel', Icons.home_outlined),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildResidenceOption(
                    'apartment',
                    'Apartamento',
                    Icons.apartment_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResidenceOption(
                    'house',
                    'Casa',
                    Icons.home_rounded,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Room Count
            _buildSectionTitle('Quantidade de Cômodos', Icons.door_back_door_outlined),
            const SizedBox(height: 16),
            _buildCounterCard(
              'Quartos',
              Icons.bed_outlined,
              _rooms,
              (value) => setState(() {
                _rooms = value;
                _calculatePrice();
              }),
              min: 1,
              max: 6,
            ),
            const SizedBox(height: 12),
            _buildCounterCard(
              'Banheiros',
              Icons.bathroom_outlined,
              _bathrooms,
              (value) => setState(() {
                _bathrooms = value;
                _calculatePrice();
              }),
              min: 1,
              max: 4,
            ),
            
            const SizedBox(height: 32),
            
            // Additional Services
            _buildSectionTitle('Serviços Adicionais', Icons.add_circle_outline),
            const SizedBox(height: 16),
            _buildServiceOption(
              'Produtos de limpeza',
              'Incluímos todos os produtos necessários',
              Icons.cleaning_services_outlined,
              _includeProducts,
              35,
              (value) => setState(() {
                _includeProducts = value;
                _calculatePrice();
              }),
            ),
            const SizedBox(height: 12),
            _buildServiceOption(
              'Limpeza com pets',
              'Cuidado especial para casas com animais',
              Icons.pets_outlined,
              _includePets,
              25,
              (value) => setState(() {
                _includePets = value;
                _calculatePrice();
              }),
            ),
            
            const SizedBox(height: 32),
            
            // Estimated Time
            _buildEstimatedTimeCard(),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00D4AA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF00D4AA),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
  
  Widget _buildResidenceOption(String value, String label, IconData icon) {
    final isSelected = _selectedResidence == value;
    
    return GestureDetector(
      onTap: () => setState(() {
        _selectedResidence = value;
        _calculatePrice();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D4AA).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00D4AA) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? const Color(0xFF00D4AA) : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF00D4AA) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCounterCard(
    String label,
    IconData icon,
    int value,
    Function(int) onChanged, {
    int min = 0,
    int max = 10,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
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
                  onPressed: value > min
                      ? () => onChanged(value - 1)
                      : null,
                  icon: Icon(
                    Icons.remove,
                    color: value > min ? const Color(0xFF00D4AA) : Colors.grey[400],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 40),
                  child: Text(
                    value.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: value < max
                      ? () => onChanged(value + 1)
                      : null,
                  icon: Icon(
                    Icons.add,
                    color: value < max ? const Color(0xFF00D4AA) : Colors.grey[400],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildServiceOption(
    String title,
    String description,
    IconData icon,
    bool value,
    double price,
    Function(bool) onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF00D4AA).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? const Color(0xFF00D4AA) : Colors.grey[200]!,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: value 
                  ? const Color(0xFF00D4AA).withOpacity(0.1)
                  : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: value ? const Color(0xFF00D4AA) : Colors.grey[600],
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: value ? const Color(0xFF00D4AA) : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+ R\$ ${price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: value ? const Color(0xFF00D4AA) : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: value ? const Color(0xFF00D4AA) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: value ? const Color(0xFF00D4AA) : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: value
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEstimatedTimeCard() {
    final hours = _estimatedTimeInMinutes ~/ 60;
    final minutes = _estimatedTimeInMinutes % 60;
    String timeText = '';
    
    if (hours > 0 && minutes > 0) {
      timeText = '${hours}h ${minutes}min';
    } else if (hours > 0) {
      timeText = '${hours}h';
    } else {
      timeText = '${minutes}min';
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[50]!.withOpacity(0.5),
            Colors.blue[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue[100]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[600]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.access_time,
              color: Colors.blue[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tempo estimado',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScheduleStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar Section
          _buildSectionTitle('Escolha a data', Icons.calendar_today_outlined),
          const SizedBox(height: 16),
          _buildDateSelector(),
          
          const SizedBox(height: 32),
          
          // Time Section
          _buildSectionTitle('Escolha o horário', Icons.access_time),
          const SizedBox(height: 16),
          
          if (_selectedDate != null) ...[
            _buildTimeSection('Manhã', _morningSlots),
            const SizedBox(height: 16),
            _buildTimeSection('Tarde', _afternoonSlots),
            const SizedBox(height: 16),
            _buildTimeSection('Noite', _eveningSlots),
          ] else
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[600],
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Selecione uma data primeiro',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }
  
  Widget _buildDateSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _availableDates.length,
        itemBuilder: (context, index) {
          final date = _availableDates[index];
          final isSelected = _selectedDate?.day == date.day &&
              _selectedDate?.month == date.month;
          final isToday = date.day == DateTime.now().day &&
              date.month == DateTime.now().month;
          
          return GestureDetector(
            onTap: () => setState(() {
              _selectedDate = date;
              _selectedTime = null; // Reset time when date changes
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 75,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                  ? const Color(0xFF00D4AA) 
                  : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                    ? const Color(0xFF00D4AA) 
                    : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00D4AA).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'pt_BR').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM', 'pt_BR').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.orange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTimeSection(String title, List<String> times) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: times.map((time) {
            final isSelected = _selectedTime == time;
            final isAvailable = _isTimeAvailable(time);
            
            return GestureDetector(
              onTap: isAvailable
                  ? () => setState(() => _selectedTime = time)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00D4AA)
                      : isAvailable
                          ? Colors.white
                          : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00D4AA)
                        : isAvailable
                            ? Colors.grey[300]!
                            : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isAvailable
                            ? const Color(0xFF1A1A1A)
                            : Colors.grey[400],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  bool _isTimeAvailable(String time) {
    // Simulate availability check
    return true; // For now, all times are available
  }
  
  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Methods
          _buildSectionTitle('Forma de Pagamento', Icons.payment_outlined),
          const SizedBox(height: 16),
          
          // PIX Option
          _buildPaymentOption(
            'pix',
            'PIX',
            'Pagamento instantâneo',
            Icons.pix,
            Colors.teal,
          ),
          
          const SizedBox(height: 12),
          
          // Credit Card Option
          _buildPaymentOption(
            'credit_card',
            'Cartão de Crédito',
            'Parcelamento disponível',
            Icons.credit_card,
            Colors.blue,
          ),
          
          const SizedBox(height: 12),
          
          // Money Option
          _buildPaymentOption(
            'money',
            'Dinheiro',
            'Pague na hora do serviço',
            Icons.money,
            Colors.green,
          ),
          
          const SizedBox(height: 32),
          
          // Payment Details
          if (_selectedPaymentMethod == 'credit_card')
            _buildCreditCardForm()
          else if (_selectedPaymentMethod == 'pix')
            _buildPixInfo()
          else if (_selectedPaymentMethod == 'money')
            _buildMoneyInfo(),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }
  
  Widget _buildPaymentOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPaymentMethod == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCreditCardForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[50]!.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Column(
            children: [
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Número do Cartão',
                  hintText: '0000 0000 0000 0000',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cardHolderController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Nome no Cartão',
                  hintText: 'NOME COMPLETO',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryDateController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Validade',
                        hintText: 'MM/AA',
                        prefixIcon: const Icon(Icons.calendar_month),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: const Icon(Icons.lock_outline),
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
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPixInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal[50]!.withOpacity(0.5),
            Colors.teal[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal[100]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pix,
            size: 48,
            color: Colors.teal[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Pagamento via PIX',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.teal[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Após confirmar o agendamento, você receberá um código PIX para realizar o pagamento',
            style: TextStyle(
              fontSize: 14,
              color: Colors.teal[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.teal[600],
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'O código PIX tem validade de 30 minutos',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMoneyInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green[50]!.withOpacity(0.5),
            Colors.green[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.money,
            size: 48,
            color: Colors.green[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Pagamento em Dinheiro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.green[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'O pagamento será realizado diretamente com o profissional no momento do serviço',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tenha o valor exato: R\$ ${_totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Success Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00D4AA),
                  Color(0xFF00A88A),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4AA).withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 60,
            ),
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Confirme seu agendamento',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Serviço',
                  widget.serviceTitle,
                  Icons.cleaning_services_outlined,
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  'Data',
                  _selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                      : '-',
                  Icons.calendar_today_outlined,
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  'Horário',
                  _selectedTime ?? '-',
                  Icons.access_time,
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  'Local',
                  _selectedResidence == 'apartment' ? 'Apartamento' : 'Casa',
                  Icons.home_outlined,
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  'Detalhes',
                  '$_rooms quartos, $_bathrooms banheiros',
                  Icons.door_back_door_outlined,
                ),
                if (_includeProducts || _includePets) ...[
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Adicionais',
                    [
                      if (_includeProducts) 'Produtos',
                      if (_includePets) 'Pets',
                    ].join(', '),
                    Icons.add_circle_outline,
                  ),
                ],
                const Divider(height: 24),
                _buildSummaryRow(
                  'Pagamento',
                  _getPaymentMethodText(),
                  Icons.payment_outlined,
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      'R\$ ${_totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00D4AA),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
  
  String _getPaymentMethodText() {
    switch (_selectedPaymentMethod) {
      case 'pix':
        return 'PIX';
      case 'credit_card':
        return 'Cartão de Crédito';
      case 'money':
        return 'Dinheiro';
      default:
        return '-';
    }
  }
  
  Widget _buildBottomNavigation() {
    final canProceed = _canProceedToNextStep();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _currentStep--);
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Voltar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: canProceed ? _handleNextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentStep == 3 ? 'Confirmar' : 'Continuar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return true; // Property details are always valid
      case 1:
        return _selectedDate != null && _selectedTime != null;
      case 2:
        if (_selectedPaymentMethod == 'credit_card') {
          return _cardNumberController.text.length >= 16 &&
              _cardHolderController.text.isNotEmpty &&
              _expiryDateController.text.length == 5 &&
              _cvvController.text.length == 3;
        }
        return true;
      case 3:
        return true;
      default:
        return false;
    }
  }
  
  void _handleNextStep() async {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final confirmation
      if (_selectedPaymentMethod == 'pix') {
        // Generate PIX code
        final pixCode = _generatePixCode();
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PixPaymentScreen(
              pixCode: pixCode,
              amount: _totalPrice,
              serviceTitle: widget.serviceTitle,
              selectedDate: _selectedDate!,
              selectedTime: _selectedTime!,
            ),
          ),
        );
      } else {
        // Show success for other payment methods
        _showSuccessDialog();
      }
    }
  }
  
  String _generatePixCode() {
    // Generate a sample PIX code
    return '00020126330014BR.GOV.BCB.PIX0111${DateTime.now().millisecondsSinceEpoch}520400005303986540${_totalPrice.toStringAsFixed(2)}5802BR5925SIMPLIFY SERVICOS LTDA6009SAO PAULO62140510${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}6304';
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF00D4AA),
                      Color(0xFF00A88A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Agendamento Confirmado!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Seu serviço foi agendado com sucesso.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Voltar ao início',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
}

// Input Formatters
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}