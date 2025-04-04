import 'package:flutter/material.dart';

class DescriptionBagScreen extends StatefulWidget {
  final String id;
  final String imagePath;
  final String title;
  final String description;
  final double price;
  final String category;
  final String storeName;
  final String storeLogo;

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
  });

  @override
  _DescriptionBagScreenState createState() => _DescriptionBagScreenState();
}

class _DescriptionBagScreenState extends State<DescriptionBagScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -50,
            left: -screenWidth * 0.05,
            right: -screenWidth * 0.05,
            child: Image.asset(
              'assets/detail.png',
              width: screenWidth * 1,
              fit: BoxFit.contain,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),

              /// Imagem principal do produto
              Image.asset(widget.imagePath, width: 250),

              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                height: screenHeight * 0.63,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Logo + Nome da Loja
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      widget.storeLogo,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.storeName,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              // "Ver Loja" + "Retirada no Local"
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Ver Loja',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Retirada no Local',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(widget.description,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 10),
                          const Text(
                            'Atenção! Contém leite e derivados.',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                // Lógica para adicionar à sacola
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text(
                                  'Adicionar à Sacola',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                // Lógica para compra
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'Comprar  R\$${widget.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
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
            ],
          ),
        ],
      ),
    );
  }
}
