import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../game/world.dart';
import 'sprites.dart';

/// 항성 캐릭터 스프라이트. 모두 같은 화풍(태양 'sun' 기준)으로 그린 의인화 항성.
enum StarFace {
  sun('sun'),
  yellowElder('star_yellow_elder'),
  redGrandpa('star_red_grandpa'),
  redKid('star_red_kid'),
  redGrumpy('star_red_grumpy'),
  orange('star_orange'),

  /// 오른쪽을 바라보는 쌍둥이. 짝의 오른쪽에 있으면 뒤집어 서로 마주 보게 한다.
  twin('star_twin'),
  blueGiant('star_blue_giant'),
  whiteDwarf('star_white_dwarf'),
  blackHole('black_hole');

  const StarFace(this.sprite);
  final String sprite;

  /// 스프라이트에서 몸통이 차지하는 비율 (나머지는 불꽃·원반)
  double get bodyRatio => this == blackHole ? 0.45 : 0.6;
}

/// 항성계 안의 천체 하나. 위치 = 무리 중심의 공전 + 무리 안의 공전.
/// 같은 유형이어도 [hue]·[size]·속도·위상이 항성계마다 달라 똑같아 보이지 않게 한다.
class StarBody {
  const StarBody(
    this.face, {
    this.size = 1,
    this.hue = 0,
    this.orbit = 0,
    this.speed = 0,
    this.phase = 0,
    this.groupOrbit = 0,
    this.groupSpeed = 0,
    this.groupPhase = 0,
    this.partner,
    required this.glow,
  });

  final StarFace face;

  /// 몸통 반지름 배율 (1 = [GameWorld.starRadius])
  final double size;

  /// 색상환 회전 (도). 같은 캐릭터를 조금씩 다른 색으로
  final double hue;

  /// 무리 중심에서의 공전 반지름·각속도(rad/s)·위상
  final double orbit, speed, phase;

  /// 무리 중심 자체가 항성계 중심을 도는 반지름·각속도·위상 (3중성 등)
  final double groupOrbit, groupSpeed, groupPhase;

  /// 서로 마주 볼 짝의 인덱스 (쌍둥이)
  final int? partner;

  /// 광채 색
  final Color glow;

  Offset posAt(double t) {
    final g = groupOrbit == 0
        ? Offset.zero
        : Offset.fromDirection(groupPhase + groupSpeed * t, groupOrbit);
    return orbit == 0 ? g : g + Offset.fromDirection(phase + speed * t, orbit);
  }
}

/// 항성계 한 곳의 하늘: 천체들, 배경 색, 성운 색.
class StarSystemLook {
  const StarSystemLook(this.bodies, this.bg, this.nebula);
  final List<StarBody> bodies;

  /// 배경 방사 그라데이션 (가운데, 가장자리)
  final (Color, Color) bg;

  /// 성운 덩어리 색 3개
  final List<Color> nebula;

  /// 미니맵 점 색 (주성 광채)
  Color get mapColor => bodies.first.glow.withValues(alpha: 1);
}

const _yellow = Color(0xFFFFB300);
const _red = Color(0xFFFF5A3C);
const _orange = Color(0xFFFF8F1F);
const _blue = Color(0xFF6EC6FF);
const _white = Color(0xFFE6DDFF);
const _violet = Color(0xFFB04BFF);

/// 쌍둥이 한 쌍: 서로 반대편에서 마주 보며 돈다
List<StarBody> _twins({
  required double orbit,
  required double speed,
  double sizeA = .7,
  double sizeB = .7,
  double hueA = 0,
  double hueB = 0,
  Color glowA = _yellow,
  Color glowB = _yellow,
  int first = 0,
  double groupOrbit = 0,
  double groupSpeed = 0,
  double groupPhase = 0,
}) => [
  StarBody(
    StarFace.twin,
    size: sizeA,
    hue: hueA,
    orbit: orbit,
    speed: speed,
    groupOrbit: groupOrbit,
    groupSpeed: groupSpeed,
    groupPhase: groupPhase,
    partner: first + 1,
    glow: glowA,
  ),
  StarBody(
    StarFace.twin,
    size: sizeB,
    hue: hueB,
    orbit: orbit,
    speed: speed,
    phase: pi,
    groupOrbit: groupOrbit,
    groupSpeed: groupSpeed,
    groupPhase: groupPhase,
    partner: first,
    glow: glowB,
  ),
];

/// 주변을 도는 작은 무리 (성단)
List<StarBody> _cluster(
  StarFace face,
  int n, {
  required double orbit,
  required double speed,
  required double size,
  double hueStep = 0,
  double hue = 0,
  required Color glow,
}) => [
  for (var i = 0; i < n; i++)
    StarBody(
      face,
      size: size * (1 - .12 * (i % 2)),
      hue: hue + hueStep * i,
      orbit: orbit * (1 + .18 * (i % 3)),
      speed: speed * (i.isEven ? 1 : .8),
      phase: i * 2 * pi / n,
      glow: glow,
    ),
];

/// 이름 있는 항성계(0~26). 실제 천체의 특징을 따른다.
final List<StarSystemLook> _catalog = [
  // 0 태양계: 태양
  const StarSystemLook(
    [StarBody(StarFace.sun, glow: _yellow)],
    (Color(0xFF1A1440), Color(0xFF070614)),
    [Color(0x334A2C8F), Color(0x2A1E5A8F), Color(0x22C2185B)],
  ),
  // 1 알파 센타우리: A·B 쌍둥이 + 멀리서 엿보는 꼬마 프록시마
  StarSystemLook(
    [
      ..._twins(
        orbit: 190,
        speed: .35,
        sizeA: .75,
        sizeB: .62,
        hueB: -14,
        glowB: _orange,
      ),
      const StarBody(
        StarFace.redKid,
        size: .32,
        orbit: 480,
        speed: .06,
        phase: 2.2,
        glow: _red,
      ),
    ],
    (const Color(0xFF13234A), const Color(0xFF050914)),
    const [Color(0x334A6CC2), Color(0x22FFB74D), Color(0x1A8F4AC2)],
  ),
  // 2 바너드별: 가장 나이 많은 이웃, 콧수염 할아버지
  const StarSystemLook(
    [StarBody(StarFace.redGrandpa, size: .78, glow: _red)],
    (Color(0xFF2E1010), Color(0xFF0C0404)),
    [Color(0x33A23A2C), Color(0x22704020), Color(0x1A5A2C8F)],
  ),
  // 3 울프 359: 툭하면 폭발하는 플레어별
  const StarSystemLook(
    [StarBody(StarFace.redGrumpy, size: .72, glow: _red)],
    (Color(0xFF330A14), Color(0xFF0E0306)),
    [Color(0x33E0303A), Color(0x22801030), Color(0x1AFF8A50)],
  ),
  // 4 랄랑드 21185: 조용한 적색왜성 꼬마
  const StarSystemLook(
    [StarBody(StarFace.redKid, size: .8, hue: 10, glow: _red)],
    (Color(0xFF2A1420), Color(0xFF0B0509)),
    [Color(0x33A23A6C), Color(0x22C26A3A), Color(0x1A3A2C8F)],
  ),
  // 5 시리우스: 왕관 쓴 청색 거성 + 백색왜성 아기
  const StarSystemLook(
    [
      StarBody(
        StarFace.blueGiant,
        size: 1.15,
        orbit: 60,
        speed: .18,
        glow: _blue,
      ),
      StarBody(
        StarFace.whiteDwarf,
        size: .3,
        orbit: 340,
        speed: .18,
        phase: pi,
        glow: _white,
      ),
    ],
    (Color(0xFF0E2A4A), Color(0xFF030A14)),
    [Color(0x3340A0FF), Color(0x22B0E0FF), Color(0x1A6A4AC2)],
  ),
  // 6 에리다누스자리 엡실론: 젊은 주황색 별
  const StarSystemLook(
    [StarBody(StarFace.orange, size: .88, glow: _orange)],
    (Color(0xFF2B1A0A), Color(0xFF0D0703)),
    [Color(0x33C27A2C), Color(0x22806A3A), Color(0x1A2C6A8F)],
  ),
  // 7 로스 128: 조용한 할아버지 (바너드보다 작고 주황빛)
  const StarSystemLook(
    [StarBody(StarFace.redGrandpa, size: .64, hue: 14, glow: _orange)],
    (Color(0xFF2B1A12), Color(0xFF0D0704)),
    [Color(0x33A2602C), Color(0x22604A3A), Color(0x1A3A5A8F)],
  ),
  // 8 고래자리 타우: 태양 닮은 현자
  const StarSystemLook(
    [StarBody(StarFace.yellowElder, size: .95, glow: _yellow)],
    (Color(0xFF1E1A3A), Color(0xFF07060F)),
    [Color(0x33C2A040), Color(0x224A6C8F), Color(0x1A8F4A8F)],
  ),
  // 9 티가든별: 아주 작은 꼬마
  const StarSystemLook(
    [StarBody(StarFace.redKid, size: .6, hue: -12, glow: _red)],
    (Color(0xFF2E0F24), Color(0xFF0C030A)),
    [Color(0x33C23A8F), Color(0x22803A4A), Color(0x1A3A4A8F)],
  ),
  // 10 글리제 581: 덜 성난 플레어별
  const StarSystemLook(
    [StarBody(StarFace.redGrumpy, size: .82, hue: 16, glow: _orange)],
    (Color(0xFF2E1A0E), Color(0xFF0C0603)),
    [Color(0x33C2602C), Color(0x22A23A3A), Color(0x1A4A3A8F)],
  ),
  // 11 글리제 667C: 꼬마 C 둘레를 주황 쌍둥이 A·B가 멀리서 함께 돈다 (3중성)
  StarSystemLook(
    [
      const StarBody(StarFace.redKid, size: .7, hue: 6, glow: _red),
      ..._twins(
        orbit: 85,
        speed: .9,
        sizeA: .4,
        sizeB: .38,
        hueA: -12,
        hueB: -20,
        glowA: _orange,
        glowB: _orange,
        first: 1,
        groupOrbit: 470,
        groupSpeed: .05,
        groupPhase: -.8,
      ),
    ],
    (const Color(0xFF26160E), const Color(0xFF0A0503)),
    const [Color(0x33C2702C), Color(0x22C23A3A), Color(0x1A2C6A6A)],
  ),
  // 12 트라피스트-1: 어둡고 작은 초저온 왜성
  const StarSystemLook(
    [StarBody(StarFace.redKid, size: .55, hue: -22, glow: Color(0xFFE0304A))],
    (Color(0xFF240818), Color(0xFF080206)),
    [Color(0x33801A4A), Color(0x22401A6A), Color(0x1AC23A3A)],
  ),
  // 13 게자리 55: 주황색 별 + 멀리 도는 적색왜성 동반성
  const StarSystemLook(
    [
      StarBody(StarFace.orange, size: .92, hue: -8, glow: _orange),
      StarBody(
        StarFace.redKid,
        size: .34,
        orbit: 440,
        speed: .08,
        phase: 1,
        glow: _red,
      ),
    ],
    (Color(0xFF2E1E0A), Color(0xFF0E0803)),
    [Color(0x33E0A040), Color(0x22A2502C), Color(0x1A4A2C6A)],
  ),
  // 14 페가수스자리 51: 태양과 닮은 별 (조금 더 크고 노랗게)
  const StarSystemLook(
    [StarBody(StarFace.sun, size: 1.1, hue: -5, glow: _yellow)],
    (Color(0xFF14203A), Color(0xFF05080F)),
    [Color(0x33E0C040), Color(0x222C6A8F), Color(0x1A6A2C8F)],
  ),
  // 15 TOI-700: 적색왜성 꼬마
  const StarSystemLook(
    [StarBody(StarFace.redKid, size: .74, hue: 20, glow: _orange)],
    (Color(0xFF1A1A30), Color(0xFF06060C)),
    [Color(0x33C2603A), Color(0x223A6AC2), Color(0x1A8F3A6A)],
  ),
  // 16 케플러-16: 행성이 두 별을 함께 도는 쌍성 (주황 형 + 붉은 동생)
  StarSystemLook(
    _twins(
      orbit: 210,
      speed: .45,
      sizeA: .78,
      sizeB: .55,
      hueA: -16,
      hueB: -34,
      glowA: _orange,
      glowB: _red,
    ),
    (const Color(0xFF301A0A), const Color(0xFF0E0603)),
    const [Color(0x33FF8A3A), Color(0x22C23A2C), Color(0x1A2C4A8F)],
  ),
  // 17 케플러-186: 성난 적색왜성
  const StarSystemLook(
    [StarBody(StarFace.redGrumpy, size: .66, hue: -8, glow: _red)],
    (Color(0xFF200A1E), Color(0xFF080308)),
    [Color(0x33A21A6A), Color(0x22E03A3A), Color(0x1A3A2C8F)],
  ),
  // 18 케플러-22: 조금 주황빛인 태양형 별
  const StarSystemLook(
    [StarBody(StarFace.sun, size: .96, hue: -10, glow: _orange)],
    (Color(0xFF0D2B26), Color(0xFF03100D)),
    [Color(0x332CA28F), Color(0x22E0A040), Color(0x1A2C4A8F)],
  ),
  // 19 케플러-452: 지구의 사촌별, 태양보다 크고 나이 든 현자
  const StarSystemLook(
    [StarBody(StarFace.yellowElder, size: 1.12, hue: -8, glow: _orange)],
    (Color(0xFF26203A), Color(0xFF0A080F)),
    [Color(0x33E0B040), Color(0x228F4AC2), Color(0x1A2C8F6A)],
  ),
  // 20 케플러-90: 하얗게 빛나는 큰 별 (F형)
  const StarSystemLook(
    [StarBody(StarFace.sun, size: 1.2, hue: -4, glow: Color(0xFFFFF080))],
    (Color(0xFF1A2A3A), Color(0xFF060A0F)),
    [Color(0x33E0E080), Color(0x2240A0C2), Color(0x1A8F8F4A)],
  ),
  // 21 오메가 센타우리: 늙은 별들이 모인 구상성단, 할아버지와 친구들
  StarSystemLook(
    [
      const StarBody(StarFace.redGrandpa, size: .7, hue: 18, glow: _orange),
      ..._cluster(
        StarFace.yellowElder,
        3,
        orbit: 300,
        speed: .12,
        size: .34,
        hue: -10,
        hueStep: 8,
        glow: _yellow,
      ),
      ..._cluster(
        StarFace.redGrandpa,
        3,
        orbit: 420,
        speed: -.08,
        size: .3,
        hue: 4,
        hueStep: 10,
        glow: _red,
      ),
    ],
    (const Color(0xFF2A2210), const Color(0xFF0C0904)),
    const [Color(0x33E0C060), Color(0x22C2703A), Color(0x1AE0E0A0)],
  ),
  // 22 궁수자리 A*: 은하 중심 블랙홀 + 빠르게 도는 별 S2
  const StarSystemLook(
    [
      StarBody(StarFace.blackHole, size: 1.05, glow: _violet),
      StarBody(
        StarFace.blueGiant,
        size: .32,
        hue: -10,
        orbit: 380,
        speed: .5,
        glow: _blue,
      ),
    ],
    (Color(0xFF1E0A2E), Color(0xFF06020C)),
    [Color(0x44B04BFF), Color(0x33FF8A3A), Color(0x22E0C060)],
  ),
  // 23 대마젤란은하 R136a1: 가장 무거운 별, 거대한 청색 거성과 성단
  StarSystemLook(
    [
      const StarBody(StarFace.blueGiant, size: 1.4, hue: 8, glow: _blue),
      ..._cluster(
        StarFace.blueGiant,
        2,
        orbit: 400,
        speed: .1,
        size: .36,
        hue: -12,
        hueStep: 20,
        glow: _blue,
      ),
    ],
    (const Color(0xFF0A2236), const Color(0xFF02080E)),
    const [Color(0x4440C0FF), Color(0x33FF4A9A), Color(0x22A0E0FF)],
  ),
  // 24 소마젤란은하 NGC 346: 갓 태어난 별들이 뛰노는 성운
  StarSystemLook(
    [
      const StarBody(StarFace.blueGiant, size: .7, hue: -18, glow: _blue),
      ..._cluster(
        StarFace.twin,
        4,
        orbit: 300,
        speed: .22,
        size: .3,
        hue: 160,
        hueStep: 14,
        glow: _blue,
      ),
    ],
    (const Color(0xFF2A0E30), const Color(0xFF0A030C)),
    const [Color(0x44FF4AB0), Color(0x3340C0FF), Color(0x22FFB0E0)],
  ),
  // 25 안드로메다 PA-99-N2: 이웃 은하의 행성을 품은 별
  const StarSystemLook(
    [StarBody(StarFace.orange, size: .9, hue: 14, glow: _yellow)],
    (Color(0xFF1A1030), Color(0xFF06040C)),
    [Color(0x44C27AFF), Color(0x33E0A0C0), Color(0x224A6AC2)],
  ),
  // 26 M33 X-7: 코어 제작자의 근원지. 블랙홀과 청색 거성이 서로 도는 X선 쌍성
  const StarSystemLook(
    [
      StarBody(
        StarFace.blackHole,
        size: .95,
        orbit: 170,
        speed: .3,
        glow: _violet,
      ),
      StarBody(
        StarFace.blueGiant,
        size: .95,
        hue: -24,
        orbit: 230,
        speed: .3,
        phase: pi,
        glow: _blue,
      ),
    ],
    (Color(0xFF1A0626), Color(0xFF050108)),
    [Color(0x55B04BFF), Color(0x3340A0FF), Color(0x22FF3A6A)],
  ),
];

/// 이름 없는 먼 항성계: 섹터 번호로 결정되는 조합 (같은 섹터는 늘 같은 하늘)
StarSystemLook _procedural(int sector) {
  final r = Random(sector * 7919 + 13);
  double jitter(double a) => (r.nextDouble() * 2 - 1) * a;
  final hue = jitter(24);
  final size = .7 + r.nextDouble() * .5;
  final bodies = switch (r.nextInt(7)) {
    0 => [StarBody(StarFace.sun, size: size, hue: hue, glow: _yellow)],
    1 => [
      StarBody(StarFace.redGrandpa, size: size * .85, hue: hue, glow: _red),
    ],
    2 => _twins(
      orbit: 170 + jitter(40),
      speed: .3 + r.nextDouble() * .3,
      sizeA: size * .7,
      sizeB: size * .6,
      hueA: hue,
      hueB: hue - 20,
      glowA: _orange,
      glowB: _red,
    ),
    3 => [
      StarBody(StarFace.blueGiant, size: size * 1.1, hue: hue, glow: _blue),
      StarBody(
        StarFace.whiteDwarf,
        size: .3,
        orbit: 330,
        speed: .2,
        phase: r.nextDouble() * 2 * pi,
        glow: _white,
      ),
    ],
    4 => [StarBody(StarFace.redGrumpy, size: size * .8, hue: hue, glow: _red)],
    5 => [StarBody(StarFace.orange, size: size, hue: hue, glow: _orange)],
    _ => [
      StarBody(StarFace.blackHole, size: size, glow: _violet),
      StarBody(
        StarFace.redKid,
        size: .35,
        orbit: 360,
        speed: .4,
        phase: r.nextDouble() * 2 * pi,
        glow: _red,
      ),
    ],
  };
  final tint = HSVColor.fromAHSV(1, r.nextDouble() * 360, .6, .2).toColor();
  final edge = HSVColor.fromColor(tint).withValue(.06).toColor();
  Color neb() => HSVColor.fromAHSV(.2, r.nextDouble() * 360, .7, .8).toColor();
  return StarSystemLook(bodies, (tint, edge), [neb(), neb(), neb()]);
}

final _procCache = <int, StarSystemLook>{};

/// 섹터의 하늘
StarSystemLook starSystemLook(int sector) =>
    sector >= 0 && sector < _catalog.length
    ? _catalog[sector]
    : _procCache.putIfAbsent(sector, () => _procedural(sector));

/// 섹터 수 검사용 (테스트)
int get starSystemLookCount => _catalog.length;

/// 항성계 중심 천체들을 그린다. [hueFilter]는 색상환 회전 행렬을 만든다.
void paintStarSystem(
  Canvas canvas,
  int sector,
  double t,
  ColorFilter Function(double deg) hueFilter,
) {
  const base = GameWorld.starRadius;
  final look = starSystemLook(sector);
  final bodies = look.bodies;
  final pos = [for (final b in bodies) b.posAt(t)];
  // 뒤(위쪽)에 있는 천체부터 그려 겹칠 때 앞뒤가 맞게
  final order = List.generate(bodies.length, (i) => i)
    ..sort((a, b) => pos[a].dy.compareTo(pos[b].dy));
  for (final i in order) {
    final b = bodies[i];
    final c = pos[i];
    final r = base * b.size;
    canvas.drawCircle(
      c,
      r * 3,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          r * 3,
          [
            b.glow.withValues(alpha: .4),
            b.glow.withValues(alpha: .13),
            b.glow.withValues(alpha: 0),
          ],
          [.3, .6, 1],
        ),
    );
    // 쌍둥이는 짝 쪽을 바라본다 (스프라이트는 오른쪽을 본다)
    final faceLeft = b.partner != null && pos[b.partner!].dx < c.dx;
    // 작은 천체일수록 통통 튄다
    final bob = sin(t * (2.2 + i * .7) + i) * r * .06;
    final spin = sin(t * .3 + i) * .08;
    canvas.save();
    canvas.translate(c.dx, c.dy + bob);
    if (faceLeft) canvas.scale(-1, 1);
    final drawn = Sprites.draw(
      canvas,
      b.face.sprite,
      Offset.zero,
      r * 2 / b.face.bodyRatio,
      angle: b.face == StarFace.twin ? spin * 1.5 : spin,
      filter: b.hue == 0 ? null : hueFilter(b.hue),
    );
    if (!drawn) {
      canvas.drawCircle(Offset.zero, r, Paint()..color = look.mapColor);
    }
    canvas.restore();
  }
}
