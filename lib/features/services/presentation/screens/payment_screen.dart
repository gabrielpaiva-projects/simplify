import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

enum PaymentMethod { pix, creditCard }

class PaymentScreen extends StatefulWidget {
  final String serviceTitle;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final double totalAmount;
  final Map<String, dynamic> bookingDetails;

  const PaymentScreen({
    super.key,
    required this.serviceTitle,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.totalAmount,
    required this.bookingDetails,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.pix;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Controladores para o formulário do cartão
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isProcessing = false;
  int _cardInstallments = 1;
  
  // PIX
  String _pixCode = '';
  bool _pixCodeGenerated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    // Gera código PIX automaticamente se PIX for selecionado
    if (_selectedPaymentMethod == PaymentMethod.pix) {
      _generatePixCode();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _generatePixCode() {
    // Simula geração de código PIX
    setState(() {
      _pixCodeGenerated = true;
      _pixCode = '00020126360014BR.GOV.BCB.PIX0114+5511999999999520400005303986540${widget.totalAmount.toStringAsFixed(2)}5802BR5925NOME DO RECEBEDOR6009SAO PAULO62070503***6304A1B2';
    });
  }

  String _formatCardNumber(String value) {
    final cleanValue = value.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleanValue.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanValue[i]);
    }
    return buffer.toString();
  }

  String _formatExpiryDate(String value) {
    final cleanValue = value.replaceAll('/', '');
    if (cleanValue.length >= 2) {
      return '${cleanValue.substring(0, 2)}/${cleanValue.substring(2, cleanValue.length.clamp(0, 4))}';
    }
    return cleanValue;
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == PaymentMethod.creditCard) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.mediumImpact();

    // Simula processamento do pagamento
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
    });

    // Mostra diálogo de sucesso
    if (!mounted) return;
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.primaryGreen.withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Pagamento Confirmado!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Seu agendamento foi confirmado com sucesso',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Voltar ao Início',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3436)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pagamento',
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumo do agendamento
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resumo do Agendamento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryRow(
                            'Serviço',
                            widget.serviceTitle,
                            Icons.cleaning_services,
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Data',
                            '${widget.scheduledDate?.day}/${widget.scheduledDate?.month}/${widget.scheduledDate?.year}',
                            Icons.calendar_today,
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Horário',
                            widget.scheduledTime ?? '',
                            Icons.access_time,
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total a pagar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3436),
                                ),
                              ),
                              Text(
                                'R\$ ${widget.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Métodos de pagamento
                    const Text(
                      'Escolha a forma de pagamento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Opções de pagamento
                    _buildPaymentMethodCard(
                      PaymentMethod.pix,
                      'PIX',
                      'Pagamento instantâneo',
                      Icons.qr_code_2,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentMethodCard(
                      PaymentMethod.creditCard,
                      'Cartão de Crédito',
                      'Parcelamento disponível',
                      Icons.credit_card,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Conteúdo específico do método de pagamento
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _selectedPaymentMethod == PaymentMethod.pix
                          ? _buildPixContent()
                          : _buildCreditCardContent(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Botão de pagamento
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _selectedPaymentMethod == PaymentMethod.pix
                                ? 'Confirmar Pagamento PIX'
                                : 'Finalizar Pagamento',
                            style: const TextStyle(
                              color: Colors.white,
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
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3436),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedPaymentMethod = method;
          if (method == PaymentMethod.pix && !_pixCodeGenerated) {
            _generatePixCode();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen.withOpacity(0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primaryGreen : Colors.grey[600],
              ),
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
                      color: isSelected ? AppColors.primaryGreen : const Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Radio<PaymentMethod>(
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedPaymentMethod = value!;
                  if (value == PaymentMethod.pix && !_pixCodeGenerated) {
                    _generatePixCode();
                  }
                });
              },
              activeColor: AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPixContent() {
    return Container(
      key: const ValueKey('pix'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Escaneie o QR Code para pagar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 20),
          
          // QR Code placeholder
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: _pixCodeGenerated
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2,
                          size: 180,
                          color: Colors.grey[800],
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.pix,
                            size: 40,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Código PIX copiável
          if (_pixCodeGenerated) ...[
            const Text(
              'Ou copie o código PIX:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF636E72),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _pixCode,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Color(0xFF2D3436),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _pixCode));
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Código PIX copiado!'),
                          backgroundColor: AppColors.primaryGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 20),
                    color: AppColors.primaryGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Válido por 30 minutos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreditCardContent() {
    return Container(
      key: const ValueKey('credit_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados do Cartão',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 20),
            
            // Número do cartão
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              decoration: InputDecoration(
                labelText: 'Número do Cartão',
                hintText: '0000 0000 0000 0000',
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
                ),
              ),
              onChanged: (value) {
                final formatted = _formatCardNumber(value);
                if (formatted != value) {
                  _cardNumberController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o número do cartão';
                }
                if (value.replaceAll(' ', '').length < 16) {
                  return 'Número do cartão inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Nome do titular
            TextFormField(
              controller: _cardHolderController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Nome do Titular',
                hintText: 'Como está no cartão',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o nome do titular';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Validade e CVV
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryDateController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Validade',
                      hintText: 'MM/AA',
                      prefixIcon: const Icon(Icons.calendar_month),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      final formatted = _formatExpiryDate(value);
                      if (formatted != value) {
                        _expiryDateController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite a validade';
                      }
                      if (value.length < 5) {
                        return 'Validade inválida';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '000',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite o CVV';
                      }
                      if (value.length < 3) {
                        return 'CVV inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Parcelamento
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Parcelamento',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _cardInstallments,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: List.generate(12, (index) {
                      final installments = index + 1;
                      final installmentValue = widget.totalAmount / installments;
                      return DropdownMenuItem(
                        value: installments,
                        child: Text(
                          installments == 1
                              ? 'À vista - R\$ ${widget.totalAmount.toStringAsFixed(2)}'
                              : '${installments}x de R\$ ${installmentValue.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _cardInstallments = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Informação de segurança
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pagamento 100% seguro com criptografia',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}