import 'package:flutter/material.dart';
import '../../models/business.dart';
import '../../models/client.dart';
import '../../models/address.dart';
import '../../services/business_service.dart';
import '../../services/client_service.dart';
import '../../services/address_service.dart';
import '../../services/cart_service.dart';
import '../../utils/database_helper.dart';

class DeliveryOptionScreen extends StatefulWidget {
  final double subtotal;

  const DeliveryOptionScreen({
    super.key,
    required this.subtotal,
  });

  @override
  State<DeliveryOptionScreen> createState() => _DeliveryOptionScreenState();
}

class _DeliveryOptionScreenState extends State<DeliveryOptionScreen> {
  final CartService _cartService = CartService();
  BusinessData? businessData;
  Client? clientData;
  Address? clientAddress;
  bool isLoading = true;
  String? errorMessage;
  bool isPickupSelected = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final token = await DatabaseHelper.instance.getToken();
      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final userData = await DatabaseHelper.instance.getUser();
      if (userData == null) {
        throw Exception('Dados do usuário não encontrados');
      }

      if (_cartService.isEmpty) {
        throw Exception(
            'Carrinho vazio. Adicione itens ao carrinho antes de prosseguir.');
      }

      final client =
      await ClientService.getClient(userData['entityId'].toString(), token);
      if (client == null) {
        throw Exception('Dados do cliente não encontrados');
      }

      final address =
      await AddressService.getAddress(client.idAddress.toString(), token);

      BusinessData? business;

      if (_cartService.businessId != null) {
        business =
        await BusinessService.getBusiness(_cartService.businessId!, token);
      }

      setState(() {
        clientData = client;
        clientAddress = address;
        businessData = business;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Opções de Entrega',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Opções de Entrega',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Erro: $errorMessage',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final hasDelivery = businessData?.delivery ?? false;
    final deliveryTax = businessData?.deliveryTax ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Opções de Entrega',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // MUDANÇA 1: O body agora é só o conteúdo que precisa rolar.
      // Removemos o Container com altura fixa e o Spacer.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Padding movido para cá
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (businessData != null) ...[
              const Text(
                'Estabelecimento:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessData!.appName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    if (businessData!.address != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.red),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              businessData!.address!.fullAddress,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (businessData!.cellphone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Telefone: ${businessData!.cellphone}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Suas Bags:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ..._cartService.items
                  .map((item) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag,
                        color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          if (item.description != null &&
                              item.description!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      'R\$ ${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ))
                  .toList(),
              const SizedBox(height: 16),
            ],
            const Text(
              'Retirada no Local:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isPickupSelected ? Colors.red[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isPickupSelected ? Colors.red : Colors.grey,
                  width: isPickupSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    isPickupSelected = true;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Retirar no estabelecimento',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (businessData?.address != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Colors.red),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    businessData!.address!.fullAddress,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      isPickupSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isPickupSelected ? Colors.red : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            if (!hasDelivery)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aviso! O estabelecimento não tem opção de entrega.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            if (hasDelivery) ...[
              const SizedBox(height: 16),
              const Text(
                'Entrega:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color:
                  !isPickupSelected ? Colors.red[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: !isPickupSelected ? Colors.red : Colors.grey,
                    width: !isPickupSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isPickupSelected = false;
                    });
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Entrega em domicílio',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            !isPickupSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: !isPickupSelected
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Taxa de entrega:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$ ${deliveryTax.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (clientAddress != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Seu Endereço:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(clientAddress!.fullAddress),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            // MUDANÇA 2: O Spacer e o botão foram removidos daqui.
          ],
        ),
      ),
      // MUDANÇA 3: Adicionamos a propriedade `bottomNavigationBar` ao Scaffold.
      // O botão agora vive aqui, sempre visível e fixo na parte inferior.
      bottomNavigationBar: Container(
        color: Colors.white, // Para combinar com o fundo do Scaffold
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), // Padding para o botão
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final finalDeliveryFee =
              isPickupSelected ? 0.0 : deliveryTax;
              Navigator.pushNamed(
                context,
                '/bag/reviewOrder',
                arguments: {
                  'subtotal': widget.subtotal,
                  'deliveryFee': finalDeliveryFee,
                  'isPickup': isPickupSelected,
                  'businessData': businessData,
                  'clientAddress': clientAddress,
                },
              );
            },
            child: Text(
              isPickupSelected
                  ? 'Confirmar Retirada - R\$ ${widget.subtotal.toStringAsFixed(2)}'
                  : 'Confirmar Entrega - R\$ ${(widget.subtotal + deliveryTax).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}