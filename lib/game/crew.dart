import 'dart:math';

import '../l10n/l.dart';
import 'cosmetics.dart';

enum CrewRole { gunner, engineer, pilot, trader, miner, scientist }

extension CrewRoleInfo on CrewRole {
  String get label => switch (this) {
        CrewRole.gunner => tr.g_crewRoleGunner,
        CrewRole.engineer => tr.g_crewRoleEngineer,
        CrewRole.pilot => tr.g_crewRolePilot,
        CrewRole.trader => tr.g_crewRoleTrader,
        CrewRole.miner => tr.g_crewRoleMiner,
        CrewRole.scientist => tr.g_crewRoleScientist,
      };
  String get icon => switch (this) {
        CrewRole.gunner => '🔫',
        CrewRole.engineer => '🔧',
        CrewRole.pilot => '🕹',
        CrewRole.trader => '💰',
        CrewRole.miner => '⛏',
        CrewRole.scientist => '🧪',
      };
  String get effect => switch (this) {
        CrewRole.gunner => tr.g_crewEffectGunner,
        CrewRole.engineer => tr.g_crewEffectEngineer,
        CrewRole.pilot => tr.g_crewEffectPilot,
        CrewRole.trader => tr.g_crewEffectTrader,
        CrewRole.miner => tr.g_crewEffectMiner,
        CrewRole.scientist => tr.g_crewEffectScientist,
      };
  int get suitColor => switch (this) {
        CrewRole.gunner => 0xFFE53935,
        CrewRole.engineer => 0xFFFFA000,
        CrewRole.pilot => 0xFF1E88E5,
        CrewRole.trader => 0xFF43A047,
        CrewRole.miner => 0xFF6D4C41,
        CrewRole.scientist => 0xFF8E24AA,
      };
}

/// 저장용 원본 이름 (세이브 호환). 화면 표시는 [_localNames]로 번역한다.
const _names = [
  '뭉치', '코코', '별이', '두부', '콩이', '루루', '하루', '포포', '미미', '도리',
  '몽실', '나비', '초코', '보리', '구름', '단비', '토리', '해피', '찹쌀', '모찌',
  '라떼', '쿠키', '젤리', '솜이', '망고', '자두', '호두', '깜이', '밤비', '치즈',
];

const _hairColors = [
  0xFF5D4037, 0xFF212121, 0xFFFFD54F, 0xFFEC407A, 0xFF42A5F5,
  0xFF66BB6A, 0xFFFF7043, 0xFFB0BEC5, 0xFF7E57C2, 0xFFFFFFFF,
];
const _skinColors = [0xFFFFE0C7, 0xFFFFD3B0, 0xFFF1C27D, 0xFFE0AC69, 0xFFFFE6D5];

/// 현재 언어의 승무원 이름 ([_names]와 같은 순서). 저장은 한국어 원본으로 한다.
List<String> get _localNames => [
      tr.g_crewName0,
      tr.g_crewName1,
      tr.g_crewName2,
      tr.g_crewName3,
      tr.g_crewName4,
      tr.g_crewName5,
      tr.g_crewName6,
      tr.g_crewName7,
      tr.g_crewName8,
      tr.g_crewName9,
      tr.g_crewName10,
      tr.g_crewName11,
      tr.g_crewName12,
      tr.g_crewName13,
      tr.g_crewName14,
      tr.g_crewName15,
      tr.g_crewName16,
      tr.g_crewName17,
      tr.g_crewName18,
      tr.g_crewName19,
      tr.g_crewName20,
      tr.g_crewName21,
      tr.g_crewName22,
      tr.g_crewName23,
      tr.g_crewName24,
      tr.g_crewName25,
      tr.g_crewName26,
      tr.g_crewName27,
      tr.g_crewName28,
      tr.g_crewName29,
    ];

/// ★4 전설 승무원 칭호
List<String> get _legendTitles =>
    [tr.g_crewLegend0, tr.g_crewLegend1, tr.g_crewLegend2, tr.g_crewLegend3, tr.g_crewLegend4];

class CrewMember {
  CrewMember({
    required this.id,
    required String name,
    required this.role,
    required this.rarity,
    required this.lookSeed,
    this.level = 1,
    this.assigned = false,
  }) : rawName = name;

  final int id;

  /// 저장되는 원래 이름 (기본 이름표의 한국어 원본)
  final String rawName;

  /// 화면에 보이는 이름 (기본 이름표면 현재 언어로)
  String get name {
    final i = _names.indexOf(rawName);
    return i < 0 ? rawName : _localNames[i];
  }
  final CrewRole role;
  final int rarity; // 1..4 (★4 = 전설, 젬 전용)
  final int lookSeed;
  int level;
  bool assigned;

  static const maxLevel = 5;

  /// 효과 (퍼센트)
  int get bonusPct => rarity * 5 + (level - 1) * 3;

  int get levelUpCost => 200 * level * rarity;

  /// ★4 전설
  bool get legendary => rarity >= 4;

  /// ★4는 칭호가 붙는다 (예: '은하수호자 뭉치')
  String get displayName =>
      legendary ? tr.g_crewLegendName(_legendTitles[lookSeed % _legendTitles.length], name) : name;

  int get hairColor => _hairColors[lookSeed % _hairColors.length];
  int get skinColor => _skinColors[(lookSeed ~/ 7) % _skinColors.length];
  bool get glasses => (lookSeed ~/ 13) % 4 == 0;
  Accessory get accessory {
    if (legendary) return Accessory.crown;
    final opts = [
      Accessory.none, Accessory.none, Accessory.catEars, Accessory.bunnyEars,
      Accessory.antenna, Accessory.flower,
      if (rarity == 3) Accessory.crown,
    ];
    return opts[(lookSeed ~/ 31) % opts.length];
  }

  String get stars => '★' * rarity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': rawName,
        'role': role.index,
        'rarity': rarity,
        'look': lookSeed,
        'level': level,
        'assigned': assigned,
      };

  static CrewMember fromJson(Map<String, dynamic> j) => CrewMember(
        id: j['id'] as int,
        name: j['name'] as String,
        role: CrewRole.values[j['role'] as int],
        rarity: j['rarity'] as int,
        lookSeed: j['look'] as int,
        level: j['level'] as int,
        assigned: j['assigned'] as bool,
      );

  /// 희귀도 확률표 (게임 내 공개용)
  static const creditOdds = {1: 70, 2: 25, 3: 5};
  /// ★4 전설은 고급(젬) 영입에서만 나온다
  static const gemOdds = {2: 77, 3: 20, 4: 3};

  /// 확률표 안내 문구 ('★2 77% / ★3 20% / ★4 3%')
  static String oddsText(Map<int, int> odds) =>
      odds.entries.map((e) => '${'★' * e.key} ${e.value}%').join(' / ');

  static CrewMember random(Random r, int id, {required Map<int, int> odds}) {
    final roll = r.nextInt(100);
    var acc = 0;
    var rarity = odds.keys.first;
    for (final e in odds.entries) {
      acc += e.value;
      if (roll < acc) {
        rarity = e.key;
        break;
      }
    }
    return CrewMember(
      id: id,
      name: _names[r.nextInt(_names.length)],
      role: CrewRole.values[r.nextInt(CrewRole.values.length)],
      rarity: rarity,
      lookSeed: r.nextInt(1 << 20),
    );
  }
}
