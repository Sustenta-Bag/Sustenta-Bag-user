import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/business.dart';
import '../../models/bag.dart';
import '../../services/business_service.dart';
import '../../services/order_service.dart';
import '../../services/bag_service.dart';
import '../../utils/database_helper.dart';

class PendingOrderDetailsScreen extends StatefulWidget {
  final Order order;

  const PendingOrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<PendingOrderDetailsScreen> createState() =>
      _PendingOrderDetailsScreenState();
}

class _PendingOrderDetailsScreenState extends State<PendingOrderDetailsScreen> {
  BusinessData? businessData;
  Order? fullOrder;
  Map<int, Bag> bagDetails = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
  }

  Future<void> _loadBusinessData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final token = await DatabaseHelper.instance.getToken();
      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final orderFromApi = await OrderService.getOrder(widget.order.id!, token);
      if (orderFromApi == null) {
        throw Exception('Pedido não encontrado');
      }

      final business =
          await BusinessService.getBusiness(widget.order.businessId, token);

      Map<int, Bag> bagDetailsMap = {};
      for (final item in orderFromApi.items) {
        final bag = await BagService.getBag(item.bagId.toString(), token);
        if (bag != null) {
          bagDetailsMap[item.bagId] = bag;
        }
      }

      setState(() {
        fullOrder = orderFromApi;
        businessData = business;
        bagDetails = bagDetailsMap;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Pedido'),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[600]),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar dados',
                        style: TextStyle(fontSize: 18, color: Colors.red[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBusinessData,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Revisar pedido',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      if (businessData != null) ...[
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
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (businessData!.address != null) ...[
                                const SizedBox(height: 4),
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text(
                        'Suas Sacolas:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: fullOrder?.items.length ?? 0,
                          itemBuilder: (context, index) {
                            final item = fullOrder!.items[index];
                            final bag = bagDetails[item.bagId];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Image.asset('assets/bag.png',
                                      width: 50, height: 50),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bag?.name ?? 'Sacola',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'R\$${item.unitPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text('Quantidade: ${item.quantity}'),
                                        if (bag?.description != null &&
                                            bag!.description.isNotEmpty)
                                          Text(
                                            bag.description,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
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
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$${widget.order.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/bag/payment');
                          },
                          child: const Text(
                            'Pagar Agora',
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
