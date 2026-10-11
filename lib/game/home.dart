import 'dart:math';

import '../l10n/l.dart';

/// 내 행성: 환생해도 유지되는 나만의 행성.
/// 둘레의 칸에 건물을 지으면 모든 게임에 영구 보너스를 준다.
enum BuildingType { house, farm, mine, lab, tower, shipyard, park, statue }

extension BuildingInfo on BuildingType {
  String get label => switch (this) {
        BuildingType.house => tr.g_bldHouse,
        BuildingType.farm => tr.g_bldFarm,
        BuildingType.mine => tr.g_bldMine,
        BuildingType.lab => tr.g_bldLab,
        BuildingType.tower => tr.g_bldTower,
        BuildingType.shipyard => tr.g_bldShipyard,
        BuildingType.park => tr.g_bldPark,
        BuildingType.statue => tr.g_bldStatue,
      };

  String get icon => switch (this) {
        BuildingType.house => '🏠',
        BuildingType.farm => '🌾',
        BuildingType.mine => '⛏',
        BuildingType.lab => '🔬',
        BuildingType.tower => '🛡',
        BuildingType.shipyard => '🚀',
        BuildingType.park => '🎡',
        BuildingType.statue => '🗿',
      };

  /// 레벨당 효과 설명
  String effect(int level) => switch (this) {
        BuildingType.house => tr.g_bldHouseEffect(level * 2),
        BuildingType.farm => tr.g_bldFarmEffect(level * 3),
        BuildingType.mine => tr.g_bldMineEffect(level * 4),
        BuildingType.lab => tr.g_bldLabEffect(level * 3),
        BuildingType.tower => tr.g_bldTowerEffect(level * 4),
        BuildingType.shipyard => tr.g_bldShipyardEffect(level * 3),
        BuildingType.park => tr.g_bldParkEffect((level * HomePlanet.offlineParkStep * 100).round()),
        BuildingType.statue => tr.g_bldStatueEffect(level),
      };

  /// 젬으로만 짓는 건물
  bool get gemOnly => this == BuildingType.statue;
}

class HomeSlot {
  HomeSlot(this.type, [this.level = 1]);
  final BuildingType type;
  int level;
  static const maxLevel = 5;
}

/// 행성 색상 팔레트 (밝은색, 어두운색). 마지막 3개는 젬 구매
List<(String, int, int, int)> get homePalettes => [
  (tr.g_homePalette0, 0xFF66BB6A, 0xFF1565C0, 0),
  (tr.g_homePalette1, 0xFFFFCC80, 0xFFBF6F2C, 0),
  (tr.g_homePalette2, 0xFFE1F5FE, 0xFF4FC3F7, 0),
  (tr.g_homePalette3, 0xFFFF7043, 0xFF3E2723, 0),
  (tr.g_homePalette4, 0xFFCE93D8, 0xFF5E35B1, 0),
  (tr.g_homePalette5, 0xFFF8BBD0, 0xFFC2185B, 50),
  (tr.g_homePalette6, 0xFF69F0AE, 0xFF304FFE, 50),
  (tr.g_homePalette7, 0xFFFFE082, 0xFFFF8F00, 80),
];

class HomePlanet {
  /// 사용자가 붙인 이름. null이면 기본 이름(현재 언어의 g_homeDefaultName)을 보여 준다.
  /// 기본 이름을 문자열로 저장하면 언어를 바꿔도 예전 언어로 남아서 null로 둔다.
  String? _customName;

  String get name => _customName ?? tr.g_homeDefaultName;

  /// 빈 문자열이나 어느 언어든 기본 이름이면 기본 이름으로 되돌린다
  set name(String? value) {
    final v = value?.trim() ?? '';
    _customName = v.isEmpty || isDefaultName(v) ? null : v;
  }

  /// 사용자가 이름을 바꿨는지
  bool get hasCustomName => _customName != null;

  /// [text]가 지원 언어 중 하나의 기본 이름인지 (예전 저장은 기본 이름을 문자열로 저장했다)
  static bool isDefaultName(String text) =>
      L10n.supportedLocales.any((l) => lookupL10n(l).g_homeDefaultName == text);

  int palette = 0;
  final ownedPalettes = <int>{0, 1, 2, 3, 4};
  bool ring = false;
  int level = 1;
  final slots = <HomeSlot?>[];
  int lastHarvestMs = 0;

  static const maxLevel = 4;
  static const harvestHours = 8;

  HomePlanet() {
    _fitSlots();
  }

  int get slotCount => 2 + level * 2; // 4, 6, 8, 10

  void _fitSlots() {
    while (slots.length < slotCount) {
      slots.add(null);
    }
  }

  int levelOf(BuildingType t) =>
      slots.whereType<HomeSlot>().where((s) => s.type == t).fold(0, (a, s) => a + s.level);

  int get buildingCount => slots.whereType<HomeSlot>().length;
  int get residents => 2 + levelOf(BuildingType.house) * 2;

  // ---------- 보너스 (게임 전체에 적용) ----------
  double get incomeMul => 1 + levelOf(BuildingType.farm) * 0.03;
  double get oreMul => 1 + levelOf(BuildingType.mine) * 0.04;
  double get cooldownMul => max(0.5, 1 - levelOf(BuildingType.lab) * 0.03);
  double get hpMul => 1 + levelOf(BuildingType.tower) * 0.04;
  double get damageMul => 1 + levelOf(BuildingType.shipyard) * 0.03;
  /// 오프라인 수입 효율: 기본 [offlineBaseEfficiency], 놀이공원 레벨마다 +[offlineParkStep]%p.
  /// 세션 사이 2시간(광고 2배)이 한 세션 플레이 수입의 2~3배쯤 되게 맞춘다.
  /// (예전 50%는 2시간 오프라인이 한 세션의 10배라 접속만 하면 다음 항성계가 끝났다)
  static const offlineBaseEfficiency = 0.15;
  static const offlineParkStep = 0.02;
  static const offlineMaxEfficiency = 0.5;
  double get offlineEfficiency => min(offlineMaxEfficiency,
      offlineBaseEfficiency + levelOf(BuildingType.park) * offlineParkStep);

  // ---------- 비용 ----------
  /// 새 건물 비용 (크레딧, 광석). 동상은 젬 (아래 [statueGemCost])
  /// [mul]은 비용 배율 (GameWorld.homeCostMul: 가장 멀리 간 항성계 기준).
  /// 고정 가격이면 뒤 항성계에서 몇 분 수입으로 영구 보너스를 다 채운다.
  (int, int) buildCost(BuildingType t, [double mul = 1]) =>
      ((600 * pow(1.35, buildingCount) * mul).round(), ((100 + buildingCount * 40) * mul).round());

  (int, int) upgradeCost(HomeSlot s, [double mul = 1]) =>
      ((800 * pow(1.8, s.level) * mul).round(), (150 * s.level * mul).round());

  int statueGemCost(int level) => 40 + level * 30;

  (int, int) levelUpCostAt(double mul) =>
      ((3000 * pow(3, level - 1) * mul).round(), (500 * level * mul).round());
  (int, int) get levelUpCost => levelUpCostAt(1);

  void levelUp() {
    level++;
    _fitSlots();
  }

  // ---------- 행성 선물 ----------
  bool harvestReady(DateTime now) =>
      now.millisecondsSinceEpoch - lastHarvestMs >= harvestHours * 3600 * 1000;

  Duration harvestIn(DateTime now) {
    final ms = lastHarvestMs + harvestHours * 3600 * 1000 - now.millisecondsSinceEpoch;
    return Duration(milliseconds: max(0, ms));
  }

  /// 선물 내용 (크레딧 배율은 현재 섹터 배율을 곱해서 사용)
  (int credits, int gems) harvestReward(double sectorMul) => (
        (300 * (1 + residents * 0.1) * sectorMul).round(),
        1 + levelOf(BuildingType.statue) + (residents >= 12 ? 1 : 0),
      );

  Map<String, dynamic> toJson() => {
        // 기본 이름은 저장하지 않는다 (불러올 때 현재 언어로 보여 준다)
        if (_customName != null) 'name': _customName,
        'palette': palette,
        'owned': ownedPalettes.toList(),
        'ring': ring,
        'level': level,
        'slots': [
          for (final s in slots) s == null ? null : {'t': s.type.index, 'l': s.level}
        ],
        'harvest': lastHarvestMs,
      };

  static HomePlanet fromJson(Map<String, dynamic> j) {
    final h = HomePlanet()
      ..name = j['name'] as String?
      ..palette = j['palette'] as int? ?? 0
      ..ring = j['ring'] as bool? ?? false
      ..level = j['level'] as int? ?? 1
      ..lastHarvestMs = j['harvest'] as int? ?? 0;
    h.ownedPalettes.addAll(((j['owned'] as List?) ?? []).cast<int>());
    h.slots.clear();
    for (final s in (j['slots'] as List?) ?? []) {
      if (s == null) {
        h.slots.add(null);
      } else {
        final m = s as Map;
        h.slots.add(HomeSlot(BuildingType.values[m['t'] as int], m['l'] as int));
      }
    }
    h._fitSlots();
    return h;
  }
}
