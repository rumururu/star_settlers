import 'package:flutter/services.dart';

/// 개발자에게 피드백 메일 보내기 (네이티브: MainActivity.kt / AppDelegate.swift).
/// 앱 버전·기기·OS 버전은 네이티브 쪽에서 본문 아래에 채운다.
abstract final class FeedbackService {
  static const email = 'mkideabox.feedback@gmail.com';
  static const _channel = MethodChannel('star_settlers/feedback');

  /// 메일 앱을 열었으면 true. 메일 앱이 없거나 지원하지 않는 플랫폼이면 false.
  static Future<bool> send() async {
    try {
      return await _channel.invokeMethod<bool>('send') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
