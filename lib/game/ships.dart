import '../l10n/l.dart';

/// 격납고 함선 종류. 스킨(색)과 별개로 성능과 외형(실루엣)이 다르다.
class ShipType {
  const ShipType(
    this.id, {
    this.hpMul = 1,
    this.speedMul = 1,
    this.dmgMul = 1,
    this.fireMul = 1,
    this.oreMul = 1,
    this.magnetMul = 1,
    this.crit = 0,
    this.unlockStat,
    this.unlockTarget = 0,
    this.gemPrice = 0,
    this.premium = false,
    this.pierce = 0,
    this.regenRate = 0,
    this.guardInterval = 0,
    this.creditMul = 1,
    this.wing = 26,
    this.length = 46,
  });

  final String id;
  String get name => switch (id) {
        'interceptor' => tr.g_shipInterceptorName,
        'fortress' => tr.g_shipFortressName,
        'prospector' => tr.g_shipProspectorName,
        'phantom' => tr.g_shipPhantomName,
        'nova' => tr.g_shipNovaName,
        'aurora' => tr.g_shipAuroraName,
        _ => tr.g_shipScoutName,
      };
  String get desc => switch (id) {
        'interceptor' => tr.g_shipInterceptorDesc,
        'fortress' => tr.g_shipFortressDesc,
        'prospector' => tr.g_shipProspectorDesc,
        'phantom' => tr.g_shipPhantomDesc,
        'nova' => tr.g_shipNovaDesc,
        'aurora' => tr.g_shipAuroraDesc,
        _ => tr.g_shipScoutDesc,
      };
  final double hpMul;
  final double speedMul;
  final double dmgMul;

  /// 발사 간격 배율 (작을수록 빠름)
  final double fireMul;
  final double oreMul;
  final double magnetMul;

  /// 치명타 확률 (치명타는 2.5배 피해)
  final double crit;

  /// 해금 조건: 프로필 통계 [unlockStat] >= [unlockTarget], 또는 젬 구매
  final String? unlockStat;
  final int unlockTarget;
  String get unlockDesc => switch (unlockStat) {
        'sector' => tr.g_unlockSector(unlockTarget),
        'bosses' => tr.g_unlockBosses(unlockTarget),
        'ore' => tr.g_unlockOre(unlockTarget),
        _ => '',
      };
  final int gemPrice;

  /// 프리미엄 함선: 통계로는 해금되지 않고 젬으로만 살 수 있다
  final bool premium;

  /// 고유 능력 설명 (격납고·상점 표시용). 직접 버는 크레딧 보너스가 있으면 한 줄 덧붙인다.
  String get ability {
    final base = switch (id) {
      'nova' => tr.g_shipNovaAbility,
      'aurora' => tr.g_shipAuroraAbility,
      _ => '',
    };
    if (creditMul <= 1) return base;
    final bonus = tr.g_shipCreditBonus(creditBonusPct);
    return base.isEmpty ? bonus : '$base\n$bonus';
  }

  /// 직접 버는 크레딧 배율: 함선이 잡은 해적 현상금·소행성 크레딧·임무·습격 방어·두목 보상.
  /// 본거지 레이저가 잡은 해적에는 붙지 않는다 (안전 구역 파밍 방지).
  final double creditMul;
  int get creditBonusPct => ((creditMul - 1) * 100).round();

  /// 관통: 탄환이 적을 맞히고도 이만큼 더 날아가 추가로 맞힌다
  final int pierce;

  /// 자가 수리: 피격 없이 [regenDelay]초가 지나면 초당 최대 체력의 이 비율만큼 회복
  final double regenRate;
  static const regenDelay = 3.0;

  /// 보호막: 이 간격(초)마다 재충전되어 피격 1회를 막는다 (0이면 없음)
  final double guardInterval;

  /// 외형
  final double wing;
  final double length;
}

const shipTypes = [
  ShipType('scout'),
  ShipType('interceptor',
      hpMul: 0.8, speedMul: 1.3, dmgMul: 0.9, fireMul: 0.75,
      unlockStat: 'sector', unlockTarget: 2, gemPrice: 150,
      wing: 34, length: 42),
  ShipType('fortress',
      hpMul: 1.6, speedMul: 0.8, dmgMul: 1.15, fireMul: 1.1,
      unlockStat: 'bosses', unlockTarget: 3, gemPrice: 150,
      wing: 22, length: 52),
  ShipType('prospector',
      hpMul: 1.1, dmgMul: 0.85, oreMul: 1.5, magnetMul: 1.8,
      unlockStat: 'ore', unlockTarget: 3000, gemPrice: 150,
      wing: 30, length: 44),
  ShipType('phantom',
      hpMul: 0.9, speedMul: 1.15, crit: 0.25,
      unlockStat: 'sector', unlockTarget: 4, gemPrice: 250,
      wing: 30, length: 50),
  ShipType('nova',
      speedMul: 1.1, fireMul: 0.85,
      premium: true, pierce: 1, gemPrice: 400, creditMul: 1.5,
      wing: 36, length: 54),
  ShipType('aurora',
      hpMul: 1.3, fireMul: 0.95,
      premium: true,
      regenRate: 0.03, guardInterval: 8, gemPrice: 600, creditMul: 1.75,
      wing: 34, length: 48),
];

ShipType shipTypeById(String id) =>
    shipTypes.firstWhere((s) => s.id == id, orElse: () => shipTypes.first);
