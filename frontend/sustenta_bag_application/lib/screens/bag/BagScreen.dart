import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../services/cart_service.dart';
import '../../utils/database_helper.dart';

class BagScreen extends StatefulWidget {
  const BagScreen({super.key});

  @override
  State<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  final CartService _cartService = CartService();
  bool _isLoading = false;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _loadActiveCart();
    _cartService.addListener(_onCartChanged);
  }

  Future<void> _loadActiveCart() async {
    try {
      final token = await DatabaseHelper.instance.getToken();
      final userData = await DatabaseHelper.instance.getUser();
      
      if (token != null && userData != null) {
        await _cartService.loadActiveCart(userData['id'], token);
      }
      
      // Se ainda estiver vazio após carregar da API, adiciona itens de exemplo
      if (_cartService.isEmpty) {
        _addSampleItems();
      }
    } catch (e) {
      print('Erro ao carregar carrinho ativo: $e');
      // Em caso de erro, adiciona itens de exemplo
      if (_cartService.isEmpty) {
        _addSampleItems();
      }
    }
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }
  void _addSampleItems() {
    _cartService.addItem(CartItem(
      bagId: 1,
      name: 'Sweet Surprise',
      price: 20.50,
      businessId: 1,
      description: 'Sacola doce misteriosa',
    ));
    _cartService.addItem(CartItem(
      bagId: 2,
      name: 'Salty Surprise',
      price: 18.00,
      businessId: 1,
      description: 'Sacola salgada misteriosa',
    ));
  }
  void _removeItem(int index) {
    final item = _cartService.items[index];
    _cartService.removeItem(item.bagId);
  }

  Future<void> _createOrder() async {
    if (_cartService.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carrinho vazio')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await DatabaseHelper.instance.getToken();
      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final userData = await DatabaseHelper.instance.getUser();
      if (userData == null) {
        throw Exception('Dados do usuário não encontrados');
      }

      final order = _cartService.createOrder(userData['id']);

      final createdOrder = await OrderService.createOrder(order, token);

      if (createdOrder != null) {
        _cartService.clear();

        if (mounted) {
          Navigator.pushNamed(
            context,
            '/bag/deliveryOptions',
            arguments: {
              'hasDelivery': true,
              'userAddress': 'Rua do Usuário, 123, Cidade, 12345678',
              'storeAddress': 'Rua da Loja, 456, Cidade, 87654321',
              'subtotal': order.totalAmount,
              'orderId': createdOrder.id,
            },
          );
        }
      } else {
        throw Exception('Falha ao criar pedido');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao criar pedido: ${e.toString()}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!)),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sacolas'),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revisar pedido',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),            Expanded(
              child: _cartService.isEmpty
                  ? const Center(
                      child: Text(
                        'Seu carrinho está vazio',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _cartService.items.length,
                      itemBuilder: (context, index) {
                        final item = _cartService.items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Image.asset('assets/bag.png', width: 50, height: 50),
                              const SizedBox(width: 12),                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      'R\$${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text('Quantidade: ${item.quantity}'),
                                    if (item.description != null)
                                      Text(
                                        item.description!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),            ),
            if (_cartService.isNotEmpty) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'R\$${_cartService.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],const SizedBox(height: 16),
            if (_cartService.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _createOrder,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Avançar',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
