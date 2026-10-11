import 'package:flutter/services.dart';

import '../game/profile.dart';

/// 화면 방향 설정 → 허용할 기기 방향.
/// 자동은 빈 목록: 시스템 기본(안드로이드는 기기 회전 잠금 설정을 따르고,
/// iOS는 Info.plist에 적힌 방향 전부)으로 돌아간다.
List<DeviceOrientation> deviceOrientationsFor(ScreenOrient o) => switch (o) {
      ScreenOrient.auto => const [],
      ScreenOrient.portrait => const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
      ScreenOrient.landscape => const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    };

/// 앱 시작 시와 설정을 바꿀 때 부른다
Future<void> applyOrientation(ScreenOrient o) => SystemChrome.setPreferredOrientations(deviceOrientationsFor(o));
