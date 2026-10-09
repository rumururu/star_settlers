import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/crew.dart';
import 'package:star_settlers/game/home.dart';
import 'package:star_settlers/game/josa.dart';
import 'package:star_settlers/game/missions.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/ships.dart';
import 'package:star_settlers/game/world.dart';

GameWorld rich({int seed = 1}) => GameWorld(seed: seed)
  ..credits = 1e6
  ..ore = 1e6;

void runFor(GameWorld w, double sec, [InputState? input]) {
  final i = input ?? InputState();
  for (var t = 0.0; t < sec; t += 1 / 60) {
    w.update(1 / 60, i);
  }
}

void main() {
  group('월드', () {
    test('생성: 행성/기지/게이트/소행성', () {
      final w = GameWorld(seed: 42);
      expect(w.planets.length, greaterThanOrEqualTo(5));
      expect(w.planets.first.name, '테라노바');
      expect(w.stations.length, 1);
      expect(w.gates.where((g) => g.forward).length, 1);
      expect(w.asteroids.length, GameWorld.maxAsteroids);
      expect(w.dialogs, isNotEmpty);
    });

    test('같은 시드면 같은 배치', () {
      final a = GameWorld(seed: 7);
      final b = GameWorld(seed: 7);
      expect(a.planets.map((p) => p.pos).toList(), b.planets.map((p) => p.pos).toList());
    });

    test('3분 시뮬레이션이 오류 없이 돌아가고 해적이 등장', () {
      final w = GameWorld(seed: 3);
      final input = InputState()
        ..move = const Offset(1, 0.3)
        ..fire = true;
      runFor(w, 180, input);
      expect(w.totalTime, closeTo(180, 0.5));
      expect(w.pirates, isNotEmpty);
    });
  });

  group('개척/경제', () {
    test('정착은 비용을 내고 수입을 만든다', () {
      final w = GameWorld(seed: 1)..credits = 1000;
      final p = w.planets.first;
      final before = w.creditIncome;
      expect(w.upgradePlanet(p), isTrue);
      expect(p.colonyLevel, 1);
      expect(w.credits, 1000 - 150);
      expect(w.creditIncome, greaterThan(before));
    });

    test('자원이 부족하면 실패', () {
      final w = GameWorld(seed: 1)..credits = 0;
      expect(w.upgradeShip(UpgradeKind.weapon), isFalse);
      expect(w.weaponLevel, 0);
    });

    test('습격 중인 행성은 생산하지 않는다', () {
      final w = rich();
      final p = w.planets.first;
      w.upgradePlanet(p);
      expect(w.planetCreditRate(p), greaterThan(0));
      p.raided = true;
      expect(w.planetCreditRate(p), 0);
    });

    test('광석 판매', () {
      final w = GameWorld(seed: 1)..ore = 100;
      final c = w.credits;
      expect(w.sellOre(50), isTrue);
      expect(w.ore, 50);
      expect(w.credits, greaterThan(c));
    });
  });

  group('전투/스킬', () {
    test('해적 격추 시 보상 드롭과 카운트', () {
      final w = GameWorld(seed: 5);
      final c = w.credits;
      w.pirates.add(Pirate(PirateKind.scout, w.player.pos + const Offset(0, -60), 1));
      w.player.angle = -1.5707963;
      runFor(w, 1.5, InputState()..fire = true);
      expect(w.counter('kills'), greaterThanOrEqualTo(1));
      // 드롭된 크레딧은 자석으로 자동 회수된다
      expect(w.credits, greaterThan(c + 20));
    });

    test('미사일은 장착해야 쓸 수 있고 해적을 추적한다', () {
      final w = rich();
      expect(w.fireMissiles(), isFalse);
      w.upgradeShip(UpgradeKind.missile);
      final e = Pirate(PirateKind.raider, w.player.pos + const Offset(300, 0), 30);
      w.pirates.add(e);
      expect(w.fireMissiles(), isTrue);
      expect(w.missiles, isNotEmpty);
      runFor(w, 2);
      expect(w.pirates.contains(e), isFalse);
    });

    test('실드가 피해를 막는다', () {
      final w = rich();
      w.upgradeShip(UpgradeKind.shield);
      w.activateShield();
      final hp = w.player.hp;
      w.bullets.add(Bullet(w.player.pos, Offset.zero, 50, false));
      w.update(1 / 60, InputState());
      expect(w.player.hp, hp);
    });

    test('격추 → 부활 선택 (제자리 / 기지)', () {
      final w = GameWorld(seed: 2)..credits = 1000;
      w.player.pos = const Offset(1500, 1500); // 본거지 안전 구역 밖
      w.player.hp = 1;
      w.bullets.add(Bullet(w.player.pos, Offset.zero, 50, false));
      w.update(1 / 60, InputState());
      expect(w.player.alive, isFalse);
      expect(w.player.awaitingRevive, isTrue);
      w.reviveHere();
      expect(w.player.alive, isTrue);
      expect(w.credits, greaterThanOrEqualTo(1000));

      w.player.invulnerable = 0;
      w.player.hp = 1;
      w.bullets.add(Bullet(w.player.pos, Offset.zero, 50, false));
      w.update(1 / 60, InputState());
      final before = w.credits;
      w.respawnAtBase();
      expect(w.credits, lessThan(before));
    });
  });

  group('승무원', () {
    test('영입·배치·보너스', () {
      final w = rich();
      final dmg = w.playerDamage;
      final c = w.recruitWithCredits();
      expect(c, isNotNull);
      expect(c!.assigned, isTrue);
      w.roster
        ..clear()
        ..add(CrewMember(id: 99, name: '테스트', role: CrewRole.gunner, rarity: 3, lookSeed: 1, assigned: true));
      expect(w.playerDamage, greaterThan(dmg));
    });

    test('배치 슬롯 제한', () {
      final w = rich();
      for (var i = 0; i < 5; i++) {
        w.recruitWithCredits();
      }
      expect(w.assignedCount, w.crewSlots);
    });

    test('확률표 합은 100%', () {
      expect(CrewMember.creditOdds.values.reduce((a, b) => a + b), 100);
      expect(CrewMember.gemOdds.values.reduce((a, b) => a + b), 100);
    });
  });

  group('임무/스토리', () {
    test('처치 임무 진행 및 보상', () {
      final w = GameWorld(seed: 8);
      w.update(1 / 60, InputState()); // 게시판 생성
      final m = Mission(id: 999, type: MissionType.kill, target: 1, rewardCredits: 500);
      w.missionOffers.add(m);
      expect(w.acceptMission(m), isTrue);
      final c = w.credits;
      w.pirates.add(Pirate(PirateKind.scout, w.player.pos + const Offset(0, -60), 1));
      w.player.angle = -1.5707963;
      runFor(w, 0.6, InputState()..fire = true);
      expect(w.activeMissions.contains(m), isFalse);
      expect(w.credits, greaterThan(c + 400));
    });

    test('스토리 1단계: 소행성 3개 부수면 다음 단계', () {
      final w = GameWorld(seed: 4);
      expect(w.storyIndex, 0);
      w.counters['asteroids'] = 3;
      runFor(w, 1);
      expect(w.storyIndex, 1);
    });

    test('스토리 무한 단계 생성', () {
      expect(storyStepAt(storySteps.length).key, 'devPercent');
      expect(storyStepAt(storySteps.length).target, 100);
      expect(storySectorAt(storySteps.length), 1);
      expect(storyStepAt(storySteps.length + 1).key, 'sector');
    });
  });

  group('섹터/이벤트', () {
    test('발전도 100% 전에는 게이트가 잠겨 있다 (두목만 잡아서는 안 열림)', () {
      final w = GameWorld(seed: 6);
      final gate = w.gates.firstWhere((g) => g.forward);
      expect(w.warp(gate), isFalse);
      w.bossDefeated = true;
      expect(w.warp(gate), isFalse);
      for (final p in w.planets.skip(1)) {
        p.colonyLevel = 3;
      }
      expect(w.development, lessThan(1));
      expect(w.warp(gate), isFalse);
      w.planets.first.colonyLevel = 3;
      expect(w.warp(gate), isTrue);
      expect(w.sector, 1);
      expect(w.gates.any((g) => !g.forward), isTrue);
    });

    test('섹터를 오가도 식민지가 유지되고 다른 섹터 수입이 합산된다', () {
      final w = rich(seed: 11);
      w.upgradePlanet(w.planets.first);
      for (final p in w.planets.skip(1)) {
        p.colonyLevel = 3;
      }
      w.planets.first.colonyLevel = 3;
      w.warp(w.gates.firstWhere((g) => g.forward));
      expect(w.otherSectorCredits, greaterThan(0));
      w.warp(w.gates.firstWhere((g) => !g.forward));
      expect(w.sector, 0);
      expect(w.planets.first.colonyLevel, 3);
      // 한 번 가 본 다음 항성계 게이트는 계속 열려 있다
      expect(w.gateOpen(w.gates.firstWhere((g) => g.forward)), isTrue);
    });

    test('식민지 습격: 해적을 모두 물리치면 보상', () {
      final w = rich(seed: 12);
      w.upgradePlanet(w.planets.first);
      final ev = w.startEvent(EventKind.raid)!;
      expect(w.pirates.where((e) => e.eventId == ev.id), isNotEmpty);
      w.pirates.removeWhere((e) => e.eventId == ev.id);
      final gems = w.profile.gems;
      w.update(1 / 60, InputState());
      expect(w.events, isEmpty);
      expect(w.profile.gems, gems + 2);
    });

    test('떠돌이 상인 거래', () {
      final w = rich(seed: 13);
      w.startEvent(EventKind.merchant);
      expect(w.merchantCrew, isNotNull);
      expect(w.buyMerchantCrew(), isTrue);
      expect(w.roster.length, 1);
      expect(w.buyGemsFromMerchant(), isTrue);
    });
  });

  group('프로필/저장', () {
    test('저장 후 불러오면 진행 상황 유지', () {
      final w = rich(seed: 9);
      w.upgradePlanet(w.planets.first);
      w.upgradeShip(UpgradeKind.engine);
      w.recruitWithCredits();
      for (final p in w.planets) {
        p.colonyLevel = 3; // 발전도 100%
      }
      w.warp(w.gates.firstWhere((g) => g.forward));
      final w2 = GameWorld.fromJson(w.toJson(), w.profile);
      expect(w2.sector, 1);
      expect(w2.sectors[0]!.colonyLevels.first, 3);
      expect(w2.level(UpgradeKind.engine), 1);
      expect(w2.roster.length, 1);
      expect(w2.credits, closeTo(w.credits, 0.01));
    });

    test('오프라인 수입은 최대 2시간, 프리미엄 8시간', () {
      final w = rich(seed: 10);
      w.upgradePlanet(w.planets.first);
      final now = DateTime(2026, 1, 1, 12);
      w.savedAt = now.subtract(const Duration(hours: 10));
      final (sec, c, _) = w.offlineEarnings(now);
      expect(sec, 7200);
      expect(c, greaterThan(0));
      w.profile.premium = true;
      expect(w.offlineEarnings(now).$1, 8 * 3600);
    });

    test('업적 달성과 수령', () {
      final p = Profile();
      p.addStat('kills');
      final a = achievements.firstWhere((a) => a.id == 'first_blood');
      expect(p.claimable, contains(a));
      expect(p.claim(a), isTrue);
      expect(p.gems, a.gems);
      expect(p.claim(a), isFalse);
    });

    test('출석: 연속 출석과 끊김', () {
      final p = Profile();
      final d1 = DateTime(2026, 3, 1);
      expect(p.claimLogin(d1), loginRewards[0]);
      expect(p.pendingLogin(d1), isNull);
      expect(p.claimLogin(DateTime(2026, 3, 2)), loginRewards[1]);
      expect(p.loginStreak, 2);
      expect(p.claimLogin(DateTime(2026, 3, 5)), loginRewards[0]);
      expect(p.loginStreak, 1);
    });

    test('광고 젬은 하루 3회', () {
      final p = Profile();
      final d = DateTime(2026, 3, 1);
      for (var i = 0; i < 3; i++) {
        expect(p.claimAdGems(d), isTrue);
      }
      expect(p.claimAdGems(d), isFalse);
      expect(p.claimAdGems(DateTime(2026, 3, 2)), isTrue);
    });

    test('프로필 JSON 왕복', () {
      final p = Profile()
        ..gems = 77
        ..premium = true
        ..skin = 'gold';
      p.ownedSkins.add('gold');
      p.addStat('kills', 5);
      final q = Profile.fromJson(p.toJson());
      expect(q.gems, 77);
      expect(q.premium, isTrue);
      expect(q.ownedSkins, contains('gold'));
      expect(q.stat('kills'), 5);
    });
  });

  test('한국어 조사', () {
    expect(eul('테라노바'), '테라노바를');
    expect(eul('볼카노'), '볼카노를');
    expect(eul('헤이븐 기지'), '헤이븐 기지를');
    expect(iGa('루비아'), '루비아가');
    expect(iGa('정거장 2호'), '정거장 2호가');
    expect(iGa('뭉치'), '뭉치가');
    expect(iGa('콩이'), '콩이가');
    expect(iGa('별'), '별이');
    expect(euro('유자'), '유자로');
    expect(euro('망고별'), '망고별로');
    expect(euro('섹터 3'), '섹터 3으로');
    expect(euro('섹터 2'), '섹터 2로');
    expect(eul('⭐100'), '⭐100을');
  });

  test('두목 2페이즈: 체력 절반 이하에서 부하 소환', () {
    final w = GameWorld(seed: 21);
    final boss = Pirate(PirateKind.boss, w.player.pos + const Offset(0, -500), 100)..hp = 40;
    w.pirates.add(boss);
    final before = w.pirates.length;
    w.update(1 / 60, InputState());
    expect(boss.enraged, isTrue);
    expect(w.pirates.length, greaterThan(before));
  });

  test('튜토리얼 안내: 정착 단계에서 가까운 미정착 행성을 가리킴', () {
    final w = GameWorld(seed: 22);
    w.storyIndex = storySteps.indexWhere((s) => s.key == 'colonies');
    expect(w.storyTarget, w.planets.first.pos);
  });

  group('라운드3', () {
    test('일일 퀘스트: 날마다 3개, 진행·수령·보너스', () {
      final p = Profile();
      final d = DateTime(2026, 5, 1);
      p.refreshDaily(d);
      expect(p.dailyQuests.length, 3);
      for (final q in p.dailyQuests) {
        p.addStat(q.stat, q.target);
      }
      final before = p.gems;
      for (final q in p.dailyQuests) {
        expect(p.claimDaily(q.id), isTrue);
        expect(p.claimDaily(q.id), isFalse);
      }
      expect(p.dailyBonusReady, isTrue);
      expect(p.claimDaily('bonus'), isTrue);
      expect(p.gems, greaterThan(before + dailyBonusGems));
      // 다음 날에는 새로 뽑히고 진행도가 0부터
      p.refreshDaily(DateTime(2026, 5, 2));
      expect(p.dailyClaimed, isEmpty);
      expect(p.dailyQuests.every((q) => p.dailyProgress(q) == 0), isTrue);
    });

    test('일일 퀘스트 상태가 저장/복원된다', () {
      final p = Profile()..refreshDaily(DateTime(2026, 5, 1));
      final q = Profile.fromJson(p.toJson());
      expect(q.dailyIds, p.dailyIds);
      expect(q.dailyDay, p.dailyDay);
    });

    test('함선: 잠김/해금/교체 시 성능 반영', () {
      final w = rich(seed: 31);
      final inter = shipTypeById('interceptor');
      expect(w.switchShip(inter), isFalse);
      w.profile.maxStat('sector', 2);
      final speed = w.playerSpeed;
      expect(w.switchShip(inter), isTrue);
      expect(w.playerSpeed, greaterThan(speed));
      expect(w.player.hp, lessThanOrEqualTo(w.playerMaxHp));
    });

    test('함선 젬 구매', () {
      final w = rich(seed: 32);
      w.profile.gems = 1000;
      expect(w.buyShip(shipTypeById('phantom')), isTrue);
      expect(w.profile.shipType, 'phantom');
      expect(w.profile.gems, 1000 - shipTypeById('phantom').gemPrice);
    });

    test('전투 드론이 근처 적을 쏜다', () {
      final w = rich(seed: 33);
      w.upgradeShip(UpgradeKind.drone);
      final e = Pirate(PirateKind.scout, w.player.pos + const Offset(200, 0), 5);
      w.pirates.add(e);
      runFor(w, 3);
      expect(w.pirates.contains(e), isFalse);
    });

    test('은하 명예 보너스와 환생 조건', () {
      final w = rich(seed: 34);
      final inc = w.creditIncome;
      final dmg = w.playerDamage;
      expect(w.canAscend, isFalse);
      w.profile.honor = 4;
      expect(w.creditIncome, closeTo(inc * 1.2, 0.01));
      expect(w.playerDamage, closeTo(dmg * 1.12, 0.01));
      w.counters['maxSector'] = 3;
      expect(w.canAscend, isTrue);
      expect(w.honorGain, greaterThanOrEqualTo(1));
    });
  });

  group('버그 회귀', () {
    test('격추 상태로 저장하면 불러와도 격추 상태 (공짜 부활 방지)', () {
      final w = GameWorld(seed: 41);
      w.player.pos = const Offset(1500, 1500); // 본거지 안전 구역 밖
      w.player.hp = 1;
      w.bullets.add(Bullet(w.player.pos, Offset.zero, 50, false));
      w.update(1 / 60, InputState());
      expect(w.player.alive, isFalse);
      final w2 = GameWorld.fromJson(w.toJson(), w.profile);
      expect(w2.player.alive, isFalse);
      expect(w2.player.awaitingRevive, isTrue);
    });

    test('유성우 소행성은 맵 밖으로 나가면 사라진다', () {
      final w = GameWorld(seed: 42);
      final a = Asteroid(const Offset(GameWorld.worldHalf + 50, 0), 20, 1)
        ..drift = const Offset(500, 0);
      w.asteroids.add(a);
      runFor(w, 0.5);
      expect(w.asteroids.contains(a), isFalse);
    });

    test('임무 게시판은 비워도 타이머 전에는 다시 채워지지 않는다', () {
      final w = GameWorld(seed: 43);
      w.update(1 / 60, InputState());
      for (final m in [...w.missionOffers]) {
        w.acceptMission(m);
      }
      for (final m in [...w.activeMissions]) {
        w.abandonMission(m);
      }
      w.update(1 / 60, InputState());
      expect(w.missionOffers, isEmpty);
    });

    test('시계를 되돌려도 출석/광고 젬 중복 수령 불가', () {
      final p = Profile();
      expect(p.claimLogin(DateTime(2026, 6, 2)), greaterThan(0));
      expect(p.claimLogin(DateTime(2026, 6, 1)), 0);
      for (var i = 0; i < 3; i++) {
        p.claimAdGems(DateTime(2026, 6, 2));
      }
      expect(p.claimAdGems(DateTime(2026, 6, 1)), isFalse);
    });

    test('이전 항성계로 돌아가도 새 항성계 발전 목표가 완료되지 않는다', () {
      final w = rich(seed: 44);
      for (final p in w.planets) {
        p.colonyLevel = 3; // 발전도 100%
      }
      w.warp(w.gates.firstWhere((g) => g.forward));
      w.storyIndex = storySteps.length; // 항성계 2 발전도 단계
      w.warp(w.gates.firstWhere((g) => !g.forward));
      expect(w.development, 1);
      final (v, t) = w.storyProgress;
      expect(v < t, isTrue);
    });

    test('불러오기 후 현상수배범은 플레이어 근처에 다시 등장', () {
      final w = GameWorld(seed: 45);
      w.player.pos = const Offset(3000, 3000);
      final m = Mission(id: 77, type: MissionType.bounty, target: 1, rewardCredits: 10, bountyName: '외눈 잭');
      w.activeMissions.add(m);
      final w2 = GameWorld.fromJson(w.toJson(), w.profile);
      final b = w2.pirates.firstWhere((e) => e.missionId == 77);
      expect((b.pos - const Offset(3000, 3000)).distance, lessThan(3500));
      expect((b.pos - Offset.zero).distance, greaterThan(500));
    });
  });

  group('내 행성', () {
    test('건설·업그레이드·레벨업과 보너스 반영', () {
      final w = rich(seed: 51);
      final inc = w.creditIncome;
      final hp = w.playerMaxHp;
      expect(w.buildHome(0, BuildingType.farm), isTrue);
      expect(w.buildHome(0, BuildingType.mine), isFalse); // 이미 지어진 칸
      expect(w.buildHome(1, BuildingType.tower), isTrue);
      expect(w.creditIncome, closeTo(inc * 1.03, 0.01));
      expect(w.playerMaxHp, closeTo(hp * 1.04, 0.01));
      expect(w.upgradeHome(0), isTrue);
      expect(w.home.levelOf(BuildingType.farm), 2);
      final slots = w.home.slots.length;
      expect(w.levelUpHome(), isTrue);
      expect(w.home.slots.length, slots + 2);
    });

    test('동상은 젬으로만', () {
      final w = rich(seed: 52)..profile.gems = 0;
      expect(w.buildHome(0, BuildingType.statue), isFalse);
      w.profile.gems = 100;
      expect(w.buildHome(0, BuildingType.statue), isTrue);
      expect(w.profile.gems, 100 - w.home.statueGemCost(0));
    });

    test('행성 선물은 8시간마다', () {
      final w = rich(seed: 53);
      final now = DateTime(2026, 7, 1, 10);
      final gems = w.profile.gems;
      expect(w.harvestHome(now), isNotNull);
      expect(w.profile.gems, greaterThan(gems));
      expect(w.harvestHome(now.add(const Duration(hours: 7))), isNull);
      expect(w.harvestHome(now.add(const Duration(hours: 8))), isNotNull);
    });

    test('놀이공원은 오프라인 효율을 올린다', () {
      final w = rich(seed: 54);
      w.upgradePlanet(w.planets.first);
      final now = DateTime(2026, 7, 1, 12);
      w.savedAt = now.subtract(const Duration(hours: 1));
      final base = w.offlineEarnings(now).$2;
      w.buildHome(0, BuildingType.park);
      expect(w.offlineEarnings(now).$2, closeTo(base * 1.1, base * 0.01));
    });

    test('내 행성은 프로필에 저장되고 환생해도 유지', () {
      final w = rich(seed: 55);
      w.buildHome(2, BuildingType.lab);
      w.home
        ..name = '토끼별'
        ..palette = 3;
      final p2 = Profile.fromJson(w.profile.toJson());
      expect(p2.home.name, '토끼별');
      expect(p2.home.slots[2]?.type, BuildingType.lab);
      final w2 = GameWorld(seed: 56, profile: p2);
      expect(w2.home.levelOf(BuildingType.lab), 1);
    });
  });

  group('식민지 건물/정착 보호막', () {
    test('식민지 방어막: 탄을 대신 맞아 줄고, 깨지면 재충전 후 다시 켜진다', () {
      final w = rich(seed: 21);
      final p = w.planets.first;
      w.player.pos = p.pos + Offset(p.radius + 60, 0);
      w.upgradePlanet(p);
      final cap = p.shieldMax(w.sectorMul);
      expect(p.domeUp, isTrue);
      expect(p.shieldHp, cap);
      expect(w.shielded, isFalse); // 함선 자체 실드가 아니다
      expect(w.colonyTutorialPending, isTrue);
      // 돔 안: 탄은 돔이 대신 맞는다
      w.pirates.clear();
      final hp = w.player.hp;
      w.bullets.add(Bullet(p.pos + Offset(p.domeRadius + 40, 0), const Offset(-430, 0), 20, false));
      runFor(w, 0.5);
      expect(w.player.hp, hp);
      expect(p.shieldHp, closeTo(cap - 20, 0.01));
      // 안 맞으면 다시 찬다
      runFor(w, Planet.shieldRegenDelay + 3);
      expect(p.shieldHp, cap);
      // 해적은 돔 안으로 못 들어온다
      final e = Pirate(PirateKind.raider, p.pos + Offset(p.radius + 100, 0), 1e6);
      w.pirates.add(e);
      w.update(1 / 60, InputState());
      expect((e.pos - p.pos).distance, greaterThanOrEqualTo(p.domeRadius));
      w.pirates.clear();
      // 큰 피해로 깨지면 꺼졌다가, 대기 후 절반까지 차면 재가동
      w.bullets.add(Bullet(p.pos + Offset(p.domeRadius - 5, 0), const Offset(-100, 0), cap + 50, false));
      w.update(1 / 60, InputState());
      expect(p.domeUp, isFalse);
      expect(p.shieldBroken, isTrue);
      runFor(w, GameWorld.shieldBrokenDelay - 1);
      expect(p.domeUp, isFalse);
      runFor(w, 10);
      expect(p.domeUp, isTrue);
      // 돔 밖: 함선이 피해를 입는다
      w.player.pos = p.pos + Offset(p.domeRadius + 300, 0);
      final hp2 = w.player.hp;
      w.bullets.add(Bullet(w.player.pos + const Offset(10, 0), const Offset(-100, 0), 20, false));
      w.update(1 / 60, InputState());
      expect(w.player.hp, lessThan(hp2));
    });

    test('방어막이 버티면 습격당해도 생산이 계속되고 레벨이 안 떨어진다', () {
      final w = rich(seed: 28);
      final p = w.planets.first;
      w.upgradePlanet(p);
      w.upgradePlanet(p);
      final ev = w.startEvent(EventKind.raid)!;
      for (final e in w.pirates.where((e) => e.eventId == ev.id)) {
        e.pos = p.pos + Offset(p.domeRadius + 20, 0);
      }
      w.update(1 / 60, InputState());
      expect(p.raided, isFalse);
      ev.timeLeft = 0;
      p.shieldHp = 1e6; // 끝까지 버틴 상황
      w.update(1 / 60, InputState());
      expect(p.colonyLevel, 2);
    });

    test('방어막 발생기는 용량을 늘린다', () {
      final w = rich(seed: 29);
      final p = w.planets.first;
      w.upgradePlanet(p);
      final before = p.shieldMax(w.sectorMul);
      expect(w.buildColony(p, ColonyBuilding.shieldGen), isTrue);
      expect(p.shieldMax(w.sectorMul), before + 250);
    });

    test('두 번째 정착부터는 안내를 다시 띄우지 않는다', () {
      final w = rich(seed: 22);
      w.profile.colonyTutorialSeen = true;
      w.upgradePlanet(w.planets.first);
      expect(w.colonyTutorialPending, isFalse);
      expect(w.planets.first.domeUp, isTrue);
    });

    test('건물은 식민지 레벨까지만 지을 수 있다', () {
      final w = rich(seed: 23);
      final p = w.planets.first;
      expect(w.buildColony(p, ColonyBuilding.mine), isFalse);
      w.upgradePlanet(p);
      expect(w.buildColony(p, ColonyBuilding.mine), isTrue);
      expect(w.buildColony(p, ColonyBuilding.mine), isFalse);
      w.upgradePlanet(p);
      expect(w.buildColony(p, ColonyBuilding.mine), isTrue);
      expect(p.building(ColonyBuilding.mine), 2);
    });

    test('채굴 시설은 광석, 교역소는 크레딧 수입을 늘린다', () {
      final w = rich(seed: 24);
      final p = w.planets.first; // 정원 행성: 원래 광석 0
      w.upgradePlanet(p);
      expect(w.planetOreRate(p), 0);
      final cr = w.planetCreditRate(p);
      w.buildColony(p, ColonyBuilding.mine);
      w.buildColony(p, ColonyBuilding.trade);
      expect(w.planetOreRate(p), greaterThan(0));
      expect(w.planetCreditRate(p), closeTo(cr * 1.25, 0.001));
    });

    test('식민지 포탑이 근처 해적을 쏜다', () {
      final w = rich(seed: 25);
      final p = w.planets.first;
      w.upgradePlanet(p);
      w.buildColony(p, ColonyBuilding.turret);
      p.shieldBroken = true;
      w.player.pos = const Offset(-3000, -3000);
      w.pirates
        ..clear()
        ..add(Pirate(PirateKind.scout, p.pos + Offset(p.radius + 150, 0), 1e6));
      w.update(1 / 60, InputState());
      expect(w.bullets.where((b) => b.fromPlayer), isNotEmpty);
    });

    test('수리 도크 근처에서 체력이 찬다', () {
      final w = rich(seed: 26);
      final p = w.planets.first;
      w.upgradePlanet(p);
      w.buildColony(p, ColonyBuilding.dock);
      w.player
        ..pos = p.pos + Offset(p.radius + 80, 0)
        ..hp = 10;
      runFor(w, 1);
      expect(w.player.hp, greaterThan(20));
    });

    test('건물은 저장·섹터 이동 후에도 유지된다', () {
      final w = rich(seed: 27);
      final p = w.planets.first;
      w.upgradePlanet(p);
      w.buildColony(p, ColonyBuilding.turret);
      final w2 = GameWorld.fromJson(w.toJson(), w.profile);
      expect(w2.planets.first.building(ColonyBuilding.turret), 1);
      for (final p in w2.planets) {
        if (p.colonyLevel < 3) p.colonyLevel = 3;
      }
      w2.warp(w2.gates.firstWhere((g) => g.forward));
      w2.warp(w2.gates.firstWhere((g) => !g.forward));
      expect(w2.planets.first.building(ColonyBuilding.turret), 1);
    });
  });

  group('본거지(헤이븐 기지) 방어', () {
    test('안전 구역 안에서는 함선이 피해를 입지 않고 해적 탄이 사라진다', () {
      final w = GameWorld(seed: 31);
      w.player.pos = w.homeBase.pos + const Offset(0, 200);
      final hp = w.player.hp;
      w.bullets.add(Bullet(w.player.pos + const Offset(30, 0), const Offset(-400, 0), 50, false));
      runFor(w, 0.5);
      expect(w.player.hp, hp);
      expect(w.bullets.where((b) => !b.fromPlayer), isEmpty);
    });

    test('레이저가 범위 안 일반 해적을 터뜨리고, 두목은 조금씩 깎는다', () {
      final w = GameWorld(seed: 32);
      w.pirates.clear();
      final scout = Pirate(PirateKind.raider, w.homeBase.pos + const Offset(600, 0),
          Pirate.baseHp(PirateKind.raider));
      final boss = Pirate(PirateKind.boss, w.homeBase.pos + const Offset(0, 850), 1000);
      w.pirates.addAll([scout, boss]);
      runFor(w, 1.0);
      expect(w.pirates.contains(scout), isFalse);
      expect(w.counter('kills'), greaterThanOrEqualTo(1));
      expect(boss.hp, lessThan(1000));
      expect(boss.hp, greaterThan(0));
      expect(w.beams, isNotEmpty);
    });

    test('범위 밖 해적은 건드리지 않는다', () {
      final w = GameWorld(seed: 33);
      w.pirates.clear();
      final far = Pirate(PirateKind.scout, w.homeBase.pos + const Offset(2500, 0), 30);
      w.pirates.add(far);
      w.update(1 / 60, InputState());
      expect(far.hp, 30);
    });
  });

  group('공전', () {
    test('행성은 항성을 돌고, 세계 밖으로 안 나가고, 서로 겹치지 않는다', () {
      final w = GameWorld(seed: 51);
      final start = w.planets.first.pos;
      for (var t = 0.0; t < 2400; t += 7) {
        w.sectorElapsed = t;
        for (final p in w.planets) {
          p.placeOnOrbit(t);
          expect(p.pos.dx.abs() + p.radius, lessThan(GameWorld.worldHalf));
          expect(p.pos.dy.abs() + p.radius, lessThan(GameWorld.worldHalf));
          expect((p.pos - GameWorld.homePos).distance, greaterThan(p.radius + 150), reason: '본거지와 겹침');
        }
        for (var i = 0; i < w.planets.length; i++) {
          for (var j = i + 1; j < w.planets.length; j++) {
            final a = w.planets[i], b = w.planets[j];
            expect((a.pos - b.pos).distance, greaterThan(a.radius + b.radius), reason: '${a.name}-${b.name} t=$t');
          }
        }
      }
      w.planets.first.placeOnOrbit(60);
      expect(w.planets.first.pos, isNot(start));
    });

    test('저장 후 불러와도 행성 위치가 같다', () {
      final w = GameWorld(seed: 52);
      runFor(w, 30);
      final w2 = GameWorld.fromJson(w.toJson(), w.profile);
      for (var i = 0; i < w.planets.length; i++) {
        expect((w2.planets[i].pos - w.planets[i].pos).distance, lessThan(1));
        expect(w2.planets[i].name, w.planets[i].name);
      }
    });

    test('예전 저장의 원점 본거지는 새 본거지 자리로 옮긴다', () {
      final w = GameWorld(seed: 53);
      final j = w.toJson();
      ((j['current'] as Map)['stations'] as List).first
        ..['x'] = 0.0
        ..['y'] = 0.0;
      final w2 = GameWorld.fromJson(j, w.profile);
      expect(w2.homeBase.pos, GameWorld.homePos);
    });
  });

  test('떨어진 코인은 일정 시간 뒤 사라진다', () {
    final w = GameWorld(seed: 61);
    w.pickups
      ..clear()
      ..add(Pickup(PickupKind.credits, const Offset(-3000, -3000), 10, Offset.zero));
    runFor(w, Pickup.lifetime - 1);
    expect(w.pickups.where((k) => k.kind == PickupKind.credits), isNotEmpty);
    runFor(w, 2);
    expect(w.pickups.where((k) => k.kind == PickupKind.credits && k.pos == const Offset(-3000, -3000)), isEmpty);
  });

  group('정거장 역할 / 항성계 발전', () {
    GameWorld farFromHome(int seed) {
      final w = rich(seed: seed);
      // 지을 수 있는 빈 자리를 찾는다 (항성·본거지·게이트·행성 현재 위치와 떨어진 곳)
      for (var y = -3400.0; y <= 3400; y += 200) {
        for (var x = -3400.0; x <= 3400; x += 200) {
          w.player.pos = Offset(x, y);
          if (w.canBuildStationHere) return w;
        }
      }
      fail('지을 자리가 없음');
    }

    test('역할을 골라 짓고, 본거지 역할은 지을 수 없다', () {
      final w = farFromHome(71);
      expect(w.canBuildStationHere, isTrue);
      expect(w.buildStation(StationRole.home), isFalse);
      expect(w.buildStation(StationRole.defense), isTrue);
      final s = w.stations.last;
      expect(s.role, StationRole.defense);
      expect(s.turretLevel, 1);
      expect(s.maxHp, (200 + 100) * 2);
    });

    test('방어 기지는 근처 적 탄을 막는다', () {
      final w = farFromHome(72);
      w.buildStation(StationRole.defense);
      final s = w.stations.last;
      w.bullets.add(Bullet(s.pos + const Offset(100, 0), Offset.zero, 10, false));
      w.update(1 / 60, InputState());
      expect(w.bullets.where((b) => !b.fromPlayer), isEmpty);
    });

    test('수리 기지: 넓은 범위 수리, 재출격 비용 10%', () {
      final w = farFromHome(73);
      w.buildStation(StationRole.repair);
      final s = w.stations.last;
      w.player
        ..pos = s.pos + const Offset(500, 0)
        ..hp = 10;
      runFor(w, 1);
      expect(w.player.hp, greaterThan(50));
      expect(GameWorld.respawnCostRatio(s), 0.10);
      expect(GameWorld.respawnCostRatio(w.homeBase), 0.25);
    });

    test('보급 기지는 근처 식민지 생산을 늘린다', () {
      final w = farFromHome(74);
      final p = w.planets.first;
      w.upgradePlanet(p);
      final before = w.planetCreditRate(p);
      w.stations.add(Station('보급', p.pos + const Offset(400, 0), role: StationRole.support));
      expect(w.planetCreditRate(p), closeTo(before * 1.25, 0.001));
    });

    test('예전 저장의 역할 없는 정거장은 보급 기지로 불러온다', () {
      final w = farFromHome(75);
      expect(w.buildStation(StationRole.repair), isTrue);
      final j = w.toJson();
      for (final st in ((j['current'] as Map)['stations'] as List)) {
        (st as Map).remove('role');
      }
      final w2 = GameWorld.fromJson(j, w.profile);
      expect(w2.homeBase.role, StationRole.home);
      expect(w2.stations.last.role, StationRole.support);
    });

    test('발전도: 행성마다 Lv.3까지 계산, 100%면 게이트 열림 알림', () {
      final w = rich(seed: 76);
      expect(w.development, 0);
      w.planets.first.colonyLevel = 5;
      expect(w.development, closeTo(1 / w.planets.length, 1e-9));
      for (final p in w.planets) {
        p.colonyLevel = 3;
      }
      runFor(w, 1);
      expect(w.dialogs.any((d) => d.text.contains('다음 항성계')), isTrue);
      expect(w.gateOpen(w.gates.firstWhere((g) => g.forward)), isTrue);
    });
  });

  group('프리미엄 함선', () {
    final premiums = shipTypes.where((t) => t.premium).toList();

    test('프리미엄 함선은 통계로 해금되지 않고 젬으로만 산다', () {
      expect(premiums.map((t) => t.id), containsAll(['nova', 'aurora']));
      final w = rich(seed: 81);
      for (final k in ['sector', 'bosses', 'ore', 'kills']) {
        w.profile.maxStat(k, 1 << 30);
      }
      for (final t in premiums) {
        expect(w.profile.shipUnlocked(t), isFalse, reason: t.id);
        expect(w.switchShip(t), isFalse, reason: t.id);
      }
      w.profile.gems = premiums.first.gemPrice - 1;
      expect(w.buyShip(premiums.first), isFalse);
      expect(w.profile.gems, premiums.first.gemPrice - 1);

      w.profile.gems = 2000;
      final nova = shipTypeById('nova');
      expect(w.buyShip(nova), isTrue);
      expect(w.profile.shipType, 'nova');
      expect(w.profile.gems, 2000 - nova.gemPrice);
      expect(w.profile.shipUnlocked(nova), isTrue);
      expect(w.buyShip(nova), isFalse); // 중복 구매 불가
      final q = Profile.fromJson(w.profile.toJson());
      expect(q.ownedShips, contains('nova'));
    });

    GameWorld farWorld(int seed) {
      final w = rich(seed: seed);
      w.player.pos = const Offset(1500, 1500); // 본거지 안전 구역 밖
      w.pirates.clear();
      return w;
    }

    /// 플레이어 쪽으로 날아오는 아군 탄 하나와, 그 길목에 일렬로 선 해적 둘
    (Pirate, Pirate) lineUp(GameWorld w, int pierce) {
      final p = w.player.pos;
      final a = Pirate(PirateKind.raider, p + const Offset(0, 240), 1e5);
      final b = Pirate(PirateKind.raider, p + const Offset(0, 180), 1e5);
      w.pirates.addAll([a, b]);
      w.bullets.add(Bullet(p + const Offset(0, 300), const Offset(0, -760), 7, true, pierce: pierce));
      runFor(w, 0.2);
      return (a, b);
    }

    test('노바 드래곤: 탄 하나가 일렬의 적 둘을 꿰뚫는다', () {
      expect(shipTypeById('nova').pierce, 1);
      final w = farWorld(82);
      final (a, b) = lineUp(w, 1);
      expect(a.hp, lessThan(a.maxHp));
      expect(b.hp, lessThan(b.maxHp));
      expect(a.maxHp - a.hp, closeTo(7, 1e-9)); // 같은 적을 두 번 맞히지 않는다

      // 관통 없는 탄은 첫 적에서 멈춘다
      final w2 = farWorld(83);
      final (c, d) = lineUp(w2, 0);
      expect(c.hp, lessThan(c.maxHp));
      expect(d.hp, d.maxHp);
    });

    test('노바 드래곤이 쏜 탄에 관통이 실린다', () {
      final w = farWorld(84)..profile.ownedShips.add('nova');
      expect(w.switchShip(shipTypeById('nova')), isTrue);
      runFor(w, 0.1, InputState()..fire = true);
      expect(w.bullets.where((b) => b.fromPlayer && b.pierce == 1), isNotEmpty);
    });

    test('오로라: 수호막이 피격 1회를 막고 재충전된다', () {
      final w = farWorld(85)..profile.ownedShips.add('aurora');
      final aurora = shipTypeById('aurora');
      expect(w.switchShip(aurora), isTrue);
      w.player.hp = w.playerMaxHp;
      expect(w.guardReady, isTrue);
      final hp = w.player.hp;
      w.bullets.add(Bullet(w.player.pos, Offset.zero, 30, false));
      w.update(1 / 60, InputState());
      expect(w.player.hp, hp);
      expect(w.guardReady, isFalse);
      expect(w.player.guardCooldown, closeTo(aurora.guardInterval, 0.05));

      w.bullets.add(Bullet(w.player.pos, Offset.zero, 30, false));
      w.update(1 / 60, InputState());
      expect(w.player.hp, lessThan(hp));

      w.player.guardCooldown = 0.01;
      w.update(1 / 60, InputState());
      expect(w.guardReady, isTrue);
    });

    test('오로라: 피격 없이 3초가 지나면 자가 수리', () {
      final w = farWorld(86)..profile.ownedShips.add('aurora');
      expect(w.switchShip(shipTypeById('aurora')), isTrue);
      final max = w.playerMaxHp;
      w.player
        ..hp = max * 0.5
        ..sinceHit = 0;
      runFor(w, 2.5);
      expect(w.player.hp, closeTo(max * 0.5, 1e-6)); // 대기 중엔 회복 없음
      runFor(w, 2);
      expect(w.player.hp, greaterThan(max * 0.5 + max * 0.03 * 1.3));
      expect(w.player.hp, lessThanOrEqualTo(max));

      // 다른 함선은 자가 수리가 없다
      final s = farWorld(87);
      s.player
        ..hp = s.playerMaxHp * 0.5
        ..sinceHit = 10;
      runFor(s, 1);
      expect(s.player.hp, closeTo(s.playerMaxHp * 0.5, 1e-6));
    });
  });

  group('본거지 강화·내구도', () {
    test('안전 구역에 들어온 해적 탄은 본거지가 대신 맞는다', () {
      final w = GameWorld(seed: 81);
      w.pirates.clear();
      final hb = w.homeBase;
      expect(hb.hp, hb.maxHp);
      w.player.pos = hb.pos + const Offset(0, 200);
      final php = w.player.hp;
      w.bullets.add(Bullet(w.player.pos + const Offset(30, 0), const Offset(-400, 0), 50, false));
      w.update(1 / 60, InputState());
      expect(w.player.hp, php);
      expect(hb.hp, closeTo(hb.maxHp - 50, 1e-6));
      expect(w.bullets.where((b) => !b.fromPlayer), isEmpty);
    });

    test('내구도 0이면 기능 정지: 함선이 피해를 입고 레이저가 멈춘다', () {
      final w = GameWorld(seed: 82);
      w.pirates.clear();
      final hb = w.homeBase;
      hb.hp = 10;
      w.bullets.add(Bullet(hb.pos + const Offset(100, 0), Offset.zero, 50, false));
      w.update(1 / 60, InputState());
      expect(hb.disabled, isTrue);
      expect(hb.hp, 0);
      expect(w.dialogs.any((d) => d.text.contains('기능 정지')), isTrue);
      w.player
        ..pos = hb.pos + const Offset(0, 200)
        ..invulnerable = 0;
      expect(w.inHaven(w.player.pos), isFalse);
      final php = w.player.hp;
      w.bullets.add(Bullet(w.player.pos + const Offset(10, 0), Offset.zero, 5, false));
      final e = Pirate(PirateKind.scout, hb.pos + const Offset(-600, 0), 30);
      w.pirates.add(e);
      w.beams.clear();
      w.update(1 / 60, InputState());
      expect(w.player.hp, lessThan(php));
      expect(e.hp, 30);
      expect(w.beams, isEmpty);
    });

    test('정지 시간이 지나면 30% 내구도로 재가동한다', () {
      final w = GameWorld(seed: 83);
      w.pirates.clear();
      final hb = w.homeBase;
      hb.hp = 0;
      w.update(1 / 60, InputState());
      expect(hb.disabled, isTrue);
      runFor(w, GameWorld.baseDisableTime - 1);
      expect(hb.disabled, isTrue);
      runFor(w, 1.5);
      expect(hb.disabled, isFalse);
      expect(hb.hp, greaterThanOrEqualTo(hb.maxHp * GameWorld.baseRebootRatio * 0.9));
      expect(w.dialogs.any((d) => d.text.contains('재가동')), isTrue);
    });

    test('피격이 멈추면 서서히 재생한다', () {
      final w = GameWorld(seed: 84);
      w.pirates.clear();
      final hb = w.homeBase..hp = 100;
      hb.takeHit(0);
      runFor(w, Station.regenDelay - 0.5);
      expect(hb.hp, 100);
      runFor(w, 2);
      expect(hb.hp, greaterThan(100));
    });

    test('강화: 비용이 가파르게 오르고 능력치가 오른다, Lv.10에서 멈춤', () {
      final w = rich(seed: 85);
      final hb = w.homeBase;
      final c1 = w.baseUpgradeCost(hb);
      final dmg = hb.laserDamage, range = hb.laserRange, hp = hb.maxHp, r = hb.safeRadius;
      final iv = hb.laserInterval;
      final credits = w.credits;
      expect(w.upgradeBase(hb), isTrue);
      expect(hb.baseLevel, 2);
      expect(w.credits, credits - c1.$1);
      expect(hb.laserDamage, greaterThan(dmg));
      expect(hb.laserRange, greaterThan(range));
      expect(hb.maxHp, greaterThan(hp));
      expect(hb.safeRadius, greaterThan(r));
      expect(hb.laserInterval, lessThan(iv));
      expect(hb.hp, hb.maxHp);
      final c2 = w.baseUpgradeCost(hb);
      expect(c2.$1, greaterThan(c1.$1 * 1.5));
      while (hb.baseLevel < Station.maxBaseLevel) {
        expect(w.upgradeBase(hb), isTrue);
      }
      expect(w.upgradeBase(hb), isFalse);
      // 일반 정거장은 본거지 강화 불가
      final poor = GameWorld(seed: 86);
      expect(poor.upgradeBase(poor.homeBase), isFalse);
    });

    test('저장/불러오기: 강화 단계 유지, 예전 저장은 Lv.1', () {
      final w = rich(seed: 87);
      w.upgradeBase(w.homeBase);
      w.upgradeBase(w.homeBase);
      final j = w.toJson();
      final w2 = GameWorld.fromJson(j, w.profile);
      expect(w2.homeBase.baseLevel, 3);
      expect(w2.homeBase.hp, w2.homeBase.maxHp);
      for (final st in ((j['current'] as Map)['stations'] as List)) {
        (st as Map).remove('base');
      }
      final w3 = GameWorld.fromJson(j, w.profile);
      expect(w3.homeBase.baseLevel, 1);
    });

    test('알파 성역 Lv.1 레이저는 정찰기·약탈선을 한 방에, 후반 섹터 약탈선은 못 잡는다', () {
      final w = GameWorld(seed: 88);
      w.pirates.clear();
      final hb = w.homeBase;
      final scout = Pirate(PirateKind.scout, hb.pos + const Offset(600, 0), Pirate.baseHp(PirateKind.scout) * 1.6);
      w.pirates.add(scout);
      w.update(1 / 60, InputState());
      expect(w.pirates.contains(scout), isFalse);
      // 위협 5 정도의 알파 성역 약탈선 (체력 x1.6)
      final raider = Pirate(PirateKind.raider, hb.pos + const Offset(600, 0), Pirate.baseHp(PirateKind.raider) * 1.6);
      w.pirates.add(raider);
      runFor(w, hb.laserInterval + 0.05);
      expect(w.pirates.contains(raider), isFalse);
      // 섹터 4급 약탈선 (sectorMul 3) 은 Lv.1 한 방으로는 안 죽는다
      final tough = Pirate(PirateKind.raider, hb.pos + const Offset(600, 0), Pirate.baseHp(PirateKind.raider) * 3);
      w.pirates.add(tough);
      runFor(w, hb.laserInterval + 0.05);
      expect(tough.hp, greaterThan(0));
      expect(tough.hp, lessThan(tough.maxHp));
    });
  });
  group('유료 승무원·슬롯', () {
    test('확률표: 합 100%, ★4는 고급(젬) 영입에만', () {
      expect(CrewMember.creditOdds.values.reduce((a, b) => a + b), 100);
      expect(CrewMember.gemOdds.values.reduce((a, b) => a + b), 100);
      expect(CrewMember.creditOdds.containsKey(4), isFalse);
      expect(CrewMember.gemOdds[4], greaterThan(0));
      expect(CrewMember.oddsText(CrewMember.gemOdds), contains('★★★★ ${CrewMember.gemOdds[4]}%'));
    });

    test('일반 영입은 ★4가 나오지 않는다', () {
      final r = Random(90);
      for (var i = 0; i < 2000; i++) {
        expect(CrewMember.random(r, i, odds: CrewMember.creditOdds).rarity, lessThanOrEqualTo(3));
      }
    });

    test('★4 보너스는 ★3보다 강하다', () {
      CrewMember m(int r) => CrewMember(id: 1, name: '뭉치', role: CrewRole.gunner, rarity: r, lookSeed: 5);
      expect(m(4).bonusPct, 20);
      expect(m(4).bonusPct, greaterThan(m(3).bonusPct));
      expect(m(4).levelUpCost, greaterThan(m(3).levelUpCost));
      expect(m(4).displayName, endsWith('뭉치'));
      expect(m(4).displayName, isNot('뭉치'));
      expect(m(3).displayName, '뭉치');
    });

    test('전설 확정 모집: 젬 차감 + ★4 지급', () {
      final w = rich(seed: 91)..profile.gems = GameWorld.legendaryGemCost - 1;
      expect(w.recruitLegendary(), isNull);
      w.profile.gems = GameWorld.legendaryGemCost + 10;
      final c = w.recruitLegendary();
      expect(c, isNotNull);
      expect(c!.rarity, 4);
      expect(w.roster, contains(c));
      expect(w.profile.gems, 10);
      expect(w.profile.stat('crew3'), 1);
    });

    test('배치 슬롯: 가격이 오르고 3개까지', () {
      final w = rich(seed: 92)..profile.gems = 10000;
      expect(w.crewSlots, 3);
      final paid = <int>[];
      while (true) {
        final price = w.profile.nextCrewSlotPrice;
        final before = w.profile.gems;
        if (!w.profile.buyCrewSlot()) break;
        expect(before - w.profile.gems, price);
        paid.add(price!);
      }
      expect(paid, Profile.crewSlotPrices);
      expect(paid[1], greaterThan(paid[0]));
      expect(paid[2], greaterThan(paid[1]));
      expect(w.crewSlots, 6);
      expect(w.profile.nextCrewSlotPrice, isNull);
      expect(w.profile.gems, 10000 - 650);
    });

    test('정원 확장: +4씩 최대 24', () {
      final w = rich(seed: 93)..profile.gems = 10000;
      expect(w.rosterCap, 12);
      for (var i = 0; i < 5; i++) {
        w.profile.buyRosterPack();
      }
      expect(w.rosterCap, 24);
      expect(w.profile.gems, 10000 - Profile.rosterPackPrice * 3);
      for (var i = 0; i < 30; i++) {
        w.recruitWithCredits();
      }
      expect(w.roster.length, 24);
      expect(w.recruitWithCredits(), isNull);
    });

    test('예전 저장의 extraCrewSlot(true)는 슬롯 1개로', () {
      final j = Profile().toJson()
        ..remove('slots')
        ..remove('rosterPacks')
        ..['slot'] = true;
      expect(Profile.fromJson(j).extraCrewSlots, 1);
      j['slot'] = false;
      expect(Profile.fromJson(j).extraCrewSlots, 0);
      expect(Profile.fromJson(j).rosterPacks, 0);
    });

    test('프로필 JSON 왕복: 슬롯·정원', () {
      final p = Profile()
        ..extraCrewSlots = 2
        ..rosterPacks = 3;
      final q = Profile.fromJson(p.toJson());
      expect(q.extraCrewSlots, 2);
      expect(q.rosterPacks, 3);
    });

    test('★4 승무원은 월드 저장 왕복 후에도 ★4', () {
      final w = rich(seed: 94)..profile.gems = 1000;
      w.recruitLegendary();
      final w2 = GameWorld.fromJson(w.toJson(), w.profile);
      expect(w2.roster.single.rarity, 4);
    });
  });

  test('자석 업그레이드: 더 멀리 있는 코인을 끌어온다', () {
    double collectFrom(int magnetLv) {
      final w = rich(seed: 81);
      w.levels[UpgradeKind.magnet] = magnetLv;
      w.player.pos = const Offset(-3000, -3000);
      w.pirates.clear();
      final c0 = w.credits;
      w.pickups
        ..clear()
        ..add(Pickup(PickupKind.credits, w.player.pos + const Offset(320, 0), 100, Offset.zero));
      runFor(w, 3);
      return w.credits - c0 - w.creditIncome * 3;
    }

    expect(collectFrom(0), lessThan(50)); // 기본 범위(170) 밖
    expect(collectFrom(3), greaterThan(90)); // 170 + 180 = 350 안
    final w = rich(seed: 82);
    expect(UpgradeKind.magnet.maxLevel, 5);
    final c = w.upgradeCost(UpgradeKind.magnet);
    expect(w.upgradeShip(UpgradeKind.magnet), isTrue);
    expect(w.upgradeCost(UpgradeKind.magnet).$1, greaterThan(c.$1));
  });

  test('위협도는 시간으로 끝없이 오르지 않는다', () {
    final w = GameWorld(seed: 91);
    w.sectorElapsed = 60 * 60 * 5; // 5시간
    expect(w.threat, lessThanOrEqualTo(1 + GameWorld.threatTimeCap + 0.01));
  });

  test('본거지 기능 정지·체력은 저장되고 불러와도 그대로', () {
    final w = GameWorld(seed: 92);
    w.homeBase
      ..disabledTime = 12
      ..hp = 0;
    final w2 = GameWorld.fromJson(w.toJson(), w.profile);
    expect(w2.homeBase.disabled, isTrue);
    expect(w2.homeBase.disabledTime, closeTo(12, 0.01));
    expect(w2.inHaven(w2.homeBase.pos), isFalse);
  });
}
