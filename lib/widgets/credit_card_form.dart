import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/card_validator.dart';
import '../models/badge_models.dart';

class CreditCardForm extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;
  final bool isLoading;

  const CreditCardForm({
    Key? key,
    required this.onSubmit,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  
  CardBrand _detectedBrand = CardBrand.unknown;
  bool _showCardBack = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _updateCardBrand(String value) {
    final brand = CardValidator.detectCardBrand(value);
    if (brand != _detectedBrand) {
      setState(() {
        _detectedBrand = brand;
      });
    }
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Número do cartão é obrigatório';
    }
    if (!CardValidator.validateCardNumber(value)) {
      return 'Número do cartão inválido';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Data de validade é obrigatória';
    }
    final parts = value.split('/');
    if (parts.length != 2) {
      return 'Formato inválido (MM/AA)';
    }
    if (!CardValidator.validateExpiryDate(parts[0], parts[1])) {
      return 'Data de validade inválida';
    }
    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV é obrigatório';
    }
    if (!CardValidator.validateCVV(value, cardNumber: _cardNumberController.text)) {
      return 'CVV inválido';
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final expiry = _expiryController.text.split('/');
      widget.onSubmit({
        'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
        'cardHolder': _cardHolderController.text,
        'expiryMonth': expiry[0],
        'expiryYear': expiry[1],
        'cvv': _cvvController.text,
      });
    }
  }

  Widget _buildCardPreview() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: _showCardBack ? _buildCardBack() : _buildCardFront(),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      key: const ValueKey('front'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getCardGradient(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                _getCardBrandIcon(),
                color: Colors.white,
                size: 40,
              ),
              const Icon(
                Icons.contactless,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
          Text(
            _cardNumberController.text.isEmpty
                ? '**** **** **** ****'
                : CardValidator.formatCardNumber(_cardNumberController.text),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TITULAR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    _cardHolderController.text.isEmpty
                        ? 'SEU NOME'
                        : _cardHolderController.text.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VALIDADE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    _expiryController.text.isEmpty
                        ? 'MM/AA'
                        : _expiryController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
    return Container(
      key: const ValueKey('back'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getCardGradient(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            color: Colors.black,
            margin: const EdgeInsets.only(top: 20),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _cvvController.text.isEmpty
                        ? '***'
                        : _cvvController.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getCardGradient() {
    switch (_detectedBrand) {
      case CardBrand.visa:
        return [Colors.blue.shade700, Colors.blue.shade900];
      case CardBrand.mastercard:
        return [Colors.orange.shade700, Colors.red.shade700];
      case CardBrand.amex:
        return [Colors.green.shade700, Colors.green.shade900];
      case CardBrand.elo:
        return [Colors.yellow.shade700, Colors.orange.shade700];
      default:
        return [Colors.grey.shade700, Colors.grey.shade900];
    }
  }

  IconData _getCardBrandIcon() {
    switch (_detectedBrand) {
      case CardBrand.visa:
      case CardBrand.mastercard:
      case CardBrand.amex:
      case CardBrand.elo:
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCardPreview(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: InputDecoration(
                      labelText: 'Número do Cartão',
                      hintText: '0000 0000 0000 0000',
                      prefixIcon: const Icon(Icons.credit_card),
                      suffixIcon: _detectedBrand != CardBrand.unknown
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CardNumberFormatter(),
                    ],
                    onChanged: (value) {
                      _updateCardBrand(value);
                    },
                    validator: _validateCardNumber,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cardHolderController,
                    decoration: InputDecoration(
                      labelText: 'Nome do Titular',
                      hintText: 'Como está no cartão',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nome do titular é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _expiryController,
                          decoration: InputDecoration(
                            labelText: 'Validade',
                            hintText: 'MM/AA',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ExpiryDateFormatter(),
                          ],
                          validator: _validateExpiry,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            setState(() {
                              _showCardBack = hasFocus;
                            });
                          },
                          child: TextFormField(
                            controller: _cvvController,
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              hintText: '123',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                _detectedBrand == CardBrand.amex ? 4 : 3,
                              ),
                            ],
                            validator: _validateCVV,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: widget.isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Pagar',
                              style: TextStyle(fontSize: 18),
                            ),
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
}

// Formatador para número do cartão
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(
        offset: buffer.toString().length,
      ),
    );
  }
}

// Formatador para data de validade
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(
        offset: buffer.toString().length,
      ),
    );
  }
}