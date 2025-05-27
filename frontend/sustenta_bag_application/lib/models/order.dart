class Order {
  final int? id;
  final int userId;
  final int businessId;
  final String status;
  final double totalAmount;
  final String? notes;
  final String createdAt;
  final String? updatedAt;
  final List<OrderItem> items;

  Order({
    this.id,
    required this.userId,
    required this.businessId,
    required this.status,
    required this.totalAmount,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      businessId: json['businessId'],
      status: json['status'],
      totalAmount: (json['totalAmount'] is num) 
          ? json['totalAmount'].toDouble() 
          : 0.0,
      notes: json['notes'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'businessId': businessId,
      'status': status,
      'totalAmount': totalAmount,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Helper method para criar payload de criação de pedido
  Map<String, dynamic> toCreatePayload() {
    return {
      'userId': userId,
      'businessId': businessId,
      'items': items.map((item) => {
        'bagId': item.bagId,
        'quantity': item.quantity,
      }).toList(),
    };
  }
}

class OrderItem {
  final int? id;
  final int? orderId;
  final int bagId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? bagName;
  final String? bagDescription;

  OrderItem({
    this.id,
    this.orderId,
    required this.bagId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.bagName,
    this.bagDescription,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['orderId'],
      bagId: json['bagId'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] is num) 
          ? json['unitPrice'].toDouble() 
          : 0.0,
      totalPrice: (json['totalPrice'] is num) 
          ? json['totalPrice'].toDouble() 
          : 0.0,
      bagName: json['bagName'],
      bagDescription: json['bagDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'bagId': bagId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'bagName': bagName,
      'bagDescription': bagDescription,
    };
  }
}

// Enum para status do pedido
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.ready:
        return 'Pronto';
      case OrderStatus.delivered:
        return 'Entregue';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.ready:
        return 'ready';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
