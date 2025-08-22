import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/appointment_model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('dd/MM');
  final DateFormat _dayFormat = DateFormat('EEE', 'pt_BR');
  final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'pt_BR');

  // Mock data - substituir por dados reais do Firebase
  final List<AppointmentModel> _mockAppointments = [
    AppointmentModel(
      id: '1',
      professionalId: 'prof123',
      clientId: 'client1',
      clientName: 'Maria Santos',
      clientPhone: '(11) 98765-4321',
      serviceName: 'Limpeza Residencial',
      serviceDescription: 'Limpeza completa de apartamento 2 quartos',
      scheduledDate: DateTime.now().add(const Duration(hours: 2)),
      timeSlot: '10:00 - 12:00',
      price: 150.00,
      status: AppointmentStatus.confirmed,
      address: 'Rua das Flores, 123',
      addressComplement: 'Apto 45',
      neighborhood: 'Jardim Primavera',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '01234-567',
      notes: 'Cliente tem cachorro. Levar produtos antialérgicos.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    AppointmentModel(
      id: '2',
      professionalId: 'prof123',
      clientId: 'client2',
      clientName: 'João Silva',
      clientPhone: '(11) 91234-5678',
      serviceName: 'Instalação de Ar Condicionado',
      serviceDescription: 'Instalação de ar condicionado split 12000 BTUs',
      scheduledDate: DateTime.now().add(const Duration(hours: 5)),
      timeSlot: '14:00 - 16:00',
      price: 350.00,
      status: AppointmentStatus.scheduled,
      address: 'Av. Principal, 456',
      addressComplement: 'Casa',
      neighborhood: 'Centro',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '01234-567',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppointmentModel(
      id: '3',
      professionalId: 'prof123',
      clientId: 'client3',
      clientName: 'Ana Paula',
      clientPhone: '(11) 95555-5555',
      serviceName: 'Manutenção Elétrica',
      serviceDescription: 'Revisão da instalação elétrica',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '09:00 - 11:00',
      price: 200.00,
      status: AppointmentStatus.scheduled,
      address: 'Rua dos Pinheiros, 789',
      addressComplement: '',
      neighborhood: 'Pinheiros',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '05422-000',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
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
          'Agenda',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showCalendarPicker();
            },
            icon: const Icon(Icons.calendar_month, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implementar filtros
            },
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4A90E2),
          labelColor: const Color(0xFF4A90E2),
          unselectedLabelColor: Colors.grey[500],
          tabs: const [
            Tab(text: 'Hoje'),
            Tab(text: 'Próximos'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildUpcomingTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar novo agendamento
        },
        backgroundColor: const Color(0xFF4A90E2),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodayTab() {
    final todayAppointments = _mockAppointments
        .where((apt) => apt.isToday)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    if (todayAppointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_available,
        title: 'Sem agendamentos hoje',
        subtitle: 'Aproveite para descansar ou adicione novos agendamentos',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todayAppointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(todayAppointments[index]);
      },
    );
  }

  Widget _buildUpcomingTab() {
    final upcomingAppointments = _mockAppointments
        .where((apt) => apt.isFuture && !apt.isToday)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    if (upcomingAppointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_note,
        title: 'Sem agendamentos futuros',
        subtitle: 'Adicione novos agendamentos para manter sua agenda cheia',
      );
    }

    // Agrupar por data
    Map<DateTime, List<AppointmentModel>> groupedAppointments = {};
    for (var apt in upcomingAppointments) {
      final date = DateTime(apt.scheduledDate.year, apt.scheduledDate.month, apt.scheduledDate.day);
      if (groupedAppointments[date] == null) {
        groupedAppointments[date] = [];
      }
      groupedAppointments[date]!.add(apt);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedAppointments.length,
      itemBuilder: (context, index) {
        final date = groupedAppointments.keys.elementAt(index);
        final appointments = groupedAppointments[date]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _formatDateHeader(date),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...appointments.map((apt) => _buildAppointmentCard(apt)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    final pastAppointments = _mockAppointments
        .where((apt) => apt.isPast || apt.status == AppointmentStatus.completed)
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    if (pastAppointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'Sem histórico',
        subtitle: 'Seus agendamentos concluídos aparecerão aqui',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pastAppointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(pastAppointments[index], isHistory: true);
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, {bool isHistory = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(appointment.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _showAppointmentDetails(appointment);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com status e horário
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(appointment.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusLabel(appointment.status),
                            style: TextStyle(
                              color: _getStatusColor(appointment.status),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appointment.timeSlot,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    if (!isHistory)
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.grey[500], size: 20),
                        color: const Color(0xFF2A2A2A),
                        onSelected: (value) {
                          _handleAppointmentAction(value, appointment);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text('Editar', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'cancel',
                            child: Row(
                              children: [
                                Icon(Icons.cancel, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text('Cancelar', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Cliente e serviço
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          appointment.clientName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF4A90E2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.clientName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appointment.serviceName,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'R\$ ${appointment.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Endereço
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey[500],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appointment.fullAddress,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Notas (se houver)
                if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          color: Colors.grey[500],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            appointment.notes!,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Ações
                if (!isHistory) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            // TODO: Implementar navegação GPS
                          },
                          icon: const Icon(Icons.directions, size: 16),
                          label: const Text('Direções'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF4A90E2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            // TODO: Implementar chamada
                          },
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Ligar'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            // TODO: Implementar chat
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 16),
                          label: const Text('Chat'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFF9800),
                          ),
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

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return const Color(0xFF2196F3);
      case AppointmentStatus.confirmed:
        return const Color(0xFF4CAF50);
      case AppointmentStatus.inProgress:
        return const Color(0xFFFF9800);
      case AppointmentStatus.completed:
        return const Color(0xFF9E9E9E);
      case AppointmentStatus.cancelled:
        return const Color(0xFFF44336);
      case AppointmentStatus.rescheduled:
        return const Color(0xFF9C27B0);
    }
  }

  String _getStatusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'AGENDADO';
      case AppointmentStatus.confirmed:
        return 'CONFIRMADO';
      case AppointmentStatus.inProgress:
        return 'EM ANDAMENTO';
      case AppointmentStatus.completed:
        return 'CONCLUÍDO';
      case AppointmentStatus.cancelled:
        return 'CANCELADO';
      case AppointmentStatus.rescheduled:
        return 'REAGENDADO';
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hoje';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Amanhã';
    } else {
      return DateFormat('EEEE, d \'de\' MMMM', 'pt_BR').format(date);
    }
  }

  void _showCalendarPicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4A90E2),
              surface: Color(0xFF2A2A2A),
              background: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    ).then((date) {
      if (date != null) {
        setState(() {
          _selectedDate = date;
        });
      }
    });
  }

  void _showAppointmentDetails(AppointmentModel appointment) {
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
                    'Detalhes do Agendamento',
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
              // Adicionar mais detalhes aqui
              Text(
                'Cliente: ${appointment.clientName}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Serviço: ${appointment.serviceName}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Horário: ${appointment.timeSlot}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Endereço: ${appointment.fullAddress}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implementar início do serviço
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Iniciar Serviço'),
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

  void _handleAppointmentAction(String action, AppointmentModel appointment) {
    switch (action) {
      case 'edit':
        // TODO: Implementar edição
        break;
      case 'cancel':
        // TODO: Implementar cancelamento
        break;
    }
  }
}