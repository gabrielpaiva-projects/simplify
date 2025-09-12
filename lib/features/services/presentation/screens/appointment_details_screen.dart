import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/appointment_model.dart';
import '../../../../services/appointment_service.dart';

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

class AppointmentDetailsScreen extends StatelessWidget {
  final AppointmentModel appointment;
  
  const AppointmentDetailsScreen({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    final isUpcoming = appointment.isUpcoming;
    final bool isCancelled = appointment.paymentStatus.toUpperCase() == 'CANCELLED';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.formattedAmount,
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
                          appointment.displayName,
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
            
            // Conteúdo scrollável
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
