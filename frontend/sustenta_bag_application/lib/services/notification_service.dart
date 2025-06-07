import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Configuração para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuração para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Inicialização
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Adicione lógica adicional aqui se necessário
        print('Notification clicked with payload: ${details.payload}');
      },
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Detalhes da notificação para Android
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sustentabag_notifications_channel', // mesmo ID definido na classe Application.kt
      'SustentaBag Notifications',
      channelDescription: 'Notificações do aplicativo SustentaBag',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
    );

    // Detalhes para iOS
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Especificações da notificação
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Mostrar a notificação
    await _flutterLocalNotificationsPlugin.show(
      0, // ID da notificação
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
