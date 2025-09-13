import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/enums/cleaning_type.dart';
import 'pix_payment_screen.dart';

class CleaningScheduleScreen extends StatefulWidget {
  final String serviceTitle;
  final CleaningType cleaningType;
  
  const CleaningScheduleScreen({
    Key? key,
    required this.serviceTitle,
    this.cleaningType = CleaningType.standard,
  }) : super(key: key);

  @override
  State<CleaningScheduleScreen> createState() => _CleaningScheduleScreenState();
}

class _CleaningScheduleScreenState extends State<CleaningScheduleScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Property Details
  String _selectedResidence = 'apartment';
  int _rooms = 2;
  int _bathrooms = 1;
  bool _includeProducts = false;
  bool _includePets = false;
  
  // Schedule
  DateTime? _selectedDate;
  String? _selectedTime;
  
  // Payment
  String _selectedPaymentMethod = 'pix';
  
  // Pricing
  double get _totalPrice {
    double price = 149.0;
    
    if (_selectedResidence == 'studio') {
      price = 99.0;
    } else if (_selectedResidence == 'house') {
      price = 179.0;
    }
    
    // Additional rooms
    if (_rooms > 2) {
      price += (_rooms - 2) * 30;
    }
    
    // Additional bathrooms
    if (_bathrooms > 1) {
      price += (_bathrooms - 1) * 25;
    }
    
    // Extras
    if (_includeProducts) price += 35;
    if (_includePets) price += 25;
    
    return price;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          widget.serviceTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF32BCAD).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'R\$ ${_totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFF32BCAD),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            height: 4,
            color: Colors.grey[200],
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentStep + 1) / 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF32BCAD),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(2),
                    bottomRight: Radius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildPropertyStep(),
                _buildScheduleStep(),
                _buildPaymentStep(),
              ],
            ),
          ),
          
          // Bottom Navigation
          Container(
            padding: const EdgeInsets.all(16),
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
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _canProceed() ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF32BCAD),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _currentStep == 2 ? 'Confirmar Agendamento' : 'Continuar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _selectedDate != null && _selectedTime != null;
      case 2:
        return _selectedPaymentMethod.isNotEmpty;
      default:
        return false;
    }
  }
  
  void _handleNext() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final confirmation
      if (_selectedPaymentMethod == 'pix') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PixPaymentScreen(
              pixCode: _generatePixCode(),
              amount: _totalPrice,
              serviceTitle: widget.serviceTitle,
              selectedDate: _selectedDate!,
              selectedTime: _selectedTime!,
            ),
          ),
        );
      } else {
        _showSuccessDialog();
      }
    }
  }
  
  String _generatePixCode() {
    return '00020126330014BR.GOV.BCB.PIX0111${DateTime.now().millisecondsSinceEpoch}5204000053039865802BR6009SAO PAULO62140510${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}6304';
  }
  
  Widget _buildPropertyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de Imóvel',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Property Type Selection
          Row(
            children: [
              Expanded(
                child: _buildPropertyCard(
                  'studio',
                  'Studio',
                  Icons.apartment,
                  'Até 50m²',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPropertyCard(
                  'apartment',
                  'Apartamento',
                  Icons.apartment,
                  '50-150m²',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPropertyCard(
                  'house',
                  'Casa',
                  Icons.home,
                  'Acima 150m²',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Room Configuration
          if (_selectedResidence != 'studio') ...[
            const Text(
              'Configuração',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildCounter(
              'Quartos',
              Icons.bed,
              _rooms,
              (value) => setState(() => _rooms = value),
              min: 1,
              max: 5,
            ),
            
            const SizedBox(height: 12),
            
            _buildCounter(
              'Banheiros',
              Icons.bathroom,
              _bathrooms,
              (value) => setState(() => _bathrooms = value),
              min: 1,
              max: 4,
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Additional Services
          const Text(
            'Serviços Extras',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildCheckOption(
            'Produtos de limpeza inclusos',
            '+ R\$ 35',
            _includeProducts,
            (value) => setState(() => _includeProducts = value!),
          ),
          
          _buildCheckOption(
            'Casa com pets',
            '+ R\$ 25',
            _includePets,
            (value) => setState(() => _includePets = value!),
          ),
          
          const SizedBox(height: 32),
          
          // Price Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF32BCAD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Valor Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'R\$ ${_totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF32BCAD),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPropertyCard(String value, String label, IconData icon, String size) {
    final isSelected = _selectedResidence == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedResidence = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF32BCAD).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF32BCAD) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? const Color(0xFF32BCAD) : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF32BCAD) : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              size,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCounter(
    String label,
    IconData icon,
    int value,
    Function(int) onChanged, {
    int min = 0,
    int max = 10,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: const Color(0xFF32BCAD),
                disabledColor: Colors.grey[400],
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 40),
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF32BCAD),
                disabledColor: Colors.grey[400],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCheckOption(String title, String price, bool value, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? const Color(0xFF32BCAD) : Colors.grey[300]!,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF32BCAD),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        secondary: Text(
          price,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: value ? const Color(0xFF32BCAD) : Colors.grey[600],
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
  
  Widget _buildScheduleStep() {
    final now = DateTime.now();
    final dates = List.generate(
      14,
      (index) => now.add(Duration(days: index + 1)),
    );
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escolha a Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Date Selection
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = _selectedDate?.day == date.day;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF32BCAD) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF32BCAD) : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE', 'pt_BR').format(date).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM', 'pt_BR').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Time Selection
          const Text(
            'Escolha o Horário',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_selectedDate != null) ...[
            _buildTimeSection('Manhã', ['08:00', '09:00', '10:00', '11:00']),
            const SizedBox(height: 16),
            _buildTimeSection('Tarde', ['14:00', '15:00', '16:00', '17:00']),
            const SizedBox(height: 16),
            _buildTimeSection('Noite', ['19:00', '20:00']),
          ] else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Center(
                child: Text(
                  'Selecione uma data primeiro',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildTimeSection(String period, List<String> times) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          period,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: times.map((time) {
            final isSelected = _selectedTime == time;
            
            return GestureDetector(
              onTap: () => setState(() => _selectedTime = time),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF32BCAD) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF32BCAD) : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo do Agendamento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Serviço', widget.serviceTitle),
                const Divider(),
                _buildSummaryRow('Tipo', _getPropertyTypeText()),
                if (_selectedResidence != 'studio') ...[
                  const Divider(),
                  _buildSummaryRow('Configuração', '$_rooms quartos, $_bathrooms banheiros'),
                ],
                if (_includeProducts || _includePets) ...[
                  const Divider(),
                  _buildSummaryRow(
                    'Extras',
                    [
                      if (_includeProducts) 'Produtos inclusos',
                      if (_includePets) 'Casa com pets',
                    ].join(', '),
                  ),
                ],
                const Divider(),
                _buildSummaryRow(
                  'Data',
                  _selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                      : '-',
                ),
                const Divider(),
                _buildSummaryRow('Horário', _selectedTime ?? '-'),
                const Divider(),
                _buildSummaryRow(
                  'Total',
                  'R\$ ${_totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                  isTotal: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Payment Method
          const Text(
            'Forma de Pagamento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildPaymentOption(
            'pix',
            'PIX',
            'Pagamento instantâneo',
            Icons.pix,
          ),
          
          _buildPaymentOption(
            'credit',
            'Cartão de Crédito',
            'Parcelamento disponível',
            Icons.credit_card,
          ),
          
          _buildPaymentOption(
            'cash',
            'Dinheiro',
            'Pagar ao profissional',
            Icons.money,
          ),
        ],
      ),
    );
  }
  
  String _getPropertyTypeText() {
    switch (_selectedResidence) {
      case 'studio':
        return 'Studio';
      case 'apartment':
        return 'Apartamento';
      case 'house':
        return 'Casa';
      default:
        return '';
    }
  }
  
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black87 : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFF32BCAD) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentOption(String value, String title, String subtitle, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF32BCAD).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF32BCAD) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF32BCAD) : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF32BCAD) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF32BCAD),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Agendamento Confirmado!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Seu serviço foi agendado com sucesso.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF32BCAD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Voltar ao início'),
            ),
          ),
        ],
      ),
    );
  }
}