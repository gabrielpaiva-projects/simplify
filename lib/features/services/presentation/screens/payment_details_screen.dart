import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/payment_pix_model.dart';
import '../../../../services/professional_service.dart';
import '../../../../services/appointment_service.dart';
import '../../../../models/appointment_model.dart';

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

class PaymentDetailsScreen extends StatefulWidget {
  final PaymentPixModel payment;
  
  const PaymentDetailsScreen({
    super.key,
    required this.payment,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final ProfessionalService _professionalService = ProfessionalService();
  final AppointmentService _appointmentService = AppointmentService();
  ProfessionalData? _professional;
  AppointmentModel? _appointment;
  bool _loadingProfessional = false;

  @override
  void initState() {
    super.initState();
    _loadProfessionalData();
  }

  Future<void> _loadProfessionalData() async {
    print('🔍 [PAYMENT_DETAILS] Status: ${widget.payment.status}');
    print('🔍 [PAYMENT_DETAILS] PaymentId: ${widget.payment.asaasId}');
    
    // Para pagamentos RECEIVED (PIX) ou CONFIRMED (CARTÃO), buscar na collection services
    if (widget.payment.status == 'RECEIVED' || widget.payment.status == 'CONFIRMED') {
      print('🔍 [PAYMENT_DETAILS] Buscando appointment na collection services...');
      
      setState(() {
        _loadingProfessional = true;
      });

      try {
        // Buscar appointment pelo paymentId
        final appointments = await _appointmentService.getUserAppointments().first;
        final appointment = appointments.where((app) => app.paymentId == widget.payment.asaasId).firstOrNull;
        
        print('🔍 [PAYMENT_DETAILS] Appointment encontrado: ${appointment?.id}');
        
        if (appointment != null) {
          _appointment = appointment;
          
          // Verificar se appointment tem profissionalId
          final profissionalId = appointment.profissionalId;
          print('🔍 [PAYMENT_DETAILS] ProfissionalId do appointment: $profissionalId');
          
          // Se tem profissionalId, buscar dados do profissional
          if (profissionalId != null && profissionalId.isNotEmpty) {
            print('🔍 [PAYMENT_DETAILS] Carregando dados do profissional: $profissionalId');
            
            final professional = await _professionalService.getProfessionalById(profissionalId);
            print('🔍 [PAYMENT_DETAILS] Profissional encontrado: ${professional?.displayName}');
            
            if (mounted) {
              setState(() {
                _professional = professional;
                _loadingProfessional = false;
              });
            }
          } else {
            print('🔍 [PAYMENT_DETAILS] Appointment sem profissionalId - Buscando profissional');
            if (mounted) {
              setState(() {
                _loadingProfessional = false;
              });
            }
          }
        } else {
          print('🔍 [PAYMENT_DETAILS] Nenhum appointment encontrado para o paymentId');
          if (mounted) {
            setState(() {
              _loadingProfessional = false;
            });
          }
        }
      } catch (e) {
        print('❌ [PAYMENT_DETAILS] Erro ao carregar dados: $e');
        if (mounted) {
          setState(() {
            _loadingProfessional = false;
          });
        }
      }
    } else {
      print('🔍 [PAYMENT_DETAILS] Status não é RECEIVED/CONFIRMED - não buscar profissional');
    }
  }

  String get _statusText {
    // Para pagamentos RECEIVED (PIX) ou CONFIRMED (CARTÃO)
    if (widget.payment.status == 'RECEIVED' || widget.payment.status == 'CONFIRMED') {
      if (_appointment?.profissionalId == null || (_appointment?.profissionalId?.isEmpty ?? true)) {
        return 'Buscando profissional';
      } else {
        return 'Confirmado';
      }
    }
    return widget.payment.status;
  }

  Color get _statusColor {
    if (widget.payment.status == 'RECEIVED' || widget.payment.status == 'CONFIRMED') {
      if (_appointment?.profissionalId == null || (_appointment?.profissionalId?.isEmpty ?? true)) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
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
                          widget.payment.formattedAmount,
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
                          widget.payment.serviceTypeDisplayName,
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
                                  getGoogleMapsUrl(widget.payment.fullAddress),
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      print('🗺️ [MAP] Mapa carregado com sucesso para: ${widget.payment.fullAddress}');
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
                                    print('❌ [MAP] Erro ao carregar mapa para: ${widget.payment.fullAddress}');
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
                                        widget.payment.fullAddress,
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

                      // DEBUG INFO TEMPORÁRIO
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DEBUG INFO:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Status: ${widget.payment.status}'),
                            Text('AppointmentId: ${_appointment?.id ?? "null"}'),
                            Text('ProfissionalId: ${_appointment?.profissionalId ?? "null"}'),
                            Text('Should show section: ${_appointment?.profissionalId != null && (_appointment?.profissionalId?.isNotEmpty ?? false)}'),
                            Text('Loading: $_loadingProfessional'),
                            Text('Professional loaded: ${_professional?.displayName ?? "null"}'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Informações em grid
                      Row(
                        children: [
                          Expanded(
                            child: _CleanInfoCard(
                              title: 'Data',
                              value: widget.payment.formattedDate,
                              icon: Icons.calendar_today_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _CleanInfoCard(
                              title: 'Status',
                              value: _statusText,
                              icon: Icons.info_outlined,
                            ),
                          ),
                        ],
                      ),

                      // Seção do profissional (se disponível)
                      if (_appointment?.profissionalId != null && (_appointment?.profissionalId?.isNotEmpty ?? false)) ...[
                        const SizedBox(height: 24),
                        Builder(
                          builder: (context) {
                            print('🎨 [PAYMENT_DETAILS] Renderizando seção do profissional');
                            print('🎨 [PAYMENT_DETAILS] Professional: ${_professional?.displayName}');
                            print('🎨 [PAYMENT_DETAILS] Loading: $_loadingProfessional');
                            return _ProfessionalSection(
                              professional: _professional,
                              loading: _loadingProfessional,
                            );
                          },
                        ),
                      ],
                      
                      if (!widget.payment.isExpired && widget.payment.qrCode.isNotEmpty) ...[
                        const SizedBox(height: 40),
                        
                        // Botões clean
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: widget.payment.qrCode));
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
            ),
          ],
        ),
      ),
    );
  }

  void _showQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code PIX'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: widget.payment.qrCode,
              version: QrVersions.auto,
              size: 200,
            ),
            const SizedBox(height: 16),
            Text(
              widget.payment.formattedAmount,
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
              Clipboard.setData(ClipboardData(text: widget.payment.qrCode));
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
                // Avatar do profissional
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
                
                // Dados do profissional
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    size: 12,
                                    color: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verificado',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      if (professional!.rating != null)
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${professional!.rating!.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (professional!.totalJobs != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• ${professional!.totalJobs} serviços',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        )
                      else
                        Text(
                          professional!.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          else
            Text(
              'Não foi possível carregar os dados do profissional',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }
}
