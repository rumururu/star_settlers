import 'crew.dart';
import 'models.dart';
import 'profile.dart';
import 'star_catalog.dart';
import 'system_traits.dart';

/// 도감 (TASK 006). 만난 적·정착한 행성 종류·도달한 항성계·얻어 본 승무원 조합을 모은다.
/// 계정 단위([Profile.codex])라 새 게임·은하 명예(환생) 뒤에도 남는다.
/// 게임 코드는 [GameWorld]의 기존 처치/정착/도착/승무원 지점에서 한 줄씩 부른다.
enum CodexTab { enemies, planets, systems, crew }

/// 적 도감 항목 (등장 순서). 항성계 두목 원형은 `arch_<원형>`.
const codexEnemyIds = [
  'scout',
  'raider',
  'bomber',
  'sniper',
  'jelly',
  'boss',
  'commander',
  'missile',
  'mine',
  'laser',
  'warden',
  'phantom',
  'medic',
  'carrier',
  'juggernaut',
  'arch_fleet',
  'arch_devourer',
  'arch_flare',
  'arch_wraith',
  'arch_gravity',
  'arch_plunder',
];

/// 승무원 도감: 직업 6 × ★1~3 (★4 전설은 젬 전용이라 칸을 두지 않는다)
const codexCrewRarities = [1, 2, 3];
List<String> get codexCrewIds => [
  for (final r in CrewRole.values)
    for (final s in codexCrewRarities) crewCodexId(r, s),
];
String crewCodexId(CrewRole role, int rarity) => '${role.name}:$rarity';

/// 처치한 적의 도감 항목
String codexEnemyId(Pirate e) {
  if (e.invasionCommander) return 'commander';
  if (e.kind == PirateKind.boss) {
    final a = e.archetype;
    return a == null ? 'boss' : 'arch_${a.name}';
  }
  return e.kind.name;
}

/// 항목 그림: 적 스프라이트 (원형 두목·지휘함은 두목·습격선 그림)
String codexEnemySprite(String id) => switch (id) {
  'jelly' => 'jelly',
  'commander' => 'pirate_raider',
  _ when id == 'boss' || id.startsWith('arch_') => 'pirate_boss',
  _ => 'pirate_$id',
};

/// 원형 두목 항목의 원형 (아니면 null)
BossArchetype? codexArchetype(String id) => id.startsWith('arch_')
    ? BossArchetype.values.where((a) => 'arch_${a.name}' == id).firstOrNull
    : null;

/// 이 적을 처음 만날 수 있는 항성계 (0 기반). 두목 원형은 그 특성을 가진 첫 항성계.
int codexEnemySector(String id) {
  final a = codexArchetype(id);
  if (a != null) {
    for (var s = 1; s < catalogSystemCount; s++) {
      if (systemTrait(s).bossArchetype == a) return s;
    }
  }
  return PirateKind.values
          .where((k) => k.name == id)
          .firstOrNull
          ?.unlockSector ??
      0;
}

/// 마일스톤 (탭별 퍼센트)
const codexMilestones = [25, 50, 75, 100];

/// 마일스톤 보상. 젬은 쓰지 않는다 (공통 규칙: 새 젬 출처 금지).
/// 100%: ★3 승무원 + 도감 전용 선장 의상(처음 한 번).
class CodexReward {
  const CodexReward({
    this.credits = 0,
    this.ore = 0,
    this.crewRarity = 0,
    this.outfit = false,
  });
  final int credits;
  final int ore;
  final int crewRarity;
  final bool outfit;
}

CodexReward codexReward(int pct) => switch (pct) {
  25 => const CodexReward(credits: 2000),
  50 => const CodexReward(credits: 3000, ore: 1500),
  75 => const CodexReward(credits: 5000, ore: 3000, crewRarity: 2),
  _ => const CodexReward(crewRarity: 3, outfit: true),
};

/// 도감 전용 선장 의상 id ([codexOutfit], cosmetics.dart)
const codexOutfitId = 'codex';

/// HUD 토스트 한 건
typedef CodexFind = ({CodexTab tab, String id});

class Codex {
  Codex([this._onDirty]);
  final void Function()? _onDirty;

  /// 적 항목별 처치 수 (1 이상 = 발견)
  final kills = <String, int>{};

  /// 정착해 본 행성 종류 (PlanetKind.name)
  final planetKinds = <String>{};

  /// 정착한 행성 "항성계:번호:행성수" → 가장 높은 식민지 레벨. 이름은 [planetIdentity]로 그때 언어로 만든다.
  final colonies = <String, int>{};

  /// 도달한 항성계 (0 = 태양계)
  final systems = <int>{};

  /// 얻어 본 승무원 "직업:★"
  final crew = <String>{};

  /// 받은 마일스톤 "탭:퍼센트"
  final claimed = <String>{};

  /// 도감을 열어 보기 전의 새 항목 "탭:id" (빨간 점)
  final fresh = <String>{};

  /// 받았지만 아직 월드에 넣지 못한 보상 (타이틀에서 받으면 다음 게임에 들어간다)
  int pendingCredits = 0;
  int pendingOre = 0;
  final pendingCrew = <int>[];

  /// HUD 토스트 대기열 (저장하지 않는다)
  final toasts = <CodexFind>[];

  /// 지금 HUD 대사 칸에 보여 주는 토스트 (CodexHud가 정하고 게임 화면이 그린다). 저장하지 않는다.
  CodexFind? showing;

  void _changed() => _onDirty?.call();

  bool _discover(CodexTab tab, String id, {bool silent = false}) {
    if (!silent) {
      fresh.add('${tab.name}:$id');
      toasts.add((tab: tab, id: id));
    }
    _changed();
    return true;
  }

  // ---------- 기록 ----------
  /// 적 처치. 처음이면 true
  bool recordKill(Pirate e) {
    final id = codexEnemyId(e);
    final n = kills[id] ?? 0;
    kills[id] = n + 1;
    _changed();
    return n == 0 && _discover(CodexTab.enemies, id);
  }

  /// 행성 정착·식민지 레벨 상승 (현재 항성계 또는 원격)
  bool recordColony(
    int sector,
    int index,
    int count,
    PlanetKind kind,
    int level, {
    bool silent = false,
  }) {
    if (level <= 0 || index < 0) return false;
    final key = '$sector:$index:$count';
    if ((colonies[key] ?? 0) < level) {
      colonies[key] = level;
      _changed();
    }
    if (!planetKinds.add(kind.name)) return false;
    return _discover(CodexTab.planets, kind.name, silent: silent);
  }

  /// 항성계 도착
  bool recordSystem(int sector, {bool silent = false}) {
    if (sector < 0 || sector >= catalogSystemCount || !systems.add(sector)) {
      return false;
    }
    return _discover(CodexTab.systems, '$sector', silent: silent);
  }

  /// 승무원 획득 (★4는 세지 않는다)
  bool recordCrew(CrewRole role, int rarity, {bool silent = false}) {
    if (!codexCrewRarities.contains(rarity)) return false;
    final id = crewCodexId(role, rarity);
    if (!crew.add(id)) return false;
    return _discover(CodexTab.crew, id, silent: silent);
  }

  // ---------- 진행도 ----------
  bool found(CodexTab tab, String id) => switch (tab) {
    CodexTab.enemies => (kills[id] ?? 0) > 0,
    CodexTab.planets => planetKinds.contains(id),
    CodexTab.systems => systems.contains(int.tryParse(id)),
    CodexTab.crew => crew.contains(id),
  };

  static List<String> ids(CodexTab tab) => switch (tab) {
    CodexTab.enemies => codexEnemyIds,
    CodexTab.planets => [for (final k in PlanetKind.values) k.name],
    CodexTab.systems => [for (var s = 0; s < catalogSystemCount; s++) '$s'],
    CodexTab.crew => codexCrewIds,
  };

  int foundCount(CodexTab tab) => ids(tab).where((id) => found(tab, id)).length;
  int total(CodexTab tab) => ids(tab).length;

  /// 0~100 (내림)
  int percent(CodexTab tab) => foundCount(tab) * 100 ~/ total(tab);

  bool isClaimed(CodexTab tab, int pct) => claimed.contains('${tab.name}:$pct');
  bool canClaim(CodexTab tab, int pct) =>
      percent(tab) >= pct && !isClaimed(tab, pct);

  /// 받을 수 있는 마일스톤 수
  int get claimable => [
    for (final t in CodexTab.values)
      for (final m in codexMilestones)
        if (canClaim(t, m)) 1,
  ].length;

  /// 빨간 점 숫자: 새 항목 + 받을 수 있는 보상
  int get badge => fresh.length + claimable;

  int freshIn(CodexTab tab) =>
      fresh.where((f) => f.startsWith('${tab.name}:')).length;
  bool isFresh(CodexTab tab, String id) => fresh.contains('${tab.name}:$id');

  /// 이 탭을 봤다 → 새 항목 표시를 지운다
  void markSeen(CodexTab tab) {
    final before = fresh.length;
    fresh.removeWhere((f) => f.startsWith('${tab.name}:'));
    if (fresh.length != before) _changed();
  }

  /// 마일스톤 수령. 보상은 [pendingCredits] 등에 쌓이고 [deliver]가 월드에 넣는다.
  /// 의상은 [profile]에 바로 준다. 이미 받았거나 아직이면 null.
  CodexReward? claim(CodexTab tab, int pct, Profile profile) {
    if (!codexMilestones.contains(pct) || !canClaim(tab, pct)) return null;
    claimed.add('${tab.name}:$pct');
    final r = codexReward(pct);
    pendingCredits += r.credits;
    pendingOre += r.ore;
    if (r.crewRarity > 0) pendingCrew.add(r.crewRarity);
    if (r.outfit) profile.ownedOutfits.add(codexOutfitId);
    _changed();
    return r;
  }

  bool get hasPending =>
      pendingCredits > 0 || pendingOre > 0 || pendingCrew.isNotEmpty;

  /// 쌓인 보상을 월드에 넣는다. 승무원은 정원이 차 있으면 다음에 다시 시도한다.
  /// [addCredits]/[addOre]/[addCrew]는 월드가 넘긴다 (도감은 월드를 모른다).
  void deliver({
    required void Function(int) addCredits,
    required void Function(int) addOre,
    required bool Function(int rarity) addCrew,
  }) {
    if (!hasPending) return;
    if (pendingCredits > 0) addCredits(pendingCredits);
    if (pendingOre > 0) addOre(pendingOre);
    pendingCredits = 0;
    pendingOre = 0;
    while (pendingCrew.isNotEmpty && addCrew(pendingCrew.first)) {
      pendingCrew.removeAt(0);
    }
    _changed();
  }

  // ---------- 저장 ----------
  Map<String, dynamic> toJson() => {
    'k': kills,
    'pk': planetKinds.toList(),
    'pl': colonies,
    'sy': systems.toList(),
    'cr': crew.toList(),
    'cl': claimed.toList(),
    'new': fresh.toList(),
    'pc': pendingCredits,
    'po': pendingOre,
    'pw': pendingCrew,
  };

  /// 예전 저장(도감 없음)이면 빈 도감
  void load(Object? json) {
    if (json is! Map) return;
    final j = json.cast<String, dynamic>();
    (j['k'] as Map?)?.forEach((k, v) {
      if (k is String && v is int && v > 0) kills[k] = v;
    });
    planetKinds.addAll(((j['pk'] as List?) ?? const []).whereType<String>());
    (j['pl'] as Map?)?.forEach((k, v) {
      if (k is String && v is int) colonies[k] = v;
    });
    systems.addAll(((j['sy'] as List?) ?? const []).whereType<int>());
    crew.addAll(((j['cr'] as List?) ?? const []).whereType<String>());
    claimed.addAll(((j['cl'] as List?) ?? const []).whereType<String>());
    fresh.addAll(((j['new'] as List?) ?? const []).whereType<String>());
    pendingCredits = j['pc'] as int? ?? 0;
    pendingOre = j['po'] as int? ?? 0;
    pendingCrew.addAll(((j['pw'] as List?) ?? const []).whereType<int>());
  }
}
