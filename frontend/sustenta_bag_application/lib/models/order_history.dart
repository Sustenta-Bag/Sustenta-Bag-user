import 'order.dart';

class OrderHistoryResponse {
  final List<Order> orders;
  final int total;
  final bool hasMore;

  OrderHistoryResponse({
    required this.orders,
    required this.total,
    required this.hasMore,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> ordersJson = json['orders'] ?? [];
    final orders = ordersJson.map((item) => Order.fromJson(item)).toList();

    return OrderHistoryResponse(
      orders: orders,
      total: json['total'] ?? 0,
      hasMore: !(json['lastPage'] ?? true),
    );
  }
}
