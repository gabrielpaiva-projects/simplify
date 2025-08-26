import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
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

class _PaymentScreenState extends State<PaymentScreen> 
    with TickerProviderStateMixin {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.pix;
  
  // Animation Controllers
  late AnimationController _mainController;
  late AnimationController _cardFlipController;
  late AnimationController _pulseController;
  late AnimationController _successController;
  late AnimationController _pixAnimationController;
  late AnimationController _shimmerController;
  
  // Animations
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideUpAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _cardFlipAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _pixRotationAnimation;
  late Animation<double> _shimmerAnimation;
  
  // Card Form Controllers
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // State
  bool _isProcessing = false;
  int _cardInstallments = 1;
  bool _showCardBack = false;
  String _pixCode = '';
  bool _pixCodeGenerated = false;
  bool _pixCopied = false;
  
  // Visual Effects
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generatePixCode();
  }

  void _initializeAnimations() {
    // Main animations
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeInAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
    ));
    
    _slideUpAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
    ));
    
    // Card flip animation
    _cardFlipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardFlipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _cardFlipController,
      curve: Curves.easeInOutBack,
    ));
    
    // Pulse animation for buttons
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // PIX animation
    _pixAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pixRotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _pixAnimationController,
      curve: Curves.linear,
    ));
    
    // Shimmer effect
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    // Success animation
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Start main animation
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _cardFlipController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    _pixAnimationController.dispose();
    _shimmerController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _generatePixCode() {
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

    HapticFeedback.heavyImpact();

    // Simula processamento
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    
    setState(() {
      _isProcessing = false;
    });

    _showSuccessAnimation();
  }

  void _showSuccessAnimation() {
    _successController.forward();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => _buildSuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom app bar
                _buildCustomAppBar(),
                
                // Content
                Expanded(
                  child: AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideUpAnimation.value),
                        child: Opacity(
                          opacity: _fadeInAnimation.value,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                
                                // Order summary card with glassmorphism
                                _buildGlassmorphicSummaryCard(),
                                
                                const SizedBox(height: 30),
                                
                                // Payment method selector
                                _buildPaymentMethodSelector(),
                                
                                const SizedBox(height: 30),
                                
                                // Payment content
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  switchInCurve: Curves.easeInOut,
                                  switchOutCurve: Curves.easeInOut,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.1, 0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _selectedPaymentMethod == PaymentMethod.pix
                                      ? _buildModernPixContent()
                                      : _buildModernCreditCardContent(),
                                ),
                                
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Floating payment button
          _buildFloatingPaymentButton(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + _shimmerAnimation.value, -1),
              end: Alignment(1 + _shimmerAnimation.value, 1),
              colors: [
                const Color(0xFF0A0E27),
                const Color(0xFF1A237E).withOpacity(0.8),
                const Color(0xFF0A0E27),
                AppColors.primaryGreen.withOpacity(0.3),
                const Color(0xFF0A0E27),
              ],
              stops: const [0, 0.25, 0.5, 0.75, 1],
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Back button with glow effect
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          
          const Expanded(
            child: Text(
              'Finalizar Pagamento',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          
          const SizedBox(width: 44), // Balance the layout
        ],
      ),
    );
  }

  Widget _buildGlassmorphicSummaryCard() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  children: [
                    // Service icon with glow
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.primaryGreen.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.cleaning_services,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Service title
                    Text(
                      widget.serviceTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Date and time chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoChip(
                          Icons.calendar_today,
                          '${widget.scheduledDate?.day}/${widget.scheduledDate?.month}',
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.access_time,
                          widget.scheduledTime ?? '',
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Price with animation
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGreen.withOpacity(0.3),
                                  AppColors.primaryGreen.withOpacity(0.1),
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.primaryGreen.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'R\$',
                                  style: TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.totalAmount.toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMethodOption(
              PaymentMethod.pix,
              'PIX',
              Icons.qr_code_2,
            ),
          ),
          Expanded(
            child: _buildMethodOption(
              PaymentMethod.creditCard,
              'Cartão',
              Icons.credit_card,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodOption(PaymentMethod method, String label, IconData icon) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.primaryGreen.withOpacity(0.8),
                  ],
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernPixContent() {
    return Container(
      key: const ValueKey('pix'),
      child: Column(
        children: [
          // Animated QR Code
          AnimatedBuilder(
            animation: _pixRotationAnimation,
            builder: (context, child) {
              return Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating glow effect
                    Transform.rotate(
                      angle: _pixRotationAnimation.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: SweepGradient(
                            colors: [
                              AppColors.primaryGreen.withOpacity(0.3),
                              Colors.transparent,
                              AppColors.primaryGreen.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // QR Code
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 160,
                            color: Colors.grey[900],
                          ),
                          // PIX logo
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.pix,
                              size: 35,
                              color: AppColors.primaryGreen,
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
          
          const SizedBox(height: 30),
          
          // Copy code button with glassmorphism
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: _pixCopied 
                      ? AppColors.primaryGreen 
                      : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  if (_pixCopied)
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _pixCopied ? Icons.check_circle : Icons.copy,
                    color: _pixCopied ? AppColors.primaryGreen : Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _pixCopied ? 'Código Copiado!' : 'Copiar Código PIX',
                    style: TextStyle(
                      color: _pixCopied ? AppColors.primaryGreen : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Timer indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.orange.withOpacity(0.2),
              border: Border.all(
                color: Colors.orange.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: Colors.orange[300],
                ),
                const SizedBox(width: 8),
                Text(
                  'Válido por 30 minutos',
                  style: TextStyle(
                    color: Colors.orange[300],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCreditCardContent() {
    return Container(
      key: const ValueKey('credit_card'),
      child: Column(
        children: [
          // 3D Credit Card
          GestureDetector(
            onTap: () {
              setState(() {
                _showCardBack = !_showCardBack;
                if (_showCardBack) {
                  _cardFlipController.forward();
                } else {
                  _cardFlipController.reverse();
                }
              });
            },
            child: AnimatedBuilder(
              animation: _cardFlipAnimation,
              builder: (context, child) {
                final isShowingFront = _cardFlipAnimation.value < 0.5;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(math.pi * _cardFlipAnimation.value),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isShowingFront
                            ? [
                                const Color(0xFF1E3C72),
                                const Color(0xFF2A5298),
                              ]
                            : [
                                const Color(0xFF2A5298),
                                const Color(0xFF1E3C72),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: isShowingFront
                        ? _buildCardFront()
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: _buildCardBack(),
                          ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Card form with glassmorphism
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Card number field
                  _buildGlassTextField(
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
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Card holder field
                  _buildGlassTextField(
                    controller: _cardHolderController,
                    label: 'Nome do Titular',
                    hint: 'Como está no cartão',
                    icon: Icons.person,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Expiry and CVV row
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassTextField(
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
                                selection: TextSelection.collapsed(
                                  offset: formatted.length,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGlassTextField(
                          controller: _cvvController,
                          label: 'CVV',
                          hint: '000',
                          icon: Icons.lock,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          onTap: () {
                            setState(() {
                              _showCardBack = true;
                              _cardFlipController.forward();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Installments selector
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen.withOpacity(0.1),
                          AppColors.primaryGreen.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Parcelamento',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
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
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: [
                                              AppColors.primaryGreen,
                                              AppColors.primaryGreen.withOpacity(0.8),
                                            ],
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : Colors.white.withOpacity(0.1),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                          : Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${installments}x',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _cardInstallments == 1
                              ? 'À vista: R\$ ${widget.totalAmount.toStringAsFixed(2)}'
                              : '${_cardInstallments}x de R\$ ${(widget.totalAmount / _cardInstallments).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chip
              Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.amber[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Card brand
              const Icon(
                Icons.contactless,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
          const Spacer(),
          // Card number
          Text(
            _cardNumberController.text.isEmpty
                ? '•••• •••• •••• ••••'
                : _formatCardNumber(_cardNumberController.text),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
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
    );
  }

  Widget _buildCardBack() {
    return Column(
      children: [
        const SizedBox(height: 30),
        // Magnetic strip
        Container(
          height: 50,
          color: Colors.black,
        ),
        const SizedBox(height: 20),
        // CVV field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 60,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    _cvvController.text.isEmpty ? 'CVV' : _cvvController.text,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Function(String)? onChanged,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      onTap: onTap,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white.withOpacity(0.5),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryGreen,
            width: 2,
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

  Widget _buildFloatingPaymentButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0),
              Colors.black.withOpacity(0.8),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isProcessing ? 1.0 : _pulseAnimation.value,
                child: GestureDetector(
                  onTap: _isProcessing ? null : _processPayment,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: _isProcessing
                            ? [
                                Colors.grey[600]!,
                                Colors.grey[700]!,
                              ]
                            : [
                                AppColors.primaryGreen,
                                AppColors.primaryGreen.withOpacity(0.8),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isProcessing
                              ? Colors.transparent
                              : AppColors.primaryGreen.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _selectedPaymentMethod == PaymentMethod.pix
                                      ? Icons.qr_code_scanner
                                      : Icons.lock,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedPaymentMethod == PaymentMethod.pix
                                      ? 'Confirmar PIX'
                                      : 'Pagar R\$ ${widget.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
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
          color: const Color(0xFF0A0E27),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.primaryGreen.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Pagamento Confirmado!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Seu agendamento foi confirmado com sucesso',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            GestureDetector(
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryGreen.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Text(
                  'Voltar ao Início',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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