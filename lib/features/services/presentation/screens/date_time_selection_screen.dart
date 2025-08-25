import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import 'payment_screen.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  final String serviceTitle;
  final double totalPrice;
  final Map<String, dynamic> serviceDetails;
  
  const DateTimeSelectionScreen({
    Key? key,
    required this.serviceTitle,
    required this.totalPrice,
    required this.serviceDetails,
  }) : super(key: key);

  @override
  State<DateTimeSelectionScreen> createState() => _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen>
    with TickerProviderStateMixin {
  
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  
  // Selected values
  DateTime? _selectedDate;
  String? _selectedTime;
  String _selectedPeriod = 'morning'; // morning, afternoon, evening
  
  // Available dates (next 30 days)
  late List<DateTime> _availableDates;
  
  // Time slots by period
  final Map<String, List<String>> _timeSlots = {
    'morning': ['08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30'],
    'afternoon': ['12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30'],
    'evening': ['18:00', '18:30', '19:00', '19:30', '20:00', '20:30'],
  };
  
  // Calendar view
  late DateTime _focusedMonth;
  late List<List<DateTime?>> _calendarDays;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDates();
    _generateCalendarDays();
  }
  
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }
  
  void _initializeDates() {
    final now = DateTime.now();
    _focusedMonth = now;
    _availableDates = List.generate(
      30, 
      (index) => DateTime(now.year, now.month, now.day).add(Duration(days: index))
    );
  }
  
  void _generateCalendarDays() {
    _calendarDays = [];
    
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    
    // Get the first day of the week (Sunday = 0)
    int startWeekday = firstDay.weekday % 7;
    
    // Add empty days before the first day of the month
    List<DateTime?> week = List.filled(startWeekday, null);
    
    // Add all days of the month
    for (int day = 1; day <= lastDay.day; day++) {
      week.add(DateTime(_focusedMonth.year, _focusedMonth.month, day));
      
      if (week.length == 7) {
        _calendarDays.add(week);
        week = [];
      }
    }
    
    // Add the last week if it's not empty
    if (week.isNotEmpty) {
      while (week.length < 7) {
        week.add(null);
      }
      _calendarDays.add(week);
    }
  }
  
  void _changeMonth(int direction) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + direction,
      );
      _generateCalendarDays();
    });
  }
  
  bool _isDateAvailable(DateTime date) {
    final today = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    
    // Check if date is today or in the future (within 30 days)
    if (dateOnly.isBefore(todayOnly)) return false;
    if (dateOnly.difference(todayOnly).inDays > 30) return false;
    
    return true;
  }
  
  bool _isDateSelected(DateTime date) {
    if (_selectedDate == null) return false;
    return date.year == _selectedDate!.year &&
           date.month == _selectedDate!.month &&
           date.day == _selectedDate!.day;
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.black87,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Escolha a Data e Hora',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.serviceTitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar Section
                  FadeTransition(
                    opacity: _fadeController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: _buildCalendarSection(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Time Selection Section
                  FadeTransition(
                    opacity: _fadeController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                      )),
                      child: _buildTimeSection(),
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 20,
          right: 20,
          top: 16,
        ),
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
            // Selected Info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'R\$ ${widget.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  if (_selectedDate != null && _selectedTime != null)
                    Text(
                      '${_selectedDate!.day}/${_selectedDate!.month} às $_selectedTime',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            
            // Continue Button
            ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: _scaleController,
                curve: Curves.elasticOut,
              )),
              child: ElevatedButton(
                onPressed: (_selectedDate != null && _selectedTime != null)
                    ? () {
                        HapticFeedback.mediumImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              serviceTitle: widget.serviceTitle,
                              totalPrice: widget.totalPrice,
                              serviceDetails: widget.serviceDetails,
                              selectedDate: _selectedDate!,
                              selectedTime: _selectedTime!,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: (_selectedDate != null && _selectedTime != null)
                            ? Colors.white
                            : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: (_selectedDate != null && _selectedTime != null)
                          ? Colors.white
                          : Colors.grey[500],
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
  
  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getMonthName(_focusedMonth.month)} ${_focusedMonth.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Weekday Headers
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
          
          // Calendar Days
          Column(
            children: _calendarDays.map((week) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: week.map((date) {
                    if (date == null) {
                      return const SizedBox(width: 40, height: 40);
                    }
                    
                    final isAvailable = _isDateAvailable(date);
                    final isSelected = _isDateSelected(date);
                    final isToday = date.day == DateTime.now().day &&
                                   date.month == DateTime.now().month &&
                                   date.year == DateTime.now().year;
                    
                    return GestureDetector(
                      onTap: isAvailable
                          ? () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _selectedDate = date;
                              });
                            }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : isToday
                                  ? AppColors.primaryGreen.withOpacity(0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isToday && !isSelected
                              ? Border.all(
                                  color: AppColors.primaryGreen.withOpacity(0.3),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : isAvailable
                                      ? const Color(0xFF2D3436)
                                      : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeSection() {
    if (_selectedDate == null) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Selecione uma data primeiro',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha o dia desejado no calendário acima',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escolha o Horário',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Period Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildPeriodTab(
                  'morning',
                  'Manhã',
                  Icons.wb_sunny_outlined,
                ),
                _buildPeriodTab(
                  'afternoon',
                  'Tarde',
                  Icons.wb_twilight_outlined,
                ),
                _buildPeriodTab(
                  'evening',
                  'Noite',
                  Icons.nightlight_outlined,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Time Slots Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _timeSlots[_selectedPeriod]!.length,
            itemBuilder: (context, index) {
              final time = _timeSlots[_selectedPeriod]![index];
              final isSelected = _selectedTime == time;
              
              // Simulate some slots as unavailable
              final isAvailable = index % 5 != 3; // Every 5th slot is unavailable
              
              return GestureDetector(
                onTap: isAvailable
                    ? () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedTime = time;
                        });
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : isAvailable
                            ? Colors.grey[50]
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : isAvailable
                              ? Colors.grey[300]!
                              : Colors.grey[200]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : isAvailable
                                ? const Color(0xFF2D3436)
                                : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodTab(String period, String label, IconData icon) {
    final isSelected = _selectedPeriod == period;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedPeriod = period;
            _selectedTime = null; // Reset selected time when changing period
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
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primaryGreen : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryGreen : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }
}