/// 주간 "개척 점수" (순위표용). 게임 사건으로만 쌓이고, ISO 주(UTC)가 바뀌면 0부터 다시 센다.
/// 서버(supabase/migrations/20261011000000_starset_leaderboard.sql)는 이번 주·지난주만 받고, 점수 상한도 같다.
library;

/// 사건별 점수. 서버 상한([WeeklyScore.maxPoints]) 계산의 근거라 바꾸면 마이그레이션 주석·상한도 같이 본다.
abstract final class ScorePoints {
  /// 식민지 레벨 1 올릴 때마다 (정착 포함)
  static const colonyLevel = 100;

  /// 처음 가 보는 항성계에 도착할 때마다
  static const newSystem = 500;

  /// 내 함선(총알·미사일·드론)이 해적을 격추할 때마다 (본거지 레이저 제외)
  static const pirateKill = 5;

  /// 두목(섹터 두목·일반 두목)을 격파할 때마다
  static const bossDefeated = 200;
}

/// ISO 8601 주를 yyyyww 정수로 (예: 2026-10-10 → 202641). 항상 UTC 기준.
int isoWeekKey(DateTime t) {
  final u = t.toUtc();
  final day = DateTime.utc(u.year, u.month, u.day);
  // 그 주의 목요일이 속한 해가 ISO 연도다
  final thursday = day.add(Duration(days: DateTime.thursday - day.weekday));
  final jan1 = DateTime.utc(thursday.year, 1, 1);
  final week = thursday.difference(jan1).inDays ~/ 7 + 1;
  return thursday.year * 100 + week;
}

/// [t]의 바로 전 ISO 주 (yyyyww)
int previousIsoWeekKey(DateTime t) => isoWeekKey(t.toUtc().subtract(const Duration(days: 7)));

/// 이번 주 개척 점수. 주가 바뀌면 지난주 최종 점수를 [lastWeek]/[lastPoints]에 남기고 0부터 센다
/// (서버가 지난주 점수도 받으므로, 월요일 0시(UTC) 직전에 번 점수를 다음 실행 때 보낼 수 있다).
class WeeklyScore {
  WeeklyScore({required this.week, this.points = 0, this.lastWeek, this.lastPoints = 0});

  /// 서버 상한과 같다 (마이그레이션 주석에 계산 근거)
  static const maxPoints = 5000000;

  factory WeeklyScore.now([DateTime? now]) => WeeklyScore(week: isoWeekKey(now ?? DateTime.now()));

  int week;
  int points;

  /// 직전에 끝난 주와 그 주의 최종 점수 (없으면 null / 0)
  int? lastWeek;
  int lastPoints;

  /// 주가 바뀌었으면 넘긴다. 넘겼으면 true.
  bool rollover([DateTime? now]) {
    final cur = isoWeekKey(now ?? DateTime.now());
    if (cur == week) return false;
    // 바로 전 주였을 때만 지난주 점수로 남긴다 (몇 주 쉬었다 오면 서버가 받지 않는다)
    final prev = previousIsoWeekKey(now ?? DateTime.now());
    if (week == prev && points > 0) {
      lastWeek = week;
      lastPoints = points;
    } else {
      lastWeek = null;
      lastPoints = 0;
    }
    week = cur;
    points = 0;
    return true;
  }

  /// 이번 주 점수 (주가 바뀌었으면 먼저 넘긴다)
  int pointsNow([DateTime? now]) {
    rollover(now);
    return points;
  }

  void _add(int p, DateTime? now) {
    rollover(now);
    points = (points + p).clamp(0, maxPoints);
  }

  void addColonyLevel([DateTime? now]) => _add(ScorePoints.colonyLevel, now);
  void addNewSystem([DateTime? now]) => _add(ScorePoints.newSystem, now);
  void addPirateKill([DateTime? now]) => _add(ScorePoints.pirateKill, now);
  void addBossDefeated([DateTime? now]) => _add(ScorePoints.bossDefeated, now);

  Map<String, dynamic> toJson() => {
        'week': week,
        'points': points,
        if (lastWeek != null) 'lastWeek': lastWeek,
        if (lastWeek != null) 'lastPoints': lastPoints,
      };

  /// 깨졌거나 없는 값은 이번 주 0점으로 시작한다
  factory WeeklyScore.fromJson(Map<String, dynamic>? j, [DateTime? now]) {
    final week = j?['week'];
    final points = j?['points'];
    if (week is! int || points is! int) return WeeklyScore.now(now);
    final lastWeek = j?['lastWeek'];
    final lastPoints = j?['lastPoints'];
    return WeeklyScore(
      week: week,
      points: points.clamp(0, maxPoints),
      lastWeek: lastWeek is int ? lastWeek : null,
      lastPoints: lastWeek is int && lastPoints is int ? lastPoints.clamp(0, maxPoints) : 0,
    );
  }
}
