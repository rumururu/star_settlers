import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart' show keyHint, tr;
import 'package:star_settlers/services/audio.dart';
import 'package:star_settlers/ui/common.dart';

void runFor(GameWorld w, double sec) {
  final i = InputState();
  for (var t = 0.0; t < sec; t += 1 / 60) {
    w.update(1 / 60, i);
  }
}

/// 그려진 문단의 각 줄이 시작하는 글자 위치
List<int> lineStarts(RenderParagraph p, int length) {
  // 글자 위치마다 커서의 y를 보고, y가 바뀌는 곳이 새 줄의 시작
  final starts = <int>[0];
  var lastY = p.getOffsetForCaret(const TextPosition(offset: 0), Rect.zero).dy;
  for (var i = 1; i < length; i++) {
    final y = p.getOffsetForCaret(TextPosition(offset: i), Rect.zero).dy;
    if (y > lastY + 0.5) starts.add(i);
    lastY = y;
  }
  return starts;
}

Future<RenderParagraph> layoutNarrow(WidgetTester tester, String text, double width) async {
  await tester.pumpWidget(Directionality(
    textDirection: TextDirection.ltr,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: Text(text, style: const TextStyle(fontSize: 16))),
    ),
  ));
  return tester.renderObject<RenderParagraph>(find.byType(RichText));
}

void main() {
  group('한국어 어절 단위 줄바꿈 (keepAll)', () {
    const sentence = '되돌릴 수 없어요. 젬과 진행 상황은 영구히 삭제돼요. 정말 초기화할까요?';

    testWidgets('좁은 칸에서도 띄어쓰기에서만 줄이 바뀐다', (tester) async {
      final text = keepAll(sentence, ko: true);
      expect(text.replaceAll(wordJoiner, ''), sentence);
      // 가장 긴 어절("초기화할까요?" 7글자 = 112px)보다 넓은 칸들. 더 좁으면 어떤 방법으로도 단어를 쪼갤 수밖에 없다.
      for (final width in [120.0, 150.0, 200.0, 260.0]) {
        final p = await layoutNarrow(tester, text, width);
        final starts = lineStarts(p, text.length);
        expect(starts.length, greaterThan(1), reason: '폭 $width에서 여러 줄이어야 검사가 의미 있다');
        for (final s in starts.where((s) => s > 0)) {
          expect(text[s - 1], ' ', reason: '폭 $width: "${text.substring(0, s)}|${text.substring(s)}" 단어 중간에서 끊김');
        }
      }
    });

    testWidgets('단어 결합 문자는 폭을 차지하지 않는다', (tester) async {
      final plain = await layoutNarrow(tester, '진행 상황', 1000);
      final w0 = plain.size.width;
      final joined = await layoutNarrow(tester, keepAll('진행 상황', ko: true), 1000);
      expect(joined.size.width, w0);
    });

    testWidgets('대조: keepAll 없이는 단어 중간에서 끊긴다', (tester) async {
      final p = await layoutNarrow(tester, sentence, 120);
      final starts = lineStarts(p, sentence.length);
      expect(starts.where((s) => s > 0 && sentence[s - 1] != ' '), isNotEmpty);
    });

    test('한국어가 아니면 그대로', () {
      expect(keepAll('Reset all data', ko: false), 'Reset all data');
      expect(keepAll('정말 초기화할까요?', ko: false), '정말 초기화할까요?');
    });
  });

  testWidgets('좁은 타일 설명은 단어 중간에서 끊지 않는다 (income·buildings)', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: fitLines('Level up\nincome·buildings↑', Ts.body, 72))),
    ));
    final lines = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
    expect(lines.join(' ').replaceAll('· ', '·'), 'Level up income·buildings↑');
    for (final l in lines) {
      expect(['Level', 'up', 'Level up', 'income·', 'buildings↑', 'income·buildings↑'], contains(l));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('버튼 글자도 본문과 같은 글꼴(Jua)', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(fontFamily: Ts.family),
      home: Scaffold(
        body: Column(children: [
          actionBtn('Reset', true, () {}),
          actionBtn('New Game', true, () {}, primary: true, leadingIcon: Icons.play_arrow),
          TextButton(onPressed: () {}, child: const Text('Cancel')),
          FilledButton(onPressed: () {}, child: const Text('OK')),
          const Text('Body text'),
        ]),
      ),
    ));
    for (final label in ['Reset', 'New Game', 'Cancel', 'OK', 'Body text']) {
      final p = tester.renderObject<RenderParagraph>(find.descendant(of: find.text(label), matching: find.byType(RichText)));
      expect(p.text.style?.fontFamily, Ts.family, reason: label);
    }
  });

  test('모바일에서는 단축키 안내를 뺀다', () {
    expect(keyHint('상인 (E)', keyboard: false), '상인');
    expect(keyHint('헤이븐 기지 관리 (E)', keyboard: false), '헤이븐 기지 관리');
    expect(keyHint('적을 추적하는 미사일 (Q키 / 🚀 버튼)', keyboard: false), '적을 추적하는 미사일 (🚀 버튼)');
    expect(keyHint('Homing missiles (Q key / 🚀 button)', keyboard: false), 'Homing missiles (🚀 button)');
    expect(keyHint('敵を追尾するミサイル（Qキー / 🚀ボタン）', keyboard: false), '敵を追尾するミサイル（🚀ボタン）');
    expect(keyHint('유도 미사일 장착! (Q)', keyboard: false), '유도 미사일 장착!');
    expect(keyHint('상인 (E)', keyboard: true), '상인 (E)');
  });

  test('젬·결제 승무원은 크레딧 모집 가격을 올리지 않는다', () {
    final w = GameWorld(seed: 3)
      ..credits = 1e6
      ..ore = 1e6;
    w.profile.gems = 10000;
    final base = w.recruitCost;
    w.grantCrew(3); // 스타터 팩 승무원
    expect(w.recruitWithGems(), isNotNull);
    expect(w.recruitLegendary(), isNotNull);
    expect(w.recruitCost, base);
    expect(w.recruitWithCredits(), isNotNull);
    expect(w.recruitCost, base + 150);
    // 저장·불러오기 후에도 같은 가격
    final again = GameWorld.fromJson(w.toJson(), w.profile);
    expect(again.recruitCost, base + 150);
  });

  test('튜토리얼 해적 격추 목표는 내 함선이 잡은 것만 센다', () {
    final w = GameWorld(seed: 4);
    final far = w.player.pos + const Offset(0, -900);
    w.pirates.add(Pirate(PirateKind.scout, far, 0)..lastHitByBase = true);
    w.update(1 / 60, InputState());
    expect(w.counter('kills'), 1);
    expect(w.counter('shipKills'), 0);
    w.pirates.add(Pirate(PirateKind.scout, far, 0));
    w.update(1 / 60, InputState());
    expect(w.counter('kills'), 2);
    expect(w.counter('shipKills'), 1);
  });

  test('첫 항성계 튜토리얼에도 적은 줄이지 않는다 (초반에 많이 나와야 재미있다)', () {
    final w = GameWorld(seed: 5);
    runFor(w, 180);
    expect(w.storyIndex, lessThan(2));
    expect(w.threat, closeTo(3, 0.05)); // 시간 위협은 원래 속도로 오른다
    // 3분 동안 기지 포탑이 잡을 만큼 꾸준히 몰려온다 (튜토리얼 감속이 있던 때는 절반 이하)
    expect(w.counter('kills'), greaterThanOrEqualTo(15));
  });

  test('행성 곁에 있는 함선은 행성과 함께 궤도를 돈다', () {
    final w = GameWorld(seed: 6);
    final planet = w.planets.first;
    w.player.pos = planet.pos + Offset(planet.radius + 60, 0);
    w.player.vel = Offset.zero;
    final rel = w.player.pos - planet.pos;
    runFor(w, 10);
    expect((planet.pos - (w.player.pos - rel)).distance, lessThan(25)); // 행성 기준 자리는 거의 그대로
    expect(w.nearbyPlanet, planet);
  });

  test('배경음악은 여러 곡을 돌아가며 틀고 같은 곡을 연달아 틀지 않는다', () {
    for (final t in [...AudioService.tracks, AudioService.bossTrack]) {
      expect(File('assets/$t').existsSync(), isTrue, reason: t);
    }
    final rng = Random(1);
    var cur = AudioService.nextTrack(-1, rng);
    final seen = {cur};
    for (var i = 0; i < 200; i++) {
      final next = AudioService.nextTrack(cur, rng);
      expect(next, isNot(cur));
      seen.add(next);
      cur = next;
    }
    expect(seen.length, AudioService.tracks.length);
  });

  test('순항을 켜면 조이스틱을 놓아도 바라보는 방향으로 계속 날아간다', () {
    for (final cruise in [false, true]) {
      final w = GameWorld(seed: 7);
      final i = InputState()..cruise = cruise;
      w.player.angle = 0; // 오른쪽
      final start = w.player.pos;
      for (var t = 0.0; t < 3; t += 1 / 60) {
        w.update(1 / 60, i);
      }
      final dx = w.player.pos.dx - start.dx;
      if (cruise) {
        expect(dx, greaterThan(300));
      } else {
        expect(dx.abs(), lessThan(5));
      }
    }
  });

  test('순항은 처음엔 꺼져 있고, 첫 튜토리얼(소행성·해적)을 마칠 때 안내와 함께 한 번만 켜진다', () {
    final w = GameWorld(seed: 8);
    expect(w.profile.cruise, isFalse);
    w.storyIndex = GameWorld.cruiseTipStep - 1; // 해적 격추 단계
    w.counters['shipKills'] = 99;
    runFor(w, 1); // 스토리 완료는 0.5초마다 확인한다
    expect(w.storyIndex, GameWorld.cruiseTipStep);
    expect(w.profile.cruise, isTrue);
    expect(w.dialogs.any((d) => d.text == tr.g_dlgCruiseOn), isTrue);
    expect(Profile.fromJson(w.profile.toJson()).cruise, isTrue);
    // 사용자가 끄면 다시 켜지 않는다
    w.profile.cruise = false;
    w.storyIndex = GameWorld.cruiseTipStep - 1;
    w.counters['shipKills'] = 999;
    runFor(w, 1);
    expect(w.profile.cruise, isFalse);
  });
}
