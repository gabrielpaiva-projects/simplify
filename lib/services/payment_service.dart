import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_response.dart';
import '../models/badge_models.dart';
import '../models/badge_payload_models.dart';
import '../utils/badge_generator.dart';
import '../utils/card_validator.dart';
import '../utils/secure_config.dart';

class PaymentService {
  static const String _baseUrl = 'https://simplify-backend-paas.onrender.com';
  
  static Map<String, String> _getHeaders(String badge) => {
    'Content-Type': 'application/json',
    'badge': badge,
  };

  static Future<ApiResponse<PixPaymentResponse>> processPixPayment({
    required String userId,
    required double amount,
    String description = 'Pagamento Simplify',
    ServiceSchedulingData? serviceData,
  }) async {
    try {
      final badge = BadgeGenerator.generatePixBadge(
        userId: userId,
        amount: amount,
        serviceData: serviceData,
      );
      
      print('=== DEBUG PIX PAYMENT ===');
      print('UserId: $userId');
      print('Amount: $amount');
      print('Badge gerada: $badge');
      print('Badge length: ${badge.length}');
      print('========================');

      final apiUrl = await SecureConfig.getApiBaseUrl();
      final url = Uri.parse('$apiUrl/api/payments/pix');

      final body = jsonEncode({
        'description': description,
      });
      
      print('URL: $url');
      print('Headers: ${_getHeaders(badge)}');
      print('Body: $body');

      final response = await http.post(
        url,
        headers: _getHeaders(badge),
        body: body,
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.fromJson(
          jsonData,
          (data) => PixPaymentResponse.fromJson(data),
        );
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: false,
          error: errorData['error'] ?? 'Erro ao processar pagamento PIX',
          message: errorData['message'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Erro de conexão: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<CardPaymentResponse>> processCardPayment({
    required String userId,
    required double amount,
    required String cardNumber,
    required String expirationYear,
    required String expirationMonth,
    required String securityCode,
    int installments = 1,
    String description = 'Teste de pagamento com cartão',
    ServiceSchedulingData? serviceData,
  }) async {
    try {
      print('=== DEBUG CARD PAYMENT SERVICE ===');
      print('UserId: $userId');
      print('Amount: $amount');
      print('Card Number: ${cardNumber.substring(0, 4)}****${cardNumber.substring(cardNumber.length - 4)}');
      print('Expiry: $expirationMonth/$expirationYear');
      print('CVV Length: ${securityCode.length}');
      print('Installments: $installments');
      print('Description: $description');
      
      final validationErrors = CardValidator.validateCard(
        cardNumber: cardNumber,
        expiryMonth: expirationMonth,
        expiryYear: expirationYear,
        cvv: securityCode,
      );

      if (validationErrors.isNotEmpty) {
        print('ERRO DE VALIDAÇÃO DO CARTÃO:');
        validationErrors.forEach((key, value) {
          print('  $key: $value');
        });
        return ApiResponse(
          success: false,
          error: 'Dados do cartão inválidos',
          message: validationErrors.values.join(', '),
        );
      }

      print('Cartão validado com sucesso!');

      final cardBrand = CardValidator.detectCardBrand(cardNumber);
      print('Bandeira detectada: ${cardBrand.name} (${cardBrand.paymentMethodId})');
      
      print('Gerando badge criptografada...');
      final badge = BadgeGenerator.generateCardBadge(
        userId: userId,
        amount: amount,
        cardNumber: cardNumber,
        expirationYear: expirationYear,
        expirationMonth: expirationMonth,
        securityCode: securityCode,
        installments: installments,
        serviceData: serviceData,
      );
      print('Badge gerada com sucesso! Length: ${badge.length}');

      final apiUrl = await SecureConfig.getApiBaseUrl();
      final url = Uri.parse('$apiUrl/api/payments/card');
      print('URL da API: $url');

      final body = jsonEncode({
        'description': description,
        'paymentMethodId': cardBrand.paymentMethodId,
      });
      
      print('Body da requisição: $body');
      print('Headers: Content-Type: application/json, badge: [ENCRYPTED]');

      print('Enviando requisição POST...');
      final response = await http.post(
        url,
        headers: _getHeaders(badge),
        body: body,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Resposta bem-sucedida!');
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(
          jsonData,
          (data) => CardPaymentResponse.fromJson(data),
        );
        
        if (apiResponse.data != null) {
          print('Pagamento processado:');
          print('  ID: ${apiResponse.data!.paymentId}');
          print('  Status: ${apiResponse.data!.status}');
          print('  Aprovado: ${apiResponse.data!.isApproved}');
        }
        
        return apiResponse;
      } else {
        print('ERRO HTTP: Status ${response.statusCode}');
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        print('Error Data: $errorData');
        return ApiResponse(
          success: false,
          error: errorData['error'] ?? 'Erro ao processar pagamento com cartão',
          message: errorData['message'],
        );
      }
    } catch (e, stackTrace) {
      print('EXCEÇÃO NO PAYMENT SERVICE:');
      print('Error: ${e.toString()}');
      print('Stack Trace: $stackTrace');
      return ApiResponse(
        success: false,
        error: 'Erro de conexão: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> checkPaymentStatus({
    required String paymentId,
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

  static Future<ApiResponse<Map<String, dynamic>>> cancelPayment({
    required String paymentId,
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

  static Future<ApiResponse<Map<String, dynamic>>> refundPayment({
    required String paymentId,
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