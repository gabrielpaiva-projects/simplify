import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class CleaningScheduleScreen extends StatefulWidget {
  final String serviceTitle;
  
  const CleaningScheduleScreen({
    Key? key,
    required this.serviceTitle,
  }) : super(key: key);

  @override
  State<CleaningScheduleScreen> createState() => _CleaningScheduleScreenState();
}

class _CleaningScheduleScreenState extends State<CleaningScheduleScreen>
    with TickerProviderStateMixin {
  // Tipo de residência
  String _selectedResidenceType = 'apartamento';
  
  // Contadores
  int _roomCount = 1;
  int _bathroomCount = 1;
  
  // Produtos de limpeza
  bool _includeCleaningProducts = false;
  
  // Animações
  late AnimationController _priceAnimationController;
  late Animation<double> _priceAnimation;
  
  double _currentPrice = 94.0;
  double _targetPrice = 94.0;
  
  // Preços base
  final Map<String, double> _basePrices = {
    'studio': 94.0,
    'apartamento': 94.0,
    'casa': 105.0,
  };

  @override
  void initState() {
    super.initState();
    
    _priceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _priceAnimation = Tween<double>(
      begin: _currentPrice,
      end: _targetPrice,
    ).animate(CurvedAnimation(
      parent: _priceAnimationController,
      curve: Curves.easeOutQuart,
    ));
    
    _calculatePrice();
  }

  @override
  void dispose() {
    _priceAnimationController.dispose();
    super.dispose();
  }

  void _calculatePrice() {
    double basePrice = _basePrices[_selectedResidenceType] ?? 94.0;
    double roomsPrice = basePrice * (1 + ((_roomCount - 1) * 0.10));
    double bathroomsPrice = roomsPrice * (1 + ((_bathroomCount - 1) * 0.15));
    double finalPrice = _includeCleaningProducts 
        ? bathroomsPrice * 1.20 
        : bathroomsPrice;
    
    setState(() {
      _currentPrice = _targetPrice;
      _targetPrice = finalPrice;
      _priceAnimation = Tween<double>(
        begin: _currentPrice,
        end: _targetPrice,
      ).animate(CurvedAnimation(
        parent: _priceAnimationController,
        curve: Curves.easeOutQuart,
      ));
      _priceAnimationController.forward(from: 0);
    });
  }

  void _showIncludedServices() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'O que está incluso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 24),
            _buildIncludedItem('Limpeza completa da cozinha'),
            _buildIncludedItem('Sala de estar e jantar'),
            _buildIncludedItem('Todos os quartos'),
            _buildIncludedItem('Banheiros desinfetados'),
            _buildIncludedItem('Áreas externas e varandas'),
            _buildIncludedItem('Recolhimento do lixo'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Entendi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildIncludedItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
        ],
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1A1A1A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.serviceTitle,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo de Residência
              const Text(
                'Tipo de residência',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildResidenceOption('studio', 'Studio', 'R\$ 94'),
                  const SizedBox(width: 8),
                  _buildResidenceOption('apartamento', 'Apartamento', 'R\$ 94'),
                  const SizedBox(width: 8),
                  _buildResidenceOption('casa', 'Casa', 'R\$ 105'),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Cômodos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cômodos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'Sem contar banheiros',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  _buildCounter(
                    value: _roomCount,
                    onChanged: (value) {
                      setState(() {
                        _roomCount = value;
                        _calculatePrice();
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Banheiros
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Banheiros',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  _buildCounter(
                    value: _bathroomCount,
                    onChanged: (value) {
                      setState(() {
                        _bathroomCount = value;
                        _calculatePrice();
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Produtos de Limpeza
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _includeCleaningProducts = !_includeCleaningProducts;
                    _calculatePrice();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _includeCleaningProducts 
                        ? AppColors.primaryGreen.withOpacity(0.05)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _includeCleaningProducts 
                          ? AppColors.primaryGreen
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _includeCleaningProducts
                              ? AppColors.primaryGreen
                              : Colors.transparent,
                          border: Border.all(
                            color: _includeCleaningProducts
                                ? AppColors.primaryGreen
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: _includeCleaningProducts
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Incluir produtos de limpeza',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Adiciona 20% ao valor total',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Botão O que está incluso
              TextButton(
                onPressed: _showIncludedServices,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'O que está incluso',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Preço
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedBuilder(
                    animation: _priceAnimation,
                    builder: (context, child) {
                      return Text(
                        'R\$ ${_priceAnimation.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // Botão
              SizedBox(
                height: 48,
                width: 140,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _showConfirmationModal();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 15,
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
    );
  }

  Widget _buildResidenceOption(String value, String label, String price) {
    final isSelected = _selectedResidenceType == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedResidenceType = value;
            _calculatePrice();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryGreen : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white70 : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounter({
    required int value,
    required Function(int) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: value > 1
                ? () {
                    HapticFeedback.lightImpact();
                    onChanged(value - 1);
                  }
                : null,
            icon: Icon(
              Icons.remove,
              color: value > 1 ? Colors.grey[700] : Colors.grey[300],
              size: 20,
            ),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onChanged(value + 1);
            },
            icon: Icon(
              Icons.add,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: AppColors.primaryGreen,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pedido Confirmado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Serviço agendado com sucesso',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Residência',
                    _selectedResidenceType == 'studio' 
                        ? 'Studio' 
                        : _selectedResidenceType == 'apartamento'
                            ? 'Apartamento'
                            : 'Casa',
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Cômodos',
                    '$_roomCount',
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Banheiros',
                    '$_bathroomCount',
                  ),
                  if (_includeCleaningProducts) ...[
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      'Produtos',
                      'Inclusos',
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Total',
                    'R\$ ${_targetPrice.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Fechar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppColors.primaryGreen : const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}