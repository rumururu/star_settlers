import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../game/models.dart';
import '../game/profile.dart';
import '../game/save.dart';
import '../services/ads.dart';
import '../services/app_state.dart';
import '../services/audio.dart';
import '../services/cloud_backup.dart';
import '../services/feedback.dart';
import '../services/notifications.dart';
import '../services/orientation.dart';
import '../l10n/l.dart';
import 'common.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    final p = AppState.profile;
    final done = achievements.where((a) => p.claimed.contains(a.id)).length;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B26),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151236),
        title: Text(tr.m_achievementsTitle(done, achievements.length)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final a in achievements)
            Card(
              color: p.claimed.contains(a.id) ? const Color(0xFF1B3A2A) : const Color(0xFF1E1A4A),
              child: ListTile(
                title: Text(a.title, style: bodyStyle),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.desc, style: dimStyle),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (p.stat(a.stat) / a.target).clamp(0, 1),
                      color: const Color(0xFF7CFFB2),
                      backgroundColor: Colors.white12,
                    ),
                    Text('${p.stat(a.stat).clamp(0, a.target)} / ${a.target}', style: dimStyle),
                  ],
                ),
                trailing: p.claimed.contains(a.id)
                    ? Text(tr.m_done, style: const TextStyle(color: Color(0xFF7CFFB2)))
                    : actionBtn(tr.m_claimGems(a.gems), p.isComplete(a), () async {
                        p.claim(a);
                        AppState.play(Sfx.gem);
                        await SaveService.saveProfile(p);
                        setState(() {});
                      }, color: const Color(0xFFAD1457)),
              ),
            ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// 화면을 열 때 한 번만 묻는다 (스위치를 켤 때마다 다시 묻고 깜박이지 않게)
  final Future<bool> _adPrivacyRequired = AdService.instance.privacyOptionsRequired();

  Future<void> _save() async {
    await SaveService.saveProfile(AppState.profile);
    setState(() {});
  }

  /// 언어 선택: 기기 언어(null) 또는 지원 언어 중 하나. 각 언어는 그 언어 자신의 이름으로 보인다.
  Future<void> _pickLanguage() async {
    final p = AppState.profile;
    const system = '';
    final picked = await showDialog<String>(
      context: context,
      builder: (c) => SimpleDialog(
        backgroundColor: kPanelColor,
        title: Text(tr.m_settingsLanguage),
        children: [
          for (final code in [system, ...L10n.supportedLocales.map((l) => l.languageCode)])
            ListTile(
              title: Text(code == system ? tr.m_languageSystem : lookupL10n(Locale(code)).languageName),
              trailing: (p.language ?? system) == code ? const Icon(Icons.check, color: Color(0xFF7CFFB2)) : null,
              onTap: () => Navigator.pop(c, code),
            ),
        ],
      ),
    );
    if (picked == null) return;
    p.language = picked == system ? null : picked;
    Lang.apply(p.language);
    await _save();
  }

  /// 화면 방향 선택: 자동 / 세로 / 가로. 고르면 바로 적용하고 저장한다.
  Future<void> _pickOrientation() async {
    final p = AppState.profile;
    final picked = await showDialog<ScreenOrient>(
      context: context,
      builder: (c) => SimpleDialog(
        backgroundColor: kPanelColor,
        title: Text(tr.m_settingsOrientation),
        children: [
          for (final o in ScreenOrient.values)
            ListTile(
              leading: Icon(orientIcon(o)),
              title: Text(orientLabel(o)),
              trailing: p.orientation == o ? const Icon(Icons.check, color: Color(0xFF7CFFB2)) : null,
              onTap: () => Navigator.pop(c, o),
            ),
        ],
      ),
    );
    if (picked == null || picked == p.orientation) return;
    p.orientation = picked;
    await applyOrientation(picked);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppState.profile;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B26),
      appBar: AppBar(backgroundColor: const Color(0xFF151236), title: Text(tr.m_settingsTitle)),
      body: contentWidth(ListView(
        children: [
          SwitchListTile(
            title: Text(tr.m_settingsSound),
            value: p.sound,
            onChanged: (v) {
              p.sound = v;
              AudioService.instance.soundOn = v;
              _save();
            },
          ),
          SwitchListTile(
            title: Text(tr.m_settingsMusic),
            value: p.music,
            onChanged: (v) {
              p.music = v;
              AudioService.instance.setMusic(v);
              _save();
            },
          ),
          SwitchListTile(
            title: Text(tr.m_settingsNotify),
            subtitle: Text(keepAll(tr.m_settingsNotifyDesc)),
            value: p.notifications,
            onChanged: (v) {
              p.notifications = v;
              if (!v) NotificationService.instance.cancelAll();
              _save();
            },
          ),
          SwitchListTile(
            title: Text(tr.m_settingsHaptics),
            value: p.haptics,
            onChanged: (v) {
              p.haptics = v;
              _save();
            },
          ),
          // 주간 순위표 참여 (순위 화면의 스위치와 같은 값)
          if (AppState.leaderboard.configured)
            SwitchListTile(
              title: Text(tr.lb_join),
              subtitle: Text(keepAll(tr.lb_joinDesc)),
              value: p.leaderboardOptIn,
              onChanged: (v) async {
                await AppState.leaderboard.setOptIn(v);
                if (v) AppState.submitLeaderboard();
                setState(() {});
              },
            ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(tr.m_settingsLanguage == 'Language' ? 'Language' : '${tr.m_settingsLanguage} / Language'),
            subtitle: Text(p.language == null ? tr.m_languageSystem : lookupL10n(Locale(p.language!)).languageName),
            onTap: _pickLanguage,
          ),
          ListTile(
            leading: Icon(orientIcon(p.orientation)),
            title: Text(tr.m_settingsOrientation),
            subtitle: Text(orientLabel(p.orientation)),
            onTap: _pickOrientation,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(tr.m_restorePurchases),
            onTap: () async {
              await AppState.money.restore();
              if (context.mounted) toast(context, tr.m_restoreDone);
            },
          ),
          if (CloudBackup.supported) const CloudBackupTiles(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(tr.m_privacyTitle),
            onTap: () => showDialog<void>(
              context: context,
              builder: (c) => AlertDialog(
                backgroundColor: kPanelColor,
                title: Text(tr.m_privacyTitle),
                content: SingleChildScrollView(child: SelectableText(tr.m_privacyBody(FeedbackService.email))),
                actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(tr.m_close))],
              ),
            ),
          ),
          // 광고 동의가 필요한 지역(유럽 등)에서만: 동의 변경·철회
          FutureBuilder<bool>(
            future: _adPrivacyRequired,
            builder: (context, snap) => snap.data != true
                ? const SizedBox.shrink()
                : ListTile(
                    leading: const Icon(Icons.ads_click),
                    title: Text(tr.m_adPrivacy),
                    onTap: AdService.instance.showPrivacyOptions,
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: Text(tr.m_wipeTitle, style: const TextStyle(color: Colors.redAccent)),
            subtitle: Text(keepAll(tr.m_wipeDesc)),
            onTap: () async {
              if (!await confirmDialog(context, tr.m_wipeConfirmTitle, tr.m_wipeConfirmBody,
                  ok: tr.m_wipeOk)) {
                return;
              }
              // 순위표에 참여했으면 서버 기록도 지운다 (기다리지 않음 — 실패해도 초기화는 진행)
              AppState.forgetLeaderboard();
              await SaveService.wipeAll();
              AppState.resetProfile();
              // 설정도 처음으로: 화면 방향은 기본(세로)으로 돌아간다
              applyOrientation(AppState.profile.orientation);
              if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(tr.m_feedbackTitle),
            subtitle: Text(keepAll(tr.m_feedbackDesc)),
            onTap: () async {
              if (!await FeedbackService.send() && context.mounted) {
                toast(context, tr.m_noMailApp(FeedbackService.email));
              }
            },
          ),
          ListTile(title: Text(tr.m_aboutTitle), subtitle: Text(tr.m_version('1.0.0'))),
        ],
      )),
    );
  }
}

class DailyQuestScreen extends StatefulWidget {
  const DailyQuestScreen({super.key});

  @override
  State<DailyQuestScreen> createState() => _DailyQuestScreenState();
}

class _DailyQuestScreenState extends State<DailyQuestScreen> {
  Future<void> _claim(String id) async {
    final p = AppState.profile;
    if (!p.claimDaily(id)) return;
    AppState.play(Sfx.gem);
    await SaveService.saveProfile(p);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = AppState.profile..refreshDaily(DateTime.now());
    final now = DateTime.now();
    final reset = DateTime(now.year, now.month, now.day + 1).difference(now);
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B26),
      appBar: AppBar(backgroundColor: const Color(0xFF151236), title: Text(tr.m_dailyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(tr.m_dailyReset(reset.inHours, reset.inMinutes % 60), style: dimStyle),
          const SizedBox(height: 8),
          for (final q in p.dailyQuests)
            Card(
              color: p.dailyClaimed.contains(q.id) ? const Color(0xFF1B3A2A) : const Color(0xFF1E1A4A),
              child: ListTile(
                title: Text(q.title, style: bodyStyle),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: p.dailyProgress(q) / q.target,
                      color: const Color(0xFF7CFFB2),
                      backgroundColor: Colors.white12,
                    ),
                    Text('${p.dailyProgress(q)} / ${q.target}', style: dimStyle),
                  ],
                ),
                trailing: p.dailyClaimed.contains(q.id)
                    ? Text(tr.m_done, style: const TextStyle(color: Color(0xFF7CFFB2)))
                    : actionBtn(tr.m_claimGems(q.gems), p.dailyDone(q), () => _claim(q.id),
                        color: const Color(0xFFAD1457)),
              ),
            ),
          const SizedBox(height: 8),
          Card(
            color: const Color(0xFF311B92),
            child: ListTile(
              title: Text(tr.m_dailyBonusTitle, style: bodyStyle),
              subtitle: Text(keepAll(tr.m_dailyBonusDesc), style: dimStyle),
              trailing: p.dailyClaimed.contains('bonus')
                  ? Text(tr.m_done, style: const TextStyle(color: Color(0xFF7CFFB2)))
                  : actionBtn(tr.m_claimGems(dailyBonusGems), p.dailyBonusReady, () => _claim('bonus'),
                      color: const Color(0xFFAD1457)),
            ),
          ),
        ],
      ),
    );
  }
}

/// 화면 방향 이름 (설정 목록)
String orientLabel(ScreenOrient o) => switch (o) {
      ScreenOrient.auto => tr.m_orientAuto,
      ScreenOrient.portrait => tr.m_orientPortrait,
      ScreenOrient.landscape => tr.m_orientLandscape,
    };

IconData orientIcon(ScreenOrient o) => switch (o) {
      ScreenOrient.auto => Icons.screen_rotation,
      ScreenOrient.portrait => Icons.stay_current_portrait,
      ScreenOrient.landscape => Icons.stay_current_landscape,
    };

/// 설정 > 클라우드 백업 (Android: Google Play 게임즈, iOS: Game Center)
class CloudBackupTiles extends StatefulWidget {
  const CloudBackupTiles({super.key});

  @override
  State<CloudBackupTiles> createState() => _CloudBackupTilesState();
}

class _CloudBackupTilesState extends State<CloudBackupTiles> {
  CloudBackup get _cloud => AppState.cloud;
  bool? _signedIn;
  bool _busy = false;

  static String get service => Platform.isIOS ? 'Game Center' : 'Google Play Games';

  @override
  void initState() {
    super.initState();
    _cloud.isSignedIn.then((v) {
      if (mounted) setState(() => _signedIn = v);
    });
  }

  String _time(DateTime t) => DateFormat.yMd(Localizations.localeOf(context).toString()).add_Hm().format(t);

  Future<void> _run(Future<void> Function() job) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await job();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _connect() => _run(() async {
        final ok = await _cloud.signIn();
        if (!mounted) return;
        setState(() => _signedIn = ok);
        if (!ok) {
          toast(context, tr.m_cloudConnectFailed(service));
          return;
        }
        // 다른 기기(또는 지우기 전)의 백업이 있고 이 기기는 아직 백업·복원을 한 적이 없으면 복원을 먼저 묻는다
        if (AppState.profile.cloudLinked) return;
        final (_, snap) = await _cloud.peek();
        if (snap == null || !mounted) return;
        if (await confirmDialog(context, tr.m_cloudFoundTitle, tr.m_cloudFoundBody(_time(snap.savedAt)),
            ok: tr.m_cloudRestoreOk, cancel: tr.m_cloudLater)) {
          await _restore(snap);
        }
      });

  Future<void> _backup() => _run(() async {
        // 이 기기에서 처음 백업할 때 클라우드에 다른 진행이 있으면 덮어쓰기 전에 묻는다
        if (!AppState.profile.cloudLinked) {
          final (_, snap) = await _cloud.peek();
          if (snap != null && snap.installId != AppState.profile.installId) {
            if (!mounted) return;
            if (!await confirmDialog(context, tr.m_cloudOverwriteTitle, tr.m_cloudOverwriteBody(_time(snap.savedAt)),
                ok: tr.m_cloudOverwriteOk)) {
              return;
            }
          }
        }
        final r = await _cloud.backupNow();
        if (!mounted) return;
        toast(context, r == BackupStatus.ok ? tr.m_cloudBackedUp : tr.m_cloudFailed);
      });

  Future<void> _askRestore() => _run(() async {
        final (status, snap) = await _cloud.peek();
        if (!mounted) return;
        if (snap == null) {
          toast(context, status == BackupStatus.nothingToRestore ? tr.m_cloudNoBackup : tr.m_cloudFailed);
          return;
        }
        if (!await confirmDialog(context, tr.m_cloudRestoreTitle, tr.m_cloudRestoreBody(_time(snap.savedAt)),
            ok: tr.m_cloudRestoreOk)) {
          return;
        }
        await _restore(snap);
      });

  Future<void> _restore(CloudSnapshot snap) async {
    final (status, restored) = await _cloud.restore(snap);
    if (restored == null || status != BackupStatus.ok) {
      if (mounted) toast(context, tr.m_cloudFailed);
      return;
    }
    await AppState.adoptRestored(restored);
    // 설정도 백업의 것으로
    Lang.apply(restored.language);
    applyOrientation(restored.orientation);
    AudioService.instance
      ..soundOn = restored.sound
      ..setMusic(restored.music);
    if (!mounted) return;
    toast(context, tr.m_cloudRestored);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final p = AppState.profile;
    final at = p.cloudBackupAt;
    if (_signedIn != true) {
      return ListTile(
        leading: const Icon(Icons.cloud_outlined),
        title: Text(tr.m_cloudTitle),
        subtitle: Text(keepAll(tr.m_cloudDesc(service))),
        trailing: _busy ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
        onTap: _signedIn == null ? null : _connect,
      );
    }
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.cloud_upload_outlined),
          title: Text(tr.m_cloudBackupNow),
          subtitle: Text(at == null ? tr.m_cloudNever : tr.m_cloudLast(_time(at))),
          trailing: _busy ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
          onTap: _backup,
        ),
        ListTile(
          leading: const Icon(Icons.cloud_download_outlined),
          title: Text(tr.m_cloudRestore),
          subtitle: Text(keepAll(tr.m_cloudAccount((_cloud.playerName ?? '').isEmpty ? service : '$service · ${_cloud.playerName}'))),
          onTap: _askRestore,
        ),
      ],
    );
  }
}
