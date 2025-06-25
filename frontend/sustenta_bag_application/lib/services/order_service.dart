import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/order_history.dart';
import '../utils/api_config.dart';


class PaginatedOrdersResponse {
  final List<Order> orders;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasMore;

  PaginatedOrdersResponse({
    required this.orders,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
  }) : hasMore = currentPage < totalPages;
}


class OrderService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<OrderHistoryResponse?> getOrderHistory(
      String token, {
        int page = 1,
        int limit = 10,
        String? status,
        String? startDate,
        String? endDate,
        String? orderBy,
        String? orderDirection,
      }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (orderBy != null) queryParams['orderBy'] = orderBy;
      if (orderDirection != null) queryParams['orderDirection'] = orderDirection;

      final uri = Uri.parse('$baseUrl/orders/history').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return OrderHistoryResponse.fromJson(body);
      } else {
        print('Erro ao buscar histórico de pedidos: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar histórico de pedidos: $e');
      return null;
    }
  }


  static Future<Order?> createOrder(Order order, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode(order.toCreatePayload()),
      );

      if (response.statusCode == 200) {
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
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({'status': 'cancelled'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erro ao cancelar pedido (status): ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao cancelar pedido (status): $e');
      return false;
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
