/// 게임 개선 통계 이벤트 (이탈 지점 측정).
///
/// 게임 로직은 서비스(네트워크·저장)에 의존하지 않는다. 이벤트가 생기는 곳에서 [GameTelemetry.emit] 한 줄만 부르고,
/// 앱(`AppState.init` → services/telemetry.dart)이 [GameTelemetry.sink]를 연결한다. 연결 전·테스트에서는 아무 일도 없다.
///
/// 이벤트 이름 목록은 여기(Dart)와 서버 `starset_event_names()` 두 곳에만 있다. 추가할 때 둘 다 고친다.
/// 서버 쪽은 새 마이그레이션에서 `create or replace function starset_event_names()`로 목록 전체를 다시 쓴다
/// (가장 최근 마이그레이션의 정의가 정본. test/telemetry_test.dart가 둘을 비교한다).
enum TelemetryEvent {
  sessionStart('session_start'),

  /// value = 세션 길이(초)
  sessionEnd('session_end'),

  /// value = 마친 스토리(튜토리얼) 단계 수 (1부터)
  tutorialStep('tutorial_step'),
  tutorialDone('tutorial_done'),
  firstKill('first_kill', once: true),
  firstColony('first_colony', once: true),
  firstBuilding('first_building', once: true),
  firstCrew('first_crew', once: true),
  firstWarp('first_warp', once: true),
  firstBoss('first_boss', once: true),
  firstDeath('first_death', once: true),

  /// value = 처음 도착한 항성계 번호 (1부터)
  systemReached('system_reached'),

  /// value = 연속 출석 일수
  loginClaim('login_claim'),
  dailyQuestClaim('daily_quest_claim'),
  adWatch('ad_watch'),
  shopOpen('shop_open'),
  iapStart('iap_start'),

  /// value = 첫 실행 뒤 지난 날수 (하루 한 번, 서비스가 보낸다)
  dayReturn('day_return'),

  // ---- 1.0.8 retention-update (TASK 003~006). 서버 목록: 20261108010000_starset_events_v2.sql ----

  /// '다음 목표' 하나 달성. value = 목표 번호(NextGoal 순서)
  goalDone('goal_done'),

  /// 첫 항성계 미니 두목(해적 부두목) 처치
  miniBossKill('mini_boss_kill', once: true),

  /// 7일 출석 달력을 연 날. value = 오늘이 달력 며칠째(1~7)
  calendarOpen('calendar_open'),

  /// 승무원 원정 보냄. value = 원정 시간(시간 단위)
  expeditionStart('expedition_start'),
  expeditionClaim('expedition_claim'),
  riftStart('rift_start'),

  /// 균열 런 끝. value = 도달한 파도 번호
  riftEnd('rift_end'),
  codexOpen('codex_open');

  const TelemetryEvent(this.wire, {this.once = false});

  /// 서버에 보내는 이름 (서버 허용 목록과 같다)
  final String wire;

  /// 설치당 한 번만 보낸다 (first_*). 중복 거르기는 서비스가 한다 — 게임은 매번 불러도 된다.
  final bool once;
}

abstract final class GameTelemetry {
  /// 앱이 연결하는 받는 곳. null이면 버린다.
  static void Function(TelemetryEvent event, int? value)? sink;

  /// 이벤트 하나. 예외를 밖으로 던지지 않는다 (통계 때문에 게임이 멈추면 안 된다).
  static void emit(TelemetryEvent event, [int? value]) {
    final s = sink;
    if (s == null) return;
    try {
      s(event, value);
    } catch (_) {}
  }
}
