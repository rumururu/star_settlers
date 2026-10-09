import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/l.dart';

/// 복귀 알림 (로컬 알림). 앱이 백그라운드로 갈 때 예약하고, 돌아오면 취소한다.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _asked = false;

  static bool get supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> init() async {
    if (!supported || _ready) return;
    try {
      tzdata.initializeTimeZones();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
    } catch (e) {
      debugPrint('notification init failed: $e');
    }
  }

  /// 처음 게임을 시작할 때 한 번 권한 요청
  Future<void> requestPermission() async {
    if (!_ready || _asked) return;
    _asked = true;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('notification permission failed: $e');
    }
  }

  static NotificationDetails get _details => NotificationDetails(
        android: AndroidNotificationDetails('return', tr.g_notifChannelName,
            channelDescription: tr.g_notifChannelDesc),
        iOS: const DarwinNotificationDetails(),
      );

  /// 백그라운드로 갈 때: 오프라인 수입이 가득 차는 시점 + 다음 날 알림 예약
  Future<void> scheduleReturn({required Duration storageFullIn, required bool hasColonies}) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      final now = tz.TZDateTime.now(tz.UTC);
      if (hasColonies) {
        await _plugin.zonedSchedule(
          id: 1,
          title: '📦 ${tr.g_notifStorageTitle}',
          body: tr.g_notifStorageBody,
          scheduledDate: now.add(storageFullIn),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
      await _plugin.zonedSchedule(
        id: 2,
        title: '🏴‍☠️ ${tr.g_notifPiratesTitle}',
        body: tr.g_notifPiratesBody,
        scheduledDate: now.add(const Duration(hours: 22)),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('notification schedule failed: $e');
    }
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
