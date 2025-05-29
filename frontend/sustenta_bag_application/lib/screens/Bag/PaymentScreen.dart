import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../../services/payment_service.dart';
import '../../services/order_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  Timer? _statusCheckTimer;
  Timer? _redirectTimer;
  String? _paymentId;
  double? _amount;

  String _paymentStatus = 'pending';
  bool _isLoading = true;
  String? _errorMessage;
  int _statusCheckCount = 0;
  static const int maxStatusChecks = 60;

  late AnimationController _successAnimationController;
  late AnimationController _errorAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  int _redirectCountdown = 3;

  @override
  void initState() {
    super.initState();

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _errorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.easeIn,
    ));

    _controller = VideoPlayerController.asset('assets/payment.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePayment();
    });
  }

  void _initializePayment() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      setState(() {
        _paymentId = args['paymentId'];
        _amount = args['amount'];
        _isLoading = false;
      });

      _startStatusMonitoring();
    } else {
      setState(() {
        _errorMessage = 'Dados do pagamento não encontrados';
        _isLoading = false;
      });
    }
  }

  void _startStatusMonitoring() {
    if (_paymentId == null) return;

    _statusCheckTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_statusCheckCount >= maxStatusChecks) {
        timer.cancel();
        setState(() {
          _errorMessage = 'Tempo limite para confirmação do pagamento';
          _paymentStatus = 'timeout';
        });
        return;
      }

      final paymentData = await PaymentService.getPaymentStatus(_paymentId!);
      if (paymentData != null) {
        setState(() {
          _paymentStatus = paymentData['status'] ?? 'pending';
        });

        if (_paymentStatus == 'approved' || _paymentStatus == 'rejected') {
          timer.cancel();
          _handlePaymentResult();
        }
      }

      _statusCheckCount++;
    });
  }

  void _handlePaymentResult() {
    if (_paymentStatus == 'approved') {
      _successAnimationController.forward();
      _startRedirectCountdown();
    } else if (_paymentStatus == 'rejected') {
      _errorAnimationController.forward();
      _cancelAssociatedOrder();
      _startRedirectCountdown();
    }
  }

  void _startRedirectCountdown() {
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _redirectCountdown--;
      });

      if (_redirectCountdown <= 0) {
        timer.cancel();
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    });
  }

  Future<void> _cancelAssociatedOrder() async {
    try {
      if (_paymentId != null) {
        final paymentData = await PaymentService.getPaymentStatus(_paymentId!);
        if (paymentData != null && paymentData['orderId'] != null) {
          final orderId = paymentData['orderId'];
          await OrderService.cancelOrder(orderId, 'Payment rejected');
          print('Order $orderId canceled due to payment rejection');
        }
      }
    } catch (e) {
      print('Error canceling associated order: $e');
    }
  }

  Future<void> _simulateApproval() async {
    if (_paymentId != null) {
      final success = await PaymentService.simulatePaymentApproval(_paymentId!);
      if (success) {
        setState(() {
          _paymentStatus = 'approved';
        });
        _handlePaymentResult();
      }
    }
  }

  Future<void> _simulateRejection() async {
    if (_paymentId != null) {
      final success =
          await PaymentService.simulatePaymentRejection(_paymentId!);
      if (success) {
        setState(() {
          _paymentStatus = 'rejected';
        });
        _handlePaymentResult();
      }
    }
  }

  Future<void> _cancelPayment() async {
    if (_paymentId != null) {
      final success = await PaymentService.cancelPayment(_paymentId!);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _statusCheckTimer?.cancel();
    _redirectTimer?.cancel();
    _successAnimationController.dispose();
    _errorAnimationController.dispose();
    super.dispose();
  }

  Widget buildProgressBar() {
    List<Color> colors = [
      Colors.grey.shade400,
      Colors.grey.shade400,
      Colors.grey.shade400
    ];

    switch (_paymentStatus) {
      case 'pending':
        colors = [Colors.black, Colors.black, Colors.grey.shade400];
        break;
      case 'approved':
        colors = [Colors.green, Colors.green, Colors.green];
        break;
      case 'rejected':
      case 'cancelled':
        colors = [Colors.red, Colors.red, Colors.red];
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBar(40, colors[0]),
        const SizedBox(width: 8),
        _buildBar(40, colors[1]),
        const SizedBox(width: 8),
        _buildBar(40, colors[2]),
      ],
    );
  }

  Widget _buildBar(double width, Color color) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  String _getStatusMessage() {
    switch (_paymentStatus) {
      case 'pending':
        return 'Aguardando confirmação do pagamento...\n\nEm desenvolvimento: Use os botões abaixo para simular o resultado do pagamento.';
      case 'approved':
        return 'Pagamento aprovado! Redirecionando em $_redirectCountdown segundos...';
      case 'rejected':
        return 'Pagamento rejeitado. Redirecionando em $_redirectCountdown segundos...';
      case 'cancelled':
        return 'Pagamento cancelado';
      case 'timeout':
        return 'Tempo limite excedido';
      default:
        return 'Processando pagamento...';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Erro no Pagamento'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(_paymentStatus == 'approved'
            ? 'Pagamento Aprovado'
            : 'Aguardando Pagamento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_paymentStatus == 'pending')
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'approve':
                    _simulateApproval();
                    break;
                  case 'reject':
                    _simulateRejection();
                    break;
                  case 'cancel':
                    _cancelPayment();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'approve',
                  child: Text('Simular Aprovação'),
                ),
                const PopupMenuItem(
                  value: 'reject',
                  child: Text('Simular Rejeição'),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Text('Cancelar Pagamento'),
                ),
              ],
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 253, 253, 253),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              if (_paymentStatus == 'approved')
                AnimatedBuilder(
                  animation: _successAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: const Icon(
                          Icons.check_circle,
                          size: 200,
                          color: Colors.green,
                        ),
                      ),
                    );
                  },
                )
              else if (_paymentStatus == 'rejected')
                AnimatedBuilder(
                  animation: _errorAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: const Icon(
                          Icons.cancel,
                          size: 200,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                )
              else if (_controller.value.isInitialized)
                SizedBox(
                  height: 250,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
              else
                const CircularProgressIndicator(),
              const SizedBox(height: 40),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _getStatusMessage(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (_paymentStatus == 'approved' ||
                      _paymentStatus == 'rejected') ...[
                    const SizedBox(height: 20),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _paymentStatus == 'approved'
                            ? Colors.green
                            : Colors.red,
                      ),
                      child: Center(
                        child: Text(
                          '$_redirectCountdown',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_amount != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Valor: R\$ ${_amount!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  buildProgressBar(),
                  const SizedBox(height: 20),
                  if (_paymentStatus == 'pending') ...[
                    const Text(
                      'Verificando status a cada 5 segundos...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tentativa ${_statusCheckCount + 1} de $maxStatusChecks',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Para testar, use os botões de simulação:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _simulateApproval,
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Aprovar',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _simulateRejection,
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: const Text('Rejeitar',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
