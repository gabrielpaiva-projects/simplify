import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentConfirmationBottomSheet {
  static void show({
    required BuildContext context,
    required String serviceTitle,
    required double totalAmount,
    required DateTime selectedDate,
    required String selectedTime,
    required String paymentMethod,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentConfirmationContent(
        serviceTitle: serviceTitle,
        totalAmount: totalAmount,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        paymentMethod: paymentMethod,
      ),
    );
  }
}

class PaymentConfirmationContent extends StatefulWidget {
  final String serviceTitle;
  final double totalAmount;
  final DateTime selectedDate;
  final String selectedTime;
  final String paymentMethod;
  
  const PaymentConfirmationContent({
    Key? key,
    required this.serviceTitle,
    required this.totalAmount,
    required this.selectedDate,
    required this.selectedTime,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  State<PaymentConfirmationContent> createState() => _PaymentConfirmationContentState();
}

class _PaymentConfirmationContentState extends State<PaymentConfirmationContent>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _searchController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _searchAnimation;
  
  late String _orderNumber;
  
  @override
  void initState() {
    super.initState();
    _orderNumber = DateTime.now().millisecondsSinceEpoch.toString().substring(6, 12);
    _setupAnimations();
  }
  
  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _searchController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _searchAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeInOut,
    ));
    
    _slideController.forward();
    _searchController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.primaryGreen.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Pagamento Confirmado!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Pedido #$_orderNumber',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildSearchStatus(),
                    
                    const SizedBox(height: 24),
                    
                    _buildServiceSummary(),
                    
                    const SizedBox(height: 24),
                    
                    _buildNextSteps(),
                    
                    const SizedBox(height: 120), // Space for buttons
                  ],
                ),
              ),
            ),
            
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchStatus() {
    return AnimatedBuilder(
      animation: _searchController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange[50]!,
                Colors.orange[100]!.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orange[200]!,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: Colors.orange[700],
                          size: 26,
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(
                            Colors.orange[400]!.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buscando profissionais',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estamos procurando o melhor profissional para você',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Em breve retornaremos com os dados do profissional selecionado',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildServiceSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo do pedido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildSummaryRow(
            Icons.cleaning_services_rounded,
            'Serviço',
            widget.serviceTitle,
          ),
          
          _buildSummaryRow(
            Icons.calendar_today_rounded,
            'Data',
            _formatDate(widget.selectedDate),
          ),
          
          _buildSummaryRow(
            Icons.access_time_rounded,
            'Horário',
            widget.selectedTime,
          ),
          
          _buildSummaryRow(
            widget.paymentMethod == 'pix' ? Icons.pix : Icons.credit_card,
            'Pagamento',
            widget.paymentMethod == 'pix' ? 'PIX' : 'Cartão',
          ),
          
          const SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.primaryGreen.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total pago',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _formatCurrency(widget.totalAmount),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNextSteps() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.blue[700],
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Próximos passos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildStepItem('Você receberá uma notificação com os dados do profissional'),
          _buildStepItem('O profissional entrará em contato para confirmar o agendamento'),
          _buildStepItem('Tempo máximo de resposta: 24 horas'),
        ],
      ),
    );
  }
  
  Widget _buildStepItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tela de agendamentos em desenvolvimento'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.schedule_rounded),
                label: const Text(
                  'Meus Agendamentos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: BorderSide(color: AppColors.primaryGreen, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text(
                  'Voltar ao Início',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
    
    return '${weekDays[date.weekday % 7]}, ${date.day} de ${months[date.month - 1]}';
  }
  
  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class PaymentConfirmationScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PaymentConfirmationBottomSheet.show(
        context: context,
        serviceTitle: serviceTitle,
        totalAmount: totalAmount,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        paymentMethod: paymentMethod,
      );
    });
    
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}