import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/l10n/l.dart' show Lang, L10n;
import 'package:star_settlers/ui/tokens.dart';

/// 렌더 증거 PNG 하네스 (TASK 003/004). 앱 글꼴(Jua)을 올리고 화면 크기·안전 영역·글자 배율을 맞춰 그린 뒤
/// 화면 전체를 PNG로 저장한다. 이모지는 테스트 엔진에 글꼴이 없어 네모로 보인다.
Future<void> loadAppFont() async {
  final font = FontLoader(Ts.family)
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File('assets/fonts/Jua-Regular.ttf').readAsBytesSync(),
        ),
      ),
    );
  await font.load();
}

final _boundary = GlobalKey();

/// [home]을 [size]·[padding]·[textScale]로 그리고, 넘침 등 그리기 오류 목록을 돌려준다.
Future<List<String>> pumpScreen(
  WidgetTester tester,
  Widget home, {
  required Size size,
  EdgeInsets padding = EdgeInsets.zero,
  double textScale = 1,
  String lang = 'ko',
}) async {
  Lang.set(Locale(lang));
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.padding = FakeViewPadding(
    left: padding.left,
    top: padding.top,
    right: padding.right,
    bottom: padding.bottom,
  );
  tester.view.viewPadding = tester.view.padding;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  final errors = <String>[];
  final old = FlutterError.onError;
  FlutterError.onError = (e) {
    errors.add(e.exceptionAsString().split('\n').first);
    if (Platform.environment['R3_DEBUG'] != null) debugPrint(e.toString());
  };
  try {
    await tester.pumpWidget(
      RepaintBoundary(
        key: _boundary,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: Lang.changed.value,
          supportedLocales: L10n.supportedLocales,
          localizationsDelegates: L10n.localizationsDelegates,
          theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: Ts.family,
            useMaterial3: true,
          ),
          home: home,
        ),
      ),
    );
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    // 아이콘 이미지 디코딩은 실제 시간이 걸린다: 잠깐 기다렸다가 다시 그린다
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pump(const Duration(milliseconds: 50));
  } finally {
    FlutterError.onError = old;
  }
  final pending = tester.takeException();
  if (pending != null) errors.add('$pending');
  return errors;
}

/// 마지막으로 그린 화면을 [path]에 PNG로 저장
Future<void> savePng(WidgetTester tester, String path) async {
  await tester.runAsync(() async {
    final ro =
        _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await ro.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    File(path)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
  });
}

void resetScreen(WidgetTester tester) {
  tester.view.reset();
  tester.platformDispatcher.clearTextScaleFactorTestValue();
}
