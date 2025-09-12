import 'dart:ui';
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

// Função global para gerar URLs do Google Maps com logs
String getGoogleMapsUrl(String address) {
  final encodedAddress = Uri.encodeComponent(address);
  final url = 'https://maps.googleapis.com/maps/api/staticmap?'
      'center=$encodedAddress&'
      'zoom=16&'
      'size=400x200&'
      'maptype=roadmap&'
      'markers=color:green%7C$encodedAddress&'
      'style=feature:poi%7Cvisibility:off&'
      'style=feature:transit%7Cvisibility:off&'
      'key=AIzaSyBRg_0vHtd-kB2lHQ_y1w0oIV0ChdIcBlw';
  
  print('🗺️ [MAP] Gerando URL do mapa para: $address');
  print('🗺️ [MAP] Endereço codificado: $encodedAddress');
  print('🗺️ [MAP] URL gerada: $url');
  
  return url;
}

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

  // Métodos auxiliares para a tab bar
  IconData _getTabIcon(int index) {
    switch (index) {
      case 0:
        return Icons.payment_rounded;
      case 1:
        return Icons.schedule_rounded;
      case 2:
        return Icons.history_rounded;
      default:
        return Icons.circle;
    }
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'Pendentes';
      case 1:
        return 'Próximos';
      case 2:
        return 'Histórico';
      default:
        return '';
    }
  }

  Future<int> _getTabCount(int index) async {
    try {
      switch (index) {
        case 0:
          // Contador de pagamentos pendentes
          final payments = await _paymentPixService.getPendingPixPayments().first;
          return payments.length;
        case 1:
          // Contador de agendamentos próximos
          final appointments = await _appointmentService.getUpcomingAppointments().first;
          return appointments.length;
        case 2:
          // Contador de histórico
          final history = await _appointmentService.getAppointmentHistory().first;
          return history.length;
        default:
          return 0;
      }
    } catch (e) {
      return 0;
    }
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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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

              // Tab bar premium e elegante
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE9ECEF),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < 3; i++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _tabController.animateTo(i),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    _tabController.index == i ? 0.04 : 0.0
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    _tabController.index == i ? 0.02 : 0.0
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOutCubic,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeInOutCubic,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: _tabController.index == i 
                                              ? FontWeight.w600 
                                              : FontWeight.w500,
                                          color: _tabController.index == i
                                              ? const Color(0xFF1A1A1A)
                                              : const Color(0xFF6B7280),
                                          letterSpacing: -0.2,
                                        ),
                                        child: Text(_getTabTitle(i)),
                                      ),
                                      FutureBuilder<int>(
                                        future: _getTabCount(i),
                                        builder: (context, snapshot) {
                                          final count = snapshot.data ?? 0;
                                          if (count == 0) return const SizedBox.shrink();
                                          
                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 250),
                                            curve: Curves.easeInOutCubic,
                                            margin: const EdgeInsets.only(left: 6),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _tabController.index == i
                                                  ? AppColors.primaryGreen
                                                  : const Color(0xFFE5E7EB),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 250),
                                              curve: Curves.easeInOutCubic,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _tabController.index == i
                                                    ? Colors.white
                                                    : const Color(0xFF6B7280),
                                              ),
                                              child: Text(count.toString()),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOutCubic,
                                    height: 2,
                                    width: _tabController.index == i ? 24 : 0,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen,
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
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
    print('📱 [MODAL] Abrindo modal de detalhes de pagamento');
    print('📱 [MODAL] Endereço: ${payment.shortAddress}');
    print('📱 [MODAL] Valor: ${payment.formattedAmount}');
    
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
    print('📱 [MODAL] Abrindo modal de detalhes de agendamento');
    print('📱 [MODAL] Endereço: ${appointment.endereco.fullAddress}');
    print('📱 [MODAL] Valor: ${appointment.formattedAmount}');
    print('📱 [MODAL] Data: ${appointment.formattedDate}');
    
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle minimalista
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header clean
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                Text(
                  payment.formattedAmount,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -1,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: payment.isExpired ? Colors.red[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    payment.isExpired ? 'Expirado' : 'Pendente',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: payment.isExpired ? Colors.red[700] : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Subtítulo
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Row(
              children: [
                Text(
                  payment.serviceTypeDisplayName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Conteúdo scrollável
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Localização com mapa real
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Mapa real do Google Maps
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              getGoogleMapsUrl(payment.shortAddress),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  print('🗺️ [MAP] Mapa carregado com sucesso para: ${payment.shortAddress}');
                                  return child;
                                }
                                
                                final progress = loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null;
                                
                                print('🗺️ [MAP] Carregando mapa... ${progress != null ? '${(progress * 100).toInt()}%' : 'indefinido'}');
                                
                                return Container(
                                  color: const Color(0xFFF8F9FA),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryGreen,
                                      strokeWidth: 2,
                                      value: progress,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ [MAP] Erro ao carregar mapa para: ${payment.shortAddress}');
                                print('❌ [MAP] Erro: $error');
                                if (stackTrace != null) {
                                  print('❌ [MAP] StackTrace: $stackTrace');
                                }
                                
                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.map_outlined,
                                          color: Colors.grey[400],
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Mapa indisponível',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Endereço overlay
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    payment.shortAddress,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Informações em grid
                  Row(
                    children: [
                      Expanded(
                        child: _CleanInfoCard(
                          title: 'Data',
                          value: payment.formattedDate,
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _CleanInfoCard(
                          title: 'Status',
                          value: payment.status,
                          icon: Icons.info_outlined,
                        ),
                      ),
                    ],
                  ),
                  
                  if (!payment.isExpired && payment.qrCode.isNotEmpty) ...[
                    const SizedBox(height: 40),
                    
                    // Botões clean
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: payment.qrCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Código PIX copiado!'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.primaryGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 22),
                            label: const Text(
                              'Copiar código PIX',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () => _showQRCode(context),
                            icon: const Icon(Icons.qr_code_2_outlined, size: 22),
                            label: const Text(
                              'Mostrar QR Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1A1A1A),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
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
    final isUpcoming = appointment.isUpcoming;
    final bool isCancelled = appointment.paymentStatus.toUpperCase() == 'CANCELLED';
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle minimalista
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header clean
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                Text(
                  appointment.formattedAmount,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -1,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status, Theme.of(context)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.status,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(appointment.status, Theme.of(context)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Subtítulo
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Row(
              children: [
                Text(
                  appointment.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Conteúdo scrollável
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Localização com mapa real
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Mapa real do Google Maps
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              getGoogleMapsUrl(appointment.endereco.fullAddress),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  print('🗺️ [MAP] Mapa carregado com sucesso para: ${appointment.endereco.fullAddress}');
                                  return child;
                                }
                                
                                final progress = loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null;
                                
                                print('🗺️ [MAP] Carregando mapa... ${progress != null ? '${(progress * 100).toInt()}%' : 'indefinido'}');
                                
                                return Container(
                                  color: const Color(0xFFF8F9FA),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryGreen,
                                      strokeWidth: 2,
                                      value: progress,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ [MAP] Erro ao carregar mapa para: ${appointment.endereco.fullAddress}');
                                print('❌ [MAP] Erro: $error');
                                if (stackTrace != null) {
                                  print('❌ [MAP] StackTrace: $stackTrace');
                                }
                                
                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.map_outlined,
                                          color: Colors.grey[400],
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Mapa indisponível',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Endereço overlay
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    appointment.endereco.fullAddress,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Informações em grid
                  Row(
                    children: [
                      Expanded(
                        child: _CleanInfoCard(
                          title: 'Data',
                          value: appointment.formattedDate,
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _CleanInfoCard(
                          title: 'Horário',
                          value: appointment.horario,
                          icon: Icons.access_time_outlined,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _CleanInfoCard(
                    title: 'Tipo de Imóvel',
                    value: appointment.propertyTypeDisplayName,
                    icon: Icons.home_outlined,
                  ),
                  
                  if (isUpcoming && !isCancelled) ...[
                    const SizedBox(height: 40),
                    
                    // Botões clean
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => _addToCalendar(context),
                            icon: const Icon(Icons.calendar_today_outlined, size: 22),
                            label: const Text(
                              'Adicionar ao calendário',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmAndCancel(context),
                            icon: const Icon(Icons.cancel_outlined, size: 22),
                            label: const Text(
                              'Cancelar agendamento',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red[600],
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
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

class _CleanInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  
  const _CleanInfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernDetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  
  const _ModernDetailCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
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
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
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