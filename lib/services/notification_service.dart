import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Solo inicializar en plataformas nativas (no web)
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Manejar cuando el usuario toca la notificación
        if (kDebugMode) {
          print('Notificación tocada: ${details.payload}');
        }
      },
    );

    _initialized = true;
  }

  static Future<void> showMessageNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // En web, usar notificaciones del navegador
    if (kIsWeb) {
      _showWebNotification(title, body);
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'chat_messages',
      'Mensajes del Chat',
      channelDescription: 'Notificaciones de nuevos mensajes en el chat',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static void _showWebNotification(String title, String body) {
    // Para web, podrías usar la API de notificaciones del navegador
    // o simplemente mostrar un SnackBar en la UI
    if (kDebugMode) {
      print('📬 Nueva notificación: $title - $body');
    }
  }

  static Future<void> cancelAll() async {
    if (!kIsWeb) {
      await _notifications.cancelAll();
    }
  }

  static Future<void> cancel(int id) async {
    if (!kIsWeb) {
      await _notifications.cancel(id);
    }
  }
}
