import 'dart:convert';
import 'dart:ui' show Locale, Offset;

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/home.dart';
import 'package:star_settlers/game/missions.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart';

final ko = lookupL10n(const Locale('ko'));
final en = lookupL10n(const Locale('en'));
final ja = lookupL10n(const Locale('ja'));

/// 저장 문자열을 거친 왕복 (실제 저장과 같은 JSON 인코딩)
Map<String, dynamic> roundTrip(Map<String, dynamic> j) =>
    jsonDecode(jsonEncode(j)) as Map<String, dynamic>;

Mission bountyMission(int id, int bountyId) =>
    Mission(id: id, type: MissionType.bounty, target: 1, rewardCredits: 10, bountyId: bountyId);

void main() {
  tearDown(() => Lang.apply('ko'));

  test('한국어로 만든 정거장·현상수배·행성 이름이 영어로 바꾸면 영어로 보인다', () {
    Lang.apply('ko');
    final w = GameWorld(seed: 3)
      ..credits = 1e6
      ..ore = 1e6;
    final home = w.stations.first;
    expect(home.name, ko.g_stationHaven);
    final m = bountyMission(901, 4);
    w.activeMissions.add(m);
    expect(m.bountyName, ko.g_bounty4);
    expect(w.planets.first.name, ko.cat_mars);
    final st = Station.named(const StationName.numbered(StationRole.defense, 2), const Offset(10, 10),
        role: StationRole.defense);
    expect(st.name, ko.g_stationNumbered(ko.g_stationRoleDefense, 2));

    Lang.apply('en');
    expect(home.name, en.g_stationHaven);
    expect(home.name, 'Haven Base');
    expect(m.bountyName, en.g_bounty4);
    expect(m.title(w.planets), en.g_missionBounty(en.g_bounty4));
    expect(w.planets.first.name, en.cat_mars);
    expect(st.name, en.g_stationNumbered(en.g_stationRoleDefense, 2));

    // 저장 → (영어로) 불러오기: 여전히 영어
    final w2 = GameWorld.fromJson(roundTrip(w.toJson()), w.profile);
    expect(w2.stations.first.name, en.g_stationHaven);
    expect(w2.activeMissions.single.bountyName, en.g_bounty4);
    final bountyPirate = w2.pirates.firstWhere((e) => e.missionId == 901);
    expect(bountyPirate.name, en.g_bounty4);
    // 다시 한국어로 바꾸면 해적 이름표도 따라간다
    Lang.apply('ko');
    expect(bountyPirate.name, ko.g_bounty4);
    expect(w2.stations.first.name, ko.g_stationHaven);
  });

  test('항성계 전진기지 이름도 언어를 따라간다', () {
    Lang.apply('ko');
    const label = StationName.outpost(1);
    final koText = label.text;
    Lang.apply('en');
    expect(label.text, isNot(koText));
    expect(label.text, endsWith('Outpost'));
  });

  test('예전 저장(한국어 문자열 이름)을 영어로 불러와도 영어 이름이 된다', () {
    Lang.apply('ko');
    final w = GameWorld(seed: 5);
    w.activeMissions.add(bountyMission(902, 7));
    final j = roundTrip(w.toJson());

    // 예전 형식으로 되돌린다: 키 없이 저장 당시(한국어) 문자열만
    final current = j['current'] as Map<String, dynamic>;
    final stations = (current['stations'] as List).cast<Map<String, dynamic>>();
    for (final s in stations) {
      s.remove('nk');
    }
    stations.first['name'] = '헤이븐 기지';
    stations.add({
      'name': ko.g_stationNumbered(ko.g_stationRoleDefense, 2),
      'x': 400.0, 'y': 400.0, 'hab': 1, 'tur': 1, 'role': 'defense', 'hp': 100.0,
    });
    stations.add({
      'name': ja.g_stationNumbered(ja.g_stationRoleRepair, 3), // 일본어로 저장된 것도
      'x': 600.0, 'y': 600.0, 'hab': 1, 'tur': 0, 'role': 'repair',
    });
    stations.add({
      'name': '알 수 없는 이름', // 어느 언어와도 안 맞는 이름 → 기본 키
      'x': 800.0, 'y': 800.0, 'hab': 1, 'tur': 0, 'role': 'support',
    });
    final missions = (j['missions'] as List).cast<Map<String, dynamic>>();
    missions.single
      ..remove('bid')
      ..['bounty'] = '붉은 수염 토토';
    // 문자열로 저장했다가 다시 읽는 실제 경로
    final raw = jsonEncode(j);

    Lang.apply('en');
    final w2 = GameWorld.fromJson(jsonDecode(raw) as Map<String, dynamic>, w.profile);
    expect(w2.stations[0].name, en.g_stationHaven);
    expect(w2.stations[1].name, en.g_stationNumbered(en.g_stationRoleDefense, 2));
    expect(w2.stations[2].name, en.g_stationNumbered(en.g_stationRoleRepair, 3));
    expect(w2.stations[3].name, en.g_stationNumbered(en.g_stationRoleSupport, 4));
    final idx = [for (var i = 0; i < bountyCount; i++) bountyNameOf(i, ko)].indexOf('붉은 수염 토토');
    expect(idx, greaterThanOrEqualTo(0));
    expect(w2.activeMissions.single.bountyName, bountyNameOf(idx, en));
    expect(w2.activeMissions.single.bountyId, idx);

    // 다시 저장하면 새 형식 키가 붙는다
    final again = roundTrip(w2.toJson());
    final st0 = ((again['current'] as Map)['stations'] as List).first as Map;
    expect(st0['nk'], {'k': 'haven'});
    expect((again['missions'] as List).single['bid'], idx);
  });

  test('예전 저장의 모르는 현상수배범 이름·본거지 이름은 기본 키로, 터지지 않는다', () {
    Lang.apply('en');
    final m = Mission.fromJson({
      'id': 1, 'type': MissionType.bounty.index, 'target': 1, 'rc': 5, 'rg': 0,
      'planet': null, 'bounty': '???', 'progress': 0,
    });
    expect(m.bountyId, 0);
    expect(m.bountyName, en.g_bounty0);

    final kill = Mission.fromJson({
      'id': 2, 'type': MissionType.kill.index, 'target': 3, 'rc': 5, 'rg': 0,
      'planet': null, 'bounty': null, 'progress': 1,
    });
    expect(kill.bountyName, isNull);

    expect(StationName.fromLegacy('Some Base', role: StationRole.home, sector: 0, fallbackNumber: 1).kind,
        StationNameKind.haven);
    final outpost = StationName.fromLegacy('前哨', role: StationRole.home, sector: 2, fallbackNumber: 1);
    expect(outpost.kind, StationNameKind.outpost);
    expect(outpost.sector, 2);
    expect(StationName.fromLegacy(null, role: StationRole.support, sector: 0, fallbackNumber: 5).number, 5);
    expect(StationName.fromJson({'k': 'nope'}), isNull);
  });
  test('내 행성 기본 이름은 언어를 따라가고, 바꾼 이름은 그대로 남는다', () {
    Lang.apply('ko');
    final h = HomePlanet();
    expect(h.name, ko.g_homeDefaultName);
    expect(h.hasCustomName, isFalse);
    // 기본 이름은 저장하지 않는다
    final saved = roundTrip(h.toJson());
    expect(saved.containsKey('name'), isFalse);

    Lang.apply('en');
    expect(h.name, en.g_homeDefaultName);
    expect(HomePlanet.fromJson(saved).name, en.g_homeDefaultName);

    // 예전 저장: 어느 언어든 기본 이름 문자열이면 기본으로 본다
    for (final t in [ko, ja, lookupL10n(const Locale('ru'))]) {
      final old = HomePlanet.fromJson({'name': t.g_homeDefaultName});
      expect(old.hasCustomName, isFalse, reason: t.g_homeDefaultName);
      expect(old.name, en.g_homeDefaultName);
    }
    Lang.apply('ja');
    expect(HomePlanet.fromJson({'name': ko.g_homeDefaultName}).name, ja.g_homeDefaultName);
    // 이름이 없거나 비어 있어도 기본
    expect(HomePlanet.fromJson({}).name, ja.g_homeDefaultName);
    expect(HomePlanet.fromJson({'name': ''}).name, ja.g_homeDefaultName);
  });

  test('직접 붙인 내 행성 이름은 언어를 바꾸고 저장해도 유지된다', () {
    Lang.apply('ko');
    final h = HomePlanet()..name = '  별빛마을 ';
    expect(h.name, '별빛마을');
    expect(h.hasCustomName, isTrue);
    final saved = roundTrip(h.toJson());
    expect(saved['name'], '별빛마을');

    Lang.apply('en');
    expect(h.name, '별빛마을');
    final loaded = HomePlanet.fromJson(saved);
    expect(loaded.name, '별빛마을');
    expect(loaded.hasCustomName, isTrue);

    // 다시 기본 이름(다른 언어 것이라도)으로 바꾸면 언어를 따라간다
    loaded.name = ko.g_homeDefaultName;
    expect(loaded.hasCustomName, isFalse);
    expect(loaded.name, en.g_homeDefaultName);
  });
}
