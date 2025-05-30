import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../utils/api_config.dart';

class OrderService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Order?> createOrder(Order order, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode(order.toCreatePayload()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      } else {
        print('Erro ao criar pedido: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao criar pedido: $e');
      return null;
    }
  }

  static Future<List<Order>> getAllOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar pedidos: $e');
      return [];
    }
  }

  static Future<Order?> getOrder(int orderId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar pedido: $e');
      return null;
    }
  }

  static Future<List<Order>> getOrdersByUser(int userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/user/$userId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar pedidos do usuário: $e');
      return [];
    }
  }

  static Future<List<Order>> getOrdersByBusiness(int businessId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/business/$businessId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar pedidos do estabelecimento: $e');
      return [];
    }
  }

  static Future<bool> updateOrderStatus(int orderId, OrderStatus status, String token) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({'status': status.value}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao atualizar status do pedido: $e');
      return false;
    }
  }

  static Future<bool> addItemToOrder(int orderId, int bagId, int quantity, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/items'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({
          'bagId': bagId,
          'quantity': quantity,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Erro ao adicionar item ao pedido: $e');
      return false;
    }
  }

  static Future<bool> removeItemFromOrder(int orderId, int itemId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/orders/$orderId/items/$itemId'),
        headers: ApiConfig.getHeaders(token),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Erro ao remover item do pedido: $e');
      return false;
    }
  }

  static Future<bool> updateItemQuantity(int orderId, int itemId, int quantity, String token) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/items/$itemId/quantity'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({'quantity': quantity}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao atualizar quantidade do item: $e');
      return false;
    }
  }

  static Future<bool> cancelOrder(int orderId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erro ao cancelar pedido: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao cancelar pedido: $e');
      return false;
    }
  }

  static Future<List<Order>> getActiveOrdersByUser(int userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/user/$userId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final orders = data.map((json) => Order.fromJson(json)).toList();
        
        return orders.where((order) => 
          order.status == OrderStatus.pending.value ||
          order.status == OrderStatus.confirmed.value ||
          order.status == OrderStatus.preparing.value ||
          order.status == OrderStatus.ready.value
        ).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar pedidos ativos: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getOrderHistoryByUser(
    int userId, 
    String token, {
    String? status,
    String? startDate,
    String? endDate,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final uri = Uri.parse('$baseUrl/orders/history/user/$userId')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'orders': (data['orders'] as List<dynamic>)
              .map((json) => Order.fromJson(json))
              .toList(),
          'total': data['total'] ?? 0,
          'hasMore': data['hasMore'] ?? false,
        };
      }
      return null;
    } catch (e) {
      print('Erro ao buscar histórico de pedidos: $e');
      return null;
    }
  }


  static Future<Map<String, dynamic>?> getOrderStatsForUser(int userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/stats/user/$userId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar estatísticas de pedidos: $e');
      return null;
    }
  }
}
