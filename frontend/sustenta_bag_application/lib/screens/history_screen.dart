import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../services/business_service.dart';
import '../../utils/database_helper.dart';
import '../../models/order.dart';
import '../../models/business.dart';
import 'Review/review_screen.dart';

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
  int currentPage = 1;
  final int pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadOrderHistory(isRefresh: true);
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
        _loadOrderHistory(isRefresh: false);
      }
    }
  }

  Future<void> _loadOrderHistory({bool isRefresh = false}) async {
    if (isLoadingMore || (!hasMore && !isRefresh)) return;

    setState(() {
      if (isRefresh) {
        isLoading = true;
        errorMessage = null;
        currentPage = 1;
      } else {
        isLoadingMore = true;
      }
    });

    try {
      final token = await DatabaseHelper.instance.getToken();
      if (token == null)
        throw Exception('Token de autenticação não encontrado');

      final response = await OrderService.getOrderHistory(token,
          page: currentPage, limit: pageSize);

      if (response != null) {
        final newOrders = response.orders;

        for (final order in newOrders) {
          if (!businessCache.containsKey(order.idBusiness)) {
            final business =
                await BusinessService.getBusiness(order.idBusiness, token);
            if (business != null) {
              businessCache[order.idBusiness] = business;
            }
          }
        }

        setState(() {
          if (isRefresh) {
            orderHistory.clear();
            activeOrder = null;
          }

          for (final order in newOrders) {
            if (_isActiveOrderStatus(order.status)) {
              if (activeOrder == null) {
                activeOrder = order;
              }
            } else {
              orderHistory.add(order);
            }
          }

          hasMore = response.hasMore;
          if (hasMore) {
            currentPage++;
          }
        });
      } else {
        throw Exception('Erro ao carregar histórico');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  bool _isActiveOrderStatus(String status) {
    final activeStatuses = ['pending', 'confirmed', 'preparing', 'ready'];
    return activeStatuses
        .contains(OrderStatusExtension.fromString(status).value);
  }

  bool _isDeliveredOrder(String status) {
    return OrderStatusExtension.fromString(status) == OrderStatus.delivered;
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
      body: isLoading && orderHistory.isEmpty && activeOrder == null
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
                        onPressed: () => _loadOrderHistory(isRefresh: true),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadOrderHistory(isRefresh: true),
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
                                    ' | ${businessCache[activeOrder!.idBusiness]?.appName ?? 'Estabelecimento'}'),
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
                                                'order': activeOrder!
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                          ),
                                          child: const Text('Pagar Agora',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _cancelOrder(activeOrder!),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[600],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                          ),
                                          child: const Text('Cancelar',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
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
                                child: _buildHistoryItem(context, order: order),
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
    final business = businessCache[order.idBusiness];
    final businessName = business?.appName ?? 'Estabelecimento';

    return Card(
      color: Colors.grey[100],
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    businessName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDate(order.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getOrderDescription(order),
              style: const TextStyle(color: Colors.black54),
            ),
            const Divider(height: 24),
            _buildBottomSection(context, order, businessName),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(
      BuildContext context, Order order, String businessName) {
    // Condição 1: Pedido entregue e NÃO AVALIADO
    if (order.status == 'entregue' && order.reviewed == false) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.star_border, size: 20),
          label: const Text('Fazer Avaliação'),
          onPressed: () async {
            final userData = await DatabaseHelper.instance.getUser();
            if (userData != null && order.id != null) {
              // Navega para a tela de avaliação e aguarda um resultado.
              final reviewSubmitted = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewScreen(
                    estabelecimento: businessName,
                    estabelecimentoId: order.idBusiness.toString(),
                    idOrder: order.id!,
                    idClient: userData['id'],
                  ),
                ),
              );

              if (reviewSubmitted == true) {
                _loadOrderHistory(isRefresh: true);
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    }

    if (order.status == 'entregue' && order.reviewed == true) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Text('Pedido avaliado!', style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    if (order.status == 'pendente') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bag/pendingOrderDetails',
                    arguments: {'order': order});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Pagar Agora'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _cancelOrder(order),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[400]!),
              ),
              child: const Text('Cancelar'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Text('Status: ', style: TextStyle(color: Colors.grey)),
        Text(
          _getStatusDisplayName(order.status),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: order.status == 'cancelled' ? Colors.red : Colors.blueGrey,
          ),
        ),
      ],
    );
  }
}
