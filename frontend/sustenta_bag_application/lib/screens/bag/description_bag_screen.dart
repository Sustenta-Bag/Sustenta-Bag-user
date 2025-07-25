import 'package:flutter/material.dart';
import 'package:sustenta_bag_application/models/nearby_bag.dart';
import 'package:sustenta_bag_application/screens/business/business_screen.dart';
import '../../models/allergen_tag.dart';
import '../../services/business_service.dart';
import '../../services/cart_service.dart';
import '../../utils/database_helper.dart';

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
  final List<String> tags;

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
    required this.tags,
  });

  @override
  _DescriptionBagScreenState createState() => _DescriptionBagScreenState();
}

class _DescriptionBagScreenState extends State<DescriptionBagScreen> {
  final CartService _cartService = CartService();
  bool _isLoadingStore = false;


  @override
  void initState() {
    super.initState();
  }

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

  Future<void> _navigateToStore() async {
    setState(() {
      _isLoadingStore = true;
    });

    try {
      final token = await DatabaseHelper.instance.getToken();
      if (token == null) {
        throw Exception("Usuário não autenticado.");
      }

      final businessData =
      await BusinessService.getBusiness(widget.business.id, token);

      if (businessData == null) {
        throw Exception("Não foi possível carregar os dados da loja.");
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreScreen(
              id: businessData.id.toString(),
              storeName: businessData.appName,
              storeLogo: businessData.logo ?? 'assets/shop.png',
              storeDescription:
              businessData.description ?? 'Descrição não disponível.',
              rating: 4.8,
              workingHours:
              businessData.openingHours ?? 'Horário não informado',
              business: businessData,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar loja: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStore = false;
        });
      }
    }
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
                              onPressed: _isLoadingStore ? null : _navigateToStore,
                              child: _isLoadingStore
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                                  : const Text(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.tags.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Informações sobre Alergênicos',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4A5568)),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: widget.tags.map((apiTag) {
                                      final AllergenTag tag =
                                          AllergenTagExtension.fromString(
                                              apiTag);

                                      if (tag == AllergenTag.unknown) {
                                        return const SizedBox
                                            .shrink();
                                      }
                                      return Chip(
                                        avatar: Icon(
                                          tag.icon,
                                          size: 18,
                                          color: Colors.orange[800],
                                        ),
                                        label: Text(
                                          tag.displayName,
                                          style: TextStyle(
                                            color: Colors.orange[900],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        backgroundColor:
                                            Colors.orange.withOpacity(0.15),
                                        side: BorderSide.none,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 8.0),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                        ],
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
