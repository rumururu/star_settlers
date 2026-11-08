// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Star Settlers';

  @override
  String get languageName => 'English';

  @override
  String get u_tabShip => 'Ship';

  @override
  String get u_tabStation => 'Station';

  @override
  String get u_tabCrew => 'Crew';

  @override
  String get u_tabMission => 'Missions';

  @override
  String get u_tabMarket => 'Market';

  @override
  String u_upWeapon(int dmg) {
    return 'Damage $dmg · Lv.3 double · Lv.6 triple';
  }

  @override
  String u_upHull(int hp) {
    return 'Max HP $hp';
  }

  @override
  String u_upEngine(int speed) {
    return 'Top speed $speed';
  }

  @override
  String get u_upMissileIntro => 'Homing missiles (Q key / 🚀 button)';

  @override
  String u_upMissile(int count, String cooldown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count missiles',
      one: '1 missile',
    );
    return '$_temp0 · cooldown ${cooldown}s';
  }

  @override
  String get u_upShieldIntro =>
      'Shield that blocks all damage (F key / 🛡 button)';

  @override
  String u_upShield(String duration, String cooldown) {
    return '${duration}s · cooldown ${cooldown}s';
  }

  @override
  String get u_upDroneIntro => 'Orbits you, auto-fires and pulls in items';

  @override
  String u_upDrone(int dmg, String interval) {
    return 'Damage $dmg · fires every ${interval}s';
  }

  @override
  String u_upMagnet(int range, String power) {
    return 'Pulls credits & ore · range $range · power x$power';
  }

  @override
  String get u_equip => 'Equip';

  @override
  String get u_hangarSection => '🛸 Hangar';

  @override
  String get u_viewLarge => 'View';

  @override
  String get u_hp => 'HP';

  @override
  String get u_speed => 'Speed';

  @override
  String get u_attack => 'Attack';

  @override
  String get u_fireRate => 'Fire rate';

  @override
  String get u_ore => 'Ore';

  @override
  String get u_crit => 'Crit';

  @override
  String get u_boarded => 'Aboard';

  @override
  String get u_board => 'Board';

  @override
  String get u_boardNow => 'Board';

  @override
  String get u_gemsOnly => 'Gems only';

  @override
  String u_unlockOrGems(String condition) {
    return 'Unlock: $condition or gems';
  }

  @override
  String u_unlock(String condition) {
    return 'Unlock: $condition';
  }

  @override
  String u_durability(int hp, int max) {
    return 'Hull $hp / $max';
  }

  @override
  String get u_habitat => 'Habitat';

  @override
  String u_habitatDesc(String rate, int hp) {
    return 'Income 💰$rate/s · Hull $hp';
  }

  @override
  String get u_turret => 'Defense Turret';

  @override
  String get u_turretIntro => 'Automatically shoots pirates';

  @override
  String u_turretDesc(int dmg, int range) {
    return 'Damage $dmg · Range $range';
  }

  @override
  String get u_baseUpgrade => 'Base Upgrade';

  @override
  String u_baseDesc(int dmg, int range, int hp) {
    return 'Laser $dmg · Range $range · Hull $hp';
  }

  @override
  String u_disabledSec(int sec) {
    return 'Disabled ${sec}s';
  }

  @override
  String u_sectorStatus(String sector) {
    return '$sector Status';
  }

  @override
  String u_sectorStats(
    int colonies,
    int planets,
    int stations,
    String mul,
    String other,
  ) {
    return 'Settled planets $colonies / $planets\nStations: $stations\nSystem bonus: output x$mul\nOther systems: 💰$other/s';
  }

  @override
  String get u_legendaryGet => '🌟 Legendary! 🌟';

  @override
  String get u_rareGet => '✨ Rare crew! ✨';

  @override
  String get u_newCrew => 'New crew joined!';

  @override
  String get u_great => 'Great!';

  @override
  String u_crewHeader(int count, int cap, int assigned, int slots) {
    return 'Crew $count/$cap · Assigned $assigned/$slots';
  }

  @override
  String u_recruit(int cost) {
    return 'Recruit 💰$cost';
  }

  @override
  String u_recruitPremium(int cost) {
    return 'Premium Recruit ⭐$cost';
  }

  @override
  String u_recruitLegendary(int cost) {
    return '🌟 Guaranteed Legendary ⭐$cost';
  }

  @override
  String u_recruitOdds(String normal, String premium) {
    return 'Odds · Recruit: $normal\nPremium Recruit: $premium\nGuaranteed Legendary: ★4 100%';
  }

  @override
  String u_slotMax(int n) {
    return 'Crew slots MAX ($n)';
  }

  @override
  String u_slotBuy(int price) {
    return 'Crew slot +1 ⭐$price';
  }

  @override
  String u_rosterMax(int n) {
    return 'Roster MAX ($n)';
  }

  @override
  String u_rosterBuy(int size, int price) {
    return 'Roster +$size ⭐$price';
  }

  @override
  String get u_noCrew =>
      'No crew yet. Recruit some and assign them to your ship!';

  @override
  String get u_unassign => 'Unassign';

  @override
  String get u_assign => 'Assign';

  @override
  String get u_dismiss => 'Dismiss';

  @override
  String get u_dismissCrewTitle => 'Dismiss Crew';

  @override
  String u_dismissCrewBody(String name) {
    return 'Let $name go? This can\'t be undone.';
  }

  @override
  String get u_missionDeliverHint => 'Head to the destination (yellow arrow)';

  @override
  String get u_missionBountyHint => 'Find and defeat the target (yellow arrow)';

  @override
  String u_reward(String rewards) {
    return 'Reward $rewards';
  }

  @override
  String u_activeMissions(int n) {
    return 'Active ($n/3)';
  }

  @override
  String get u_noActiveMissions => 'No active missions.';

  @override
  String get u_abandon => 'Abandon';

  @override
  String u_missionBoard(int sec) {
    return 'Mission Board · new in ${sec}s';
  }

  @override
  String get u_accept => 'Accept';

  @override
  String get u_priceHigh => '📈 High! Time to sell';

  @override
  String get u_priceLow => '📉 Low… better wait';

  @override
  String get u_priceNormal => '➡ Normal';

  @override
  String get u_orePrice => 'Ore Price';

  @override
  String get u_sell100 => 'Sell 100';

  @override
  String get u_sellHalf => 'Sell Half';

  @override
  String get u_sellAll => 'Sell All';

  @override
  String get u_marketTip => 'Prices rise and fall over time. Sell high!';

  @override
  String get u_gemExchange => '⭐ Star Gem Exchange';

  @override
  String get u_creditPack => 'Credit Pack';

  @override
  String get u_exchange => 'Exchange';

  @override
  String get u_openShop => '⭐ Open Shop';

  @override
  String u_achievementDone(String title, int gems) {
    return '🏆 Achievement: $title! Claim ⭐$gems in Menu > Achievements.';
  }

  @override
  String get u_cannotDo => 'Not enough resources, or you can\'t do that now.';

  @override
  String get u_welcomeBack => 'Welcome back, Captain!';

  @override
  String u_offlineHm(int h, int m) {
    return 'While you were away for ${h}h ${m}m,\nyour colonies worked hard!';
  }

  @override
  String u_offlineM(int m) {
    return 'While you were away for ${m}m,\nyour colonies worked hard!';
  }

  @override
  String get u_passOfflineHint => 'Commander Pass: up to 8h + auto 2x';

  @override
  String get u_collect => 'Collect';

  @override
  String get u_adLoading => 'Loading ad. Please try again in a moment.';

  @override
  String get u_adLoadingRetry => 'Loading ad. Please tap again in a moment.';

  @override
  String get u_collectDouble => 'Collect 2x 👑';

  @override
  String get u_adDouble => '📺 Watch ad for 2x';

  @override
  String get u_galaxyHonor => '🌌 Galactic Honor';

  @override
  String u_honorStatus(int honor, int ascensions) {
    return 'Honor $honor (ascended ${ascensions}x)';
  }

  @override
  String u_honorBonus(int income, int attack) {
    return 'Income +$income% · Damage +$attack%';
  }

  @override
  String get u_ascendExplain =>
      'Ascending resets this universe (star systems, colonies, stations, ship upgrades, crew, credits)\nand grants honor, a permanent bonus.\nGems, cosmetics, ships and achievements are kept.';

  @override
  String u_ascendGain(int gain) {
    return 'Ascend now for +$gain honor!\n(The bigger your empire, the more you get)';
  }

  @override
  String get u_ascendLocked => 'Reach star system 4 to ascend.';

  @override
  String get u_close => 'Close';

  @override
  String u_ascendBtn(int gain) {
    return 'Ascend (+$gain)';
  }

  @override
  String get u_ascendConfirmTitle => 'Really ascend?';

  @override
  String get u_ascendConfirmBody =>
      'Your current universe will be reset. This can\'t be undone.';

  @override
  String get u_ascend => 'Ascend';

  @override
  String u_shieldBroken(String name) {
    return '$name broken';
  }

  @override
  String u_hudSector(String sector, int dev, String threat, String value) {
    return '$sector · Stab. $dev%\n⚠ Threat $threat  🏛 $value';
  }

  @override
  String u_baseDisabled(int sec) {
    return 'Base down ${sec}s';
  }

  @override
  String u_baseHp(int pct) {
    return 'Base $pct%';
  }

  @override
  String u_invasionCountdown(int sec) {
    return 'Invasion in ${sec}s';
  }

  @override
  String u_invasionWave(int wave, int total, int left) {
    return 'Invasion $wave/$total · $left left';
  }

  @override
  String u_invasionWon(int credits) {
    return 'Repelled! 💰$credits ⭐5';
  }

  @override
  String u_invasionRetreat(int pct, int credits) {
    return 'Withdrew · $pct% · 💰$credits';
  }

  @override
  String get u_merchantE => 'Merchant (E)';

  @override
  String get u_nextSectorE => 'Next System (E)';

  @override
  String get u_prevSectorE => 'Prev System (E)';

  @override
  String u_gateLocked(int pct) {
    return '🔒 Opens at 100% Stabilization ($pct%)';
  }

  @override
  String u_settle(String name) {
    return 'Settle $name';
  }

  @override
  String u_manageE(String name) {
    return 'Manage $name (E)';
  }

  @override
  String get u_buildStation => 'Build Station';

  @override
  String get u_fire => 'FIRE';

  @override
  String get u_equipAtStation => 'You can equip it in the station\'s Ship tab!';

  @override
  String get u_shotDown => '💥 You were shot down!';

  @override
  String u_autoRespawn(int sec) {
    return 'Auto-respawn at base in ${sec}s';
  }

  @override
  String get u_reviveFree => '👑 Revive here (free)';

  @override
  String get u_reviveAd => '📺 Watch ad to revive here';

  @override
  String get u_reviveGems => 'Revive here for ⭐10';

  @override
  String u_respawnBase(int pct) {
    return '🏠 Respawn at base (lose $pct% credits)';
  }

  @override
  String get u_spkCaptain => 'Captain';

  @override
  String get u_spkPirate => 'Pirate';

  @override
  String get u_spkAdvisor => 'Scientist Mina';

  @override
  String get u_spkMerchant => 'Nyang the Merchant';

  @override
  String get u_paused => 'Paused';

  @override
  String u_pauseStats(
    String sector,
    int kills,
    int crew,
    int colonies,
    int stations,
    int missions,
  ) {
    return '$sector · Kills $kills · Crew $crew\nColonies $colonies · Stations $stations · Missions $missions';
  }

  @override
  String get u_resume => '▶︎ Resume';

  @override
  String get u_shop => '⭐ Shop';

  @override
  String get u_achievements => '🏆 Achievements';

  @override
  String get u_dailyQuests => '📅 Daily Quests';

  @override
  String get u_myPlanet => '🌍 My Planet';

  @override
  String get u_ascendMenu => '🌌 Galactic Honor (Ascend)';

  @override
  String get u_settings => '⚙ Settings';

  @override
  String get u_saveAndQuit => '💾 Save & Quit to Title';

  @override
  String get u_keyboardHelp =>
      'Keys: WASD move · Space fire · Q missile · F shield · Shift boost\nE interact · B build station · Esc menu';

  @override
  String get u_recharging => 'Recharging';

  @override
  String get u_tutDome => 'Shield\nsafe inside';

  @override
  String get u_tutLevelUp => 'Level up\nincome·buildings↑';

  @override
  String get u_tutTurret => 'Turret';

  @override
  String get u_tutRepair => 'Repair';

  @override
  String get u_tutRaid => 'Stop raids';

  @override
  String get u_gotIt => 'Got it';

  @override
  String u_damage(int dmg) {
    return 'Damage $dmg';
  }

  @override
  String u_oreRate(String rate) {
    return 'Ore +$rate/s';
  }

  @override
  String u_incomePct(int pct) {
    return 'Income +$pct%';
  }

  @override
  String u_repairRate(int hp) {
    return 'HP +$hp/s';
  }

  @override
  String u_shieldPlus(int amount) {
    return 'Shield +$amount';
  }

  @override
  String u_systemTitle(String sector, int n) {
    return '$sector · System $n';
  }

  @override
  String u_systemInfo(String threat, String mul) {
    return 'Threat $threat · Resources x$mul';
  }

  @override
  String u_development(int pct) {
    return 'Stabilization $pct%';
  }

  @override
  String get u_nextSystemOpen => 'Next system open';

  @override
  String get u_opensAt100 => 'Opens at 100%';

  @override
  String get u_devHint =>
      'Phase Anchor levels totaling the number of planets × 3 reach 100%.';

  @override
  String u_stabilizerHealth(int hp, int max) {
    return 'Durability $hp/$max';
  }

  @override
  String g_foeIntro(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missile':
          'A missile carrier! Its missiles home in, but you can shoot them down.',
      'laser':
          'A laser lancer is aiming! When you see the red line, dodge sideways.',
      'warden':
          'A shield warden protects nearby pirates. Enemies inside the blue ring take half damage, so take it out first!',
      'carrier':
          'A drone carrier! It keeps launching drones, so hit the carrier first.',
      'phantom':
          'A phantom cloaks and reappears. Focus fire while it is visible!',
      'mine':
          'A mine layer! Yellow mines blow up when you get close, but you can shoot them.',
      'medic':
          'A repair tender is fixing the pirates. Take out the tender hiding in the back!',
      'juggernaut':
          'A juggernaut! Its front armor is tough, so hit its sides or rear, and dodge its charge.',
      'other': 'A new enemy!',
    });
    return '$_temp0';
  }

  @override
  String u_levelUnlockAtSystem(int level, int system) {
    return 'Lv.$level unlocks in star system $system';
  }

  @override
  String get u_myColonies => 'My Colonies';

  @override
  String get u_myColoniesHint =>
      'Level up any colony from here, wherever you are.';

  @override
  String get u_noColonies => 'No colonies yet. Fly to a planet and settle it.';

  @override
  String get u_currentHere => 'You are here';

  @override
  String u_anchorEffect(int income, int shield, int regen) {
    return 'Income +$income% · Shared shield $shield · Regen +$regen%';
  }

  @override
  String get u_conqueredSystems => 'Conquered Systems (still producing)';

  @override
  String get u_unsettled => 'Unsettled';

  @override
  String get u_underRaid => 'Under raid';

  @override
  String u_unknownSector(int n) {
    return 'Unknown System $n';
  }

  @override
  String u_sectorDev(String name, int pct) {
    return '$name · Stab. $pct%';
  }

  @override
  String get u_buildStationTitle => 'Build Station · Choose a Role';

  @override
  String get u_cost => 'Cost';

  @override
  String get u_build => 'Build';

  @override
  String get u_toNextSector => '🌀 To next star system';

  @override
  String get u_bossLocked => '🔒 Defeat the boss to open';

  @override
  String get u_toPrevSector => '🌀 To previous star system';

  @override
  String get u_raidAlert => '⚠ Under raid!';

  @override
  String u_rechargePct(int pct) {
    return 'Recharge $pct%';
  }

  @override
  String u_merchantLabel(int sec) {
    return '🛒 Wandering Merchant (${sec}s)';
  }

  @override
  String get u_supplyPod => '📦 Supply Pod';

  @override
  String u_sectorBoss(String sector) {
    return '☠ $sector Boss';
  }

  @override
  String get u_pirateBoss => '☠ Pirate Boss';

  @override
  String get u_merchantName => 'Nyang, Wandering Merchant';

  @override
  String u_merchantLeaves(int sec, String credits) {
    return 'Leaves in ${sec}s · 💰$credits';
  }

  @override
  String get u_rareCrewOffer => 'Rare Crew for Hire';

  @override
  String get u_crewSoldOut => 'Today\'s crew is sold out, meow!';

  @override
  String get u_gemTrade => 'Gem Exchange (max 3)';

  @override
  String u_gemTradeRow(int price, int left) {
    return '💰$price → ⭐5  ($left left)';
  }

  @override
  String get u_convert => 'Trade';

  @override
  String get u_potions => 'Boost Potions (2x duration)';

  @override
  String get u_notEnoughGems => 'Not enough gems';

  @override
  String get u_buyConfirmTitle => 'Confirm Purchase';

  @override
  String u_buyShipConfirm(String ship, String price) {
    return 'Spend $price on the $ship?';
  }

  @override
  String u_shipBought(String ship) {
    return 'Got the $ship! You\'re now aboard.';
  }

  @override
  String get u_premiumShips => 'Premium Ships';

  @override
  String get u_hangarTitle => 'Hangar';

  @override
  String u_buyGems(int price) {
    return 'Buy ⭐$price';
  }

  @override
  String get u_premium => 'Premium';

  @override
  String get u_ok => 'OK';

  @override
  String get u_cancel => 'Cancel';

  @override
  String get m_ok => 'OK';

  @override
  String get m_cancel => 'Cancel';

  @override
  String get m_close => 'Close';

  @override
  String get m_claim => 'Claim';

  @override
  String m_claimGems(int gems) {
    return 'Claim ⭐$gems';
  }

  @override
  String get m_done => '✅ Done';

  @override
  String get m_notEnoughGems => 'Not enough gems';

  @override
  String get m_restorePurchases => 'Restore Purchases';

  @override
  String get m_restoreDone => 'Purchases checked';

  @override
  String get m_buyConfirmTitle => 'Confirm Purchase';

  @override
  String m_spendGemsConfirm(String price) {
    return 'Spend $price?';
  }

  @override
  String get m_loginTitle => '📅 Daily Login';

  @override
  String get m_loginWelcome => 'Welcome back, Captain!';

  @override
  String get m_loginFirst =>
      'Welcome aboard, Captain! Here\'s your first login reward.';

  @override
  String get m_loginStreakHint => 'Log in 7 days in a row for ⭐50!';

  @override
  String get m_newGameTitle => 'New Game';

  @override
  String get m_newGameBody =>
      'Your current progress will be erased.\n(Gems, cosmetics, achievements and purchases are kept.) Continue?';

  @override
  String get m_start => 'Start';

  @override
  String get m_loadFailed => 'Couldn\'t load your save data.';

  @override
  String m_honorLine(int honor, int income, int attack) {
    return '🌌 Galactic Honor $honor · Income +$income% · Attack +$attack%';
  }

  @override
  String get m_continue => 'Continue';

  @override
  String get m_newGame => '✨ New Game';

  @override
  String get m_menuHome => 'My Planet';

  @override
  String get m_menuShop => 'Shop';

  @override
  String get m_menuQuest => 'Quests';

  @override
  String get m_menuAchievements => 'Trophies';

  @override
  String get m_menuSettings => 'Settings';

  @override
  String m_achievementsTitle(int done, int total) {
    return '🏆 Achievements ($done/$total)';
  }

  @override
  String get m_dailyTitle => '📅 Daily Quests';

  @override
  String m_dailyReset(int hours, int minutes) {
    return 'Resets in ${hours}h ${minutes}m';
  }

  @override
  String get m_dailyBonusTitle => '🎁 All-Clear Bonus';

  @override
  String get m_dailyBonusDesc => 'Claim all 3 of today\'s quests';

  @override
  String get m_settingsTitle => '⚙ Settings';

  @override
  String get m_settingsSound => 'Sound Effects';

  @override
  String get m_settingsMusic => 'Music';

  @override
  String get m_settingsNotify => 'Return Reminders';

  @override
  String get m_settingsNotifyDesc =>
      'We\'ll tell you when colony storage is full';

  @override
  String get m_settingsHaptics => 'Vibration';

  @override
  String get m_settingsLanguage => 'Language';

  @override
  String get m_languageSystem => 'Use device language';

  @override
  String get m_settingsOrientation => 'Screen orientation';

  @override
  String get m_orientAuto => 'Auto';

  @override
  String get m_orientPortrait => 'Portrait';

  @override
  String get m_orientLandscape => 'Landscape';

  @override
  String get m_privacyTitle => 'Privacy Policy';

  @override
  String m_privacyBody(String email) {
    return 'Star Settlers has no sign-up and does not collect personally identifiable information. Game data (progress, credits and ore, cosmetics, settings) is stored on your device. Gems and purchase records are kept in a gem wallet on our server so they cannot be forged or lost, and the optional weekly leaderboard below sends its data only if you turn it on.\n\nPurchases: processed by Google Play / App Store; payment details are never shared with the developer. RevenueCat verifies and restores purchases, processing a random install ID and purchase history. Once a purchase is confirmed, the server credits your gem wallet.\n\nGem wallet: gems are kept on our server, not on your device, so they cannot be increased by tampering. The server stores a random install ID (not an advertising or device ID), your gem balance, records of gems earned and spent, and purchase records; no names and nothing you type. Spending gems needs an internet connection. The server is Supabase (Seoul region).\n\nCloud backup (optional): works only when you connect your Google Play Games or Game Center account in Settings and back up. Your progress, settings and random install ID are stored in your own Google Play Games saved games or iCloud, not on the developer\'s server.\n\nAds: Google AdMob rewarded ads play only when you choose to watch one. AdMob may use your advertising ID, IP address and device info to serve ads, personalise them where permitted, and measure them. In the EEA, the UK and Switzerland, consent is asked on first launch and can be changed in Settings → Ad privacy settings.\n\nNotifications: local notifications scheduled on your device; nothing is sent out.\n\nFeedback: your message, app version and device info reach the developer only if you send the email yourself.\n\nWeekly leaderboard (optional): off by default; you join only by turning it on in Settings or on the ranking screen. Only a random install ID, a nickname the game builds from fixed word lists, and your weekly score are sent. No names, nothing you type, and no chat. Other players see only the nickname and score. The server is Supabase (Seoul region).\n\nDeletion: Settings → Reset All Data erases the data on your device. Resetting also sets your gem balance on the server to 0; the Starter Pack and Fleet Commander Pass come back from your purchase records. If you joined the leaderboard, resetting also deletes your leaderboard record (install ID, nickname, score) on the server; you can also ask for deletion by email.\n\nFull policy: https://rumururu.github.io/mkideabox/star_settlers/privacy.html\nContact: $email';
  }

  @override
  String get m_wipeTitle => 'Reset All Data';

  @override
  String get m_wipeDesc =>
      'Deletes all progress, gems, cosmetics and your leaderboard record';

  @override
  String get m_wipeConfirmTitle => 'Really reset everything?';

  @override
  String get m_wipeConfirmBody =>
      'This can\'t be undone. Gems and progress are deleted permanently. The Starter Pack and Fleet Commander Pass can be recovered with \"Restore Purchases\".';

  @override
  String get m_wipeOk => 'Reset';

  @override
  String get m_feedbackTitle => 'Send Feedback to Developer';

  @override
  String get m_feedbackDesc =>
      'Bugs, ideas, anything! Device and app version are filled in automatically.';

  @override
  String m_noMailApp(String email) {
    return 'No mail app found. Please write to $email.';
  }

  @override
  String get m_aboutTitle => 'STAR SETTLERS';

  @override
  String m_version(String version) {
    return 'Version $version';
  }

  @override
  String get m_shopTitle => '⭐ Shop';

  @override
  String get m_buyThanks => 'Purchase complete! Thank you 💜';

  @override
  String get m_walletOffline =>
      'Gems are kept on our server. Connect to the internet and try again.';

  @override
  String get m_purchasePending =>
      'Payment done. Your gems will arrive as soon as it\'s confirmed.';

  @override
  String get m_adLoading => 'Loading ad. Please try again in a moment.';

  @override
  String m_buyShipConfirm(String ship, String price) {
    return 'Spend $price on $ship?';
  }

  @override
  String m_shipAcquired(String ship) {
    return 'Got the $ship! You\'re now aboard';
  }

  @override
  String get m_tabGems => 'Gems';

  @override
  String get m_tabPacks => 'Packs';

  @override
  String get m_tabPremiumShips => 'Premium Ships';

  @override
  String get m_tabSkins => 'Ship Skins';

  @override
  String get m_tabOutfits => 'Captain Outfits';

  @override
  String get m_tabFree => 'Free Gems';

  @override
  String get m_testMode =>
      '🧪 Test mode: no real payments; ads are Google test ads';

  @override
  String get m_owned => 'Owned';

  @override
  String get m_boarded => 'Flying';

  @override
  String get m_gemsInfo =>
      'Use gems for cosmetics, premium recruiting, instant revives and credit exchange.\nYou can also earn them by playing (achievements, logins, bosses, supply pods).';

  @override
  String get m_crewSection => '👩‍🚀 Crew (Gems)';

  @override
  String get m_premiumSection => '🛸 Premium Ships';

  @override
  String get m_premiumDesc =>
      'Special fighters available only for gems, each with a unique ability.';

  @override
  String get m_viewLarge => 'View Full Size';

  @override
  String get m_premiumHangarHint =>
      'You can also buy and switch ships in the Hangar (Station → Ships tab).';

  @override
  String get m_legendTitle => 'Guaranteed Legendary Recruit';

  @override
  String get m_legendDescNoGame =>
      '1 ★4 legendary crew member (20%+ bonus + all production +40%, title, golden aura)\nAvailable after you start a game';

  @override
  String m_legendDesc(int count, int cap) {
    return '1 ★4 legendary crew member (20%+ bonus + all production +40%, title, golden aura)\nCrew $count/$cap';
  }

  @override
  String m_crewJoined(String stars, String name) {
    return '$stars $name joined!';
  }

  @override
  String get m_slotTitle => 'Crew Slot +1';

  @override
  String m_slotDesc(int slots) {
    return 'Crew members you can assign at once · Now $slots';
  }

  @override
  String m_rosterTitle(int n) {
    return 'Crew Capacity +$n';
  }

  @override
  String m_rosterDesc(int cap, int max) {
    return 'Crew members you can keep · Now $cap (max $max)';
  }

  @override
  String m_crewOdds(String odds) {
    return 'Premium recruit odds: $odds · Guaranteed Legendary: ★4 100%';
  }

  @override
  String get m_equipped => 'Equipped';

  @override
  String get m_equip => 'Equip';

  @override
  String get m_passOnly => 'Commander Pass only';

  @override
  String get m_starterOnly => 'Starter Pack only';

  @override
  String get m_adSection => '📺 Free Gems from Ads';

  @override
  String m_adInfo(int perDay, int left) {
    return '$perDay times a day, ⭐5 each · $left left today';
  }

  @override
  String get m_adClaimPremium => 'Claim ⭐5 (Commander Pass: no ads)';

  @override
  String get m_adWatch => 'Watch Ad for ⭐5';

  @override
  String m_loginStreak(int days) {
    return 'Login streak: day $days';
  }

  @override
  String m_dayN(int day) {
    return 'Day $day';
  }

  @override
  String get m_notEnoughResources => 'Not enough resources';

  @override
  String m_emptyLot(int n) {
    return 'Empty Lot #$n · Build';
  }

  @override
  String get m_buildInGameOnly =>
      'You can build during a game (Menu → My Planet). Credits and ore come from your current universe.';

  @override
  String m_heldAll(String credits, String ore, int gems) {
    return 'Have 💰$credits  💎$ore  ⭐$gems';
  }

  @override
  String m_held(String credits, String ore) {
    return 'Have 💰$credits  💎$ore';
  }

  @override
  String m_currentEffect(String effect) {
    return 'Current: $effect';
  }

  @override
  String m_nextLevel(String effect) {
    return 'Next level: $effect';
  }

  @override
  String m_upgrade(String cost) {
    return 'Upgrade $cost';
  }

  @override
  String get m_maxLevel => '🌟 Max Level';

  @override
  String get m_planetName => 'Planet Name';

  @override
  String get m_decorateTitle => '🎨 Decorate Planet';

  @override
  String get m_planetRing => 'Planet Ring';

  @override
  String get m_giftInGameOnly => 'Gifts can be collected during a game';

  @override
  String get m_giftTitle => '🎁 Planet Gift';

  @override
  String m_giftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A gift from your $count residents!',
      one: 'A gift from your 1 resident!',
    );
    return '$_temp0';
  }

  @override
  String get m_giftThanks => 'Thanks!';

  @override
  String m_planetStatus(int level, int residents, int built, int slots) {
    return 'Planet Lv.$level · $residents residents · Buildings $built/$slots';
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
    return 'Permanent bonus · Income +$income%  Ore +$ore%  Attack +$attack%  HP +$hp%  Cooldown -$cooldown%  Offline $offline%';
  }

  @override
  String get m_planetHint => 'Swipe to spin the planet, tap a lot to build';

  @override
  String get m_giftClaim => '🎁 Collect Gift';

  @override
  String m_giftWait(int hours, int minutes) {
    return '🎁 Gift in ${hours}h ${minutes}m';
  }

  @override
  String m_planetLevelUp(int level, String cost) {
    return '🌍 Planet Lv.$level (+2 lots) $cost';
  }

  @override
  String get g_shipScoutName => 'Scout';

  @override
  String get g_shipInterceptorName => 'Interceptor';

  @override
  String get g_shipFortressName => 'Fortress';

  @override
  String get g_shipProspectorName => 'Prospector';

  @override
  String get g_shipPhantomName => 'Phantom';

  @override
  String get g_shipNovaName => 'Nova Dragon';

  @override
  String get g_shipAuroraName => 'Aurora';

  @override
  String get g_shipScoutDesc => 'A well-balanced starter ship';

  @override
  String get g_shipInterceptorDesc => 'Fast and rapid-firing, but thin armor';

  @override
  String get g_shipFortressDesc => 'Slow but tough, with heavy hits';

  @override
  String get g_shipProspectorDesc => 'Ore +50%, pulls in items from afar';

  @override
  String get g_shipPhantomDesc => '25% chance of 2.5x critical hits';

  @override
  String get g_shipNovaDesc => 'Premium fighter whose shots pierce enemies';

  @override
  String get g_shipAuroraDesc =>
      'Premium guardian that self-repairs and wears a barrier';

  @override
  String get g_shipNovaAbility =>
      'Piercing shots: each shot pierces up to 3 enemies';

  @override
  String get g_shipAuroraAbility =>
      'Self-repair: heal 5% HP/sec after 3s without damage\nGuard: blocks 1 hit every 5s';

  @override
  String g_crewLegendPerk(int pct) {
    return '👑 Legendary command: all production (credits & ore) +$pct% (doesn\'t stack)';
  }

  @override
  String g_shipCreditBonus(int pct) {
    return '💰 Hunter bonus: +$pct% credits you earn yourself (bounties, asteroids, missions, raid defense)';
  }

  @override
  String g_unlockSector(int n) {
    return 'Reach star system $n';
  }

  @override
  String g_unlockBosses(int n) {
    return 'Defeat $n pirate bosses';
  }

  @override
  String g_unlockOre(int n) {
    return 'Collect $n ore';
  }

  @override
  String get g_skinDefault => 'Basic Scout';

  @override
  String get g_skinCrimson => 'Red Comet';

  @override
  String get g_skinMint => 'Mint Choco';

  @override
  String get g_skinStealth => 'Stealth Black';

  @override
  String get g_skinNeon => 'Neon Pink';

  @override
  String get g_skinRainbow => 'Rainbow Dream';

  @override
  String get g_skinGalaxy => 'Galaxy';

  @override
  String get g_skinGold => 'Gold Royal';

  @override
  String get g_outfitDefault => 'Basic Spacesuit';

  @override
  String get g_outfitCat => 'Kitty Helmet';

  @override
  String get g_outfitBunny => 'Bunny Ears';

  @override
  String get g_outfitAlien => 'Alien Antennae';

  @override
  String get g_outfitFlower => 'Flower Pin';

  @override
  String get g_outfitHat => 'Captain Hat';

  @override
  String get g_outfitCrown => 'Galaxy Crown';

  @override
  String get g_crewRoleGunner => 'Gunner';

  @override
  String get g_crewEffectGunner => 'Attack';

  @override
  String get g_crewRoleEngineer => 'Engineer';

  @override
  String get g_crewEffectEngineer => 'Max HP & repair';

  @override
  String get g_crewRolePilot => 'Pilot';

  @override
  String get g_crewEffectPilot => 'Speed';

  @override
  String get g_crewRoleTrader => 'Trader';

  @override
  String get g_crewEffectTrader => 'Credit income';

  @override
  String get g_crewRoleMiner => 'Miner';

  @override
  String get g_crewEffectMiner => 'Ore gain';

  @override
  String get g_crewRoleScientist => 'Scientist';

  @override
  String get g_crewEffectScientist => 'Skill cooldown';

  @override
  String get g_crewName0 => 'Bun';

  @override
  String get g_crewName1 => 'Coco';

  @override
  String get g_crewName2 => 'Starry';

  @override
  String get g_crewName3 => 'Tofu';

  @override
  String get g_crewName4 => 'Bean';

  @override
  String get g_crewName5 => 'Lulu';

  @override
  String get g_crewName6 => 'Haru';

  @override
  String get g_crewName7 => 'Popo';

  @override
  String get g_crewName8 => 'Mimi';

  @override
  String get g_crewName9 => 'Dori';

  @override
  String get g_crewName10 => 'Fluffy';

  @override
  String get g_crewName11 => 'Butterfly';

  @override
  String get g_crewName12 => 'Choco';

  @override
  String get g_crewName13 => 'Barley';

  @override
  String get g_crewName14 => 'Cloud';

  @override
  String get g_crewName15 => 'Drizzle';

  @override
  String get g_crewName16 => 'Tori';

  @override
  String get g_crewName17 => 'Happy';

  @override
  String get g_crewName18 => 'Rice Cake';

  @override
  String get g_crewName19 => 'Mochi';

  @override
  String get g_crewName20 => 'Latte';

  @override
  String get g_crewName21 => 'Cookie';

  @override
  String get g_crewName22 => 'Jelly';

  @override
  String get g_crewName23 => 'Cotton';

  @override
  String get g_crewName24 => 'Mango';

  @override
  String get g_crewName25 => 'Plum';

  @override
  String get g_crewName26 => 'Walnut';

  @override
  String get g_crewName27 => 'Inky';

  @override
  String get g_crewName28 => 'Bambi';

  @override
  String get g_crewName29 => 'Cheese';

  @override
  String get g_crewLegend0 => 'Galaxy Guardian';

  @override
  String get g_crewLegend1 => 'Star Hero';

  @override
  String get g_crewLegend2 => 'Nebula Sage';

  @override
  String get g_crewLegend3 => 'Comet Knight';

  @override
  String get g_crewLegend4 => 'Supernova';

  @override
  String g_crewLegendName(String title, String name) {
    return '$title $name';
  }

  @override
  String get g_bldHouse => 'House';

  @override
  String g_bldHouseEffect(int n) {
    return 'Residents +$n (more gifts)';
  }

  @override
  String get g_bldFarm => 'Space Farm';

  @override
  String g_bldFarmEffect(int n) {
    return 'Credit income +$n%';
  }

  @override
  String get g_bldMine => 'Mine';

  @override
  String g_bldMineEffect(int n) {
    return 'Ore gain +$n%';
  }

  @override
  String get g_bldLab => 'Lab';

  @override
  String g_bldLabEffect(int n) {
    return 'Skill cooldown -$n%';
  }

  @override
  String get g_bldTower => 'Defense Tower';

  @override
  String g_bldTowerEffect(int n) {
    return 'Max HP +$n%';
  }

  @override
  String get g_bldShipyard => 'Shipyard';

  @override
  String g_bldShipyardEffect(int n) {
    return 'Attack +$n%';
  }

  @override
  String get g_bldPark => 'Amusement Park';

  @override
  String g_bldParkEffect(int n) {
    return 'Offline income +$n%p';
  }

  @override
  String get g_bldStatue => 'Captain Statue';

  @override
  String g_bldStatueEffect(int n) {
    return 'Planet gift gems +$n';
  }

  @override
  String get g_homePalette0 => 'Green Garden';

  @override
  String get g_homePalette1 => 'Sand Desert';

  @override
  String get g_homePalette2 => 'Ice Kingdom';

  @override
  String get g_homePalette3 => 'Lava Island';

  @override
  String get g_homePalette4 => 'Violet Gas';

  @override
  String get g_homePalette5 => 'Cherry Blossom';

  @override
  String get g_homePalette6 => 'Aurora';

  @override
  String get g_homePalette7 => 'Gold';

  @override
  String get g_homeDefaultName => 'My Little Star';

  @override
  String get g_achFirstBloodTitle => 'First Blood';

  @override
  String get g_achFirstBloodDesc => 'Shoot down 1 pirate';

  @override
  String get g_achHunterTitle => 'Pirate Hunter';

  @override
  String get g_achHunterDesc => 'Shoot down 100 pirates';

  @override
  String get g_achLegendTitle => 'Legendary Captain';

  @override
  String get g_achLegendDesc => 'Shoot down 1000 pirates';

  @override
  String get g_achMinerTitle => 'Mining King';

  @override
  String get g_achMinerDesc => 'Collect 1000 ore';

  @override
  String get g_achMiner2Title => 'Ore Tycoon';

  @override
  String get g_achMiner2Desc => 'Collect 10000 ore';

  @override
  String get g_achColonistTitle => 'Pioneer';

  @override
  String get g_achColonistDesc => 'Settle 5 planets';

  @override
  String get g_achMetropolisTitle => 'Metropolis';

  @override
  String get g_achMetropolisDesc => 'Grow a colony to Lv.5';

  @override
  String get g_achBuilderTitle => 'Builder';

  @override
  String get g_achBuilderDesc => 'Build 3 stations';

  @override
  String get g_achBoss1Title => 'Boss Hunt';

  @override
  String get g_achBoss1Desc => 'Defeat a pirate boss';

  @override
  String get g_achBoss10Title => 'Boss Slayer';

  @override
  String get g_achBoss10Desc => 'Defeat pirate bosses 10 times';

  @override
  String get g_achExplorerTitle => 'Explorer';

  @override
  String get g_achExplorerDesc => 'Reach star system 3';

  @override
  String get g_achVoyagerTitle => 'Voyager';

  @override
  String get g_achVoyagerDesc => 'Reach star system 6';

  @override
  String get g_achRichTitle => 'Rich Captain';

  @override
  String get g_achRichDesc => 'Hold 10000 credits';

  @override
  String get g_achCrew6Title => 'Trusty Crew';

  @override
  String get g_achCrew6Desc => 'Recruit 6 crew';

  @override
  String get g_achCrew3starTitle => 'Legendary Mate';

  @override
  String get g_achCrew3starDesc => 'Recruit a ★3 crew member';

  @override
  String get g_achMissionsTitle => 'Troubleshooter';

  @override
  String get g_achMissionsDesc => 'Complete 20 missions';

  @override
  String get g_achJellyTitle => 'Jellyfish Expert';

  @override
  String get g_achJellyDesc => 'Defeat 10 space jellyfish';

  @override
  String get g_achFashionTitle => 'Fashionista';

  @override
  String get g_achFashionDesc => 'Buy a cosmetic item';

  @override
  String get g_achAscendTitle => 'New Beginning';

  @override
  String get g_achAscendDesc => 'Ascend with Galactic Honor';

  @override
  String get g_achDroneTitle => 'Trusty Drone';

  @override
  String get g_achDroneDesc => 'Equip a combat drone';

  @override
  String get g_achHome5Title => 'Planet Architect';

  @override
  String get g_achHome5Desc => '5 buildings on my planet';

  @override
  String get g_achHomeMaxTitle => 'Dream Planet';

  @override
  String get g_achHomeMaxDesc => 'Max out my planet level';

  @override
  String get g_dailyKill => 'Shoot down 30 pirates';

  @override
  String get g_dailyOre => 'Collect 300 ore';

  @override
  String get g_dailyMission => 'Complete 2 missions';

  @override
  String get g_dailyColony => 'Grow colonies 2 times';

  @override
  String get g_dailyBoss => 'Defeat a pirate boss';

  @override
  String get g_dailyPower => 'Grab 3 power-ups';

  @override
  String get g_dailyPlay => 'Play for 10 minutes';

  @override
  String get g_dailyJelly => 'Defeat 3 space jellyfish';

  @override
  String g_missionKill(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n pirates',
      one: '1 pirate',
    );
    return 'Clear $_temp0';
  }

  @override
  String g_missionMine(int n) {
    return 'Collect $n ore';
  }

  @override
  String g_missionDeliver(String planet) {
    return 'Deliver cargo to $planet';
  }

  @override
  String g_missionBounty(String name) {
    return 'Wanted: $name';
  }

  @override
  String get g_bounty0 => 'One-Eye Jack';

  @override
  String get g_bounty1 => 'Lightning Molly';

  @override
  String get g_bounty2 => 'Scrap King Bark';

  @override
  String get g_bounty3 => 'Redbeard Toto';

  @override
  String get g_bounty4 => 'Shadow Lena';

  @override
  String get g_bounty5 => 'Chubby Pork';

  @override
  String get g_bounty6 => 'Twin-Blade Gigi';

  @override
  String get g_bounty7 => 'Mad Hammer Bud';

  @override
  String get g_bounty8 => 'Galaxy Fox Lucy';

  @override
  String get g_bounty9 => 'Captain Skull Bones';

  @override
  String get g_storyAsteroidsTitle => 'Smash 3 asteroids';

  @override
  String get g_storyAsteroidsLine0 =>
      'We need ore for our Mars supply base. Break three asteroids first.';

  @override
  String get g_storyAsteroidsLine1 =>
      'Move with the joystick and shoot with the fire button!';

  @override
  String get g_storyKillsTitle => 'Defeat 3 attacking ships';

  @override
  String get g_storyKillsLine0 =>
      'Unidentified ships are targeting the relay outposts. Follow the red arrows and stop three attackers.';

  @override
  String get g_storyKillsLine1 =>
      'Let us clear the way. Others will be following us!';

  @override
  String get g_storyColoniesTitle => 'Settle Mars';

  @override
  String get g_storyColoniesLine0 =>
      'Let us make a place to return to on Mars. Fly close and tap Settle.';

  @override
  String get g_storyColoniesLine1 =>
      'The settlers\' credits will help us prepare for our next voyage.';

  @override
  String get g_storyShipLevelsTitle => 'Upgrade your ship at a station';

  @override
  String get g_storyShipLevelsLine0 =>
      'Our ship needs to be stronger to expand the network. Refit her at Haven Base.';

  @override
  String get g_storyCrewTitle => 'Recruit 1 crew member';

  @override
  String get g_storyCrewLine0 =>
      'We need company for the long journey. Recruit someone in the station\'s Crew tab.';

  @override
  String get g_storyMissionsTitle => 'Complete 1 mission';

  @override
  String get g_storyMissionsLine0 =>
      'People along the route need help, too. Take a job from the station mission board.';

  @override
  String get g_storyStationsTitle => 'Build a new station';

  @override
  String get g_storyStationsLine0 =>
      'Give supply ships another place to rest. Build a station in open space away from planets.';

  @override
  String get g_storyDevPercentTitle => 'System stabilization 100%';

  @override
  String get g_storyDevPercentLine0 =>
      'Reach a total Phase Anchor level of the number of planets × 3 to connect the supply network and open the gate. Check the System button.';

  @override
  String get g_storySectorTitle => 'Warp to the next system';

  @override
  String get g_storySectorLine0 =>
      'We need transmission outposts in the next system. Head to the purple gate on the minimap.';

  @override
  String get g_storySectorLine1 =>
      'Let us tell them we are coming. No one should have to wait alone.';

  @override
  String g_storyDevNTitle(int n) {
    return 'System $n stabilization 100%';
  }

  @override
  String get g_storyDevNLine =>
      'Build a way home here, too. Reach a total Phase Anchor level of the number of planets × 3 to open the next gate.';

  @override
  String g_systemN(int n) {
    return 'System $n';
  }

  @override
  String g_storyWarpNTitle(String system) {
    return 'Warp to $system';
  }

  @override
  String get g_storyWarpNLine =>
      'The route is connected. Expand the Haven network into the new system.';

  @override
  String get g_powerUpRapid => 'Rapid Fire';

  @override
  String get g_powerUpShield => 'Shield';

  @override
  String get g_powerUpMagnet => 'Magnet';

  @override
  String get g_powerUpDoubleCredits => '2x Credits';

  @override
  String get g_planetKindGarden => 'Garden Planet';

  @override
  String get g_planetKindDesert => 'Desert Planet';

  @override
  String get g_planetKindIce => 'Ice Planet';

  @override
  String get g_planetKindLava => 'Lava Planet';

  @override
  String get g_planetKindGas => 'Gas Planet';

  @override
  String get g_colonyBldTurret => 'Turret';

  @override
  String get g_colonyBldMine => 'Mining Rig';

  @override
  String get g_colonyBldTrade => 'Trade Post';

  @override
  String get g_colonyBldDock => 'Repair Dock';

  @override
  String get g_colonyBldShieldGen => 'Shield Generator';

  @override
  String get g_colonyBldStabilizer => 'Phase Anchor';

  @override
  String get g_colonyBldBlurbTurret =>
      'Auto-shoots pirates near the colony. A must against raids!';

  @override
  String get g_colonyBldBlurbMine => 'Mines ore and sends 💎 every second.';

  @override
  String get g_colonyBldBlurbTrade =>
      'Boosts this colony\'s credit income by 25% per level.';

  @override
  String get g_colonyBldBlurbDock => 'Repairs your ship while you are nearby.';

  @override
  String get g_colonyBldBlurbShieldGen =>
      'Increases shield capacity and recharge speed.';

  @override
  String get g_colonyBldBlurbStabilizer =>
      'System stabilization · shared shield\n+10% colony income per level';

  @override
  String g_stabilizerDamaged(String planet, int level) {
    return 'The Phase Anchor on $planet was damaged and dropped to level $level.';
  }

  @override
  String get g_stationRoleHome => 'Home Base';

  @override
  String get g_stationRoleDefense => 'Defense Base';

  @override
  String get g_stationRoleRepair => 'Repair Base';

  @override
  String get g_stationRoleSupport => 'Supply Base';

  @override
  String get g_stationRoleBlurbHome => 'Laser battery and safe zone';

  @override
  String get g_stationRoleBlurbDefense =>
      'Strong turret · 2x durability · blocks nearby enemy shots';

  @override
  String get g_stationRoleBlurbRepair =>
      'Wide fast repair · 10% relaunch cost · 2x shield recharge for nearby colonies';

  @override
  String get g_stationRoleBlurbSupport =>
      'Nearby colony output +25% (+5% per habitat level)';

  @override
  String g_eventRaid(String planet) {
    return 'Raid on $planet';
  }

  @override
  String get g_eventMeteor => 'Meteor Shower';

  @override
  String get g_eventMerchant => 'Wandering Merchant';

  @override
  String get g_eventSupply => 'Supply Capsule';

  @override
  String get g_productGems100Title => 'Handful of Gems';

  @override
  String get g_productGems550Title => 'Pouch of Gems';

  @override
  String get g_productGems1200Title => 'Chest of Gems';

  @override
  String get g_productStarterTitle => 'Starter Pack';

  @override
  String get g_productPassTitle => 'Fleet Commander Pass';

  @override
  String get g_productGems550Desc => '⭐550 (+10% bonus)';

  @override
  String get g_productGems1200Desc => '⭐1200 (+20% bonus)';

  @override
  String get g_productStarterDesc =>
      '⭐300 + exclusive skin \"Galaxy\" + ★3 crew (one time only)';

  @override
  String get g_productPassDesc =>
      'Credit income +25%, 8h offline income, rewards without ads, exclusive skin \"Gold Royal\"';

  @override
  String g_testPurchaseTitle(String product) {
    return '[Test purchase] $product';
  }

  @override
  String g_testPurchaseBody(String desc, String price) {
    return 'No real payment will be made.\n$desc\nPrice: $price';
  }

  @override
  String get g_testAdTitle => '[Test ad]';

  @override
  String get g_testAdBody => 'Treat the ad as fully watched?';

  @override
  String get g_webDemoTitle => 'Web Demo';

  @override
  String get g_webDemoBody =>
      'Purchases and ad rewards are available in the mobile app.';

  @override
  String get g_notifChannelName => 'Return reminders';

  @override
  String get g_notifChannelDesc => 'Colony income and daily reward reminders';

  @override
  String get g_notifStorageTitle => 'Your colony storage is full!';

  @override
  String get g_notifStorageBody =>
      'Captain, come collect your credits before income stops!';

  @override
  String get g_notifPiratesTitle => 'The pirates are running wild again!';

  @override
  String get g_notifPiratesBody =>
      'Today\'s login reward and daily quests are waiting.';

  @override
  String get g_upgradeWeapon => 'Weapon';

  @override
  String get g_upgradeHull => 'Armor';

  @override
  String get g_upgradeEngine => 'Engine';

  @override
  String get g_upgradeMissile => 'Homing Missile';

  @override
  String get g_upgradeShield => 'Energy Shield';

  @override
  String get g_upgradeDrone => 'Combat Drone';

  @override
  String get g_upgradeMagnet => 'Magnet';

  @override
  String g_unknownSector(int n) {
    return 'Unknown System $n';
  }

  @override
  String get g_stationHaven => 'Haven Base';

  @override
  String g_stationOutpost(String sector) {
    return '$sector Outpost';
  }

  @override
  String g_stationNumbered(String role, int n) {
    return '$role #$n';
  }

  @override
  String get g_dlgWelcome => 'Welcome, Captain. I\'m Scientist Mina.';

  @override
  String get g_dlgMissionsCancelled =>
      'Delivery and bounty missions from the last system were canceled.';

  @override
  String get g_floatDisabled => 'Disabled!';

  @override
  String get g_floatRebooted => 'Back online!';

  @override
  String get g_dlgBaseRebooted =>
      'Home base back online! Restored to 30% durability.';

  @override
  String get g_dlgUpWeapon => 'Weapons upgraded! Pirates, brace yourselves!';

  @override
  String get g_dlgUpHull => 'Armor upgraded! Feels sturdier now.';

  @override
  String get g_dlgUpEngine => 'Engine upgraded! Faster!';

  @override
  String get g_dlgMissileNew => 'Homing missiles equipped! (Q)';

  @override
  String get g_dlgMissileUp => 'Missiles upgraded!';

  @override
  String get g_dlgShieldNew => 'Energy shield equipped! (F)';

  @override
  String get g_dlgShieldUp => 'Shield upgraded!';

  @override
  String get g_dlgDroneNew => 'Combat drone launched! A trusty new friend.';

  @override
  String get g_dlgDroneUp => 'Drone upgraded!';

  @override
  String get g_dlgUpMagnet => 'Magnet upgraded! Credits fly right to me!';

  @override
  String get g_dlgNotOver => 'It\'s not over yet!';

  @override
  String get g_floatBlocked => 'Blocked!';

  @override
  String get g_floatGuard => 'Guarded!';

  @override
  String get g_pirateBossLose => 'Argh! This system… is yours…';

  @override
  String get g_pirateBossFlee => 'Argh! I\'ll remember this, Captain!';

  @override
  String get g_dlgSupplyCollected => 'Supply capsule recovered!';

  @override
  String get g_merchantBye => 'See you next time~ meow!';

  @override
  String get g_pirateRaidTaunt => 'Destroy the Phase Anchors first.';

  @override
  String get g_dlgMeteor =>
      'Meteor shower spotted! Packed with crystals. Big ore chance!';

  @override
  String get g_merchantHello =>
      'Wandering merchant Nyang-nyang is here~ Lots of good stuff, meow!';

  @override
  String get g_dlgSupplySignal =>
      'Signal from a supply capsule with gems! Pirates are guarding it, so be careful.';

  @override
  String get g_dlgCruiseOn =>
      'First training done! I turned on [Cruise] above the joystick: you keep flying where you face even after letting go. Tap it again to turn it off.';

  @override
  String get g_dlgBossWarning =>
      'Warning! The system boss ship is approaching!';

  @override
  String get g_pirateRevenge => 'I\'m back for revenge! Prepare yourself!';

  @override
  String get g_floatShieldBroken => 'Broken!';

  @override
  String get g_floatShieldBack => 'Back up';

  @override
  String get g_floatGoalDone => 'Goal complete!';

  @override
  String g_dlgArrived(String sector) {
    return 'Arrived at $sector!';
  }

  @override
  String get g_dlgNewFrontier => 'A brand-new frontier.';

  @override
  String g_dlgBaseUpgraded(String station, int level) {
    return '$station upgraded to Lv.$level! Lasers are stronger.';
  }

  @override
  String g_dlgBaseDisabled(int sec) {
    return 'Home base disabled! Protection is down for ${sec}s!';
  }

  @override
  String g_dlgSettled(String planet) {
    return 'Flag planted on $planet! Settled!';
  }

  @override
  String g_dlgStationBuilt(String station, String blurb) {
    return '$station built! $blurb';
  }

  @override
  String g_dlgHabitatUp(String station, int level) {
    return '$station habitat Lv.$level!';
  }

  @override
  String g_dlgTurretUp(String station, int level) {
    return '$station turret Lv.$level!';
  }

  @override
  String g_dlgShipSwitched(String ship) {
    return 'Switched to the $ship! Feels good!';
  }

  @override
  String g_dlgOreSold(int n, int credits) {
    return 'Sold $n ore for 💰$credits.';
  }

  @override
  String g_dlgCrewJoined(String stars, String role, String name) {
    return '$stars $role $name joined the crew!';
  }

  @override
  String g_dlgCrewLevel(String name, int level) {
    return '$name Lv.$level! Getting better.';
  }

  @override
  String g_dlgCargoLoaded(String mission) {
    return 'Cargo loaded! $mission';
  }

  @override
  String g_dlgBountyTaunt(String name) {
    return 'You think you can catch $name? Come and try!';
  }

  @override
  String get g_floatMissionDone => 'Mission complete!';

  @override
  String g_dlgMissionDone(String mission) {
    return 'Mission complete: $mission!';
  }

  @override
  String g_dlgRepairCost(int credits) {
    return 'You\'re safe, Captain! Repairs cost 💰$credits.';
  }

  @override
  String g_dlgSectorDeveloped(String sector) {
    return '$sector fully developed! The warp gate to the next system is open.';
  }

  @override
  String g_floatCrit(int dmg) {
    return 'Critical! $dmg';
  }

  @override
  String g_dlgStationDestroyed(String station) {
    return '$station was destroyed! We need turrets!';
  }

  @override
  String g_dlgBossDefeated(int credits) {
    return 'System boss defeated! Reward 💰$credits';
  }

  @override
  String g_dlgBountyCaught(String name) {
    return 'Wanted pirate $name captured!';
  }

  @override
  String g_dlgRaidDefended(String planet, int credits) {
    return '$planet defended! Grateful residents sent 💰$credits ⭐2.';
  }

  @override
  String g_dlgRaidLooted(String planet, String level) {
    return '$planet was looted and dropped to $level… 😢';
  }

  @override
  String g_dlgRaidLeft(String planet) {
    return 'The pirates looted $planet and left.';
  }

  @override
  String g_dlgRaidAlert(String planet) {
    return 'Emergency! Pirates are raiding $planet! Production has stopped!';
  }

  @override
  String g_dlgInvasionWarning(int sec) {
    return 'Invasion alert! A pirate fleet arrives in ${sec}s. Defend the base!';
  }

  @override
  String g_dlgInvasionWon(int credits) {
    return 'We stopped the invasion! Reward 💰$credits ⭐5';
  }

  @override
  String g_dlgInvasionRetreat(int pct, int credits) {
    return 'The invasion fleet withdrew. $pct% downed · reward 💰$credits';
  }

  @override
  String get g_invasionCommander => 'Invasion Commander';

  @override
  String g_pirateBossArrive(String sector) {
    return 'Cut off the relay network in $sector.';
  }

  @override
  String g_dlgWelcomeBack(String goal) {
    return 'Welcome back, Captain! Current goal: $goal';
  }

  @override
  String get g_pirateWin0 => 'Hahaha! Not so tough!';

  @override
  String get g_pirateWin1 => 'Come back stronger next time, kid!';

  @override
  String get g_pirateWin2 => 'Your ship is scrap now!';

  @override
  String get g_pirateRage0 => 'Come out, boys! Teach them a lesson!';

  @override
  String get g_pirateRage1 => 'Now it gets real!';

  @override
  String get g_pirateRage2 => 'Now you made me mad?!';

  @override
  String get g_captainKill0 => 'One down!';

  @override
  String get g_captainKill1 => 'Where d\'you think you\'re going!';

  @override
  String get g_captainKill2 => 'This turf is mine!';

  @override
  String get g_captainKill3 => 'Next!';

  @override
  String get g_pirateAmbush0 => 'Target ship confirmed. Continue pursuit.';

  @override
  String get g_pirateAmbush1 => 'Intercept the expedition.';

  @override
  String get g_pirateAmbush2 => 'Keep them away from the transmitters.';

  @override
  String get g_pirateAmbush3 => 'Target acquired. Begin the attack.';

  @override
  String get cat_sysSol => 'Solar System';

  @override
  String get cat_sysAlphaCen => 'Alpha Centauri';

  @override
  String get cat_sysBarnard => 'Barnard\'s Star';

  @override
  String get cat_sysWolf359 => 'Wolf 359';

  @override
  String get cat_sysLalande => 'Lalande 21185';

  @override
  String get cat_sysSirius => 'Sirius';

  @override
  String get cat_sysEpsEri => 'Epsilon Eridani';

  @override
  String get cat_sysRoss128 => 'Ross 128';

  @override
  String get cat_sysTauCeti => 'Tau Ceti';

  @override
  String get cat_sysTeegarden => 'Teegarden\'s Star';

  @override
  String get cat_sysGliese581 => 'Gliese 581';

  @override
  String get cat_sysGliese667C => 'Gliese 667 C';

  @override
  String get cat_sysTrappist1 => 'TRAPPIST-1';

  @override
  String get cat_sys55Cnc => '55 Cancri';

  @override
  String get cat_sys51Peg => '51 Pegasi';

  @override
  String cat_sysKepler(int n) {
    return 'Kepler-$n';
  }

  @override
  String get cat_sysOmegaCen => 'Omega Centauri Cluster';

  @override
  String get cat_sysSgrA => 'Galactic Center (Sgr A*)';

  @override
  String get cat_sysLMC => 'Large Magellanic Cloud';

  @override
  String get cat_sysSMC => 'Small Magellanic Cloud';

  @override
  String get cat_sysAndromeda => 'Andromeda Galaxy';

  @override
  String get cat_sysTriangulum => 'Triangulum Galaxy';

  @override
  String get cat_pfxProxima => 'Proxima';

  @override
  String get cat_pfxBarnard => 'Barnard';

  @override
  String get cat_pfxSirius => 'Sirius A';

  @override
  String get cat_pfxEpsEri => 'Epsilon Eridani';

  @override
  String get cat_pfxTauCeti => 'Tau Ceti';

  @override
  String get cat_pfxTeegarden => 'Teegarden';

  @override
  String get cat_mars => 'Mars';

  @override
  String get cat_moon => 'Moon';

  @override
  String get cat_venus => 'Venus';

  @override
  String get cat_mercury => 'Mercury';

  @override
  String get cat_ceres => 'Ceres';

  @override
  String get cat_vesta => 'Vesta';

  @override
  String get cat_jupiter => 'Jupiter';

  @override
  String get cat_io => 'Io';

  @override
  String get cat_europa => 'Europa';

  @override
  String get cat_ganymede => 'Ganymede';

  @override
  String get cat_callisto => 'Callisto';

  @override
  String get cat_saturn => 'Saturn';

  @override
  String get cat_enceladus => 'Enceladus';

  @override
  String get cat_titan => 'Titan';

  @override
  String get cat_uranus => 'Uranus';

  @override
  String get cat_miranda => 'Miranda';

  @override
  String get cat_titania => 'Titania';

  @override
  String get cat_neptune => 'Neptune';

  @override
  String get cat_triton => 'Triton';

  @override
  String get cat_pluto => 'Pluto';

  @override
  String get cat_charon => 'Charon';

  @override
  String get cat_haumea => 'Haumea';

  @override
  String get cat_makemake => 'Makemake';

  @override
  String get cat_eris => 'Eris';

  @override
  String get cat_sedna => 'Sedna';

  @override
  String get cat_planetNine => 'Planet Nine';

  @override
  String get u_topUpTitle => 'Not enough resources';

  @override
  String u_topUpBody(String short, int gems) {
    return 'You need $short more. Use ⭐$gems to fill the gap and continue?';
  }

  @override
  String u_topUpNoGems(String short, int gems, int have) {
    return 'You need $short more. Filling it takes ⭐$gems, but you have ⭐$have. Gather a bit more!';
  }

  @override
  String get u_topUpOk => 'Fill & go';

  @override
  String get u_goShop => 'Go to shop';

  @override
  String get u_exchangeTitle => '💰 Exchange credits';

  @override
  String u_exchangeBody(int gems, int credits) {
    return 'Exchange ⭐$gems for 💰$credits?';
  }

  @override
  String get m_purchaseFailed =>
      'Couldn\'t reach the store. Please try again later.';

  @override
  String get m_adWatchToEnd => 'Watch the ad to the end to get the reward.';

  @override
  String get u_cruise => 'Cruise';

  @override
  String get u_autoFireOn => 'ON';

  @override
  String get u_autoFireOff => 'OFF';

  @override
  String u_recruitRoleOdds(int count, String pct) {
    return 'Role (all recruits): random among $count, $pct each';
  }

  @override
  String m_feedbackSubject(String app) {
    return '$app feedback';
  }

  @override
  String get lb_menu => '🏅 Weekly Ranking';

  @override
  String get lb_menuShort => 'Ranks';

  @override
  String get lb_title => '🏅 Weekly Ranking';

  @override
  String get lb_join => 'Join the leaderboard';

  @override
  String get lb_joinDesc =>
      'Only an anonymous ID, a nickname made by the game and your weekly score are sent. No names, no chat, nothing you type. You can turn it off any time.';

  @override
  String get lb_yourNick => 'Your nickname';

  @override
  String lb_reroll(int count) {
    return 'New name ($count)';
  }

  @override
  String lb_weekPoints(String points) {
    return 'This week: $points pts';
  }

  @override
  String lb_rank(int rank, int total) {
    return '#$rank of $total';
  }

  @override
  String lb_rankOnly(int rank) {
    return '#$rank';
  }

  @override
  String get lb_top50 => 'Top 50 this week';

  @override
  String get lb_empty => 'No scores yet this week. Be the first!';

  @override
  String get lb_retry => 'Try again';

  @override
  String get lb_refresh => 'Refresh';

  @override
  String get lb_offline =>
      'No connection. Your game is fine — try again later.';

  @override
  String get lb_rateLimited => 'Too many tries. Wait a minute and try again.';

  @override
  String get lb_rejected => 'This score could not be sent.';

  @override
  String get lb_serverError => 'The leaderboard is busy. Try again later.';

  @override
  String get lb_unavailable => 'The leaderboard is not available.';

  @override
  String get lb_optedOut =>
      'Turn on “Join the leaderboard” to post your score.';

  @override
  String get lb_howTo =>
      'Colony level +100 · New star system +500 · Pirate +5 · Boss +200';

  @override
  String get lb_resets => 'A new week starts every Monday at 00:00 UTC.';

  @override
  String nickFormat(String adj, String animal, String number) {
    return '$adj $animal $number';
  }

  @override
  String get nickGenders => '';

  @override
  String nickAdj0(String g) {
    return 'Brave';
  }

  @override
  String get nickAnimal0 => 'Otter';

  @override
  String nickAdj1(String g) {
    return 'Bright';
  }

  @override
  String get nickAnimal1 => 'Panda';

  @override
  String nickAdj2(String g) {
    return 'Calm';
  }

  @override
  String get nickAnimal2 => 'Fox';

  @override
  String nickAdj3(String g) {
    return 'Clever';
  }

  @override
  String get nickAnimal3 => 'Rabbit';

  @override
  String nickAdj4(String g) {
    return 'Cosmic';
  }

  @override
  String get nickAnimal4 => 'Owl';

  @override
  String nickAdj5(String g) {
    return 'Curious';
  }

  @override
  String get nickAnimal5 => 'Penguin';

  @override
  String nickAdj6(String g) {
    return 'Bouncy';
  }

  @override
  String get nickAnimal6 => 'Koala';

  @override
  String nickAdj7(String g) {
    return 'Dreamy';
  }

  @override
  String get nickAnimal7 => 'Dolphin';

  @override
  String nickAdj8(String g) {
    return 'Cozy';
  }

  @override
  String get nickAnimal8 => 'Turtle';

  @override
  String nickAdj9(String g) {
    return 'Fast';
  }

  @override
  String get nickAnimal9 => 'Hedgehog';

  @override
  String nickAdj10(String g) {
    return 'Fluffy';
  }

  @override
  String get nickAnimal10 => 'Squirrel';

  @override
  String nickAdj11(String g) {
    return 'Friendly';
  }

  @override
  String get nickAnimal11 => 'Kitten';

  @override
  String nickAdj12(String g) {
    return 'Gentle';
  }

  @override
  String get nickAnimal12 => 'Puppy';

  @override
  String nickAdj13(String g) {
    return 'Glowing';
  }

  @override
  String get nickAnimal13 => 'Duckling';

  @override
  String nickAdj14(String g) {
    return 'Golden';
  }

  @override
  String get nickAnimal14 => 'Lamb';

  @override
  String nickAdj15(String g) {
    return 'Happy';
  }

  @override
  String get nickAnimal15 => 'Seal';

  @override
  String nickAdj16(String g) {
    return 'Funny';
  }

  @override
  String get nickAnimal16 => 'Whale';

  @override
  String nickAdj17(String g) {
    return 'Kind';
  }

  @override
  String get nickAnimal17 => 'Hamster';

  @override
  String nickAdj18(String g) {
    return 'Lucky';
  }

  @override
  String get nickAnimal18 => 'Beaver';

  @override
  String nickAdj19(String g) {
    return 'Musical';
  }

  @override
  String get nickAnimal19 => 'Raccoon';

  @override
  String nickAdj20(String g) {
    return 'Strong';
  }

  @override
  String get nickAnimal20 => 'Parrot';

  @override
  String nickAdj21(String g) {
    return 'Colorful';
  }

  @override
  String get nickAnimal21 => 'Ladybug';

  @override
  String nickAdj22(String g) {
    return 'Sweet';
  }

  @override
  String get nickAnimal22 => 'Sparrow';

  @override
  String nickAdj23(String g) {
    return 'Polite';
  }

  @override
  String get nickAnimal23 => 'Fawn';

  @override
  String nickAdj24(String g) {
    return 'Playful';
  }

  @override
  String get nickAnimal24 => 'Pony';

  @override
  String nickAdj25(String g) {
    return 'Quiet';
  }

  @override
  String get nickAnimal25 => 'Bear Cub';

  @override
  String nickAdj26(String g) {
    return 'Shiny';
  }

  @override
  String get nickAnimal26 => 'Lion Cub';

  @override
  String nickAdj27(String g) {
    return 'Silver';
  }

  @override
  String get nickAnimal27 => 'Tiger Cub';

  @override
  String nickAdj28(String g) {
    return 'Sleepy';
  }

  @override
  String get nickAnimal28 => 'Giraffe';

  @override
  String nickAdj29(String g) {
    return 'Lunar';
  }

  @override
  String get nickAnimal29 => 'Zebra';

  @override
  String nickAdj30(String g) {
    return 'Solar';
  }

  @override
  String get nickAnimal30 => 'Elephant';

  @override
  String nickAdj31(String g) {
    return 'Magic';
  }

  @override
  String get nickAnimal31 => 'Hippo';

  @override
  String nickAdj32(String g) {
    return 'Super';
  }

  @override
  String get nickAnimal32 => 'Llama';

  @override
  String nickAdj33(String g) {
    return 'Starry';
  }

  @override
  String get nickAnimal33 => 'Alpaca';

  @override
  String nickAdj34(String g) {
    return 'Sunny';
  }

  @override
  String get nickAnimal34 => 'Meerkat';

  @override
  String nickAdj35(String g) {
    return 'Noble';
  }

  @override
  String get nickAnimal35 => 'Starfish';

  @override
  String nickAdj36(String g) {
    return 'Tiny';
  }

  @override
  String get nickAnimal36 => 'Seahorse';

  @override
  String nickAdj37(String g) {
    return 'Wise';
  }

  @override
  String get nickAnimal37 => 'Chipmunk';

  @override
  String nickAdj38(String g) {
    return 'Snowy';
  }

  @override
  String get nickAnimal38 => 'Goldfish';

  @override
  String nickAdj39(String g) {
    return 'Loyal';
  }

  @override
  String get nickAnimal39 => 'Firefly';

  @override
  String get m_adPrivacy => 'Ad privacy settings';

  @override
  String get m_cloudTitle => 'Cloud backup';

  @override
  String m_cloudDesc(String service) {
    return 'Back up your progress to your $service account to keep playing after switching devices or reinstalling. Tap to connect.';
  }

  @override
  String m_cloudConnectFailed(String service) {
    return 'Couldn\'t connect to $service. Please try again in a moment.';
  }

  @override
  String get m_cloudBackupNow => 'Back up now';

  @override
  String get m_cloudNever => 'Not backed up yet';

  @override
  String m_cloudLast(String time) {
    return 'Last backup: $time';
  }

  @override
  String get m_cloudBackedUp => 'Backed up.';

  @override
  String get m_cloudFailed =>
      'Couldn\'t reach the cloud. Check your internet connection.';

  @override
  String get m_cloudRestore => 'Restore from backup';

  @override
  String m_cloudAccount(String account) {
    return 'Connected account: $account';
  }

  @override
  String get m_cloudNoBackup => 'There\'s no backup to restore.';

  @override
  String get m_cloudRestoreTitle => 'Restore from backup?';

  @override
  String m_cloudRestoreBody(String time) {
    return 'Your progress will be replaced with the backup from $time. Progress on this device will be lost and can\'t be undone. Gems and purchases will also switch to the backed-up ones.';
  }

  @override
  String get m_cloudRestoreOk => 'Restore';

  @override
  String get m_cloudRestored => 'Restored.';

  @override
  String get m_cloudFoundTitle => 'Backup found';

  @override
  String m_cloudFoundBody(String time) {
    return 'There\'s a backup from $time. Restore it now? You can also restore later in Settings.';
  }

  @override
  String get m_cloudLater => 'Later';

  @override
  String get m_cloudOverwriteTitle => 'Overwrite the cloud backup?';

  @override
  String m_cloudOverwriteBody(String time) {
    return 'The cloud has a backup from another device ($time). If you overwrite it with this device\'s progress, that backup can\'t be recovered.';
  }

  @override
  String get m_cloudOverwriteOk => 'Overwrite';

  @override
  String get n_title => 'Project Haven';

  @override
  String get n_signal => 'Visitor from Beyond Sol';

  @override
  String get n_haven => 'Time Bought';

  @override
  String get n_departure => 'Haven Expedition';

  @override
  String get n_mars => 'Preparing to Transmit';

  @override
  String get n_transmission => 'First Transmission';

  @override
  String get n_gate => 'Beyond Sol';

  @override
  String get n_signalSpeaker => 'Scientist Mina';

  @override
  String get n_settler => 'Colony resident';

  @override
  String get n_earthReport => 'Earth report';

  @override
  String get n_open0 =>
      'Antimatter particle detections keep rising.\nAt this rate, an antimatter Earth will enter our solar system.';

  @override
  String get n_open1 =>
      'Mina’s Phase Anchor passed its first test with Haven’s ancient CORE ENGINE. Humans still do not know who built the core, but it slowed the antimatter Earth.';

  @override
  String get n_open2 =>
      'I will install the anchors.\nWe will build colonies and connect a transmission network to Haven.';

  @override
  String get n_open3 => 'Haven is online. Track the expedition.';

  @override
  String get n_enemyCommander => 'Unidentified transmission';

  @override
  String get n_mars0 =>
      'The settlement is ready, Captain. We have prepared a site for the Phase Anchor, too.';

  @override
  String get n_mars1 =>
      'Build a Phase Anchor to send energy to Haven.\n\nUpgrade the devices and establish more outposts to complete the system network.';

  @override
  String get n_mars2 =>
      'Unknown raiders are targeting the Phase Anchor. Protect the devices and shields.';

  @override
  String get n_transmission0 =>
      'Phase Anchor online. Haven confirms receipt of the first transmission.\n\nThe energy we gathered has reached Earth.';

  @override
  String get n_transmission1 =>
      'A school closed by power rationing has reopened. Children are back in class.\n\nPlease keep transmitting. Protect the equipment and shields, and expand the network.';

  @override
  String get n_warp0 =>
      'The Sol network is stable, but Earth and solar energy are insufficient. We need power from other stars to slow the antimatter Earth further.';

  @override
  String get n_warp1 =>
      'Keep this network transmitting and build colonies and anchors in other systems. Set course for Alpha Centauri, Captain.';

  @override
  String get n_next => 'Next';

  @override
  String get n_skip => 'Skip scene';

  @override
  String get n_launch => 'Launch';

  @override
  String get g_antimatterEarth => 'Antimatter Earth';

  @override
  String get u_antimatterHint =>
      'It is still beyond the planetary orbits. More Phase Anchors will slow its approach.';

  @override
  String get c_endingTitle => 'Earth is safe';

  @override
  String get c_endingBody =>
      'The antimatter Earth has been sent away. Every colony helped protect Earth, and settlement continues.';

  @override
  String get c_finalTitle => 'Final operation';

  @override
  String get c_stabilize => 'Bring local anchor grid to 100%';

  @override
  String get c_syncReady => 'Go to the Haven relay and sync';

  @override
  String c_syncProgress(int percent) {
    return 'Sync $percent%';
  }

  @override
  String get c_guardian => 'Defeat the core guardian';

  @override
  String get c_counterattack => 'Return to the relay and reverse transmission';

  @override
  String get c_complete => 'Mission complete';

  @override
  String get c_syncButton => 'Sync ship';

  @override
  String get c_fireButton => 'Reverse transmission';

  @override
  String get c_guardianName => 'Core Guardian';

  @override
  String c_title(String sector) {
    String _temp0 = intl.Intl.selectLogic(sector, {
      '1': 'Alpha Centauri relay',
      '5': 'Sirius under attack',
      '8': 'Tau Ceti discrepancy',
      '12': 'Hidden channel',
      '16': 'Orders recovered',
      '20': 'The planted core',
      '22': 'The outer-galaxy trace',
      '25': 'Manual phase control',
      '26': 'Triangulum: M33 X-7',
      'other': 'Continue the network',
    });
    return '$_temp0';
  }

  @override
  String c_body(String sector) {
    String _temp0 = intl.Intl.selectLogic(sector, {
      '1':
          'The first extrasolar transmission has reached Haven. Anchors in other star systems can now contribute to Earth’s defense.',
      '5':
          'The expanded network is strengthening Earth’s defense. Unknown raiders are deliberately targeting its relays.',
      '8':
          'The energy received by Haven is slightly below Tau Ceti’s output. Keep the protection running while we investigate.',
      '12':
          'Analysis of accumulated transmission records reveals an undocumented outbound channel in Haven’s core. The Phase Anchors themselves are working correctly.',
      '16':
          'We intercepted enemy command records during the journey. The raiders are Severance, acting on orders from alien masters.',
      '20':
          'Kepler-90 records show the same core design in alien archives. The ancient OOPART found on Earth was planted there deliberately.',
      '22':
          'Comparing the Kepler-90 records with the energy trace reveals a route beyond our galaxy. Aliens sent the antimatter Earth to force us to gather energy; the necessary defense lets the core steal a share.',
      '25':
          'I have found a way to isolate the alien automatic controller. We will use your ship as Haven’s direct phase control point.',
      '26':
          'This is the aliens’ region of origin, Triangulum M33 X-7. Complete the local anchor grid, sync your ship at the Haven relay, defeat the core guardian, then return to the relay to reverse the transmission.',
      'other':
          'Establish colonies and keep the Phase Anchors transmitting. Earth still needs their energy.',
    });
    return '$_temp0';
  }

  @override
  String c_task(String task) {
    String _temp0 = intl.Intl.selectLogic(task, {
      'anchor': 'Build or repair a Phase Anchor',
      's1_0': 'Test transmission at the anchor',
      's5': 'Defeat the anchor raiders',
      's5_0': 'Verify restored transmission',
      's8_0': 'Measure anchor output',
      's8_1': 'Compare reception logs at Haven',
      's12_0': 'Inspect the hidden core circuit at Haven',
      's16': 'Defeat the command ship',
      's16_0': 'Recover orders from the wreck',
      's20_0': 'Investigate the core design in the alien ruins',
      's22_0': 'Survey the energy leak observation point',
      's22_1': 'Compare alien records at Haven',
      's25_0': 'Test automatic control isolation at Haven',
      'other': 'Expand the relay network',
    });
    return '$_temp0';
  }

  @override
  String get c_operate => 'Begin operation';

  @override
  String get c_finishOperation => 'Complete the regional operation';

  @override
  String get c_reverseResult =>
      'The ship and Haven remain synchronized. Energy from the colonies reverses through the network, driving antimatter Earth away.';

  @override
  String get c_severanceName => 'Severance';

  @override
  String get u_sharedShield => 'Shared shield';

  @override
  String get u_supportOffline => 'Haven support offline';

  @override
  String u_systemTrait(String trait) {
    String _temp0 = intl.Intl.selectLogic(trait, {
      'pirateNest': 'Pirate nest · Spawn interval ×0.7, bounties ×1.5',
      'richVeins': 'Rich veins · Colony ore ×2, mined ore ×1.5',
      'solarFlare': 'Solar flare · Colony credits ×1.25, shield regen ×0.5',
      'ionNebula':
          'Ion nebula · Skill cooldowns ×0.7, colony/station turret damage ×0.7',
      'gravityWell':
          'Gravity well · Top speed ×0.85, combat/mission rewards ×1.3',
      'tradeLane':
          'Trade lane · Ore sale price ×1.3, colony raid frequency ×1.3',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String g_traitIntro(String trait) {
    String _temp0 = intl.Intl.selectLogic(trait, {
      'pirateNest':
          'A pirate nest! Pirates arrive more often, but bounties are higher. Get ready to hunt!',
      'richVeins':
          'Rich veins! Colonies produce twice the ore, and asteroids yield 1.5 times as much. Start mining!',
      'solarFlare':
          'Strong solar flares! Colony credits rise, but shield regeneration is halved. Watch your defenses!',
      'ionNebula':
          'An ion nebula! Skill cooldowns and colony and station turret damage are both ×0.7. Support them with your skills!',
      'gravityWell':
          'A gravity well! Top speed is ×0.85, but combat and mission rewards are ×1.3. Pick a mission!',
      'tradeLane':
          'A trade lane! Ore sale prices and colony raid frequency are ×1.3. Trade while watching colony alerts!',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get u_specTitle => 'Specialization';

  @override
  String u_specName(String spec) {
    String _temp0 = intl.Intl.selectLogic(spec, {
      'industry': 'Industry',
      'mining': 'Mining',
      'fortress': 'Fortress',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String u_specEffect(String spec) {
    String _temp0 = intl.Intl.selectLogic(spec, {
      'industry': 'Credit output ×1.5',
      'mining': 'Ore output ×2.5',
      'fortress': 'Shield ×2 · turret damage ×1.5 · raids keep level',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String u_specLocked(int level) {
    return 'Specialization unlocks at Lv.$level';
  }

  @override
  String u_specInactive(int level) {
    return 'Active only at Lv.$level+';
  }

  @override
  String get u_specFree => 'Free';

  @override
  String get u_specChoose => 'Specialize';

  @override
  String get u_specSwitch => 'Switch';

  @override
  String g_dlgSpecUnlocked(String planet) {
    return '$planet reached Lv.5! You can now choose a specialization: Industry for credits, Mining for ore, Fortress for defense. Your first pick is free!';
  }

  @override
  String g_dlgRaidFortress(String planet) {
    return 'The $planet fortress held off the raid. Its level is safe!';
  }

  @override
  String u_bossName(String archetype) {
    String _temp0 = intl.Intl.selectLogic(archetype, {
      'fleet': '☠ Pirate Admiral',
      'devourer': '☠ Vein Devourer',
      'flare': '☠ Flare Gunship',
      'wraith': '☠ Ion Wraith',
      'gravity': '☠ Gravity Lord',
      'plunder': '☠ Plunder Freighter',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String g_dlgBossArchetype(String archetype) {
    String _temp0 = intl.Intl.selectLogic(archetype, {
      'fleet':
          'Warning! The Pirate Admiral keeps calling raider escorts. Hit the boss before they pile up!',
      'devourer':
          'Warning! The Vein Devourer scatters mines around itself. Shoot them down as you fight!',
      'flare':
          'Warning! The Flare Gunship: when you see the aim lines, a three-way laser follows. Dodge sideways!',
      'wraith':
          'Warning! The Ion Wraith vanishes every 4 seconds. Strike while it is visible!',
      'gravity':
          'Warning! The Gravity Lord pulls you in when you get close. Boost to break free!',
      'plunder':
          'Warning! The Plunder Freighter is fast and steals credits with every hit. Take it down to get them all back!',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get codex_title => 'Codex';

  @override
  String codex_tab(String tab) {
    String _temp0 = intl.Intl.selectLogic(tab, {
      'enemies': 'Enemies',
      'planets': 'Planets',
      'systems': 'Systems',
      'crew': 'Crew',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String codex_progress(int found, int total, int pct) {
    return '$found/$total found · $pct%';
  }

  @override
  String codex_enemy(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'scout': 'Scout',
      'raider': 'Raider',
      'bomber': 'Bomber',
      'sniper': 'Sniper',
      'jelly': 'Space Jellyfish',
      'boss': 'Pirate Boss',
      'commander': 'Invasion Commander',
      'missile': 'Missile Carrier',
      'mine': 'Mine Layer',
      'laser': 'Laser Lancer',
      'warden': 'Shield Warden',
      'phantom': 'Phantom',
      'medic': 'Repair Tender',
      'carrier': 'Drone Carrier',
      'juggernaut': 'Juggernaut',
      'arch_fleet': 'Pirate Admiral',
      'arch_devourer': 'Vein Devourer',
      'arch_flare': 'Flare Gunship',
      'arch_wraith': 'Ion Wraith',
      'arch_gravity': 'Gravity Lord',
      'arch_plunder': 'Plunder Freighter',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String codex_kills(int n) {
    return 'Defeated $n';
  }

  @override
  String codex_fromSystem(int n) {
    return 'From system $n';
  }

  @override
  String codex_planetKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'garden': 'Garden World',
      'desert': 'Desert World',
      'ice': 'Ice World',
      'lava': 'Lava World',
      'gas': 'Gas Giant',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get codex_planetHint => 'Settle a planet of this kind to fill it';

  @override
  String codex_settled(int n) {
    return 'Settled planets: $n';
  }

  @override
  String get codex_settledNone => 'No settled planets yet';

  @override
  String get codex_home => 'Home system · no special conditions';

  @override
  String get codex_unreached => 'Reach it through a warp gate';

  @override
  String get codex_crewHint => 'Recruit to fill';

  @override
  String get codex_rewards => 'Collection rewards';

  @override
  String codex_rewardCrew(String stars) {
    return '$stars crew';
  }

  @override
  String get codex_outfitName => 'Star Chart Explorer';

  @override
  String codex_newEntry(String name) {
    return 'New codex entry: $name';
  }

  @override
  String get codex_claimedLater => 'Rewards arrive when you start playing';

  @override
  String codex_pendingCrew(int n) {
    return 'Crew full: $n waiting for a free slot';
  }

  @override
  String r3_goalSettle(String planet) {
    return 'Settle $planet';
  }

  @override
  String r3_goalSettleNeed(String planet, int n) {
    return '💰$n more to settle $planet';
  }

  @override
  String r3_goalColonyUp(String planet, int level) {
    return '$planet colony to Lv.$level';
  }

  @override
  String r3_goalBuild(String planet, String building) {
    return '$planet: build $building';
  }

  @override
  String get r3_goalAssignCrew => 'Assign crew at a station';

  @override
  String get r3_goalWarp => 'Warp to the next system';

  @override
  String r3_goalDevelop(String sector) {
    return 'Stabilize $sector';
  }

  @override
  String get r3_goalMiniBoss => 'Defeat the Pirate Lieutenant';

  @override
  String get r3_miniBossName => 'Pirate Lieutenant';

  @override
  String get r3_miniBossArrive =>
      'The Lieutenant is here! Rookie captain, your ship is mine!';

  @override
  String get r3_miniBossHint =>
      'It\'s the Pirate Lieutenant! Your current ship can take him. Keep firing, and back off if your hull gets low!';

  @override
  String get r3_miniBossLose => 'N-no way… I\'m telling the boss!';

  @override
  String get r3_miniBossDown =>
      'You got the Lieutenant! I used the parts he dropped to upgrade your weapon for free!';

  @override
  String r3_weaponUp(int level) {
    return 'Weapon Lv.$level!';
  }

  @override
  String r3_star3Line(String name) {
    return 'Nice flying! HQ sent us a ★3 veteran. Say hi to $name!';
  }

  @override
  String get r3_crewAssigned => 'Assigned automatically — bonus active now';

  @override
  String get rift_title => 'Rift Run';

  @override
  String get rift_menuSub => 'Today\'s Rift · 3–5 min';

  @override
  String rift_locked(String step) {
    return 'Unlocks after “$step”';
  }

  @override
  String get rift_rules =>
      'Survive 10 waves and defeat the Rift Boss on wave 10. After each wave, pick a card to power up. Your main-game upgrades don\'t apply — everyone flies the same ship through the same daily rift.';

  @override
  String rift_bestLine(String score, int wave) {
    return 'Best $score pts · Wave $wave';
  }

  @override
  String get rift_noBest => 'No record yet';

  @override
  String rift_fullLeft(int n) {
    return 'Full rewards: $n runs left today';
  }

  @override
  String get rift_fullUsed => 'Today\'s full rewards used (now 1/4)';

  @override
  String get rift_start => 'Launch';

  @override
  String rift_wave(int n, int total) {
    return 'Wave $n/$total';
  }

  @override
  String rift_score(String score) {
    return 'Score $score';
  }

  @override
  String rift_incoming(int n, int s) {
    return 'Wave $n incoming in ${s}s';
  }

  @override
  String rift_bossIncoming(int s) {
    return 'Rift Boss arrives in ${s}s';
  }

  @override
  String rift_enemiesLeft(int n) {
    return '$n enemies left';
  }

  @override
  String get rift_collapse => 'Rift collapsing!';

  @override
  String rift_pickTitle(int n) {
    return 'Wave $n cleared! Pick a card';
  }

  @override
  String rift_cardLevel(int lv, int max) {
    return 'Lv $lv/$max';
  }

  @override
  String get rift_rarityCommon => 'Common';

  @override
  String get rift_rarityRare => 'Rare';

  @override
  String get rift_rarityEpic => 'Epic';

  @override
  String get rift_cardDamage => 'Firepower';

  @override
  String get rift_cardDamageDesc => 'Bullet damage +25%';

  @override
  String get rift_cardRapid => 'Rapid Fire';

  @override
  String get rift_cardRapidDesc => 'Fire interval −15%';

  @override
  String get rift_cardMultishot => 'Multishot';

  @override
  String get rift_cardMultishotDesc => 'One extra bullet per shot';

  @override
  String get rift_cardPierce => 'Piercing Rounds';

  @override
  String get rift_cardPierceDesc => 'Bullets pass through 1 more enemy';

  @override
  String get rift_cardHoming => 'Homing Missiles';

  @override
  String get rift_cardHomingDesc =>
      'Homing missiles launch automatically every few seconds';

  @override
  String get rift_cardRegen => 'Shield Regen';

  @override
  String get rift_cardRegenDesc => 'Restore 2 HP per second';

  @override
  String get rift_cardDrone => 'Combat Drone';

  @override
  String get rift_cardDroneDesc =>
      'A drone shoots nearby enemies. Stronger when stacked';

  @override
  String get rift_cardMagnet => 'Magnet';

  @override
  String get rift_cardMagnetDesc => 'Pulls rift shards from farther away';

  @override
  String get rift_cardCrit => 'Critical Hits';

  @override
  String get rift_cardCritDesc => '12% chance to deal 2.5× damage';

  @override
  String get rift_cardBlades => 'Spinning Blades';

  @override
  String get rift_cardBladesDesc => '+1 blade orbiting your ship';

  @override
  String get rift_cardHull => 'Reinforced Hull';

  @override
  String get rift_cardHullDesc => 'Max HP +35 and fully repaired';

  @override
  String get rift_cardEngine => 'Thrusters';

  @override
  String get rift_cardEngineDesc => 'Move speed +12%';

  @override
  String get rift_cardShockwave => 'Shockwave';

  @override
  String get rift_cardShockwaveDesc =>
      'Periodically damages all nearby enemies';

  @override
  String get rift_cardGuard => 'Barrier';

  @override
  String get rift_cardGuardDesc => 'Blocks one hit every few seconds';

  @override
  String get rift_cardVampire => 'Siphon';

  @override
  String get rift_cardVampireDesc => 'Restore 3 HP per enemy destroyed';

  @override
  String get rift_resultWin => 'Rift Conquered!';

  @override
  String get rift_resultLose => 'Shot down in the Rift';

  @override
  String get rift_resultGaveUp => 'Retreated from the Rift';

  @override
  String rift_reached(int n) {
    return 'Reached wave $n';
  }

  @override
  String get rift_newBest => 'New personal best!';

  @override
  String get rift_rewardTitle => 'Rewards for your main game';

  @override
  String get rift_rewardReduced => 'From the 4th run today, rewards are 1/4';

  @override
  String get rift_noSave =>
      'No main-game save, so credits and ore weren\'t added';

  @override
  String get rift_again => 'Try Again';

  @override
  String get rift_exit => 'Exit';

  @override
  String get rift_giveUp => 'Give up and exit';

  @override
  String get rift_giveUpNote =>
      'Leaving ends this run. You keep the score and rewards up to the wave you reached.';

  @override
  String get rift_tabPioneer => 'Pioneer Score';

  @override
  String get rift_tabRift => 'Rift';

  @override
  String get rift_boardHow =>
      'Ranked by your best Rift Run score this week. Everyone races the same daily rift with the same ship.';

  @override
  String rift_myWeek(String score, int wave) {
    return 'This week\'s best: $score pts · Wave $wave';
  }

  @override
  String get rift_noWeekRun => 'No Rift Run this week yet';

  @override
  String rift_waveShort(int n) {
    return 'W$n';
  }

  @override
  String get r4_calendarTitle => '7-Day Check-in';

  @override
  String r4_calendarStreak(int n) {
    return 'Day $n in a row';
  }

  @override
  String get r4_calendarHint =>
      'Miss a day and it starts over from day 1. Day 7 gives a check-in-only ship skin!';

  @override
  String get r4_calendarToday => 'Today';

  @override
  String get r4_calendarClaim => 'Claim today\'s reward';

  @override
  String get r4_calendarClaimed => 'Today\'s reward claimed!';

  @override
  String get r4_rewardOre => 'Ore crate';

  @override
  String get r4_rewardCredits => 'Credit bundle';

  @override
  String get r4_rewardCrew2 => '★2 crew';

  @override
  String get r4_rewardCrew3 => '★3 crew';

  @override
  String get r4_rewardSkin => 'Exclusive ship skin';

  @override
  String r4_tomorrow(String reward) {
    return 'Tomorrow: $reward';
  }

  @override
  String get r4_skinName => 'Starlight Streak';

  @override
  String get r4_attendanceOnly => '7-day check-in reward';

  @override
  String get r4_notifCalendarTitle => 'Your check-in reward is ready';

  @override
  String r4_notifCalendarBody(String reward) {
    return 'Today\'s check-in: $reward';
  }

  @override
  String get r4_notifExpeditionTitle => 'Expedition is back!';

  @override
  String get r4_notifExpeditionBody =>
      'Your crew brought back rewards. Collect them at a station.';

  @override
  String get r4_expTitle => 'Crew Expeditions';

  @override
  String r4_expSlots(int n, int max) {
    return '$n/$max teams';
  }

  @override
  String get r4_expHint =>
      'Send unassigned crew. Time keeps running even with the app closed.';

  @override
  String get r4_expPassSlot => 'Commander Pass: +1 team';

  @override
  String get r4_expNoIdle => 'No crew free. Unassign someone or recruit.';

  @override
  String r4_expHours(int h) {
    return '${h}h';
  }

  @override
  String get r4_expLuck => '⭐/★3 luck';

  @override
  String r4_expLeft(String time) {
    return '$time left';
  }

  @override
  String get r4_expClaim => 'Back! Collect';

  @override
  String get r4_expAway => 'On expedition';

  @override
  String r4_expGot(String rewards) {
    return 'Expedition loot: $rewards';
  }

  @override
  String r4_timeHm(int h, int m) {
    return '${h}h ${m}m';
  }

  @override
  String r4_timeM(int m) {
    return '${m}m';
  }

  @override
  String r4_ascendExpWarn(int n) {
    return '$n crew on expeditions will leave too, without rewards.';
  }
}
