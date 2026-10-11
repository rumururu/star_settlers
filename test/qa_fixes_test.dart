import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart' show keyHint;
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

  test('첫 항성계 튜토리얼 초반에는 위협이 천천히 오른다', () {
    final calm = GameWorld(seed: 5);
    runFor(calm, 180);
    expect(calm.storyIndex, lessThan(2));
    expect(calm.threat, lessThan(2)); // 예전에는 3분이면 3
    // 저장해도 유지
    expect(GameWorld.fromJson(calm.toJson(), calm.profile).threat, closeTo(calm.threat, 0.05));

    // 식민지 단계부터는 원래 속도
    final normal = GameWorld(seed: 5)..storyIndex = 2;
    runFor(normal, 90);
    expect(normal.threat, closeTo(2, 0.05));
  });
}
