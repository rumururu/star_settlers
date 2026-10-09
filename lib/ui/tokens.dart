import 'package:flutter/material.dart';

/// 디자인 토큰. 화면 코드에 글자 크기·간격·터치 크기 숫자를 직접 쓰지 않고 여기서 가져온다.
/// 기준: 모바일 가독 하한 16dp, 터치 타겟 하한 48dp (Material 3) — ~/.claude/GAME_UI_ARCHITECTURE.md

/// 타이포 스케일 (6단계)
abstract final class Ts {
  /// 타이틀 로고급
  static const display = TextStyle(fontSize: 36, color: Colors.white, height: 1.1);

  /// 화면/패널 제목, 큰 보상 숫자
  static const title = TextStyle(fontSize: 24, color: Colors.white);

  /// 섹션 제목, 목록 항목 이름
  static const heading = TextStyle(fontSize: 19, color: Colors.white);

  /// 읽는 글 (설명·대화)
  static const body = TextStyle(fontSize: 16, color: Colors.white);

  /// 버튼 글자
  static const label = TextStyle(fontSize: 16, color: Colors.white);

  /// HUD 숫자·타이머·배지 전용. 문장에는 쓰지 않는다.
  static const caption = TextStyle(fontSize: 13, color: Colors.white70);

  // 자주 쓰는 변형
  static const headingBold = TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.bold);
  static const section = TextStyle(fontSize: 19, color: Color(0xFF8AD8FF), fontWeight: FontWeight.bold);
  static const bodyDim = TextStyle(fontSize: 16, color: Colors.white60);

  /// 아이콘 대신 쓰는 이모지 글리프
  static const glyph = TextStyle(fontSize: 28);
}

/// 간격
abstract final class Space {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;
}

/// 터치 크기
abstract final class Tap {
  /// 모든 버튼의 최소 높이·폭
  static const min = 48.0;

  /// 주요 버튼(타이틀 화면 등) 높이와 폭
  static const primaryHeight = 56.0;
  static const primaryWidth = 260.0;
}

/// 아이콘 크기
abstract final class IconSz {
  static const inline = 20.0;
  static const button = 26.0;
  static const row = 48.0;
  static const hero = 64.0;
}
