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
      totalAmount:
          (json['totalAmount'] is num) ? json['totalAmount'].toDouble() : 0.0,
      notes: json['notes'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
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

  Map<String, dynamic> toCreatePayload() {
    return {
      'userId': userId,
      'idBusiness': businessId,
      'items': items
          .map((item) => {
                'idBag': item.bagId,
                'quantity': item.quantity,
              })
          .toList(),
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
    double priceValue = 0.0;
    if (json['price'] != null) {
      if (json['price'] is String) {
        priceValue = double.tryParse(json['price']) ?? 0.0;
      } else if (json['price'] is num) {
        priceValue = json['price'].toDouble();
      }
    } else if (json['unitPrice'] is num) {
      priceValue = json['unitPrice'].toDouble();
    }

    return OrderItem(
      id: json['id'],
      orderId: json['orderId'],
      bagId: json['bagId'],
      quantity: json['quantity'],
      unitPrice: priceValue,
      totalPrice: (json['totalPrice'] is num)
          ? json['totalPrice'].toDouble()
          : priceValue * (json['quantity'] ?? 1),
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
      case 'pendente':
        return OrderStatus.pending;
      case 'confirmed':
      case 'confirmado':
        return OrderStatus.confirmed;
      case 'preparing':
      case 'preparando':
        return OrderStatus.preparing;
      case 'ready':
      case 'pronto':
        return OrderStatus.ready;
      case 'delivered':
      case 'entregue':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'cancelado':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
