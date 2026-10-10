// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class L10nDe extends L10n {
  L10nDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Star Settlers';

  @override
  String get languageName => 'Deutsch';

  @override
  String get u_tabShip => 'Schiff';

  @override
  String get u_tabStation => 'Station';

  @override
  String get u_tabCrew => 'Crew';

  @override
  String get u_tabMission => 'Missionen';

  @override
  String get u_tabMarket => 'Markt';

  @override
  String u_upWeapon(int dmg) {
    return 'Schaden $dmg · Lv.3 doppelt · Lv.6 dreifach';
  }

  @override
  String u_upHull(int hp) {
    return 'Max. LP $hp';
  }

  @override
  String u_upEngine(int speed) {
    return 'Höchsttempo $speed';
  }

  @override
  String get u_upMissileIntro => 'Zielsuchende Raketen (Q-Taste / 🚀-Knopf)';

  @override
  String u_upMissile(int count, String cooldown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Raketen',
      one: '1 Rakete',
    );
    return '$_temp0 · Abklingzeit ${cooldown}s';
  }

  @override
  String get u_upShieldIntro =>
      'Schild, der jeden Schaden blockt (F-Taste / 🛡-Knopf)';

  @override
  String u_upShield(String duration, String cooldown) {
    return '${duration}s · Abklingzeit ${cooldown}s';
  }

  @override
  String get u_upDroneIntro =>
      'Umkreist dich, feuert automatisch und zieht Items an';

  @override
  String u_upDrone(int dmg, String interval) {
    return 'Schaden $dmg · feuert alle ${interval}s';
  }

  @override
  String u_upMagnet(int range, String power) {
    return 'Zieht Credits & Erz an · Reichweite $range · Kraft x$power';
  }

  @override
  String get u_equip => 'Ausrüsten';

  @override
  String get u_hangarSection => '🛸 Hangar';

  @override
  String get u_viewLarge => 'Ansehen';

  @override
  String get u_hp => 'LP';

  @override
  String get u_speed => 'Tempo';

  @override
  String get u_attack => 'Angriff';

  @override
  String get u_fireRate => 'Feuerrate';

  @override
  String get u_ore => 'Erz';

  @override
  String get u_crit => 'Krit';

  @override
  String get u_boarded => 'An Bord';

  @override
  String get u_board => 'Einsteigen';

  @override
  String get u_boardNow => 'Einsteigen';

  @override
  String get u_gemsOnly => 'Nur mit Edelsteinen';

  @override
  String u_unlockOrGems(String condition) {
    return 'Freischalten: $condition oder Edelsteine';
  }

  @override
  String u_unlock(String condition) {
    return 'Freischalten: $condition';
  }

  @override
  String u_durability(int hp, int max) {
    return 'Hülle $hp / $max';
  }

  @override
  String get u_habitat => 'Wohnmodul';

  @override
  String u_habitatDesc(String rate, int hp) {
    return 'Einkommen 💰$rate/s · Hülle $hp';
  }

  @override
  String get u_turret => 'Abwehrgeschütz';

  @override
  String get u_turretIntro => 'Schießt automatisch auf Piraten';

  @override
  String u_turretDesc(int dmg, int range) {
    return 'Schaden $dmg · Reichweite $range';
  }

  @override
  String get u_baseUpgrade => 'Basis-Ausbau';

  @override
  String u_baseDesc(int dmg, int range, int hp) {
    return 'Laser $dmg · Reichweite $range · Hülle $hp';
  }

  @override
  String u_disabledSec(int sec) {
    return 'Außer Betrieb ${sec}s';
  }

  @override
  String u_sectorStatus(String sector) {
    return 'Status: $sector';
  }

  @override
  String u_sectorStats(
    int colonies,
    int planets,
    int stations,
    String mul,
    String other,
  ) {
    return 'Besiedelte Planeten $colonies / $planets\nStationen: $stations\nSektorbonus: Produktion x$mul\nAndere Sektoren: 💰$other/s';
  }

  @override
  String get u_legendaryGet => '🌟 Legendär! 🌟';

  @override
  String get u_rareGet => '✨ Seltenes Crewmitglied! ✨';

  @override
  String get u_newCrew => 'Neues Crewmitglied!';

  @override
  String get u_great => 'Super!';

  @override
  String u_crewHeader(int count, int cap, int assigned, int slots) {
    return 'Crew $count/$cap · Eingeteilt $assigned/$slots';
  }

  @override
  String u_recruit(int cost) {
    return 'Anwerben 💰$cost';
  }

  @override
  String u_recruitPremium(int cost) {
    return 'Premium-Anwerbung ⭐$cost';
  }

  @override
  String u_recruitLegendary(int cost) {
    return '🌟 Garantiert legendär ⭐$cost';
  }

  @override
  String u_recruitOdds(String normal, String premium) {
    return 'Chancen · Anwerben: $normal\nPremium-Anwerbung: $premium\nGarantiert legendär: ★4 100%';
  }

  @override
  String u_slotMax(int n) {
    return 'Crew-Plätze MAX ($n)';
  }

  @override
  String u_slotBuy(int price) {
    return 'Crew-Platz +1 ⭐$price';
  }

  @override
  String u_rosterMax(int n) {
    return 'Kapazität MAX ($n)';
  }

  @override
  String u_rosterBuy(int size, int price) {
    return 'Kapazität +$size ⭐$price';
  }

  @override
  String get u_noCrew =>
      'Noch keine Crew. Wirb welche an und teile sie deinem Schiff zu!';

  @override
  String get u_unassign => 'Abziehen';

  @override
  String get u_assign => 'Einteilen';

  @override
  String get u_dismiss => 'Entlassen';

  @override
  String get u_dismissCrewTitle => 'Crewmitglied entlassen';

  @override
  String u_dismissCrewBody(String name) {
    return '$name gehen lassen? Das kann nicht rückgängig gemacht werden.';
  }

  @override
  String get u_missionDeliverHint => 'Flieg zum Ziel (gelber Pfeil)';

  @override
  String get u_missionBountyHint => 'Finde und besiege das Ziel (gelber Pfeil)';

  @override
  String u_reward(String rewards) {
    return 'Belohnung $rewards';
  }

  @override
  String u_activeMissions(int n) {
    return 'Aktiv ($n/3)';
  }

  @override
  String get u_noActiveMissions => 'Keine aktiven Missionen.';

  @override
  String get u_abandon => 'Abbrechen';

  @override
  String u_missionBoard(int sec) {
    return 'Missionsbrett · neu in ${sec}s';
  }

  @override
  String get u_accept => 'Annehmen';

  @override
  String get u_priceHigh => '📈 Hoch! Jetzt verkaufen';

  @override
  String get u_priceLow => '📉 Niedrig… lieber warten';

  @override
  String get u_priceNormal => '➡ Normal';

  @override
  String get u_orePrice => 'Erzpreis';

  @override
  String get u_sell100 => '100 verkaufen';

  @override
  String get u_sellHalf => 'Hälfte verkaufen';

  @override
  String get u_sellAll => 'Alles verkaufen';

  @override
  String get u_marketTip =>
      'Preise steigen und fallen mit der Zeit. Teuer verkaufen!';

  @override
  String get u_gemExchange => '⭐ Edelstein-Tausch';

  @override
  String get u_creditPack => 'Credit-Paket';

  @override
  String get u_exchange => 'Tauschen';

  @override
  String get u_openShop => '⭐ Shop öffnen';

  @override
  String u_achievementDone(String title, int gems) {
    return '🏆 Erfolg: $title! Hol dir ⭐$gems unter Menü > Erfolge.';
  }

  @override
  String get u_cannotDo => 'Nicht genug Ressourcen oder gerade nicht möglich.';

  @override
  String get u_welcomeBack => 'Willkommen zurück, Captain!';

  @override
  String u_offlineHm(int h, int m) {
    return 'Während deiner $h Std. $m Min. Abwesenheit\nhaben deine Kolonien fleißig gearbeitet!';
  }

  @override
  String u_offlineM(int m) {
    return 'Während deiner $m Min. Abwesenheit\nhaben deine Kolonien fleißig gearbeitet!';
  }

  @override
  String get u_passOfflineHint => 'Kommandanten-Pass: bis zu 8 Std. + auto 2x';

  @override
  String get u_collect => 'Einsammeln';

  @override
  String get u_adLoading =>
      'Werbung wird geladen. Bitte versuch es gleich noch mal.';

  @override
  String get u_adLoadingRetry =>
      'Werbung wird geladen. Bitte gleich noch mal tippen.';

  @override
  String get u_collectDouble => '2x einsammeln 👑';

  @override
  String get u_adDouble => '📺 Werbung für 2x';

  @override
  String get u_galaxyHonor => '🌌 Galaktische Ehre';

  @override
  String u_honorStatus(int honor, int ascensions) {
    return 'Ehre $honor (${ascensions}x aufgestiegen)';
  }

  @override
  String u_honorBonus(int income, int attack) {
    return 'Einkommen +$income% · Schaden +$attack%';
  }

  @override
  String get u_ascendExplain =>
      'Der Aufstieg setzt dieses Universum zurück (Sektoren, Kolonien, Stationen, Schiffs-Upgrades, Crew, Credits)\nund gibt dir Ehre, einen dauerhaften Bonus.\nEdelsteine, Kosmetik, Schiffe und Erfolge bleiben erhalten.';

  @override
  String u_ascendGain(int gain) {
    return 'Steig jetzt auf für +$gain Ehre!\n(Je größer dein Imperium, desto mehr bekommst du)';
  }

  @override
  String get u_ascendLocked => 'Erreiche Sektor 4, um aufzusteigen.';

  @override
  String get u_close => 'Schließen';

  @override
  String u_ascendBtn(int gain) {
    return 'Aufsteigen (+$gain)';
  }

  @override
  String get u_ascendConfirmTitle => 'Wirklich aufsteigen?';

  @override
  String get u_ascendConfirmBody =>
      'Dein aktuelles Universum wird zurückgesetzt. Das kann nicht rückgängig gemacht werden.';

  @override
  String get u_ascend => 'Aufsteigen';

  @override
  String u_shieldBroken(String name) {
    return '$name zerstört';
  }

  @override
  String u_hudSector(String sector, int dev, String threat, String value) {
    return '$sector · Entw. $dev%\n⚠ Gefahr $threat  🏛 $value';
  }

  @override
  String u_baseDisabled(int sec) {
    return 'Basis aus ${sec}s';
  }

  @override
  String u_baseHp(int pct) {
    return 'Basis $pct%';
  }

  @override
  String get u_merchantE => 'Händlerin (E)';

  @override
  String get u_nextSectorE => 'Nächster Sektor (E)';

  @override
  String get u_prevSectorE => 'Vorh. Sektor (E)';

  @override
  String u_gateLocked(int pct) {
    return '🔒 Öffnet bei 100% Entwicklung ($pct%)';
  }

  @override
  String u_settle(String name) {
    return '$name besiedeln';
  }

  @override
  String u_manageE(String name) {
    return '$name verwalten (E)';
  }

  @override
  String get u_buildStation => 'Station bauen';

  @override
  String get u_fire => 'FEUER';

  @override
  String get u_equipAtStation =>
      'Du kannst es im Schiff-Tab der Station ausrüsten!';

  @override
  String get u_shotDown => '💥 Du wurdest abgeschossen!';

  @override
  String u_autoRespawn(int sec) {
    return 'Automatischer Neustart an der Basis in ${sec}s';
  }

  @override
  String get u_reviveFree => '👑 Hier wiederbeleben (gratis)';

  @override
  String get u_reviveAd => '📺 Werbung ansehen und hier wiederbeleben';

  @override
  String get u_reviveGems => 'Hier wiederbeleben für ⭐10';

  @override
  String u_respawnBase(int pct) {
    return '🏠 Neustart an der Basis ($pct% Credits verlieren)';
  }

  @override
  String get u_spkCaptain => 'Captain';

  @override
  String get u_spkPirate => 'Pirat';

  @override
  String get u_spkAdvisor => 'Lt. Mina';

  @override
  String get u_spkMerchant => 'Händlerin Nyang';

  @override
  String get u_paused => 'Pause';

  @override
  String u_pauseStats(
    String sector,
    int kills,
    int crew,
    int colonies,
    int stations,
    int missions,
  ) {
    return '$sector · Abschüsse $kills · Crew $crew\nKolonien $colonies · Stationen $stations · Missionen $missions';
  }

  @override
  String get u_resume => '▶︎ Weiter';

  @override
  String get u_shop => '⭐ Shop';

  @override
  String get u_achievements => '🏆 Erfolge';

  @override
  String get u_dailyQuests => '📅 Tagesquests';

  @override
  String get u_myPlanet => '🌍 Mein Planet';

  @override
  String get u_ascendMenu => '🌌 Galaktische Ehre (Aufstieg)';

  @override
  String get u_settings => '⚙ Einstellungen';

  @override
  String get u_saveAndQuit => '💾 Speichern & zum Titel';

  @override
  String get u_keyboardHelp =>
      'Tasten: WASD bewegen · Leertaste feuern · Q Rakete · F Schild · Shift Boost\nE interagieren · B Station bauen · Esc Menü';

  @override
  String get u_recharging => 'Lädt auf';

  @override
  String get u_tutDome => 'Schild\ndrinnen sicher';

  @override
  String get u_tutLevelUp => 'Levelaufstieg\nEinkommen·Gebäude↑';

  @override
  String get u_tutTurret => 'Geschütz';

  @override
  String get u_tutRepair => 'Reparieren';

  @override
  String get u_tutRaid => 'Überfälle stoppen';

  @override
  String get u_gotIt => 'Verstanden';

  @override
  String u_damage(int dmg) {
    return 'Schaden $dmg';
  }

  @override
  String u_oreRate(String rate) {
    return 'Erz +$rate/s';
  }

  @override
  String u_incomePct(int pct) {
    return 'Einkommen +$pct%';
  }

  @override
  String u_repairRate(int hp) {
    return 'LP +$hp/s';
  }

  @override
  String u_shieldPlus(int amount) {
    return 'Schild +$amount';
  }

  @override
  String u_systemTitle(String sector, int n) {
    return '$sector · System $n';
  }

  @override
  String u_systemInfo(String threat, String mul) {
    return 'Gefahr $threat · Ressourcen x$mul';
  }

  @override
  String u_development(int pct) {
    return 'Entwicklung $pct%';
  }

  @override
  String get u_nextSystemOpen => 'Nächstes System offen';

  @override
  String get u_opensAt100 => 'Öffnet bei 100%';

  @override
  String get u_devHint => 'Bring jeden Planeten auf Lv.3 für 100%';

  @override
  String get u_conqueredSystems => 'Eroberte Systeme (produzieren weiter)';

  @override
  String get u_unsettled => 'Unbesiedelt';

  @override
  String get u_underRaid => 'Wird überfallen';

  @override
  String u_unknownSector(int n) {
    return 'Unbekannter Sektor $n';
  }

  @override
  String u_sectorDev(String name, int pct) {
    return '$name · Entw. $pct%';
  }

  @override
  String get u_buildStationTitle => 'Station bauen · Rolle wählen';

  @override
  String get u_cost => 'Kosten';

  @override
  String get u_build => 'Bauen';

  @override
  String get u_toNextSector => '🌀 Zum nächsten Sektor';

  @override
  String get u_bossLocked => '🔒 Besiege den Boss zum Öffnen';

  @override
  String get u_toPrevSector => '🌀 Zum vorherigen Sektor';

  @override
  String get u_raidAlert => '⚠ Überfall!';

  @override
  String u_rechargePct(int pct) {
    return 'Aufladen $pct%';
  }

  @override
  String u_merchantLabel(int sec) {
    return '🛒 Reisende Händlerin (${sec}s)';
  }

  @override
  String get u_supplyPod => '📦 Versorgungskapsel';

  @override
  String u_sectorBoss(String sector) {
    return '☠ Boss von $sector';
  }

  @override
  String get u_pirateBoss => '☠ Piratenboss';

  @override
  String get u_merchantName => 'Nyang, reisende Händlerin';

  @override
  String u_merchantLeaves(int sec, String credits) {
    return 'Geht in ${sec}s · 💰$credits';
  }

  @override
  String get u_rareCrewOffer => 'Seltene Crew zu haben';

  @override
  String get u_crewSoldOut => 'Die Crew von heute ist schon weg, miau!';

  @override
  String get u_gemTrade => 'Edelstein-Tausch (max. 3)';

  @override
  String u_gemTradeRow(int price, int left) {
    return '💰$price → ⭐5  (noch $left)';
  }

  @override
  String get u_convert => 'Tauschen';

  @override
  String get u_potions => 'Boost-Tränke (2x Dauer)';

  @override
  String get u_notEnoughGems => 'Nicht genug Edelsteine';

  @override
  String get u_buyConfirmTitle => 'Kauf bestätigen';

  @override
  String u_buyShipConfirm(String ship, String price) {
    return '$price für die $ship ausgeben?';
  }

  @override
  String u_shipBought(String ship) {
    return '$ship erhalten! Du bist jetzt an Bord.';
  }

  @override
  String get u_premiumShips => 'Premium-Schiffe';

  @override
  String get u_hangarTitle => 'Hangar';

  @override
  String u_buyGems(int price) {
    return 'Kaufen ⭐$price';
  }

  @override
  String get u_premium => 'Premium';

  @override
  String get u_ok => 'OK';

  @override
  String get u_cancel => 'Abbrechen';

  @override
  String get m_ok => 'OK';

  @override
  String get m_cancel => 'Abbrechen';

  @override
  String get m_close => 'Schließen';

  @override
  String get m_claim => 'Abholen';

  @override
  String m_claimGems(int gems) {
    return '⭐$gems abholen';
  }

  @override
  String get m_done => '✅ Erledigt';

  @override
  String get m_notEnoughGems => 'Nicht genug Edelsteine';

  @override
  String get m_restorePurchases => 'Käufe wiederherstellen';

  @override
  String get m_restoreDone => 'Käufe überprüft';

  @override
  String get m_buyConfirmTitle => 'Kauf bestätigen';

  @override
  String m_spendGemsConfirm(String price) {
    return '$price ausgeben?';
  }

  @override
  String get m_loginTitle => '📅 Tägliche Anmeldung';

  @override
  String get m_loginWelcome => 'Willkommen zurück, Captain!';

  @override
  String get m_loginStreakHint => 'Melde dich 7 Tage in Folge an für ⭐50!';

  @override
  String get m_newGameTitle => 'Neues Spiel';

  @override
  String get m_newGameBody =>
      'Dein aktueller Fortschritt wird gelöscht.\n(Edelsteine, Kosmetik, Erfolge und Käufe bleiben erhalten.) Fortfahren?';

  @override
  String get m_start => 'Starten';

  @override
  String get m_loadFailed => 'Spielstand konnte nicht geladen werden.';

  @override
  String m_honorLine(int honor, int income, int attack) {
    return '🌌 Galaktische Ehre $honor · Einkommen +$income% · Angriff +$attack%';
  }

  @override
  String get m_continue => 'Fortsetzen';

  @override
  String get m_newGame => '✨ Neues Spiel';

  @override
  String get m_menuHome => 'Mein Planet';

  @override
  String get m_menuShop => 'Shop';

  @override
  String get m_menuQuest => 'Quests';

  @override
  String get m_menuAchievements => 'Erfolge';

  @override
  String get m_menuSettings => 'Optionen';

  @override
  String m_achievementsTitle(int done, int total) {
    return '🏆 Erfolge ($done/$total)';
  }

  @override
  String get m_dailyTitle => '📅 Tagesquests';

  @override
  String m_dailyReset(int hours, int minutes) {
    return 'Zurücksetzung in $hours Std. $minutes Min.';
  }

  @override
  String get m_dailyBonusTitle => '🎁 Komplett-Bonus';

  @override
  String get m_dailyBonusDesc => 'Hol dir alle 3 heutigen Quests ab';

  @override
  String get m_settingsTitle => '⚙ Einstellungen';

  @override
  String get m_settingsSound => 'Soundeffekte';

  @override
  String get m_settingsMusic => 'Musik';

  @override
  String get m_settingsNotify => 'Erinnerungen';

  @override
  String get m_settingsNotifyDesc =>
      'Wir sagen Bescheid, wenn das Kolonielager voll ist';

  @override
  String get m_settingsHaptics => 'Vibration';

  @override
  String get m_settingsLanguage => 'Sprache';

  @override
  String get m_languageSystem => 'Gerätesprache verwenden';

  @override
  String get m_privacyTitle => 'Datenschutzerklärung';

  @override
  String m_privacyBody(String email) {
    return 'Star Settlers speichert Spieldaten (Fortschritt, Einstellungen) nur auf deinem Gerät und erhebt keine personenbezogenen Daten.\n\nIn-App-Käufe werden von Google Play / App Store abgewickelt; Zahlungsdaten werden nie an den Entwickler weitergegeben.\n\nWenn Belohnungswerbung aktiv ist, kann der Werbeanbieter (Google AdMob) Daten wie Werbe-IDs erheben.\n\nKontakt: $email (Einstellungen → Feedback an Entwickler senden)';
  }

  @override
  String get m_wipeTitle => 'Alle Daten zurücksetzen';

  @override
  String get m_wipeDesc => 'Löscht allen Fortschritt, Edelsteine und Kosmetik';

  @override
  String get m_wipeConfirmTitle => 'Wirklich alles zurücksetzen?';

  @override
  String get m_wipeConfirmBody =>
      'Das kann nicht rückgängig gemacht werden. Käufe lassen sich mit „Käufe wiederherstellen“ zurückholen.';

  @override
  String get m_wipeOk => 'Zurücksetzen';

  @override
  String get m_feedbackTitle => 'Feedback an Entwickler senden';

  @override
  String get m_feedbackDesc =>
      'Bugs, Ideen, alles! Gerät und App-Version werden automatisch eingetragen.';

  @override
  String m_noMailApp(String email) {
    return 'Keine Mail-App gefunden. Bitte schreib an $email.';
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
  String get m_buyThanks => 'Kauf abgeschlossen! Danke 💜';

  @override
  String get m_adLoading =>
      'Werbung wird geladen. Bitte versuch es gleich noch mal.';

  @override
  String m_buyShipConfirm(String ship, String price) {
    return '$price für $ship ausgeben?';
  }

  @override
  String m_shipAcquired(String ship) {
    return '$ship erhalten! Du bist jetzt an Bord';
  }

  @override
  String get m_tabGems => 'Edelsteine';

  @override
  String get m_tabPacks => 'Pakete';

  @override
  String get m_tabPremiumShips => 'Premium-Schiffe';

  @override
  String get m_tabSkins => 'Schiff-Skins';

  @override
  String get m_tabOutfits => 'Captain-Outfits';

  @override
  String get m_tabFree => 'Gratis-Edelsteine';

  @override
  String get m_testMode => '🧪 Testmodus: keine echten Zahlungen oder Werbung';

  @override
  String get m_owned => 'Im Besitz';

  @override
  String get m_boarded => 'Im Flug';

  @override
  String get m_gemsInfo =>
      'Edelsteine kannst du für Kosmetik, Premium-Anwerbung, Sofort-Wiederbelebung und Credit-Tausch nutzen.\nDu verdienst sie auch beim Spielen (Erfolge, Anmeldungen, Bosse, Versorgungskapseln).';

  @override
  String get m_crewSection => '👩‍🚀 Crew (Edelsteine)';

  @override
  String get m_premiumSection => '🛸 Premium-Schiffe';

  @override
  String get m_premiumDesc =>
      'Spezielle Jäger nur für Edelsteine, jeder mit einer einzigartigen Fähigkeit.';

  @override
  String get m_viewLarge => 'Groß ansehen';

  @override
  String get m_premiumHangarHint =>
      'Du kannst Schiffe auch im Hangar kaufen und wechseln (Station → Schiff-Tab).';

  @override
  String get m_legendTitle => 'Garantiert legendäre Anwerbung';

  @override
  String get m_legendDescNoGame =>
      '1 legendäres ★4-Crewmitglied (20%+ Bonus, Titel, goldene Aura)\nVerfügbar, sobald du ein Spiel startest';

  @override
  String m_legendDesc(int count, int cap) {
    return '1 legendäres ★4-Crewmitglied (20%+ Bonus, Titel, goldene Aura)\nCrew $count/$cap';
  }

  @override
  String m_crewJoined(String stars, String name) {
    return '$stars $name ist dabei!';
  }

  @override
  String get m_slotTitle => 'Crew-Platz +1';

  @override
  String m_slotDesc(int slots) {
    return 'Gleichzeitig einteilbare Crew · Aktuell $slots';
  }

  @override
  String m_rosterTitle(int n) {
    return 'Crew-Kapazität +$n';
  }

  @override
  String m_rosterDesc(int cap, int max) {
    return 'Crewmitglieder, die du behalten kannst · Aktuell $cap (max. $max)';
  }

  @override
  String m_crewOdds(String odds) {
    return 'Premium-Chancen: $odds · Garantiert legendär: ★4 100%';
  }

  @override
  String get m_equipped => 'Ausgerüstet';

  @override
  String get m_equip => 'Ausrüsten';

  @override
  String get m_passOnly => 'Nur Kommandanten-Pass';

  @override
  String get m_starterOnly => 'Nur Starterpaket';

  @override
  String get m_adSection => '📺 Gratis-Edelsteine per Werbung';

  @override
  String m_adInfo(int perDay, int left) {
    return '${perDay}x pro Tag, je ⭐5 · heute noch $left';
  }

  @override
  String get m_adClaimPremium => '⭐5 abholen (Kommandanten-Pass: ohne Werbung)';

  @override
  String get m_adWatch => 'Werbung für ⭐5';

  @override
  String m_loginStreak(int days) {
    return 'Anmeldeserie: Tag $days';
  }

  @override
  String m_dayN(int day) {
    return 'Tag $day';
  }

  @override
  String get m_notEnoughResources => 'Nicht genug Ressourcen';

  @override
  String m_emptyLot(int n) {
    return 'Freies Grundstück #$n · Bauen';
  }

  @override
  String get m_buildInGameOnly =>
      'Bauen geht während eines Spiels (Menü → Mein Planet). Credits und Erz kommen aus deinem aktuellen Universum.';

  @override
  String m_heldAll(String credits, String ore, int gems) {
    return 'Besitz 💰$credits  💎$ore  ⭐$gems';
  }

  @override
  String m_held(String credits, String ore) {
    return 'Besitz 💰$credits  💎$ore';
  }

  @override
  String m_currentEffect(String effect) {
    return 'Aktuell: $effect';
  }

  @override
  String m_nextLevel(String effect) {
    return 'Nächstes Level: $effect';
  }

  @override
  String m_upgrade(String cost) {
    return 'Verbessern $cost';
  }

  @override
  String get m_maxLevel => '🌟 Max. Level';

  @override
  String get m_planetName => 'Planetenname';

  @override
  String get m_decorateTitle => '🎨 Planet gestalten';

  @override
  String get m_planetRing => 'Planetenring';

  @override
  String get m_giftInGameOnly =>
      'Geschenke kannst du während eines Spiels abholen';

  @override
  String get m_giftTitle => '🎁 Planetengeschenk';

  @override
  String m_giftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ein Geschenk von deinen $count Bewohnern!',
      one: 'Ein Geschenk von deinem 1 Bewohner!',
    );
    return '$_temp0';
  }

  @override
  String get m_giftThanks => 'Danke!';

  @override
  String m_planetStatus(int level, int residents, int built, int slots) {
    return 'Planet Lv.$level · $residents Bewohner · Gebäude $built/$slots';
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
    return 'Dauerbonus · Einkommen +$income%  Erz +$ore%  Angriff +$attack%  LP +$hp%  Abklingzeit -$cooldown%  Offline $offline%';
  }

  @override
  String get m_planetHint =>
      'Wische, um den Planeten zu drehen, tippe ein Grundstück zum Bauen';

  @override
  String get m_giftClaim => '🎁 Geschenk abholen';

  @override
  String m_giftWait(int hours, int minutes) {
    return '🎁 Geschenk in $hours Std. $minutes Min.';
  }

  @override
  String m_planetLevelUp(int level, String cost) {
    return '🌍 Planet Lv.$level (+2 Grundstücke) $cost';
  }

  @override
  String get g_shipScoutName => 'Scout';

  @override
  String get g_shipInterceptorName => 'Abfangjäger';

  @override
  String get g_shipFortressName => 'Festung';

  @override
  String get g_shipProspectorName => 'Prospektor';

  @override
  String get g_shipPhantomName => 'Phantom';

  @override
  String get g_shipNovaName => 'Nova-Drache';

  @override
  String get g_shipAuroraName => 'Aurora';

  @override
  String get g_shipScoutDesc => 'Ein ausgewogenes Startschiff';

  @override
  String get g_shipInterceptorDesc =>
      'Schnell und feuert rasch, aber dünn gepanzert';

  @override
  String get g_shipFortressDesc => 'Langsam, aber zäh und schlägt hart zu';

  @override
  String get g_shipProspectorDesc => 'Erz +50%, zieht Items von weit her an';

  @override
  String get g_shipPhantomDesc => '25% Chance auf 2,5x kritische Treffer';

  @override
  String get g_shipNovaDesc =>
      'Premium-Jäger, dessen Schüsse Feinde durchbohren';

  @override
  String get g_shipAuroraDesc =>
      'Premium-Wächter, der sich repariert und eine Barriere trägt';

  @override
  String get g_shipNovaAbility =>
      'Durchschlag: Jeder Schuss durchbohrt bis zu 2 Feinde';

  @override
  String get g_shipAuroraAbility =>
      'Selbstreparatur: 3% LP/s nach 3s ohne Schaden\nSchutz: blockt alle 8s einen Treffer';

  @override
  String g_unlockSector(int n) {
    return 'Sektor $n erreichen';
  }

  @override
  String g_unlockBosses(int n) {
    return '$n Piratenbosse besiegen';
  }

  @override
  String g_unlockOre(int n) {
    return '$n Erz sammeln';
  }

  @override
  String get g_skinDefault => 'Standard-Scout';

  @override
  String get g_skinCrimson => 'Roter Komet';

  @override
  String get g_skinMint => 'Minz-Schoko';

  @override
  String get g_skinStealth => 'Tarnschwarz';

  @override
  String get g_skinNeon => 'Neonpink';

  @override
  String get g_skinRainbow => 'Regenbogentraum';

  @override
  String get g_skinGalaxy => 'Galaxie';

  @override
  String get g_skinGold => 'Königsgold';

  @override
  String get g_outfitDefault => 'Standard-Raumanzug';

  @override
  String get g_outfitCat => 'Kätzchenhelm';

  @override
  String get g_outfitBunny => 'Hasenohren';

  @override
  String get g_outfitAlien => 'Alien-Fühler';

  @override
  String get g_outfitFlower => 'Blumenspange';

  @override
  String get g_outfitHat => 'Kapitänsmütze';

  @override
  String get g_outfitCrown => 'Galaxiekrone';

  @override
  String get g_crewRoleGunner => 'Schütze';

  @override
  String get g_crewEffectGunner => 'Angriff';

  @override
  String get g_crewRoleEngineer => 'Ingenieur';

  @override
  String get g_crewEffectEngineer => 'Max. LP & Reparatur';

  @override
  String get g_crewRolePilot => 'Pilot';

  @override
  String get g_crewEffectPilot => 'Tempo';

  @override
  String get g_crewRoleTrader => 'Händler';

  @override
  String get g_crewEffectTrader => 'Credit-Einkommen';

  @override
  String get g_crewRoleMiner => 'Bergmann';

  @override
  String get g_crewEffectMiner => 'Erzertrag';

  @override
  String get g_crewRoleScientist => 'Wissenschaftler';

  @override
  String get g_crewEffectScientist => 'Abklingzeit';

  @override
  String get g_crewName0 => 'Brötchen';

  @override
  String get g_crewName1 => 'Coco';

  @override
  String get g_crewName2 => 'Sternchen';

  @override
  String get g_crewName3 => 'Tofu';

  @override
  String get g_crewName4 => 'Böhnchen';

  @override
  String get g_crewName5 => 'Lulu';

  @override
  String get g_crewName6 => 'Haru';

  @override
  String get g_crewName7 => 'Poppy';

  @override
  String get g_crewName8 => 'Mimi';

  @override
  String get g_crewName9 => 'Dori';

  @override
  String get g_crewName10 => 'Flauschi';

  @override
  String get g_crewName11 => 'Falter';

  @override
  String get g_crewName12 => 'Schoko';

  @override
  String get g_crewName13 => 'Gerste';

  @override
  String get g_crewName14 => 'Wölkchen';

  @override
  String get g_crewName15 => 'Tröpfchen';

  @override
  String get g_crewName16 => 'Tori';

  @override
  String get g_crewName17 => 'Happy';

  @override
  String get g_crewName18 => 'Knödel';

  @override
  String get g_crewName19 => 'Mochi';

  @override
  String get g_crewName20 => 'Latte';

  @override
  String get g_crewName21 => 'Keks';

  @override
  String get g_crewName22 => 'Gelee';

  @override
  String get g_crewName23 => 'Watte';

  @override
  String get g_crewName24 => 'Mango';

  @override
  String get g_crewName25 => 'Pflaume';

  @override
  String get g_crewName26 => 'Nüsschen';

  @override
  String get g_crewName27 => 'Klecks';

  @override
  String get g_crewName28 => 'Bambi';

  @override
  String get g_crewName29 => 'Käse';

  @override
  String get g_crewLegend0 => 'Galaxiewächter';

  @override
  String get g_crewLegend1 => 'Sternenheld';

  @override
  String get g_crewLegend2 => 'Nebelweiser';

  @override
  String get g_crewLegend3 => 'Kometenritter';

  @override
  String get g_crewLegend4 => 'Supernova';

  @override
  String g_crewLegendName(String title, String name) {
    return '$title $name';
  }

  @override
  String get g_bldHouse => 'Haus';

  @override
  String g_bldHouseEffect(int n) {
    return 'Bewohner +$n (mehr Geschenke)';
  }

  @override
  String get g_bldFarm => 'Weltraumfarm';

  @override
  String g_bldFarmEffect(int n) {
    return 'Credit-Einkommen +$n%';
  }

  @override
  String get g_bldMine => 'Mine';

  @override
  String g_bldMineEffect(int n) {
    return 'Erzertrag +$n%';
  }

  @override
  String get g_bldLab => 'Labor';

  @override
  String g_bldLabEffect(int n) {
    return 'Abklingzeit -$n%';
  }

  @override
  String get g_bldTower => 'Verteidigungsturm';

  @override
  String g_bldTowerEffect(int n) {
    return 'Max. LP +$n%';
  }

  @override
  String get g_bldShipyard => 'Werft';

  @override
  String g_bldShipyardEffect(int n) {
    return 'Angriff +$n%';
  }

  @override
  String get g_bldPark => 'Freizeitpark';

  @override
  String g_bldParkEffect(int n) {
    return 'Offline-Einkommen +$n %-Pkt.';
  }

  @override
  String get g_bldStatue => 'Captain-Statue';

  @override
  String g_bldStatueEffect(int n) {
    return 'Edelsteine pro Planetengeschenk +$n';
  }

  @override
  String get g_homePalette0 => 'Grüner Garten';

  @override
  String get g_homePalette1 => 'Sandwüste';

  @override
  String get g_homePalette2 => 'Eiskönigreich';

  @override
  String get g_homePalette3 => 'Lavainsel';

  @override
  String get g_homePalette4 => 'Violettes Gas';

  @override
  String get g_homePalette5 => 'Kirschblüte';

  @override
  String get g_homePalette6 => 'Polarlicht';

  @override
  String get g_homePalette7 => 'Gold';

  @override
  String get g_homeDefaultName => 'Mein kleiner Stern';

  @override
  String get g_achFirstBloodTitle => 'Erster Abschuss';

  @override
  String get g_achFirstBloodDesc => '1 Piraten abschießen';

  @override
  String get g_achHunterTitle => 'Piratenjäger';

  @override
  String get g_achHunterDesc => '100 Piraten abschießen';

  @override
  String get g_achLegendTitle => 'Legendärer Captain';

  @override
  String get g_achLegendDesc => '1000 Piraten abschießen';

  @override
  String get g_achMinerTitle => 'Minenkönig';

  @override
  String get g_achMinerDesc => '1000 Erz sammeln';

  @override
  String get g_achMiner2Title => 'Erzmagnat';

  @override
  String get g_achMiner2Desc => '10000 Erz sammeln';

  @override
  String get g_achColonistTitle => 'Pionier';

  @override
  String get g_achColonistDesc => '5 Planeten besiedeln';

  @override
  String get g_achMetropolisTitle => 'Metropole';

  @override
  String get g_achMetropolisDesc => 'Eine Kolonie auf Lv.5 bringen';

  @override
  String get g_achBuilderTitle => 'Baumeister';

  @override
  String get g_achBuilderDesc => '3 Stationen bauen';

  @override
  String get g_achBoss1Title => 'Bossjagd';

  @override
  String get g_achBoss1Desc => 'Einen Piratenboss besiegen';

  @override
  String get g_achBoss10Title => 'Bosskiller';

  @override
  String get g_achBoss10Desc => 'Piratenbosse 10-mal besiegen';

  @override
  String get g_achExplorerTitle => 'Entdecker';

  @override
  String get g_achExplorerDesc => 'Sektor 3 erreichen';

  @override
  String get g_achVoyagerTitle => 'Weltraumreisender';

  @override
  String get g_achVoyagerDesc => 'Sektor 6 erreichen';

  @override
  String get g_achRichTitle => 'Reicher Captain';

  @override
  String get g_achRichDesc => '10000 Credits besitzen';

  @override
  String get g_achCrew6Title => 'Treue Crew';

  @override
  String get g_achCrew6Desc => '6 Crewmitglieder anwerben';

  @override
  String get g_achCrew3starTitle => 'Legendärer Gefährte';

  @override
  String get g_achCrew3starDesc => 'Ein ★3-Crewmitglied anwerben';

  @override
  String get g_achMissionsTitle => 'Problemlöser';

  @override
  String get g_achMissionsDesc => '20 Missionen abschließen';

  @override
  String get g_achJellyTitle => 'Quallenexperte';

  @override
  String get g_achJellyDesc => '10 Weltraumquallen besiegen';

  @override
  String get g_achFashionTitle => 'Fashionista';

  @override
  String get g_achFashionDesc => 'Ein Kosmetik-Item kaufen';

  @override
  String get g_achAscendTitle => 'Neuanfang';

  @override
  String get g_achAscendDesc => 'Mit Galaktischer Ehre aufsteigen';

  @override
  String get g_achDroneTitle => 'Treue Drohne';

  @override
  String get g_achDroneDesc => 'Eine Kampfdrohne ausrüsten';

  @override
  String get g_achHome5Title => 'Planetenarchitekt';

  @override
  String get g_achHome5Desc => '5 Gebäude auf meinem Planeten';

  @override
  String get g_achHomeMaxTitle => 'Traumplanet';

  @override
  String get g_achHomeMaxDesc => 'Mein Planet auf max. Level';

  @override
  String get g_dailyKill => '30 Piraten abschießen';

  @override
  String get g_dailyOre => '300 Erz sammeln';

  @override
  String get g_dailyMission => '2 Missionen abschließen';

  @override
  String get g_dailyColony => 'Kolonien 2-mal wachsen lassen';

  @override
  String get g_dailyBoss => 'Einen Piratenboss besiegen';

  @override
  String get g_dailyPower => '3 Power-ups einsammeln';

  @override
  String get g_dailyPlay => '10 Minuten spielen';

  @override
  String get g_dailyJelly => '3 Weltraumquallen besiegen';

  @override
  String g_missionKill(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Piraten erledigen',
      one: '$n Piraten erledigen',
    );
    return '$_temp0';
  }

  @override
  String g_missionMine(int n) {
    return '$n Erz sammeln';
  }

  @override
  String g_missionDeliver(String planet) {
    return 'Fracht nach $planet liefern';
  }

  @override
  String g_missionBounty(String name) {
    return 'Gesucht: $name';
  }

  @override
  String get g_bounty0 => 'Einauge Jack';

  @override
  String get g_bounty1 => 'Blitz-Molly';

  @override
  String get g_bounty2 => 'Schrottkönig Bark';

  @override
  String get g_bounty3 => 'Rotbart Toto';

  @override
  String get g_bounty4 => 'Schatten-Lena';

  @override
  String get g_bounty5 => 'Dicker Pork';

  @override
  String get g_bounty6 => 'Zwei-Klingen-Gigi';

  @override
  String get g_bounty7 => 'Irrer Hammer Bud';

  @override
  String get g_bounty8 => 'Galaxiefuchs Lucy';

  @override
  String get g_bounty9 => 'Totenkopf-Käpt\'n Bones';

  @override
  String get g_storyAsteroidsTitle => '3 Asteroiden zerstören';

  @override
  String get g_storyAsteroidsLine0 =>
      'Captain! Zerstör zuerst Asteroiden, um Erz zu sammeln.';

  @override
  String get g_storyAsteroidsLine1 =>
      'Beweg dich mit dem Joystick und schieß mit dem Feuerknopf!';

  @override
  String get g_storyKillsTitle => '3 Piraten abschießen';

  @override
  String get g_storyKillsLine0 =>
      'Piraten auf dem Radar! Folg dem roten Pfeil.';

  @override
  String get g_storyKillsLine1 =>
      'Piraten? Vor meinem Schiff sind die nur Schrott!';

  @override
  String get g_storyColoniesTitle => 'Terra Nova besiedeln';

  @override
  String get g_storyColoniesLine0 =>
      'Besiedle doch den grünen Planeten Terra Nova in der Nähe. Flieg nah ran, dann erscheint ein Besiedeln-Knopf.';

  @override
  String get g_storyColoniesLine1 =>
      'Kolonien verdienen Credits, sogar wenn du dich ausruhst!';

  @override
  String get g_storyShipLevelsTitle => 'Schiff an einer Station verbessern';

  @override
  String get g_storyShipLevelsLine0 =>
      'Flieg zurück zur Haven-Basis und verbessere dein Schiff. In der Nähe von Stationen wirst du auch repariert.';

  @override
  String get g_storyCrewTitle => '1 Crewmitglied anwerben';

  @override
  String get g_storyCrewLine0 =>
      'Einsam hier draußen? Wirb im Crew-Tab des Stationsmenüs einen Kumpel an!';

  @override
  String get g_storyMissionsTitle => '1 Mission abschließen';

  @override
  String get g_storyMissionsLine0 =>
      'Nimm einen Auftrag am Missionsbrett der Station an. Die Bezahlung ist super.';

  @override
  String get g_storyStationsTitle => 'Neue Station bauen';

  @override
  String get g_storyStationsLine0 =>
      'Zeit zu expandieren! Bau eine Station im freien All, weit weg von Planeten.';

  @override
  String get g_storyDevPercentTitle => 'Systementwicklung 100%';

  @override
  String get g_storyDevPercentLine0 =>
      'Bring jeden Planeten auf Lv.3, um das nächste System zu öffnen. Schau oben rechts auf den System-Knopf!';

  @override
  String get g_storySectorTitle => 'Zum nächsten System warpen';

  @override
  String get g_storySectorLine0 =>
      'Das Warp-Tor ist offen! Flieg zum lila Tor auf der Minikarte.';

  @override
  String get g_storySectorLine1 => 'Ein ganz neues Universum wartet!';

  @override
  String g_storyDevNTitle(int n) {
    return 'System $n: Entwicklung 100%';
  }

  @override
  String get g_storyDevNLine =>
      'Bring jeden Planeten im neuen System auf Lv.3!';

  @override
  String g_systemN(int n) {
    return 'System $n';
  }

  @override
  String g_storyWarpNTitle(String system) {
    return 'Warp nach $system';
  }

  @override
  String get g_storyWarpNLine =>
      'Das Tor ist offen. Fliegen wir tiefer ins All?';

  @override
  String get g_powerUpRapid => 'Schnellfeuer';

  @override
  String get g_powerUpShield => 'Schild';

  @override
  String get g_powerUpMagnet => 'Magnet';

  @override
  String get g_powerUpDoubleCredits => '2x Credits';

  @override
  String get g_planetKindGarden => 'Gartenplanet';

  @override
  String get g_planetKindDesert => 'Wüstenplanet';

  @override
  String get g_planetKindIce => 'Eisplanet';

  @override
  String get g_planetKindLava => 'Lavaplanet';

  @override
  String get g_planetKindGas => 'Gasplanet';

  @override
  String get g_colonyBldTurret => 'Abwehrgeschütz';

  @override
  String get g_colonyBldMine => 'Bohranlage';

  @override
  String get g_colonyBldTrade => 'Handelsposten';

  @override
  String get g_colonyBldDock => 'Reparaturdock';

  @override
  String get g_colonyBldShieldGen => 'Schildgenerator';

  @override
  String get g_colonyBldBlurbTurret =>
      'Schießt automatisch auf Piraten nahe der Kolonie. Ein Muss gegen Überfälle!';

  @override
  String get g_colonyBldBlurbMine => 'Baut Erz ab und schickt jede Sekunde 💎.';

  @override
  String get g_colonyBldBlurbTrade =>
      'Erhöht das Credit-Einkommen dieser Kolonie um 25% pro Stufe.';

  @override
  String get g_colonyBldBlurbDock =>
      'Repariert dein Schiff, solange du in der Nähe bist.';

  @override
  String get g_colonyBldBlurbShieldGen =>
      'Erhöht Schildkapazität und Aufladetempo.';

  @override
  String get g_stationRoleHome => 'Heimatbasis';

  @override
  String get g_stationRoleDefense => 'Verteidigungsbasis';

  @override
  String get g_stationRoleRepair => 'Reparaturbasis';

  @override
  String get g_stationRoleSupport => 'Versorgungsbasis';

  @override
  String get g_stationRoleBlurbHome => 'Laserbatterie und Schutzzone';

  @override
  String get g_stationRoleBlurbDefense =>
      'Starkes Geschütz · 2x Haltbarkeit · blockt feindliche Schüsse in der Nähe';

  @override
  String get g_stationRoleBlurbRepair =>
      'Schnelle Reparatur mit großer Reichweite · 10% Neustartkosten · 2x Schildaufladung naher Kolonien';

  @override
  String get g_stationRoleBlurbSupport =>
      'Produktion naher Kolonien +25% (+5% pro Wohnmodul-Stufe)';

  @override
  String g_eventRaid(String planet) {
    return 'Überfall auf $planet';
  }

  @override
  String get g_eventMeteor => 'Meteorschauer';

  @override
  String get g_eventMerchant => 'Reisende Händlerin';

  @override
  String get g_eventSupply => 'Versorgungskapsel';

  @override
  String get g_productGems100Title => 'Handvoll Edelsteine';

  @override
  String get g_productGems550Title => 'Edelsteinbeutel';

  @override
  String get g_productGems1200Title => 'Edelsteintruhe';

  @override
  String get g_productStarterTitle => 'Starterpaket';

  @override
  String get g_productPassTitle => 'Kommandanten-Pass';

  @override
  String get g_productGems550Desc => '⭐550 (+10% Bonus)';

  @override
  String get g_productGems1200Desc => '⭐1200 (+20% Bonus)';

  @override
  String get g_productStarterDesc =>
      '⭐300 + exklusiver Skin „Galaxie“ + ★3-Crewmitglied (nur einmal)';

  @override
  String get g_productPassDesc =>
      'Credit-Einkommen +25%, 8 Std. Offline-Einkommen, Belohnungen ohne Werbung, exklusiver Skin „Königsgold“';

  @override
  String g_testPurchaseTitle(String product) {
    return '[Testkauf] $product';
  }

  @override
  String g_testPurchaseBody(String desc, String price) {
    return 'Es erfolgt keine echte Zahlung.\n$desc\nPreis: $price';
  }

  @override
  String get g_testAdTitle => '[Testwerbung]';

  @override
  String get g_testAdBody => 'Werbung als vollständig angesehen werten?';

  @override
  String get g_webDemoTitle => 'Web-Demo';

  @override
  String get g_webDemoBody =>
      'Käufe und Werbebelohnungen gibt es in der mobilen App.';

  @override
  String get g_notifChannelName => 'Rückkehr-Erinnerungen';

  @override
  String get g_notifChannelDesc =>
      'Erinnerungen an Kolonie-Einkommen und tägliche Belohnungen';

  @override
  String get g_notifStorageTitle => 'Dein Kolonielager ist voll!';

  @override
  String get g_notifStorageBody =>
      'Captain, hol deine Credits ab, bevor das Einkommen stoppt!';

  @override
  String get g_notifPiratesTitle => 'Die Piraten treiben wieder ihr Unwesen!';

  @override
  String get g_notifPiratesBody =>
      'Deine Login-Belohnung und die Tagesquests warten.';

  @override
  String get g_upgradeWeapon => 'Waffe';

  @override
  String get g_upgradeHull => 'Panzerung';

  @override
  String get g_upgradeEngine => 'Triebwerk';

  @override
  String get g_upgradeMissile => 'Zielsuchende Rakete';

  @override
  String get g_upgradeShield => 'Energieschild';

  @override
  String get g_upgradeDrone => 'Kampfdrohne';

  @override
  String get g_upgradeMagnet => 'Magnet';

  @override
  String get g_sector0 => 'Alpha-Heiligtum';

  @override
  String get g_sector1 => 'Beta-Nebel';

  @override
  String get g_sector2 => 'Gamma-Schlucht';

  @override
  String get g_sector3 => 'Delta-Piratenzone';

  @override
  String get g_sector4 => 'Epsilon-Abgrund';

  @override
  String get g_sector5 => 'Zeta-Eisgürtel';

  @override
  String get g_sector6 => 'Eta-Flammenhaufen';

  @override
  String get g_sector7 => 'Theta-Geisterroute';

  @override
  String get g_sector8 => 'Iota-Kronennebel';

  @override
  String get g_sector9 => 'Kappa-Loch';

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
  String get g_planet6 => 'Momo-Stern';

  @override
  String get g_planet7 => 'Nebula';

  @override
  String get g_planet8 => 'Cassiope';

  @override
  String get g_planet9 => 'Aurora';

  @override
  String get g_planet10 => 'Durian';

  @override
  String get g_planet11 => 'Zimt';

  @override
  String get g_planet12 => 'Marshmallow';

  @override
  String get g_planet13 => 'Popcorn-Stern';

  @override
  String get g_planet14 => 'Lavendel';

  @override
  String get g_planet15 => 'Emeraldia';

  @override
  String get g_planet16 => 'Crimson';

  @override
  String get g_planet17 => 'Polaris';

  @override
  String get g_planet18 => 'Wega';

  @override
  String get g_planet19 => 'Rigel';

  @override
  String get g_planet20 => 'Mira';

  @override
  String get g_planet21 => 'Topas';

  @override
  String get g_planet22 => 'Kobalt';

  @override
  String get g_planet23 => 'Saphir';

  @override
  String get g_planet24 => 'Onyx';

  @override
  String get g_planet25 => 'Peridot';

  @override
  String get g_planet26 => 'Minzstern';

  @override
  String get g_planet27 => 'Vanille';

  @override
  String get g_planet28 => 'Karamell';

  @override
  String get g_planet29 => 'Pistazie';

  @override
  String get g_planet30 => 'Blaubeere';

  @override
  String get g_planet31 => 'Zitronenstern';

  @override
  String get g_planet32 => 'Kirsche';

  @override
  String get g_planet33 => 'Melone';

  @override
  String get g_planet34 => 'Kiwi';

  @override
  String get g_planet35 => 'Mangostern';

  @override
  String get g_planet36 => 'Yuzu';

  @override
  String get g_planet37 => 'Grapefruit';

  @override
  String get g_planet38 => 'Kürbisstern';

  @override
  String get g_planetTerraNova => 'Terra Nova';

  @override
  String g_unknownSector(int n) {
    return 'Unbekannter Sektor $n';
  }

  @override
  String get g_stationHaven => 'Haven-Basis';

  @override
  String g_stationOutpost(String sector) {
    return 'Außenposten $sector';
  }

  @override
  String g_stationNumbered(String role, int n) {
    return '$role Nr. $n';
  }

  @override
  String get g_dlgWelcome =>
      'Willkommen, Captain! Ich bin Mina, deine Erste Offizierin.';

  @override
  String get g_dlgMissionsCancelled =>
      'Liefer- und Kopfgeldmissionen aus dem letzten Sektor wurden abgebrochen.';

  @override
  String get g_floatDisabled => 'Außer Betrieb!';

  @override
  String get g_floatRebooted => 'Wieder online!';

  @override
  String get g_dlgBaseRebooted =>
      'Heimatbasis wieder online! Auf 30% Haltbarkeit wiederhergestellt.';

  @override
  String get g_dlgUpWeapon => 'Waffen verbessert! Piraten, nehmt euch in Acht!';

  @override
  String get g_dlgUpHull =>
      'Panzerung verbessert! Fühlt sich gleich stabiler an.';

  @override
  String get g_dlgUpEngine => 'Triebwerk verbessert! Schneller!';

  @override
  String get g_dlgMissileNew => 'Zielsuchende Raketen ausgerüstet! (Q)';

  @override
  String get g_dlgMissileUp => 'Raketen verbessert!';

  @override
  String get g_dlgShieldNew => 'Energieschild ausgerüstet! (F)';

  @override
  String get g_dlgShieldUp => 'Schild verbessert!';

  @override
  String get g_dlgDroneNew => 'Kampfdrohne gestartet! Ein treuer neuer Freund.';

  @override
  String get g_dlgDroneUp => 'Drohne verbessert!';

  @override
  String get g_dlgUpMagnet =>
      'Magnet verbessert! Die Credits fliegen direkt zu mir!';

  @override
  String get g_dlgNotOver => 'Es ist noch nicht vorbei!';

  @override
  String get g_floatBlocked => 'Geblockt!';

  @override
  String get g_floatGuard => 'Geschützt!';

  @override
  String get g_pirateBossLose => 'Argh! Dieser Sektor… gehört dir…';

  @override
  String get g_pirateBossFlee => 'Argh! Das merk ich mir, Captain!';

  @override
  String get g_dlgSupplyCollected => 'Versorgungskapsel geborgen!';

  @override
  String get g_merchantBye => 'Bis zum nächsten Mal~ miau!';

  @override
  String get g_pirateRaidTaunt => 'Diese Kolonie gehört jetzt uns! Hahaha!';

  @override
  String get g_dlgMeteor =>
      'Meteorschauer entdeckt! Voller Kristalle. Große Erz-Chance!';

  @override
  String get g_merchantHello =>
      'Die reisende Händlerin Nyang-Nyang ist da~ Jede Menge tolle Sachen, miau!';

  @override
  String get g_dlgSupplySignal =>
      'Signal einer Versorgungskapsel mit Edelsteinen! Piraten bewachen sie, also sei vorsichtig.';

  @override
  String get g_dlgBossWarning =>
      'Warnung! Das Schiff des Sektorbosses nähert sich!';

  @override
  String get g_pirateRevenge =>
      'Ich bin zurück und will Rache! Mach dich bereit!';

  @override
  String get g_floatShieldBroken => 'Zerstört!';

  @override
  String get g_floatShieldBack => 'Wieder aktiv';

  @override
  String get g_floatGoalDone => 'Ziel erreicht!';

  @override
  String g_dlgArrived(String sector) {
    return 'Angekommen: $sector!';
  }

  @override
  String get g_dlgNewFrontier => 'Ein brandneues Grenzland.';

  @override
  String g_dlgBaseUpgraded(String station, int level) {
    return '$station auf Lv.$level verbessert! Die Laser sind stärker.';
  }

  @override
  String g_dlgBaseDisabled(int sec) {
    return 'Heimatbasis außer Betrieb! ${sec}s lang kein Schutz!';
  }

  @override
  String g_dlgSettled(String planet) {
    return 'Flagge auf $planet gehisst! Besiedelt!';
  }

  @override
  String g_dlgStationBuilt(String station, String blurb) {
    return '$station gebaut! $blurb';
  }

  @override
  String g_dlgHabitatUp(String station, int level) {
    return '$station: Wohnmodul Lv.$level!';
  }

  @override
  String g_dlgTurretUp(String station, int level) {
    return '$station: Abwehrgeschütz Lv.$level!';
  }

  @override
  String g_dlgShipSwitched(String ship) {
    return 'Umgestiegen auf die $ship! Fühlt sich gut an!';
  }

  @override
  String g_dlgOreSold(int n, int credits) {
    return '$n Erz für 💰$credits verkauft.';
  }

  @override
  String g_dlgCrewJoined(String stars, String role, String name) {
    return '$stars $role $name ist der Crew beigetreten!';
  }

  @override
  String g_dlgCrewLevel(String name, int level) {
    return '$name Lv.$level! Wird immer besser.';
  }

  @override
  String g_dlgCargoLoaded(String mission) {
    return 'Fracht geladen! $mission';
  }

  @override
  String g_dlgBountyTaunt(String name) {
    return 'Du willst $name fangen? Versuch\'s doch!';
  }

  @override
  String get g_floatMissionDone => 'Mission erfüllt!';

  @override
  String g_dlgMissionDone(String mission) {
    return 'Mission erfüllt: $mission!';
  }

  @override
  String g_dlgRepairCost(int credits) {
    return 'Du bist in Sicherheit, Captain! Die Reparatur kostet 💰$credits.';
  }

  @override
  String g_dlgSectorDeveloped(String sector) {
    return '$sector voll entwickelt! Das Warp-Tor zum nächsten System ist offen.';
  }

  @override
  String g_floatCrit(int dmg) {
    return 'Kritisch! $dmg';
  }

  @override
  String g_dlgStationDestroyed(String station) {
    return '$station wurde zerstört! Wir brauchen Abwehrgeschütze!';
  }

  @override
  String g_dlgBossDefeated(int credits) {
    return 'Sektorboss besiegt! Belohnung 💰$credits';
  }

  @override
  String g_dlgBountyCaught(String name) {
    return 'Gesucht und gefasst: $name!';
  }

  @override
  String g_dlgRaidDefended(String planet, int credits) {
    return '$planet verteidigt! Die dankbaren Bewohner schicken 💰$credits ⭐2.';
  }

  @override
  String g_dlgRaidLooted(String planet, String level) {
    return '$planet wurde geplündert und fiel auf $level zurück… 😢';
  }

  @override
  String g_dlgRaidLeft(String planet) {
    return 'Die Piraten haben $planet geplündert und sind abgezogen.';
  }

  @override
  String g_dlgRaidAlert(String planet) {
    return 'Notfall! Piraten überfallen $planet! Die Produktion steht still!';
  }

  @override
  String g_pirateBossArrive(String sector) {
    return '$sector gehört mir! Komm nur her, kleiner Captain!';
  }

  @override
  String g_dlgWelcomeBack(String goal) {
    return 'Willkommen zurück, Captain! Aktuelles Ziel: $goal';
  }

  @override
  String get g_pirateWin0 => 'Hahaha! Gar nicht so zäh!';

  @override
  String get g_pirateWin1 => 'Komm nächstes Mal stärker wieder, Kleiner!';

  @override
  String get g_pirateWin2 => 'Dein Schiff ist jetzt Schrott!';

  @override
  String get g_pirateRage0 => 'Raus mit euch, Jungs! Zeigt\'s ihnen!';

  @override
  String get g_pirateRage1 => 'Jetzt wird\'s ernst!';

  @override
  String get g_pirateRage2 => 'Jetzt hast du mich wütend gemacht?!';

  @override
  String get g_captainKill0 => 'Einer weniger!';

  @override
  String get g_captainKill1 => 'Wo willst du denn hin!';

  @override
  String get g_captainKill2 => 'Das ist mein Revier!';

  @override
  String get g_captainKill3 => 'Der Nächste!';

  @override
  String get g_pirateAmbush0 => 'Hahaha! Her mit deiner Fracht!';

  @override
  String get g_pirateAmbush1 => 'Das ist das Revier unserer Bande!';

  @override
  String get g_pirateAmbush2 => 'Rück die glänzenden Credits raus!';

  @override
  String get g_pirateAmbush3 => 'Pech gehabt, Kleiner!';
}
