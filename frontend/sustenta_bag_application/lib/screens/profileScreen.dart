import 'package:flutter/material.dart';
import 'package:sustenta_bag_application/utils/firebase_messaging_service.dart';
import 'package:sustenta_bag_application/utils/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasNotificationsEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final user = await DatabaseHelper.instance.getUser();
    setState(() {
      _hasNotificationsEnabled = user != null && user['fcmToken'] != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/favorites'),
              icon: const Icon(Icons.favorite, color: Color(0xFFE8514C)),
              label: const Text('Favoritos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2F2F2),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : _buildNotificationButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    final buttonText = _hasNotificationsEnabled
        ? 'Notificações Ativadas'
        : 'Ativar Notificações';
    
    final buttonIcon = _hasNotificationsEnabled
        ? const Icon(Icons.notifications_active, color: Color(0xFF4CAF50))
        : const Icon(Icons.notifications_off, color: Colors.grey);
    
    return ElevatedButton.icon(
      onPressed: () => _vincularTokenFCM(context),
      icon: buttonIcon,
      label: Text(buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF2F2F2),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
    void _vincularTokenFCM(BuildContext context) async {
    // Mostrar diálogo de carregamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Registrando notificações..."),
            ],
          ),
        );
      },
    );
    
    // Verificar e solicitar permissões, se necessário
    bool hasPermission = await FirebaseMessagingService.checkNotificationPermission();
    if (!hasPermission) {
      hasPermission = await FirebaseMessagingService.requestNotificationPermission();
      if (!hasPermission) {
        // Fechar o diálogo de carregamento
        Navigator.pop(context);
        
        // Mostrar mensagem de erro de permissão
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de notificação negada. Por favor, habilite nas configurações do app.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
    }
    
    // Chamar o serviço para enviar o token FCM para o servidor
    bool success = await FirebaseMessagingService.sendFCMTokenToServer();
    
    // Fechar o diálogo de carregamento
    Navigator.pop(context);
    
    // Atualizar o estado da tela
    setState(() {
      _hasNotificationsEnabled = success;
    });
    
    // Mostrar mensagem de sucesso ou erro
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success 
              ? 'Notificações ativadas com sucesso!' 
              : 'Falha ao ativar notificações. Tente novamente.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
