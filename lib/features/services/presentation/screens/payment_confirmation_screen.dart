import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
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
    with TickerProviderStateMixin {
  
  late AnimationController _checkController;
  late AnimationController _contentController;
  late AnimationController _searchingController;
  
  late Animation<double> _checkAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _contentSlideAnimation;
  late Animation<double> _searchingAnimation;
  
  late String _orderNumber;
  
  @override
  void initState() {
    super.initState();
    _orderNumber = _generateOrderNumber();
    _initializeAnimations();
    _startAnimations();
  }
  
  String _generateOrderNumber() {
    // Gera número baseado na data e hora
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }
  
  void _initializeAnimations() {
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _searchingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _checkAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
    _contentSlideAnimation = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));
    
    _searchingAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _searchingController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _checkController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _contentController.forward();
    _searchingController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    _searchingController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A237E),
                  const Color(0xFF3949AB),
                ],
              ),
            ),
          ),
          
          // Glass morphism overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                color: Colors.white.withOpacity(0.95),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Custom Header
                _buildHeader(),
                
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    child: AnimatedBuilder(
                      animation: _contentController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _contentFadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _contentSlideAnimation.value),
                            child: Column(
                              children: [
                                const SizedBox(height: 40),
                                
                                // Success Animation
                                _buildSuccessAnimation(),
                                
                                const SizedBox(height: 32),
                                
                                // Title
                                _buildTitle(),
                                
                                const SizedBox(height: 40),
                                
                                // Search Status Card
                                _buildSearchStatusCard(),
                                
                                const SizedBox(height: 32),
                                
                                // Process Timeline
                                _buildProcessTimeline(),
                                
                                const SizedBox(height: 32),
                                
                                // Payment Details
                                _buildPaymentDetails(),
                                
                                const SizedBox(height: 32),
                                
                                // Info Cards
                                _buildInfoCards(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomCTA(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
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
                Icons.arrow_back,
                size: 20,
                color: Color(0xFF1A237E),
              ),
            ),
          ),
          
          // Order number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Pedido $_orderNumber',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessAnimation() {
    return AnimatedBuilder(
      animation: _checkController,
      builder: (context, child) {
        return Transform.scale(
          scale: _checkAnimation.value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGreen.withOpacity(0.9),
                  AppColors.primaryGreen,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Pagamento Confirmado!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A237E),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Agora vamos encontrar o profissional perfeito',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSearchStatusCard() {
    return AnimatedBuilder(
      animation: _searchingController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade50,
                Colors.orange.shade100.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orange.shade200,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Animated circles
                  Transform.scale(
                    scale: 0.8 + (_searchingAnimation.value * 0.2),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.9 + (_searchingAnimation.value * 0.1),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_search,
                        color: Colors.orange[700],
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Procurando Profissionais',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Estamos buscando os melhores profissionais\ndisponíveis na sua região',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildProcessTimeline() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acompanhe o processo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 24),
          
          _buildTimelineItem(
            icon: Icons.payment,
            title: 'Pagamento confirmado',
            time: 'Agora',
            isCompleted: true,
            isFirst: true,
          ),
          
          _buildTimelineConnector(isActive: true),
          
          _buildTimelineItem(
            icon: Icons.search,
            title: 'Buscando profissionais',
            time: 'Em andamento...',
            isActive: true,
          ),
          
          _buildTimelineConnector(isActive: false),
          
          _buildTimelineItem(
            icon: Icons.person_check,
            title: 'Profissional selecionado',
            time: 'Em até 24 horas',
            isCompleted: false,
          ),
          
          _buildTimelineConnector(isActive: false),
          
          _buildTimelineItem(
            icon: Icons.home_repair_service,
            title: 'Serviço confirmado',
            time: _formatDate(widget.selectedDate),
            isCompleted: false,
            isLast: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String time,
    bool isCompleted = false,
    bool isActive = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final color = isCompleted 
        ? AppColors.primaryGreen 
        : isActive 
            ? Colors.orange 
            : Colors.grey.shade300;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isCompleted || isActive 
                ? color.withOpacity(0.1) 
                : Colors.grey.shade50,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: isActive ? 2 : 1.5,
            ),
          ),
          child: isActive
              ? Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                )
              : Icon(
                  isCompleted ? Icons.check : icon,
                  size: 20,
                  color: color,
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
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isCompleted || isActive 
                      ? const Color(0xFF1A237E) 
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive 
                      ? Colors.orange 
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimelineConnector({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(left: 21, top: 4, bottom: 4),
      height: 30,
      width: 2,
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.primaryGreen.withOpacity(0.3) 
            : Colors.grey.shade200,
      ),
    );
  }
  
  Widget _buildPaymentDetails() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A237E).withOpacity(0.05),
            const Color(0xFF3949AB).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1A237E).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total pago',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(widget.totalAmount),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.paymentMethod == 'pix' ? 'PIX' : 'Cartão',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDetailRow('Serviço', widget.serviceTitle),
                const SizedBox(height: 12),
                _buildDetailRow('Data', _formatFullDate(widget.selectedDate)),
                const SizedBox(height: 12),
                _buildDetailRow('Horário', widget.selectedTime),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A237E),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoCards() {
    return Column(
      children: [
        // Next steps card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade700,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'O que acontece agora?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Você receberá o nome, foto e contato do profissional assim que ele aceitar o serviço.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Guarantee card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.green.shade700,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Garantia total',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Se não encontrarmos um profissional em 24h, seu pagamento será estornado automaticamente.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomCTA() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Track order
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: const Color(0xFF1A237E).withOpacity(0.2),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Acompanhar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Voltar ao início',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return '${weekDays[date.weekday % 7]}, ${date.day}/${date.month.toString().padLeft(2, '0')}';
  }
  
  String _formatFullDate(DateTime date) {
    final months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return '${date.day} de ${months[date.month - 1]}';
  }
  
  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}