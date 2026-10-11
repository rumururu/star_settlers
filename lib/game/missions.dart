import '../l10n/l.dart';
import 'models.dart';

enum MissionType { kill, mine, deliver, bounty }

class Mission {
  Mission({
    required this.id,
    required this.type,
    required this.target,
    required this.rewardCredits,
    this.rewardGems = 0,
    this.planetIndex,
    int? bountyId,
    /// 이름 문자열로 지정할 때 (어느 언어든 기본 이름표면 번호로 바꾼다. 모르면 0번)
    String? bountyName,
  }) : bountyId = bountyId ?? (bountyName == null ? null : bountyIdFromText(bountyName) ?? 0);

  final int id;
  final MissionType type;
  final int target;
  final int rewardCredits;
  final int rewardGems;
  final int? planetIndex;
  /// 현상수배범 이름표 번호 ([bountyNameOf]). 저장 키 'bid'
  final int? bountyId;

  /// 현상수배범 이름 (현재 언어로)
  String? get bountyName => bountyId == null ? null : bountyNameOf(bountyId!);
  int progress = 0;
  bool bountySpawned = false;

  bool get done => progress >= target;

  String title(List<Planet> planets) => switch (type) {
        MissionType.kill => tr.g_missionKill(target),
        MissionType.mine => tr.g_missionMine(target),
        MissionType.deliver => tr.g_missionDeliver(
            euro(planetIndex != null && planetIndex! < planets.length ? planets[planetIndex!].name : '?')),
        MissionType.bounty => tr.g_missionBounty(bountyName ?? ''),
      };

  String get icon => switch (type) {
        MissionType.kill => '⚔',
        MissionType.mine => '⛏',
        MissionType.deliver => '📦',
        MissionType.bounty => '🎯',
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'target': target,
        'rc': rewardCredits,
        'rg': rewardGems,
        'planet': planetIndex,
        'bid': bountyId,
        // 예전 버전 앱이 읽을 수 있게 표시용 이름도 남긴다 (불러올 때는 'bid'가 우선)
        'bounty': bountyName,
        'progress': progress,
      };

  static Mission fromJson(Map<String, dynamic> j) {
    final type = MissionType.values[j['type'] as int];
    return Mission(
      id: j['id'] as int,
      type: type,
      target: j['target'] as int,
      rewardCredits: j['rc'] as int,
      rewardGems: j['rg'] as int,
      planetIndex: j['planet'] as int?,
      bountyId: _bountyIdFromJson(j, type),
    )..progress = j['progress'] as int;
  }

  /// 새 저장은 'bid'. 예전 저장은 저장 당시 언어의 이름 문자열이라 어느 언어 이름인지 찾아 번호로 되돌리고,
  /// 모르는 이름이면 현상수배 임무는 0번 이름표로 둔다.
  static int? _bountyIdFromJson(Map<String, dynamic> j, MissionType type) {
    final bid = j['bid'];
    if (bid is int && bid >= 0 && bid < bountyCount) return bid;
    final legacy = j['bounty'];
    final id = bountyIdFromText(legacy is String ? legacy : null);
    if (id != null) return id;
    return type == MissionType.bounty ? 0 : null;
  }
}

/// 현상수배범 이름 (현재 언어로). 저장·비교에는 번호([Mission.bountyId])를 쓴다.
List<String> get bountyNames => [for (var i = 0; i < bountyCount; i++) bountyNameOf(i)];

/// 스토리 진행 단계 (튜토리얼 겸용)
class StoryStep {
  const StoryStep(this.title, this.key, this.target, this.lines,
      {this.relative = false, this.credits = 100, this.gems = 5});
  final String title;

  /// GameWorld.storyValue(key) 로 진행도 측정
  final String key;
  final int target;
  final bool relative;
  final List<(Speaker, String)> lines;
  final int credits;
  final int gems;
}

List<StoryStep> get storySteps => [
  StoryStep(tr.g_storyAsteroidsTitle, 'asteroids', 3, [
    (Speaker.advisor, tr.g_storyAsteroidsLine0),
    (Speaker.advisor, tr.g_storyAsteroidsLine1),
  ], relative: true, credits: 60),
  // 내 함선이 잡은 해적만 (본거지 레이저 처치는 세지 않는다)
  StoryStep(tr.g_storyKillsTitle, 'shipKills', 3, [
    (Speaker.advisor, tr.g_storyKillsLine0),
    (Speaker.captain, tr.g_storyKillsLine1),
  ], relative: true, credits: 120),
  StoryStep(tr.g_storyColoniesTitle, 'colonies', 1, [
    (Speaker.advisor, tr.g_storyColoniesLine0),
    (Speaker.advisor, tr.g_storyColoniesLine1),
  ], credits: 150),
  StoryStep(tr.g_storyShipLevelsTitle, 'shipLevels', 1, [
    (Speaker.advisor, tr.g_storyShipLevelsLine0),
  ], credits: 100),
  StoryStep(tr.g_storyCrewTitle, 'crew', 1, [
    (Speaker.advisor, tr.g_storyCrewLine0),
  ], credits: 200),
  StoryStep(tr.g_storyMissionsTitle, 'missions', 1, [
    (Speaker.advisor, tr.g_storyMissionsLine0),
  ], relative: true, credits: 150),
  StoryStep(tr.g_storyStationsTitle, 'stations', 2, [
    (Speaker.advisor, tr.g_storyStationsLine0),
  ], credits: 300, gems: 10),
  StoryStep(tr.g_storyDevPercentTitle, 'devPercent', 100, [
    (Speaker.advisor, tr.g_storyDevPercentLine0),
  ], credits: 500, gems: 15),
  StoryStep(tr.g_storySectorTitle, 'sector', 1, [
    (Speaker.advisor, tr.g_storySectorLine0),
    (Speaker.captain, tr.g_storySectorLine1),
  ], credits: 300, gems: 10),
];

/// 스토리 단계가 목표로 하는 항성계 번호 (발전도 단계용)
int storySectorAt(int index) =>
    index < storySteps.length ? 0 : (index - storySteps.length) ~/ 2 + 1;

/// 무한 스토리: 기본 단계 이후 항성계마다 발전 → 워프 반복
StoryStep storyStepAt(int index) {
  if (index < storySteps.length) return storySteps[index];
  final k = index - storySteps.length;
  final sector = k ~/ 2 + 1;
  if (k.isEven) {
    return StoryStep(tr.g_storyDevNTitle(sector + 1), 'devPercent', 100, [
      (Speaker.advisor, tr.g_storyDevNLine),
    ], credits: 500 * (sector + 1), gems: 15);
  }
  return StoryStep(tr.g_storyWarpNTitle(euro(tr.g_systemN(sector + 2))), 'sector', sector + 1, [
    (Speaker.advisor, tr.g_storyWarpNLine),
  ], credits: 300 * (sector + 1), gems: 10);
}
