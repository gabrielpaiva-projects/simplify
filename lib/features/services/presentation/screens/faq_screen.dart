import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  // Search
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Selected Category
  String _selectedCategory = 'all';
  
  // Expanded FAQ Items
  final Set<int> _expandedItems = {};
  
  // FAQ Categories
  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'Todas', 'icon': Icons.apps},
    {'id': 'services', 'name': 'Serviços', 'icon': Icons.cleaning_services},
    {'id': 'payment', 'name': 'Pagamento', 'icon': Icons.payment},
    {'id': 'scheduling', 'name': 'Agendamento', 'icon': Icons.calendar_today},
    {'id': 'account', 'name': 'Conta', 'icon': Icons.person},
  ];
  
  // FAQ Items
  final List<Map<String, dynamic>> _faqItems = [
    {
      'id': 1,
      'category': 'services',
      'question': 'Quais serviços de limpeza vocês oferecem?',
      'answer': 'Oferecemos limpeza residencial completa, incluindo:\n\n• Limpeza padrão (manutenção regular)\n• Limpeza pesada (faxina completa)\n• Limpeza pós-obra\n• Limpeza de mudança\n• Passadoria\n• Limpeza de vidros\n\nTodos os serviços podem ser personalizados de acordo com suas necessidades.',
    },
    {
      'id': 2,
      'category': 'services',
      'question': 'Os produtos de limpeza estão inclusos?',
      'answer': 'Você pode escolher entre duas opções:\n\n1. Serviço COM produtos inclusos - trazemos todos os materiais necessários\n2. Serviço SEM produtos - utilizamos os produtos disponíveis em sua casa\n\nA diferença de preço é informada durante o agendamento.',
    },
    {
      'id': 3,
      'category': 'payment',
      'question': 'Quais formas de pagamento são aceitas?',
      'answer': 'Aceitamos as seguintes formas de pagamento:\n\n• PIX (10% de desconto)\n• Cartão de crédito (até 3x sem juros)\n• Cartão de débito\n• Dinheiro (pago diretamente ao profissional)\n\nO pagamento é processado após a confirmação do serviço.',
    },
    {
      'id': 4,
      'category': 'payment',
      'question': 'Posso parcelar o pagamento?',
      'answer': 'Sim! Oferecemos parcelamento em até 3x sem juros no cartão de crédito para serviços acima de R\$ 150,00.\n\nPara valores superiores a R\$ 500,00, consulte condições especiais de parcelamento.',
    },
    {
      'id': 5,
      'category': 'scheduling',
      'question': 'Com quanto tempo de antecedência devo agendar?',
      'answer': 'Recomendamos agendar com pelo menos 24 horas de antecedência para garantir disponibilidade.\n\nPara urgências, temos a opção de "Agendamento Expresso" com taxa adicional, sujeito à disponibilidade de profissionais.',
    },
    {
      'id': 6,
      'category': 'scheduling',
      'question': 'Posso cancelar ou reagendar meu serviço?',
      'answer': 'Sim, você pode cancelar ou reagendar seu serviço:\n\n• Cancelamento gratuito até 24h antes\n• Reagendamento gratuito até 12h antes\n• Cancelamentos em cima da hora podem ter taxa de 20%\n\nPara cancelar ou reagendar, acesse "Meus Agendamentos" no app.',
    },
    {
      'id': 7,
      'category': 'scheduling',
      'question': 'Quanto tempo dura a limpeza?',
      'answer': 'O tempo varia de acordo com o tipo de serviço e tamanho do imóvel:\n\n• Studio/1 quarto: 2-3 horas\n• 2 quartos: 3-4 horas\n• 3 quartos: 4-5 horas\n• Casa: 4-6 horas\n\nLimpeza pesada ou pós-obra pode levar mais tempo.',
    },
    {
      'id': 8,
      'category': 'account',
      'question': 'Como faço para criar uma conta?',
      'answer': 'Criar uma conta é simples:\n\n1. Clique em "Cadastrar" na tela inicial\n2. Informe seus dados pessoais\n3. Adicione seu endereço\n4. Confirme seu e-mail ou telefone\n\nVocê também pode fazer login com Google ou Facebook.',
    },
    {
      'id': 9,
      'category': 'account',
      'question': 'Meus dados estão seguros?',
      'answer': 'Sim! Levamos sua privacidade muito a sério:\n\n• Dados criptografados\n• Conformidade com LGPD\n• Pagamentos processados com segurança PCI DSS\n• Nunca compartilhamos seus dados com terceiros\n\nVocê pode solicitar a exclusão dos seus dados a qualquer momento.',
    },
    {
      'id': 10,
      'category': 'services',
      'question': 'Os profissionais são confiáveis?',
      'answer': 'Todos os nossos profissionais passam por:\n\n• Verificação de antecedentes criminais\n• Treinamento de qualidade\n• Avaliação contínua pelos clientes\n• Seguro de responsabilidade civil\n\nApenas profissionais com avaliação acima de 4.5 estrelas permanecem ativos.',
    },
    {
      'id': 11,
      'category': 'services',
      'question': 'E se algo for danificado durante a limpeza?',
      'answer': 'Temos seguro para cobrir eventuais danos:\n\n1. Tire fotos do dano\n2. Notifique-nos em até 24h\n3. Nossa equipe avaliará o caso\n4. Reembolso ou reparo em até 7 dias úteis\n\nDanos intencionais ou por negligência do cliente não são cobertos.',
    },
    {
      'id': 12,
      'category': 'payment',
      'question': 'Existe taxa adicional para fins de semana?',
      'answer': 'Sim, aplicamos uma taxa adicional de 20% para serviços aos sábados e 30% aos domingos e feriados.\n\nEssa taxa é claramente informada durante o processo de agendamento.',
    },
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
    )..forward();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  List<Map<String, dynamic>> get _filteredItems {
    return _faqItems.where((item) {
      final matchesCategory = _selectedCategory == 'all' || item['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          item['question'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['answer'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar with Search
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.black87,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryGreen.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      FadeTransition(
                        opacity: _fadeController,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: _fadeController,
                        child: const Text(
                          'Central de Ajuda',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _fadeController,
                        child: Text(
                          'Encontre respostas para suas dúvidas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Search Bar
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.easeOutCubic,
                )),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar por palavra-chave...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Categories
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category['id'];
                  
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedCategory = category['id'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.primaryGreen 
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            category['icon'],
                            size: 18,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected 
                                  ? FontWeight.w600 
                                  : FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.grey[700],
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
          
          // FAQ Items
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (_filteredItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma pergunta encontrada',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tente buscar com outras palavras',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final item = _filteredItems[index];
                  final isExpanded = _expandedItems.contains(item['id']);
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isExpanded 
                            ? AppColors.primaryGreen.withOpacity(0.3)
                            : Colors.grey[200]!,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        childrenPadding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        initiallyExpanded: isExpanded,
                        onExpansionChanged: (expanded) {
                          HapticFeedback.lightImpact();
                          setState(() {
                            if (expanded) {
                              _expandedItems.add(item['id']);
                            } else {
                              _expandedItems.remove(item['id']);
                            }
                          });
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getCategoryIcon(item['category']),
                            size: 20,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        title: Text(
                          item['question'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        trailing: AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: isExpanded ? 0.5 : 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isExpanded
                                  ? AppColors.primaryGreen
                                  : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: isExpanded ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              item['answer'],
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Esta resposta foi útil?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 16),
                              _buildFeedbackButton(
                                icon: Icons.thumb_up_outlined,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _showFeedbackSnackbar(true);
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildFeedbackButton(
                                icon: Icons.thumb_down_outlined,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _showFeedbackSnackbar(false);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _filteredItems.isEmpty ? 1 : _filteredItems.length,
              ),
            ),
          ),
          
          // Contact Support Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.primaryGreen.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.headset_mic,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ainda precisa de ajuda?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nossa equipe está pronta para ajudar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildContactButton(
                        icon: Icons.chat,
                        label: 'Chat',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          // Open chat
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildContactButton(
                        icon: Icons.email,
                        label: 'E-mail',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          // Open email
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildContactButton(
                        icon: Icons.phone,
                        label: 'Ligar',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          // Make call
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeedbackButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }
  
  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'services':
        return Icons.cleaning_services;
      case 'payment':
        return Icons.payment;
      case 'scheduling':
        return Icons.calendar_today;
      case 'account':
        return Icons.person;
      default:
        return Icons.help_outline;
    }
  }
  
  void _showFeedbackSnackbar(bool isPositive) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isPositive 
              ? 'Obrigado pelo feedback positivo!' 
              : 'Obrigado pelo feedback. Vamos melhorar!',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isPositive ? Colors.green[600] : Colors.orange[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}