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
  late Animation<double> _slideAnimation;
  late String _orderNumber;
  
  @override
  void initState() {
    super.initState();
    _orderNumber = _generateOrderNumber();
    _initializeAnimations();
  }
  
  String _generateOrderNumber() {
    final date = widget.selectedDate;
    final time = widget.selectedTime.replaceAll(':', '');
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}$time';
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<double>(
      begin: 20,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  // Minimal Header
                  _buildHeader(),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 48),
                            
                            // Success Icon
                            _buildSuccessIcon(),
                            
                            const SizedBox(height: 40),
                            
                            // Main Title
                            _buildTitle(),
                            
                            const SizedBox(height: 48),
                            
                            // Status Section
                            _buildStatusSection(),
                            
                            const SizedBox(height: 40),
                            
                            // Details Section
                            _buildDetailsSection(),
                            
                            const SizedBox(height: 40),
                            
                            // Info Section
                            _buildInfoSection(),
                            
                            const SizedBox(height: 40),
                            
                            // Guarantee Section
                            _buildGuaranteeSection(),
                            
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomSheet: _buildBottomSheet(),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '#$_orderNumber',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                size: 24,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessIcon() {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          size: 40,
          color: const Color(0xFF2E7D32),
        ),
      ),
    );
  }
  
  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pagamento confirmado',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Estamos procurando o melhor profissional para você.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search,
              size: 20,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buscando profissional',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Você receberá as informações em até 24h',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange[800],
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
  
  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DETALHES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildDetailItem(
          label: 'Serviço',
          value: widget.serviceTitle,
        ),
        
        _buildDivider(),
        
        _buildDetailItem(
          label: 'Data',
          value: _formatDate(widget.selectedDate),
        ),
        
        _buildDivider(),
        
        _buildDetailItem(
          label: 'Horário',
          value: widget.selectedTime,
        ),
        
        _buildDivider(),
        
        _buildDetailItem(
          label: 'Valor pago',
          value: _formatCurrency(widget.totalAmount),
          isHighlighted: true,
        ),
        
        _buildDivider(),
        
        _buildDetailItem(
          label: 'Forma de pagamento',
          value: widget.paymentMethod == 'pix' ? 'PIX' : 'Cartão de crédito',
        ),
      ],
    );
  }
  
  Widget _buildDetailItem({
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 16 : 14,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
              color: isHighlighted ? Colors.black87 : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
    );
  }
  
  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'O que acontece agora?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoStep('1. Estamos selecionando o profissional ideal'),
          const SizedBox(height: 8),
          _buildInfoStep('2. Você receberá nome e contato do profissional'),
          const SizedBox(height: 8),
          _buildInfoStep('3. O profissional confirmará o horário com você'),
        ],
      ),
    );
  }
  
  Widget _buildInfoStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 26),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
          height: 1.4,
        ),
      ),
    );
  }
  
  Widget _buildGuaranteeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF4CAF50),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 24,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Se não encontrarmos um profissional em 24h, seu dinheiro será devolvido.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Voltar ao início',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
  
  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}