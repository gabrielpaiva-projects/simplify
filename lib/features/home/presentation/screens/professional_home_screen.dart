import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/models/user_model.dart';

class ProfessionalHomeScreen extends StatefulWidget {
  const ProfessionalHomeScreen({super.key});

  @override
  State<ProfessionalHomeScreen> createState() => _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState extends State<ProfessionalHomeScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late List<AnimationController> _cardControllers;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  // State
  int _selectedMenuIndex = 0;
  bool _isMenuExpanded = true;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
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
    
    _cardControllers = List.generate(
      6, // Number of cards
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
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
      controller.forward();
    }
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.deepBlack : AppColors.iceWhite,
      body: Row(
        children: [
          // Side Navigation Menu (Desktop/Tablet)
          if (isDesktop || isTablet)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isMenuExpanded ? 280 : 80,
              child: _buildSideMenu(isDarkMode),
            ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(isDarkMode, isDesktop, isTablet),
                
                // Dashboard Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildDashboardContent(isDarkMode),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Bottom Navigation (Mobile)
      bottomNavigationBar: (!isDesktop && !isTablet)
          ? _buildBottomNavigation(isDarkMode)
          : null,
    );
  }
  
  Widget _buildSideMenu(bool isDarkMode) {
    final menuItems = [
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard', 'badge': null},
      {'icon': Icons.calendar_month_rounded, 'label': 'Agenda', 'badge': '3'},
      {'icon': Icons.people_rounded, 'label': 'Clientes', 'badge': null},
      {'icon': Icons.medical_services_rounded, 'label': 'Serviços', 'badge': null},
      {'icon': Icons.attach_money_rounded, 'label': 'Financeiro', 'badge': null},
      {'icon': Icons.bar_chart_rounded, 'label': 'Relatórios', 'badge': null},
      {'icon': Icons.settings_rounded, 'label': 'Configurações', 'badge': null},
    ];
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.greyBlack : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Brand
          Container(
            height: 100,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.mediumGreen,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (_isMenuExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MedPro',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : AppColors.deepBlack,
                          ),
                        ),
                        Text(
                          'Portal Profissional',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.6)
                                : AppColors.charcoalGrey.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = _selectedMenuIndex == index;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMenuIndex = index;
                        });
                        HapticFeedback.lightImpact();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: _isMenuExpanded ? 16 : 8,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : isDarkMode
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : AppColors.charcoalGrey,
                              size: 24,
                            ),
                            if (_isMenuExpanded) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item['label'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primaryGreen
                                        : isDarkMode
                                            ? Colors.white.withValues(alpha: 0.9)
                                            : AppColors.charcoalGrey,
                                  ),
                                ),
                              ),
                              if (item['badge'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item['badge'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Toggle Menu Button
          Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _isMenuExpanded = !_isMenuExpanded;
                });
              },
              icon: Icon(
                _isMenuExpanded
                    ? Icons.keyboard_arrow_left
                    : Icons.keyboard_arrow_right,
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.6)
                    : AppColors.charcoalGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopBar(bool isDarkMode, bool isDesktop, bool isTablet) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.userData?['name'] ?? 'Profissional';
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.greyBlack : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mobile Menu Button
          if (!isDesktop && !isTablet)
            IconButton(
              onPressed: () {
                // Open drawer
              },
              icon: Icon(
                Icons.menu_rounded,
                color: isDarkMode ? Colors.white : AppColors.deepBlack,
              ),
            ),
          
          // Welcome Message
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo de volta!',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppColors.charcoalGrey.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.deepBlack,
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          Row(
            children: [
              // Search Button
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.charcoalGrey
                      : AppColors.iceWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.search_rounded,
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.charcoalGrey,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Notifications
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.charcoalGrey
                          : AppColors.iceWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.charcoalGrey,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode ? AppColors.greyBlack : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 12),
              
              // Profile
              PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isDarkMode ? AppColors.charcoalGrey : Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.mediumGreen,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 20,
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.charcoalGrey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Meu Perfil',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : AppColors.deepBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          size: 20,
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.charcoalGrey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Configurações',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : AppColors.deepBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 20,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sair',
                          style: TextStyle(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'logout') {
                    _handleLogout();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDashboardContent(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards Row
          _buildStatsCards(isDarkMode),
          
          const SizedBox(height: 24),
          
          // Charts and Recent Activities Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chart
              Expanded(
                flex: 2,
                child: _buildChartCard(isDarkMode),
              ),
              
              const SizedBox(width: 24),
              
              // Recent Activities
              Expanded(
                child: _buildRecentActivitiesCard(isDarkMode),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Appointments and Tasks Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Appointments
              Expanded(
                child: _buildAppointmentsCard(isDarkMode),
              ),
              
              const SizedBox(width: 24),
              
              // Tasks
              Expanded(
                child: _buildTasksCard(isDarkMode),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsCards(bool isDarkMode) {
    final stats = [
      {
        'title': 'Consultas Hoje',
        'value': '8',
        'change': '+12%',
        'icon': Icons.calendar_today,
        'color': AppColors.primaryGreen,
      },
      {
        'title': 'Pacientes Ativos',
        'value': '124',
        'change': '+5%',
        'icon': Icons.people,
        'color': AppColors.info,
      },
      {
        'title': 'Receita Mensal',
        'value': 'R\$ 15.8k',
        'change': '+18%',
        'icon': Icons.attach_money,
        'color': AppColors.success,
      },
      {
        'title': 'Taxa de Satisfação',
        'value': '98%',
        'change': '+2%',
        'icon': Icons.star,
        'color': AppColors.warning,
      },
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        
        return AnimatedBuilder(
          animation: _cardControllers[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _cardControllers[index].value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.charcoalGrey : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (stat['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            stat['icon'] as IconData,
                            color: stat['color'] as Color,
                            size: 24,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stat['change'] as String,
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat['value'] as String,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : AppColors.deepBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stat['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.6)
                                : AppColors.charcoalGrey.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildChartCard(bool isDarkMode) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.charcoalGrey : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Atendimentos Semanais',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.deepBlack,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_vert,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppColors.charcoalGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Placeholder for chart
          Expanded(
            child: Center(
              child: Text(
                'Gráfico de atendimentos',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.4)
                      : AppColors.charcoalGrey.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentActivitiesCard(bool isDarkMode) {
    final activities = [
      {
        'title': 'Nova consulta agendada',
        'subtitle': 'Maria Silva - 14:00',
        'icon': Icons.calendar_month,
        'color': AppColors.primaryGreen,
      },
      {
        'title': 'Pagamento recebido',
        'subtitle': 'João Santos - R\$ 250',
        'icon': Icons.payment,
        'color': AppColors.success,
      },
      {
        'title': 'Avaliação recebida',
        'subtitle': '5 estrelas de Ana Costa',
        'icon': Icons.star,
        'color': AppColors.warning,
      },
    ];
    
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.charcoalGrey : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atividades Recentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.deepBlack,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: activities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.greyBlack
                        : AppColors.iceWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (activity['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          activity['icon'] as IconData,
                          color: activity['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white
                                    : AppColors.deepBlack,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activity['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : AppColors.charcoalGrey.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppointmentsCard(bool isDarkMode) {
    final appointments = [
      {'time': '09:00', 'name': 'Carlos Mendes', 'type': 'Consulta'},
      {'time': '10:30', 'name': 'Ana Paula', 'type': 'Retorno'},
      {'time': '14:00', 'name': 'Roberto Silva', 'type': 'Avaliação'},
      {'time': '15:30', 'name': 'Juliana Costa', 'type': 'Consulta'},
    ];
    
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.charcoalGrey : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Agenda de Hoje',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.deepBlack,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Ver tudo',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: appointments.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          appointment['time']!,
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment['name']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white
                                    : AppColors.deepBlack,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              appointment['type']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : AppColors.charcoalGrey.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_horiz,
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.4)
                              : AppColors.charcoalGrey.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTasksCard(bool isDarkMode) {
    final tasks = [
      {'title': 'Revisar prontuário de Maria Silva', 'done': false},
      {'title': 'Enviar relatório mensal', 'done': false},
      {'title': 'Atualizar agenda da próxima semana', 'done': true},
      {'title': 'Responder e-mails pendentes', 'done': false},
    ];
    
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.charcoalGrey : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tarefas Pendentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.deepBlack,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.greyBlack
                        : AppColors.iceWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: task['done'] as bool,
                        onChanged: (value) {},
                        activeColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.white
                                : AppColors.deepBlack,
                            decoration: (task['done'] as bool)
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomNavigation(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.greyBlack : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedMenuIndex,
        onTap: (index) {
          setState(() {
            _selectedMenuIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.6)
            : AppColors.charcoalGrey.withValues(alpha: 0.7),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Mais',
          ),
        ],
      ),
    );
  }
  
  void _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    
    if (shouldLogout == true) {
      await authProvider.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}