import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  static Future<void> initialize() async {
    // Inicializar fusos horários para notificações agendadas
    tz_data.initializeTimeZones();

    // Configurações para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurações para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Inicialização
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Lógica adicional quando o usuário clica na notificação
        if (kDebugMode) {
          print('Notificação clicada com payload: ${details.payload}');
        }
      },
    );

    // Solicitar permissões
    await requestPermissions();
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao solicitar permissões de notificação: $e');
      }
      return false;
    }
  }

  // Show a notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'sustentabag_notifications_channel', // ID do canal
        'SustentaBag Notifications', // Nome do canal
        channelDescription: 'Notificações do aplicativo SustentaBag',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        playSound: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      ); // Usar o timestamp em milissegundos como ID para garantir que não haja colisões
      final int notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      if (kDebugMode) {
        print('Tentando exibir notificação com ID: $notificationId');
        print('Título: "$title"');
        print('Corpo: "$body"');
      }

      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      if (kDebugMode) {
        print('Notificação local exibida com sucesso: ID=$notificationId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao exibir notificação: $e');
      }
    }
  }

  // Schedule a notification for a future time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'sustentabag_notifications_channel',
        'SustentaBag Notifications',
        channelDescription: 'Notificações do aplicativo SustentaBag',
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      if (kDebugMode) {
        print('Notificação agendada para: ${scheduledDate.toString()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao agendar notificação: $e');
      }
    }
  }

  // Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
