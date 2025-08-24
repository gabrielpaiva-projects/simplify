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
    with SingleTickerProviderStateMixin {
  String _selectedResidenceType = 'apartamento';
  int _roomCount = 1;
  int _bathroomCount = 1;
  bool _includeCleaningProducts = false;
  
  late AnimationController _priceAnimationController;
  late Animation<double> _priceAnimation;
  
  double _currentPrice = 94.0;
  double _targetPrice = 94.0;
  
  final Map<String, double> _basePrices = {
    'studio': 94.0,
    'apartamento': 94.0,
    'casa': 105.0,
  };

  final Map<String, IconData> _residenceIcons = {
    'studio': Icons.weekend,
    'apartamento': Icons.apartment,
    'casa': Icons.home,
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
      curve: Curves.easeInOut,
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
        curve: Curves.easeInOut,
      ));
      _priceAnimationController.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Color(0xFF2C3E50),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agendamento',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Serviço de Limpeza',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 3,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 3,
                    color: AppColors.primaryGreen.withOpacity(0.2),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 3,
                    color: AppColors.primaryGreen.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Residence Type Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.home_work,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Tipo de Residência',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildResidenceOption('studio', 'Studio', 'R\$ 94'),
                            const SizedBox(width: 10),
                            _buildResidenceOption('apartamento', 'Apartamento', 'R\$ 94'),
                            const SizedBox(width: 10),
                            _buildResidenceOption('casa', 'Casa', 'R\$ 105'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Rooms and Bathrooms Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.meeting_room,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Detalhes do Imóvel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Rooms Counter
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.bed,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cômodos',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    'Sem contar banheiros',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: _roomCount > 1
                                        ? () {
                                            HapticFeedback.lightImpact();
                                            setState(() {
                                              _roomCount--;
                                              _calculatePrice();
                                            });
                                          }
                                        : null,
                                    icon: Icon(
                                      Icons.remove,
                                      color: _roomCount > 1 
                                          ? const Color(0xFF2C3E50)
                                          : Colors.grey[400],
                                      size: 18,
                                    ),
                                  ),
                                  Container(
                                    constraints: const BoxConstraints(minWidth: 30),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _roomCount.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _roomCount++;
                                        _calculatePrice();
                                      });
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: AppColors.primaryGreen,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // Bathrooms Counter
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.bathroom,
                                color: Colors.purple[700],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Banheiros',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    'Completos e lavabos',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: _bathroomCount > 1
                                        ? () {
                                            HapticFeedback.lightImpact();
                                            setState(() {
                                              _bathroomCount--;
                                              _calculatePrice();
                                            });
                                          }
                                        : null,
                                    icon: Icon(
                                      Icons.remove,
                                      color: _bathroomCount > 1 
                                          ? const Color(0xFF2C3E50)
                                          : Colors.grey[400],
                                      size: 18,
                                    ),
                                  ),
                                  Container(
                                    constraints: const BoxConstraints(minWidth: 30),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _bathroomCount.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _bathroomCount++;
                                        _calculatePrice();
                                      });
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: AppColors.primaryGreen,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Additional Options
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Serviços Adicionais',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Cleaning Products Option
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
                                  : const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _includeCleaningProducts
                                    ? AppColors.primaryGreen
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _includeCleaningProducts
                                        ? AppColors.primaryGreen
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.cleaning_services,
                                    color: _includeCleaningProducts
                                        ? Colors.white
                                        : Colors.orange[700],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Incluir produtos de limpeza',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2C3E50),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '+20%',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.orange[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Produtos profissionais inclusos',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
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
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // What's Included Button
                        TextButton.icon(
                          onPressed: _showIncludedServices,
                          icon: Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.primaryGreen,
                          ),
                          label: Text(
                            'Ver o que está incluso no serviço',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 14,
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
          
          // Bottom Price and Continue
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Valor estimado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedBuilder(
                            animation: _priceAnimation,
                            builder: (context, child) {
                              return Text(
                                'R\$ ${_priceAnimation.value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryGreen,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 140,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _showConfirmation();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continuar',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildResidenceOption(String value, String label, String price) {
    final isSelected = _selectedResidenceType == value;
    final icon = _residenceIcons[value]!;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedResidenceType = value;
            _calculatePrice();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primaryGreen 
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected 
                      ? Colors.white.withOpacity(0.8)
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIncludedServices() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Serviços Inclusos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildIncludedItem(Icons.home, 'Limpeza completa de todos os cômodos'),
            _buildIncludedItem(Icons.auto_fix_high, 'Organização e arrumação básica'),
            _buildIncludedItem(Icons.sanitizer, 'Desinfecção de banheiros'),
            _buildIncludedItem(Icons.window, 'Limpeza de vidros e espelhos'),
            _buildIncludedItem(Icons.grass, 'Aspiração e limpeza de pisos'),
            _buildIncludedItem(Icons.delete_outline, 'Retirada e organização do lixo'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildIncludedItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
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
                  size: 32,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Confirmação',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Revise os detalhes do seu pedido',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      Icons.home,
                      'Tipo de residência',
                      _selectedResidenceType == 'studio' 
                          ? 'Studio' 
                          : _selectedResidenceType == 'apartamento'
                              ? 'Apartamento'
                              : 'Casa',
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      Icons.bed,
                      'Cômodos',
                      '$_roomCount ${_roomCount > 1 ? "cômodos" : "cômodo"}',
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      Icons.bathroom,
                      'Banheiros',
                      '$_bathroomCount ${_bathroomCount > 1 ? "banheiros" : "banheiro"}',
                    ),
                    if (_includeCleaningProducts) ...[
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        Icons.cleaning_services,
                        'Produtos de limpeza',
                        'Inclusos',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Valor Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      'R\$ ${_targetPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Voltar',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }
}