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
  String get u_boostNote =>
      '💨 Boost (Shift / 💨 button) is equipped by default.';

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
    return 'Settled planets $colonies / $planets\nStations: $stations\nSector bonus: output x$mul\nOther sectors: 💰$other/s';
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
      'Ascending resets this universe (sectors, colonies, stations, ship upgrades, crew, credits)\nand grants honor, a permanent bonus.\nGems, cosmetics, ships and achievements are kept.';

  @override
  String u_ascendGain(int gain) {
    return 'Ascend now for +$gain honor!\n(The bigger your empire, the more you get)';
  }

  @override
  String get u_ascendLocked => 'Reach sector 4 to ascend.';

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
    return '$sector · Dev $dev%\n⚠ Threat $threat  🏛 $value';
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
  String get u_merchantE => 'Merchant (E)';

  @override
  String get u_nextSectorE => 'Next Sector (E)';

  @override
  String get u_prevSectorE => 'Prev Sector (E)';

  @override
  String u_gateLocked(int pct) {
    return '🔒 Opens at 100% development ($pct%)';
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
  String get u_spkAdvisor => 'Lt. Mina';

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
  String get u_resume => '▶ Resume';

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
    return 'Development $pct%';
  }

  @override
  String get u_nextSystemOpen => 'Next system open';

  @override
  String get u_opensAt100 => 'Opens at 100%';

  @override
  String get u_devHint => 'Raise every planet to Lv.3 for 100%';

  @override
  String get u_conqueredSystems => 'Conquered Systems (still producing)';

  @override
  String get u_unsettled => 'Unsettled';

  @override
  String get u_underRaid => 'Under raid';

  @override
  String u_unknownSector(int n) {
    return 'Unknown Sector $n';
  }

  @override
  String u_sectorDev(String name, int pct) {
    return '$name · Dev $pct%';
  }

  @override
  String get u_buildStationTitle => 'Build Station · Choose a Role';

  @override
  String get u_cost => 'Cost';

  @override
  String get u_build => 'Build';

  @override
  String get u_toNextSector => '🌀 To next sector';

  @override
  String get u_bossLocked => '🔒 Defeat the boss to open';

  @override
  String get u_toPrevSector => '🌀 To previous sector';

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
  String get m_continue => '▶ Continue';

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
  String get m_privacyTitle => 'Privacy Policy';

  @override
  String m_privacyBody(String email) {
    return 'Star Settlers stores game data (progress, settings) only on your device and does not collect personally identifiable information.\n\nIn-app purchases are processed by Google Play / App Store; payment details are never shared with the developer.\n\nIf rewarded ads are enabled, the ad provider (Google AdMob) may collect data such as advertising identifiers.\n\nContact: $email (Settings → Send Feedback to Developer)';
  }

  @override
  String get m_wipeTitle => 'Reset All Data';

  @override
  String get m_wipeDesc => 'Deletes all progress, gems and cosmetics';

  @override
  String get m_wipeConfirmTitle => 'Really reset everything?';

  @override
  String get m_wipeConfirmBody =>
      'This can\'t be undone. Purchases can be recovered with \"Restore Purchases\".';

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
  String get m_testMode => '🧪 Test mode: no real payments or ads';

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
      '1 ★4 legendary crew member (20%+ bonus, title, golden aura)\nAvailable after you start a game';

  @override
  String m_legendDesc(int count, int cap) {
    return '1 ★4 legendary crew member (20%+ bonus, title, golden aura)\nCrew $count/$cap';
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
      'Piercing shots: each shot pierces up to 2 enemies';

  @override
  String get g_shipAuroraAbility =>
      'Self-repair: heal 3% HP/sec after 3s without damage\nGuard: blocks 1 hit every 8s';

  @override
  String g_unlockSector(int n) {
    return 'Reach sector $n';
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
  String get g_achExplorerDesc => 'Reach sector 3';

  @override
  String get g_achVoyagerTitle => 'Voyager';

  @override
  String get g_achVoyagerDesc => 'Reach sector 6';

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
      'Captain! First, smash asteroids to gather ore.';

  @override
  String get g_storyAsteroidsLine1 =>
      'Move with the joystick and shoot with the fire button!';

  @override
  String get g_storyKillsTitle => 'Shoot down 3 pirates';

  @override
  String get g_storyKillsLine0 => 'Pirates on radar! Follow the red arrow.';

  @override
  String get g_storyKillsLine1 =>
      'Pirates? They\'re scrap metal before my ship!';

  @override
  String get g_storyColoniesTitle => 'Settle Terra Nova';

  @override
  String get g_storyColoniesLine0 =>
      'Try settling the nearby green planet Terra Nova. Get close and a Settle button appears.';

  @override
  String get g_storyColoniesLine1 =>
      'Colonies earn credits even while you relax!';

  @override
  String get g_storyShipLevelsTitle => 'Upgrade your ship at a station';

  @override
  String get g_storyShipLevelsLine0 =>
      'Head back to Haven Base and upgrade your ship. Stations repair you nearby, too.';

  @override
  String get g_storyCrewTitle => 'Recruit 1 crew member';

  @override
  String get g_storyCrewLine0 =>
      'Lonely out here? Recruit a buddy from the Crew tab in the station menu!';

  @override
  String get g_storyMissionsTitle => 'Complete 1 mission';

  @override
  String get g_storyMissionsLine0 =>
      'Take a job from the station mission board. The pay is sweet.';

  @override
  String get g_storyStationsTitle => 'Build a new station';

  @override
  String get g_storyStationsLine0 =>
      'Time to expand! Build a station in open space away from planets.';

  @override
  String get g_storyDevPercentTitle => 'System development 100%';

  @override
  String get g_storyDevPercentLine0 =>
      'Grow every planet to Lv.3 to open the next system. Check the System button at the top right!';

  @override
  String get g_storySectorTitle => 'Warp to the next system';

  @override
  String get g_storySectorLine0 =>
      'The warp gate is open! Head to the purple gate on the minimap.';

  @override
  String get g_storySectorLine1 => 'A whole new universe awaits!';

  @override
  String g_storyDevNTitle(int n) {
    return 'System $n development 100%';
  }

  @override
  String get g_storyDevNLine => 'Grow every planet in the new system to Lv.3!';

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
      'The gate is open. Shall we go deeper into space?';

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
  String get g_sector0 => 'Alpha Sanctum';

  @override
  String get g_sector1 => 'Beta Nebula';

  @override
  String get g_sector2 => 'Gamma Canyon';

  @override
  String get g_sector3 => 'Delta Pirate Zone';

  @override
  String get g_sector4 => 'Epsilon Abyss';

  @override
  String get g_sector5 => 'Zeta Ice Belt';

  @override
  String get g_sector6 => 'Eta Flame Cluster';

  @override
  String get g_sector7 => 'Theta Ghost Lane';

  @override
  String get g_sector8 => 'Iota Crown Nebula';

  @override
  String get g_sector9 => 'Kappa Black Hole';

  @override
  String get g_planet0 => 'Aquaris';

  @override
  String get g_planet1 => 'Rubia';

  @override
  String get g_planet2 => 'Frosta';

  @override
  String get g_planet3 => 'Volcano';

  @override
  String get g_planet4 => 'Jellio';

  @override
  String get g_planet5 => 'Solaris';

  @override
  String get g_planet6 => 'Momo Star';

  @override
  String get g_planet7 => 'Nebula';

  @override
  String get g_planet8 => 'Cassiope';

  @override
  String get g_planet9 => 'Aurora';

  @override
  String get g_planet10 => 'Durian';

  @override
  String get g_planet11 => 'Cinnamon';

  @override
  String get g_planet12 => 'Marshmallow';

  @override
  String get g_planet13 => 'Popcorn Star';

  @override
  String get g_planet14 => 'Lavender';

  @override
  String get g_planet15 => 'Emeraldia';

  @override
  String get g_planet16 => 'Crimson';

  @override
  String get g_planet17 => 'Polaris';

  @override
  String get g_planet18 => 'Vega';

  @override
  String get g_planet19 => 'Rigel';

  @override
  String get g_planet20 => 'Mira';

  @override
  String get g_planet21 => 'Topaz';

  @override
  String get g_planet22 => 'Cobalt';

  @override
  String get g_planet23 => 'Sapphire';

  @override
  String get g_planet24 => 'Onyx';

  @override
  String get g_planet25 => 'Peridot';

  @override
  String get g_planet26 => 'Mint Star';

  @override
  String get g_planet27 => 'Vanilla';

  @override
  String get g_planet28 => 'Caramel';

  @override
  String get g_planet29 => 'Pistachio';

  @override
  String get g_planet30 => 'Blueberry';

  @override
  String get g_planet31 => 'Lemon Star';

  @override
  String get g_planet32 => 'Cherry';

  @override
  String get g_planet33 => 'Melon';

  @override
  String get g_planet34 => 'Kiwi';

  @override
  String get g_planet35 => 'Mango Star';

  @override
  String get g_planet36 => 'Yuzu';

  @override
  String get g_planet37 => 'Grapefruit';

  @override
  String get g_planet38 => 'Pumpkin Star';

  @override
  String get g_planetTerraNova => 'Terra Nova';

  @override
  String g_unknownSector(int n) {
    return 'Unknown Sector $n';
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
  String get g_dlgWelcome => 'Welcome, Captain! I\'m Mina, your first officer.';

  @override
  String get g_dlgMissionsCancelled =>
      'Delivery and bounty missions from the last sector were canceled.';

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
  String get g_pirateBossLose => 'Argh! This sector… is yours…';

  @override
  String get g_pirateBossFlee => 'Argh! I\'ll remember this, Captain!';

  @override
  String get g_dlgSupplyCollected => 'Supply capsule recovered!';

  @override
  String get g_merchantBye => 'See you next time~ meow!';

  @override
  String get g_pirateRaidTaunt => 'This colony is ours now! Hahaha!';

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
  String get g_dlgBossWarning =>
      'Warning! The sector boss ship is approaching!';

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
    return 'Sector boss defeated! Reward 💰$credits';
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
  String g_pirateBossArrive(String sector) {
    return 'I rule $sector! Bring it on, little captain!';
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
  String get g_pirateAmbush0 => 'Hahaha! Drop your cargo!';

  @override
  String get g_pirateAmbush1 => 'This is our gang\'s turf!';

  @override
  String get g_pirateAmbush2 => 'Hand over those shiny credits!';

  @override
  String get g_pirateAmbush3 => 'Unlucky day, kid!';
}
