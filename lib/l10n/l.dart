import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../game/josa.dart' as ko;
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// 현재 언어. 위젯 밖(게임 로직·대사·알림)에서도 번역 문자열을 쓰기 위한 전역 접근점.
/// 앱 시작과 언어 설정 변경 때 [Lang.set]으로 맞춘다.
abstract final class Lang {
  static Locale _locale = const Locale('ko');
  static L10n _t = lookupL10n(_locale);

  /// 언어가 바뀌면 앱 전체를 다시 그린다 (MaterialApp이 듣는다)
  static final changed = ValueNotifier<Locale>(_locale);

  static Locale get locale => _locale;
  static bool get isKo => _locale.languageCode == 'ko';

  /// 지원하지 않는 언어면 영어
  static void set(Locale l) {
    final supported = L10n.supportedLocales.any((s) => s.languageCode == l.languageCode);
    _locale = supported ? Locale(l.languageCode) : const Locale('en');
    _t = lookupL10n(_locale);
    changed.value = _locale;
  }

  /// 프로필 설정(null이면 기기 언어)으로 맞춘다
  static void apply(String? code) =>
      set(code != null ? Locale(code) : PlatformDispatcher.instance.locale);

  static L10n get t => _t;
}

/// 번역 문자열 (어디서나): `tr.someKey`
L10n get tr => Lang.t;

// 한국어 조사는 한국어일 때만 붙인다. 다른 언어에서는 단어 그대로 (ARB 문장에 조사를 넣지 않는다).
String eul(String w) => Lang.isKo ? ko.eul(w) : w;
String iGa(String w) => Lang.isKo ? ko.iGa(w) : w;
String euro(String w) => Lang.isKo ? ko.euro(w) : w;
String josa(String w, String withBatchim, String without) =>
    Lang.isKo ? ko.josa(w, withBatchim, without) : w;
