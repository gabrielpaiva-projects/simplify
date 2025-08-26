import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  // Selected values - INICIALIZADO CORRETAMENTE
  DateTime? _selectedDate;
  String? _selectedTime;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  
  // Calendar data
  List<DateTime> _calendarDays = [];
  
  final List<String> _weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
  final List<String> _monthNames = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  
  // Time slots
  final List<String> _morningSlots = ['08:00', '09:00', '10:00', '11:00'];
  final List<String> _afternoonSlots = ['14:00', '15:00', '16:00', '17:00'];
  final List<String> _eveningSlots = ['18:00', '19:00', '20:00'];
  
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
    _generateCalendarDays();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
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
    
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
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
  }
  
  bool _isDateAvailable(DateTime date) {
    if (date.year == 0) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    
    if (checkDate.isBefore(today)) return false;
    if (checkDate.isAfter(today.add(const Duration(days: 30)))) return false;
    if (date.weekday == 7) return false; // No Sundays
    
    return true;
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
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
    return Container(
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
    );
  }
  
  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.1),
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
          icon: Icon(Icons.chevron_left, color: AppColors.primaryGreen),
        ),
        Text(
          '${_monthNames[_selectedMonth - 1]} $_selectedYear',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _changeMonth(1);
          },
          icon: Icon(Icons.chevron_right, color: AppColors.primaryGreen),
        ),
      ],
    );
  }
  
  Widget _buildWeekDaysHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _weekDays.map((day) {
        return Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildCalendarGrid() {
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
        
        return GestureDetector(
          onTap: isAvailable ? () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedDate = date;
            });
          } : null,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen
                  : isToday
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : isAvailable
                          ? Colors.grey[50]
                          : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isToday && !isSelected
                    ? AppColors.primaryGreen
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
                              ? AppColors.primaryGreen
                              : Colors.grey[800],
                ),
              ),
            ),
          ),
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
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Selecione uma data primeiro',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimePeriod('Manhã', _morningSlots, Icons.wb_sunny_outlined, Colors.orange),
          const SizedBox(height: 16),
          _buildTimePeriod('Tarde', _afternoonSlots, Icons.wb_sunny, Colors.amber),
          const SizedBox(height: 16),
          _buildTimePeriod('Noite', _eveningSlots, Icons.nightlight_outlined, Colors.indigo),
        ],
      ),
    );
  }
  
  Widget _buildTimePeriod(String period, List<String> slots, IconData icon, Color color) {
    return Container(
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
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                period,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots.map((time) => _buildTimeSlot(time)).toList(),
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
      child: Container(
        width: 75,
        height: 45,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : isAvailable
                  ? Colors.grey[100]
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            time,
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
        child: ElevatedButton(
          onPressed: canContinue ? () {
            HapticFeedback.mediumImpact();
            widget.onDateTimeSelected(_selectedDate!, _selectedTime!);
            Navigator.pop(context);
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            canContinue ? 'Confirmar Data e Hora' : 'Selecione Data e Hora',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}