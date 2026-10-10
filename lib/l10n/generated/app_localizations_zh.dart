// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class L10nZh extends L10n {
  L10nZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Star Settlers';

  @override
  String get languageName => '中文';

  @override
  String get u_tabShip => '飞船';

  @override
  String get u_tabStation => '空间站';

  @override
  String get u_tabCrew => '船员';

  @override
  String get u_tabMission => '任务';

  @override
  String get u_tabMarket => '市场';

  @override
  String u_upWeapon(int dmg) {
    return '攻击力 $dmg · Lv.3 双发 · Lv.6 三发';
  }

  @override
  String u_upHull(int hp) {
    return '最大生命 $hp';
  }

  @override
  String u_upEngine(int speed) {
    return '最高速度 $speed';
  }

  @override
  String get u_upMissileIntro => '追踪敌人的导弹（Q键 / 🚀按钮）';

  @override
  String u_upMissile(int count, String cooldown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count发',
    );
    return '$_temp0 · 冷却$cooldown秒';
  }

  @override
  String get u_upShieldIntro => '抵挡一切伤害的护盾（F键 / 🛡按钮）';

  @override
  String u_upShield(String duration, String cooldown) {
    return '$duration秒 · 冷却$cooldown秒';
  }

  @override
  String get u_upDroneIntro => '环绕在身边自动射击，还会吸取道具';

  @override
  String u_upDrone(int dmg, String interval) {
    return '伤害 $dmg · 每$interval秒发射';
  }

  @override
  String u_upMagnet(int range, String power) {
    return '吸取信用点和矿石 · 范围 $range · 力度 x$power';
  }

  @override
  String get u_equip => '装备';

  @override
  String get u_hangarSection => '🛸 机库';

  @override
  String get u_viewLarge => '查看';

  @override
  String get u_hp => '生命';

  @override
  String get u_speed => '速度';

  @override
  String get u_attack => '攻击';

  @override
  String get u_fireRate => '射速';

  @override
  String get u_ore => '矿石';

  @override
  String get u_crit => '暴击';

  @override
  String get u_boarded => '搭乘中';

  @override
  String get u_board => '搭乘';

  @override
  String get u_boardNow => '立即搭乘';

  @override
  String get u_gemsOnly => '仅限宝石购买';

  @override
  String u_unlockOrGems(String condition) {
    return '解锁：$condition 或宝石';
  }

  @override
  String u_unlock(String condition) {
    return '解锁：$condition';
  }

  @override
  String u_durability(int hp, int max) {
    return '耐久 $hp / $max';
  }

  @override
  String get u_habitat => '居住区';

  @override
  String u_habitatDesc(String rate, int hp) {
    return '收入 💰$rate/s · 耐久 $hp';
  }

  @override
  String get u_turret => '防御炮塔';

  @override
  String get u_turretIntro => '自动拦截海盗';

  @override
  String u_turretDesc(int dmg, int range) {
    return '伤害 $dmg · 射程 $range';
  }

  @override
  String get u_baseUpgrade => '基地强化';

  @override
  String u_baseDesc(int dmg, int range, int hp) {
    return '激光 $dmg · 射程 $range · 耐久 $hp';
  }

  @override
  String u_disabledSec(int sec) {
    return '停机 $sec秒';
  }

  @override
  String u_sectorStatus(String sector) {
    return '$sector 概况';
  }

  @override
  String u_sectorStats(
    int colonies,
    int planets,
    int stations,
    String mul,
    String other,
  ) {
    return '已定居行星 $colonies / $planets\n空间站 $stations座\n星系加成：产量 x$mul\n其他星系收入：💰$other/s';
  }

  @override
  String get u_legendaryGet => '🌟 传说！ 🌟';

  @override
  String get u_rareGet => '✨ 稀有船员！ ✨';

  @override
  String get u_newCrew => '新船员加入！';

  @override
  String get u_great => '太好了！';

  @override
  String u_crewHeader(int count, int cap, int assigned, int slots) {
    return '船员 $count/$cap · 派驻 $assigned/$slots';
  }

  @override
  String u_recruit(int cost) {
    return '招募 💰$cost';
  }

  @override
  String u_recruitPremium(int cost) {
    return '高级招募 ⭐$cost';
  }

  @override
  String u_recruitLegendary(int cost) {
    return '🌟 传说必得 ⭐$cost';
  }

  @override
  String u_recruitOdds(String normal, String premium) {
    return '概率 · 招募：$normal\n高级招募：$premium\n传说必得：★4 100%';
  }

  @override
  String u_slotMax(int n) {
    return '派驻栏位 MAX ($n)';
  }

  @override
  String u_slotBuy(int price) {
    return '派驻栏位 +1 ⭐$price';
  }

  @override
  String u_rosterMax(int n) {
    return '船员上限 MAX ($n)';
  }

  @override
  String u_rosterBuy(int size, int price) {
    return '船员上限 +$size ⭐$price';
  }

  @override
  String get u_noCrew => '还没有船员。快去招募并派驻到飞船上吧！';

  @override
  String get u_unassign => '撤下';

  @override
  String get u_assign => '派驻';

  @override
  String get u_dismiss => '解雇';

  @override
  String get u_dismissCrewTitle => '解雇船员';

  @override
  String u_dismissCrewBody(String name) {
    return '要让$name离开吗？此操作无法撤销。';
  }

  @override
  String get u_missionDeliverHint => '前往目的地（黄色箭头）';

  @override
  String get u_missionBountyHint => '找到并击败目标（黄色箭头）';

  @override
  String u_reward(String rewards) {
    return '奖励 $rewards';
  }

  @override
  String u_activeMissions(int n) {
    return '进行中 ($n/3)';
  }

  @override
  String get u_noActiveMissions => '没有进行中的任务。';

  @override
  String get u_abandon => '放弃';

  @override
  String u_missionBoard(int sec) {
    return '任务板 · $sec秒后刷新';
  }

  @override
  String get u_accept => '接受';

  @override
  String get u_priceHigh => '📈 高价！快卖';

  @override
  String get u_priceLow => '📉 低价…再等等';

  @override
  String get u_priceNormal => '➡ 一般';

  @override
  String get u_orePrice => '矿石行情';

  @override
  String get u_sell100 => '卖出100';

  @override
  String get u_sellHalf => '卖出一半';

  @override
  String get u_sellAll => '全部卖出';

  @override
  String get u_marketTip => '价格会随时间涨跌。高价时卖出更划算！';

  @override
  String get u_gemExchange => '⭐ 星之宝石兑换';

  @override
  String get u_creditPack => '信用点礼包';

  @override
  String get u_exchange => '兑换';

  @override
  String get u_openShop => '⭐ 打开商店';

  @override
  String u_achievementDone(String title, int gems) {
    return '🏆 达成成就：$title！请在菜单 > 成就中领取⭐$gems。';
  }

  @override
  String get u_cannotDo => '资源不足，或现在无法执行。';

  @override
  String get u_welcomeBack => '欢迎回来，舰长！';

  @override
  String u_offlineHm(int h, int m) {
    return '你离开的$h小时$m分钟里，\n殖民地一直在努力工作！';
  }

  @override
  String u_offlineM(int m) {
    return '你离开的$m分钟里，\n殖民地一直在努力工作！';
  }

  @override
  String get u_passOfflineHint => '指挥官通行证：最长8小时 + 自动双倍';

  @override
  String get u_collect => '领取';

  @override
  String get u_adLoading => '广告加载中，请稍后再试。';

  @override
  String get u_adLoadingRetry => '广告加载中，请稍后再点一次。';

  @override
  String get u_collectDouble => '双倍领取 👑';

  @override
  String get u_adDouble => '📺 看广告双倍';

  @override
  String get u_galaxyHonor => '🌌 银河荣誉';

  @override
  String u_honorStatus(int honor, int ascensions) {
    return '当前荣誉 $honor（转生 $ascensions次）';
  }

  @override
  String u_honorBonus(int income, int attack) {
    return '收入 +$income% · 攻击力 +$attack%';
  }

  @override
  String get u_ascendExplain =>
      '转生会重置当前宇宙（星系、殖民地、空间站、飞船强化、船员、信用点），\n并获得永久加成——荣誉点数。\n宝石、装扮、飞船和成就会保留。';

  @override
  String u_ascendGain(int gain) {
    return '现在转生可获得荣誉 +$gain！\n（帝国越大，获得越多）';
  }

  @override
  String get u_ascendLocked => '到达星系4后即可转生。';

  @override
  String get u_close => '关闭';

  @override
  String u_ascendBtn(int gain) {
    return '转生 (+$gain)';
  }

  @override
  String get u_ascendConfirmTitle => '确定要转生吗？';

  @override
  String get u_ascendConfirmBody => '当前宇宙将被重置，无法撤销。';

  @override
  String get u_ascend => '转生';

  @override
  String u_shieldBroken(String name) {
    return '$name 已破损';
  }

  @override
  String u_hudSector(String sector, int dev, String threat, String value) {
    return '$sector · 发展 $dev%\n⚠ 威胁 $threat  🏛 $value';
  }

  @override
  String u_baseDisabled(int sec) {
    return '基地停机 ${sec}s';
  }

  @override
  String u_baseHp(int pct) {
    return '基地 $pct%';
  }

  @override
  String get u_merchantE => '商人 (E)';

  @override
  String get u_nextSectorE => '下一星系 (E)';

  @override
  String get u_prevSectorE => '上一星系 (E)';

  @override
  String u_gateLocked(int pct) {
    return '🔒 发展度100%时开启 ($pct%)';
  }

  @override
  String u_settle(String name) {
    return '定居$name';
  }

  @override
  String u_manageE(String name) {
    return '管理$name (E)';
  }

  @override
  String get u_buildStation => '建造空间站';

  @override
  String get u_fire => '开火';

  @override
  String get u_equipAtStation => '可以在空间站的飞船页装备！';

  @override
  String get u_shotDown => '💥 你被击落了！';

  @override
  String u_autoRespawn(int sec) {
    return '$sec秒后在基地自动重新出击';
  }

  @override
  String get u_reviveFree => '👑 原地复活（免费）';

  @override
  String get u_reviveAd => '📺 看广告原地复活';

  @override
  String get u_reviveGems => '花费⭐10原地复活';

  @override
  String u_respawnBase(int pct) {
    return '🏠 在基地重新出击（损失$pct%信用点）';
  }

  @override
  String get u_spkCaptain => '舰长';

  @override
  String get u_spkPirate => '海盗';

  @override
  String get u_spkAdvisor => '副官米娜';

  @override
  String get u_spkMerchant => '商人喵喵';

  @override
  String get u_paused => '已暂停';

  @override
  String u_pauseStats(
    String sector,
    int kills,
    int crew,
    int colonies,
    int stations,
    int missions,
  ) {
    return '$sector · 击落 $kills · 船员 $crew\n殖民地 $colonies · 空间站 $stations · 完成任务 $missions';
  }

  @override
  String get u_resume => '▶︎ 继续';

  @override
  String get u_shop => '⭐ 商店';

  @override
  String get u_achievements => '🏆 成就';

  @override
  String get u_dailyQuests => '📅 每日任务';

  @override
  String get u_myPlanet => '🌍 我的星球';

  @override
  String get u_ascendMenu => '🌌 银河荣誉（转生）';

  @override
  String get u_settings => '⚙ 设置';

  @override
  String get u_saveAndQuit => '💾 保存并返回标题';

  @override
  String get u_keyboardHelp =>
      '按键：WASD 移动 · Space 射击 · Q 导弹 · F 护盾 · Shift 加速\nE 互动 · B 建造空间站 · Esc 菜单';

  @override
  String get u_recharging => '充能中';

  @override
  String get u_tutDome => '护盾\n待在里面很安全';

  @override
  String get u_tutLevelUp => '升级\n收入·建筑↑';

  @override
  String get u_tutTurret => '炮塔';

  @override
  String get u_tutRepair => '修理';

  @override
  String get u_tutRaid => '阻止袭击';

  @override
  String get u_gotIt => '知道了';

  @override
  String u_damage(int dmg) {
    return '伤害 $dmg';
  }

  @override
  String u_oreRate(String rate) {
    return '矿石 +$rate/s';
  }

  @override
  String u_incomePct(int pct) {
    return '收入 +$pct%';
  }

  @override
  String u_repairRate(int hp) {
    return '生命 +$hp/s';
  }

  @override
  String u_shieldPlus(int amount) {
    return '护盾 +$amount';
  }

  @override
  String u_systemTitle(String sector, int n) {
    return '$sector · 星系 $n';
  }

  @override
  String u_systemInfo(String threat, String mul) {
    return '威胁 $threat · 资源倍率 x$mul';
  }

  @override
  String u_development(int pct) {
    return '发展度 $pct%';
  }

  @override
  String get u_nextSystemOpen => '下一星系已开启';

  @override
  String get u_opensAt100 => '100%时开启';

  @override
  String get u_devHint => '所有行星升到Lv.3即达100%';

  @override
  String get u_conqueredSystems => '已征服星系（持续生产中）';

  @override
  String get u_unsettled => '未定居';

  @override
  String get u_underRaid => '遭袭中';

  @override
  String u_unknownSector(int n) {
    return '未知星系 $n';
  }

  @override
  String u_sectorDev(String name, int pct) {
    return '$name · 发展 $pct%';
  }

  @override
  String get u_buildStationTitle => '建造空间站 · 选择职能';

  @override
  String get u_cost => '费用';

  @override
  String get u_build => '建造';

  @override
  String get u_toNextSector => '🌀 前往下一星系';

  @override
  String get u_bossLocked => '🔒 击败首领后开启';

  @override
  String get u_toPrevSector => '🌀 返回上一星系';

  @override
  String get u_raidAlert => '⚠ 遭袭中！';

  @override
  String u_rechargePct(int pct) {
    return '充能 $pct%';
  }

  @override
  String u_merchantLabel(int sec) {
    return '🛒 流浪商人 ($sec秒)';
  }

  @override
  String get u_supplyPod => '📦 补给舱';

  @override
  String u_sectorBoss(String sector) {
    return '☠ $sector首领';
  }

  @override
  String get u_pirateBoss => '☠ 海盗首领';

  @override
  String get u_merchantName => '流浪商人喵喵';

  @override
  String u_merchantLeaves(int sec, String credits) {
    return '$sec秒后离开 · 💰$credits';
  }

  @override
  String get u_rareCrewOffer => '稀有船员介绍';

  @override
  String get u_crewSoldOut => '今天的船员已经卖完了喵！';

  @override
  String get u_gemTrade => '宝石兑换（限3次）';

  @override
  String u_gemTradeRow(int price, int left) {
    return '💰$price → ⭐5  (剩余$left次)';
  }

  @override
  String get u_convert => '兑换';

  @override
  String get u_potions => '强化药水（持续时间x2）';

  @override
  String get u_notEnoughGems => '宝石不足';

  @override
  String get u_buyConfirmTitle => '确认购买';

  @override
  String u_buyShipConfirm(String ship, String price) {
    return '花费$price购买$ship？';
  }

  @override
  String u_shipBought(String ship) {
    return '获得$ship！已立即搭乘';
  }

  @override
  String get u_premiumShips => '高级飞船';

  @override
  String get u_hangarTitle => '机库';

  @override
  String u_buyGems(int price) {
    return '⭐$price 购买';
  }

  @override
  String get u_premium => '高级';

  @override
  String get u_ok => '确定';

  @override
  String get u_cancel => '取消';

  @override
  String get m_ok => '确定';

  @override
  String get m_cancel => '取消';

  @override
  String get m_close => '关闭';

  @override
  String get m_claim => '领取';

  @override
  String m_claimGems(int gems) {
    return '领取⭐$gems';
  }

  @override
  String get m_done => '✅ 已完成';

  @override
  String get m_notEnoughGems => '宝石不足';

  @override
  String get m_restorePurchases => '恢复购买';

  @override
  String get m_restoreDone => '已检查购买记录';

  @override
  String get m_buyConfirmTitle => '确认购买';

  @override
  String m_spendGemsConfirm(String price) {
    return '要花费$price吗？';
  }

  @override
  String get m_loginTitle => '📅 每日签到';

  @override
  String get m_loginWelcome => '今天也来啦，舰长！';

  @override
  String get m_loginStreakHint => '连续签到7天得⭐50！';

  @override
  String get m_newGameTitle => '新游戏';

  @override
  String get m_newGameBody => '当前进度将被清除。\n（宝石、装扮、成就和已购商品会保留）要继续吗？';

  @override
  String get m_start => '开始';

  @override
  String get m_loadFailed => '无法读取存档数据。';

  @override
  String m_honorLine(int honor, int income, int attack) {
    return '🌌 银河荣誉 $honor · 收入 +$income% · 攻击 +$attack%';
  }

  @override
  String get m_continue => '继续游戏';

  @override
  String get m_newGame => '✨ 新游戏';

  @override
  String get m_menuHome => '我的星球';

  @override
  String get m_menuShop => '商店';

  @override
  String get m_menuQuest => '任务';

  @override
  String get m_menuAchievements => '成就';

  @override
  String get m_menuSettings => '设置';

  @override
  String m_achievementsTitle(int done, int total) {
    return '🏆 成就 ($done/$total)';
  }

  @override
  String get m_dailyTitle => '📅 每日任务';

  @override
  String m_dailyReset(int hours, int minutes) {
    return '$hours小时$minutes分后重置';
  }

  @override
  String get m_dailyBonusTitle => '🎁 全部完成奖励';

  @override
  String get m_dailyBonusDesc => '领取今日全部3个任务奖励';

  @override
  String get m_settingsTitle => '⚙ 设置';

  @override
  String get m_settingsSound => '音效';

  @override
  String get m_settingsMusic => '背景音乐';

  @override
  String get m_settingsNotify => '回归提醒';

  @override
  String get m_settingsNotifyDesc => '殖民地仓库满了时会通知你';

  @override
  String get m_settingsHaptics => '振动';

  @override
  String get m_settingsLanguage => '语言';

  @override
  String get m_languageSystem => '跟随设备语言';

  @override
  String get m_privacyTitle => '隐私政策';

  @override
  String m_privacyBody(String email) {
    return 'Star Settlers 仅在你的设备上保存游戏数据（进度、设置），不收集任何可识别个人身份的信息。\n\n应用内购买由 Google Play / App Store 处理，支付信息不会提供给开发者。\n\n如启用激励广告，广告提供商（Google AdMob）可能会收集广告标识符等数据。\n\n联系方式：$email（设置 → 向开发者发送反馈）';
  }

  @override
  String get m_wipeTitle => '重置所有数据';

  @override
  String get m_wipeDesc => '删除所有进度、宝石和装扮';

  @override
  String get m_wipeConfirmTitle => '确定要全部重置吗？';

  @override
  String get m_wipeConfirmBody => '此操作无法撤销。已购商品可通过“恢复购买”找回。';

  @override
  String get m_wipeOk => '重置';

  @override
  String get m_feedbackTitle => '向开发者发送反馈';

  @override
  String get m_feedbackDesc => 'Bug、建议，什么都可以！设备和应用版本会自动填写。';

  @override
  String m_noMailApp(String email) {
    return '未找到邮件应用。请发送至 $email。';
  }

  @override
  String get m_aboutTitle => 'STAR SETTLERS';

  @override
  String m_version(String version) {
    return '版本 $version';
  }

  @override
  String get m_shopTitle => '⭐ 商店';

  @override
  String get m_buyThanks => '购买完成！谢谢你 💜';

  @override
  String get m_adLoading => '广告加载中，请稍后再试。';

  @override
  String m_buyShipConfirm(String ship, String price) {
    return '花费$price购买$ship？';
  }

  @override
  String m_shipAcquired(String ship) {
    return '获得$ship！已立即搭乘';
  }

  @override
  String get m_tabGems => '宝石';

  @override
  String get m_tabPacks => '礼包';

  @override
  String get m_tabPremiumShips => '高级飞船';

  @override
  String get m_tabSkins => '飞船皮肤';

  @override
  String get m_tabOutfits => '舰长服装';

  @override
  String get m_tabFree => '免费宝石';

  @override
  String get m_testMode => '🧪 测试模式：不会产生真实付款或广告';

  @override
  String get m_owned => '已拥有';

  @override
  String get m_boarded => '搭乘中';

  @override
  String get m_gemsInfo => '宝石可用于装扮、高级招募、立即复活和兑换信用点。\n也可以通过游玩获得（成就、签到、首领、补给舱）。';

  @override
  String get m_crewSection => '👩‍🚀 船员（宝石）';

  @override
  String get m_premiumSection => '🛸 高级飞船';

  @override
  String get m_premiumDesc => '只能用宝石获得的特别战机，各有独特能力。';

  @override
  String get m_viewLarge => '查看大图';

  @override
  String get m_premiumHangarHint => '也可以在机库（空间站 → 飞船页）购买和更换飞船。';

  @override
  String get m_legendTitle => '传说船员必得招募';

  @override
  String get m_legendDescNoGame =>
      '1名★4传说船员（加成20%起＋全部产出+40%，称号·金色光环）\n开始游戏后可购买';

  @override
  String m_legendDesc(int count, int cap) {
    return '1名★4传说船员（加成20%起＋全部产出+40%，称号·金色光环）\n船员 $count/$cap';
  }

  @override
  String m_crewJoined(String stars, String name) {
    return '$stars $name 加入了！';
  }

  @override
  String get m_slotTitle => '派驻栏位 +1';

  @override
  String m_slotDesc(int slots) {
    return '可同时派驻的船员数 · 当前 $slots';
  }

  @override
  String m_rosterTitle(int n) {
    return '船员上限 +$n';
  }

  @override
  String m_rosterDesc(int cap, int max) {
    return '可拥有的船员数 · 当前 $cap（上限 $max）';
  }

  @override
  String m_crewOdds(String odds) {
    return '高级招募概率：$odds · 传说必得：★4 100%';
  }

  @override
  String get m_equipped => '已装备';

  @override
  String get m_equip => '装备';

  @override
  String get m_passOnly => '指挥官通行证专属';

  @override
  String get m_starterOnly => '新手礼包专属';

  @override
  String get m_adSection => '📺 看广告得免费宝石';

  @override
  String m_adInfo(int perDay, int left) {
    return '每天$perDay次，每次⭐5 · 今日剩余$left次';
  }

  @override
  String get m_adClaimPremium => '领取⭐5（指挥官通行证：免广告）';

  @override
  String get m_adWatch => '看广告得⭐5';

  @override
  String m_loginStreak(int days) {
    return '连续签到第$days天';
  }

  @override
  String m_dayN(int day) {
    return '第$day天';
  }

  @override
  String get m_notEnoughResources => '资源不足';

  @override
  String m_emptyLot(int n) {
    return '空地 #$n · 建造';
  }

  @override
  String get m_buildInGameOnly => '游戏中（菜单 → 我的星球）才能建造。使用的是当前宇宙的信用点和矿石。';

  @override
  String m_heldAll(String credits, String ore, int gems) {
    return '持有 💰$credits  💎$ore  ⭐$gems';
  }

  @override
  String m_held(String credits, String ore) {
    return '持有 💰$credits  💎$ore';
  }

  @override
  String m_currentEffect(String effect) {
    return '当前效果：$effect';
  }

  @override
  String m_nextLevel(String effect) {
    return '下一级：$effect';
  }

  @override
  String m_upgrade(String cost) {
    return '升级 $cost';
  }

  @override
  String get m_maxLevel => '🌟 已满级';

  @override
  String get m_planetName => '星球名称';

  @override
  String get m_decorateTitle => '🎨 装扮星球';

  @override
  String get m_planetRing => '星球光环';

  @override
  String get m_giftInGameOnly => '游戏中才能领取礼物';

  @override
  String get m_giftTitle => '🎁 星球礼物';

  @override
  String m_giftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '这是$count位居民为你准备的礼物！',
    );
    return '$_temp0';
  }

  @override
  String get m_giftThanks => '谢谢！';

  @override
  String m_planetStatus(int level, int residents, int built, int slots) {
    return '星球 Lv.$level · 居民 $residents人 · 建筑 $built/$slots';
  }

  @override
  String m_permBonus(
    int income,
    int ore,
    int attack,
    int hp,
    int cooldown,
    int offline,
  ) {
    return '永久加成 · 收入 +$income%  矿石 +$ore%  攻击 +$attack%  生命 +$hp%  冷却 -$cooldown%  离线 $offline%';
  }

  @override
  String get m_planetHint => '滑动旋转星球，点击空地建造';

  @override
  String get m_giftClaim => '🎁 领取礼物';

  @override
  String m_giftWait(int hours, int minutes) {
    return '🎁 $hours小时$minutes分后有礼物';
  }

  @override
  String m_planetLevelUp(int level, String cost) {
    return '🌍 星球 Lv.$level（空地 +2）$cost';
  }

  @override
  String get g_shipScoutName => '侦察机';

  @override
  String get g_shipInterceptorName => '截击机';

  @override
  String get g_shipFortressName => '堡垒号';

  @override
  String get g_shipProspectorName => '勘探者';

  @override
  String get g_shipPhantomName => '幻影';

  @override
  String get g_shipNovaName => '新星巨龙';

  @override
  String get g_shipAuroraName => '极光';

  @override
  String get g_shipScoutDesc => '均衡的基础飞船';

  @override
  String get g_shipInterceptorDesc => '速度快、射速快，但装甲薄';

  @override
  String get g_shipFortressDesc => '速度慢但很结实，一击很重';

  @override
  String get g_shipProspectorDesc => '矿石+50%，可远距离吸取道具';

  @override
  String get g_shipPhantomDesc => '25%概率造成2.5倍暴击';

  @override
  String get g_shipNovaDesc => '子弹可贯穿敌人的高级战机';

  @override
  String get g_shipAuroraDesc => '能自我修复并展开屏障的高级守护舰';

  @override
  String get g_shipNovaAbility => '贯穿弹：每发子弹最多贯穿2个敌人';

  @override
  String get g_shipAuroraAbility => '自我修复：3秒未受伤后每秒恢复3%生命\n守护膜：每8秒抵挡1次攻击';

  @override
  String g_crewLegendPerk(int pct) {
    return '👑 传说指挥：全部产出（信用点·矿石）+$pct%（不叠加）';
  }

  @override
  String g_shipCreditBonus(int pct) {
    return '💰 猎手加成：亲自赚取的信用点+$pct%（赏金·小行星·任务·防御袭击）';
  }

  @override
  String g_unlockSector(int n) {
    return '到达星系$n';
  }

  @override
  String g_unlockBosses(int n) {
    return '击败海盗首领$n次';
  }

  @override
  String g_unlockOre(int n) {
    return '收集$n个矿石';
  }

  @override
  String get g_skinDefault => '基础侦察机';

  @override
  String get g_skinCrimson => '红色彗星';

  @override
  String get g_skinMint => '薄荷巧克力';

  @override
  String get g_skinStealth => '隐形黑';

  @override
  String get g_skinNeon => '霓虹粉';

  @override
  String get g_skinRainbow => '彩虹之梦';

  @override
  String get g_skinGalaxy => '银河';

  @override
  String get g_skinGold => '皇家黄金';

  @override
  String get g_outfitDefault => '基础宇航服';

  @override
  String get g_outfitCat => '猫耳头盔';

  @override
  String get g_outfitBunny => '兔耳朵';

  @override
  String get g_outfitAlien => '外星人触角';

  @override
  String get g_outfitFlower => '小花发夹';

  @override
  String get g_outfitHat => '舰长帽';

  @override
  String get g_outfitCrown => '银河王冠';

  @override
  String get g_crewRoleGunner => '炮手';

  @override
  String get g_crewEffectGunner => '攻击力';

  @override
  String get g_crewRoleEngineer => '机械师';

  @override
  String get g_crewEffectEngineer => '最大生命·修理';

  @override
  String get g_crewRolePilot => '驾驶员';

  @override
  String get g_crewEffectPilot => '速度';

  @override
  String get g_crewRoleTrader => '商人';

  @override
  String get g_crewEffectTrader => '信用点收入';

  @override
  String get g_crewRoleMiner => '矿工';

  @override
  String get g_crewEffectMiner => '矿石获取';

  @override
  String get g_crewRoleScientist => '科学家';

  @override
  String get g_crewEffectScientist => '技能冷却缩短';

  @override
  String get g_crewName0 => '团团';

  @override
  String get g_crewName1 => '可可';

  @override
  String get g_crewName2 => '星星';

  @override
  String get g_crewName3 => '豆腐';

  @override
  String get g_crewName4 => '豆豆';

  @override
  String get g_crewName5 => '露露';

  @override
  String get g_crewName6 => '小春';

  @override
  String get g_crewName7 => '波波';

  @override
  String get g_crewName8 => '咪咪';

  @override
  String get g_crewName9 => '多莉';

  @override
  String get g_crewName10 => '绒绒';

  @override
  String get g_crewName11 => '蝴蝶';

  @override
  String get g_crewName12 => '巧克';

  @override
  String get g_crewName13 => '麦麦';

  @override
  String get g_crewName14 => '云朵';

  @override
  String get g_crewName15 => '小雨';

  @override
  String get g_crewName16 => '托莉';

  @override
  String get g_crewName17 => '开心';

  @override
  String get g_crewName18 => '年糕';

  @override
  String get g_crewName19 => '麻糬';

  @override
  String get g_crewName20 => '拿铁';

  @override
  String get g_crewName21 => '曲奇';

  @override
  String get g_crewName22 => '果冻';

  @override
  String get g_crewName23 => '棉花';

  @override
  String get g_crewName24 => '芒果';

  @override
  String get g_crewName25 => '李子';

  @override
  String get g_crewName26 => '核桃';

  @override
  String get g_crewName27 => '小黑';

  @override
  String get g_crewName28 => '斑比';

  @override
  String get g_crewName29 => '芝士';

  @override
  String get g_crewLegend0 => '银河守护者';

  @override
  String get g_crewLegend1 => '星之英雄';

  @override
  String get g_crewLegend2 => '星云贤者';

  @override
  String get g_crewLegend3 => '彗星骑士';

  @override
  String get g_crewLegend4 => '超新星';

  @override
  String g_crewLegendName(String title, String name) {
    return '$title $name';
  }

  @override
  String get g_bldHouse => '住宅';

  @override
  String g_bldHouseEffect(int n) {
    return '居民 +$n人（礼物增加）';
  }

  @override
  String get g_bldFarm => '太空农场';

  @override
  String g_bldFarmEffect(int n) {
    return '信用点收入 +$n%';
  }

  @override
  String get g_bldMine => '矿场';

  @override
  String g_bldMineEffect(int n) {
    return '矿石获取 +$n%';
  }

  @override
  String get g_bldLab => '研究所';

  @override
  String g_bldLabEffect(int n) {
    return '技能冷却 -$n%';
  }

  @override
  String get g_bldTower => '防御塔';

  @override
  String g_bldTowerEffect(int n) {
    return '最大生命 +$n%';
  }

  @override
  String get g_bldShipyard => '造船厂';

  @override
  String g_bldShipyardEffect(int n) {
    return '攻击力 +$n%';
  }

  @override
  String get g_bldPark => '游乐园';

  @override
  String g_bldParkEffect(int n) {
    return '离线收入 +$n%p';
  }

  @override
  String get g_bldStatue => '舰长雕像';

  @override
  String g_bldStatueEffect(int n) {
    return '星球礼物宝石 +$n';
  }

  @override
  String get g_homePalette0 => '绿色花园';

  @override
  String get g_homePalette1 => '黄沙沙漠';

  @override
  String get g_homePalette2 => '冰雪王国';

  @override
  String get g_homePalette3 => '熔岩岛';

  @override
  String get g_homePalette4 => '紫色气体';

  @override
  String get g_homePalette5 => '樱花';

  @override
  String get g_homePalette6 => '极光';

  @override
  String get g_homePalette7 => '黄金';

  @override
  String get g_homeDefaultName => '我的小星星';

  @override
  String get g_achFirstBloodTitle => '首次击落';

  @override
  String get g_achFirstBloodDesc => '击落1艘海盗船';

  @override
  String get g_achHunterTitle => '海盗猎人';

  @override
  String get g_achHunterDesc => '击落100艘海盗船';

  @override
  String get g_achLegendTitle => '传说舰长';

  @override
  String get g_achLegendDesc => '击落1000艘海盗船';

  @override
  String get g_achMinerTitle => '矿山之王';

  @override
  String get g_achMinerDesc => '收集1000个矿石';

  @override
  String get g_achMiner2Title => '矿石富翁';

  @override
  String get g_achMiner2Desc => '收集10000个矿石';

  @override
  String get g_achColonistTitle => '开拓者';

  @override
  String get g_achColonistDesc => '定居5颗行星';

  @override
  String get g_achMetropolisTitle => '大都会';

  @override
  String get g_achMetropolisDesc => '殖民地达到Lv.5';

  @override
  String get g_achBuilderTitle => '建筑师';

  @override
  String get g_achBuilderDesc => '建造3座空间站';

  @override
  String get g_achBoss1Title => '首领狩猎';

  @override
  String get g_achBoss1Desc => '击败海盗首领';

  @override
  String get g_achBoss10Title => '首领杀手';

  @override
  String get g_achBoss10Desc => '击败海盗首领10次';

  @override
  String get g_achExplorerTitle => '探险家';

  @override
  String get g_achExplorerDesc => '到达星系3';

  @override
  String get g_achVoyagerTitle => '航行者';

  @override
  String get g_achVoyagerDesc => '到达星系6';

  @override
  String get g_achRichTitle => '富豪舰长';

  @override
  String get g_achRichDesc => '持有10000信用点';

  @override
  String get g_achCrew6Title => '可靠的伙伴';

  @override
  String get g_achCrew6Desc => '招募6名船员';

  @override
  String get g_achCrew3starTitle => '传说伙伴';

  @override
  String get g_achCrew3starDesc => '招募★3船员';

  @override
  String get g_achMissionsTitle => '万能帮手';

  @override
  String get g_achMissionsDesc => '完成20个任务';

  @override
  String get g_achJellyTitle => '水母博士';

  @override
  String get g_achJellyDesc => '消灭10只太空水母';

  @override
  String get g_achFashionTitle => '时尚达人';

  @override
  String get g_achFashionDesc => '购买装扮道具';

  @override
  String get g_achAscendTitle => '新的开始';

  @override
  String get g_achAscendDesc => '以银河荣誉转生';

  @override
  String get g_achDroneTitle => '可靠的无人机';

  @override
  String get g_achDroneDesc => '装备战斗无人机';

  @override
  String get g_achHome5Title => '星球建筑师';

  @override
  String get g_achHome5Desc => '我的星球上有5座建筑';

  @override
  String get g_achHomeMaxTitle => '梦想星球';

  @override
  String get g_achHomeMaxDesc => '我的星球达到满级';

  @override
  String get g_dailyKill => '击落30艘海盗船';

  @override
  String get g_dailyOre => '收集300个矿石';

  @override
  String get g_dailyMission => '完成2个任务';

  @override
  String get g_dailyColony => '殖民地成长2次';

  @override
  String get g_dailyBoss => '击败海盗首领';

  @override
  String get g_dailyPower => '获得3个强化道具';

  @override
  String get g_dailyPlay => '游玩10分钟';

  @override
  String get g_dailyJelly => '消灭3只太空水母';

  @override
  String g_missionKill(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '清剿$n艘海盗船',
    );
    return '$_temp0';
  }

  @override
  String g_missionMine(int n) {
    return '收集$n个矿石';
  }

  @override
  String g_missionDeliver(String planet) {
    return '向$planet运送货物';
  }

  @override
  String g_missionBounty(String name) {
    return '通缉：$name';
  }

  @override
  String get g_bounty0 => '独眼杰克';

  @override
  String get g_bounty1 => '闪电茉莉';

  @override
  String get g_bounty2 => '废铁王巴克';

  @override
  String get g_bounty3 => '红胡子托托';

  @override
  String get g_bounty4 => '暗影蕾娜';

  @override
  String get g_bounty5 => '胖子波克';

  @override
  String get g_bounty6 => '双刀吉吉';

  @override
  String get g_bounty7 => '疯锤巴德';

  @override
  String get g_bounty8 => '银河狐露西';

  @override
  String get g_bounty9 => '骷髅船长骨头';

  @override
  String get g_storyAsteroidsTitle => '击碎3颗小行星';

  @override
  String get g_storyAsteroidsLine0 => '舰长！先击碎小行星收集矿石吧。';

  @override
  String get g_storyAsteroidsLine1 => '用摇杆移动，按开火按钮射击就行！';

  @override
  String get g_storyKillsTitle => '击落3艘海盗船';

  @override
  String get g_storyKillsLine0 => '雷达发现海盗！在红色箭头的方向。';

  @override
  String get g_storyKillsLine1 => '区区海盗，在我的飞船面前就是废铁！';

  @override
  String get g_storyColoniesTitle => '在火星定居';

  @override
  String get g_storyColoniesLine0 => '在地球旁边的红色星球——火星上建立第一个殖民地吧。靠近后会出现定居按钮。';

  @override
  String get g_storyColoniesLine1 => '殖民地就算放着不管也会赚信用点哦！';

  @override
  String get g_storyShipLevelsTitle => '在空间站改造飞船';

  @override
  String get g_storyShipLevelsLine0 => '回到港湾基地改造飞船吧。在空间站附近还能修理哦。';

  @override
  String get g_storyCrewTitle => '招募1名船员';

  @override
  String get g_storyCrewLine0 => '一个人很寂寞吧？去空间站菜单的船员页招募伙伴吧！';

  @override
  String get g_storyMissionsTitle => '完成1个任务';

  @override
  String get g_storyMissionsLine0 => '在空间站的任务板接个委托吧。报酬很丰厚哦。';

  @override
  String get g_storyStationsTitle => '建造新的空间站';

  @override
  String get g_storyStationsLine0 => '该扩张领地了！在远离行星的空旷宇宙中建造空间站吧。';

  @override
  String get g_storyDevPercentTitle => '星系发展度100%';

  @override
  String get g_storyDevPercentLine0 => '把所有行星升到Lv.3就能开启下一个星系。点右上角的星系按钮查看吧！';

  @override
  String get g_storySectorTitle => '通过跃迁门前往下一星系';

  @override
  String get g_storySectorLine0 => '跃迁门打开了！前往小地图上的紫色传送门吧。';

  @override
  String get g_storySectorLine1 => '全新的宇宙在等着我！';

  @override
  String g_storyDevNTitle(int n) {
    return '星系$n发展度100%';
  }

  @override
  String get g_storyDevNLine => '把新星系的所有行星都升到Lv.3吧！';

  @override
  String g_systemN(int n) {
    return '星系$n';
  }

  @override
  String g_storyWarpNTitle(String system) {
    return '跃迁至$system';
  }

  @override
  String get g_storyWarpNLine => '传送门打开了。要去更深的宇宙看看吗？';

  @override
  String get g_powerUpRapid => '连射';

  @override
  String get g_powerUpShield => '护盾';

  @override
  String get g_powerUpMagnet => '磁铁';

  @override
  String get g_powerUpDoubleCredits => '信用点x2';

  @override
  String get g_planetKindGarden => '花园行星';

  @override
  String get g_planetKindDesert => '沙漠行星';

  @override
  String get g_planetKindIce => '冰冻行星';

  @override
  String get g_planetKindLava => '熔岩行星';

  @override
  String get g_planetKindGas => '气态行星';

  @override
  String get g_colonyBldTurret => '防御炮塔';

  @override
  String get g_colonyBldMine => '采矿设施';

  @override
  String get g_colonyBldTrade => '贸易站';

  @override
  String get g_colonyBldDock => '维修坞';

  @override
  String get g_colonyBldShieldGen => '护盾发生器';

  @override
  String get g_colonyBldBlurbTurret => '自动拦截殖民地附近的海盗。防御袭击必备！';

  @override
  String get g_colonyBldBlurbMine => '开采矿石，每秒送来💎。';

  @override
  String get g_colonyBldBlurbTrade => '每级使该殖民地的信用点收入提高25%。';

  @override
  String get g_colonyBldBlurbDock => '在附近时恢复飞船生命。';

  @override
  String get g_colonyBldBlurbShieldGen => '提升护盾容量和充能速度。';

  @override
  String get g_stationRoleHome => '大本营';

  @override
  String get g_stationRoleDefense => '防御基地';

  @override
  String get g_stationRoleRepair => '维修基地';

  @override
  String get g_stationRoleSupport => '补给基地';

  @override
  String get g_stationRoleBlurbHome => '激光炮台和安全区';

  @override
  String get g_stationRoleBlurbDefense => '强力炮塔 · 耐久x2 · 拦截周围敌方子弹';

  @override
  String get g_stationRoleBlurbRepair => '大范围快速修理 · 重新出击费用10% · 附近殖民地护盾充能x2';

  @override
  String get g_stationRoleBlurbSupport => '附近殖民地产量 +25%（居住区每级+5%）';

  @override
  String g_eventRaid(String planet) {
    return '$planet遭袭';
  }

  @override
  String get g_eventMeteor => '流星雨';

  @override
  String get g_eventMerchant => '流浪商人';

  @override
  String get g_eventSupply => '补给舱';

  @override
  String get g_productGems100Title => '一把宝石';

  @override
  String get g_productGems550Title => '一袋宝石';

  @override
  String get g_productGems1200Title => '一箱宝石';

  @override
  String get g_productStarterTitle => '新手礼包';

  @override
  String get g_productPassTitle => '舰队指挥官通行证';

  @override
  String get g_productGems550Desc => '⭐550（+10%奖励）';

  @override
  String get g_productGems1200Desc => '⭐1200（+20%奖励）';

  @override
  String get g_productStarterDesc => '⭐300 + 专属皮肤“银河” + ★3船员（限购1次）';

  @override
  String get g_productPassDesc => '信用点收入+25%，离线收入8小时，免广告领奖励，专属皮肤“皇家黄金”';

  @override
  String g_testPurchaseTitle(String product) {
    return '[测试购买] $product';
  }

  @override
  String g_testPurchaseBody(String desc, String price) {
    return '不会产生真实付款。\n$desc\n价格：$price';
  }

  @override
  String get g_testAdTitle => '[测试广告]';

  @override
  String get g_testAdBody => '视为已完整观看广告吗？';

  @override
  String get g_webDemoTitle => '网页演示版';

  @override
  String get g_webDemoBody => '购买和广告奖励请在手机应用中使用。';

  @override
  String get g_notifChannelName => '回归提醒';

  @override
  String get g_notifChannelDesc => '殖民地收入和签到奖励提醒';

  @override
  String get g_notifStorageTitle => '殖民地仓库已满！';

  @override
  String get g_notifStorageBody => '舰长，快来领取积攒的信用点吧。再晚收入就要停了。';

  @override
  String get g_notifPiratesTitle => '海盗们又在横行霸道了！';

  @override
  String get g_notifPiratesBody => '今天的签到奖励和每日任务在等着你。';

  @override
  String get g_upgradeWeapon => '武器';

  @override
  String get g_upgradeHull => '装甲';

  @override
  String get g_upgradeEngine => '引擎';

  @override
  String get g_upgradeMissile => '追踪导弹';

  @override
  String get g_upgradeShield => '能量护盾';

  @override
  String get g_upgradeDrone => '战斗无人机';

  @override
  String get g_upgradeMagnet => '磁铁';

  @override
  String g_unknownSector(int n) {
    return '未知星系$n';
  }

  @override
  String get g_stationHaven => '港湾基地';

  @override
  String g_stationOutpost(String sector) {
    return '$sector前哨基地';
  }

  @override
  String g_stationNumbered(String role, int n) {
    return '$role$n号';
  }

  @override
  String get g_dlgWelcome => '欢迎你，舰长！我是副官米娜。';

  @override
  String get g_dlgMissionsCancelled => '上一星系的运输和通缉任务已取消。';

  @override
  String get g_floatDisabled => '停机！';

  @override
  String get g_floatRebooted => '重新启动！';

  @override
  String get g_dlgBaseRebooted => '大本营重新启动！耐久已恢复至30%。';

  @override
  String get g_dlgUpWeapon => '武器强化！海盗们，做好觉悟吧！';

  @override
  String get g_dlgUpHull => '装甲强化！这下踏实多了。';

  @override
  String get g_dlgUpEngine => '引擎强化！再快一点！';

  @override
  String get g_dlgMissileNew => '追踪导弹已装备！(Q)';

  @override
  String get g_dlgMissileUp => '导弹强化！';

  @override
  String get g_dlgShieldNew => '能量护盾已装备！(F)';

  @override
  String get g_dlgShieldUp => '护盾强化！';

  @override
  String get g_dlgDroneNew => '战斗无人机出击！多了个可靠的伙伴。';

  @override
  String get g_dlgDroneUp => '无人机强化！';

  @override
  String get g_dlgUpMagnet => '磁铁强化！信用点自己飞过来了！';

  @override
  String get g_dlgNotOver => '还没结束呢！';

  @override
  String get g_floatBlocked => '挡住了！';

  @override
  String get g_floatGuard => '守护膜！';

  @override
  String get g_pirateBossLose => '呜哇啊！这个星系……归你了……';

  @override
  String get g_pirateBossFlee => '呜哇啊！给我记住，舰长！';

  @override
  String get g_dlgSupplyCollected => '补给舱回收完毕！';

  @override
  String get g_merchantBye => '那下次再见啦~ 喵！';

  @override
  String get g_pirateRaidTaunt => '这个殖民地现在归我们了！哇哈哈！';

  @override
  String get g_dlgMeteor => '发现流星雨！里面混着大量水晶。赚矿石的好机会！';

  @override
  String get g_merchantHello => '流浪商人喵喵来啦~ 好东西多多喵！';

  @override
  String get g_dlgSupplySignal => '收到装有宝石的补给舱信号！有海盗在守着，请小心。';

  @override
  String get g_dlgBossWarning => '警告！星系首领的战舰正在接近！';

  @override
  String get g_pirateRevenge => '我来复仇了！做好觉悟吧！';

  @override
  String get g_floatShieldBroken => '破碎！';

  @override
  String get g_floatShieldBack => '已恢复';

  @override
  String get g_floatGoalDone => '目标达成！';

  @override
  String g_dlgArrived(String sector) {
    return '抵达$sector！';
  }

  @override
  String get g_dlgNewFrontier => '这是全新的开拓地。';

  @override
  String g_dlgBaseUpgraded(String station, int level) {
    return '$station强化至Lv.$level！激光更强了。';
  }

  @override
  String g_dlgBaseDisabled(int sec) {
    return '大本营停机！$sec秒内失去防护！';
  }

  @override
  String g_dlgSettled(String planet) {
    return '在$planet插上旗帜！定居完成！';
  }

  @override
  String g_dlgStationBuilt(String station, String blurb) {
    return '$station建造完成！$blurb';
  }

  @override
  String g_dlgHabitatUp(String station, int level) {
    return '$station居住区 Lv.$level！';
  }

  @override
  String g_dlgTurretUp(String station, int level) {
    return '$station防御炮塔 Lv.$level！';
  }

  @override
  String g_dlgShipSwitched(String ship) {
    return '换乘$ship！感觉不错！';
  }

  @override
  String g_dlgOreSold(int n, int credits) {
    return '以💰$credits卖出了$n个矿石。';
  }

  @override
  String g_dlgCrewJoined(String stars, String role, String name) {
    return '$stars $role$name加入了！';
  }

  @override
  String g_dlgCrewLevel(String name, int level) {
    return '$name Lv.$level！实力提升了。';
  }

  @override
  String g_dlgCargoLoaded(String mission) {
    return '货物已装载！$mission';
  }

  @override
  String g_dlgBountyTaunt(String name) {
    return '想抓我$name？有本事就来啊！';
  }

  @override
  String get g_floatMissionDone => '任务完成！';

  @override
  String g_dlgMissionDone(String mission) {
    return '任务完成：$mission！';
  }

  @override
  String g_dlgRepairCost(int credits) {
    return '舰长平安无事就好！修理花了💰$credits。';
  }

  @override
  String g_dlgSectorDeveloped(String sector) {
    return '$sector发展完成！通往下一星系的跃迁门已开启。';
  }

  @override
  String g_floatCrit(int dmg) {
    return '暴击！$dmg';
  }

  @override
  String g_dlgStationDestroyed(String station) {
    return '$station被摧毁了！我们需要防御炮塔！';
  }

  @override
  String g_dlgBossDefeated(int credits) {
    return '击败星系首领！奖励 💰$credits';
  }

  @override
  String g_dlgBountyCaught(String name) {
    return '通缉犯$name已抓获！';
  }

  @override
  String g_dlgRaidDefended(String planet, int credits) {
    return '$planet防守成功！居民们送来💰$credits ⭐2表示感谢。';
  }

  @override
  String g_dlgRaidLooted(String planet, String level) {
    return '$planet遭到掠夺，降到了$level…… 😢';
  }

  @override
  String g_dlgRaidLeft(String planet) {
    return '海盗们掠夺了$planet后离开了。';
  }

  @override
  String g_dlgRaidAlert(String planet) {
    return '紧急！海盗正在袭击$planet！生产已停止！';
  }

  @override
  String g_pirateBossArrive(String sector) {
    return '$sector是本大爷的地盘！放马过来吧，小不点舰长！';
  }

  @override
  String g_dlgWelcomeBack(String goal) {
    return '欢迎回来，舰长！当前目标：$goal';
  }

  @override
  String get g_pirateWin0 => '哇哈哈！不过如此嘛！';

  @override
  String get g_pirateWin1 => '下次变强点再来吧，小不点！';

  @override
  String get g_pirateWin2 => '你的飞船成废铁啦！';

  @override
  String get g_pirateRage0 => '小的们，出来！给他们点颜色瞧瞧！';

  @override
  String get g_pirateRage1 => '现在才是动真格的！';

  @override
  String get g_pirateRage2 => '你竟敢惹我生气？！';

  @override
  String get g_captainKill0 => '解决一个！';

  @override
  String get g_captainKill1 => '往哪儿跑！';

  @override
  String get g_captainKill2 => '这片地盘是我的！';

  @override
  String get g_captainKill3 => '下一个！';

  @override
  String get g_pirateAmbush0 => '哇哈哈！把货物留下！';

  @override
  String get g_pirateAmbush1 => '这里是我们海盗团的地盘！';

  @override
  String get g_pirateAmbush2 => '把那些闪亮亮的信用点交出来！';

  @override
  String get g_pirateAmbush3 => '今天你运气不好啊，小不点！';

  @override
  String get cat_sysSol => '太阳系';

  @override
  String get cat_sysAlphaCen => '半人马座α';

  @override
  String get cat_sysBarnard => '巴纳德星';

  @override
  String get cat_sysWolf359 => '沃夫359';

  @override
  String get cat_sysLalande => '莱兰21185';

  @override
  String get cat_sysSirius => '天狼星';

  @override
  String get cat_sysEpsEri => '天苑四';

  @override
  String get cat_sysRoss128 => '罗斯128';

  @override
  String get cat_sysTauCeti => '天仓五';

  @override
  String get cat_sysTeegarden => '蒂加登星';

  @override
  String get cat_sysGliese581 => '格利泽581';

  @override
  String get cat_sysGliese667C => '格利泽667C';

  @override
  String get cat_sysTrappist1 => 'TRAPPIST-1';

  @override
  String get cat_sys55Cnc => '巨蟹座55';

  @override
  String get cat_sys51Peg => '飞马座51';

  @override
  String cat_sysKepler(int n) {
    return '开普勒-$n';
  }

  @override
  String get cat_sysOmegaCen => '半人马座ω星团';

  @override
  String get cat_sysSgrA => '银河系中心 (人马座A*)';

  @override
  String get cat_sysLMC => '大麦哲伦云';

  @override
  String get cat_sysSMC => '小麦哲伦云';

  @override
  String get cat_sysAndromeda => '仙女座星系';

  @override
  String get cat_sysTriangulum => '三角座星系';

  @override
  String get cat_pfxProxima => '比邻星';

  @override
  String get cat_pfxBarnard => '巴纳德星';

  @override
  String get cat_pfxSirius => '天狼星A';

  @override
  String get cat_pfxEpsEri => '天苑四';

  @override
  String get cat_pfxTauCeti => '天仓五';

  @override
  String get cat_pfxTeegarden => '蒂加登星';

  @override
  String get cat_mars => '火星';

  @override
  String get cat_moon => '月球';

  @override
  String get cat_venus => '金星';

  @override
  String get cat_mercury => '水星';

  @override
  String get cat_ceres => '谷神星';

  @override
  String get cat_vesta => '灶神星';

  @override
  String get cat_jupiter => '木星';

  @override
  String get cat_io => '木卫一';

  @override
  String get cat_europa => '木卫二';

  @override
  String get cat_ganymede => '木卫三';

  @override
  String get cat_callisto => '木卫四';

  @override
  String get cat_saturn => '土星';

  @override
  String get cat_enceladus => '土卫二';

  @override
  String get cat_titan => '土卫六';

  @override
  String get cat_uranus => '天王星';

  @override
  String get cat_miranda => '天卫五';

  @override
  String get cat_titania => '天卫三';

  @override
  String get cat_neptune => '海王星';

  @override
  String get cat_triton => '海卫一';

  @override
  String get cat_pluto => '冥王星';

  @override
  String get cat_charon => '冥卫一';

  @override
  String get cat_haumea => '妊神星';

  @override
  String get cat_makemake => '鸟神星';

  @override
  String get cat_eris => '阋神星';

  @override
  String get cat_sedna => '赛德娜';

  @override
  String get cat_planetNine => '第九行星';

  @override
  String get u_topUpTitle => '信用点不足';

  @override
  String u_topUpBody(int credits, int gems) {
    return '还差💰$credits。用⭐$gems补足并继续吗？';
  }

  @override
  String u_topUpNoGems(int gems) {
    return '需要⭐$gems。去商店购买宝石吗？';
  }

  @override
  String get u_topUpOk => '补足并继续';

  @override
  String get u_goShop => '去商店';

  @override
  String get u_exchangeTitle => '💰 兑换信用点';

  @override
  String u_exchangeBody(int gems, int credits) {
    return '用⭐$gems兑换💰$credits吗？';
  }

  @override
  String get m_adPrivacy => '广告隐私设置';
}
