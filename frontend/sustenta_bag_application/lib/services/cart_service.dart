import 'package:flutter/foundation.dart';
import '../models/order.dart';
import 'order_service.dart';

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

  // Quantidade sempre 1
  int get quantity => 1;
  double get totalPrice => price;
  Map<String, dynamic> toJson() {
    return {
      'bagId': bagId,
      'name': name,
      'price': price,
      'quantity': 1, // Sempre 1
      'businessId': businessId,
      'description': description,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      bagId: json['bagId'],
      name: json['name'],
      price: json['price'].toDouble(),
      businessId: json['businessId'],
      description: json['description'],
    );
  }
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];
  
  List<CartItem> get items => List.unmodifiable(_items);
  
  int get itemCount => _items.length; // Conta número de itens únicos
  
  double get total => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  bool get isEmpty => _items.isEmpty;
  
  bool get isNotEmpty => _items.isNotEmpty;

  bool get isSingleBusiness {
    if (_items.isEmpty) return true;
    final firstBusinessId = _items.first.businessId;
    return _items.every((item) => item.businessId == firstBusinessId);
  }

  int? get businessId => _items.isNotEmpty ? _items.first.businessId : null;
  void addItem(CartItem newItem) {
    final existingIndex = _items.indexWhere((item) => item.bagId == newItem.bagId);
    
    if (existingIndex >= 0) {
      // Item já existe no carrinho, não adiciona novamente
      return;
    } else {
      if (_items.isNotEmpty && !isSingleBusiness) {
        throw Exception('Não é possível adicionar itens de estabelecimentos diferentes');
      }
      
      _items.add(newItem);
    }
    
    notifyListeners();
  }

  // Remove método updateQuantity pois quantidade é sempre 1
  void removeItem(int bagId) {
    _items.removeWhere((item) => item.bagId == bagId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
  List<OrderItem> toOrderItems() {
    return _items.map((cartItem) => OrderItem(
      bagId: cartItem.bagId,
      quantity: 1, // Sempre 1
      unitPrice: cartItem.price,
      totalPrice: cartItem.price, // Sem multiplicação
      bagName: cartItem.name,
      bagDescription: cartItem.description,
    )).toList();
  }

  Order createOrder(int userId) {
    if (_items.isEmpty) {
      throw Exception('Carrinho vazio');
    }

    if (!isSingleBusiness) {
      throw Exception('Itens de estabelecimentos diferentes no carrinho');
    }

    return Order(
      userId: userId,
      businessId: businessId!,
      status: OrderStatus.pending.value,
      totalAmount: total,
      createdAt: DateTime.now().toIso8601String(),
      items: toOrderItems(),
    );
  }

  // Carrega carrinho ativo da API
  Future<void> loadActiveCart(int userId, String token) async {
    try {
      final activeOrders = await OrderService.getActiveOrdersByUser(userId, token);
      
      // Se há pedido ativo, carrega os itens no carrinho
      if (activeOrders.isNotEmpty) {
        final activeOrder = activeOrders.first; // Pega o primeiro pedido ativo
        
        clear(); // Limpa carrinho atual
        
        // Adiciona itens do pedido ativo ao carrinho
        for (final orderItem in activeOrder.items) {
          final cartItem = CartItem(
            bagId: orderItem.bagId,
            name: orderItem.bagName ?? 'Item',
            price: orderItem.unitPrice,
            businessId: activeOrder.businessId,
            description: orderItem.bagDescription,
          );
          _items.add(cartItem);
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao carregar carrinho ativo: $e');
    }
  }
}
