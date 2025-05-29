class Payment {
  final String? id;
  final String orderId;
  final String userId;
  final double amount;
  final String currency;
  final List<PaymentItem> items;
  final String status;
  final String paymentMethod;
  final String? paymentId;
  final String? paymentUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Payment({
    this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    this.currency = 'BRL',
    required this.items,
    this.status = 'pending',
    this.paymentMethod = 'simulation',
    this.paymentId,
    this.paymentUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'] ?? json['id'],
      orderId: json['orderId'],
      userId: json['userId'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'BRL',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => PaymentItem.fromJson(item))
              .toList() ??
          [],
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'simulation',
      paymentId: json['paymentId'],
      paymentUrl: json['paymentUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'paymentMethod': paymentMethod,
      if (paymentId != null) 'paymentId': paymentId,
      if (paymentUrl != null) 'paymentUrl': paymentUrl,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
  bool get isRefunded => status == 'refunded';

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Aguardando Pagamento';
      case 'approved':
        return 'Pagamento Aprovado';
      case 'rejected':
        return 'Pagamento Rejeitado';
      case 'cancelled':
        return 'Pagamento Cancelado';
      case 'refunded':
        return 'Pagamento Reembolsado';
      default:
        return 'Status Desconhecido';
    }
  }
}

class PaymentItem {
  final String title;
  final String description;
  final int quantity;
  final double unitPrice;

  PaymentItem({
    required this.title,
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      title: json['title'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  double get totalPrice => unitPrice * quantity;
}

class PayerInfo {
  final String email;
  final String name;
  final PayerIdentification identification;

  PayerInfo({
    required this.email,
    required this.name,
    required this.identification,
  });

  factory PayerInfo.fromJson(Map<String, dynamic> json) {
    return PayerInfo(
      email: json['email'],
      name: json['name'],
      identification: PayerIdentification.fromJson(json['identification']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'identification': identification.toJson(),
    };
  }
}

class PayerIdentification {
  final String type;
  final String number;

  PayerIdentification({
    required this.type,
    required this.number,
  });

  factory PayerIdentification.fromJson(Map<String, dynamic> json) {
    return PayerIdentification(
      type: json['type'],
      number: json['number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'number': number,
    };
  }
}
