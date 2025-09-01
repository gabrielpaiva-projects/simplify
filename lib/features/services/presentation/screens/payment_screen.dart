import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/payment_service.dart';
import '../../../../models/payment_response.dart';
import '../../../../utils/card_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

class _PaymentScreenState extends State<PaymentScreen> 
    with TickerProviderStateMixin {
  
  // Payment method
  PaymentMethod _selectedPaymentMethod = PaymentMethod.creditCard;
  
  // Animation Controllers
  late AnimationController _headerController;
  late AnimationController _cardController;
  late AnimationController _footerController;
  late AnimationController _priceController;
  late AnimationController _pulseController;
  late AnimationController _successController;
  
  // Animations
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _footerSlideAnimation;
  late Animation<double> _priceAnimation;
  late Animation<double> _pulseAnimation;
  
  // Card Form Controllers
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // State
  bool _isProcessing = false;
  int _cardInstallments = 1;
  String _pixCode = '';
  bool _pixCodeGenerated = false;
  bool _pixCopied = false;
  bool _showCardBack = false;
  
  // Price animation
  double _currentPrice = 0;
  double _targetPrice = 0;

  @override
  void initState() {
    super.initState();
    _targetPrice = widget.totalAmount;
    _initializeAnimations();
    _generatePixCode();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Header animation
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerAnimation = Tween<double>(
      begin: -50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));
    
    // Main card animation
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));
    
    // Footer animation
    _footerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _footerSlideAnimation = Tween<double>(
      begin: 100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _footerController,
      curve: Curves.easeOutCubic,
    ));
    
    // Price animation
    _priceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _priceAnimation = Tween<double>(
      begin: 0,
      end: _targetPrice,
    ).animate(CurvedAnimation(
      parent: _priceController,
      curve: Curves.easeInOut,
    ));
    
    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Success animation
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardController.forward();
    _priceController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _footerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardController.dispose();
    _footerController.dispose();
    _priceController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _generatePixCode() async {
    // PIX code will be generated when payment is processed
    setState(() {
      _pixCodeGenerated = false;
      _pixCode = '';
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

    try {
      // Get current user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      if (_selectedPaymentMethod == PaymentMethod.pix) {
        // Process PIX payment
        final response = await PaymentService.processPixPayment(
          userId: currentUser.uid,
          amount: widget.totalAmount,
          description: 'Agendamento: ${widget.serviceTitle}',
        );

        if (!mounted) return;

        if (response.success && response.data != null) {
          setState(() {
            _pixCode = response.data!.qrCode;
            _pixCodeGenerated = true;
          });
          
          // Show PIX QR Code in a dialog
          await _showPixPaymentDialog(response.data!);
        } else {
          _showErrorMessage(response.error ?? 'Erro ao processar pagamento PIX');
        }
      } else {
        // Process Card payment
        final expiryParts = _expiryDateController.text.split('/');
        final expiryMonth = expiryParts[0];
        final expiryYear = '20${expiryParts[1]}'; // Convert YY to YYYY

        final response = await PaymentService.processCardPayment(
          userId: currentUser.uid,
          amount: widget.totalAmount,
          cardNumber: _cardNumberController.text.replaceAll(' ', ''),
          expirationYear: expiryYear,
          expirationMonth: expiryMonth,
          securityCode: _cvvController.text,
          installments: _cardInstallments,
          description: 'Agendamento: ${widget.serviceTitle}',
        );

        if (!mounted) return;

        if (response.success && response.data != null) {
          if (response.data!.isApproved) {
            _showSuccessDialog();
          } else {
            _showErrorMessage('Pagamento recusado: ${response.data!.statusDetail}');
          }
        } else {
          _showErrorMessage(response.error ?? 'Erro ao processar pagamento com cartão');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Erro: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _showPixPaymentDialog(PixPaymentResponse pixResponse) async {
    return showDialog(
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
              // QR Code
              if (pixResponse.qrCodeBase64.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Image.memory(
                    base64Decode(pixResponse.qrCodeBase64),
                    width: 200,
                    height: 200,
                  ),
                ),
              
              const SizedBox(height: 24),
              
              Text(
                'PIX Gerado com Sucesso!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Valor: R\$ ${pixResponse.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'ID do Pagamento: ${pixResponse.paymentId}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Copy button
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: pixResponse.qrCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Código PIX copiado!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar código PIX'),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showSuccessDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                    ),
                    child: const Text(
                      'Confirmar Pagamento',
                      style: TextStyle(color: Colors.white),
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

  void _showSuccessDialog() {
    _successController.forward();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = _selectedPaymentMethod == PaymentMethod.pix || 
                       (_cardNumberController.text.isNotEmpty && 
                        _cardHolderController.text.isNotEmpty &&
                        _expiryDateController.text.length >= 5 &&
                        _cvvController.text.length >= 3);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  const Color(0xFFF8FAFB),
                ],
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Animated Header
                AnimatedBuilder(
                  animation: _headerAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _headerAnimation.value),
                      child: _buildHeader(),
                    );
                  },
                ),
                
                // Progress Bar - Step 3 of 3
                _buildProgressBar(),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        
                        // Title
                        AnimatedBuilder(
                          animation: _cardAnimation,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _cardAnimation,
                              child: Transform.scale(
                                scale: 0.8 + (_cardAnimation.value * 0.2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Finalizar Agendamento',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF2D3436),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Escolha a forma de pagamento',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Service Summary Card
                        AnimatedBuilder(
                          animation: _cardAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _cardAnimation.value,
                              child: _buildServiceSummaryCard(),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Payment Method Selector
                        _buildPaymentMethodSelector(),
                        
                        const SizedBox(height: 24),
                        
                        // Payment Content
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _selectedPaymentMethod == PaymentMethod.pix
                              ? _buildPixContent()
                              : _buildCreditCardContent(),
                        ),
                        
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Animated Footer with Payment Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _footerSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _footerSlideAnimation.value),
                  child: _buildModernFooter(canProceed),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF2D3436),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pagamento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.serviceTitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Help button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.help_outline,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Steps indicator
          Row(
            children: [
              // Step 1 - Complete
              _buildStepIndicator(1, true, 'Configuração'),
              Expanded(child: _buildStepLine(true)),
              // Step 2 - Complete
              _buildStepIndicator(2, true, 'Data e Hora'),
              Expanded(child: _buildStepLine(true)),
              // Step 3 - Current
              _buildStepIndicator(3, false, 'Pagamento', isCurrent: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, bool isComplete, String label, {bool isCurrent = false}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isComplete 
                ? AppColors.primaryGreen 
                : isCurrent 
                    ? AppColors.primaryGreen
                    : const Color(0xFFE8ECEF),
            border: isCurrent
                ? Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    width: 3,
                  )
                : null,
          ),
          child: Center(
            child: isComplete
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: isCurrent ? Colors.white : const Color(0xFF74788D),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isCurrent ? AppColors.primaryGreen : Colors.grey[600],
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isComplete) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isComplete ? AppColors.primaryGreen : const Color(0xFFE8ECEF),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildServiceSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Service icon and title
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.cleaning_services,
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
                      widget.serviceTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.scheduledDate?.day}/${widget.scheduledDate?.month}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.scheduledTime ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: const Color(0xFFE8ECEF),
          ),
          const SizedBox(height: 20),
          
          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a pagar',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF74788D),
                ),
              ),
              AnimatedBuilder(
                animation: _priceAnimation,
                builder: (context, child) {
                  return Text(
                    'R\$ ${_priceAnimation.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                      letterSpacing: -0.5,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Método de Pagamento',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodCard(
                PaymentMethod.creditCard,
                'Cartão',
                Icons.credit_card,
                'Crédito ou Débito',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentMethodCard(
                PaymentMethod.pix,
                'PIX',
                Icons.qr_code_2,
                'Pagamento instantâneo',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    PaymentMethod method,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : const Color(0xFFE8ECEF),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryGreen : const Color(0xFF74788D),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primaryGreen : const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8ECEF),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // QR Code
          Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: 168,
                        color: Colors.grey[800],
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.pix,
                          size: 32,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
          ),
          
          const SizedBox(height: 24),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Escaneie o QR Code com o app do seu banco',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Copy PIX Code button
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _pixCode));
              HapticFeedback.mediumImpact();
              setState(() {
                _pixCopied = true;
              });
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    _pixCopied = false;
                  });
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: _pixCopied ? AppColors.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _pixCopied ? AppColors.primaryGreen : const Color(0xFFE8ECEF),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _pixCopied ? Icons.check : Icons.copy,
                    size: 20,
                    color: _pixCopied ? Colors.white : const Color(0xFF74788D),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _pixCopied ? 'Código copiado!' : 'Copiar código PIX',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _pixCopied ? Colors.white : const Color(0xFF2D3436),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer,
                size: 16,
                color: Colors.orange[700],
              ),
              const SizedBox(width: 4),
              Text(
                'Código válido por 30 minutos',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardContent() {
    return Container(
      key: const ValueKey('credit_card'),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual Credit Card
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E3C72),
                    const Color(0xFF2A5298),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 50,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.amber[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const Icon(
                          Icons.contactless,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      _cardNumberController.text.isEmpty
                          ? '•••• •••• •••• ••••'
                          : _formatCardNumber(_cardNumberController.text),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TITULAR',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _cardHolderController.text.isEmpty
                                  ? 'SEU NOME'
                                  : _cardHolderController.text.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VALIDADE',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _expiryDateController.text.isEmpty
                                  ? 'MM/AA'
                                  : _expiryDateController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Card form fields
            _buildTextField(
              controller: _cardNumberController,
              label: 'Número do Cartão',
              hint: '0000 0000 0000 0000',
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              onChanged: (value) {
                final formatted = _formatCardNumber(value);
                if (formatted != value) {
                  _cardNumberController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
                setState(() {});
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _cardHolderController,
              label: 'Nome do Titular',
              hint: 'Como está no cartão',
              icon: Icons.person,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _expiryDateController,
                    label: 'Validade',
                    hint: 'MM/AA',
                    icon: Icons.calendar_month,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onChanged: (value) {
                      final formatted = _formatExpiryDate(value);
                      if (formatted != value) {
                        _expiryDateController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _cvvController,
                    label: 'CVV',
                    hint: '000',
                    icon: Icons.lock,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Installments
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12),
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
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final installments = index + 1;
                        final isSelected = _cardInstallments == installments;
                        final installmentValue = widget.totalAmount / installments;
                        
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _cardInstallments = installments;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryGreen : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.primaryGreen 
                                    : const Color(0xFFE8ECEF),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${installments}x',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF74788D),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _cardInstallments == 1
                        ? 'À vista: R\$ ${widget.totalAmount.toStringAsFixed(2)}'
                        : '${_cardInstallments}x de R\$ ${(widget.totalAmount / _cardInstallments).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF2D3436),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.grey[600],
          size: 20,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildModernFooter(bool canProceed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Price display
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Text(
                            'R\$ ${widget.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                              letterSpacing: -0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 20),
              
              // CTA Button
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: canProceed ? _pulseAnimation.value : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: canProceed
                            ? LinearGradient(
                                colors: [
                                  AppColors.primaryGreen,
                                  AppColors.primaryGreen.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: canProceed ? null : const Color(0xFFE8ECEF),
                        boxShadow: canProceed
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ]
                            : [],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: canProceed && !_isProcessing ? _processPayment : null,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            child: Row(
                              children: [
                                if (_isProcessing) ...[
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Text(
                                  _isProcessing 
                                      ? 'Processando...'
                                      : _selectedPaymentMethod == PaymentMethod.pix
                                          ? 'Confirmar PIX'
                                          : 'Finalizar Pagamento',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: canProceed 
                                        ? Colors.white
                                        : const Color(0xFF74788D),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (!_isProcessing) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: canProceed 
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: canProceed 
                                          ? Colors.white
                                          : const Color(0xFF74788D),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessDialog() {
    return Dialog(
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
            // Success animation
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
            
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Valor: R\$ ${widget.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
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
    );
  }
}