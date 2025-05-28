import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../../services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late VideoPlayerController _controller;
  Timer? _statusCheckTimer;  String? _paymentId;
  double? _amount;
  
  String _paymentStatus = 'pending';
  bool _isLoading = true;
  String? _errorMessage;
  int _statusCheckCount = 0;
  static const int maxStatusChecks = 60;

  @override
  void initState() {
    super.initState();
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
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;    if (args != null) {
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
    
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
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
      // Order status is automatically updated by the payment webhook
      // No need to manually update the order status here
      _showSuccessDialog();
    } else if (_paymentStatus == 'rejected') {
      _showErrorDialog('Pagamento rejeitado. Tente novamente com outro método de pagamento.');
    }
  }

  // Removed _updateOrderStatus method as order status is now handled 
  // automatically by the payment service webhook

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('Pagamento Aprovado!'),
          ],
        ),
        content: Text(
          'Seu pagamento de R\$ ${_amount?.toStringAsFixed(2)} foi aprovado com sucesso.\n\nSeu pedido será preparado em breve.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Erro no Pagamento'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
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
      final success = await PaymentService.simulatePaymentRejection(_paymentId!);
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
    super.dispose();
  }

  Widget buildProgressBar() {
    List<Color> colors = [Colors.grey.shade400, Colors.grey.shade400, Colors.grey.shade400];
    
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
        return 'Pagamento aprovado! Redirecionando...';
      case 'rejected':
        return 'Pagamento rejeitado';
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
        title: Text(_paymentStatus == 'approved' ? 'Pagamento Aprovado' : 'Aguardando Pagamento'),
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
              if (_controller.value.isInitialized && _paymentStatus != 'approved')
                SizedBox(
                  height: 250,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
              else if (_paymentStatus == 'approved')
                const Icon(
                  Icons.check_circle,
                  size: 200,
                  color: Colors.green,
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
                  const SizedBox(height: 20),                  if (_paymentStatus == 'pending') ...[
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
                          label: const Text('Aprovar', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _simulateRejection,
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: const Text('Rejeitar', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
