import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/order_history.dart';
import 'order_service.dart';
import 'package:collection/collection.dart';

class CartItem {
  final int bagId;
  final String name;
  final double price;
  final int businessId;
  final String? description;

  CartItem({
    required this.bagId,
    required this.name,
    required this.price,
    required this.businessId,
    this.description,
  });


  int get quantity => 1;
  double get totalPrice => price;
  Map<String, dynamic> toJson() {
    return {
      'bagId': bagId,
      'name': name,
      'price': price,
      'quantity': 1,
      'businessId': businessId,
      'description': description,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      bagId: json['bagId'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      businessId: json['businessId'] as int,
      description: json['description'] as String?,
    );
  }
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  double get total => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  int? get businessId => _items.isNotEmpty ? _items.first.businessId : null;
  bool get isSingleBusiness {
    if (_items.isEmpty) return true;
    final firstBusinessId = _items.first.businessId;
    return _items.every((item) => item.businessId == firstBusinessId);
  }

  void addItem(CartItem newItem) {
    final existingIndex = _items.indexWhere((item) => item.bagId == newItem.bagId);

    if (existingIndex >= 0) {
      return;
    } else {
      if (isNotEmpty && newItem.businessId != businessId) {
        throw Exception(
            'Não é possível adicionar itens de estabelecimentos diferentes. Limpe o carrinho primeiro.');
      }
      _items.add(newItem);
    }
    notifyListeners();
  }

  void removeItem(int bagId) {
    _items.removeWhere((item) => item.bagId == bagId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
  List<OrderItem> toOrderItems() {
    return _items
        .map((cartItem) => OrderItem(
      idBag: cartItem.bagId,
      quantity: 1,
      unitPrice: cartItem.price,
      totalPrice: cartItem.price,
      bagName: cartItem.name,
      bagDescription: cartItem.description,
    ))
        .toList();
  }

  Order createOrder(int idClient) {
    if (_items.isEmpty) {
      throw Exception('O carrinho está vazio.');
    }
    if (!isSingleBusiness) {
      throw Exception('Itens de estabelecimentos diferentes no carrinho.');
    }

    return Order(
      idClient: idClient,
      idBusiness: businessId!,
      status: 'pendente',
      totalAmount: total,
      createdAt: DateTime.now().toIso8601String(),
      items: toOrderItems(),
    );
  }

  Future<void> loadActiveCart(String token) async {
    try {

      final OrderHistoryResponse? response = await OrderService.getOrderHistory(
        token,
        status: 'pendente',
        limit: 1,
        orderBy: 'createdAt',
        orderDirection: 'DESC',
      );

      final activeOrder = response?.orders.firstWhereOrNull(
              (order) => order.status == 'pendente'
      );

      if (activeOrder != null) {
        bool needsUpdate = false;
        if (_items.length != activeOrder.items.length) {
          needsUpdate = true;
        } else {
          final localBagIds = _items.map((item) => item.bagId).toSet();
          final remoteBagIds = activeOrder.items.map((item) => item.idBag).toSet();
          if (!const SetEquality().equals(localBagIds, remoteBagIds)) {
            needsUpdate = true;
          }
        }
        if (needsUpdate) {
          _items.clear();

          for (final orderItem in activeOrder.items) {
            final cartItem = CartItem(
              bagId: orderItem.idBag,
              name: orderItem.bagName ?? 'Item sem nome',
              price: orderItem.unitPrice,
              businessId: activeOrder.idBusiness,
              description: orderItem.bagDescription,
            );
            _items.add(cartItem);
          }
          notifyListeners();
        }
      } else {
        if (_items.isNotEmpty) {
          _items.clear();
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar carrinho ativo: $e');
      }
    }
  }
}