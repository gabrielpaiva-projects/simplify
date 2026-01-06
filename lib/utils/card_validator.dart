import '../models/badge_models.dart';

class CardValidator {
  static bool validateCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length < 13 || cleaned.length > 19) {
      return false;
    }

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

  static bool validateExpiryDate(String month, String year) {
    try {
      final monthInt = int.parse(month);
      final yearInt = int.parse(year);

      if (monthInt < 1 || monthInt > 12) {
        return false;
      }

      final now = DateTime.now();
      final currentYear = now.year;
      final currentMonth = now.month;

      final fullYear = yearInt < 100 ? 2000 + yearInt : yearInt;

      if (fullYear < currentYear) {
        return false;
      }

      if (fullYear == currentYear && monthInt < currentMonth) {
        return false;
      }

      if (fullYear > currentYear + 20) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static bool validateCVV(String cvv, {String? cardNumber}) {
    final cleaned = cvv.replaceAll(RegExp(r'\D'), '');

    if (cardNumber != null) {
      final brand = detectCardBrand(cardNumber);
      if (brand == CardBrand.amex) {
        return cleaned.length == 4;
      }
    }

    return cleaned.length == 3 || cleaned.length == 4;
  }

  static CardBrand detectCardBrand(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleaned.isEmpty) return CardBrand.unknown;
    
    if (cleaned.startsWith('5031')) {
      print('DEBUG: Detectando cartão 5031...');
      print('  - É Elo 5041/5066/5067/5090? ${RegExp(r'^(5041|5066|5067|5090)').hasMatch(cleaned)}');
      print('  - Matches 50XX? ${RegExp(r'^50[0-9]{2}').hasMatch(cleaned)}');
      print('  - Matches 51-55? ${RegExp(r'^5[1-5]').hasMatch(cleaned)}');
    }
    
    if (RegExp(r'^(4011|4312|4389|4514|4576|5041|5066|5067|5090|6277|6362|6363|6504|6505|6506|6507|6509|6516|6550)').hasMatch(cleaned)) {
      return CardBrand.elo;
    }
    
    if (cleaned.startsWith('4') && !RegExp(r'^(4011|4312|4389|4514|4576)').hasMatch(cleaned)) {
      return CardBrand.visa;
    }
    
    if (RegExp(r'^5[1-5]').hasMatch(cleaned) ||
        RegExp(r'^50[0-9]{2}').hasMatch(cleaned) && !RegExp(r'^(5041|5066|5067|5090)').hasMatch(cleaned) ||
        RegExp(r'^2(22[1-9]|2[3-9][0-9]|[3-6][0-9]{2}|7[0-1][0-9]|720)').hasMatch(cleaned)) {
      return CardBrand.mastercard;
    }
    
    if (cleaned.startsWith('34') || cleaned.startsWith('37')) {
      return CardBrand.amex;
    }
    
    if (cleaned.startsWith('6062')) {
      return CardBrand.hipercard;
    }
    
    return CardBrand.unknown;
  }

  static String formatCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    final brand = detectCardBrand(cleaned);

    if (brand == CardBrand.amex && cleaned.length >= 15) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 10)} ${cleaned.substring(10)}';
    }

    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  static String maskCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 4) {
      return cleaned;
    }

    final lastFour = cleaned.substring(cleaned.length - 4);
    final maskedLength = cleaned.length - 4;
    final masked = '*' * maskedLength;

    final formatted = formatCardNumber(masked + lastFour);
    return formatted;
  }

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

    if (!validateCardNumber(cardNumber)) {
      print('❌ Card number validation failed');
      errors['cardNumber'] = 'Número do cartão inválido';
    } else {
      print('✅ Card number is valid');
    }

    if (!validateExpiryDate(expiryMonth, expiryYear)) {
      print('❌ Expiry date validation failed');
      errors['expiry'] = 'Data de expiração inválida';
    } else {
      print('✅ Expiry date is valid');
    }

    if (!validateCVV(cvv, cardNumber: cardNumber)) {
      print('❌ CVV validation failed');
      errors['cvv'] = 'Código de segurança inválido';
    } else {
      print('✅ CVV is valid');
    }

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