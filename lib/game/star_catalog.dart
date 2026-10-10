import '../l10n/l.dart';
import 'models.dart';

/// 실제 천문 카탈로그. 섹터 순서 = 지구에서 가까운 순.
/// 태양계(본거지는 지구) → 이웃 별들 → 우리 은하 깊은 곳 → 이웃 은하 → 미지의 섹터.
///
/// 행성 배치는 안쪽 고리부터 바깥쪽이므로 실제 행성도 궤도 순(안→밖)으로 둔다.
/// 알려진 천체가 모자라면 실제 명명 규칙을 따른 가상의 천체로 채운다
/// (외계행성: 다음 알파벳 "Proxima e, f…", 태양계: 제9행성 → 임시 소행성 부호).

typedef _Name = String Function(L10n t);

/// 태양계 천체: 이름, 종류, 선택 우선순위(작을수록 먼저 들어감).
/// 목록 자체는 고리 순서(안 → 밖). 0번(화성)은 언제나 첫 식민지(튜토리얼).
class _SolBody {
  const _SolBody(this.name, this.kind, this.priority);
  final _Name name;
  final PlanetKind kind;
  final int priority;
}

final List<_SolBody> _solar = [
  _SolBody((t) => t.cat_mars, PlanetKind.desert, 0),
  _SolBody((t) => t.cat_moon, PlanetKind.desert, 7),
  _SolBody((t) => t.cat_venus, PlanetKind.lava, 1),
  _SolBody((t) => t.cat_mercury, PlanetKind.lava, 2),
  _SolBody((t) => t.cat_vesta, PlanetKind.desert, 23),
  _SolBody((t) => t.cat_ceres, PlanetKind.ice, 8),
  _SolBody((t) => t.cat_jupiter, PlanetKind.gas, 3),
  _SolBody((t) => t.cat_io, PlanetKind.lava, 12),
  _SolBody((t) => t.cat_europa, PlanetKind.ice, 11),
  _SolBody((t) => t.cat_ganymede, PlanetKind.ice, 13),
  _SolBody((t) => t.cat_callisto, PlanetKind.ice, 14),
  _SolBody((t) => t.cat_saturn, PlanetKind.gas, 4),
  _SolBody((t) => t.cat_enceladus, PlanetKind.ice, 15),
  _SolBody((t) => t.cat_titan, PlanetKind.ice, 10),
  _SolBody((t) => t.cat_uranus, PlanetKind.ice, 5),
  _SolBody((t) => t.cat_miranda, PlanetKind.ice, 24),
  _SolBody((t) => t.cat_titania, PlanetKind.ice, 20),
  _SolBody((t) => t.cat_neptune, PlanetKind.ice, 6),
  _SolBody((t) => t.cat_triton, PlanetKind.ice, 16),
  _SolBody((t) => t.cat_pluto, PlanetKind.ice, 9),
  _SolBody((t) => t.cat_charon, PlanetKind.ice, 22),
  _SolBody((t) => t.cat_haumea, PlanetKind.ice, 18),
  _SolBody((t) => t.cat_makemake, PlanetKind.desert, 19),
  _SolBody((t) => t.cat_eris, PlanetKind.ice, 17),
  _SolBody((t) => t.cat_planetNine, PlanetKind.ice, 25),
  _SolBody((t) => t.cat_sedna, PlanetKind.desert, 21),
];

/// 외계 항성계. [planets]는 실제 확인된(일부 후보 포함) 행성의 부호 문자와 종류, 궤도 순.
class _StarSystem {
  const _StarSystem(this.name, this.ly, {this.prefix, this.sep = ' ', this.planets = const []});
  final _Name name;
  final double ly;

  /// 행성 부호 앞에 붙는 별 이름. 없으면 항성계 이름을 그대로 쓴다.
  final _Name? prefix;

  /// 별 이름과 문자 사이 (Gliese 667 Cb, Sirius Ab 처럼 붙여 쓰는 경우 '')
  final String sep;
  final List<(String, PlanetKind)> planets;
}

String _lit(String s) => s; // 라틴 문자 고유 부호 (모든 언어 공통)

const _g = PlanetKind.garden, _d = PlanetKind.desert, _i = PlanetKind.ice, _l = PlanetKind.lava, _x = PlanetKind.gas;

final List<_StarSystem> _systems = [
  _StarSystem((t) => t.cat_sysAlphaCen, 4.24,
      prefix: (t) => t.cat_pfxProxima, planets: [('d', _l), ('b', _g), ('c', _i)]),
  _StarSystem((t) => t.cat_sysBarnard, 5.96,
      prefix: (t) => t.cat_pfxBarnard, planets: [('d', _l), ('b', _d), ('c', _d), ('e', _d)]),
  _StarSystem((t) => t.cat_sysWolf359, 7.86, planets: [('c', _l), ('b', _x)]),
  _StarSystem((t) => t.cat_sysLalande, 8.31, planets: [('b', _d), ('c', _i)]),
  // 시리우스는 알려진 행성이 없다. 쌍성계라 행성 부호는 "Sirius Ab"꼴.
  _StarSystem((t) => t.cat_sysSirius, 8.60, prefix: (t) => t.cat_pfxSirius, sep: ''),
  _StarSystem((t) => t.cat_sysEpsEri, 10.5, prefix: (t) => t.cat_pfxEpsEri, planets: [('b', _x)]),
  _StarSystem((t) => t.cat_sysRoss128, 11.0, planets: [('b', _g)]),
  _StarSystem((t) => t.cat_sysTauCeti, 11.9,
      prefix: (t) => t.cat_pfxTauCeti, planets: [('g', _l), ('h', _d), ('e', _d), ('f', _i)]),
  _StarSystem((t) => t.cat_sysTeegarden, 12.5,
      prefix: (t) => t.cat_pfxTeegarden, planets: [('b', _g), ('c', _i), ('d', _i)]),
  _StarSystem((t) => t.cat_sysGliese581, 20.5, planets: [('e', _l), ('b', _x), ('c', _d)]),
  _StarSystem((t) => t.cat_sysGliese667C, 23.6, sep: '', planets: [('b', _d), ('c', _g)]),
  _StarSystem((t) => t.cat_sysTrappist1, 40.7,
      planets: [('b', _l), ('c', _d), ('d', _g), ('e', _g), ('f', _i), ('g', _i), ('h', _i)]),
  _StarSystem((t) => t.cat_sys55Cnc, 41.0, planets: [('e', _l), ('b', _x), ('c', _x), ('f', _x), ('d', _x)]),
  _StarSystem((t) => t.cat_sys51Peg, 50.6, planets: [('b', _x)]),
  _StarSystem((t) => _lit('TOI-700'), 101.4, planets: [('b', _d), ('c', _x), ('e', _g), ('d', _g)]),
  _StarSystem((t) => t.cat_sysKepler(16), 245, planets: [('b', _x)]),
  _StarSystem((t) => t.cat_sysKepler(186), 579,
      planets: [('b', _l), ('c', _l), ('d', _d), ('e', _d), ('f', _g)]),
  _StarSystem((t) => t.cat_sysKepler(22), 638, planets: [('b', _g)]),
  _StarSystem((t) => t.cat_sysKepler(452), 1800, planets: [('b', _g)]),
  _StarSystem((t) => t.cat_sysKepler(90), 2840, planets: [
    ('b', _l), ('c', _l), ('i', _d), ('d', _x), ('e', _i), ('f', _i), ('g', _x), ('h', _x)
  ]),
  // 우리 은하 깊은 곳 — 알려진 행성은 없으니 대표 천체 이름으로 가상 부호를 붙인다
  _StarSystem((t) => t.cat_sysOmegaCen, 17090, prefix: (t) => _lit('ω Cen')),
  _StarSystem((t) => t.cat_sysSgrA, 26670, prefix: (t) => _lit('S2')), // Sgr A* 를 도는 실제 별 S2
  // 이웃 은하
  _StarSystem((t) => t.cat_sysLMC, 163000, prefix: (t) => _lit('R136a1')), // 가장 무거운 별
  _StarSystem((t) => t.cat_sysSMC, 200000, prefix: (t) => _lit('NGC 346')),
  // PA-99-N2 b: 안드로메다 은하의 외계행성 후보 (미세중력렌즈, 2009)
  _StarSystem((t) => t.cat_sysAndromeda, 2537000, prefix: (t) => _lit('PA-99-N2'), planets: [('b', _x)]),
  _StarSystem((t) => t.cat_sysTriangulum, 2730000, prefix: (t) => _lit('M33 X-7')),
];

/// 카탈로그에 이름 있는 섹터 수 (이후는 "미지의 섹터 N")
int get catalogSystemCount => _systems.length + 1;

bool _known(int sector) => sector >= 0 && sector < catalogSystemCount;

/// 섹터(0 = 태양계)의 현지화된 항성계 이름
String systemName(int sector) {
  if (sector <= 0) return tr.cat_sysSol;
  if (_known(sector)) return _systems[sector - 1].name(tr);
  return tr.g_unknownSector(sector + 1);
}

/// 지구에서의 거리 (광년). 태양계는 0. 단조 증가.
double systemDistanceLy(int sector) {
  if (sector <= 0) return 0;
  if (_known(sector)) return _systems[sector - 1].ly;
  return _systems.last.ly + (sector - catalogSystemCount + 1) * 250000.0;
}

/// 이 항성계에 실제로 알려진(카탈로그에 있는) 천체 수
int knownBodyCount(int sector) {
  if (sector <= 0) return _solar.length;
  if (_known(sector)) return _systems[sector - 1].planets.length;
  return 0;
}

/// 섹터 [sector]의 [count]개 행성 중 [index]번째(안쪽 고리부터)의 이름과 종류.
/// 실제 천체가 먼저, 모자라면 실제 명명 규칙을 따른 가상 천체. 같은 입력이면 늘 같은 결과.
({String name, PlanetKind kind}) planetIdentity(int sector, int index, int count) {
  final n = count < index + 1 ? index + 1 : count;
  if (sector <= 0) return _solarIdentity(index, n);

  final sys = _known(sector) ? _systems[sector - 1] : null;
  final real = sys?.planets ?? const <(String, PlanetKind)>[];
  // 행성 수가 알려진 수보다 적으면 안쪽부터 n개만 쓴다
  if (index < real.length) {
    final (letter, kind) = real[index];
    return (name: _designation(sector, sys, letter), kind: kind);
  }
  // 가상 행성: 이미 쓴 문자 다음부터 b, c, d … z, 그 뒤는 숫자
  var maxLetter = 'a'.codeUnitAt(0);
  for (final (l, _) in real) {
    final c = l.codeUnitAt(0);
    if (c > maxLetter) maxLetter = c;
  }
  final code = maxLetter + 1 + (index - real.length);
  final letter = code <= 'z'.codeUnitAt(0) ? String.fromCharCode(code) : '${index + 1}';
  return (name: _designation(sector, sys, letter), kind: _fictionalKind(sector, index, n));
}

String _designation(int sector, _StarSystem? sys, String letter) {
  if (sys == null) return 'SX-${sector + 1} $letter';
  final star = (sys.prefix ?? sys.name)(tr);
  final sep = letter.length > 1 ? ' ' : sys.sep;
  return '$star$sep$letter';
}

({String name, PlanetKind kind}) _solarIdentity(int index, int n) {
  // 우선순위 상위 n개를 골라 고리 순서(목록 순서)를 유지한다
  final take = n < _solar.length ? n : _solar.length;
  final chosen = _solar.where((b) => b.priority < take).toList();
  if (index < chosen.length) {
    final b = chosen[index];
    return (name: b.name(tr), kind: b.kind);
  }
  // 가상의 해왕성 바깥 천체: 소행성 임시 부호 꼴 "2031 QX" (연도가 달라 겹치지 않는다)
  final k = index - chosen.length;
  final h = _hash(0, index);
  const letters = 'ABCDEFGHJKLMNOPQRSTUVWXY'; // 임시 부호엔 I, Z를 쓰지 않는다
  final name = '${2031 + k} ${letters[h % 24]}${letters[(h ~/ 24) % 24]}';
  return (name: name, kind: (h >> 7) % 3 == 0 ? PlanetKind.desert : PlanetKind.ice);
}

int _hash(int sector, int index) {
  var h = sector * 73856093 ^ index * 19349663 ^ 0x5bd1e995;
  h = (h ^ (h >> 13)) * 0x5bd1e995 & 0x7fffffff;
  return h ^ (h >> 15);
}

/// 가상 행성 종류: 안쪽은 뜨겁고, 바깥은 차갑거나 가스. (sector, index) 결정적.
PlanetKind _fictionalKind(int sector, int index, int count) {
  final h = _hash(sector, index);
  final pos = index / count;
  final List<PlanetKind> pool;
  if (pos < 0.25) {
    pool = const [_l, _l, _d, _d, _g];
  } else if (pos < 0.6) {
    pool = const [_g, _g, _d, _i, _x, _l];
  } else {
    pool = const [_x, _x, _i, _i, _d, _g];
  }
  return pool[h % pool.length];
}
