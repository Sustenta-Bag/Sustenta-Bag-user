import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../services/cart_service.dart';
import '../../services/payment_service.dart';
import '../../utils/database_helper.dart';

class ReviewOrderScreen extends StatefulWidget {
  final double subtotal;
  final double deliveryFee;

  const ReviewOrderScreen({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
  });

  @override
  State<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  final CartService _cartService = CartService();
  bool _isLoading = false;
  String? _errorMessage;

  double get total => widget.subtotal + widget.deliveryFee;
  Future<void> _createOrderAndProceedToPayment() async {
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

      // Primeiro, cria o pedido no sistema principal
      final order = _cartService.createOrder(userData['id']);
      final createdOrder = await OrderService.createOrder(order, token);
      
      if (createdOrder == null) {
        throw Exception('Falha ao criar pedido');
      }

      // Prepara os dados para o payment service
      final cartItems = _cartService.items;
      final paymentItems = cartItems.map((cartItem) => {
        'title': cartItem.name,
        'description': cartItem.description ?? cartItem.name,
        'quantity': cartItem.quantity,
        'unitPrice': cartItem.price,
      }).toList();

      final payerInfo = {
        'email': userData['email'] ?? 'user@example.com',
        'name': userData['name'] ?? 'Usuário',
        'identification': {
          'type': 'CPF',
          'number': '12345678901'
        }
      };      final paymentData = await PaymentService.createPayment(
        userId: userData['id'].toString(),
        orderId: createdOrder.id.toString(),
        items: paymentItems,
        payer: payerInfo,
      );

      if (paymentData != null && mounted) {
        _cartService.clear();
        
        Navigator.pushNamed(
          context, 
          '/bag/payment',
          arguments: {
            'paymentId': paymentData['paymentId'],
            'paymentUrl': paymentData['paymentUrl'],
            'orderId': createdOrder.id,
            'amount': total,
          }
        );
      } else {
        throw Exception('Falha ao criar pagamento');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Revisar Pedido',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo de valores',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),            _buildRow('Subtotal', widget.subtotal),
            const SizedBox(height: 8),
            _buildRow('Taxa de entrega', widget.deliveryFee),
            const SizedBox(height: 24),
            const Divider(),
            _buildRow('Total', total, isBold: true),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createOrderAndProceedToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                        'Prosseguir para pagamento',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          'R\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
