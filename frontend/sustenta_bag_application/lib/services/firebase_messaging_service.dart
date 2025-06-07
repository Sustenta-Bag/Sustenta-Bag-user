import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/database_helper.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }
}

class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static String get baseUrl => dotenv.env['API_MONOLITO_BASE_URL'] ?? 'http://10.0.2.2:4041/api';
  static String? _token;
  
  static String? get token => _token;
  static Future<void> initialize() async {
    try {
      await LocalNotificationService.initialize();
      
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      bool hasPermission = settings.authorizationStatus == AuthorizationStatus.authorized ||
                          settings.authorizationStatus == AuthorizationStatus.provisional;
      
      if (!hasPermission) {
        if (kDebugMode) {
          print('Permissões de notificação negadas: ${settings.authorizationStatus}');
        }
      } else {
        if (kDebugMode) {
          print('Permissões de notificação concedidas: ${settings.authorizationStatus}');
        }
      }
      _token = await _firebaseMessaging.getToken();
      if (kDebugMode && _token != null) {
        print('FCM Token: $_token');
      }

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      
      FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);
      
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );      
      _firebaseMessaging.onTokenRefresh.listen(_handleTokenRefresh);
      
      if (kDebugMode) {
        print('Firebase Messaging inicializado com sucesso');
        print('FCM Token: $_token');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao inicializar Firebase Messaging: $e');
      }
    }
  }

  static void _handleTokenRefresh(String newToken) {
    if (kDebugMode) {
      print('FCM Token atualizado: $newToken');
    }
    _token = newToken;
    sendFCMTokenToServer();
  }
  static void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Mensagem recebida com o app em primeiro plano:');
      print('Título: ${message.notification?.title}');
      print('Corpo: ${message.notification?.body}');
      print('Dados: ${message.data}');
    }
    
    if (message.notification != null) {
      LocalNotificationService.showNotification(
        title: message.notification?.title ?? 'SustentaBag',
        body: message.notification?.body ?? 'Nova notificação recebida',
        payload: jsonEncode(message.data),
      );
    } else if (message.data.isNotEmpty) {
      final title = message.data['title'] ?? 'SustentaBag';
      final body = message.data['body'] ?? 'Nova notificação recebida';
      
      LocalNotificationService.showNotification(
        title: title,
        body: body,
        payload: jsonEncode(message.data),
      );
    }
  }
  
  static void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('Usuário tocou na notificação com o app em segundo plano:');
      print('Título: ${message.notification?.title}');
      print('Corpo: ${message.notification?.body}');
      print('Dados: ${message.data}');
    }
  }
  
  static void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      if (kDebugMode) {
        print('App aberto a partir do estado terminado pela notificação:');
        print('Título: ${message.notification?.title}');
        print('Corpo: ${message.notification?.body}');
        print('Dados: ${message.data}');
      }
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    if (kDebugMode) {
      print('Inscrito no tópico: $topic');
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('Inscrição cancelada do tópico: $topic');
    }
  }
  
  static Future<bool> sendFCMTokenToServer() async {
    try {
      String? authToken = await DatabaseHelper.instance.getToken();
      
      if (authToken == null) {
        if (kDebugMode) {
          print('Nenhum token de autenticação encontrado, o usuário deve fazer login primeiro');
        }
        return false;
      }
      
      // Usar o token FCM já armazenado
      if (_token == null) {
        try {
          _token = await _firebaseMessaging.getToken();
        } catch (e) {
          if (kDebugMode) {
            print('Erro ao obter token FCM: $e');
          }
          _token = 'dummy-fcm-token-${DateTime.now().millisecondsSinceEpoch}';
        }
      }
      
      if (_token == null) {
        if (kDebugMode) {
          print('Falha ao obter token FCM');
        }
        return false;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/device-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'deviceToken': _token,
        }),
      );      
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        if (kDebugMode) {
          print('Token FCM enviado com sucesso para o servidor');
        }
        
        final user = await DatabaseHelper.instance.getUser();
        if (user != null) {
          user['fcmToken'] = _token;
          await DatabaseHelper.instance.saveUser(user);
        }
        
        return true;
      } else {
        if (kDebugMode) {
          print('Falha ao enviar token FCM para o servidor: ${response.statusCode} - ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao enviar token FCM: $e');
      }
      return false;
    }
  }

  static Future<bool> checkNotificationPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao verificar permissão de notificação: $e');
      }
      return false;
    }
  }

  static Future<bool> requestNotificationPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao solicitar permissão de notificação: $e');
      }
      return false;
    }
  }
  
  static Future<void> testLocalNotification() async {
    try {
      await LocalNotificationService.showNotification(
        title: 'Teste de Notificação',
        body: 'Esta é uma notificação de teste. Se você está vendo isso, o sistema está funcionando!',
        payload: jsonEncode({'test': true, 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      );
      
      if (kDebugMode) {
        print('Notificação de teste enviada com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao enviar notificação de teste: $e');
      }
    }
  }
}
