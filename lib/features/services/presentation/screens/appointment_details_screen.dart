import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/appointment_model.dart';
import '../../../../services/appointment_service.dart';
import '../../../../services/professional_service.dart';

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

class AppointmentDetailsScreen extends StatefulWidget {
  final AppointmentModel appointment;
  
  const AppointmentDetailsScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final ProfessionalService _professionalService = ProfessionalService();
  final AppointmentService _appointmentService = AppointmentService();
  ProfessionalData? _professional;
  bool _loadingProfessional = false;

  @override
  void initState() {
    super.initState();
    _loadProfessionalData();
  }

  Future<void> _loadProfessionalData() async {
    print('🔍 [APPOINTMENT_DETAILS] Status: ${widget.appointment.paymentStatus}');
    print('🔍 [APPOINTMENT_DETAILS] ProfissionalId: ${widget.appointment.profissionalId}');
    
    if (widget.appointment.paymentStatus == 'RECEIVED' || widget.appointment.paymentStatus == 'CONFIRMED') {
      if (widget.appointment.profissionalId != null && widget.appointment.profissionalId!.isNotEmpty) {
        print('🔍 [APPOINTMENT_DETAILS] Carregando dados do profissional: ${widget.appointment.profissionalId}');
        
        setState(() {
          _loadingProfessional = true;
        });

        try {
          final professional = await _professionalService.getProfessionalById(widget.appointment.profissionalId!);
          print('🔍 [APPOINTMENT_DETAILS] Profissional encontrado: ${professional?.displayName}');
          
          if (mounted) {
            setState(() {
              _professional = professional;
              _loadingProfessional = false;
            });
          }
        } catch (e) {
          print('❌ [APPOINTMENT_DETAILS] Erro ao carregar profissional: $e');
          if (mounted) {
            setState(() {
              _loadingProfessional = false;
            });
          }
        }
      } else {
        print('🔍 [APPOINTMENT_DETAILS] Agendamento pago sem profissionalId - Buscando profissional');
      }
    } else {
      print('🔍 [APPOINTMENT_DETAILS] Status não é RECEIVED/CONFIRMED - não buscar profissional');
    }
  }

  String get _statusText {
    if (widget.appointment.paymentStatus == 'RECEIVED' || widget.appointment.paymentStatus == 'CONFIRMED') {
      if (widget.appointment.profissionalId == null || (widget.appointment.profissionalId?.isEmpty ?? true)) {
        return 'Buscando profissional';
      } else {
        return 'Confirmado';
      }
    }
    
    return widget.appointment.paymentStatusDisplayName;
  }

  Color get _statusColor {
    if (widget.appointment.paymentStatus == 'RECEIVED' || widget.appointment.paymentStatus == 'CONFIRMED') {
      if (widget.appointment.profissionalId == null || (widget.appointment.profissionalId?.isEmpty ?? true)) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    }
    return AppColors.primaryGreen;
  }

  @override
  Widget build(BuildContext context) {
    final isUpcoming = widget.appointment.isUpcoming;
    final bool isCancelled = widget.appointment.paymentStatus.toUpperCase() == 'CANCELLED';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.appointment.formattedAmount,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.appointment.displayName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B6B6B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  getGoogleMapsUrl(widget.appointment.endereco.fullAddress),
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      print('🗺️ [MAP] Mapa carregado com sucesso para: ${widget.appointment.endereco.fullAddress}');
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
                                    print('❌ [MAP] Erro ao carregar mapa para: ${widget.appointment.endereco.fullAddress}');
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
                                        widget.appointment.endereco.fullAddress,
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
                      
                      Row(
                        children: [
                          Expanded(
                            child: _CleanInfoCard(
                              title: 'Data',
                              value: widget.appointment.formattedDate,
                              icon: Icons.calendar_today_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _CleanInfoCard(
                              title: 'Horário',
                              value: widget.appointment.horario,
                              icon: Icons.access_time_outlined,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _CleanInfoCard(
                        title: 'Tipo de Imóvel',
                        value: widget.appointment.propertyTypeDisplayName,
                        icon: Icons.home_outlined,
                      ),

                      if (widget.appointment.profissionalId != null && (widget.appointment.profissionalId?.isNotEmpty ?? false)) ...[
                        const SizedBox(height: 24),
                        _ProfessionalSection(
                          professional: _professional,
                          loading: _loadingProfessional,
                        ),
                      ],
                      
                      if (isUpcoming && !isCancelled) ...[
                        const SizedBox(height: 40),
                        
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
            ),
          ],
        ),
      ),
    );
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final service = _appointmentService;
    final success = await service.cancelAppointment(widget.appointment.id);

    if (context.mounted) {
      Navigator.pop(context); // fecha progresso
      if (success) {
        Navigator.pop(context); // fecha tela de detalhes
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
      final DateTime appointmentDate = DateTime.parse(widget.appointment.data);
      final List<String> timeParts = widget.appointment.horario.split(':');
      final DateTime startTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      
      final Event event = Event(
        title: '${widget.appointment.displayName} - Simplify',
        description: 'Serviço agendado\n'
                    'Endereço: ${widget.appointment.endereco.fullAddress}\n'
                    'Valor: ${widget.appointment.formattedAmount}\n'
                    'Tipo: ${widget.appointment.propertyTypeDisplayName}',
        location: widget.appointment.endereco.fullAddress,
        startDate: startTime,
        endDate: startTime.add(const Duration(hours: 2)),
        allDay: false,
      );

      final bool result = await Add2Calendar.addEvent2Cal(event);
      
      if (result && context.mounted) {
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

class _ProfessionalSection extends StatelessWidget {
  final ProfessionalData? professional;
  final bool loading;
  
  const _ProfessionalSection({
    required this.professional,
    required this.loading,
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
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Profissional',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (loading)
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Carregando dados do profissional...'),
              ],
            )
          else if (professional != null)
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: professional!.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            professional!.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  professional!.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            professional!.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              professional!.displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          if (professional!.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verificado',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (professional!.rating ?? 0.0).toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.work_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${professional!.totalJobs} serviços',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            const Text(
              'Dados do profissional não disponíveis',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
