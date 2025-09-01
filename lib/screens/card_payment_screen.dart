import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../models/payment_response.dart';
import '../widgets/credit_card_form.dart';

class CardPaymentScreen extends StatefulWidget {
  final String userId;
  final double amount;

  const CardPaymentScreen({
    Key? key,
    required this.userId,
    required this.amount,
  }) : super(key: key);

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  bool _isLoading = false;
  CardPaymentResponse? _paymentResponse;
  String? _errorMessage;

  Future<void> _processCardPayment(Map<String, String> cardData) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _paymentResponse = null;
    });

    try {
      final response = await PaymentService.processCardPayment(
        userId: widget.userId,
        amount: widget.amount,
        cardNumber: cardData['cardNumber']!,
        expirationYear: '20${cardData['expiryYear']}', // Converte AA para AAAA
        expirationMonth: cardData['expiryMonth']!,
        securityCode: cardData['cvv']!,
        installments: 1,
        description: 'Pagamento com Cartão - Simplify',
      );

      if (response.success && response.data != null) {
        setState(() {
          _paymentResponse = response.data;
        });
        _showSuccessDialog();
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Erro ao processar pagamento';
        });
        _showErrorDialog();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro: ${e.toString()}';
      });
      _showErrorDialog();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 50,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pagamento Aprovado!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'R\$ ${widget.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${_paymentResponse?.paymentId}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            if (_paymentResponse?.dateApproved != null) ...[
              const SizedBox(height: 4),
              Text(
                'Aprovado em: ${_formatDate(_paymentResponse!.dateApproved!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Retorna sucesso
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pagamento Recusado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Erro ao processar pagamento',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento com Cartão'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Column(
              children: [
                Text(
                  'Total a Pagar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${widget.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CreditCardForm(
              onSubmit: _processCardPayment,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}