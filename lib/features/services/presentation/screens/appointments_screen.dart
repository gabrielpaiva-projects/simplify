import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/appointment_model.dart';
import '../../../../models/payment_pix_model.dart';
import '../../../../services/appointment_service.dart';
import '../../../../services/payment_pix_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final AppointmentService _appointmentService = AppointmentService();
  final PaymentPixService _paymentPixService = PaymentPixService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceWhite,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header customizado
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meus agendamentos',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Acompanhe seus serviços e pagamentos',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B6B6B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Segmented control custom (abas) + contadores
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _tabController.animateTo(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _tabController.index == i
                                    ? AppColors.primaryGreen.withOpacity(0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    i == 0 ? 'Pendentes' : i == 1 ? 'Próximos' : 'Histórico',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _tabController.index == i
                                          ? AppColors.primaryGreen
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _tabController.index == i
                                          ? AppColors.primaryGreen.withOpacity(0.18)
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      i == 0 ? 'PIX' : i == 1 ? 'UP' : 'HIS',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _tabController.index == i
                                            ? AppColors.primaryGreen
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Conteúdo com fundo sutil
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    const _PendingPaymentsTab(),
                    const _UpcomingAppointmentsTab(),
                    const _HistoryAppointmentsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingPaymentsTab extends StatelessWidget {
  const _PendingPaymentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentService = PaymentPixService();
    
    return StreamBuilder<List<PaymentPixModel>>(
      stream: paymentService.getPendingPixPayments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingWidget();
        }

        if (snapshot.hasError) {
          return const _ErrorWidget(message: 'Erro ao carregar pagamentos');
        }

        final List<PaymentPixModel> payments = snapshot.data ?? [];

        if (payments.isEmpty) {
          return const _EmptyWidget(
            icon: Icons.payment_outlined,
            title: 'Nenhum pagamento pendente',
            subtitle: 'Todos os seus pagamentos estão em dia',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PaymentCard(payment: payments[index]),
            );
          },
        );
      },
    );
  }
}

class _UpcomingAppointmentsTab extends StatelessWidget {
  const _UpcomingAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentService = AppointmentService();
    
    return StreamBuilder<List<AppointmentModel>>(
      stream: appointmentService.getUpcomingAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingWidget();
        }

        if (snapshot.hasError) {
          return const _ErrorWidget(message: 'Erro ao carregar agendamentos');
        }

        final List<AppointmentModel> appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return const _EmptyWidget(
            icon: Icons.calendar_today_outlined,
            title: 'Nenhum agendamento próximo',
            subtitle: 'Seus próximos serviços aparecerão aqui',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final a = appointments[index];
            final bool showHeader = index == 0 ||
              appointments[index - 1].formattedDate != a.formattedDate;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader)
                    _DateHeader(label: a.formattedDate),
                  _AppointmentCard(appointment: a),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _HistoryAppointmentsTab extends StatelessWidget {
  const _HistoryAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentService = AppointmentService();
    
    return StreamBuilder<List<AppointmentModel>>(
      stream: appointmentService.getAppointmentHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingWidget();
        }

        if (snapshot.hasError) {
          return const _ErrorWidget(message: 'Erro ao carregar histórico');
        }

        final List<AppointmentModel> appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return const _EmptyWidget(
            icon: Icons.history_outlined,
            title: 'Nenhum histórico encontrado',
            subtitle: 'Seus serviços anteriores aparecerão aqui',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final a = appointments[index];
            final bool showHeader = index == 0 ||
              appointments[index - 1].formattedDate != a.formattedDate;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader)
                    _DateHeader(label: a.formattedDate),
                  _AppointmentCard(appointment: a),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentPixModel payment;
  
  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final isExpired = payment.isExpired;
    return GestureDetector(
      onTap: () => _showPaymentDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey[100]!, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isExpired 
                      ? Colors.red.withOpacity(0.1)
                      : AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isExpired ? Icons.warning_amber_rounded : Icons.payment_rounded,
                    size: 20,
                    color: isExpired ? Colors.red[600] : AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.serviceTypeDisplayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        payment.shortAddress,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isExpired ? Colors.red : Colors.orange).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isExpired ? Colors.red : Colors.orange).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isExpired ? 'Expirado' : 'Pendente',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isExpired ? Colors.red : Colors.orange[700],
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valor do serviço',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.formattedAmount,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Data',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (!isExpired && payment.qrCode.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.qr_code_2_rounded, size: 18, color: AppColors.primaryGreen),
                          const SizedBox(width: 8),
                          const Text(
                            'PIX disponível',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primaryGreen),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _showPaymentDetails(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.4)),
                      ),
                      child: Icon(Icons.more_horiz_rounded, color: AppColors.primaryGreen, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPaymentDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PaymentDetailsModal(payment: payment),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  
  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final isUpcoming = appointment.isUpcoming;

    return GestureDetector(
      onTap: () => _showAppointmentDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey[100]!, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getServiceIcon(appointment.tipoLimpeza),
                    size: 20,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appointment.shortAddress,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status, Theme.of(context)).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(appointment.status, Theme.of(context)).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    appointment.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _getStatusColor(appointment.status, Theme.of(context)),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valor do serviço',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.formattedAmount,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      appointment.formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      appointment.horario,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (isUpcoming) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _addToCalendar(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Adicionar ao calendário',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _showAppointmentDetails(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.4)),
                      ),
                      child: Icon(Icons.more_horiz_rounded, color: AppColors.primaryGreen, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getServiceIcon(String tipoLimpeza) {
    switch (tipoLimpeza.toLowerCase()) {
      case 'padrao':
        return Icons.cleaning_services;
      case 'pesada':
        return Icons.home_work;
      case 'passadoria':
        return Icons.iron;
      default:
        return Icons.room_service;
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'confirmado':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'cancelado':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.primary;
    }
  }

  void _addToCalendar(BuildContext context) async {
    try {
      final DateTime appointmentDate = DateTime.parse(appointment.data);
      final List<String> timeParts = appointment.horario.split(':');
      final DateTime startTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      
      final Event event = Event(
        title: '${appointment.displayName} - Simplify',
        description: 'Serviço agendado\n'
                    'Endereço: ${appointment.endereco.fullAddress}\n'
                    'Valor: ${appointment.formattedAmount}\n'
                    'Tipo: ${appointment.propertyTypeDisplayName}',
        location: appointment.endereco.fullAddress,
        startDate: startTime,
        endDate: startTime.add(const Duration(hours: 2)),
        allDay: false,
      );

      final bool result = await Add2Calendar.addEvent2Cal(event);
      
      if (result && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Evento adicionado ao calendário!'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao adicionar ao calendário'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showAppointmentDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _AppointmentDetailsModal(appointment: appointment),
    );
  }
}

class _PaymentDetailsModal extends StatelessWidget {
  final PaymentPixModel payment;
  
  const _PaymentDetailsModal({required this.payment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Detalhes do Pagamento',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            payment.formattedAmount,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryGreen,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            payment.serviceTypeDisplayName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(icon: Icons.location_on, label: 'Endereço', value: payment.shortAddress),
                    _DetailRow(icon: Icons.calendar_today, label: 'Data', value: payment.formattedDate),
                    _DetailRow(icon: Icons.info, label: 'Status', value: payment.status),
                    if (!payment.isExpired && payment.qrCode.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: payment.qrCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Código PIX copiado!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: const Text('Copiar PIX'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () => _showQRCode(context),
                            icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                            label: const Text('Ver QR'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              side: BorderSide(color: AppColors.primaryGreen),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showQRCode(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code PIX'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: payment.qrCode,
              version: QrVersions.auto,
              size: 200,
            ),
            const SizedBox(height: 16),
            Text(
              payment.formattedAmount,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: payment.qrCode));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Código PIX copiado!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Copiar'),
          ),
        ],
      ),
    );
  }
}

class _AppointmentDetailsModal extends StatelessWidget {
  final AppointmentModel appointment;
  
  const _AppointmentDetailsModal({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUpcoming = appointment.isUpcoming;
    final bool isCancelled = appointment.paymentStatus.toUpperCase() == 'CANCELLED';
    
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Detalhes do Agendamento',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            appointment.formattedAmount,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryGreen,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            appointment.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(icon: Icons.location_on, label: 'Endereço', value: appointment.endereco.fullAddress),
                    _DetailRow(icon: Icons.calendar_today, label: 'Data', value: appointment.formattedDate),
                    _DetailRow(icon: Icons.access_time, label: 'Horário', value: appointment.horario),
                    _DetailRow(icon: Icons.home, label: 'Tipo', value: appointment.propertyTypeDisplayName),
                    _DetailRow(icon: Icons.info, label: 'Status', value: appointment.status),
                    if (isUpcoming && !isCancelled) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _addToCalendar(context),
                          icon: const Icon(Icons.calendar_today_rounded, size: 18),
                          label: const Text('Adicionar ao Calendário'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmAndCancel(context),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Cancelar agendamento'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[700],
                            side: BorderSide(color: Colors.red[400]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndCancel(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar agendamento'),
        content: const Text('Tem certeza que deseja cancelar este agendamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Mostra progresso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final service = AppointmentService();
    final success = await service.cancelAppointment(appointment.id);

    if (context.mounted) {
      Navigator.pop(context); // fecha progresso
      if (success) {
        Navigator.pop(context); // fecha modal de detalhes
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento cancelado com sucesso.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível cancelar. Tente novamente.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _addToCalendar(BuildContext context) async {
    try {
      final DateTime appointmentDate = DateTime.parse(appointment.data);
      final List<String> timeParts = appointment.horario.split(':');
      final DateTime startTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      
      final Event event = Event(
        title: '${appointment.displayName} - Simplify',
        description: 'Serviço agendado\n'
                    'Endereço: ${appointment.endereco.fullAddress}\n'
                    'Valor: ${appointment.formattedAmount}\n'
                    'Tipo: ${appointment.propertyTypeDisplayName}',
        location: appointment.endereco.fullAddress,
        startDate: startTime,
        endDate: startTime.add(const Duration(hours: 2)),
        allDay: false,
      );

      final bool result = await Add2Calendar.addEvent2Cal(event);
      
      if (result && context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento adicionado ao calendário!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao adicionar ao calendário'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Carregando...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, top: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  
  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ops! Algo deu errado',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Implementar retry
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  
  const _EmptyWidget({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add),
              label: const Text('Agendar serviço'),
            ),
          ],
        ),
      ),
    );
  }
}