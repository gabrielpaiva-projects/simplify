import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_response.dart';
import '../models/badge_models.dart';
import '../utils/badge_generator.dart';
import '../utils/card_validator.dart';
import '../utils/secure_config.dart';

/// Serviço principal para processar pagamentos
class PaymentService {
  static const String _baseUrl = 'https://simplify-backend-paas.onrender.com';
  
  /// Headers padrão para as requisições
  static Map<String, String> _getHeaders(String badge) => {
    'Content-Type': 'application/json',
    'badge': badge,
  };

  /// Processa um pagamento via PIX
  static Future<ApiResponse<PixPaymentResponse>> processPixPayment({
    required String userId,
    required double amount,
    String description = 'Pagamento Simplify',
  }) async {
    try {
      // Gera a badge criptografada
      final badge = BadgeGenerator.generatePixBadge(
        userId: userId,
        amount: amount,
      );

      // Obtém a URL da API (pode ser configurada dinamicamente)
      final apiUrl = await SecureConfig.getApiBaseUrl();
      final url = Uri.parse('$apiUrl/api/payments/pix');

      // Prepara o corpo da requisição
      final body = jsonEncode({
        'description': description,
      });

      // Faz a requisição
      final response = await http.post(
        url,
        headers: _getHeaders(badge),
        body: body,
      );

      // Processa a resposta
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.fromJson(
          jsonData,
          (data) => PixPaymentResponse.fromJson(data),
        );
      } else {
        // Trata erros HTTP
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: false,
          error: errorData['error'] ?? 'Erro ao processar pagamento PIX',
          message: errorData['message'],
        );
      }
    } catch (e) {
      // Trata erros de rede ou parsing
      return ApiResponse(
        success: false,
        error: 'Erro de conexão: ${e.toString()}',
      );
    }
  }

  /// Processa um pagamento com cartão de crédito
  static Future<ApiResponse<CardPaymentResponse>> processCardPayment({
    required String userId,
    required double amount,
    required String cardNumber,
    required String expirationYear,
    required String expirationMonth,
    required String securityCode,
    int installments = 1,
    String description = 'Teste de pagamento com cartão',
  }) async {
    try {
      // Valida o cartão antes de enviar
      final validationErrors = CardValidator.validateCard(
        cardNumber: cardNumber,
        expiryMonth: expirationMonth,
        expiryYear: expirationYear,
        cvv: securityCode,
      );

      if (validationErrors.isNotEmpty) {
        return ApiResponse(
          success: false,
          error: 'Dados do cartão inválidos',
          message: validationErrors.values.join(', '),
        );
      }

      // Detecta a bandeira do cartão
      final cardBrand = CardValidator.detectCardBrand(cardNumber);
      
      // Gera a badge criptografada
      final badge = BadgeGenerator.generateCardBadge(
        userId: userId,
        amount: amount,
        cardNumber: cardNumber,
        expirationYear: expirationYear,
        expirationMonth: expirationMonth,
        securityCode: securityCode,
        installments: installments,
      );

      // Obtém a URL da API
      final apiUrl = await SecureConfig.getApiBaseUrl();
      final url = Uri.parse('$apiUrl/api/payments/card');

      // Prepara o corpo da requisição
      final body = jsonEncode({
        'description': description,
        'paymentMethodId': cardBrand.paymentMethodId,
      });

      // Faz a requisição
      final response = await http.post(
        url,
        headers: _getHeaders(badge),
        body: body,
      );

      // Processa a resposta
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.fromJson(
          jsonData,
          (data) => CardPaymentResponse.fromJson(data),
        );
      } else {
        // Trata erros HTTP
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: false,
          error: errorData['error'] ?? 'Erro ao processar pagamento com cartão',
          message: errorData['message'],
        );
      }
    } catch (e) {
      // Trata erros de rede ou parsing
      return ApiResponse(
        success: false,
        error: 'Erro de conexão: ${e.toString()}',
      );
    }
  }

  /// Verifica o status de um pagamento
  static Future<ApiResponse<Map<String, dynamic>>> checkPaymentStatus({
    required int paymentId,
  }) async {
    try {
      final apiUrl = await SecureConfig.getApiBaseUrl();
      final url = Uri.parse('$apiUrl/api/payments/status/$paymentId');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: true,
          data: jsonData['data'] as Map<String, dynamic>,
        );
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: false,
          error: errorData['error'] ?? 'Erro ao verificar status do pagamento',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Erro de conexão: ${e.toString()}',
      );
    }
  }

  /// Cancela um pagamento
  static Future<ApiResponse<Map<String, dynamic>>> cancelPayment({
    required int paymentId,
  }) async {
    try {
      final apiUrl = await SecureConfig.getApiBaseUrl();
      final url = Uri.parse('$apiUrl/api/payments/cancel/$paymentId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: true,
          data: jsonData['data'] as Map<String, dynamic>,
        );
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: false,
          error: errorData['error'] ?? 'Erro ao cancelar pagamento',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Erro de conexão: ${e.toString()}',
      );
    }
  }

  /// Processa um reembolso
  static Future<ApiResponse<Map<String, dynamic>>> refundPayment({
    required int paymentId,
    double? amount,
  }) async {
    try {
      final apiUrl = await SecureConfig.getApiBaseUrl();
      final url = Uri.parse('$apiUrl/api/payments/refund/$paymentId');

      final body = amount != null ? jsonEncode({'amount': amount}) : null;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: true,
          data: jsonData['data'] as Map<String, dynamic>,
        );
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: false,
          error: errorData['error'] ?? 'Erro ao processar reembolso',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Erro de conexão: ${e.toString()}',
      );
    }
  }
}