import 'package:credit_card_flag_detector/credit_card_flag_detector.dart';
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

  /// Detecta a bandeira do cartão usando a biblioteca credit_card_flag_detector
  static CardBrand detectCardBrand(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    // Usa a biblioteca para detectar a bandeira (API v1.0.0+6)
    final detector = CreditCardFlagDetector();
    final detectedBrand = detector.detectFlag(cleaned);
    
    // Mapeia para o enum CardBrand
    switch (detectedBrand) {
      case CreditCardFlag.mastercard:
        return CardBrand.mastercard;
      case CreditCardFlag.visa:
        return CardBrand.visa;
      case CreditCardFlag.americanExpress:
        return CardBrand.amex;
      case CreditCardFlag.elo:
        return CardBrand.elo;
      case CreditCardFlag.hipercard:
        return CardBrand.hipercard;
      default:
        return CardBrand.unknown;
    }
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
    final errors = <String, String?>{};

    // Valida número do cartão
    if (!validateCardNumber(cardNumber)) {
      errors['cardNumber'] = 'Número do cartão inválido';
    }

    // Valida data de expiração
    if (!validateExpiryDate(expiryMonth, expiryYear)) {
      errors['expiry'] = 'Data de expiração inválida';
    }

    // Valida CVV
    if (!validateCVV(cvv, cardNumber: cardNumber)) {
      errors['cvv'] = 'Código de segurança inválido';
    }

    // Valida nome do titular (opcional)
    if (cardHolderName != null && cardHolderName.trim().isEmpty) {
      errors['cardHolderName'] = 'Nome do titular é obrigatório';
    }

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