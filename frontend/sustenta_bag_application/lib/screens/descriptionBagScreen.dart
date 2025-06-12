import 'package:flutter/material.dart';
import 'package:sustenta_bag_application/models/nearby_bag.dart';
import 'package:sustenta_bag_application/models/business.dart'; // Importar BusinessData
import 'package:sustenta_bag_application/screens/StoreScreen.dart';
import '../services/cart_service.dart';

class DescriptionBagScreen extends StatefulWidget {
  final String id;
  final String imagePath;
  final String title;
  final String description;
  final double price;
  final String category;
  final String storeName;
  final String storeLogo;
  final Business business;

  const DescriptionBagScreen({
    super.key,
    required this.id,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.storeName,
    required this.storeLogo,
    required this.business,
  });

  @override
  _DescriptionBagScreenState createState() => _DescriptionBagScreenState();
}

class _DescriptionBagScreenState extends State<DescriptionBagScreen> {
  final CartService _cartService = CartService();

  void _addToCart() {
    try {
      final cartItem = CartItem(
        bagId: int.parse(widget.id),
        name: widget.title,
        price: widget.price,
        businessId: widget.business.id,
        description: widget.description,
      );

      _cartService.addItem(cartItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.title} adicionado ao carrinho!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _buyNow() {
    _addToCart();
    Navigator.pushNamed(context, '/bag');
  }

  BusinessData _convertToBusinessData(Business business) {
    return BusinessData(
      id: business.id,
      legalName: business.legalName,
      cnpj: '',
      appName: business.name,
      cellphone: '',
      description: null,
      delivery: false,
      deliveryTax: null,
      idAddress: 0,
      deliveryTime: 'Tempo não informado',
      logo: business.logo,
      status: true,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: null,
      address: business.address != null
          ? BusinessDataAddress(
              id: 0,
              street: business.address.street,
              number: business.address.number,
              city: business.address.city,
              state: business.address.state,
              zipCode: business.address.zipCode,
              complement: null,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -25,
                  left: -MediaQuery.of(context).size.width * 0.35,
                  right: -MediaQuery.of(context).size.width * 0.35,
                  child: Image.asset(
                    'assets/detail.png',
                    width: MediaQuery.of(context).size.width * 1.8,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 30,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Image.asset(
                    widget.imagePath,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 242, 241, 241),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 117, 116, 116)
                                  .withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: widget.business.logo != null &&
                                      widget.business.logo!.isNotEmpty
                                  ? Image.network(
                                      widget.business.logo!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset('assets/shop.png',
                                                  width: 40, height: 40),
                                    )
                                  : Image.asset(
                                      'assets/shop.png',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.business.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                final businessData =
                                    _convertToBusinessData(widget.business);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StoreScreen(
                                      id: widget.business.id.toString(),
                                      storeName: widget.business.name,
                                      storeLogo: widget.business.logo ??
                                          'assets/shop.png',
                                      storeDescription:
                                          'Descrição não disponível.',
                                      rating: 4.8,
                                      workingHours: '18:00 às 23:30',
                                      business:
                                          businessData,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Ver Loja',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        widget.description,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Atenção! Contém leite e derivados.',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Preço: R\$${widget.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: _addToCart,
                              child: const Text(
                                'Adicionar à Sacola',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: _buyNow,
                              child: Text(
                                'Comprar R\$${widget.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
