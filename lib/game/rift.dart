/// 균열 런 (TASK 005): 3~5분짜리 짧은 로그라이트 판.
///
/// 이 파일은 화면·월드와 무관한 순수 규칙만 둔다 — 오늘의 시드, 파도 구성, 카드, 점수, 보상, 기록.
/// 전투는 기존 엔진을 그대로 쓴다 ([RiftWorld], world.dart의 part 파일 rift_world.dart).
///
/// 공정성: 같은 UTC 날짜면 모두가 같은 파도 구성과 같은 카드 순서를 본다. 함선 능력치는 런 전용 기본값이고
/// (메인 게임 강화·승무원·명예 무시) 외형(함선 실루엣·스킨)만 따라간다. 강화는 카드로만.
///
/// 서버 점수 상한: supabase/migrations/20261108020000_starset_rift.sql — [RiftScore.maxForWave]와 같은 식이다.
library;

import 'dart:math';

import 'models.dart' show PirateKind;
import 'system_traits.dart' show BossArchetype;
import 'weekly_score.dart' show isoWeekKey, previousIsoWeekKey;

/// UTC 날짜 yyyymmdd. 오늘의 균열은 이 값으로 정해진다.
int riftDayKey(DateTime t) {
  final u = t.toUtc();
  return u.year * 10000 + u.month * 100 + u.day;
}

/// 날짜 → 시드 (0..2^31-1). 앱 버전·기기와 무관하게 같다.
int riftSeedFor(int dayKey) {
  var x = (dayKey * 2654435761) & 0xffffffff;
  x ^= x >> 15;
  x = (x * 0x2c1b3c6d) & 0xffffffff;
  x ^= x >> 12;
  return x & 0x7fffffff;
}

// ---------------------------------------------------------------- 카드

enum RiftRarity {
  common(10),
  rare(5),
  epic(2);

  const RiftRarity(this.weight);

  /// 제시될 확률 가중치
  final int weight;
}

/// 파도를 넘길 때마다 3장 중 1장을 고른다. 같은 카드는 [maxStacks]까지 겹친다.
enum RiftCard {
  damage(RiftRarity.common, 5, 'up_weapon'),
  rapid(RiftRarity.common, 5, 'cmb_auto'),
  multishot(RiftRarity.rare, 3, 'up_weapon'),
  pierce(RiftRarity.rare, 3, 'up_weapon'),
  homing(RiftRarity.rare, 3, 'up_missile'),
  regen(RiftRarity.common, 3, 'up_shield'),
  drone(RiftRarity.rare, 3, 'up_drone'),
  magnet(RiftRarity.common, 3, 'up_magnet'),
  crit(RiftRarity.common, 4, 'up_weapon'),
  blades(RiftRarity.epic, 3, 'cmb_boost'),
  hull(RiftRarity.common, 4, 'up_hull'),
  engine(RiftRarity.common, 3, 'up_engine'),
  shockwave(RiftRarity.epic, 2, 'cmb_shield'),
  guard(RiftRarity.epic, 2, 'cmb_shield'),
  vampire(RiftRarity.rare, 3, 'up_hull');

  const RiftCard(this.rarity, this.maxStacks, this.icon);
  final RiftRarity rarity;
  final int maxStacks;

  /// assets/icons 이름
  final String icon;
}

/// 이번 런에서 고른 카드와 그 효과. 순수 계산이라 단위 테스트한다.
class RiftLoadout {
  final stacks = <RiftCard, int>{};

  int of(RiftCard c) => stacks[c] ?? 0;
  bool canTake(RiftCard c) => of(c) < c.maxStacks;

  /// 카드를 하나 더한다. 이미 최대면 false.
  bool take(RiftCard c) {
    if (!canTake(c)) return false;
    stacks[c] = of(c) + 1;
    return true;
  }

  int get picks => stacks.values.fold(0, (a, b) => a + b);

  // 기본 함선 (정찰선 Lv.0과 같다): 체력 100, 속도 260, 피해 10, 발사 간격 0.25초
  static const baseHp = 100.0;
  static const baseSpeed = 260.0;
  static const baseDamage = 10.0;
  static const baseFireInterval = 0.25;

  double get damageMul => 1 + 0.25 * of(RiftCard.damage);
  double get fireIntervalMul => pow(0.85, of(RiftCard.rapid)).toDouble();
  int get shots => 1 + of(RiftCard.multishot);
  int get pierce => of(RiftCard.pierce);

  /// 유도 미사일 자동 발사 간격(초, 0이면 없음)과 한 번에 쏘는 수, 한 발 피해
  double get homingInterval => of(RiftCard.homing) == 0 ? 0 : 4.0 - 0.8 * (of(RiftCard.homing) - 1);
  int get homingCount => 1 + of(RiftCard.homing);
  double get homingDamage => 22 * damageMul;

  /// 초당 체력 회복
  double get regenPerSec => 2.0 * of(RiftCard.regen);

  /// 기존 전투 드론 레벨 (1, 3, 5)
  int get droneLevel => of(RiftCard.drone) == 0 ? 0 : 1 + 2 * (of(RiftCard.drone) - 1);
  double get magnetBonus => 160.0 * of(RiftCard.magnet);
  double get crit => min(0.6, 0.12 * of(RiftCard.crit));

  /// 회전 칼날 수, 반경, 한 번 맞힐 때 피해 (적마다 [bladeHitInterval]초에 한 번)
  int get blades => of(RiftCard.blades);
  static const bladeRadius = 95.0;
  static const bladeHitInterval = 0.3;
  double get bladeDamage => 12 * damageMul;

  double get maxHp => baseHp + 35.0 * of(RiftCard.hull);
  double get speedMul => 1 + 0.12 * of(RiftCard.engine);

  /// 충격파 간격(초, 0이면 없음)·반경·피해
  double get shockInterval => of(RiftCard.shockwave) == 0 ? 0 : 7.0 - 2.0 * (of(RiftCard.shockwave) - 1);
  static const shockRadius = 280.0;
  double get shockDamage => (40 + 25.0 * (of(RiftCard.shockwave) - 1)) * damageMul;

  /// 보호막: 이 간격마다 피격 1회를 막는다 (기존 함선 수호막과 같은 장치)
  double get guardInterval => of(RiftCard.guard) == 0 ? 0 : 9.0 - 3.0 * (of(RiftCard.guard) - 1);

  /// 격추할 때마다 회복하는 체력
  double get healPerKill => 3.0 * of(RiftCard.vampire);
}

// ---------------------------------------------------------------- 파도

/// 파도 하나의 구성
class RiftWave {
  const RiftWave(this.index, this.kinds, this.hpMul, this.dmgMul, {this.boss = false});

  /// 1..[RiftPlan.waveCount]
  final int index;

  /// 나오는 순서대로 (두목 파도는 맨 앞이 두목)
  final List<PirateKind> kinds;
  final double hpMul;
  final double dmgMul;
  final bool boss;

  int get count => kinds.length;
}

/// 오늘의 균열: 날짜 하나로 파도·두목·카드 순서가 모두 정해진다.
class RiftPlan {
  RiftPlan(this.dayKey) : seed = riftSeedFor(dayKey);
  factory RiftPlan.today([DateTime? now]) => RiftPlan(riftDayKey(now ?? DateTime.now()));

  final int dayKey;
  final int seed;

  static const waveCount = 10;

  /// 마지막 파도 전 일반 파도의 적 수 (3 + 2n, 9파 21척) — 서버 상한 계산과 같다
  static int regularCount(int wave) => 3 + 2 * wave;

  /// 두목 파도의 호위 수
  static const bossEscorts = 8;

  /// 후반 적 후보. 앞 두 자리는 보통 크기, 마지막 자리에만 큰 적(모함·돌격함)이 올 수 있다.
  static const _midFoes = [
    PirateKind.missile,
    PirateKind.laser,
    PirateKind.warden,
    PirateKind.phantom,
    PirateKind.mine,
    PirateKind.medic,
  ];
  static const _bigFoes = [PirateKind.carrier, PirateKind.juggernaut];

  /// 오늘 섞이는 후반 적 3종 (5파·7파·8파부터)
  late final List<PirateKind> lateFoes = () {
    final r = Random(seed ^ 0x51ed);
    final mids = [..._midFoes]..shuffle(r);
    final third = r.nextBool() ? _bigFoes[r.nextInt(_bigFoes.length)] : mids[2];
    return [mids[0], mids[1], third];
  }();

  /// 두목 원형 (기존 항성계 두목 패턴 재사용)
  late final BossArchetype bossArchetype = BossArchetype.values[seed % BossArchetype.values.length];

  /// 배경으로 빌려 쓰는 항성계 (1..5)
  int get backdropSector => 1 + seed % 5;

  late final List<RiftWave> waves = [for (var n = 1; n <= waveCount; n++) _makeWave(n)];

  RiftWave wave(int n) => waves[(n - 1).clamp(0, waveCount - 1)];

  static double hpMulAt(int n) => 1 + 0.12 * (n - 1);
  static double dmgMulAt(int n) => 0.5 + 0.07 * (n - 1);

  RiftWave _makeWave(int n) {
    final r = Random(seed + n * 1013);
    final pool = <(PirateKind, int)>[
      (PirateKind.scout, 5),
      if (n >= 2) (PirateKind.raider, 4),
      if (n >= 3) (PirateKind.bomber, 2),
      if (n >= 4) (PirateKind.sniper, 2),
      if (n >= 5) (lateFoes[0], 2),
      if (n >= 7) (lateFoes[1], 2),
      if (n >= 8) (lateFoes[2], 1),
    ];
    final total = pool.fold<int>(0, (a, e) => a + e.$2);
    PirateKind pick() {
      var x = r.nextInt(total);
      for (final (k, wgt) in pool) {
        if (x < wgt) return k;
        x -= wgt;
      }
      return PirateKind.scout;
    }

    final boss = n == waveCount;
    final kinds = <PirateKind>[
      if (boss) PirateKind.boss,
      for (var i = 0; i < (boss ? bossEscorts : regularCount(n)); i++) pick(),
    ];
    // 큰 적은 한 파도에 둘까지만 (돌격함 셋은 기본 함선으로 감당이 안 된다)
    var big = 0;
    for (var i = 0; i < kinds.length; i++) {
      if (_bigFoes.contains(kinds[i]) && ++big > 2) kinds[i] = PirateKind.raider;
    }
    return RiftWave(n, kinds, hpMulAt(n), dmgMulAt(n), boss: boss);
  }

  /// [afterWave]를 넘긴 뒤 제시할 카드 3장.
  /// 모든 카드에 오늘의 시드로 가중 순위(A-ES)를 매겨 위에서부터 고르므로, 같은 날·같은 파도면 순서가 모두 같다.
  /// 이미 최대로 겹친 카드만 건너뛴다.
  List<RiftCard> offers(int afterWave, RiftLoadout loadout) {
    final r = Random(seed ^ (afterWave * 92821 + 7));
    final keyed = [
      for (final c in RiftCard.values) (c, pow(r.nextDouble(), 1 / c.rarity.weight).toDouble()),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    return [
      for (final (c, _) in keyed)
        if (loadout.canTake(c)) c,
    ].take(3).toList();
  }
}

// ---------------------------------------------------------------- 점수

/// 균열 점수. 서버 상한(마이그레이션 주석)과 같은 식이라 바꾸면 SQL도 같이 바꾼다.
abstract final class RiftScore {
  /// 적 종류별 기본 점수 (격추 점수 = 기본 × 파도 번호)
  static int base(PirateKind k) => switch (k) {
        PirateKind.scout => 10,
        PirateKind.raider || PirateKind.bomber => 15,
        PirateKind.sniper => 20,
        PirateKind.missile || PirateKind.laser || PirateKind.mine || PirateKind.phantom => 30,
        PirateKind.warden || PirateKind.medic => 35,
        PirateKind.carrier => 45,
        PirateKind.juggernaut => 60,
        PirateKind.boss => 600,
        PirateKind.jelly => 0,
      };

  /// 일반 적 기본 점수의 최댓값 (상한 계산용)
  static const maxRegularBase = 60;

  static int kill(PirateKind k, int wave) => base(k) * wave;

  /// 격추한 적이 떨어뜨리는 균열 조각의 합 (주우면 점수). 격추 점수의 절반.
  static int shards(int killPoints) => killPoints ~/ 2;

  /// 파도 돌파 보너스
  static int waveClear(int wave) => 150 * wave;

  /// 10파 정복 보너스와 빠른 정복 보너스 (전투 시간 480초 미만이면 초당 10점, 최대 4,800)
  static const clearBonus = 3000;
  static const timeBonusSeconds = 480;
  static int timeBonus(double seconds) => max(0, ((timeBonusSeconds - seconds) * 10).floor());

  /// 파도 [n]에서 격추·조각으로 얻을 수 있는 최대 점수
  static int maxKillsAt(int n) => n < RiftPlan.waveCount
      ? RiftPlan.regularCount(n) * maxRegularBase * n * 3 ~/ 2
      : (base(PirateKind.boss) * n + RiftPlan.bossEscorts * maxRegularBase * n) * 3 ~/ 2;

  /// 도달 파도 [reached](1..10)일 때 가능한 최대 점수.
  /// = 1..reached 파도 격추·조각 최대 + 1..reached-1 돌파 보너스 (+ 10파 도달이면 10파 돌파·정복·시간 보너스 최대)
  static int maxForWave(int reached) {
    final r = reached.clamp(1, RiftPlan.waveCount);
    var s = 0;
    for (var n = 1; n <= r; n++) {
      s += maxKillsAt(n);
      if (n < r) s += waveClear(n);
    }
    if (r == RiftPlan.waveCount) s += waveClear(r) + clearBonus + timeBonusSeconds * 10;
    return s;
  }

  /// 서버 점수 상한 (= maxForWave(10) = 95,700)
  static int get maxScore => maxForWave(RiftPlan.waveCount);
}

// ---------------------------------------------------------------- 보상

/// 런이 끝나고 메인 게임에 주는 보상
class RiftReward {
  const RiftReward({required this.credits, required this.ore, required this.gems, required this.full});
  final int credits;
  final int ore;
  final int gems;

  /// 하루 처음 [RiftRewards.fullRunsPerDay]판이면 true (아니면 1/4)
  final bool full;
}

abstract final class RiftRewards {
  /// 전액 보상 판 수 (UTC 하루)
  static const fullRunsPerDay = 3;

  /// 4판째부터의 보상 비율
  static const reducedRatio = 0.25;

  /// [cleared] = 돌파한 파도 수 (0..10). [rewardMul]·[sectorMul]은 메인 게임 현재 항성계 배율.
  /// [runsBefore] = 오늘 이 판 전에 끝낸 판 수.
  static RiftReward compute({
    required int cleared,
    required double rewardMul,
    required double sectorMul,
    required int runsBefore,
  }) {
    final full = runsBefore < fullRunsPerDay;
    final ratio = full ? 1.0 : reducedRatio;
    final c = cleared.clamp(0, RiftPlan.waveCount);
    return RiftReward(
      credits: ((40 + 45 * c) * rewardMul * ratio).round(),
      ore: ((6 + 5 * c) * sectorMul * ratio).round(),
      // 젬은 소량만, 서버 'play' 하루 상한 안에서 (Profile.earnGems('play', …))
      gems: !full ? 0 : (c >= RiftPlan.waveCount ? 3 : (c >= 5 ? 1 : 0)),
      full: full,
    );
  }
}

// ---------------------------------------------------------------- 기록 (Profile.stats에 저장)

/// 균열 기록. 프로필의 통계 맵(`stats`, 저장 키 'stats')에 'rift' 접두사 정수로 둔다 —
/// 저장 형식을 바꾸지 않고 하위 호환된다 (없으면 0).
class RiftRecords {
  RiftRecords(this.stats, {this.onChanged});

  final Map<String, int> stats;

  /// 값이 바뀌면 부른다 (프로필 dirty 표시)
  final void Function()? onChanged;

  static const kOpen = 'riftOpen';
  static const kBest = 'riftBest';
  static const kBestWave = 'riftBestWave';
  static const kDay = 'riftDay';
  static const kRuns = 'riftRuns';
  static const kTotal = 'riftTotal';
  static const kWeek = 'riftWeek';
  static const kWeekBest = 'riftWeekBest';
  static const kWeekWaves = 'riftWeekWaves';
  static const kWeekSent = 'riftWeekSent';
  static const kLastWeek = 'riftLastWeek';
  static const kLastBest = 'riftLastBest';
  static const kLastWaves = 'riftLastWaves';

  /// 해금: 스토리 '해적 3척 격추'(2번째 단계)까지 마치면. 한 번 열리면 환생해도 열려 있다.
  static const unlockStoryIndex = 2;

  int _g(String k) => stats[k] ?? 0;
  void _s(String k, int v) {
    if (_g(k) == v) return;
    stats[k] = v;
    onChanged?.call();
  }

  bool get unlocked => _g(kOpen) > 0;

  /// 메인 게임 스토리 진행으로 해금 여부를 갱신한다. 열렸으면 true.
  bool unlockBy(int storyIndex) {
    if (storyIndex >= unlockStoryIndex) _s(kOpen, 1);
    return unlocked;
  }

  int get best => _g(kBest);
  int get bestWave => _g(kBestWave);
  int get totalRuns => _g(kTotal);

  /// 오늘(UTC) 끝낸 판 수
  int runsToday(DateTime now) => _g(kDay) == riftDayKey(now) ? _g(kRuns) : 0;

  /// 오늘 남은 전액 보상 판 수
  int fullRunsLeft(DateTime now) => max(0, RiftRewards.fullRunsPerDay - runsToday(now));

  /// 주가 바뀌었으면 넘긴다. 바로 전 주의 보내지 못한 최고 기록은 [lastWeek]로 남긴다.
  void rollover(DateTime now) {
    final cur = isoWeekKey(now);
    final w = _g(kWeek);
    if (w == cur) return;
    if (w == previousIsoWeekKey(now) && _g(kWeekBest) > _g(kWeekSent)) {
      _s(kLastWeek, w);
      _s(kLastBest, _g(kWeekBest));
      _s(kLastWaves, _g(kWeekWaves));
    } else {
      _s(kLastWeek, 0);
      _s(kLastBest, 0);
      _s(kLastWaves, 0);
    }
    _s(kWeek, cur);
    _s(kWeekBest, 0);
    _s(kWeekWaves, 0);
    _s(kWeekSent, 0);
  }

  int weekBest(DateTime now) {
    rollover(now);
    return _g(kWeekBest);
  }

  int weekWaves(DateTime now) {
    rollover(now);
    return _g(kWeekWaves);
  }

  int get week => _g(kWeek);
  int get lastWeek => _g(kLastWeek);
  int get lastBest => _g(kLastBest);
  int get lastWaves => _g(kLastWaves);

  /// 이번 주 최고 기록을 서버가 받았는지 (같은 점수를 다시 보내지 않는다)
  bool get weekSent => _g(kWeekBest) <= _g(kWeekSent);
  void markWeekSent(int score) => _s(kWeekSent, max(_g(kWeekSent), score));
  void clearLastWeek() {
    _s(kLastWeek, 0);
    _s(kLastBest, 0);
    _s(kLastWaves, 0);
  }

  /// 런 하나를 기록한다. 개인 최고면 true.
  bool record({required int score, required int reached, required DateTime now}) {
    rollover(now);
    final day = riftDayKey(now);
    if (_g(kDay) != day) {
      _s(kDay, day);
      _s(kRuns, 0);
    }
    _s(kRuns, _g(kRuns) + 1);
    _s(kTotal, _g(kTotal) + 1);
    if (score > _g(kWeekBest) || (score == _g(kWeekBest) && reached > _g(kWeekWaves))) {
      _s(kWeekBest, score);
      _s(kWeekWaves, reached);
    }
    final newBest = score > _g(kBest);
    if (newBest) _s(kBest, score);
    if (reached > _g(kBestWave)) _s(kBestWave, reached);
    return newBest;
  }
}
