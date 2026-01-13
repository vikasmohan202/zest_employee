import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zest_employee/main.dart';
import 'package:zest_employee/presentation/screens/task_details_screen.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  Future<void> init() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _initFirebaseListeners();
  }

  _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(settings);
  }

  void _onNotificationTabForeground(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }
    final Map<String, dynamic> data = jsonDecode(payload);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        debugPrint('Navigator still null, retrying...');
        return;
      }

      // navigator.push(
      //   MaterialPageRoute(
      //     builder: (_) => TaskDetailsScreen(orderId: orderId),
      //   ),
      // );
    });
  }

  Future<void> _initFirebaseListeners() async {
    FirebaseMessaging.onMessage.listen(_showNotification);

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => debugPrint('Opened from bg: ${message.data}'),
    );

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Opened from terminated');
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      details,
      payload: jsonEncode({
        "type": "order",
        "orderId": message.data['orderId'],
        "notificationId": message.data['notificationId'],
      }),
    );
  }

  Future<String?> getFcmToken() => _firebaseMessaging.getToken();
}

@pragma('vm:entry-point')
Future<void> notificationTapBackgroundHandler(
  NotificationResponse response,
) async {
  final payload = response.payload;

  if (payload == null || payload.isEmpty) return;

  try {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final orderId = data['orderId'] as String?;

    if (orderId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        debugPrint('Navigator still null, retrying...');
        return;
      }

      // navigator.push(
      //   MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderId: orderId)),
      // );
    });
    print('BG notification tapped, stored orderId: $orderId');
  } catch (e) {
    print('BG notification payload error: $e');
  }
}
