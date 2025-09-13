import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../services/professional_available_services_service.dart';
import '../../../../models/appointment_model.dart';
import '../widgets/professional_app_bar.dart';
import '../widgets/modern_service_card.dart';

// Função global para gerar URLs do Google Maps (mesma do fluxo do cliente)
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
  
  print('🗺️ [PROFESSIONAL] Gerando URL do mapa para: $address');
  print('🗺️ [PROFESSIONAL] Endereço codificado: $encodedAddress');
  print('🗺️ [PROFESSIONAL] URL gerada: $url');
  
  return url;
}

class ProfessionalHomeScreen extends StatefulWidget {
  const ProfessionalHomeScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalHomeScreen> createState() => _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState extends State<ProfessionalHomeScreen> 
    with TickerProviderStateMixin {
  final ProfessionalAvailableServicesService _servicesService = 
      ProfessionalAvailableServicesService();
  
  late AnimationController _animationController;
  
  // Filtro de distância
  double _selectedDistance = 10.0; // km
  final List<double> _distanceOptions = [5.0, 10.0, 15.0, 25.0, 50.0];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        color: AppColors.primaryGreen,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: _buildModernAppBar(),
            ),
            // Header impecável
            SliverToBoxAdapter(
              child: _buildImpeccableHeader(),
            ),
            // Services Section
            SliverToBoxAdapter(
              child: _buildServicesSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 24,
        right: 24,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar do profissional
          Container(
            width: 44,
            height: 44,
      decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGreen,
                  AppColors.primaryGreen.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.25),
                  blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Título e status
          Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                Text(
                  'Simplify Pro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepBlack,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Ações do app bar
          Row(
            children: [
              _buildAppBarAction(
                Icons.notifications_outlined,
                onTap: () {
                  // TODO: Abrir notificações
                },
              ),
              const SizedBox(width: 12),
              _buildAppBarAction(
                Icons.more_vert,
                onTap: () {
                  // TODO: Abrir menu
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildImpeccableHeader() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
            child: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saudação elegante
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
                      final userName = authProvider.userData?['fullName']?.split(' ')[0] ?? 'Profissional';
                      return RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepBlack,
                            letterSpacing: -1.2,
                            height: 1.1,
                          ),
                          children: [
                            const TextSpan(text: 'Olá '),
                            TextSpan(
                              text: userName,
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const TextSpan(text: '! 👋'),
                          ],
                ),
              );
            },
          ),
                  const SizedBox(height: 12),
                  // Subtítulo moderno
                  Text(
                    'Encontre os melhores serviços próximos a você',
            style: TextStyle(
              fontSize: 16,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Estatística inline elegante
                  StreamBuilder<List<ServiceWithDistance>>(
                    stream: _servicesService.getAvailableServicesWithDistance(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildShimmerCard();
                      }
                      
                      final allServices = snapshot.data ?? [];
                      // Filtrar por distância para mostrar a contagem correta
                      final filteredCount = allServices
                          .where((service) => service.distance <= _selectedDistance)
                          .length;
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryGreen.withOpacity(0.08),
                              AppColors.primaryGreen.withOpacity(0.04),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryGreen.withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.work_outline,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Serviços disponíveis hoje',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Atualizado agora',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                '$filteredCount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
            ),
          ),
        ],
      ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDistanceSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                size: 18,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                'Filtrar por distância',
            style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Chips de distância
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _distanceOptions.map((distance) {
                final isSelected = _selectedDistance == distance;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDistance = distance;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primaryGreen 
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.primaryGreen 
                              : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            '${distance.toInt()} km',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected 
                                  ? Colors.white 
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Seletor de distância
                _buildDistanceSelector(),
                const SizedBox(height: 20),
                // Section header elegante
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        'Serviços Próximos',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepBlack,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Até ${_selectedDistance.toInt()} km',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Services list
                StreamBuilder<List<ServiceWithDistance>>(
      stream: _servicesService.getAvailableServicesWithDistance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

                        final allServices = snapshot.data ?? [];
                        
                        // Filtrar por distância
                        final servicesWithDistance = allServices
                            .where((service) => service.distance <= _selectedDistance)
                            .toList();

        if (servicesWithDistance.isEmpty) {
          return _buildEmptyState();
        }

                    return Column(
                      children: servicesWithDistance.asMap().entries.map((entry) {
                        final index = entry.key;
                        final serviceWithDistance = entry.value;
                        
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 600 + (index * 100)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, animationValue, child) {
                            return Transform.translate(
                              offset: Offset(0, 30 * (1 - animationValue)),
                              child: Opacity(
                                opacity: animationValue,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    left: 24,
                                    right: 24,
                                    bottom: 16,
                                  ),
                                    child: ModernServiceCard(
                service: serviceWithDistance.service,
                distance: serviceWithDistance.distance,
                onAccept: () => _handleAcceptService(serviceWithDistance.service),
                                      onViewDetails: () => _showServiceDetails(context, serviceWithDistance.service, serviceWithDistance.distance),
                                    ),
                                ),
              ),
            );
          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Buscando serviços...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.deepBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aguarde um momento',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 50,
            color: AppColors.error,
          ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ops! Algo deu errado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlack,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Não conseguimos carregar os serviços no momento',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Tentar Novamente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: AppColors.primaryGreen,
      colorOpacity: 0.3,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryGreen.withOpacity(0.15),
              AppColors.primaryGreen.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Shimmer do ícone
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            // Shimmer do texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Shimmer do contador
            Container(
              width: 40,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Ilustração moderna
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.primaryGreen.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(70),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.15),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Círculos decorativos
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 25,
                  left: 25,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Ícone principal
          Icon(
                  Icons.search_outlined,
                  size: 48,
                  color: AppColors.primaryGreen.withOpacity(0.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Texto principal
          Text(
            'Nenhum serviço encontrado',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.deepBlack,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Subtexto
          Text(
            'Não encontramos serviços disponíveis nesta\ndistância. Tente expandir o raio de busca.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF64748B),
              height: 1.5,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 32),
          // Sugestões
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEmptyStateAction(
                icon: Icons.refresh,
                label: 'Atualizar',
                onTap: () => setState(() {}),
              ),
              _buildEmptyStateAction(
                icon: Icons.tune,
                label: 'Filtros',
                onTap: () {
                  // Scroll para o seletor de distância
                  setState(() {
                    _selectedDistance = 25.0;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEmptyStateAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceDetails(BuildContext context, AppointmentModel service, double distance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDetailsBottomSheet(
        service: service,
        distance: distance,
        onAccept: () => _handleAcceptService(service),
      ),
    );
  }

  Future<void> _handleAcceptService(AppointmentModel service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.handshake_rounded,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Aceitar Serviço',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Deseja aceitar este serviço?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildServiceDetail('Serviço', service.serviceTypeDisplayName),
                    _buildServiceDetail('Endereço', service.endereco.shortAddress),
                    _buildServiceDetail('Data', service.formattedDate),
                    _buildServiceDetail('Horário', service.formattedTime),
                    _buildServiceDetail('Valor', service.formattedAmount),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondaryText,
                        side: BorderSide(color: AppColors.lightGrey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Aceitar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aceitando...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final success = await _servicesService.acceptService(service.id);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
            success 
                ? 'Serviço aceito com sucesso!' 
                    : 'Erro ao aceitar serviço',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildServiceDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.deepBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Clean & Modern Service Card
class UltraModernServiceCard extends StatelessWidget {
  final AppointmentModel service;
  final double distance;
  final VoidCallback onAccept;

  const UltraModernServiceCard({
    Key? key,
    required this.service,
    required this.distance,
    required this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Service icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getServiceIcon(),
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Service info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.serviceTypeDisplayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.propertyTypeDisplayName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Details row
          Row(
            children: [
              _buildDetailItem(
                Icons.calendar_today_outlined,
                service.formattedDate,
              ),
              const SizedBox(width: 20),
              _buildDetailItem(
                Icons.access_time_outlined,
                service.formattedTime,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildDetailItem(
            Icons.location_on_outlined,
            service.endereco.shortAddress,
            isFullWidth: true,
          ),
          
          const SizedBox(height: 24),
          
          // Divider
          Container(
            height: 1,
            color: const Color(0xFFF3F4F6),
          ),
          
          const SizedBox(height: 20),
          
          // Map image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 120,
              width: double.infinity,
              color: const Color(0xFFF3F4F6),
              child: Stack(
                children: [
                  // Mapa real do Google Maps
                  Image.network(
                    getGoogleMapsUrl(service.endereco.fullAddress),
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        print('🗺️ [PROFESSIONAL] Mapa carregado com sucesso para: ${service.endereco.fullAddress}');
                        return child;
                      }
                      
                      final progress = loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null;
                      
                      print('🗺️ [PROFESSIONAL] Carregando mapa... ${progress != null ? '${(progress * 100).toInt()}%' : 'indefinido'}');
                      
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
                      print('🗺️ [PROFESSIONAL] Erro ao carregar mapa para: ${service.endereco.fullAddress}');
                      print('🗺️ [PROFESSIONAL] Erro: $error');
                      
                      return Container(
                        width: double.infinity,
                        height: 120,
                        color: const Color(0xFFF3F4F6),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              color: Color(0xFF9CA3AF),
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Mapa não disponível',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // Distance overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${distance.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Price and actions
          Row(
            children: [
              // Price column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Valor',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.formattedAmount,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              Column(
                children: [
                  // Details button
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () => _showServiceDetails(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: BorderSide(color: AppColors.primaryGreen, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Ver Detalhes',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Accept button
                  SizedBox(
                    width: 120,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Aceitar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, {bool isFullWidth = false}) {
    return Expanded(
      flex: isFullWidth ? 1 : 0,
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDetailsBottomSheet(
        service: service,
        distance: distance,
        onAccept: onAccept,
      ),
    );
  }

  IconData _getServiceIcon() {
    switch (service.tipoLimpeza.toLowerCase()) {
      case 'padrao':
        return Icons.cleaning_services_outlined;
      case 'pesada':
        return Icons.home_repair_service_outlined;
      case 'passadoria':
        return Icons.iron_outlined;
      default:
        return Icons.home_repair_service_outlined;
    }
  }
}

// Service Details BottomSheet
class ServiceDetailsBottomSheet extends StatelessWidget {
  final AppointmentModel service;
  final double distance;
  final VoidCallback onAccept;

  const ServiceDetailsBottomSheet({
    Key? key,
    required this.service,
    required this.distance,
    required this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getServiceIcon(),
                    color: AppColors.primaryGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.serviceTypeDisplayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        service.propertyTypeDisplayName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${distance.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map section
                  _buildSection(
                    'Localização',
                    Icons.location_on_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.endereco.fullAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            child: Image.network(
                              getGoogleMapsUrl(service.endereco.fullAddress),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  print('🗺️ [PROFESSIONAL] Mapa do BottomSheet carregado com sucesso');
                                  return child;
                                }
                                
                                final progress = loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null;
                                
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
                                print('🗺️ [PROFESSIONAL] Erro ao carregar mapa do BottomSheet: $error');
                                
                                return Container(
                                  color: const Color(0xFFF3F4F6),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.map_outlined,
                                        color: Color(0xFF9CA3AF),
                                        size: 48,
                                      ),
                                      SizedBox(height: 8),
                                      Text('Mapa não disponível'),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Service details
                  _buildSection(
                    'Detalhes do Serviço',
                    Icons.info_outline,
                    child: Column(
                      children: [
                        _buildDetailRow('Data', service.formattedDate, Icons.calendar_today_outlined),
                        _buildDetailRow('Horário', service.formattedTime, Icons.access_time_outlined),
                        _buildDetailRow('Cômodos', '${service.quantidadeComodos}', Icons.home_outlined),
                        _buildDetailRow('Banheiros', '${service.quantidadeBanheiros}', Icons.bathroom_outlined),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Extra services
                  if (service.servicosExtras.temPets || service.servicosExtras.produtosInclusos)
                    _buildSection(
                      'Serviços Extras',
                      Icons.add_circle_outline,
                      child: Column(
                        children: [
                          if (service.servicosExtras.temPets)
                            _buildDetailRow(
                              'Pets na residência',
                              service.servicosExtras.petsValor > 0 
                                  ? '+R\$ ${service.servicosExtras.petsValor.toStringAsFixed(2)}'
                                  : 'Sim',
                              Icons.pets_outlined,
                            ),
                          if (service.servicosExtras.produtosInclusos)
                            _buildDetailRow(
                              'Produtos inclusos',
                              service.servicosExtras.produtosValor > 0
                                  ? '+R\$ ${service.servicosExtras.produtosValor.toStringAsFixed(2)}'
                                  : 'Sim',
                              Icons.cleaning_services_outlined,
                            ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Client info
                  _buildSection(
                    'Cliente',
                    Icons.person_outline,
                    child: _buildDetailRow('Nome', service.userName, Icons.person),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Payment info
                  _buildSection(
                    'Pagamento',
                    Icons.payment_outlined,
                    child: Column(
                      children: [
                        _buildDetailRow('Valor base', 'R\$ ${(service.paymentAmount - service.servicosExtras.totalExtrasValue).toStringAsFixed(2)}', Icons.monetization_on_outlined),
                        if (service.servicosExtras.totalExtrasValue > 0)
                          _buildDetailRow('Extras', 'R\$ ${service.servicosExtras.totalExtrasValue.toStringAsFixed(2)}', Icons.add),
                        const Divider(),
                        _buildDetailRow(
                          'Total',
                          service.formattedAmount,
                          Icons.account_balance_wallet_outlined,
                          isTotal: true,
                        ),
                        _buildDetailRow('Método', service.paymentTypeDisplayName, Icons.credit_card_outlined),
                        _buildDetailRow('Status', service.paymentStatusDisplayName, Icons.check_circle_outline),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
          
          // Fixed bottom action button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onAccept();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Aceitar Serviço',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildSection(String title, IconData icon, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.deepBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isTotal ? AppColors.primaryGreen : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                color: isTotal ? AppColors.deepBlack : const Color(0xFF6B7280),
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? AppColors.primaryGreen : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }


  IconData _getServiceIcon() {
    switch (service.tipoLimpeza.toLowerCase()) {
      case 'padrao':
        return Icons.cleaning_services_outlined;
      case 'pesada':
        return Icons.home_repair_service_outlined;
      case 'passadoria':
        return Icons.iron_outlined;
      default:
        return Icons.home_repair_service_outlined;
    }
  }
}