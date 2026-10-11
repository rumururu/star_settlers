import 'package:flutter/material.dart';

import '../game/save.dart';
import '../l10n/l.dart';
import '../services/app_state.dart';
import '../services/leaderboard.dart';
import 'common.dart';

/// 주간 순위표 화면. 참여(동의)는 기본 꺼짐이고, 켜야만 점수를 보낸다.
/// 보내는 것: 무작위 설치 ID, 자동으로 만든 별명 코드, 이번 주 개척 점수.
/// 앱 전역 상태(프로필·저장)에 연결된 순위표 화면
Widget appLeaderboardScreen() => LeaderboardScreen(
      service: AppState.leaderboard,
      score: AppState.profile.weeklyScore,
      onScoreChanged: () => SaveService.saveProfile(AppState.profile),
      onSubmitted: AppState.markSubmitted,
    );

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen(
      {super.key, required this.service, required this.score, this.onScoreChanged, this.onSubmitted});

  final LeaderboardService service;
  final WeeklyScore score;

  /// [WeeklyScore]가 바뀌었을 때(주 넘김·지난주 점수 전송) 저장하도록 부른다
  final Future<void> Function()? onScoreChanged;

  /// 이 화면에서 점수를 보냈을 때 (자동 제출 간격 맞추기용)
  final VoidCallback? onSubmitted;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  LeaderboardService get _svc => widget.service;

  bool _loading = false;
  BoardResult? _board;
  SubmitResult? _submit;

  @override
  void initState() {
    super.initState();
    if (_svc.configured) _refresh();
  }

  Future<void> _refresh() async {
    if (_loading) return;
    setState(() => _loading = true);
    SubmitResult? sub;
    final s = widget.score..rollover();
    // 0점은 올리지 않는다 (참여만 해 둔 0점 줄이 순위를 채우지 않게)
    if (_svc.optedIn && (s.points > 0 || s.lastPoints > 0)) {
      sub = await _svc.submitWeekly(s);
      widget.onSubmitted?.call();
      await widget.onScoreChanged?.call();
    }
    final board = await _svc.fetch(widget.score.week);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _submit = sub;
      _board = board;
    });
  }

  Future<void> _setOptIn(bool v) async {
    await _svc.setOptIn(v);
    if (!mounted) return;
    setState(() => _submit = null);
    _refresh();
  }

  void _reroll() {
    _svc.reroll();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    widget.score.rollover();
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B26),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151236),
        title: Text(tr.lb_title),
        actions: [
          if (_svc.configured)
            IconButton(
              tooltip: tr.lb_refresh,
              onPressed: _loading ? null : _refresh,
              icon: const Icon(Icons.refresh),
              constraints: const BoxConstraints(minWidth: Tap.min, minHeight: Tap.min),
            ),
        ],
      ),
      body: contentWidth(RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(Space.m),
          children: [
            _optInCard(),
            const SizedBox(height: Space.m),
            if (_svc.optedIn) ...[_meCard(), const SizedBox(height: Space.m)],
            ..._boardSection(),
          ],
        ),
      )),
    );
  }

  Widget _optInCard() => glass(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(keepAll(tr.lb_join), style: titleStyle),
              value: _svc.optedIn,
              onChanged: _svc.configured ? _setOptIn : null,
            ),
            Text(keepAll(tr.lb_joinDesc), style: dimStyle),
            const SizedBox(height: Space.s),
            Text(keepAll(tr.lb_howTo), style: Ts.caption.copyWith(color: kSky)),
            Text(keepAll(tr.lb_resets), style: Ts.caption),
          ],
        ),
        padding: const EdgeInsets.all(Space.m),
      );

  Widget _meCard() {
    final code = _svc.nicknameCode;
    final sub = _submit;
    final mine = _board?.mine;
    final rank = mine?.rank ?? sub?.rank;
    final total = sub?.total;
    return glass(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.lb_yourNick, style: dimStyle),
          const SizedBox(height: Space.xs),
          Wrap(
            spacing: Space.s,
            runSpacing: Space.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(nicknameText(code, tr), style: Ts.title.copyWith(color: kSky)),
              actionBtn(tr.lb_reroll(_svc.rerollsLeft), _svc.canReroll, _reroll, leadingIcon: Icons.casino),
            ],
          ),
          const SizedBox(height: Space.s),
          Row(
            children: [
              Expanded(child: Text(tr.lb_weekPoints(groupDigits(widget.score.points)), style: bodyStyle)),
              if (rank != null)
                Text(
                  total != null ? tr.lb_rank(rank, total) : tr.lb_rankOnly(rank),
                  style: Ts.headingBold.copyWith(color: const Color(0xFFFFD54F)),
                ),
            ],
          ),
          if (sub != null && sub.status != LeaderboardStatus.ok) ...[
            const SizedBox(height: Space.xs),
            Text(keepAll(_statusText(sub.status)), style: dimStyle),
          ],
        ],
      ),
      padding: const EdgeInsets.all(Space.m),
    );
  }

  List<Widget> _boardSection() {
    if (!_svc.configured) {
      return [_message(_statusText(LeaderboardStatus.notConfigured))];
    }
    final board = _board;
    if (board == null || (_loading && board.entries.isEmpty)) {
      return [
        const Padding(
          padding: EdgeInsets.all(Space.xl),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (board.status != LeaderboardStatus.ok) {
      return [
        _message(_statusText(board.status)),
        const SizedBox(height: Space.m),
        Center(child: actionBtn(tr.lb_retry, !_loading, _refresh)),
      ];
    }
    if (board.entries.isEmpty) {
      return [_message(tr.lb_empty)];
    }
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.s),
        child: Text(tr.lb_top50, style: sectionStyle),
      ),
      for (final e in board.entries) _row(e),
    ];
  }

  Widget _row(LeaderboardEntry e) {
    final medal = switch (e.rank) { 1 => '🥇', 2 => '🥈', 3 => '🥉', _ => null };
    return Container(
      key: e.me ? const ValueKey('lb_my_row') : null,
      margin: const EdgeInsets.only(bottom: Space.xs),
      constraints: const BoxConstraints(minHeight: Tap.min),
      padding: const EdgeInsets.symmetric(horizontal: Space.m, vertical: Space.s),
      decoration: BoxDecoration(
        color: e.me ? const Color(0xFF3A2F7A) : const Color(0xFF1E1A4A),
        borderRadius: BorderRadius.circular(12),
        border: e.me ? Border.all(color: kSky, width: 2) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(medal ?? '${e.rank}', style: medal != null ? Ts.heading : bodyStyle),
          ),
          Expanded(
            child: Text(
              nicknameText(e.nicknameCode, tr),
              style: e.me ? Ts.headingBold.copyWith(color: kSky) : bodyStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: Space.s),
          Text(groupDigits(e.score), style: Ts.headingBold.copyWith(color: const Color(0xFFFFD54F))),
        ],
      ),
    );
  }

  Widget _message(String s) => Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Text(keepAll(s), style: bodyStyle, textAlign: TextAlign.center),
      );

  static String _statusText(LeaderboardStatus s) => switch (s) {
        LeaderboardStatus.ok => '',
        LeaderboardStatus.optedOut => tr.lb_optedOut,
        LeaderboardStatus.notConfigured => tr.lb_unavailable,
        LeaderboardStatus.offline => tr.lb_offline,
        LeaderboardStatus.rateLimited => tr.lb_rateLimited,
        LeaderboardStatus.rejected => tr.lb_rejected,
        LeaderboardStatus.serverError => tr.lb_serverError,
      };
}

/// 1234567 → "1,234,567"
String groupDigits(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}
