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
    this.bountyName,
  });

  final int id;
  final MissionType type;
  final int target;
  final int rewardCredits;
  final int rewardGems;
  final int? planetIndex;
  final String? bountyName;
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
        'bounty': bountyName,
        'progress': progress,
      };

  static Mission fromJson(Map<String, dynamic> j) => Mission(
        id: j['id'] as int,
        type: MissionType.values[j['type'] as int],
        target: j['target'] as int,
        rewardCredits: j['rc'] as int,
        rewardGems: j['rg'] as int,
        planetIndex: j['planet'] as int?,
        bountyName: j['bounty'] as String?,
      )..progress = j['progress'] as int;
}

List<String> get bountyNames => [
      tr.g_bounty0,
      tr.g_bounty1,
      tr.g_bounty2,
      tr.g_bounty3,
      tr.g_bounty4,
      tr.g_bounty5,
      tr.g_bounty6,
      tr.g_bounty7,
      tr.g_bounty8,
      tr.g_bounty9,
    ];

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
  StoryStep(tr.g_storyKillsTitle, 'kills', 3, [
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
