import '../models/badge_models.dart';

/// Classe para validação de cartões de crédito
class CardValidator {
  /// Valida um número de cartão usando o algoritmo de Luhn
  static bool validateCardNumber(String cardNumber) {
    // Remove espaços e caracteres não numéricos
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');

    // Verifica se tem pelo menos 13 dígitos (mínimo para cartões)
    if (cleaned.length < 13 || cleaned.length > 19) {
      return false;
    }

    // Implementa o algoritmo de Luhn
    int sum = 0;
    bool alternate = false;

    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Valida a data de expiração do cartão
  static bool validateExpiryDate(String month, String year) {
    try {
      final monthInt = int.parse(month);
      final yearInt = int.parse(year);

      // Valida o mês
      if (monthInt < 1 || monthInt > 12) {
        return false;
      }

      // Obtém a data atual
      final now = DateTime.now();
      final currentYear = now.year;
      final currentMonth = now.month;

      // Converte ano de 2 dígitos para 4 dígitos se necessário
      final fullYear = yearInt < 100 ? 2000 + yearInt : yearInt;

      // Verifica se o cartão não está expirado
      if (fullYear < currentYear) {
        return false;
      }

      if (fullYear == currentYear && monthInt < currentMonth) {
        return false;
      }

      // Verifica se a data não está muito no futuro (máximo 20 anos)
      if (fullYear > currentYear + 20) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Valida o código de segurança (CVV/CVC)
  static bool validateCVV(String cvv, {String? cardNumber}) {
    // Remove espaços
    final cleaned = cvv.replaceAll(RegExp(r'\D'), '');

    // Verifica o comprimento baseado na bandeira do cartão
    if (cardNumber != null) {
      final brand = detectCardBrand(cardNumber);
      if (brand == CardBrand.amex) {
        // American Express usa 4 dígitos
        return cleaned.length == 4;
      }
    }

    // A maioria dos cartões usa 3 dígitos
    return cleaned.length == 3 || cleaned.length == 4;
  }

  /// Detecta a bandeira do cartão baseado nos primeiros dígitos
  static CardBrand detectCardBrand(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleaned.isEmpty) return CardBrand.unknown;
    
    // Visa: começa com 4
    if (cleaned.startsWith('4')) {
      return CardBrand.visa;
    }
    
    // Mastercard: começa com 51-55 ou 2221-2720
    if (RegExp(r'^5[1-5]').hasMatch(cleaned) ||
        RegExp(r'^2(22[1-9]|2[3-9][0-9]|[3-6][0-9]{2}|7[0-1][0-9]|720)').hasMatch(cleaned)) {
      return CardBrand.mastercard;
    }
    
    // American Express: começa com 34 ou 37
    if (cleaned.startsWith('34') || cleaned.startsWith('37')) {
      return CardBrand.amex;
    }
    
    // Elo: vários ranges específicos
    if (RegExp(r'^(4011|4312|4389|4514|4576|5041|5066|5067|5090|6277|6362|6363|6504|6505|6506|6507|6509|6516|6550)').hasMatch(cleaned)) {
      return CardBrand.elo;
    }
    
    // Hipercard: começa com 6062
    if (cleaned.startsWith('6062')) {
      return CardBrand.hipercard;
    }
    
    return CardBrand.unknown;
  }

  /// Formata o número do cartão para exibição
  static String formatCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    final brand = detectCardBrand(cleaned);

    // American Express: 4-6-5
    if (brand == CardBrand.amex && cleaned.length >= 15) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 10)} ${cleaned.substring(10)}';
    }

    // Outros cartões: 4-4-4-4
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  /// Mascara o número do cartão, mostrando apenas os últimos 4 dígitos
  static String maskCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 4) {
      return cleaned;
    }

    final lastFour = cleaned.substring(cleaned.length - 4);
    final maskedLength = cleaned.length - 4;
    final masked = '*' * maskedLength;

    // Formata com espaços
    final formatted = formatCardNumber(masked + lastFour);
    return formatted;
  }

  /// Valida todos os campos do cartão
  static Map<String, String?> validateCard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    String? cardHolderName,
  }) {
    print('=== CARD VALIDATOR ===');
    print('Card Number: ${cardNumber.substring(0, 4)}****${cardNumber.substring(cardNumber.length - 4)}');
    print('Expiry: $expiryMonth/$expiryYear');
    print('CVV: ${cvv.length} digits');
    print('Card Holder: $cardHolderName');
    
    final errors = <String, String?>{};

    // Valida número do cartão
    if (!validateCardNumber(cardNumber)) {
      print('❌ Card number validation failed');
      errors['cardNumber'] = 'Número do cartão inválido';
    } else {
      print('✅ Card number is valid');
    }

    // Valida data de expiração
    if (!validateExpiryDate(expiryMonth, expiryYear)) {
      print('❌ Expiry date validation failed');
      errors['expiry'] = 'Data de expiração inválida';
    } else {
      print('✅ Expiry date is valid');
    }

    // Valida CVV
    if (!validateCVV(cvv, cardNumber: cardNumber)) {
      print('❌ CVV validation failed');
      errors['cvv'] = 'Código de segurança inválido';
    } else {
      print('✅ CVV is valid');
    }

    // Valida nome do titular (opcional)
    if (cardHolderName != null && cardHolderName.trim().isEmpty) {
      print('❌ Card holder name is empty');
      errors['cardHolderName'] = 'Nome do titular é obrigatório';
    } else if (cardHolderName != null) {
      print('✅ Card holder name is valid');
    }
    
    print('Total errors: ${errors.length}');
    print('======================');

    return errors;
  }

  /// Retorna informações sobre a bandeira do cartão
  static Map<String, dynamic> getCardBrandInfo(String cardNumber) {
    final brand = detectCardBrand(cardNumber);
    
    return {
      'brand': brand,
      'displayName': _getBrandDisplayName(brand),
      'paymentMethodId': brand.paymentMethodId,
      'cvvLength': brand == CardBrand.amex ? 4 : 3,
      'maxLength': brand == CardBrand.amex ? 15 : 16,
    };
  }

  /// Retorna o nome de exibição da bandeira
  static String _getBrandDisplayName(CardBrand brand) {
    switch (brand) {
      case CardBrand.mastercard:
        return 'Mastercard';
      case CardBrand.visa:
        return 'Visa';
      case CardBrand.amex:
        return 'American Express';
      case CardBrand.elo:
        return 'Elo';
      case CardBrand.hipercard:
        return 'Hipercard';
      case CardBrand.unknown:
        return 'Desconhecido';
    }
  }
}