import 'package:flutter/material.dart';

import '../game/models.dart';
import '../game/profile.dart';
import '../game/save.dart';
import '../services/app_state.dart';
import '../services/audio.dart';
import '../services/feedback.dart';
import '../services/notifications.dart';
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

  @override
  Widget build(BuildContext context) {
    final p = AppState.profile;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B26),
      appBar: AppBar(backgroundColor: const Color(0xFF151236), title: Text(tr.m_settingsTitle)),
      body: ListView(
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
            subtitle: Text(tr.m_settingsNotifyDesc),
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
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(tr.m_settingsLanguage == 'Language' ? 'Language' : '${tr.m_settingsLanguage} / Language'),
            subtitle: Text(p.language == null ? tr.m_languageSystem : lookupL10n(Locale(p.language!)).languageName),
            onTap: _pickLanguage,
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
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(tr.m_privacyTitle),
            onTap: () => showDialog<void>(
              context: context,
              builder: (c) => AlertDialog(
                backgroundColor: kPanelColor,
                title: Text(tr.m_privacyTitle),
                content: SingleChildScrollView(child: Text(tr.m_privacyBody(FeedbackService.email))),
                actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(tr.m_close))],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: Text(tr.m_wipeTitle, style: const TextStyle(color: Colors.redAccent)),
            subtitle: Text(tr.m_wipeDesc),
            onTap: () async {
              if (!await confirmDialog(context, tr.m_wipeConfirmTitle, tr.m_wipeConfirmBody,
                  ok: tr.m_wipeOk)) {
                return;
              }
              await SaveService.wipeAll();
              AppState.profile = Profile();
              AppState.world = null;
              if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(tr.m_feedbackTitle),
            subtitle: Text(tr.m_feedbackDesc),
            onTap: () async {
              if (!await FeedbackService.send() && context.mounted) {
                toast(context, tr.m_noMailApp(FeedbackService.email));
              }
            },
          ),
          ListTile(title: Text(tr.m_aboutTitle), subtitle: Text(tr.m_version('1.0.0'))),
        ],
      ),
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
              subtitle: Text(tr.m_dailyBonusDesc, style: dimStyle),
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
