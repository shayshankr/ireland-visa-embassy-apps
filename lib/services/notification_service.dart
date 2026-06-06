import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    await _createChannel();
    _initialized = true;
  }

  static Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      'visa_decisions',
      'Visa Decisions',
      description: 'Notifies when your Ireland visa decision is published',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  static Future<void> showDecisionNotification({
    required String number,
    required String decision,
    required bool isApproved,
  }) async {
    await _plugin.show(
      0,
      isApproved ? 'Visa Approved!' : 'Visa Decision Ready',
      'Application $number: $decision',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'visa_decisions',
          'Visa Decisions',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
