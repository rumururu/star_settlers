import 'profile.dart';

/// 7일 출석 달력 (TASK 004). 젬 액수는 서버가 연속일로 계산한다([loginRewards], `starset_login_gems`) —
/// 여기서는 칸 번호와 그 칸의 **클라이언트 보상**(광석·승무원·크레딧·전용 스킨)만 정한다.
///
/// 칸 = 연속 출석일을 7로 나눈 자리 (1~7). 하루라도 빠지면 연속이 1로 돌아가므로 1칸부터.
enum CalendarRewardKind { none, ore, crew2, credits, skin, crew3 }

class CalendarReward {
  const CalendarReward(this.kind, [this.amount = 0]);
  final CalendarRewardKind kind;

  /// 광석·크레딧 기본량 (지급할 때 그 월드의 보상 배율을 곱한다)
  final int amount;
}

/// 출석 전용 함선 스킨 id ([attendanceSkin], 상점에서 팔지 않는다)
const attendanceSkinId = 'attendance';

abstract final class Attendance {
  static const days = 7;
  static const oreAmount = 150;
  static const creditAmount = 1000;

  /// 연속 [streak]일째가 달력 몇 번째 칸인가 (1~7)
  static int cell(int streak) => (streak - 1) % days + 1;

  /// 연속 출석 몇 번째 주(0부터)
  static int week(int streak) => (streak - 1) ~/ days;

  /// [cell]칸의 클라이언트 보상. 7칸 스킨은 한 번만 — 이미 있으면 ★3 승무원.
  static CalendarReward rewardFor(int cell, {required bool skinOwned}) =>
      switch (cell) {
        2 => const CalendarReward(CalendarRewardKind.ore, oreAmount),
        3 => const CalendarReward(CalendarRewardKind.crew2),
        5 => const CalendarReward(CalendarRewardKind.credits, creditAmount),
        7 =>
          skinOwned
              ? const CalendarReward(CalendarRewardKind.crew3)
              : const CalendarReward(CalendarRewardKind.skin),
        _ => const CalendarReward(CalendarRewardKind.none),
      };

  /// 젬 (서버와 같은 표, 보여 주기용)
  static int gemsFor(int cell) => loginRewards[cell - 1];

  /// 오늘 받으면 연속 며칠째가 되는가 (어제 받았으면 +1, 아니면 1). 오늘 이미 받았으면 지금 연속.
  static int streakToday(Profile p, DateTime now) {
    final today = Profile.dayKey(now);
    if (today <= p.lastLoginDay) return p.loginStreak;
    final y = Profile.dayKey(now.subtract(const Duration(days: 1)));
    return y == p.lastLoginDay ? p.loginStreak + 1 : 1;
  }

  /// 오늘 받을 수 있는가 (시계를 되돌려 같은 날·과거로 다시 받는 것은 막는다)
  static bool claimable(Profile p, DateTime now) => p.pendingLogin(now) != null;

  /// 내일 받으면 연속 며칠째 (오늘 받는다고 가정)
  static int streakTomorrow(Profile p, DateTime now) => streakToday(p, now) + 1;

  /// 달력 칸 i(1~7)의 상태: 지난 칸(받음) / 오늘 / 앞으로
  static CellState stateOf(int i, Profile p, DateTime now) {
    final today = cell(streakToday(p, now));
    if (i < today) return CellState.past;
    if (i == today) {
      return claimable(p, now) ? CellState.today : CellState.claimedToday;
    }
    return CellState.future;
  }

  /// 게임 화면 안에서 달력을 띄울까: 받을 보상이 있고,
  /// 처음 받는 플레이어는 첫 튜토리얼(소행성·해적, 스토리 2단계)을 마친 뒤.
  static bool showInGame(Profile p, DateTime now, {required int storyIndex}) =>
      claimable(p, now) && (p.lastLoginDay != 0 || storyIndex >= 2);

  /// 출석 수령: 서버 젬([Profile.claimLogin]) + 그 칸의 클라이언트 보상.
  /// 월드 보상(광석·크레딧·승무원)은 프로필에 쌓았다가 게임 화면이 월드에 넣는다 (타이틀에서도 받을 수 있게).
  /// 반환: (받은 젬, 칸, 클라이언트 보상). 받을 게 없으면 null.
  static (int, int, CalendarReward)? claim(Profile p, DateTime now) {
    if (!claimable(p, now)) return null;
    final gems = p.claimLogin(now);
    final c = cell(p.loginStreak);
    final r = rewardFor(c, skinOwned: p.ownedSkins.contains(attendanceSkinId));
    switch (r.kind) {
      case CalendarRewardKind.ore:
        p.pendingOre += r.amount;
      case CalendarRewardKind.credits:
        p.pendingCredits += r.amount;
      case CalendarRewardKind.crew2:
        p.pendingCrew2++;
      case CalendarRewardKind.crew3:
        p.pendingStarCrew++;
      case CalendarRewardKind.skin:
        p.ownedSkins.add(attendanceSkinId);
      case CalendarRewardKind.none:
        break;
    }
    p.dirty = true;
    return (gems, c, r);
  }
}

enum CellState { past, today, claimedToday, future }
