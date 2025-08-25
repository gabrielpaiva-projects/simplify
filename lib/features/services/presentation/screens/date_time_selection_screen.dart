import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  final Function(DateTime date, String time) onDateTimeSelected;
  final DateTime? initialDate;
  final String? initialTime;
  
  const DateTimeSelectionScreen({
    Key? key,
    required this.onDateTimeSelected,
    this.initialDate,
    this.initialTime,
  }) : super(key: key);

  @override
  State<DateTimeSelectionScreen> createState() => _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _calendarController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _calendarAnimation;
  
  // Selected values
  DateTime? _selectedDate;
  String? _selectedTime;
  int _selectedMonth;
  int _selectedYear;
  
  // Calendar data
  late List<DateTime> _calendarDays;
  final List<String> _weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
  final List<String> _monthNames = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  
  // Time slots with availability
  final Map<String, List<TimeSlot>> _timeSlots = {
    'Manhã': [
      TimeSlot('08:00', true),
      TimeSlot('09:00', true),
      TimeSlot('10:00', true),
      TimeSlot('11:00', false),
    ],
    'Tarde': [
      TimeSlot('12:00', true),
      TimeSlot('13:00', true),
      TimeSlot('14:00', true),
      TimeSlot('15:00', true),
      TimeSlot('16:00', false),
      TimeSlot('17:00', true),
    ],
    'Noite': [
      TimeSlot('18:00', true),
      TimeSlot('19:00', true),
      TimeSlot('20:00', true),
    ],
  };
  
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
    
    _generateCalendarDays();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
    
    // Calendar animation
    _calendarController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _calendarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _calendarController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _calendarController.forward();
  }
  
  void _generateCalendarDays() {
    final firstDay = DateTime(_selectedYear, _selectedMonth, 1);
    final lastDay = DateTime(_selectedYear, _selectedMonth + 1, 0);
    
    _calendarDays = [];
    
    // Add empty days for alignment
    for (int i = 0; i < firstDay.weekday % 7; i++) {
      _calendarDays.add(DateTime(0));
    }
    
    // Add all days of the month
    for (int i = 1; i <= lastDay.day; i++) {
      _calendarDays.add(DateTime(_selectedYear, _selectedMonth, i));
    }
  }
  
  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth += delta;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear--;
      }
      _generateCalendarDays();
    });
    
    // Restart calendar animation
    _calendarController.reset();
    _calendarController.forward();
  }
  
  bool _isDateAvailable(DateTime date) {
    if (date.year == 0) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    
    // Only allow dates from today onwards
    if (checkDate.isBefore(today)) return false;
    
    // Don't allow dates more than 30 days in the future
    if (checkDate.isAfter(today.add(const Duration(days: 30)))) return false;
    
    // Don't allow Sundays
    if (date.weekday == 7) return false;
    
    return true;
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _calendarController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildCalendarSection(),
                    _buildTimeSelectionSection(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Escolha a Data e Hora',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecione o melhor momento para sua limpeza',
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
    );
  }
  
  Widget _buildCalendarSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMonthSelector(),
              const SizedBox(height: 20),
              _buildWeekDaysHeader(),
              const SizedBox(height: 10),
              _buildCalendarGrid(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _changeMonth(-1);
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.chevron_left,
              color: AppColors.primary,
            ),
          ),
        ),
        Text(
          '${_monthNames[_selectedMonth - 1]} $_selectedYear',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _changeMonth(1);
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.chevron_right,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeekDaysHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _weekDays.map((day) {
        final isWeekend = day == 'D' || day == 'S' && _weekDays.indexOf(day) == 6;
        return Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isWeekend ? Colors.red[400] : Colors.grey[700],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildCalendarGrid() {
    return AnimatedBuilder(
      animation: _calendarAnimation,
      builder: (context, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _calendarDays.length,
          itemBuilder: (context, index) {
            final date = _calendarDays[index];
            if (date.year == 0) {
              return const SizedBox.shrink();
            }
            
            final isAvailable = _isDateAvailable(date);
            final isSelected = _selectedDate != null &&
                date.day == _selectedDate!.day &&
                date.month == _selectedDate!.month &&
                date.year == _selectedDate!.year;
            final isToday = date.day == DateTime.now().day &&
                date.month == DateTime.now().month &&
                date.year == DateTime.now().year;
            
            return Transform.scale(
              scale: _calendarAnimation.value,
              child: GestureDetector(
                onTap: isAvailable ? () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedDate = date;
                  });
                } : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.primary.withOpacity(0.1)
                            : isAvailable
                                ? Colors.grey[50]
                                : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isToday && !isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isToday || isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : !isAvailable
                                ? Colors.grey[400]
                                : isToday
                                    ? AppColors.primary
                                    : Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildTimeSelectionSection() {
    if (_selectedDate == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Horários disponíveis para ${_formatDate(_selectedDate!)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ..._timeSlots.entries.map((entry) => _buildTimeSlotSection(
              entry.key,
              entry.value,
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimeSlotSection(String period, List<TimeSlot> slots) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getPeriodIcon(period),
                size: 20,
                color: _getPeriodColor(period),
              ),
              const SizedBox(width: 8),
              Text(
                period,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots.map((slot) => _buildTimeSlot(slot)).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeSlot(TimeSlot slot) {
    final isSelected = _selectedTime == slot.time;
    final isAvailable = slot.isAvailable;
    
    return GestureDetector(
      onTap: isAvailable ? () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedTime = slot.time;
        });
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 75,
        height: 45,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !isSelected
              ? isAvailable
                  ? Colors.grey[100]
                  : Colors.grey[200]
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isAvailable
                    ? Colors.grey[300]!
                    : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            slot.time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : !isAvailable
                      ? Colors.grey[400]
                      : Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFooter() {
    final canContinue = _selectedDate != null && _selectedTime != null;
    
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
        child: Column(
          children: [
            if (_selectedDate != null && _selectedTime != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Agendado para ${_formatDate(_selectedDate!)} às $_selectedTime',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: canContinue ? () {
                HapticFeedback.mediumImpact();
                widget.onDateTimeSelected(_selectedDate!, _selectedTime!);
                Navigator.pop(context);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: canContinue ? 4 : 0,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    canContinue ? 'Confirmar Data e Hora' : 'Selecione Data e Hora',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (canContinue) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getPeriodIcon(String period) {
    switch (period) {
      case 'Manhã':
        return Icons.wb_sunny_outlined;
      case 'Tarde':
        return Icons.wb_sunny;
      case 'Noite':
        return Icons.nightlight_outlined;
      default:
        return Icons.schedule;
    }
  }
  
  Color _getPeriodColor(String period) {
    switch (period) {
      case 'Manhã':
        return Colors.orange[600]!;
      case 'Tarde':
        return Colors.amber[700]!;
      case 'Noite':
        return Colors.indigo[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return '${date.day} de ${months[date.month - 1]}';
  }
}

class TimeSlot {
  final String time;
  final bool isAvailable;
  
  TimeSlot(this.time, this.isAvailable);
}