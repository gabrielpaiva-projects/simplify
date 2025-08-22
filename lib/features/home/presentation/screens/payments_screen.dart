import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/payment_model.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Este mês';
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  // Mock data - substituir por dados reais do Firebase
  final List<PaymentModel> _mockPayments = [
    PaymentModel(
      id: '1',
      professionalId: 'prof123',
      appointmentId: 'apt1',
      clientId: 'client1',
      clientName: 'Maria Santos',
      serviceName: 'Limpeza Residencial',
      amount: 150.00,
      serviceFee: 15.00,
      netAmount: 135.00,
      status: PaymentStatus.pending,
      paymentMethod: PaymentMethod.pix,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    PaymentModel(
      id: '2',
      professionalId: 'prof123',
      appointmentId: 'apt2',
      clientId: 'client2',
      clientName: 'João Silva',
      serviceName: 'Instalação de Ar Condicionado',
      amount: 350.00,
      serviceFee: 35.00,
      netAmount: 315.00,
      status: PaymentStatus.paid,
      paymentMethod: PaymentMethod.creditCard,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      paidDate: DateTime.now().subtract(const Duration(days: 1)),
      transactionId: 'TRX123456',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PaymentModel(
      id: '3',
      professionalId: 'prof123',
      appointmentId: 'apt3',
      clientId: 'client3',
      clientName: 'Ana Paula',
      serviceName: 'Manutenção Elétrica',
      amount: 200.00,
      serviceFee: 20.00,
      netAmount: 180.00,
      status: PaymentStatus.pending,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PaymentModel(
      id: '4',
      professionalId: 'prof123',
      appointmentId: 'apt4',
      clientId: 'client4',
      clientName: 'Carlos Oliveira',
      serviceName: 'Pintura Residencial',
      amount: 800.00,
      serviceFee: 80.00,
      netAmount: 720.00,
      status: PaymentStatus.paid,
      paymentMethod: PaymentMethod.bankTransfer,
      dueDate: DateTime.now().subtract(const Duration(days: 7)),
      paidDate: DateTime.now().subtract(const Duration(days: 5)),
      transactionId: 'TRX789012',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        elevation: 0,
        title: const Text(
          'Financeiro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            color: const Color(0xFF2A2A2A),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Hoje',
                child: Text('Hoje', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'Esta semana',
                child: Text('Esta semana', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'Este mês',
                child: Text('Este mês', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'Último mês',
                child: Text('Último mês', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              // TODO: Implementar exportação de relatório
            },
            icon: const Icon(Icons.download, color: Colors.white),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4A90E2),
          labelColor: const Color(0xFF4A90E2),
          unselectedLabelColor: Colors.grey[500],
          tabs: const [
            Tab(text: 'A Receber'),
            Tab(text: 'Recebidos'),
            Tab(text: 'Resumo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildPaidTab(),
          _buildSummaryTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    final pendingPayments = _mockPayments
        .where((payment) => payment.isPending)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    if (pendingPayments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.payments_outlined,
        title: 'Nenhum valor a receber',
        subtitle: 'Todos os pagamentos estão em dia',
      );
    }

    final totalPending = pendingPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.calculatedNetAmount,
    );

    return Column(
      children: [
        // Card de resumo
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF9800),
                const Color(0xFFF57C00),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total a Receber',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedPeriod,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _currencyFormat.format(totalPending),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${pendingPayments.length} pagamento${pendingPayments.length > 1 ? 's' : ''} pendente${pendingPayments.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Lista de pagamentos pendentes
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: pendingPayments.length,
            itemBuilder: (context, index) {
              return _buildPaymentCard(pendingPayments[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaidTab() {
    final paidPayments = _mockPayments
        .where((payment) => payment.isPaid)
        .toList()
      ..sort((a, b) => b.paidDate!.compareTo(a.paidDate!));

    if (paidPayments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'Nenhum pagamento recebido',
        subtitle: 'Os pagamentos recebidos aparecerão aqui',
      );
    }

    final totalPaid = paidPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.calculatedNetAmount,
    );

    return Column(
      children: [
        // Card de resumo
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4CAF50),
                const Color(0xFF388E3C),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Recebido',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedPeriod,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _currencyFormat.format(totalPaid),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${paidPayments.length} pagamento${paidPayments.length > 1 ? 's' : ''} recebido${paidPayments.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Lista de pagamentos recebidos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: paidPayments.length,
            itemBuilder: (context, index) {
              return _buildPaymentCard(paidPayments[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryTab() {
    final totalPending = _mockPayments
        .where((p) => p.isPending)
        .fold<double>(0, (sum, p) => sum + p.calculatedNetAmount);
    
    final totalPaid = _mockPayments
        .where((p) => p.isPaid)
        .fold<double>(0, (sum, p) => sum + p.calculatedNetAmount);
    
    final totalFees = _mockPayments
        .fold<double>(0, (sum, p) => sum + (p.serviceFee ?? 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards de resumo
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Recebido',
                  value: _currencyFormat.format(totalPaid),
                  icon: Icons.account_balance_wallet,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'A Receber',
                  value: _currencyFormat.format(totalPending),
                  icon: Icons.pending_actions,
                  color: const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Bruto',
                  value: _currencyFormat.format(totalPaid + totalPending + totalFees),
                  icon: Icons.attach_money,
                  color: const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Taxas',
                  value: _currencyFormat.format(totalFees),
                  icon: Icons.receipt_long,
                  color: const Color(0xFFF44336),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Gráfico de evolução
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Evolução Mensal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: _buildChart(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Lista de transações recentes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transações Recentes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Ver todas as transações
                },
                child: const Text(
                  'Ver todas',
                  style: TextStyle(color: Color(0xFF4A90E2)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._mockPayments.take(5).map((payment) => _buildTransactionItem(payment)),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    final isOverdue = payment.isOverdue;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withOpacity(0.3)
              : _getPaymentStatusColor(payment.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _showPaymentDetails(payment);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPaymentStatusColor(payment.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            payment.statusLabel,
                            style: TextStyle(
                              color: _getPaymentStatusColor(payment.status),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isOverdue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ATRASADO',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[500], size: 20),
                      color: const Color(0xFF2A2A2A),
                      onSelected: (value) {
                        _handlePaymentAction(value, payment);
                      },
                      itemBuilder: (context) => [
                        if (payment.isPending) ...[
                          const PopupMenuItem(
                            value: 'confirm',
                            child: Row(
                              children: [
                                Icon(Icons.check, color: Color(0xFF4CAF50), size: 18),
                                SizedBox(width: 8),
                                Text('Confirmar Recebimento', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                        const PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Ver Detalhes', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Informações do pagamento
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.clientName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            payment.serviceName,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currencyFormat.format(payment.calculatedNetAmount),
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (payment.serviceFee != null)
                          Text(
                            'Taxa: ${_currencyFormat.format(payment.serviceFee)}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Datas e método de pagamento
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      payment.isPaid
                          ? 'Pago em ${DateFormat('dd/MM/yyyy').format(payment.paidDate!)}'
                          : 'Vencimento: ${DateFormat('dd/MM/yyyy').format(payment.dueDate)}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (payment.paymentMethod != null) ...[
                      Icon(
                        _getPaymentMethodIcon(payment.paymentMethod!),
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        payment.paymentMethodLabel,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
                
                // ID da transação (se houver)
                if (payment.transactionId != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tag,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ID: ${payment.transactionId}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    // Placeholder para gráfico - implementar com fl_chart ou charts_flutter
    return Center(
      child: Text(
        'Gráfico de evolução mensal',
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(PaymentModel payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPaymentStatusColor(payment.status).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              payment.isPaid ? Icons.arrow_downward : Icons.pending,
              color: _getPaymentStatusColor(payment.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.clientName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  payment.serviceName,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _currencyFormat.format(payment.calculatedNetAmount),
            style: TextStyle(
              color: payment.isPaid ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return const Color(0xFFFF9800);
      case PaymentStatus.processing:
        return const Color(0xFF2196F3);
      case PaymentStatus.paid:
        return const Color(0xFF4CAF50);
      case PaymentStatus.failed:
        return const Color(0xFFF44336);
      case PaymentStatus.cancelled:
        return const Color(0xFF9E9E9E);
      case PaymentStatus.refunded:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.pix:
        return Icons.qr_code;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
    }
  }

  void _showPaymentDetails(PaymentModel payment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalhes do Pagamento',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Cliente', payment.clientName),
              _buildDetailRow('Serviço', payment.serviceName),
              _buildDetailRow('Valor Bruto', _currencyFormat.format(payment.amount)),
              if (payment.serviceFee != null)
                _buildDetailRow('Taxa de Serviço', _currencyFormat.format(payment.serviceFee)),
              _buildDetailRow('Valor Líquido', _currencyFormat.format(payment.calculatedNetAmount)),
              _buildDetailRow('Status', payment.statusLabel),
              if (payment.paymentMethod != null)
                _buildDetailRow('Método de Pagamento', payment.paymentMethodLabel),
              _buildDetailRow(
                'Vencimento',
                DateFormat('dd/MM/yyyy').format(payment.dueDate),
              ),
              if (payment.paidDate != null)
                _buildDetailRow(
                  'Data de Pagamento',
                  DateFormat('dd/MM/yyyy').format(payment.paidDate!),
                ),
              if (payment.transactionId != null)
                _buildDetailRow('ID da Transação', payment.transactionId!),
              const SizedBox(height: 20),
              if (payment.isPending)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Implementar confirmação de recebimento
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmar Recebimento'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _handlePaymentAction(String action, PaymentModel payment) {
    switch (action) {
      case 'confirm':
        // TODO: Implementar confirmação de recebimento
        break;
      case 'details':
        _showPaymentDetails(payment);
        break;
    }
  }
}