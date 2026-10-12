// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class L10nJa extends L10n {
  L10nJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Star Settlers';

  @override
  String get languageName => '日本語';

  @override
  String get u_tabShip => '艦船';

  @override
  String get u_tabStation => 'ステーション';

  @override
  String get u_tabCrew => 'クルー';

  @override
  String get u_tabMission => '任務';

  @override
  String get u_tabMarket => '市場';

  @override
  String u_upWeapon(int dmg) {
    return '攻撃力 $dmg · Lv.3 2連射 · Lv.6 3連射';
  }

  @override
  String u_upHull(int hp) {
    return '最大HP $hp';
  }

  @override
  String u_upEngine(int speed) {
    return '最高速度 $speed';
  }

  @override
  String get u_upMissileIntro => '敵を追尾するミサイル（Qキー / 🚀ボタン）';

  @override
  String u_upMissile(int count, String cooldown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count発',
    );
    return '$_temp0 · クールタイム$cooldown秒';
  }

  @override
  String get u_upShieldIntro => 'すべてのダメージを防ぐシールド（Fキー / 🛡ボタン）';

  @override
  String u_upShield(String duration, String cooldown) {
    return '$duration秒 · クールタイム$cooldown秒';
  }

  @override
  String get u_upDroneIntro => '周りを回って自動で撃ち、アイテムを引き寄せるよ';

  @override
  String u_upDrone(int dmg, String interval) {
    return 'ダメージ $dmg · $interval秒ごとに発射';
  }

  @override
  String u_upMagnet(int range, String power) {
    return 'クレジット・鉱石を引き寄せる範囲 $range · 強さ x$power';
  }

  @override
  String get u_equip => '装備';

  @override
  String get u_hangarSection => '🛸 格納庫';

  @override
  String get u_viewLarge => '大きく見る';

  @override
  String get u_hp => 'HP';

  @override
  String get u_speed => '速度';

  @override
  String get u_attack => '攻撃';

  @override
  String get u_fireRate => '連射';

  @override
  String get u_ore => '鉱石';

  @override
  String get u_crit => '会心';

  @override
  String get u_boarded => '搭乗中';

  @override
  String get u_board => '搭乗';

  @override
  String get u_boardNow => '搭乗する';

  @override
  String get u_gemsOnly => 'ジェム限定';

  @override
  String u_unlockOrGems(String condition) {
    return '解放: $condition またはジェム';
  }

  @override
  String u_unlock(String condition) {
    return '解放: $condition';
  }

  @override
  String u_durability(int hp, int max) {
    return '耐久度 $hp / $max';
  }

  @override
  String get u_habitat => '居住区';

  @override
  String u_habitatDesc(String rate, int hp) {
    return '収入 💰$rate/s · 耐久度 $hp';
  }

  @override
  String get u_turret => '防衛砲台';

  @override
  String get u_turretIntro => '海賊を自動で迎撃します';

  @override
  String u_turretDesc(int dmg, int range) {
    return 'ダメージ $dmg · 射程 $range';
  }

  @override
  String get u_baseUpgrade => '本拠地強化';

  @override
  String u_baseDesc(int dmg, int range, int hp) {
    return 'レーザー $dmg · 射程 $range · 耐久度 $hp';
  }

  @override
  String u_disabledSec(int sec) {
    return '機能停止 $sec秒';
  }

  @override
  String u_sectorStatus(String sector) {
    return '$sector の状況';
  }

  @override
  String u_sectorStats(
    int colonies,
    int planets,
    int stations,
    String mul,
    String other,
  ) {
    return '入植した惑星 $colonies / $planets\nステーション $stations基\n星系ボーナス: 生産量 x$mul\n他星系収入: 💰$other/s';
  }

  @override
  String get u_legendaryGet => '🌟 レジェンド！ 🌟';

  @override
  String get u_rareGet => '✨ レアな仲間！ ✨';

  @override
  String get u_newCrew => '新しい仲間が加入！';

  @override
  String get u_great => 'やった！';

  @override
  String u_crewHeader(int count, int cap, int assigned, int slots) {
    return 'クルー $count/$cap · 配置 $assigned/$slots';
  }

  @override
  String u_recruit(int cost) {
    return 'スカウト 💰$cost';
  }

  @override
  String u_recruitPremium(int cost) {
    return '高級スカウト ⭐$cost';
  }

  @override
  String u_recruitLegendary(int cost) {
    return '🌟 レジェンド確定 ⭐$cost';
  }

  @override
  String u_recruitOdds(String normal, String premium) {
    return '確率 · スカウト: $normal\n高級スカウト: $premium\nレジェンド確定: ★4 100%';
  }

  @override
  String u_slotMax(int n) {
    return '配置枠 MAX ($n)';
  }

  @override
  String u_slotBuy(int price) {
    return '配置枠 +1 ⭐$price';
  }

  @override
  String u_rosterMax(int n) {
    return '定員 MAX ($n)';
  }

  @override
  String u_rosterBuy(int size, int price) {
    return '定員 +$size ⭐$price';
  }

  @override
  String get u_noCrew => 'まだ仲間がいません。スカウトして艦船に配置しよう！';

  @override
  String get u_unassign => '解除';

  @override
  String get u_assign => '配置';

  @override
  String get u_dismiss => '解雇';

  @override
  String get u_dismissCrewTitle => 'クルーの解雇';

  @override
  String u_dismissCrewBody(String name) {
    return '$nameとお別れしますか？元に戻せません。';
  }

  @override
  String get u_missionDeliverHint => '目的地へ向かおう（黄色い矢印）';

  @override
  String get u_missionBountyHint => '目標を見つけて倒そう（黄色い矢印）';

  @override
  String u_reward(String rewards) {
    return '報酬 $rewards';
  }

  @override
  String u_activeMissions(int n) {
    return '進行中 ($n/3)';
  }

  @override
  String get u_noActiveMissions => '進行中の任務はありません。';

  @override
  String get u_abandon => '放棄';

  @override
  String u_missionBoard(int sec) {
    return '任務掲示板 · 次の任務まで$sec秒';
  }

  @override
  String get u_accept => '受注';

  @override
  String get u_priceHigh => '📈 高値！売りどき';

  @override
  String get u_priceLow => '📉 安値…待とう';

  @override
  String get u_priceNormal => '➡ 普通';

  @override
  String get u_orePrice => '鉱石相場';

  @override
  String get u_sell100 => '100個売る';

  @override
  String get u_sellHalf => '半分売る';

  @override
  String get u_sellAll => '全部売る';

  @override
  String get u_marketTip => '相場は時間とともに上下します。高いときに売ろう！';

  @override
  String get u_gemExchange => '⭐ スタージェム交換';

  @override
  String get u_creditPack => 'クレジットパック';

  @override
  String get u_exchange => '交換';

  @override
  String get u_openShop => '⭐ ショップを開く';

  @override
  String u_achievementDone(String title, int gems) {
    return '🏆 実績達成: $title！メニューの実績で⭐$gemsを受け取ってね。';
  }

  @override
  String get u_cannotDo => '資源が足りないか、今はできません。';

  @override
  String get u_welcomeBack => 'おかえりなさい、艦長！';

  @override
  String u_offlineHm(int h, int m) {
    return '留守にしていた$h時間$m分の間、\n植民地ががんばって働きました！';
  }

  @override
  String u_offlineM(int m) {
    return '留守にしていた$m分の間、\n植民地ががんばって働きました！';
  }

  @override
  String get u_passOfflineHint => '司令官パス: 最大8時間 + 自動2倍';

  @override
  String get u_collect => '受け取る';

  @override
  String get u_adLoading => '広告を読み込み中です。少し待ってからもう一度お試しください。';

  @override
  String get u_adLoadingRetry => '広告を読み込み中です。少し待ってからもう一度押してください。';

  @override
  String get u_collectDouble => '2倍で受け取る 👑';

  @override
  String get u_adDouble => '📺 広告を見て2倍';

  @override
  String get u_galaxyHonor => '🌌 銀河の名誉';

  @override
  String u_honorStatus(int honor, int ascensions) {
    return '現在の名誉 $honor（転生 $ascensions回）';
  }

  @override
  String u_honorBonus(int income, int attack) {
    return '収入 +$income% · 攻撃力 +$attack%';
  }

  @override
  String get u_ascendExplain =>
      '転生すると今の宇宙（星系、植民地、ステーション、艦船強化、クルー、クレジット）がリセットされ、\n代わりに永続ボーナスの名誉ポイントがもらえます。\nジェム、着せ替え、艦船、実績はそのまま残ります。';

  @override
  String u_ascendGain(int gain) {
    return '今転生すると名誉 +$gain！\n（帝国が大きいほど多くもらえます）';
  }

  @override
  String get u_ascendLocked => '星系4に到達すると転生できます。';

  @override
  String get u_close => '閉じる';

  @override
  String u_ascendBtn(int gain) {
    return '転生 (+$gain)';
  }

  @override
  String get u_ascendConfirmTitle => '本当に転生しますか？';

  @override
  String get u_ascendConfirmBody => '今の宇宙がリセットされます。元に戻せません。';

  @override
  String get u_ascend => '転生';

  @override
  String u_shieldBroken(String name) {
    return '$name 破損';
  }

  @override
  String u_hudSector(String sector, int dev, String threat, String value) {
    return '$sector · 発展 $dev%\n⚠ 脅威 $threat  🏛 $value';
  }

  @override
  String u_baseDisabled(int sec) {
    return '本拠地停止 ${sec}s';
  }

  @override
  String u_baseHp(int pct) {
    return '本拠地 $pct%';
  }

  @override
  String get u_merchantE => '商人 (E)';

  @override
  String get u_nextSectorE => '次の星系 (E)';

  @override
  String get u_prevSectorE => '前の星系 (E)';

  @override
  String u_gateLocked(int pct) {
    return '🔒 発展度100%で開きます ($pct%)';
  }

  @override
  String u_settle(String name) {
    return '$nameに入植';
  }

  @override
  String u_manageE(String name) {
    return '$nameを管理 (E)';
  }

  @override
  String get u_buildStation => 'ステーション建設';

  @override
  String get u_fire => '発射';

  @override
  String get u_equipAtStation => 'ステーションの艦船タブで装備できます！';

  @override
  String get u_shotDown => '💥 撃墜されました！';

  @override
  String u_autoRespawn(int sec) {
    return '$sec秒後に基地から自動で再出撃';
  }

  @override
  String get u_reviveFree => '👑 この場で復活（無料）';

  @override
  String get u_reviveAd => '📺 広告を見てこの場で復活';

  @override
  String get u_reviveGems => '⭐10でこの場で復活';

  @override
  String u_respawnBase(int pct) {
    return '🏠 基地から再出撃（クレジット$pct%減少）';
  }

  @override
  String get u_spkCaptain => '艦長';

  @override
  String get u_spkPirate => '海賊';

  @override
  String get u_spkAdvisor => '副官ミナ';

  @override
  String get u_spkMerchant => '商人ニャンニャン';

  @override
  String get u_paused => '一時停止';

  @override
  String u_pauseStats(
    String sector,
    int kills,
    int crew,
    int colonies,
    int stations,
    int missions,
  ) {
    return '$sector · 撃墜 $kills · クルー $crew\n入植 $colonies · ステーション $stations · 任務完了 $missions';
  }

  @override
  String get u_resume => '▶︎ 続ける';

  @override
  String get u_shop => '⭐ ショップ';

  @override
  String get u_achievements => '🏆 実績';

  @override
  String get u_dailyQuests => '📅 デイリークエスト';

  @override
  String get u_myPlanet => '🌍 マイ惑星';

  @override
  String get u_ascendMenu => '🌌 銀河の名誉（転生）';

  @override
  String get u_settings => '⚙ 設定';

  @override
  String get u_saveAndQuit => '💾 セーブしてタイトルへ';

  @override
  String get u_keyboardHelp =>
      'キー: WASD 移動 · Space 射撃 · Q ミサイル · F シールド · Shift ブースト\nE 操作 · B ステーション建設 · Esc メニュー';

  @override
  String get u_recharging => '再充電中';

  @override
  String get u_tutDome => 'シールド\n中にいれば安全';

  @override
  String get u_tutLevelUp => 'レベルアップ\n収入・建物↑';

  @override
  String get u_tutTurret => '砲台';

  @override
  String get u_tutRepair => '修理';

  @override
  String get u_tutRaid => '襲撃を防ぐ';

  @override
  String get u_gotIt => 'わかった';

  @override
  String u_damage(int dmg) {
    return 'ダメージ $dmg';
  }

  @override
  String u_oreRate(String rate) {
    return '鉱石 +$rate/s';
  }

  @override
  String u_incomePct(int pct) {
    return '収入 +$pct%';
  }

  @override
  String u_repairRate(int hp) {
    return 'HP +$hp/s';
  }

  @override
  String u_shieldPlus(int amount) {
    return 'シールド +$amount';
  }

  @override
  String u_systemTitle(String sector, int n) {
    return '$sector · 星系 $n';
  }

  @override
  String u_systemInfo(String threat, String mul) {
    return '脅威 $threat · 資源倍率 x$mul';
  }

  @override
  String u_development(int pct) {
    return '発展度 $pct%';
  }

  @override
  String get u_nextSystemOpen => '次の星系が開放';

  @override
  String get u_opensAt100 => '100%で開放';

  @override
  String get u_devHint => 'すべての惑星をLv.3にすると100%';

  @override
  String get u_conqueredSystems => '制圧した星系（生産継続中）';

  @override
  String get u_unsettled => '未入植';

  @override
  String get u_underRaid => '襲撃中';

  @override
  String u_unknownSector(int n) {
    return '未知の星系 $n';
  }

  @override
  String u_sectorDev(String name, int pct) {
    return '$name · 発展 $pct%';
  }

  @override
  String get u_buildStationTitle => 'ステーション建設 · 役割を選ぶ';

  @override
  String get u_cost => 'コスト';

  @override
  String get u_build => '建設';

  @override
  String get u_toNextSector => '🌀 次の星系へ';

  @override
  String get u_bossLocked => '🔒 ボスを倒すと開放';

  @override
  String get u_toPrevSector => '🌀 前の星系へ';

  @override
  String get u_raidAlert => '⚠ 襲撃中！';

  @override
  String u_rechargePct(int pct) {
    return '再充電 $pct%';
  }

  @override
  String u_merchantLabel(int sec) {
    return '🛒 さすらいの商人 ($sec秒)';
  }

  @override
  String get u_supplyPod => '📦 補給カプセル';

  @override
  String u_sectorBoss(String sector) {
    return '☠ $sectorのボス';
  }

  @override
  String get u_pirateBoss => '☠ 海賊ボス';

  @override
  String get u_merchantName => 'さすらいの商人ニャンニャン';

  @override
  String u_merchantLeaves(int sec, String credits) {
    return '$sec秒後に出発 · 💰$credits';
  }

  @override
  String get u_rareCrewOffer => 'レアな仲間の紹介';

  @override
  String get u_crewSoldOut => '今日の仲間はもう売り切れだニャ！';

  @override
  String get u_gemTrade => 'ジェム両替（3回まで）';

  @override
  String u_gemTradeRow(int price, int left) {
    return '💰$price → ⭐5  (残り$left回)';
  }

  @override
  String get u_convert => '両替';

  @override
  String get u_potions => '強化ポーション（効果時間2倍）';

  @override
  String get u_notEnoughGems => 'ジェムが足りません';

  @override
  String get u_buyConfirmTitle => '購入の確認';

  @override
  String u_buyShipConfirm(String ship, String price) {
    return '$shipに$priceを使いますか？';
  }

  @override
  String u_shipBought(String ship) {
    return '$shipをゲット！さっそく搭乗しました';
  }

  @override
  String get u_premiumShips => 'プレミアム艦船';

  @override
  String get u_hangarTitle => '格納庫';

  @override
  String u_buyGems(int price) {
    return '⭐$priceで購入';
  }

  @override
  String get u_premium => 'プレミアム';

  @override
  String get u_ok => 'OK';

  @override
  String get u_cancel => 'キャンセル';

  @override
  String get m_ok => 'OK';

  @override
  String get m_cancel => 'キャンセル';

  @override
  String get m_close => '閉じる';

  @override
  String get m_claim => '受け取る';

  @override
  String m_claimGems(int gems) {
    return '⭐$gems 受け取る';
  }

  @override
  String get m_done => '✅ 完了';

  @override
  String get m_notEnoughGems => 'ジェムが足りません';

  @override
  String get m_restorePurchases => '購入を復元';

  @override
  String get m_restoreDone => '購入履歴を確認しました';

  @override
  String get m_buyConfirmTitle => '購入の確認';

  @override
  String m_spendGemsConfirm(String price) {
    return '$priceを使いますか？';
  }

  @override
  String get m_loginTitle => '📅 ログインボーナス';

  @override
  String get m_loginWelcome => '今日も来てくれたんですね、艦長！';

  @override
  String get m_loginFirst => 'ようこそ、艦長！初めてのログインボーナスです。';

  @override
  String get m_loginStreakHint => '7日連続ログインで⭐50！';

  @override
  String get m_newGameTitle => 'ニューゲーム';

  @override
  String get m_newGameBody => '今の進行状況が消えます。\n（ジェム、着せ替え、実績、購入アイテムは残ります）続けますか？';

  @override
  String get m_start => 'スタート';

  @override
  String get m_loadFailed => 'セーブデータを読み込めませんでした。';

  @override
  String m_honorLine(int honor, int income, int attack) {
    return '🌌 銀河の名誉 $honor · 収入 +$income% · 攻撃 +$attack%';
  }

  @override
  String get m_continue => 'つづきから';

  @override
  String get m_newGame => '✨ ニューゲーム';

  @override
  String get m_menuHome => 'マイ惑星';

  @override
  String get m_menuShop => 'ショップ';

  @override
  String get m_menuQuest => 'クエスト';

  @override
  String get m_menuAchievements => '実績';

  @override
  String get m_menuSettings => '設定';

  @override
  String m_achievementsTitle(int done, int total) {
    return '🏆 実績 ($done/$total)';
  }

  @override
  String get m_dailyTitle => '📅 デイリークエスト';

  @override
  String m_dailyReset(int hours, int minutes) {
    return 'リセットまで$hours時間$minutes分';
  }

  @override
  String get m_dailyBonusTitle => '🎁 全達成ボーナス';

  @override
  String get m_dailyBonusDesc => '今日のクエスト3つをすべて受け取ると';

  @override
  String get m_settingsTitle => '⚙ 設定';

  @override
  String get m_settingsSound => '効果音';

  @override
  String get m_settingsMusic => 'BGM';

  @override
  String get m_settingsNotify => 'おかえり通知';

  @override
  String get m_settingsNotifyDesc => '植民地の倉庫がいっぱいになったらお知らせします';

  @override
  String get m_settingsHaptics => '振動';

  @override
  String get m_settingsLanguage => '言語';

  @override
  String get m_languageSystem => '端末の言語に合わせる';

  @override
  String get m_settingsOrientation => '画面の向き';

  @override
  String get m_orientAuto => '自動';

  @override
  String get m_orientPortrait => '縦';

  @override
  String get m_orientLandscape => '横';

  @override
  String get m_privacyTitle => 'プライバシーポリシー';

  @override
  String m_privacyBody(String email) {
    return 'Star Settlersは会員登録がなく、個人を特定できる情報は収集しません。ゲームデータ（進行状況、クレジット・鉱石、着せ替え、設定）は端末内に保存されます。ジェムと購入記録は改ざんや紛失を防ぐためサーバーのジェムウォレットに保管し、週間ランキングはご自身でオンにした場合のみ下記の情報をサーバーに送ります。\n\n課金: Google Play / App Storeが処理し、決済情報が開発者に渡ることはありません。購入の確認と復元にはRevenueCatを使用し、ランダムなインストールIDと購入履歴が処理されます。購入が確認されるとサーバーがジェムウォレットに付与します。\n\nジェムウォレット: ジェムは端末ではなくサーバーに保管するため、改ざんで増やすことはできません。サーバーにはランダムなインストールID（広告IDや端末IDではありません）、ジェム残高、ジェムの獲得・使用記録、購入記録が保存され、名前や入力した文字は送りません。ジェムを使うにはインターネット接続が必要です。サーバーはSupabase（ソウルリージョン）です。\n\n広告: 自分で選んだときだけGoogle AdMobのリワード広告が流れます。AdMobは広告の配信、許可されている場合のパーソナライズ、広告の測定のために、広告ID、IPアドレス、端末情報を使用することがあります。欧州経済領域・英国・スイスでは初回起動時に同意を確認し、設定 → 広告のプライバシー設定 で変更できます。\n\n通知: 端末内で予約するローカル通知で、外部には送信されません。\n\nフィードバック: ご自身でメールを送った場合のみ、内容とアプリのバージョン・端末情報が開発者に届きます。\n\n週間ランキング（任意）: 初期設定はオフで、設定またはランキング画面でオンにしたときだけ参加します。送るのはランダムなインストールID、ゲームが決まった単語リストから作るニックネーム、週間スコアだけです。名前や入力した文字は送らず、チャットもありません。ほかのプレイヤーに見えるのはニックネームとスコアだけです。サーバーはSupabase（ソウルリージョン）です。\n\n削除: 設定 → すべてのデータをリセット で端末のデータを消去できます。リセットするとサーバーのジェム残高も0になり、スターターパックと艦隊司令官パスは購入記録から戻ります。ランキングに参加していた場合は、リセット時にサーバー上のランキング記録（ID・ニックネーム・スコア）も削除されます。メールで削除を依頼することもできます。\n\nポリシー全文: https://rumururu.github.io/mkideabox/star_settlers/privacy.html\nお問い合わせ: $email';
  }

  @override
  String get m_wipeTitle => 'すべてのデータをリセット';

  @override
  String get m_wipeDesc => '進行状況、ジェム、着せ替え、ランキングの記録がすべて削除されます';

  @override
  String get m_wipeConfirmTitle => '本当にリセットしますか？';

  @override
  String get m_wipeConfirmBody =>
      '元に戻せません。ジェムと進行状況は完全に削除されます。スターターパックと艦隊司令官パスは「購入を復元」で取り戻せます。';

  @override
  String get m_wipeOk => 'リセット';

  @override
  String get m_feedbackTitle => '開発者にフィードバックを送る';

  @override
  String get m_feedbackDesc => 'バグや要望、なんでもどうぞ。端末とアプリのバージョンは自動で入力されます。';

  @override
  String m_noMailApp(String email) {
    return 'メールアプリがありません。$email まで送ってください。';
  }

  @override
  String get m_aboutTitle => 'STAR SETTLERS';

  @override
  String m_version(String version) {
    return 'バージョン $version';
  }

  @override
  String get m_shopTitle => '⭐ ショップ';

  @override
  String get m_buyThanks => '購入完了！ありがとうございます 💜';

  @override
  String get m_walletOffline => 'ジェムはサーバーに保管されています。インターネットに接続してからもう一度お試しください。';

  @override
  String get m_purchasePending => 'お支払いは完了しました。確認でき次第、ジェムが届きます。';

  @override
  String get m_adLoading => '広告を読み込み中です。少し待ってからもう一度お試しください。';

  @override
  String m_buyShipConfirm(String ship, String price) {
    return '$shipに$priceを使いますか？';
  }

  @override
  String m_shipAcquired(String ship) {
    return '$shipをゲット！さっそく搭乗しました';
  }

  @override
  String get m_tabGems => 'ジェム';

  @override
  String get m_tabPacks => 'パック';

  @override
  String get m_tabPremiumShips => 'プレミアム艦船';

  @override
  String get m_tabSkins => '艦船スキン';

  @override
  String get m_tabOutfits => '艦長の衣装';

  @override
  String get m_tabFree => '無料ジェム';

  @override
  String get m_testMode => '🧪 テストモード: 実際の課金なし・広告はGoogleのテスト広告';

  @override
  String get m_owned => '所持中';

  @override
  String get m_boarded => '搭乗中';

  @override
  String get m_gemsInfo =>
      'ジェムは着せ替え、高級スカウト、即時復活、クレジット交換に使えます。\nプレイ（実績・ログイン・ボス・補給カプセル）でも集められます。';

  @override
  String get m_crewSection => '👩‍🚀 クルー（ジェム）';

  @override
  String get m_premiumSection => '🛸 プレミアム艦船';

  @override
  String get m_premiumDesc => 'ジェムでしか手に入らない特別な戦闘機。固有の能力があります。';

  @override
  String get m_viewLarge => '1機ずつ大きく見る';

  @override
  String get m_premiumHangarHint => '格納庫（ステーション → 艦船タブ）でも購入・乗り換えができます。';

  @override
  String get m_legendTitle => 'レジェンドクルー確定スカウト';

  @override
  String get m_legendDescNoGame =>
      '★4 レジェンドクルー1人（ボーナス20%〜＋全生産+40%、称号・金色のオーラ）\nゲーム開始後に購入できます';

  @override
  String m_legendDesc(int count, int cap) {
    return '★4 レジェンドクルー1人（ボーナス20%〜＋全生産+40%、称号・金色のオーラ）\nクルー $count/$cap';
  }

  @override
  String m_crewJoined(String stars, String name) {
    return '$stars $name が加入！';
  }

  @override
  String get m_slotTitle => '配置枠 +1';

  @override
  String m_slotDesc(int slots) {
    return '同時に配置できるクルーの数 · 現在 $slots';
  }

  @override
  String m_rosterTitle(int n) {
    return 'クルー定員 +$n';
  }

  @override
  String m_rosterDesc(int cap, int max) {
    return '保有できるクルーの数 · 現在 $cap（最大 $max）';
  }

  @override
  String m_crewOdds(String odds) {
    return '高級スカウト確率: $odds · レジェンド確定: ★4 100%';
  }

  @override
  String get m_equipped => '装備中';

  @override
  String get m_equip => '装備';

  @override
  String get m_passOnly => '司令官パス限定';

  @override
  String get m_starterOnly => 'スターターパック限定';

  @override
  String get m_adSection => '📺 広告で無料ジェム';

  @override
  String m_adInfo(int perDay, int left) {
    return '1日$perDay回、1回⭐5 · 今日の残り$left回';
  }

  @override
  String get m_adClaimPremium => '⭐5 受け取る（司令官パス: 広告なし）';

  @override
  String get m_adWatch => '広告を見て⭐5';

  @override
  String m_loginStreak(int days) {
    return '連続ログイン$days日目';
  }

  @override
  String m_dayN(int day) {
    return '$day日目';
  }

  @override
  String get m_notEnoughResources => '資源が足りません';

  @override
  String m_emptyLot(int n) {
    return '空き地 #$n · 建設';
  }

  @override
  String get m_buildInGameOnly =>
      '建設はゲーム中（メニュー → マイ惑星）にできます。クレジットと鉱石は今の宇宙のものを使います。';

  @override
  String m_heldAll(String credits, String ore, int gems) {
    return '所持 💰$credits  💎$ore  ⭐$gems';
  }

  @override
  String m_held(String credits, String ore) {
    return '所持 💰$credits  💎$ore';
  }

  @override
  String m_currentEffect(String effect) {
    return '現在の効果: $effect';
  }

  @override
  String m_nextLevel(String effect) {
    return '次のレベル: $effect';
  }

  @override
  String m_upgrade(String cost) {
    return 'アップグレード $cost';
  }

  @override
  String get m_maxLevel => '🌟 最大レベル';

  @override
  String get m_planetName => '惑星の名前';

  @override
  String get m_decorateTitle => '🎨 惑星デコ';

  @override
  String get m_planetRing => '惑星の環';

  @override
  String get m_giftInGameOnly => 'プレゼントはゲーム中に受け取れます';

  @override
  String get m_giftTitle => '🎁 惑星からのプレゼント';

  @override
  String m_giftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '住民$count人が集めたプレゼントです！',
    );
    return '$_temp0';
  }

  @override
  String get m_giftThanks => 'ありがとう！';

  @override
  String m_planetStatus(int level, int residents, int built, int slots) {
    return '惑星 Lv.$level · 住民 $residents人 · 建物 $built/$slots';
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
    return '永続ボーナス · 収入 +$income%  鉱石 +$ore%  攻撃 +$attack%  HP +$hp%  クールタイム -$cooldown%  オフライン $offline%';
  }

  @override
  String get m_planetHint => 'スワイプで惑星を回し、区画をタップして建設';

  @override
  String get m_giftClaim => '🎁 プレゼントを受け取る';

  @override
  String m_giftWait(int hours, int minutes) {
    return '🎁 プレゼントまで$hours時間$minutes分';
  }

  @override
  String m_planetLevelUp(int level, String cost) {
    return '🌍 惑星 Lv.$level（区画 +2）$cost';
  }

  @override
  String get g_shipScoutName => 'スカウト';

  @override
  String get g_shipInterceptorName => 'インターセプター';

  @override
  String get g_shipFortressName => 'フォートレス';

  @override
  String get g_shipProspectorName => 'プロスペクター';

  @override
  String get g_shipPhantomName => 'ファントム';

  @override
  String get g_shipNovaName => 'ノヴァドラゴン';

  @override
  String get g_shipAuroraName => 'オーロラ';

  @override
  String get g_shipScoutDesc => 'バランスのとれた基本の艦船';

  @override
  String get g_shipInterceptorDesc => '速くて連射も速いけど、装甲が薄いよ';

  @override
  String get g_shipFortressDesc => '遅いけど頑丈で、一撃が重いよ';

  @override
  String get g_shipProspectorDesc => '鉱石+50%、遠くのアイテムも引き寄せるよ';

  @override
  String get g_shipPhantomDesc => '25%の確率で2.5倍の会心';

  @override
  String get g_shipNovaDesc => '弾が敵を貫くプレミアム戦闘機';

  @override
  String get g_shipAuroraDesc => '自己修復とバリアを備えたプレミアム守護艦';

  @override
  String get g_shipNovaAbility => '貫通弾: 1発で敵2機まで貫通';

  @override
  String get g_shipAuroraAbility =>
      '自己修復: 3秒間被弾しないと毎秒HP3%回復\n守護膜: 8秒ごとに被弾を1回防ぐ';

  @override
  String g_crewLegendPerk(int pct) {
    return '👑 レジェンド指揮: 全生産（クレジット・鉱石）+$pct%（重複なし）';
  }

  @override
  String g_shipCreditBonus(int pct) {
    return '💰 ハンターボーナス: 自分で稼ぐクレジット+$pct%（賞金・小惑星・任務・襲撃防衛）';
  }

  @override
  String g_unlockSector(int n) {
    return '星系$nに到達';
  }

  @override
  String g_unlockBosses(int n) {
    return '海賊ボスを$n回撃破';
  }

  @override
  String g_unlockOre(int n) {
    return '鉱石を$n個集める';
  }

  @override
  String get g_skinDefault => 'ベーシックスカウト';

  @override
  String get g_skinCrimson => 'レッドコメット';

  @override
  String get g_skinMint => 'チョコミント';

  @override
  String get g_skinStealth => 'ステルスブラック';

  @override
  String get g_skinNeon => 'ネオンピンク';

  @override
  String get g_skinRainbow => 'レインボードリーム';

  @override
  String get g_skinGalaxy => 'ギャラクシー';

  @override
  String get g_skinGold => 'ゴールドロイヤル';

  @override
  String get g_outfitDefault => '基本の宇宙服';

  @override
  String get g_outfitCat => 'ネコミミヘルメット';

  @override
  String get g_outfitBunny => 'ウサミミ';

  @override
  String get g_outfitAlien => '宇宙人の触角';

  @override
  String get g_outfitFlower => 'お花のピン';

  @override
  String get g_outfitHat => '艦長帽';

  @override
  String get g_outfitCrown => '銀河の王冠';

  @override
  String get g_crewRoleGunner => '砲手';

  @override
  String get g_crewEffectGunner => '攻撃力';

  @override
  String get g_crewRoleEngineer => '機関士';

  @override
  String get g_crewEffectEngineer => '最大HP・修理';

  @override
  String get g_crewRolePilot => 'パイロット';

  @override
  String get g_crewEffectPilot => '速度';

  @override
  String get g_crewRoleTrader => '商人';

  @override
  String get g_crewEffectTrader => 'クレジット収入';

  @override
  String get g_crewRoleMiner => '鉱夫';

  @override
  String get g_crewEffectMiner => '鉱石獲得';

  @override
  String get g_crewRoleScientist => '科学者';

  @override
  String get g_crewEffectScientist => 'スキルのクールタイム短縮';

  @override
  String get g_crewName0 => 'モンチ';

  @override
  String get g_crewName1 => 'ココ';

  @override
  String get g_crewName2 => 'ホシ';

  @override
  String get g_crewName3 => 'トーフ';

  @override
  String get g_crewName4 => 'マメ';

  @override
  String get g_crewName5 => 'ルル';

  @override
  String get g_crewName6 => 'ハル';

  @override
  String get g_crewName7 => 'ポポ';

  @override
  String get g_crewName8 => 'ミミ';

  @override
  String get g_crewName9 => 'ドリ';

  @override
  String get g_crewName10 => 'モフモフ';

  @override
  String get g_crewName11 => 'チョウチョ';

  @override
  String get g_crewName12 => 'チョコ';

  @override
  String get g_crewName13 => 'ムギ';

  @override
  String get g_crewName14 => 'クモ';

  @override
  String get g_crewName15 => 'コサメ';

  @override
  String get g_crewName16 => 'トリ';

  @override
  String get g_crewName17 => 'ハッピー';

  @override
  String get g_crewName18 => 'オモチ';

  @override
  String get g_crewName19 => 'モチ';

  @override
  String get g_crewName20 => 'ラテ';

  @override
  String get g_crewName21 => 'クッキー';

  @override
  String get g_crewName22 => 'ゼリー';

  @override
  String get g_crewName23 => 'ワタ';

  @override
  String get g_crewName24 => 'マンゴー';

  @override
  String get g_crewName25 => 'スモモ';

  @override
  String get g_crewName26 => 'クルミ';

  @override
  String get g_crewName27 => 'クロ';

  @override
  String get g_crewName28 => 'バンビ';

  @override
  String get g_crewName29 => 'チーズ';

  @override
  String get g_crewLegend0 => '銀河の守護者';

  @override
  String get g_crewLegend1 => '星の英雄';

  @override
  String get g_crewLegend2 => '星雲の賢者';

  @override
  String get g_crewLegend3 => '彗星の騎士';

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
    return '住民 +$n人（プレゼント増加）';
  }

  @override
  String get g_bldFarm => '宇宙農場';

  @override
  String g_bldFarmEffect(int n) {
    return 'クレジット収入 +$n%';
  }

  @override
  String get g_bldMine => '鉱山';

  @override
  String g_bldMineEffect(int n) {
    return '鉱石獲得 +$n%';
  }

  @override
  String get g_bldLab => '研究所';

  @override
  String g_bldLabEffect(int n) {
    return 'スキルのクールタイム -$n%';
  }

  @override
  String get g_bldTower => '防衛タワー';

  @override
  String g_bldTowerEffect(int n) {
    return '最大HP +$n%';
  }

  @override
  String get g_bldShipyard => '造船所';

  @override
  String g_bldShipyardEffect(int n) {
    return '攻撃力 +$n%';
  }

  @override
  String get g_bldPark => '遊園地';

  @override
  String g_bldParkEffect(int n) {
    return 'オフライン収入 +$n%p';
  }

  @override
  String get g_bldStatue => '艦長の銅像';

  @override
  String g_bldStatueEffect(int n) {
    return '惑星のプレゼントのジェム +$n';
  }

  @override
  String get g_homePalette0 => '緑の庭園';

  @override
  String get g_homePalette1 => '砂の砂漠';

  @override
  String get g_homePalette2 => '氷の王国';

  @override
  String get g_homePalette3 => '溶岩の島';

  @override
  String get g_homePalette4 => '紫のガス';

  @override
  String get g_homePalette5 => '桜';

  @override
  String get g_homePalette6 => 'オーロラ';

  @override
  String get g_homePalette7 => '黄金';

  @override
  String get g_homeDefaultName => 'わたしの小さな星';

  @override
  String get g_achFirstBloodTitle => '初撃墜';

  @override
  String get g_achFirstBloodDesc => '海賊を1隻撃墜';

  @override
  String get g_achHunterTitle => '海賊ハンター';

  @override
  String get g_achHunterDesc => '海賊を100隻撃墜';

  @override
  String get g_achLegendTitle => '伝説の艦長';

  @override
  String get g_achLegendDesc => '海賊を1000隻撃墜';

  @override
  String get g_achMinerTitle => '鉱山王';

  @override
  String get g_achMinerDesc => '鉱石を1000個集める';

  @override
  String get g_achMiner2Title => '鉱石長者';

  @override
  String get g_achMiner2Desc => '鉱石を10000個集める';

  @override
  String get g_achColonistTitle => '開拓者';

  @override
  String get g_achColonistDesc => '惑星5つに入植';

  @override
  String get g_achMetropolisTitle => 'メトロポリス';

  @override
  String get g_achMetropolisDesc => '植民地をLv.5に育てる';

  @override
  String get g_achBuilderTitle => '建築家';

  @override
  String get g_achBuilderDesc => 'ステーションを3基建設';

  @override
  String get g_achBoss1Title => 'ボス狩り';

  @override
  String get g_achBoss1Desc => '海賊ボスを撃破';

  @override
  String get g_achBoss10Title => 'ボスキラー';

  @override
  String get g_achBoss10Desc => '海賊ボスを10回撃破';

  @override
  String get g_achExplorerTitle => '探検家';

  @override
  String get g_achExplorerDesc => '星系3に到達';

  @override
  String get g_achVoyagerTitle => '航海者';

  @override
  String get g_achVoyagerDesc => '星系6に到達';

  @override
  String get g_achRichTitle => 'お金持ち艦長';

  @override
  String get g_achRichDesc => 'クレジットを10000所持';

  @override
  String get g_achCrew6Title => '頼れる仲間';

  @override
  String get g_achCrew6Desc => 'クルーを6人スカウト';

  @override
  String get g_achCrew3starTitle => '伝説の仲間';

  @override
  String get g_achCrew3starDesc => '★3クルーをスカウト';

  @override
  String get g_achMissionsTitle => 'なんでも屋';

  @override
  String get g_achMissionsDesc => '任務を20件完了';

  @override
  String get g_achJellyTitle => 'クラゲ博士';

  @override
  String get g_achJellyDesc => '宇宙クラゲを10匹倒す';

  @override
  String get g_achFashionTitle => 'ファッショニスタ';

  @override
  String get g_achFashionDesc => '着せ替えアイテムを購入';

  @override
  String get g_achAscendTitle => '新たな始まり';

  @override
  String get g_achAscendDesc => '銀河の名誉で転生';

  @override
  String get g_achDroneTitle => '頼れるドローン';

  @override
  String get g_achDroneDesc => '戦闘ドローンを装備';

  @override
  String get g_achHome5Title => '惑星の建築家';

  @override
  String get g_achHome5Desc => 'マイ惑星に建物5つ';

  @override
  String get g_achHomeMaxTitle => '夢の惑星';

  @override
  String get g_achHomeMaxDesc => 'マイ惑星を最大レベルに';

  @override
  String get g_dailyKill => '海賊を30隻撃墜';

  @override
  String get g_dailyOre => '鉱石を300個集める';

  @override
  String get g_dailyMission => '任務を2件完了';

  @override
  String get g_dailyColony => '植民地を2回成長させる';

  @override
  String get g_dailyBoss => '海賊ボスを撃破';

  @override
  String get g_dailyPower => 'パワーアップを3個獲得';

  @override
  String get g_dailyPlay => '10分プレイ';

  @override
  String get g_dailyJelly => '宇宙クラゲを3匹倒す';

  @override
  String g_missionKill(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '海賊$n隻を掃討',
    );
    return '$_temp0';
  }

  @override
  String g_missionMine(int n) {
    return '鉱石を$n個集める';
  }

  @override
  String g_missionDeliver(String planet) {
    return '$planetへ貨物を輸送';
  }

  @override
  String g_missionBounty(String name) {
    return '指名手配: $name';
  }

  @override
  String get g_bounty0 => '隻眼のジャック';

  @override
  String get g_bounty1 => '稲妻のモリー';

  @override
  String get g_bounty2 => 'スクラップ王バーク';

  @override
  String get g_bounty3 => '赤ひげのトト';

  @override
  String get g_bounty4 => '影のレナ';

  @override
  String get g_bounty5 => 'でぶっちょポーク';

  @override
  String get g_bounty6 => '二刀流のジジ';

  @override
  String get g_bounty7 => '狂乱ハンマーのバド';

  @override
  String get g_bounty8 => '銀河ギツネのルーシー';

  @override
  String get g_bounty9 => 'ドクロ船長ボーンズ';

  @override
  String get g_storyAsteroidsTitle => '小惑星を3個壊す';

  @override
  String get g_storyAsteroidsLine0 => '艦長！まずは小惑星を壊して鉱石を集めてみましょう。';

  @override
  String get g_storyAsteroidsLine1 => 'ジョイスティックで移動して、発射ボタンで撃てばOKです！';

  @override
  String get g_storyKillsTitle => '海賊を3隻撃墜';

  @override
  String get g_storyKillsLine0 => 'レーダーに海賊が映っています！赤い矢印の方向です。';

  @override
  String get g_storyKillsLine1 => '海賊なんか、この艦の前じゃただの鉄くずさ！';

  @override
  String get g_storyColoniesTitle => '火星に入植しよう';

  @override
  String get g_storyColoniesLine0 =>
      '地球のすぐ隣の赤い惑星、火星に最初の植民地を作りましょう。近づくと入植ボタンが出ます。';

  @override
  String get g_storyColoniesLine1 => '植民地は放っておいてもクレジットを稼いでくれますよ！';

  @override
  String get g_storyShipLevelsTitle => 'ステーションで艦船を改造';

  @override
  String get g_storyShipLevelsLine0 =>
      'ヘイヴン基地に戻って艦船を改造しましょう。ステーションの近くでは修理もできますよ。';

  @override
  String get g_storyCrewTitle => 'クルーを1人スカウト';

  @override
  String get g_storyCrewLine0 => 'ひとりじゃ寂しいですよね？ステーションメニューのクルータブで仲間をスカウトしましょう！';

  @override
  String get g_storyMissionsTitle => '任務を1件完了';

  @override
  String get g_storyMissionsLine0 => 'ステーションの任務掲示板で依頼を受けてみてください。報酬がおいしいですよ。';

  @override
  String get g_storyStationsTitle => '新しいステーションを建設';

  @override
  String get g_storyStationsLine0 => 'そろそろ領域を広げましょう！惑星から離れた宇宙空間にステーションを建てましょう。';

  @override
  String get g_storyDevPercentTitle => '星系の発展度100%';

  @override
  String get g_storyDevPercentLine0 =>
      'すべての惑星をLv.3まで育てると次の星系が開きます。右上の星系ボタンで確認してくださいね！';

  @override
  String get g_storySectorTitle => 'ワープゲートで次の星系へ';

  @override
  String get g_storySectorLine0 => 'ワープゲートが開きました！ミニマップの紫色のゲートへ向かいましょう。';

  @override
  String get g_storySectorLine1 => '新しい宇宙が待ってるぞ！';

  @override
  String g_storyDevNTitle(int n) {
    return '星系$nの発展度100%';
  }

  @override
  String get g_storyDevNLine => '新しい星系の惑星をすべてLv.3まで育てましょう！';

  @override
  String g_systemN(int n) {
    return '星系$n';
  }

  @override
  String g_storyWarpNTitle(String system) {
    return '$systemへワープ';
  }

  @override
  String get g_storyWarpNLine => 'ゲートが開きました。もっと深い宇宙へ行ってみましょうか？';

  @override
  String get g_powerUpRapid => '連射';

  @override
  String get g_powerUpShield => 'シールド';

  @override
  String get g_powerUpMagnet => 'マグネット';

  @override
  String get g_powerUpDoubleCredits => 'クレジット2倍';

  @override
  String get g_planetKindGarden => '庭園惑星';

  @override
  String get g_planetKindDesert => '砂漠惑星';

  @override
  String get g_planetKindIce => '氷の惑星';

  @override
  String get g_planetKindLava => '溶岩惑星';

  @override
  String get g_planetKindGas => 'ガス惑星';

  @override
  String get g_colonyBldTurret => '防衛砲台';

  @override
  String get g_colonyBldMine => '採掘施設';

  @override
  String get g_colonyBldTrade => '交易所';

  @override
  String get g_colonyBldDock => '修理ドック';

  @override
  String get g_colonyBldShieldGen => 'シールド発生装置';

  @override
  String get g_colonyBldBlurbTurret => '植民地の近くの海賊を自動で迎撃します。襲撃対策に必須！';

  @override
  String get g_colonyBldBlurbMine => '鉱石を掘って毎秒💎を送ってくれます。';

  @override
  String get g_colonyBldBlurbTrade => 'この植民地のクレジット収入をレベルごとに25%アップ。';

  @override
  String get g_colonyBldBlurbDock => '近くにいると艦船のHPを回復します。';

  @override
  String get g_colonyBldBlurbShieldGen => 'シールドの容量と再充電速度をアップ。';

  @override
  String get g_stationRoleHome => '本拠地';

  @override
  String get g_stationRoleDefense => '防衛基地';

  @override
  String get g_stationRoleRepair => '修理基地';

  @override
  String get g_stationRoleSupport => '補給基地';

  @override
  String get g_stationRoleBlurbHome => 'レーザー砲台と安全地帯';

  @override
  String get g_stationRoleBlurbDefense => '強力な砲台 · 耐久度2倍 · 周囲の敵弾をブロック';

  @override
  String get g_stationRoleBlurbRepair =>
      '広範囲の高速修理 · 再出撃コスト10% · 近くの植民地のシールド充電2倍';

  @override
  String get g_stationRoleBlurbSupport => '近くの植民地の生産 +25%（居住区レベルごとに+5%）';

  @override
  String g_eventRaid(String planet) {
    return '$planet襲撃';
  }

  @override
  String get g_eventMeteor => '流星群';

  @override
  String get g_eventMerchant => 'さすらいの商人';

  @override
  String get g_eventSupply => '補給カプセル';

  @override
  String get g_productGems100Title => 'ひとつかみのジェム';

  @override
  String get g_productGems550Title => 'ジェムの小袋';

  @override
  String get g_productGems1200Title => 'ジェムの宝箱';

  @override
  String get g_productStarterTitle => 'スターターパック';

  @override
  String get g_productPassTitle => '艦隊司令官パス';

  @override
  String get g_productGems550Desc => '⭐550（+10%ボーナス）';

  @override
  String get g_productGems1200Desc => '⭐1200（+20%ボーナス）';

  @override
  String get g_productStarterDesc => '⭐300 + 限定スキン「ギャラクシー」+ ★3クルー（1回限り）';

  @override
  String get g_productPassDesc =>
      'クレジット収入+25%、オフライン収入8時間、広告なしで報酬、限定スキン「ゴールドロイヤル」';

  @override
  String g_testPurchaseTitle(String product) {
    return '[テスト購入] $product';
  }

  @override
  String g_testPurchaseBody(String desc, String price) {
    return '実際の決済は行われません。\n$desc\n価格: $price';
  }

  @override
  String get g_testAdTitle => '[テスト広告]';

  @override
  String get g_testAdBody => '広告を最後まで見たことにしますか？';

  @override
  String get g_webDemoTitle => 'Webデモ';

  @override
  String get g_webDemoBody => '購入と広告報酬はモバイルアプリで利用できます。';

  @override
  String get g_notifChannelName => 'おかえり通知';

  @override
  String get g_notifChannelDesc => '植民地の収入、ログインボーナスのお知らせ';

  @override
  String get g_notifStorageTitle => '植民地の倉庫がいっぱいです！';

  @override
  String get g_notifStorageBody => '艦長、たまったクレジットを受け取りに来てください。遅れると収入が止まっちゃいます。';

  @override
  String get g_notifPiratesTitle => '海賊たちがまた暴れています！';

  @override
  String get g_notifPiratesBody => '今日のログインボーナスとデイリークエストが待っていますよ。';

  @override
  String get g_upgradeWeapon => '武器';

  @override
  String get g_upgradeHull => '装甲';

  @override
  String get g_upgradeEngine => 'エンジン';

  @override
  String get g_upgradeMissile => '誘導ミサイル';

  @override
  String get g_upgradeShield => 'エネルギーシールド';

  @override
  String get g_upgradeDrone => '戦闘ドローン';

  @override
  String get g_upgradeMagnet => 'マグネット';

  @override
  String g_unknownSector(int n) {
    return '未知の星系$n';
  }

  @override
  String get g_stationHaven => 'ヘイヴン基地';

  @override
  String g_stationOutpost(String sector) {
    return '$sector前哨基地';
  }

  @override
  String g_stationNumbered(String role, int n) {
    return '$role $n号';
  }

  @override
  String get g_dlgWelcome => 'ようこそ、艦長！私は副官のミナです。';

  @override
  String get g_dlgMissionsCancelled => '前の星系の輸送・指名手配任務はキャンセルされました。';

  @override
  String get g_floatDisabled => '機能停止！';

  @override
  String get g_floatRebooted => '再起動！';

  @override
  String get g_dlgBaseRebooted => '本拠地が再起動！耐久度30%まで復旧しました。';

  @override
  String get g_dlgUpWeapon => '武器強化！海賊ども、覚悟しろ！';

  @override
  String get g_dlgUpHull => '装甲強化！これで頼もしくなったな。';

  @override
  String get g_dlgUpEngine => 'エンジン強化！もっと速く！';

  @override
  String get g_dlgMissileNew => '誘導ミサイル装備！(Q)';

  @override
  String get g_dlgMissileUp => 'ミサイル強化！';

  @override
  String get g_dlgShieldNew => 'エネルギーシールド装備！(F)';

  @override
  String get g_dlgShieldUp => 'シールド強化！';

  @override
  String get g_dlgDroneNew => '戦闘ドローン出撃！頼もしい相棒ができた。';

  @override
  String get g_dlgDroneUp => 'ドローン強化！';

  @override
  String get g_dlgUpMagnet => 'マグネット強化！クレジットが勝手に寄ってくる！';

  @override
  String get g_dlgNotOver => 'まだ終わってないぞ！';

  @override
  String get g_floatBlocked => '防いだ！';

  @override
  String get g_floatGuard => '守護膜！';

  @override
  String get g_pirateBossLose => 'ぐわぁっ！この星系は…お前のものだ…';

  @override
  String get g_pirateBossFlee => 'ぐわぁっ！覚えてやがれ、艦長！';

  @override
  String get g_dlgSupplyCollected => '補給カプセルを回収しました！';

  @override
  String get g_merchantBye => 'じゃあ、またね〜 ニャ！';

  @override
  String get g_pirateRaidTaunt => 'この植民地はもうオレたちのものだ！ガハハ！';

  @override
  String get g_dlgMeteor => '流星群を発見！クリスタルがたっぷり混ざっています。鉱石を稼ぐチャンス！';

  @override
  String get g_merchantHello => 'さすらいの商人ニャンニャンが来たニャ〜 いいものいっぱいあるニャ！';

  @override
  String get g_dlgSupplySignal =>
      'ジェム入りの補給カプセルの信号をキャッチしました！海賊が守っているので気をつけてください。';

  @override
  String get g_dlgCruiseOn =>
      '最初の訓練完了！スティックの上の［巡航］をオンにしました。指を離しても向いている方向へ進み続けます。もう一度押すとオフです。';

  @override
  String get g_dlgBossWarning => '警告！星系ボスの艦が接近中です！';

  @override
  String get g_pirateRevenge => 'リベンジしに来たぜ！覚悟しな！';

  @override
  String get g_floatShieldBroken => '破壊！';

  @override
  String get g_floatShieldBack => '再起動';

  @override
  String get g_floatGoalDone => '目標達成！';

  @override
  String g_dlgArrived(String sector) {
    return '$sectorに到着しました！';
  }

  @override
  String get g_dlgNewFrontier => '新しい開拓地です。';

  @override
  String g_dlgBaseUpgraded(String station, int level) {
    return '$station強化 Lv.$level！レーザーが強くなりました。';
  }

  @override
  String g_dlgBaseDisabled(int sec) {
    return '本拠地が機能停止！$sec秒間防御が切れます！';
  }

  @override
  String g_dlgSettled(String planet) {
    return '$planetに旗を立てたぞ！入植完了！';
  }

  @override
  String g_dlgStationBuilt(String station, String blurb) {
    return '$station建設完了！$blurb';
  }

  @override
  String g_dlgHabitatUp(String station, int level) {
    return '$station居住区 Lv.$level！';
  }

  @override
  String g_dlgTurretUp(String station, int level) {
    return '$station防衛砲台 Lv.$level！';
  }

  @override
  String g_dlgShipSwitched(String ship) {
    return '$shipに乗り換えた！いい感じだ！';
  }

  @override
  String g_dlgOreSold(int n, int credits) {
    return '鉱石$n個を💰$creditsで売りました。';
  }

  @override
  String g_dlgCrewJoined(String stars, String role, String name) {
    return '$stars $roleの$nameが仲間になりました！';
  }

  @override
  String g_dlgCrewLevel(String name, int level) {
    return '$name Lv.$level！腕が上がりました。';
  }

  @override
  String g_dlgCargoLoaded(String mission) {
    return '貨物を積みました！$mission';
  }

  @override
  String g_dlgBountyTaunt(String name) {
    return '$name様を捕まえるだと？やれるもんならやってみな！';
  }

  @override
  String get g_floatMissionDone => '任務完了！';

  @override
  String g_dlgMissionDone(String mission) {
    return '任務完了: $mission！';
  }

  @override
  String g_dlgRepairCost(int credits) {
    return 'ご無事でしたか、艦長！修理費に💰$credits使いました。';
  }

  @override
  String g_dlgSectorDeveloped(String sector) {
    return '$sectorの発展完了！次の星系へのワープゲートが開きました。';
  }

  @override
  String g_floatCrit(int dmg) {
    return '会心！$dmg';
  }

  @override
  String g_dlgStationDestroyed(String station) {
    return '$stationが破壊されました！防衛砲台が必要です！';
  }

  @override
  String g_dlgBossDefeated(int credits) {
    return '星系ボス撃破！報酬 💰$credits';
  }

  @override
  String g_dlgBountyCaught(String name) {
    return '指名手配犯$nameを逮捕したぞ！';
  }

  @override
  String g_dlgRaidDefended(String planet, int credits) {
    return '$planetの防衛成功！住民たちがお礼に💰$credits ⭐2を送ってくれました。';
  }

  @override
  String g_dlgRaidLooted(String planet, String level) {
    return '$planetが略奪されて$levelに下がってしまいました… 😢';
  }

  @override
  String g_dlgRaidLeft(String planet) {
    return '海賊たちが$planetを略奪して去っていきました。';
  }

  @override
  String g_dlgRaidAlert(String planet) {
    return '緊急事態！海賊が$planetを襲撃しています！生産が止まりました！';
  }

  @override
  String g_pirateBossArrive(String sector) {
    return '$sectorの支配者はこのオレ様だ！かかってこい、ちびっこ艦長！';
  }

  @override
  String g_dlgWelcomeBack(String goal) {
    return 'おかえりなさい、艦長！現在の目標: $goal';
  }

  @override
  String get g_pirateWin0 => 'ガハハ！たいしたことないな！';

  @override
  String get g_pirateWin1 => '次はもっと強くなって来な、ちびっこ！';

  @override
  String get g_pirateWin2 => 'お前の艦はもう鉄くずだ！';

  @override
  String get g_pirateRage0 => '野郎ども、出てこい！思い知らせてやれ！';

  @override
  String get g_pirateRage1 => 'ここからが本番だ！';

  @override
  String get g_pirateRage2 => 'よくも怒らせたな？！';

  @override
  String get g_captainKill0 => '1隻撃破！';

  @override
  String get g_captainKill1 => 'どこへ逃げる気だ！';

  @override
  String get g_captainKill2 => 'この宙域は渡さない！';

  @override
  String get g_captainKill3 => '次！';

  @override
  String get g_pirateAmbush0 => 'ガハハ！積み荷を置いていきな！';

  @override
  String get g_pirateAmbush1 => 'ここはオレたち海賊団のシマだ！';

  @override
  String get g_pirateAmbush2 => 'そのピカピカのクレジットをよこしな！';

  @override
  String get g_pirateAmbush3 => '今日はツイてないな、ちびっこ！';

  @override
  String get cat_sysSol => '太陽系';

  @override
  String get cat_sysAlphaCen => 'ケンタウルス座α星';

  @override
  String get cat_sysBarnard => 'バーナード星';

  @override
  String get cat_sysWolf359 => 'ウォルフ359';

  @override
  String get cat_sysLalande => 'ラランド21185';

  @override
  String get cat_sysSirius => 'シリウス';

  @override
  String get cat_sysEpsEri => 'エリダヌス座ε星';

  @override
  String get cat_sysRoss128 => 'ロス128';

  @override
  String get cat_sysTauCeti => 'くじら座τ星';

  @override
  String get cat_sysTeegarden => 'ティーガーデン星';

  @override
  String get cat_sysGliese581 => 'グリーゼ581';

  @override
  String get cat_sysGliese667C => 'グリーゼ667C';

  @override
  String get cat_sysTrappist1 => 'トラピスト1';

  @override
  String get cat_sys55Cnc => 'かに座55番星';

  @override
  String get cat_sys51Peg => 'ペガスス座51番星';

  @override
  String cat_sysKepler(int n) {
    return 'ケプラー$n';
  }

  @override
  String get cat_sysOmegaCen => 'ケンタウルス座ω星団';

  @override
  String get cat_sysSgrA => '銀河中心 (いて座A*)';

  @override
  String get cat_sysLMC => '大マゼラン雲';

  @override
  String get cat_sysSMC => '小マゼラン雲';

  @override
  String get cat_sysAndromeda => 'アンドロメダ銀河';

  @override
  String get cat_sysTriangulum => 'さんかく座銀河';

  @override
  String get cat_pfxProxima => 'プロキシマ';

  @override
  String get cat_pfxBarnard => 'バーナード';

  @override
  String get cat_pfxSirius => 'シリウスA';

  @override
  String get cat_pfxEpsEri => 'エリダヌス座ε星';

  @override
  String get cat_pfxTauCeti => 'くじら座τ星';

  @override
  String get cat_pfxTeegarden => 'ティーガーデン星';

  @override
  String get cat_mars => '火星';

  @override
  String get cat_moon => '月';

  @override
  String get cat_venus => '金星';

  @override
  String get cat_mercury => '水星';

  @override
  String get cat_ceres => 'ケレス';

  @override
  String get cat_vesta => 'ベスタ';

  @override
  String get cat_jupiter => '木星';

  @override
  String get cat_io => 'イオ';

  @override
  String get cat_europa => 'エウロパ';

  @override
  String get cat_ganymede => 'ガニメデ';

  @override
  String get cat_callisto => 'カリスト';

  @override
  String get cat_saturn => '土星';

  @override
  String get cat_enceladus => 'エンケラドゥス';

  @override
  String get cat_titan => 'タイタン';

  @override
  String get cat_uranus => '天王星';

  @override
  String get cat_miranda => 'ミランダ';

  @override
  String get cat_titania => 'チタニア';

  @override
  String get cat_neptune => '海王星';

  @override
  String get cat_triton => 'トリトン';

  @override
  String get cat_pluto => '冥王星';

  @override
  String get cat_charon => 'カロン';

  @override
  String get cat_haumea => 'ハウメア';

  @override
  String get cat_makemake => 'マケマケ';

  @override
  String get cat_eris => 'エリス';

  @override
  String get cat_sedna => 'セドナ';

  @override
  String get cat_planetNine => 'プラネット・ナイン';

  @override
  String get u_topUpTitle => '資源が足りません';

  @override
  String u_topUpBody(String short, int gems) {
    return '$short足りません。⭐$gemsで補って続けますか？';
  }

  @override
  String u_topUpNoGems(String short, int gems, int have) {
    return '$short足りません。ジェムで補うには⭐$gems必要ですが、今は⭐$haveです。もう少し集めましょう！';
  }

  @override
  String get u_topUpOk => '補って続ける';

  @override
  String get u_goShop => 'ショップへ';

  @override
  String get u_exchangeTitle => '💰 クレジット交換';

  @override
  String u_exchangeBody(int gems, int credits) {
    return '⭐$gemsを💰$creditsに交換しますか？';
  }

  @override
  String get m_purchaseFailed => 'ストアに接続できませんでした。しばらくしてからもう一度お試しください。';

  @override
  String get m_adWatchToEnd => '広告を最後まで見ると報酬がもらえます。';

  @override
  String get u_cruise => '巡航';

  @override
  String get u_autoFireOn => 'ON';

  @override
  String get u_autoFireOff => 'OFF';

  @override
  String u_recruitRoleOdds(int count, String pct) {
    return '職種（全スカウト共通）: $count種からランダム、各$pct';
  }

  @override
  String m_feedbackSubject(String app) {
    return '$app フィードバック';
  }

  @override
  String get lb_menu => '🏅 週間ランキング';

  @override
  String get lb_menuShort => 'ランキング';

  @override
  String get lb_title => '🏅 週間ランキング';

  @override
  String get lb_join => 'ランキングに参加する';

  @override
  String get lb_joinDesc =>
      '送るのは匿名ID、ゲームが作ったニックネーム、今週のスコアだけです。名前・チャット・入力した文字は送りません。いつでもオフにできます。';

  @override
  String get lb_yourNick => 'あなたのニックネーム';

  @override
  String lb_reroll(int count) {
    return '新しい名前（$count）';
  }

  @override
  String lb_weekPoints(String points) {
    return '今週の開拓スコア $points点';
  }

  @override
  String lb_rank(int rank, int total) {
    return '$rank位 / $total人';
  }

  @override
  String lb_rankOnly(int rank) {
    return '$rank位';
  }

  @override
  String get lb_top50 => '今週のトップ50';

  @override
  String get lb_empty => '今週の記録はまだありません。一番乗りしよう！';

  @override
  String get lb_retry => 'もう一度';

  @override
  String get lb_refresh => '更新';

  @override
  String get lb_offline => '接続がありません。ゲームはそのまま遊べます。あとでもう一度試してください。';

  @override
  String get lb_rateLimited => '送信が多すぎます。1分待ってからもう一度試してください。';

  @override
  String get lb_rejected => 'このスコアは送信できません。';

  @override
  String get lb_serverError => 'ランキングが混み合っています。あとでもう一度試してください。';

  @override
  String get lb_unavailable => 'ランキングは利用できません。';

  @override
  String get lb_optedOut => '「ランキングに参加する」をオンにするとスコアが載ります。';

  @override
  String get lb_howTo => '植民地レベル +100 · 新しい星系 +500 · 海賊撃墜 +5 · ボス +200';

  @override
  String get lb_resets => '毎週月曜 0:00（UTC）に新しい週が始まります。';

  @override
  String nickFormat(String adj, String animal, String number) {
    return '$adj$animal $number';
  }

  @override
  String get nickGenders => '';

  @override
  String nickAdj0(String g) {
    return 'ゆうかんな';
  }

  @override
  String get nickAnimal0 => 'ラッコ';

  @override
  String nickAdj1(String g) {
    return 'あかるい';
  }

  @override
  String get nickAnimal1 => 'パンダ';

  @override
  String nickAdj2(String g) {
    return 'おだやかな';
  }

  @override
  String get nickAnimal2 => 'キツネ';

  @override
  String nickAdj3(String g) {
    return 'りこうな';
  }

  @override
  String get nickAnimal3 => 'ウサギ';

  @override
  String nickAdj4(String g) {
    return 'うちゅうの';
  }

  @override
  String get nickAnimal4 => 'フクロウ';

  @override
  String nickAdj5(String g) {
    return 'ふしぎずきな';
  }

  @override
  String get nickAnimal5 => 'ペンギン';

  @override
  String nickAdj6(String g) {
    return 'はずむ';
  }

  @override
  String get nickAnimal6 => 'コアラ';

  @override
  String nickAdj7(String g) {
    return 'ゆめみる';
  }

  @override
  String get nickAnimal7 => 'イルカ';

  @override
  String nickAdj8(String g) {
    return 'ぽかぽか';
  }

  @override
  String get nickAnimal8 => 'カメ';

  @override
  String nickAdj9(String g) {
    return 'はやい';
  }

  @override
  String get nickAnimal9 => 'ハリネズミ';

  @override
  String nickAdj10(String g) {
    return 'もふもふ';
  }

  @override
  String get nickAnimal10 => 'リス';

  @override
  String nickAdj11(String g) {
    return 'なかよしの';
  }

  @override
  String get nickAnimal11 => 'こねこ';

  @override
  String nickAdj12(String g) {
    return 'やさしい';
  }

  @override
  String get nickAnimal12 => 'こいぬ';

  @override
  String nickAdj13(String g) {
    return 'ひかる';
  }

  @override
  String get nickAnimal13 => 'こがも';

  @override
  String nickAdj14(String g) {
    return 'きんいろの';
  }

  @override
  String get nickAnimal14 => 'こひつじ';

  @override
  String nickAdj15(String g) {
    return 'しあわせな';
  }

  @override
  String get nickAnimal15 => 'アザラシ';

  @override
  String nickAdj16(String g) {
    return 'おもしろい';
  }

  @override
  String get nickAnimal16 => 'クジラ';

  @override
  String nickAdj17(String g) {
    return 'しんせつな';
  }

  @override
  String get nickAnimal17 => 'ハムスター';

  @override
  String nickAdj18(String g) {
    return 'ラッキーな';
  }

  @override
  String get nickAnimal18 => 'ビーバー';

  @override
  String nickAdj19(String g) {
    return 'うたう';
  }

  @override
  String get nickAnimal19 => 'アライグマ';

  @override
  String nickAdj20(String g) {
    return 'ちからもちの';
  }

  @override
  String get nickAnimal20 => 'オウム';

  @override
  String nickAdj21(String g) {
    return 'カラフルな';
  }

  @override
  String get nickAnimal21 => 'テントウムシ';

  @override
  String nickAdj22(String g) {
    return 'あまい';
  }

  @override
  String get nickAnimal22 => 'スズメ';

  @override
  String nickAdj23(String g) {
    return 'れいぎただしい';
  }

  @override
  String get nickAnimal23 => 'こじか';

  @override
  String nickAdj24(String g) {
    return 'あそびずきな';
  }

  @override
  String get nickAnimal24 => 'ポニー';

  @override
  String nickAdj25(String g) {
    return 'しずかな';
  }

  @override
  String get nickAnimal25 => 'こぐま';

  @override
  String nickAdj26(String g) {
    return 'キラキラ';
  }

  @override
  String get nickAnimal26 => 'こじし';

  @override
  String nickAdj27(String g) {
    return 'ぎんいろの';
  }

  @override
  String get nickAnimal27 => 'ことら';

  @override
  String nickAdj28(String g) {
    return 'ねむたい';
  }

  @override
  String get nickAnimal28 => 'キリン';

  @override
  String nickAdj29(String g) {
    return 'つきの';
  }

  @override
  String get nickAnimal29 => 'シマウマ';

  @override
  String nickAdj30(String g) {
    return 'たいようの';
  }

  @override
  String get nickAnimal30 => 'ゾウ';

  @override
  String nickAdj31(String g) {
    return 'まほうの';
  }

  @override
  String get nickAnimal31 => 'カバ';

  @override
  String nickAdj32(String g) {
    return 'スーパー';
  }

  @override
  String get nickAnimal32 => 'ラマ';

  @override
  String nickAdj33(String g) {
    return 'ほしぞらの';
  }

  @override
  String get nickAnimal33 => 'アルパカ';

  @override
  String nickAdj34(String g) {
    return 'にこにこ';
  }

  @override
  String get nickAnimal34 => 'ミーアキャット';

  @override
  String nickAdj35(String g) {
    return 'けだかい';
  }

  @override
  String get nickAnimal35 => 'ヒトデ';

  @override
  String nickAdj36(String g) {
    return 'ちいさな';
  }

  @override
  String get nickAnimal36 => 'タツノオトシゴ';

  @override
  String nickAdj37(String g) {
    return 'ものしりの';
  }

  @override
  String get nickAnimal37 => 'シマリス';

  @override
  String nickAdj38(String g) {
    return 'ゆきいろの';
  }

  @override
  String get nickAnimal38 => 'キンギョ';

  @override
  String nickAdj39(String g) {
    return 'たのもしい';
  }

  @override
  String get nickAnimal39 => 'ホタル';

  @override
  String get m_adPrivacy => '広告のプライバシー設定';
}
