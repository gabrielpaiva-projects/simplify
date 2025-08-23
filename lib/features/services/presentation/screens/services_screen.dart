import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  int _selectedNavIndex = 0;
  int _selectedServiceIndex = -1;
  
  // Dados mockados dos serviços
  final List<ServiceModel> _services = [
    ServiceModel(
      title: 'Limpeza Padrão',
      description: 'Limpeza na medida certa para as necessidades do dia-a-dia',
      imagePath: 'assets/limpeza_padrao.jpeg',
      icon: Icons.home_outlined,
      price: 'R\$ 120',
      duration: '3-4 horas',
    ),
    ServiceModel(
      title: 'Limpeza Pesada',
      description: 'Limpeza com tudo que seu lar precisa para ficar brilhando',
      imagePath: 'assets/limpeza_pesada.jpeg',
      icon: Icons.cleaning_services_outlined,
      price: 'R\$ 200',
      duration: '5-6 horas',
    ),
    ServiceModel(
      title: 'Passadoria',
      description: 'Suas roupas bem passadas, cuidadas e dobradas',
      imagePath: 'assets/passadeira.jpeg',
      icon: Icons.iron_outlined,
      price: 'R\$ 80',
      duration: '2-3 horas',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleScheduleService(ServiceModel service) {
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendando ${service.title}'),
        backgroundColor: const Color(0xFF4CAF50),
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
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Simples e Limpo
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Serviços',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Stack(
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              size: 28,
                              color: Color(0xFF1A1A1A),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha o serviço ideal para você',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Lista de Serviços
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  final isSelected = _selectedServiceIndex == index;
                  
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    tween: Tween(begin: 0, end: 1),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedServiceIndex = isSelected ? -1 : index;
                        });
                        HapticFeedback.lightImpact();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF4CAF50)
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Imagem com Overlay
                            Container(
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                                image: DecorationImage(
                                  image: AssetImage(service.imagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Gradient Overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(14),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Badge de Preço
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            service.price,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4CAF50),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Duração
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey[700],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            service.duration,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Conteúdo do Card
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          service.icon,
                                          size: 20,
                                          color: const Color(0xFF4CAF50),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              service.title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1A1A1A),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              service.description,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: () => _handleScheduleService(service),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isSelected 
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFF4CAF50).withOpacity(0.1),
                                        foregroundColor: isSelected 
                                            ? Colors.white
                                            : const Color(0xFF4CAF50),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Agendar Serviço',
                                        style: TextStyle(
                                          fontSize: 15,
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
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar Minimalista
      bottomNavigationBar: Container(
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
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Início',
                  index: 0,
                  isSelected: _selectedNavIndex == 0,
                ),
                _buildNavItem(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  index: 1,
                  isSelected: _selectedNavIndex == 1,
                ),
                _buildNavItem(
                  icon: Icons.menu,
                  label: 'Mais',
                  index: 2,
                  isSelected: _selectedNavIndex == 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedNavIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? const Color(0xFF4CAF50)
                  : Colors.grey[500],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected 
                    ? const Color(0xFF4CAF50)
                    : Colors.grey[500],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modelo de dados
class ServiceModel {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
  final String price;
  final String duration;

  ServiceModel({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.price,
    required this.duration,
  });
}