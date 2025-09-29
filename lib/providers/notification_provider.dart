import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationProvider() {
    init();
  }

  /// Initialize notifications and request permissions
  Future<void> init() async {
    // Initialize FlutterLocalNotificationsPlugin
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint(
          'Notification tapped, payload: ${response.payload ?? "None"}',
        );
      },
    );

    await _isAndroidPermissionGranted();
    await _requestPermissions();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.areNotificationsEnabled() ??
          false;
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  Future<void> showSimpleNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'your_channel_id',
          'General Notifications',
          channelDescription: 'This channel is used for general notifications.',
          importance: Importance.high,
          priority: Priority.high,
        );
    const NotificationDetails generalNotificationDetails = NotificationDetails(
      android: androidDetails,
    );
    await flutterLocalNotificationsPlugin
        .show(
          0,
          'Hello 👋',
          'This is your local notification!',
          generalNotificationDetails,
          payload: 'Custom_Data',
        )
        .then((a) {
          debugPrint('Notified');
        });
  }

  /// Schedule a notification after a delay
  Future<void> scheduleNotification({int seconds = 10}) async {
    final now = DateTime.now();
    final scheduledTime = now.add(Duration(seconds: seconds));

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'scheduled_channel_id',
          'Scheduled Notifications',
          channelDescription: 'This channel is for scheduled notifications.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    // Initialize timezone database
    tz.initializeTimeZones();
    // Set local timezone
    final timeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone.identifier));

    final scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);
    debugPrint('Scheduled TZDateTime: $scheduledTZ');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Scheduled ⏰',
      'This notification was scheduled $seconds seconds ago.',
      scheduledTZ,
      details,
      androidScheduleMode: AndroidScheduleMode.inexact,
      payload: 'Hello-World',
    );

    debugPrint('Scheduled notification set');
  }
}
