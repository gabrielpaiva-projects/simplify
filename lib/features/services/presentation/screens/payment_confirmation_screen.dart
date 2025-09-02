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
  late AnimationController _loadingController;
  late AnimationController _fadeController;
  late AnimationController _dotController;
  
  // Animations
  late Animation<double> _loadingAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // State
  int _currentStep = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }
  
  void _initializeAnimations() {
    // Loading animation for the search indicator
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Fade animation for content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Dot animation for loading dots
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _loadingAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutBack,
    ));
  }
  
  void _startAnimations() {
    _fadeController.forward();
    _loadingController.repeat();
    _dotController.repeat();
    
    // Simulate step progression
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentStep = 1;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _loadingController.dispose();
    _fadeController.dispose();
    _dotController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeController, _loadingController, _dotController]),
        builder: (context, child) {
          return SafeArea(
            child: Column(
              children: [
                // Minimal header
                _buildHeader(),
                
                // Main content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              
                              // Status indicator
                              _buildStatusIndicator(),
                              
                              const SizedBox(height: 40),
                              
                              // Main message
                              _buildMainMessage(),
                              
                              const SizedBox(height: 32),
                              
                              // Process timeline
                              _buildProcessTimeline(),
                              
                              const SizedBox(height: 32),
                              
                              // Service details
                              _buildServiceDetails(),
                              
                              const SizedBox(height: 24),
                              
                              // Guarantee card
                              _buildGuaranteeCard(),
                              
                              const SizedBox(height: 24),
                              
                              // FAQ section
                              _buildFAQSection(),
                              
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Bottom CTA
                _buildBottomCTA(),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            iconSize: 20,
            color: const Color(0xFF1F2937),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Pagamento Confirmado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusIndicator() {
    return Container(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating circle
          AnimatedBuilder(
            animation: _loadingController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _loadingAnimation.value * 2 * math.pi,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.blue.shade100,
                        Colors.blue.shade300,
                        Colors.blue.shade500,
                        Colors.blue.shade300,
                        Colors.blue.shade100,
                      ],
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Center content
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Icon(
              Icons.person_search_rounded,
              size: 40,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainMessage() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'ATENÇÃO: Serviço ainda não agendado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Estamos procurando o\nprofissional ideal para você',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
            height: 1.2,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Animated dots
        AnimatedBuilder(
          animation: _dotController,
          builder: (context, child) {
            final dotCount = (_dotController.value * 4).floor() % 4;
            return Text(
              'Buscando profissionais disponíveis${List.generate(dotCount, (_) => '.').join()}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildProcessTimeline() {
    final steps = [
      {
        'title': 'Pagamento processado',
        'subtitle': 'Seu pagamento foi confirmado com sucesso',
        'icon': Icons.check_circle_rounded,
        'status': 'completed',
      },
      {
        'title': 'Buscando profissional',
        'subtitle': 'Procurando o melhor profissional para seu serviço',
        'icon': Icons.search_rounded,
        'status': 'in_progress',
      },
      {
        'title': 'Confirmação do profissional',
        'subtitle': 'Você receberá os dados do profissional em até 24h',
        'icon': Icons.person_rounded,
        'status': 'pending',
      },
      {
        'title': 'Serviço agendado',
        'subtitle': 'Profissional confirmado para a data escolhida',
        'icon': Icons.calendar_month_rounded,
        'status': 'pending',
      },
    ];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status do processo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;
            
            return Column(
              children: [
                _buildTimelineStep(
                  title: step['title'] as String,
                  subtitle: step['subtitle'] as String,
                  icon: step['icon'] as IconData,
                  status: step['status'] as String,
                ),
                if (!isLast)
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    height: 30,
                    width: 2,
                    decoration: BoxDecoration(
                      color: step['status'] == 'completed' 
                        ? Colors.green.shade400
                        : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required IconData icon,
    required String status,
  }) {
    final isCompleted = status == 'completed';
    final isInProgress = status == 'in_progress';
    final isPending = status == 'pending';
    
    Color iconColor = Colors.grey.shade400;
    Color bgColor = Colors.grey.shade100;
    Widget statusIcon = Icon(icon, size: 20, color: Colors.grey.shade400);
    
    if (isCompleted) {
      iconColor = Colors.green.shade600;
      bgColor = Colors.green.shade50;
      statusIcon = Icon(Icons.check_rounded, size: 20, color: Colors.green.shade600);
    } else if (isInProgress) {
      iconColor = Colors.blue.shade600;
      bgColor = Colors.blue.shade50;
      statusIcon = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
        ),
      );
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: statusIcon),
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
                  fontWeight: isInProgress ? FontWeight.w700 : FontWeight.w600,
                  color: isInProgress ? const Color(0xFF1F2937) : 
                         isCompleted ? Colors.green.shade700 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildServiceDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                Icons.receipt_long_rounded,
                size: 20,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Detalhes da solicitação',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildDetailItem(
            label: 'Serviço solicitado',
            value: widget.serviceTitle,
            icon: Icons.cleaning_services_rounded,
          ),
          const SizedBox(height: 16),
          
          _buildDetailItem(
            label: 'Data desejada',
            value: _formatFullDate(widget.selectedDate),
            icon: Icons.calendar_today_rounded,
          ),
          const SizedBox(height: 16),
          
          _buildDetailItem(
            label: 'Horário preferencial',
            value: widget.selectedTime,
            icon: Icons.access_time_rounded,
          ),
          const SizedBox(height: 16),
          
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valor pago',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(widget.totalAmount),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.paymentMethod == 'pix' ? Icons.pix : Icons.credit_card,
                      size: 16,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.paymentMethod == 'pix' ? 'PIX' : 'Cartão',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildGuaranteeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade50.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: Colors.green.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% Garantido',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Se não encontrarmos um profissional em 24h, seu dinheiro será devolvido automaticamente.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFAQSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dúvidas frequentes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFAQItem(
            question: 'Quando vou saber quem é o profissional?',
            answer: 'Você receberá nome, foto e contato em até 24 horas.',
          ),
          const SizedBox(height: 12),
          
          _buildFAQItem(
            question: 'E se nenhum profissional aceitar?',
            answer: 'Seu pagamento será estornado automaticamente em 24h.',
          ),
          const SizedBox(height: 12),
          
          _buildFAQItem(
            question: 'Posso cancelar?',
            answer: 'Sim, você pode cancelar a qualquer momento antes da confirmação do profissional.',
          ),
        ],
      ),
    );
  }
  
  Widget _buildFAQItem({required String question, required String answer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.help_outline_rounded,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                question,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomCTA() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Você será notificado assim que encontrarmos o profissional',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Primary button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Entendi, voltar ao início',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Secondary button
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Show support/contact
              },
              child: Text(
                'Preciso de ajuda',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatFullDate(DateTime date) {
    final weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    
    return '${weekDays[date.weekday % 7]}, ${date.day} de ${months[date.month - 1]}';
  }
  
  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}