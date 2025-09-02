import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/services/payment_service.dart';
import '../../data/models/payment_response.dart';

class PixPaymentScreen extends StatefulWidget {
  final String userId;
  final double amount;

  const PixPaymentScreen({
    Key? key,
    required this.userId,
    required this.amount,
  }) : super(key: key);

  @override
  State<PixPaymentScreen> createState() => _PixPaymentScreenState();
}

class _PixPaymentScreenState extends State<PixPaymentScreen> {
  bool _isLoading = false;
  PixPaymentResponse? _pixResponse;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generatePixPayment();
  }

  Future<void> _generatePixPayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await PaymentService.processPixPayment(
        userId: widget.userId,
        amount: widget.amount,
        description: 'Pagamento Simplify - PIX',
      );

      if (response.success && response.data != null) {
        setState(() {
          _pixResponse = response.data;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Erro ao gerar PIX';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyPixCode() {
    if (_pixResponse?.qrCode != null) {
      Clipboard.setData(ClipboardData(text: _pixResponse!.qrCode));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código PIX copiado!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildQRCode() {
    if (_pixResponse?.qrCodeBase64 == null) {
      return const SizedBox.shrink();
    }

    try {
      final bytes = base64Decode(_pixResponse!.qrCodeBase64);
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.memory(
              bytes,
              width: 280,
              height: 280,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'Escaneie o QR Code',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'ou copie o código PIX',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    } catch (e) {
      return Text('Erro ao exibir QR Code: $e');
    }
  }

  Widget _buildPixCode() {
    if (_pixResponse?.qrCode == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Código PIX',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: _copyPixCode,
                tooltip: 'Copiar código',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _pixResponse!.qrCode,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    if (_pixResponse == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Valor', 'R\$ ${widget.amount.toStringAsFixed(2)}'),
          const Divider(),
          _buildInfoRow('Status', _pixResponse!.status.toUpperCase()),
          const Divider(),
          _buildInfoRow('ID do Pagamento', _pixResponse!.paymentId.toString()),
          if (_pixResponse!.expirationDate.isNotEmpty) ...[
            const Divider(),
            _buildInfoRow('Validade', _formatExpirationDate(_pixResponse!.expirationDate)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatExpirationDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento PIX'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Gerando código PIX...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao gerar PIX',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _generatePixPayment,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildQRCode(),
                      _buildPixCode(),
                      const SizedBox(height: 16),
                      _buildPaymentInfo(),
                      const SizedBox(height: 24),
                      if (_pixResponse?.ticketUrl != null)
                        ElevatedButton.icon(
                          onPressed: () {
                            // Aqui você pode abrir o link no navegador
                            // usando url_launcher
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Ver Comprovante'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}