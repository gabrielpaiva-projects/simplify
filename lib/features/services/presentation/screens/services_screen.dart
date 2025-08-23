import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with TickerProviderStateMixin {
  // Controllers para animações
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Dados mockados dos serviços
  final List<ServiceModel> _services = [
    ServiceModel(
      title: 'Limpeza Padrão',
      description: 'Limpeza na medida certa para as necessidades do dia-a-dia',
      imagePath: 'assets/limpeza_padrao.jpeg',
    ),
    ServiceModel(
      title: 'Limpeza Pesada',
      description: 'Limpeza com tudo que seu lar precisa para ficar brilhando',
      imagePath: 'assets/limpeza_pesada.jpeg',
    ),
    ServiceModel(
      title: 'Passadoria',
      description: 'Suas roupas bem passadas, cuidadas e dobradas',
      imagePath: 'assets/passadeira.jpeg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Iniciar animações
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleScheduleService(ServiceModel service) {
    HapticFeedback.mediumImpact();
    
    // Por enquanto só mostra um snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendando ${service.title}...'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Nossos Serviços',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionPanelList.radio(
                  elevation: 0,
                  expandedHeaderPadding: EdgeInsets.zero,
                  animationDuration: const Duration(milliseconds: 400),
                  children: _services.map((service) {
                    return ExpansionPanelRadio(
                      value: service.title,
                      canTapOnHeader: true,
                      backgroundColor: Colors.white,
                      headerBuilder: (context, isExpanded) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Ícone
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getServiceIcon(service.title),
                                  color: const Color(0xFF4CAF50),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Título
                              Expanded(
                                child: Text(
                                  service.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagem
                          Container(
                            height: 180,
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: AssetImage(service.imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Descrição
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.description,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Botão
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () => _handleScheduleService(service),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Agendar Serviço',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String title) {
    switch (title) {
      case 'Limpeza Padrão':
        return Icons.cleaning_services;
      case 'Limpeza Pesada':
        return Icons.home_repair_service;
      case 'Passadoria':
        return Icons.iron;
      default:
        return Icons.cleaning_services;
    }
  }
}

// Modelo de dados simplificado
class ServiceModel {
  final String title;
  final String description;
  final String imagePath;

  ServiceModel({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}