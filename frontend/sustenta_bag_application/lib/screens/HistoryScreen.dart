import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../services/business_service.dart';
import '../../services/review_service.dart';
import '../../utils/database_helper.dart';
import '../../models/order.dart';
import '../../models/business.dart';
import '../../models/review.dart';
import 'Review/ReviewScreen.dart';

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
  Map<int, Review?> _orderReviewStatus = {};
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

        final newBusinessCache = Map<int, BusinessData>.from(businessCache);
        final newOrderReviewStatus = Map<int, Review?>.from(_orderReviewStatus);

        for (final order in orders) {
          if (!newBusinessCache.containsKey(order.businessId)) {
            final business =
                await BusinessService.getBusiness(order.businessId, token);
            if (business != null) {
              newBusinessCache[order.businessId] = business;
            }
          }

          if (order.status == OrderStatus.delivered.value && order.id != null) {
            if (!newOrderReviewStatus.containsKey(order.id)) {
              final review = await ReviewService.getReviewByOrder(
                  order.id!, userData['id'], token);
              newOrderReviewStatus[order.id!] = review;
            }
          }
        }

        setState(() {
          activeOrder = activeOrders.isNotEmpty ? activeOrders.first : null;
          orderHistory = orders
              .where((order) =>
                  order.status != 'confirmado' &&
                  order.status != 'preparando' &&
                  order.status != 'pronto')
              .toList();
          businessCache = newBusinessCache;
          _orderReviewStatus =
              newOrderReviewStatus;
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

        final updatedBusinessCache = Map<int, BusinessData>.from(businessCache);
        final updatedOrderReviewStatus =
            Map<int, Review?>.from(_orderReviewStatus);

        for (final order in newOrders) {
          if (!updatedBusinessCache.containsKey(order.businessId)) {
            final business =
                await BusinessService.getBusiness(order.businessId, token);
            if (business != null) {
              updatedBusinessCache[order.businessId] = business;
            }
          }
          if (order.status == OrderStatus.delivered.value && order.id != null) {
            if (!updatedOrderReviewStatus.containsKey(order.id)) {
              final review = await ReviewService.getReviewByOrder(
                  order.id!, userData['id'], token);
              updatedOrderReviewStatus[order.id!] = review;
            }
          }
        }

        setState(() {
          final filteredOrders = newOrders
              .where((order) =>
                  order.status != 'confirmado' &&
                  order.status != 'preparando' &&
                  order.status != 'pronto')
              .toList();

          orderHistory.addAll(filteredOrders);
          businessCache = updatedBusinessCache;
          _orderReviewStatus =
              updatedOrderReviewStatus;
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

  Future<void> _cancelOrder(Order order) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Pedido'),
          content:
              const Text('Você tem certeza que deseja cancelar este pedido?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Sim, cancelar'),
            ),
          ],
        );
      },
    );

    if (shouldCancel == true) {
      try {
        final token = await DatabaseHelper.instance.getToken();
        if (token == null) {
          throw Exception('Token de autenticação não encontrado');
        }

        final success = await OrderService.cancelOrder(order.id!, token);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pedido cancelado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );

          _loadOrderHistory();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao cancelar pedido'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                                if (activeOrder!.status == 'pendente') ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/bag/pendingOrderDetails',
                                              arguments: {
                                                'order': activeOrder!,
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Pagar Agora',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _cancelOrder(activeOrder!),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[600],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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

    final hasReview = order.id != null && _orderReviewStatus[order.id!] != null;
    final review = _orderReviewStatus[order.id!];

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
                if (!hasReview)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final userData =
                            await DatabaseHelper.instance.getUser();
                        if (userData != null && order.id != null) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewScreen(
                                estabelecimento: businessName,
                                estabelecimentoId: order.businessId.toString(),
                                idOrder: order.id!,
                                idClient: userData['id'],
                              ),
                            ),
                          );
                          if (result == true) {
                            _loadOrderHistory();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Dados de usuário ou pedido incompletos.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8514C),
                        // Cor vermelha do seu tema
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical:
                              12,
                        ),
                      ),
                      child: const Text(
                        'Fazer Avaliação',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Text(
                          'Avaliação feita: ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review!.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
              ],
              if (order.status == 'pendente') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/bag/pendingOrderDetails',
                            arguments: {
                              'order': order,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Pagar Agora',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _cancelOrder(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
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
