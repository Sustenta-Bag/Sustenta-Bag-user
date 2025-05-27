import 'package:flutter/material.dart';

class BagScreen extends StatefulWidget {
  const BagScreen({super.key});

  @override
  State<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  List<Map<String, dynamic>> bagItems = [
    {'name': 'Sweet Surprise', 'price': 20.50, 'quantity': 2},
    {'name': 'Sweet Surprise', 'price': 20.50, 'quantity': 2},
    {'name': 'Sweet Surprise', 'price': 20.50, 'quantity': 2},
    {'name': 'Sweet Surprise', 'price': 20.50, 'quantity': 2},
  ];

  void _removeItem(int index) {
    setState(() {
      bagItems.removeAt(index);
    });
  }

  double getTotal() {
    return bagItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
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
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: bagItems.length,
                itemBuilder: (context, index) {
                  final item = bagItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/Bag.png', width: 50, height: 50),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                item['price'].toStringAsFixed(2),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text('Quantidade: ${item['quantity']}'),
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
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'R\$${getTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/Bag/deliveryOptions',
                    arguments: {
                      'hasDelivery': true,
                      'userAddress': 'Rua do Usuário, 123, Cidade, 12345678',
                      'storeAddress': 'Rua da Loja, 456, Cidade, 87654321',
                      'subtotal': getTotal(),
                    },
                  );
                },
                child: const Text(
                  'Avançar',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
