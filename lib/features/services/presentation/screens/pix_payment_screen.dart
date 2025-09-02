import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';

class PixPaymentScreen extends StatefulWidget {
  final String pixCode;
  final double amount;
  final String serviceTitle;
  final DateTime selectedDate;
  final String selectedTime;
  
  const PixPaymentScreen({
    Key? key,
    required this.pixCode,
    required this.amount,
    required this.serviceTitle,
    required this.selectedDate,
    required this.selectedTime,
  }) : super(key: key);

  @override
  State<PixPaymentScreen> createState() => _PixPaymentScreenState();
}

class _PixPaymentScreenState extends State<PixPaymentScreen>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  bool _codeCopied = false;
  Timer? _expirationTimer;
  int _minutesRemaining = 30;
  int _secondsRemaining = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startExpirationTimer();
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 20,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  void _startExpirationTimer() {
    _expirationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else if (_minutesRemaining > 0) {
          _minutesRemaining--;
          _secondsRemaining = 59;
        } else {
          timer.cancel();
        }
      });
    });
  }
  
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.pixCode));
    HapticFeedback.mediumImpact();
    
    setState(() {
      _codeCopied = true;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _codeCopied = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _expirationTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  // Minimal Header
                  _buildHeader(),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            
                            // PIX Logo
                            _buildPixLogo(),
                            
                            const SizedBox(height: 32),
                            
                            // Amount
                            _buildAmount(),
                            
                            const SizedBox(height: 40),
                            
                            // PIX Code Section
                            _buildPixCodeSection(),
                            
                            const SizedBox(height: 32),
                            
                            // Timer
                            _buildTimer(),
                            
                            const SizedBox(height: 32),
                            
                            // Instructions
                            _buildInstructions(),
                            
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomSheet: _buildBottomSheet(),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Colors.grey[800],
            ),
          ),
          Text(
            'Pagamento PIX',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
  
  Widget _buildPixLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF32BCAD).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.pix,
        size: 40,
        color: const Color(0xFF32BCAD),
      ),
    );
  }
  
  Widget _buildAmount() {
    return Column(
      children: [
        Text(
          'Valor a pagar',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatCurrency(widget.amount),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPixCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PIX COPIA E COLA',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        
        // Code Container
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _codeCopied 
                  ? AppColors.primaryGreen 
                  : const Color(0xFFE5E7EB),
              width: _codeCopied ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                widget.pixCode,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Courier',
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Copy Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _copyToClipboard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _codeCopied 
                        ? AppColors.primaryGreen 
                        : Colors.black87,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _codeCopied ? Icons.check : Icons.copy_rounded,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _codeCopied ? 'Copiado!' : 'Copiar código',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimer() {
    final isUrgent = _minutesRemaining < 5;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUrgent 
            ? const Color(0xFFFEF2F2) 
            : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: isUrgent 
                ? const Color(0xFFDC2626) 
                : const Color(0xFF0284C7),
          ),
          const SizedBox(width: 8),
          Text(
            'Expira em ',
            style: TextStyle(
              fontSize: 13,
              color: isUrgent 
                  ? const Color(0xFFDC2626) 
                  : const Color(0xFF0284C7),
            ),
          ),
          Text(
            '${_minutesRemaining.toString().padLeft(2, '0')}:${_secondsRemaining.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isUrgent 
                  ? const Color(0xFFDC2626) 
                  : const Color(0xFF0284C7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMO PAGAR',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildInstructionItem(
          '1',
          'Abra o app do seu banco',
        ),
        const SizedBox(height: 12),
        
        _buildInstructionItem(
          '2',
          'Escolha pagar com PIX',
        ),
        const SizedBox(height: 12),
        
        _buildInstructionItem(
          '3',
          'Selecione PIX Copia e Cola',
        ),
        const SizedBox(height: 12),
        
        _buildInstructionItem(
          '4',
          'Cole o código e confirme',
        ),
      ],
    );
  }
  
  Widget _buildInstructionItem(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1.5,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _verifyPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Já fiz o pagamento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar pagamento',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _verifyPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(AppColors.primaryGreen),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verificando pagamento',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aguarde um momento...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    // Simula verificação e navega para confirmação
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Fecha dialog
      Navigator.of(context).pushReplacementNamed('/payment-confirmation');
    });
  }
  
  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}