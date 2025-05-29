import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String baseUrl = 'http://10.0.2.2:3001/api';  static Future<Map<String, dynamic>?> createPayment({
    required String userId,
    required String orderId,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> payer,
    String? callbackUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
        },        body: jsonEncode({
          'userId': userId,
          'orderId': orderId,
          'items': items,
          'payer': payer,
          if (callbackUrl != null) 'callbackUrl': callbackUrl,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Pagamento criado com sucesso: ${data['data']}');
        return data['data'];
      } else {
        print('Erro ao criar pagamento: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao criar pagamento: $e');
      return null;
    }
  }
  static Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('Erro ao buscar status do pagamento: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar status do pagamento: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getPaymentByOrderId(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/order/$orderId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Pagamento encontrado para orderId $orderId: ${data['data']}');
        return data['data'];
      } else if (response.statusCode == 404) {
        print('Nenhum pagamento encontrado para orderId $orderId');
        return null;
      } else {
        print('Erro ao buscar pagamento por orderId: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar pagamento por orderId: $e');
      return null;
    }
  }


  static Future<bool> cancelPayment(String paymentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/$paymentId/cancel'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Pagamento cancelado com sucesso');
        return true;
      } else {
        print('Erro ao cancelar pagamento: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao cancelar pagamento: $e');
      return false;
    }
  }
  static Future<bool> simulatePaymentApproval(String paymentId) async {
    try {
      final paymentData = await getPaymentStatus(paymentId);
      if (paymentData == null) {
        print('Pagamento não encontrado para aprovação');
        return false;
      }

      final orderId = paymentData['orderId'];
      if (orderId == null) {
        print('OrderId não encontrado no pagamento');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/payment-simulation/process'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'orderId': orderId,
          'action': 'approve',
        }),
      );

      if (response.statusCode == 200) {
        print('Pagamento aprovado com sucesso');
        return true;
      } else {
        print('Erro ao aprovar pagamento: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao aprovar pagamento: $e');
      return false;
    }
  }

  static Future<bool> simulatePaymentRejection(String paymentId) async {
    try {
      final paymentData = await getPaymentStatus(paymentId);
      if (paymentData == null) {
        print('Pagamento não encontrado para rejeição');
        return false;
      }

      final orderId = paymentData['orderId'];
      if (orderId == null) {
        print('OrderId não encontrado no pagamento');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/payment-simulation/process'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'orderId': orderId,
          'action': 'reject',
        }),
      );

      if (response.statusCode == 200) {
        print('Pagamento rejeitado');
        return true;
      } else {
        print('Erro ao rejeitar pagamento: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao rejeitar pagamento: $e');
      return false;
    }
  }
}
