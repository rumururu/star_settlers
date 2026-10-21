import 'dart:math' show pi;

/// 항성계 환경 규칙. 게임 로직은 UI 프로필에 의존하지 않는다.
enum SystemTrait {
  pirateNest,
  richVeins,
  solarFlare,
  ionNebula,
  gravityWell,
  tradeLane,
}

/// 1~26의 고정 배정. 울프 359의 플레어와 두 블랙홀의 중력 우물을 반영한다.
const _catalogTraits = [
  SystemTrait.tradeLane, // 1 Alpha Centauri
  SystemTrait.richVeins, // 2 Barnard
  SystemTrait.solarFlare, // 3 Wolf 359
  SystemTrait.pirateNest, // 4 Lalande 21185
  SystemTrait.ionNebula, // 5 Sirius
  SystemTrait.gravityWell, // 6 Epsilon Eridani
  SystemTrait.richVeins, // 7 Ross 128
  SystemTrait.tradeLane, // 8 Tau Ceti
  SystemTrait.solarFlare, // 9 Teegarden
  SystemTrait.ionNebula, // 10 Gliese 581
  SystemTrait.pirateNest, // 11 Gliese 667 C
  SystemTrait.richVeins, // 12 TRAPPIST-1
  SystemTrait.solarFlare, // 13 55 Cancri
  SystemTrait.tradeLane, // 14 51 Pegasi
  SystemTrait.gravityWell, // 15 TOI-700
  SystemTrait.ionNebula, // 16 Kepler-16
  SystemTrait.richVeins, // 17 Kepler-186
  SystemTrait.pirateNest, // 18 Kepler-22
  SystemTrait.solarFlare, // 19 Kepler-452
  SystemTrait.tradeLane, // 20 Kepler-90
  SystemTrait.ionNebula, // 21 Omega Centauri
  SystemTrait.gravityWell, // 22 Sagittarius A*
  SystemTrait.pirateNest, // 23 LMC
  SystemTrait.ionNebula, // 24 SMC
  SystemTrait.tradeLane, // 25 Andromeda
  SystemTrait.gravityWell, // 26 M33 X-7
];

SystemTrait? systemTrait(int sector) {
  if (sector <= 0) return null;
  if (sector <= _catalogTraits.length) return _catalogTraits[sector - 1];
  // 27부터 해적 소굴 → … → 교역로 순환. 26과의 경계도 중복 없음.
  return SystemTrait.values[(sector - 27) % SystemTrait.values.length];
}

/// 특성이 없는 태양계는 모든 배율이 1이다.
extension SystemTraitMultipliers on SystemTrait? {
  double get spawnIntervalMul => this == SystemTrait.pirateNest ? 0.7 : 1;
  double get bountyMul => this == SystemTrait.pirateNest ? 1.5 : 1;
  double get colonyOreMul => this == SystemTrait.richVeins ? 2 : 1;
  double get miningOreMul => this == SystemTrait.richVeins ? 1.5 : 1;
  double get colonyCreditMul => this == SystemTrait.solarFlare ? 1.25 : 1;
  double get shieldRegenMul => this == SystemTrait.solarFlare ? 0.5 : 1;
  double get skillCooldownMul => this == SystemTrait.ionNebula ? 0.7 : 1;
  double get turretDamageMul => this == SystemTrait.ionNebula ? 0.7 : 1;
  double get speedMul => this == SystemTrait.gravityWell ? 0.85 : 1;
  double get rewardMul => this == SystemTrait.gravityWell ? 1.3 : 1;
  double get orePriceMul => this == SystemTrait.tradeLane ? 1.3 : 1;
  double get raidFrequencyMul => this == SystemTrait.tradeLane ? 1.3 : 1;
}

/// 항성계 두목의 싸움 방식. 항성계 특성에서 정해지므로 따로 저장하지 않는다.
/// 이름(`name`)은 ARB select 키로 쓴다.
enum BossArchetype {
  fleet, // 해적 함대장: 호위 소환
  devourer, // 광맥 포식자: 기뢰 살포
  flare, // 플레어 포격함: 3갈래 레이저
  wraith, // 이온 유령: 은신 주기
  gravity, // 중력 군주: 선장 끌어당김
  plunder; // 약탈 상선: 빠름, 크레딧 약탈

  /// 함대장: 호위 소환 간격·한 번에 부르는 수·맵 위 최대 호위
  static const escortInterval = 10.0;
  static const escortBatch = 2;
  static const escortMax = 6;

  /// 포식자: 기뢰 살포 간격·한 번에 까는 수 (맵 최대치는 기뢰 부설선과 공유)
  static const mineInterval = 5.0;
  static const mineBatch = 3;

  /// 포격함: 발사 간격·충전 시간·갈래 사이 각도(±20°)
  static const flareInterval = 7.0;
  static const flareCharge = 1.5;
  static const flareSpread = 20 * pi / 180;

  /// 유령: 은신·노출 각각의 시간
  static const wraithPhase = 4.0;

  /// 군주: 끌어당기는 반경과 초당 끌림
  static const gravityRange = 700.0;
  static const gravityPull = 120.0;

  /// 상선: 이동 속도 배율, 한 번 맞힐 때 빼앗는 크레딧 비율, 처치 보상 대비 약탈 상한
  static const plunderSpeedMul = 1.4;
  static const plunderRate = 0.01;
  static const plunderCapRatio = 0.5;
}

extension SystemTraitBoss on SystemTrait? {
  /// 특성 없는 태양계는 원형 없음 (기존 두목 패턴)
  BossArchetype? get bossArchetype => switch (this) {
    SystemTrait.pirateNest => BossArchetype.fleet,
    SystemTrait.richVeins => BossArchetype.devourer,
    SystemTrait.solarFlare => BossArchetype.flare,
    SystemTrait.ionNebula => BossArchetype.wraith,
    SystemTrait.gravityWell => BossArchetype.gravity,
    SystemTrait.tradeLane => BossArchetype.plunder,
    null => null,
  };
}
