import 'package:flutter/material.dart';
import 'package:sustenta_bag_application/screens/ReviewScreen.dart';
import '../../services/order_service.dart';
import '../../services/business_service.dart';
import '../../utils/database_helper.dart';
import '../../models/order.dart';
import '../../models/business.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  List<Order> orderHistory = [];
  Order? activeOrder;
  Map<int, BusinessData> businessCache = {};
  bool hasMore = true;
  int currentOffset = 0;
  final int pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!isLoadingMore && hasMore) {
        _loadMoreHistory();
      }
    }
  }

  Future<void> _loadOrderHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
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

      final activeOrders =
          await OrderService.getActiveOrdersByUser(userData['id'], token);
      final historyResult = await OrderService.getOrderHistoryByUser(
        userData['id'],
        token,
        limit: pageSize,
        offset: 0,
      );

      if (historyResult != null) {
        final orders = historyResult['orders'] as List<Order>;
        final totalHasMore = historyResult['hasMore'] as bool;

        for (final order in orders) {
          if (!businessCache.containsKey(order.businessId)) {
            final business =
                await BusinessService.getBusiness(order.businessId, token);
            if (business != null) {
              businessCache[order.businessId] = business;
            }
          }
        }        setState(() {
          activeOrder = activeOrders.isNotEmpty ? activeOrders.first : null;
          orderHistory = orders
              .where((order) =>
                  order.status != OrderStatus.pending.value &&
                  order.status != OrderStatus.confirmed.value &&
                  order.status != OrderStatus.preparing.value &&
                  order.status != OrderStatus.ready.value)
              .toList();
          hasMore = totalHasMore;
          currentOffset = pageSize;
          isLoading = false;
        });
      } else {
        throw Exception('Erro ao carregar histórico');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadMoreHistory() async {
    if (isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final token = await DatabaseHelper.instance.getToken();
      if (token == null) return;

      final userData = await DatabaseHelper.instance.getUser();
      if (userData == null) return;

      final historyResult = await OrderService.getOrderHistoryByUser(
        userData['id'],
        token,
        limit: pageSize,
        offset: currentOffset + pageSize,
      );
      if (historyResult != null) {
        final newOrders = historyResult['orders'] as List<Order>;
        final newHasMore = historyResult['hasMore'] as bool;

        for (final order in newOrders) {
          if (!businessCache.containsKey(order.businessId)) {
            final business =
                await BusinessService.getBusiness(order.businessId, token);
            if (business != null) {
              businessCache[order.businessId] = business;
            }
          }
        }        setState(() {
          final filteredOrders = newOrders
              .where((order) =>
                  order.status != OrderStatus.pending.value &&
                  order.status != OrderStatus.confirmed.value &&
                  order.status != OrderStatus.preparing.value &&
                  order.status != OrderStatus.ready.value)
              .toList();

          orderHistory.addAll(filteredOrders);
          hasMore = newHasMore;
          currentOffset += pageSize;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      final months = [
        'janeiro',
        'fevereiro',
        'março',
        'abril',
        'maio',
        'junho',
        'julho',
        'agosto',
        'setembro',
        'outubro',
        'novembro',
        'dezembro'
      ];

      return '${weekdays[date.weekday % 7]}, ${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return isoDate;
    }
  }

  String _getOrderDescription(Order order) {
    if (order.items.isEmpty) return 'Pedido sem itens';

    final itemCount = order.items.length;
    if (itemCount == 1) {
      return order.items.first.bagName ?? '1 Sacola';
    } else {
      return '$itemCount Sacolas';
    }
  }

  String _getStatusDisplayName(String status) {
    final orderStatus = OrderStatusExtension.fromString(status);
    return orderStatus.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status do Pedido'),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
                        'Erro ao carregar histórico',
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
                        onPressed: _loadOrderHistory,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrderHistory,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (activeOrder != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getStatusDisplayName(activeOrder!.status),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(_getOrderDescription(activeOrder!) +
                                    ' | ${businessCache[activeOrder!.businessId]?.appName ?? 'Estabelecimento'}'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        const Text(
                          'Histórico',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),

                        if (orderHistory.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'Nenhum pedido no histórico',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                          )
                        else
                          ...orderHistory.map((order) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildHistoryItem(
                                  context,
                                  order: order,
                                ),
                              )),

                        if (isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, {required Order order}) {
    final business = businessCache[order.businessId];
    final businessName = business?.appName ?? 'Estabelecimento';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDate(order.createdAt),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront_outlined, size: 32),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      businessName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              if (order.status == OrderStatus.delivered.value) ...[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewScreen(
                          estabelecimento: businessName,
                          estabelecimentoId: order.businessId.toString(),
                        ),
                      ),
                    );
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Fazer avaliação',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: Text(_getOrderDescription(order)),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Status: ${_getStatusDisplayName(order.status)}',
                  style: TextStyle(
                    color: order.status == OrderStatus.delivered.value
                        ? Colors.green
                        : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
