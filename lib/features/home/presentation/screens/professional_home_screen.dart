import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'schedule_screen.dart';
import 'payments_screen.dart';
import 'chat_list_screen.dart';

class ProfessionalHomeScreen extends StatefulWidget {
  const ProfessionalHomeScreen({super.key});

  @override
  State<ProfessionalHomeScreen> createState() => _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState extends State<ProfessionalHomeScreen> 
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late List<AnimationController> _cardControllers;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  // Page Controller for smooth transitions
  late PageController _pageController;
  
  // Scroll Controller for custom effects
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize screens after init
    _screens.addAll([
      _ModernHomeTab(scrollController: _scrollController),
      const ScheduleScreen(),
      const PaymentsScreen(),
      const ChatListScreen(),
    ]);
    
    _pageController = PageController(initialPage: _selectedIndex);
    
    // Setup animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    // Initialize card animations
    _cardControllers = List.generate(
      6,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    
    for (var controller in _cardControllers) {
      Future.delayed(Duration(milliseconds: 100 * _cardControllers.indexOf(controller)), () {
        if (mounted) controller.forward();
      });
    }
    
    // Listen to scroll
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),
          
          // Main content
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
          ),
          
          // Modern bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildModernBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A0A0A),
                const Color(0xFF1A1A2E).withOpacity(0.5),
                const Color(0xFF16213E).withOpacity(0.3),
                const Color(0xFF0A0A0A),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
              transform: GradientRotation(_rotationController.value * 2 * math.pi),
            ),
          ),
          child: CustomPaint(
            painter: _MeshGradientPainter(_rotationController.value),
            child: Container(),
          ),
        );
      },
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF0A0A0A).withOpacity(0.8),
            const Color(0xFF0A0A0A),
          ],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.6),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home_rounded, 'Início', 0),
                _buildNavItem(Icons.calendar_month_rounded, 'Agenda', 1),
                _buildNavItem(Icons.account_balance_wallet_rounded, 'Finanças', 2),
                _buildNavItem(Icons.chat_bubble_rounded, 'Chat', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      )
                    : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Home Tab with Premium Design
class _ModernHomeTab extends StatefulWidget {
  final ScrollController scrollController;
  
  const _ModernHomeTab({required this.scrollController});

  @override
  State<_ModernHomeTab> createState() => _ModernHomeTabState();
}

class _ModernHomeTabState extends State<_ModernHomeTab> 
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userData?['fullName'] ?? 'Profissional';
    final firstName = userName.split(' ').first;

    return CustomScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Modern App Bar with Glassmorphism
        SliverAppBar(
          expandedHeight: 280,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient mesh background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                        Color(0xFFEC4899),
                      ],
                    ),
                  ),
                ),
                
                // Glassmorphism overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF0A0A0A).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  firstName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildHeaderButton(
                                  Icons.notifications_none_rounded,
                                  hasNotification: true,
                                ),
                                const SizedBox(width: 12),
                                _buildAvatarButton(firstName),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        
                        // Earnings Card with Glassmorphism
                        _buildEarningsCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Quick Stats Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildQuickStats(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        
        // Today's Schedule Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Agenda de Hoje', 'Ver tudo'),
                const SizedBox(height: 16),
                _buildTodaySchedule(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        
        // Quick Actions Grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Ações Rápidas', null),
                const SizedBox(height: 16),
                _buildQuickActionsGrid(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        
        // Recent Activity
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Atividade Recente', 'Ver mais'),
                const SizedBox(height: 16),
                _buildRecentActivity(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderButton(IconData icon, {bool hasNotification = false}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (hasNotification)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarButton(String firstName) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          firstName[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ganhos este mês',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'R\$ 4.850,00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          color: Color(0xFF10B981),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '+12% vs mês anterior',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.event_available_rounded,
            value: '8',
            label: 'Agendamentos hoje',
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star_rounded,
            value: '4.9',
            label: 'Avaliação média',
            color: const Color(0xFFFBBF24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.pending_actions_rounded,
            value: '3',
            label: 'Pendentes',
            color: const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: () {},
            child: Text(
              action,
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTodaySchedule() {
    return Column(
      children: [
        _buildScheduleItem(
          time: '09:00',
          clientName: 'Maria Silva',
          service: 'Limpeza Residencial',
          address: 'Rua das Flores, 123',
          status: 'confirmed',
        ),
        const SizedBox(height: 12),
        _buildScheduleItem(
          time: '11:30',
          clientName: 'João Santos',
          service: 'Organização de Escritório',
          address: 'Av. Principal, 456',
          status: 'pending',
        ),
        const SizedBox(height: 12),
        _buildScheduleItem(
          time: '14:00',
          clientName: 'Ana Costa',
          service: 'Limpeza Pós-Obra',
          address: 'Rua Nova, 789',
          status: 'confirmed',
        ),
      ],
    );
  }

  Widget _buildScheduleItem({
    required String time,
    required String clientName,
    required String service,
    required String address,
    required String status,
  }) {
    Color statusColor = status == 'confirmed' 
        ? const Color(0xFF10B981)
        : const Color(0xFFFBBF24);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                        clientName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status == 'confirmed' ? 'Confirmado' : 'Pendente',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  service,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey[600],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      address,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(
          icon: Icons.add_circle_outline_rounded,
          title: 'Novo Agendamento',
          gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        _buildActionCard(
          icon: Icons.receipt_long_rounded,
          title: 'Registrar Pagamento',
          gradient: const [Color(0xFF10B981), Color(0xFF059669)],
        ),
        _buildActionCard(
          icon: Icons.people_outline_rounded,
          title: 'Meus Clientes',
          gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        _buildActionCard(
          icon: Icons.insights_rounded,
          title: 'Relatórios',
          gradient: const [Color(0xFFEC4899), Color(0xFFBE185D)],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      children: [
        _buildActivityItem(
          icon: Icons.check_circle_rounded,
          title: 'Serviço concluído',
          subtitle: 'Maria Silva - Limpeza Residencial',
          time: 'Há 2 horas',
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          icon: Icons.star_rounded,
          title: 'Nova avaliação',
          subtitle: '5 estrelas de João Santos',
          time: 'Há 5 horas',
          color: const Color(0xFFFBBF24),
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          icon: Icons.attach_money_rounded,
          title: 'Pagamento recebido',
          subtitle: 'R\$ 250,00 - Ana Costa',
          time: 'Ontem',
          color: const Color(0xFF6366F1),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia,';
    } else if (hour < 18) {
      return 'Boa tarde,';
    } else {
      return 'Boa noite,';
    }
  }
}

// Custom Painter for Mesh Gradient Effect
class _MeshGradientPainter extends CustomPainter {
  final double animation;
  
  _MeshGradientPainter(this.animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    
    // Animated circles for mesh effect
    final circle1 = Offset(
      size.width * (0.3 + 0.2 * math.sin(animation * 2 * math.pi)),
      size.height * (0.2 + 0.1 * math.cos(animation * 2 * math.pi)),
    );
    
    final circle2 = Offset(
      size.width * (0.7 + 0.2 * math.cos(animation * 2 * math.pi)),
      size.height * (0.8 + 0.1 * math.sin(animation * 2 * math.pi)),
    );
    
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF6366F1).withOpacity(0.3),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: circle1, radius: 200));
    canvas.drawCircle(circle1, 200, paint);
    
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFFEC4899).withOpacity(0.3),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: circle2, radius: 200));
    canvas.drawCircle(circle2, 200, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}