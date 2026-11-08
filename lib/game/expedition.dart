import 'dart:math';

/// 승무원 원정 (TASK 004). 배치되지 않은 승무원을 1·4·8시간 보내면 실제 시간으로 진행하고,
/// 돌아오면 광석·크레딧·승무원 경험치(8시간은 낮은 확률로 젬·★3 승무원)를 받는다.
///
/// 보상은 보낼 때 정해서 저장한다 → 불러오기·앱 재시작으로 다시 굴릴 수 없다.
/// 시계: [ExpeditionClock]이 지금까지 본 가장 늦은 시각을 기억해, 시계를 되돌려도 진행이 줄거나
/// 같은 원정을 두 번 받을 수 없다 (출석 `dayKey` 검사와 같은 생각).
class Expedition {
  Expedition({
    required this.crewId,
    required this.hours,
    required this.startMs,
    required this.credits,
    required this.ore,
    required this.xp,
    this.gems = 0,
    this.rareCrew = false,
  });

  final int crewId;
  final int hours;
  final int startMs;
  final int credits;
  final int ore;
  final int xp;

  /// 8시간 원정의 행운 보상 (보낼 때 정해진다)
  final int gems;
  final bool rareCrew;

  int get endMs => startMs + hours * Duration.millisecondsPerHour;

  /// [nowMs] 기준 남은 시간 (0이면 귀환)
  Duration remaining(int nowMs) =>
      Duration(milliseconds: max(0, endMs - nowMs));

  bool isDone(int nowMs) => nowMs >= endMs;

  double progress(int nowMs) =>
      ((nowMs - startMs) / (endMs - startMs)).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'c': crewId,
    'h': hours,
    's': startMs,
    'cr': credits,
    'o': ore,
    'x': xp,
    'g': gems,
    'r': rareCrew,
  };

  static Expedition? fromJson(Object? j) {
    if (j is! Map) return null;
    final c = j['c'], h = j['h'], s = j['s'];
    if (c is! int || h is! int || s is! int) return null;
    if (!Expeditions.durations.contains(h)) return null;
    int n(Object? v) => v is num ? max(0, v.round()) : 0;
    return Expedition(
      crewId: c,
      hours: h,
      startMs: s,
      credits: n(j['cr']),
      ore: n(j['o']),
      xp: n(j['x']),
      gems: n(j['g']),
      rareCrew: j['r'] == true,
    );
  }
}

/// 귀환 보상 (받은 뒤 화면에 보여 준다)
class ExpeditionReward {
  const ExpeditionReward({
    required this.credits,
    required this.ore,
    required this.xp,
    this.gems = 0,
    this.levelUps = 0,
    this.rareCrew = false,
  });
  final int credits;
  final int ore;
  final int xp;
  final int gems;
  final int levelUps;
  final bool rareCrew;
}

abstract final class Expeditions {
  /// 고를 수 있는 원정 시간 (시간)
  static const durations = [1, 4, 8];

  /// 동시에 보낼 수 있는 원정 수 (사령관 패스 +1)
  static int slots({required bool premium}) => premium ? 3 : 2;

  /// 시간별로 '현재 생산의 몇 분어치'를 주는가 (오프라인 수입 2시간 상한보다 작게)
  static int incomeMinutes(int hours) => switch (hours) {
    1 => 6,
    4 => 20,
    _ => 36,
  };

  /// 승무원 경험치 (Lv.n → n+1 에 n×3 필요, [CrewMember.gainXp])
  static int xpFor(int hours) => switch (hours) {
    1 => 1,
    4 => 3,
    _ => 6,
  };

  /// 8시간 원정만: 젬 확률·양, ★3 승무원 확률
  static const gemChance = 0.3;
  static const gemAmount = 5;
  static const rareCrewChance = 0.1;

  /// 보낼 때 보상을 정한다. 생산이 아직 없어도(첫 항성계 초반) 최소 보상은 [sectorMul] 기준.
  /// 희귀도가 높은 승무원일수록 조금 더 가져온다 (★1 ×1.0 … ★4 ×1.3).
  static Expedition plan({
    required int crewId,
    required int rarity,
    required int hours,
    required int startMs,
    required double creditIncome,
    required double oreIncome,
    required double sectorMul,
    required Random rng,
  }) {
    final minutes = incomeMinutes(hours);
    final mul = 1 + 0.1 * (rarity - 1).clamp(0, 3);
    final credits =
        max(150 * sectorMul * hours, creditIncome * 60 * minutes) * mul;
    final ore = max(20 * sectorMul * hours, oreIncome * 60 * minutes) * mul;
    final lucky = hours >= 8;
    final gemRoll = rng.nextDouble();
    final crewRoll = rng.nextDouble();
    return Expedition(
      crewId: crewId,
      hours: hours,
      startMs: startMs,
      credits: credits.round(),
      ore: ore.round(),
      xp: xpFor(hours),
      gems: lucky && gemRoll < gemChance ? gemAmount : 0,
      rareCrew: lucky && crewRoll < rareCrewChance,
    );
  }
}

/// 되돌릴 수 없는 시계: 지금까지 본 가장 늦은 시각을 '지금'으로 쓴다.
class ExpeditionClock {
  int latestMs = 0;

  int now(DateTime wall) {
    final ms = wall.millisecondsSinceEpoch;
    if (ms > latestMs) latestMs = ms;
    return latestMs;
  }
}
