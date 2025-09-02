import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
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
  
  // Animation Controllers
  late AnimationController _mainController;
  late AnimationController _checkController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _floatingController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _floatingAnimation;
  
  // Page state
  bool _showDetails = false;
  late String _orderNumber;
  
  @override
  void initState() {
    super.initState();
    // Gera um número de pedido fixo baseado nos dados do pedido
    _orderNumber = _generateOrderNumber();
    _initializeAnimations();
    _startAnimationSequence();
  }
  
  String _generateOrderNumber() {
    // Usa os dados do pedido para gerar um número único e consistente
    final dateString = '${widget.selectedDate.day}${widget.selectedDate.month}';
    final timeString = widget.selectedTime.replaceAll(':', '');
    final amountString = widget.totalAmount.toStringAsFixed(0);
    return '$dateString$timeString$amountString';
  }
  
  void _initializeAnimations() {
    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Check animation controller
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Shimmer animation controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Floating animation controller
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));
    
    // Slide animation
    _slideAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    ));
    
    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    ));
    
    // Check animation
    _checkAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOutBack,
    ));
    
    // Pulse animation
    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Shimmer animation
    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
    
    // Floating animation
    _floatingAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _mainController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _checkController.forward();
    
    await Future.delayed(const Duration(milliseconds: 600));
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
    _floatingController.repeat(reverse: true);
    
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _showDetails = true;
    });
  }
  
  @override
  void dispose() {
    _mainController.dispose();
    _checkController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _floatingController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _checkController,
          _pulseController,
          _shimmerController,
          _floatingController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Background with animated gradient
              _buildAnimatedBackground(),
              
              // Main content
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Modern header
                    _buildModernHeader(),
                    
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            
                            // Success animation
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Transform.translate(
                                offset: Offset(0, _slideAnimation.value),
                                child: _buildSuccessAnimation(),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Title and subtitle
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Transform.translate(
                                offset: Offset(0, _slideAnimation.value * 0.8),
                                child: _buildTitleSection(),
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Professional info card
                            if (_showDetails)
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween(begin: 0, end: 1),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.9 + (0.1 * value),
                                    child: Opacity(
                                      opacity: value,
                                      child: _buildProfessionalInfoCard(),
                                    ),
                                  );
                                },
                              ),
                            
                            const SizedBox(height: 24),
                            
                            // Service details card
                            if (_showDetails)
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween(begin: 0, end: 1),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: _buildServiceDetailsCard(),
                                    ),
                                  );
                                },
                              ),
                            
                            const SizedBox(height: 24),
                            
                            // Timeline steps
                            if (_showDetails)
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween(begin: 0, end: 1),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: _buildTimelineSteps(),
                                    ),
                                  );
                                },
                              ),
                            
                            const SizedBox(height: 24),
                            
                            // Refund policy card
                            if (_showDetails)
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween(begin: 0, end: 1),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: _buildRefundPolicyCard(),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom action button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomAction(),
              ),
              
              // Floating decorative elements
              ..._buildFloatingElements(),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withOpacity(0.03),
            Colors.white,
            Colors.blue.withOpacity(0.02),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
  
  List<Widget> _buildFloatingElements() {
    return [
      // Top left floating circle
      Positioned(
        top: 100,
        left: -50,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatingAnimation.value),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.1),
                      AppColors.primaryGreen.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      
      // Bottom right floating circle
      Positioned(
        bottom: 200,
        right: -60,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_floatingAnimation.value),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blue.withOpacity(0.08),
                      Colors.blue.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
  
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Order ID with better design
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.primaryGreen.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Pedido #$_orderNumber',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // Close button with better design
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessAnimation() {
    return Container(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse circles with gradient
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final delay = index * 0.2;
                final adjustedValue = (_pulseController.value - delay).clamp(0.0, 1.0);
                
                return Transform.scale(
                  scale: 1 + (adjustedValue * 0.4 * (index + 1)),
                  child: Container(
                    width: 90 - (index * 10),
                    height: 90 - (index * 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryGreen.withOpacity(0.15 - (index * 0.04)),
                          AppColors.primaryGreen.withOpacity(0.05 - (index * 0.02)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          
          // Main circle with gradient and shadow
          Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 90,
              height: 90,
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
                    color: AppColors.primaryGreen.withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Transform.scale(
                scale: _checkAnimation.value,
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Pagamento Confirmado!',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '⏳ Buscando o profissional ideal para você',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildProfessionalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          // Header with icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.blue.withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_search_rounded,
              color: Colors.blue[700],
              size: 32,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Procurando Profissional',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Estamos selecionando o melhor profissional\npara realizar seu serviço',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Info box with shimmer
          AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1.5 + _shimmerAnimation.value, 0),
                    end: Alignment(-0.5 + _shimmerAnimation.value, 0),
                    colors: [
                      const Color(0xFFF0F9FF),
                      const Color(0xFFE0F2FE),
                      const Color(0xFFF0F9FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Você receberá em até 24 horas:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Nome e foto do profissional\n• Contato direto\n• Confirmação do horário',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildServiceDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Detalhes do Serviço',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Service info grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.cleaning_services_rounded,
                  label: 'Serviço',
                  value: widget.serviceTitle,
                  iconColor: Colors.purple,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Data',
                        value: _formatDate(widget.selectedDate),
                        iconColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailRow(
                        icon: Icons.access_time_rounded,
                        label: 'Horário',
                        value: widget.selectedTime,
                        iconColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Payment info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.05),
                  AppColors.primaryGreen.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.paymentMethod == 'pix' ? Icons.pix : Icons.credit_card_rounded,
                        size: 20,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pago via ${widget.paymentMethod == 'pix' ? 'PIX' : 'Cartão'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(widget.totalAmount),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pago',
                        style: TextStyle(
                          fontSize: 12,
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
        ],
      ),
    );
  }
  
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimelineSteps() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'Próximas Etapas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          
          _buildTimelineItem(
            icon: Icons.payment_rounded,
            title: 'Pagamento processado',
            subtitle: 'Concluído com sucesso',
            isCompleted: true,
            isFirst: true,
          ),
          
          _buildTimelineItem(
            icon: Icons.person_search_rounded,
            title: 'Buscando profissional',
            subtitle: 'Em andamento...',
            isActive: true,
          ),
          
          _buildTimelineItem(
            icon: Icons.person_pin_rounded,
            title: 'Profissional designado',
            subtitle: 'Aguardando confirmação',
            isPending: true,
          ),
          
          _buildTimelineItem(
            icon: Icons.home_repair_service_rounded,
            title: 'Serviço agendado',
            subtitle: 'Profissional confirmado',
            isPending: true,
            isLast: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isCompleted = false,
    bool isActive = false,
    bool isPending = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    Color iconColor = Colors.grey[400]!;
    Color bgColor = Colors.grey[100]!;
    Color textColor = Colors.grey[600]!;
    
    if (isCompleted) {
      iconColor = AppColors.primaryGreen;
      bgColor = AppColors.primaryGreen.withOpacity(0.1);
      textColor = const Color(0xFF1A1A1A);
    } else if (isActive) {
      iconColor = Colors.blue[600]!;
      bgColor = Colors.blue.withOpacity(0.1);
      textColor = const Color(0xFF1A1A1A);
    }
    
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: isActive
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(iconColor),
                            ),
                          ),
                        )
                      : Icon(
                          isCompleted ? Icons.check_rounded : icon,
                          size: 20,
                          color: iconColor,
                        ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? AppColors.primaryGreen.withOpacity(0.3) : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
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
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildRefundPolicyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withOpacity(0.08),
            Colors.amber.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: Colors.amber[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% Garantido',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber[900],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Caso não receba as informações do profissional em 24 horas, seu pagamento será estornado automaticamente.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber[800],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary action button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Voltar ao Início',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Secondary action
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Navigate to orders/tracking
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Acompanhar meus pedidos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
    final months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    
    return '${weekDays[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}';
  }
  
  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}