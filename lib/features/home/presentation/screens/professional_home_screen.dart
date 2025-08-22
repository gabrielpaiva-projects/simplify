import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'schedule_screen.dart';
import 'payments_screen.dart';
import 'chat_list_screen.dart';
import '../widgets/home_stat_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/upcoming_appointment_card.dart';

class ProfessionalHomeScreen extends StatefulWidget {
  const ProfessionalHomeScreen({super.key});

  @override
  State<ProfessionalHomeScreen> createState() => _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState extends State<ProfessionalHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const ScheduleScreen(),
    const PaymentsScreen(),
    const ChatListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userData?['fullName'] ?? 'Profissional';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF2A2A2A),
          selectedItemColor: const Color(0xFF4A90E2),
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Agenda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_outlined),
              activeIcon: Icon(Icons.attach_money),
              label: 'Financeiro',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userData?['fullName'] ?? 'Profissional';
    final firstName = userName.split(' ').first;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header com saudação
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4A90E2),
                    const Color(0xFF357ABD),
                  ],
                ),
              ),
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
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            firstName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Avatar e notificações
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              // TODO: Implementar notificações
                            },
                            icon: Stack(
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF4A90E2),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              // TODO: Implementar perfil
                            },
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  firstName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Data atual
                  Text(
                    _getCurrentDate(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Cards de estatísticas
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.5,
              ),
              delegate: SliverChildListDelegate([
                HomeStatCard(
                  title: 'Hoje',
                  value: '5',
                  subtitle: 'Agendamentos',
                  icon: Icons.today,
                  color: const Color(0xFF4CAF50),
                  onTap: () {},
                ),
                HomeStatCard(
                  title: 'Esta Semana',
                  value: '23',
                  subtitle: 'Agendamentos',
                  icon: Icons.calendar_view_week,
                  color: const Color(0xFF2196F3),
                  onTap: () {},
                ),
                HomeStatCard(
                  title: 'A Receber',
                  value: 'R\$ 2.450',
                  subtitle: 'Este mês',
                  icon: Icons.account_balance_wallet,
                  color: const Color(0xFFFF9800),
                  onTap: () {},
                ),
                HomeStatCard(
                  title: 'Avaliação',
                  value: '4.8',
                  subtitle: '127 avaliações',
                  icon: Icons.star,
                  color: const Color(0xFFFFC107),
                  onTap: () {},
                ),
              ]),
            ),
          ),

          // Ações rápidas
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ações Rápidas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.add_circle_outline,
                          label: 'Novo\nAgendamento',
                          color: const Color(0xFF4CAF50),
                          onTap: () {
                            // TODO: Implementar novo agendamento
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.person_add_outlined,
                          label: 'Adicionar\nCliente',
                          color: const Color(0xFF2196F3),
                          onTap: () {
                            // TODO: Implementar adicionar cliente
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.receipt_outlined,
                          label: 'Registrar\nPagamento',
                          color: const Color(0xFFFF9800),
                          onTap: () {
                            // TODO: Implementar registrar pagamento
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Próximos agendamentos
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Próximos Agendamentos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navegar para a aba de agenda
                        },
                        child: const Text(
                          'Ver todos',
                          style: TextStyle(
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Lista de próximos agendamentos
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return UpcomingAppointmentCard(
                        clientName: 'João Silva',
                        service: 'Instalação de Ar Condicionado',
                        time: '09:00 - 10:30',
                        address: 'Rua das Flores, 123 - Centro',
                        isToday: index == 0,
                        onTap: () {
                          // TODO: Implementar detalhes do agendamento
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Espaço extra no final
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
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

  String _getCurrentDate() {
    final now = DateTime.now();
    final weekDays = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado'
    ];
    final months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro'
    ];
    
    return '${weekDays[now.weekday % 7]}, ${now.day} de ${months[now.month - 1]} de ${now.year}';
  }
}