import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final String serviceTitle;
  final double totalAmount;
  final DateTime selectedDate;
  final String selectedTime;
  final String paymentMethod;
  
  const PaymentConfirmationScreen({
    Key? key,
    required this.serviceTitle,
    required this.totalAmount,
    required this.selectedDate,
    required this.selectedTime,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animationController.forward();
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: SafeArea(
                child: Column(
                  children: [
                    // Simple header
                    _buildMinimalHeader(),
                    
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            
                            // Success icon - minimal
                            _buildMinimalSuccessIcon(),
                            
                            const SizedBox(height: 32),
                            
                            // Success message - clean
                            _buildCleanSuccessMessage(),
                            
                            const SizedBox(height: 40),
                            
                            // Main info card
                            _buildMainInfoCard(),
                            
                            const SizedBox(height: 16),
                            
                            // Timeline
                            _buildTimeline(),
                            
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom action
                    _buildMinimalBottomAction(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildMinimalHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMinimalSuccessIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_rounded,
        color: AppColors.primaryGreen,
        size: 32,
      ),
    );
  }
  
  Widget _buildCleanSuccessMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Agendamento confirmado',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enviamos os detalhes para seu e-mail',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainInfoCard() {
    final bookingCode = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Booking code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '#$bookingCode',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Service
          Text(
            widget.serviceTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Date and time row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoItem(Icons.calendar_today_outlined, _formatSimpleDate(widget.selectedDate)),
              Container(
                width: 1,
                height: 24,
                color: const Color(0xFFE5E7EB),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildInfoItem(Icons.access_time_outlined, widget.selectedTime),
            ],
          ),
          
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 20),
          
          // Payment info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    widget.paymentMethod == 'pix' ? Icons.pix : Icons.credit_card,
                    size: 18,
                    color: const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.paymentMethod == 'pix' ? 'PIX' : 'Cartão',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              Text(
                _formatCurrency(widget.totalAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimeline() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Próximos passos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            'Confirmação enviada',
            'Você receberá um e-mail com os detalhes',
            true,
          ),
          _buildTimelineConnector(),
          _buildTimelineItem(
            'Dia anterior',
            'Receberá um lembrete do agendamento',
            false,
          ),
          _buildTimelineConnector(),
          _buildTimelineItem(
            'No dia do serviço',
            'Profissional chegará no horário combinado',
            false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineItem(String title, String subtitle, bool completed) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: completed ? AppColors.primaryGreen : const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: completed
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9CA3AF),
                    shape: BoxShape.circle,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: completed ? const Color(0xFF111827) : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimelineConnector() {
    return Container(
      margin: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
      width: 2,
      height: 24,
      color: const Color(0xFFE5E7EB),
    );
  }
  
  Widget _buildMinimalBottomAction() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Voltar ao início',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatSimpleDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
  
  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
  
