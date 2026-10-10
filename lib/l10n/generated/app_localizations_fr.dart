// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class L10nFr extends L10n {
  L10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Star Settlers';

  @override
  String get languageName => 'Français';

  @override
  String get u_tabShip => 'Vaisseau';

  @override
  String get u_tabStation => 'Station';

  @override
  String get u_tabCrew => 'Équipage';

  @override
  String get u_tabMission => 'Missions';

  @override
  String get u_tabMarket => 'Marché';

  @override
  String u_upWeapon(int dmg) {
    return 'Dégâts $dmg · Lv.3 double · Lv.6 triple';
  }

  @override
  String u_upHull(int hp) {
    return 'PV max $hp';
  }

  @override
  String u_upEngine(int speed) {
    return 'Vitesse max $speed';
  }

  @override
  String get u_upMissileIntro =>
      'Missiles à tête chercheuse (touche Q / bouton 🚀)';

  @override
  String u_upMissile(int count, String cooldown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count missiles',
      one: '1 missile',
    );
    return '$_temp0 · recharge ${cooldown}s';
  }

  @override
  String get u_upShieldIntro =>
      'Bouclier qui bloque tous les dégâts (touche F / bouton 🛡)';

  @override
  String u_upShield(String duration, String cooldown) {
    return '${duration}s · recharge ${cooldown}s';
  }

  @override
  String get u_upDroneIntro =>
      'Tourne autour de vous, tire seul et attire les objets';

  @override
  String u_upDrone(int dmg, String interval) {
    return 'Dégâts $dmg · tir toutes les ${interval}s';
  }

  @override
  String u_upMagnet(int range, String power) {
    return 'Attire crédits et minerai · portée $range · force x$power';
  }

  @override
  String get u_equip => 'Équiper';

  @override
  String get u_hangarSection => '🛸 Hangar';

  @override
  String get u_viewLarge => 'Voir';

  @override
  String get u_hp => 'PV';

  @override
  String get u_speed => 'Vitesse';

  @override
  String get u_attack => 'Attaque';

  @override
  String get u_fireRate => 'Cadence';

  @override
  String get u_ore => 'Minerai';

  @override
  String get u_crit => 'Critique';

  @override
  String get u_boarded => 'À bord';

  @override
  String get u_board => 'Monter';

  @override
  String get u_boardNow => 'Monter à bord';

  @override
  String get u_gemsOnly => 'Gemmes uniquement';

  @override
  String u_unlockOrGems(String condition) {
    return 'Déblocage : $condition ou gemmes';
  }

  @override
  String u_unlock(String condition) {
    return 'Déblocage : $condition';
  }

  @override
  String u_durability(int hp, int max) {
    return 'Coque $hp / $max';
  }

  @override
  String get u_habitat => 'Habitat';

  @override
  String u_habitatDesc(String rate, int hp) {
    return 'Revenu 💰$rate/s · Coque $hp';
  }

  @override
  String get u_turret => 'Tourelle';

  @override
  String get u_turretIntro => 'Tire automatiquement sur les pirates';

  @override
  String u_turretDesc(int dmg, int range) {
    return 'Dégâts $dmg · Portée $range';
  }

  @override
  String get u_baseUpgrade => 'Amélioration de la base';

  @override
  String u_baseDesc(int dmg, int range, int hp) {
    return 'Laser $dmg · Portée $range · Coque $hp';
  }

  @override
  String u_disabledSec(int sec) {
    return 'Hors service ${sec}s';
  }

  @override
  String u_sectorStatus(String sector) {
    return 'État de $sector';
  }

  @override
  String u_sectorStats(
    int colonies,
    int planets,
    int stations,
    String mul,
    String other,
  ) {
    return 'Planètes colonisées $colonies / $planets\nStations : $stations\nBonus de secteur : production x$mul\nAutres secteurs : 💰$other/s';
  }

  @override
  String get u_legendaryGet => '🌟 Légendaire ! 🌟';

  @override
  String get u_rareGet => '✨ Équipier rare ! ✨';

  @override
  String get u_newCrew => 'Nouvel équipier !';

  @override
  String get u_great => 'Super !';

  @override
  String u_crewHeader(int count, int cap, int assigned, int slots) {
    return 'Équipage $count/$cap · Affectés $assigned/$slots';
  }

  @override
  String u_recruit(int cost) {
    return 'Recruter 💰$cost';
  }

  @override
  String u_recruitPremium(int cost) {
    return 'Recrutement premium ⭐$cost';
  }

  @override
  String u_recruitLegendary(int cost) {
    return '🌟 Légendaire garanti ⭐$cost';
  }

  @override
  String u_recruitOdds(String normal, String premium) {
    return 'Chances · Recrutement : $normal\nRecrutement premium : $premium\nLégendaire garanti : ★4 100 %';
  }

  @override
  String u_slotMax(int n) {
    return 'Postes MAX ($n)';
  }

  @override
  String u_slotBuy(int price) {
    return 'Poste d\'équipage +1 ⭐$price';
  }

  @override
  String u_rosterMax(int n) {
    return 'Effectif MAX ($n)';
  }

  @override
  String u_rosterBuy(int size, int price) {
    return 'Effectif +$size ⭐$price';
  }

  @override
  String get u_noCrew =>
      'Pas encore d\'équipage. Recrutez-en et affectez-les à votre vaisseau !';

  @override
  String get u_unassign => 'Retirer';

  @override
  String get u_assign => 'Affecter';

  @override
  String get u_dismiss => 'Renvoyer';

  @override
  String get u_dismissCrewTitle => 'Renvoyer l\'équipier';

  @override
  String u_dismissCrewBody(String name) {
    return 'Laisser partir $name ? C\'est irréversible.';
  }

  @override
  String get u_missionDeliverHint => 'Rendez-vous à destination (flèche jaune)';

  @override
  String get u_missionBountyHint => 'Trouvez et battez la cible (flèche jaune)';

  @override
  String u_reward(String rewards) {
    return 'Récompense $rewards';
  }

  @override
  String u_activeMissions(int n) {
    return 'En cours ($n/3)';
  }

  @override
  String get u_noActiveMissions => 'Aucune mission en cours.';

  @override
  String get u_abandon => 'Abandonner';

  @override
  String u_missionBoard(int sec) {
    return 'Tableau des missions · nouvelle dans ${sec}s';
  }

  @override
  String get u_accept => 'Accepter';

  @override
  String get u_priceHigh => '📈 Élevé ! C\'est le moment de vendre';

  @override
  String get u_priceLow => '📉 Bas… mieux vaut attendre';

  @override
  String get u_priceNormal => '➡ Normal';

  @override
  String get u_orePrice => 'Cours du minerai';

  @override
  String get u_sell100 => 'Vendre 100';

  @override
  String get u_sellHalf => 'Vendre la moitié';

  @override
  String get u_sellAll => 'Tout vendre';

  @override
  String get u_marketTip =>
      'Les prix montent et descendent. Vendez quand c\'est cher !';

  @override
  String get u_gemExchange => '⭐ Échange de gemmes';

  @override
  String get u_creditPack => 'Pack de crédits';

  @override
  String get u_exchange => 'Échanger';

  @override
  String get u_openShop => '⭐ Ouvrir la boutique';

  @override
  String u_achievementDone(String title, int gems) {
    return '🏆 Succès : $title ! Récupérez ⭐$gems dans Menu > Succès.';
  }

  @override
  String get u_cannotDo =>
      'Ressources insuffisantes, ou impossible pour l\'instant.';

  @override
  String get u_welcomeBack => 'Bon retour, Capitaine !';

  @override
  String u_offlineHm(int h, int m) {
    return 'Pendant vos $h h $m min d\'absence,\nvos colonies ont bien travaillé !';
  }

  @override
  String u_offlineM(int m) {
    return 'Pendant vos $m min d\'absence,\nvos colonies ont bien travaillé !';
  }

  @override
  String get u_passOfflineHint => 'Pass Commandant : jusqu\'à 8 h + x2 auto';

  @override
  String get u_collect => 'Récupérer';

  @override
  String get u_adLoading => 'Chargement de la pub. Réessayez dans un instant.';

  @override
  String get u_adLoadingRetry =>
      'Chargement de la pub. Touchez à nouveau dans un instant.';

  @override
  String get u_collectDouble => 'Récupérer x2 👑';

  @override
  String get u_adDouble => '📺 Pub pour x2';

  @override
  String get u_galaxyHonor => '🌌 Honneur galactique';

  @override
  String u_honorStatus(int honor, int ascensions) {
    return 'Honneur $honor (renaissances : $ascensions)';
  }

  @override
  String u_honorBonus(int income, int attack) {
    return 'Revenu +$income % · Dégâts +$attack %';
  }

  @override
  String get u_ascendExplain =>
      'La renaissance réinitialise cet univers (secteurs, colonies, stations, améliorations, équipage, crédits)\net donne de l\'honneur, un bonus permanent.\nGemmes, cosmétiques, vaisseaux et succès sont conservés.';

  @override
  String u_ascendGain(int gain) {
    return 'Renaissez maintenant pour +$gain d\'honneur !\n(Plus votre empire est grand, plus vous gagnez)';
  }

  @override
  String get u_ascendLocked => 'Atteignez le secteur 4 pour renaître.';

  @override
  String get u_close => 'Fermer';

  @override
  String u_ascendBtn(int gain) {
    return 'Renaître (+$gain)';
  }

  @override
  String get u_ascendConfirmTitle => 'Vraiment renaître ?';

  @override
  String get u_ascendConfirmBody =>
      'Votre univers actuel sera réinitialisé. C\'est irréversible.';

  @override
  String get u_ascend => 'Renaître';

  @override
  String u_shieldBroken(String name) {
    return '$name brisé';
  }

  @override
  String u_hudSector(String sector, int dev, String threat, String value) {
    return '$sector · Dév. $dev %\n⚠ Menace $threat  🏛 $value';
  }

  @override
  String u_baseDisabled(int sec) {
    return 'Base HS ${sec}s';
  }

  @override
  String u_baseHp(int pct) {
    return 'Base $pct %';
  }

  @override
  String get u_merchantE => 'Marchand (E)';

  @override
  String get u_nextSectorE => 'Secteur suivant (E)';

  @override
  String get u_prevSectorE => 'Secteur précédent (E)';

  @override
  String u_gateLocked(int pct) {
    return '🔒 S\'ouvre à 100 % de développement ($pct %)';
  }

  @override
  String u_settle(String name) {
    return 'Coloniser $name';
  }

  @override
  String u_manageE(String name) {
    return 'Gérer $name (E)';
  }

  @override
  String get u_buildStation => 'Construire une station';

  @override
  String get u_fire => 'FEU';

  @override
  String get u_equipAtStation =>
      'Équipez-le dans l\'onglet Vaisseau de la station !';

  @override
  String get u_shotDown => '💥 Vous avez été abattu !';

  @override
  String u_autoRespawn(int sec) {
    return 'Retour auto à la base dans ${sec}s';
  }

  @override
  String get u_reviveFree => '👑 Revivre ici (gratuit)';

  @override
  String get u_reviveAd => '📺 Pub pour revivre ici';

  @override
  String get u_reviveGems => 'Revivre ici pour ⭐10';

  @override
  String u_respawnBase(int pct) {
    return '🏠 Retour à la base (perte de $pct % des crédits)';
  }

  @override
  String get u_spkCaptain => 'Capitaine';

  @override
  String get u_spkPirate => 'Pirate';

  @override
  String get u_spkAdvisor => 'Lt. Mina';

  @override
  String get u_spkMerchant => 'Nyang la marchande';

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
    return '$sector · Abattus $kills · Équipage $crew\nColonies $colonies · Stations $stations · Missions $missions';
  }

  @override
  String get u_resume => '▶︎ Reprendre';

  @override
  String get u_shop => '⭐ Boutique';

  @override
  String get u_achievements => '🏆 Succès';

  @override
  String get u_dailyQuests => '📅 Quêtes du jour';

  @override
  String get u_myPlanet => '🌍 Ma planète';

  @override
  String get u_ascendMenu => '🌌 Honneur galactique (Renaissance)';

  @override
  String get u_settings => '⚙ Paramètres';

  @override
  String get u_saveAndQuit => '💾 Sauver et quitter';

  @override
  String get u_keyboardHelp =>
      'Touches : WASD bouger · Espace tirer · Q missile · F bouclier · Shift boost\nE interagir · B construire station · Échap menu';

  @override
  String get u_recharging => 'Recharge';

  @override
  String get u_tutDome => 'Bouclier\nà l\'abri dedans';

  @override
  String get u_tutLevelUp => 'Niveau sup.\nrevenu·bâtiments↑';

  @override
  String get u_tutTurret => 'Tourelle';

  @override
  String get u_tutRepair => 'Réparer';

  @override
  String get u_tutRaid => 'Stopper les raids';

  @override
  String get u_gotIt => 'Compris';

  @override
  String u_damage(int dmg) {
    return 'Dégâts $dmg';
  }

  @override
  String u_oreRate(String rate) {
    return 'Minerai +$rate/s';
  }

  @override
  String u_incomePct(int pct) {
    return 'Revenu +$pct %';
  }

  @override
  String u_repairRate(int hp) {
    return 'PV +$hp/s';
  }

  @override
  String u_shieldPlus(int amount) {
    return 'Bouclier +$amount';
  }

  @override
  String u_systemTitle(String sector, int n) {
    return '$sector · Système $n';
  }

  @override
  String u_systemInfo(String threat, String mul) {
    return 'Menace $threat · Ressources x$mul';
  }

  @override
  String u_development(int pct) {
    return 'Développement $pct %';
  }

  @override
  String get u_nextSystemOpen => 'Système suivant ouvert';

  @override
  String get u_opensAt100 => 'S\'ouvre à 100 %';

  @override
  String get u_devHint => 'Montez chaque planète au Lv.3 pour 100 %';

  @override
  String get u_conqueredSystems => 'Systèmes conquis (produisent toujours)';

  @override
  String get u_unsettled => 'Non colonisée';

  @override
  String get u_underRaid => 'Attaquée';

  @override
  String u_unknownSector(int n) {
    return 'Secteur inconnu $n';
  }

  @override
  String u_sectorDev(String name, int pct) {
    return '$name · Dév. $pct %';
  }

  @override
  String get u_buildStationTitle => 'Construire · Choisir un rôle';

  @override
  String get u_cost => 'Coût';

  @override
  String get u_build => 'Construire';

  @override
  String get u_toNextSector => '🌀 Vers le secteur suivant';

  @override
  String get u_bossLocked => '🔒 Battez le boss pour ouvrir';

  @override
  String get u_toPrevSector => '🌀 Vers le secteur précédent';

  @override
  String get u_raidAlert => '⚠ Attaque en cours !';

  @override
  String u_rechargePct(int pct) {
    return 'Recharge $pct %';
  }

  @override
  String u_merchantLabel(int sec) {
    return '🛒 Marchande ambulante (${sec}s)';
  }

  @override
  String get u_supplyPod => '📦 Capsule de ravitaillement';

  @override
  String u_sectorBoss(String sector) {
    return '☠ Boss de $sector';
  }

  @override
  String get u_pirateBoss => '☠ Boss pirate';

  @override
  String get u_merchantName => 'Nyang, marchande ambulante';

  @override
  String u_merchantLeaves(int sec, String credits) {
    return 'Part dans ${sec}s · 💰$credits';
  }

  @override
  String get u_rareCrewOffer => 'Équipier rare à recruter';

  @override
  String get u_crewSoldOut => 'L\'équipier du jour est déjà parti, miaou !';

  @override
  String get u_gemTrade => 'Échange de gemmes (max 3)';

  @override
  String u_gemTradeRow(int price, int left) {
    return '💰$price → ⭐5  (reste $left)';
  }

  @override
  String get u_convert => 'Échanger';

  @override
  String get u_potions => 'Potions de boost (durée x2)';

  @override
  String get u_notEnoughGems => 'Pas assez de gemmes';

  @override
  String get u_buyConfirmTitle => 'Confirmer l\'achat';

  @override
  String u_buyShipConfirm(String ship, String price) {
    return 'Dépenser $price pour le $ship ?';
  }

  @override
  String u_shipBought(String ship) {
    return '$ship obtenu ! Vous êtes à bord.';
  }

  @override
  String get u_premiumShips => 'Vaisseaux premium';

  @override
  String get u_hangarTitle => 'Hangar';

  @override
  String u_buyGems(int price) {
    return 'Acheter ⭐$price';
  }

  @override
  String get u_premium => 'Premium';

  @override
  String get u_ok => 'OK';

  @override
  String get u_cancel => 'Annuler';

  @override
  String get m_ok => 'OK';

  @override
  String get m_cancel => 'Annuler';

  @override
  String get m_close => 'Fermer';

  @override
  String get m_claim => 'Récupérer';

  @override
  String m_claimGems(int gems) {
    return 'Récupérer ⭐$gems';
  }

  @override
  String get m_done => '✅ Fait';

  @override
  String get m_notEnoughGems => 'Pas assez de gemmes';

  @override
  String get m_restorePurchases => 'Restaurer les achats';

  @override
  String get m_restoreDone => 'Achats vérifiés';

  @override
  String get m_buyConfirmTitle => 'Confirmer l\'achat';

  @override
  String m_spendGemsConfirm(String price) {
    return 'Dépenser $price ?';
  }

  @override
  String get m_loginTitle => '📅 Connexion du jour';

  @override
  String get m_loginWelcome => 'Bon retour, Capitaine !';

  @override
  String get m_loginStreakHint =>
      'Connectez-vous 7 jours d\'affilée pour ⭐50 !';

  @override
  String get m_newGameTitle => 'Nouvelle partie';

  @override
  String get m_newGameBody =>
      'Votre progression actuelle sera effacée.\n(Gemmes, cosmétiques, succès et achats sont conservés.) Continuer ?';

  @override
  String get m_start => 'Commencer';

  @override
  String get m_loadFailed => 'Impossible de charger la sauvegarde.';

  @override
  String m_honorLine(int honor, int income, int attack) {
    return '🌌 Honneur galactique $honor · Revenu +$income % · Attaque +$attack %';
  }

  @override
  String get m_continue => 'Continuer';

  @override
  String get m_newGame => '✨ Nouvelle partie';

  @override
  String get m_menuHome => 'Ma planète';

  @override
  String get m_menuShop => 'Boutique';

  @override
  String get m_menuQuest => 'Quêtes';

  @override
  String get m_menuAchievements => 'Succès';

  @override
  String get m_menuSettings => 'Réglages';

  @override
  String m_achievementsTitle(int done, int total) {
    return '🏆 Succès ($done/$total)';
  }

  @override
  String get m_dailyTitle => '📅 Quêtes du jour';

  @override
  String m_dailyReset(int hours, int minutes) {
    return 'Réinitialisation dans $hours h $minutes min';
  }

  @override
  String get m_dailyBonusTitle => '🎁 Bonus complet';

  @override
  String get m_dailyBonusDesc => 'Récupérez les 3 quêtes du jour';

  @override
  String get m_settingsTitle => '⚙ Paramètres';

  @override
  String get m_settingsSound => 'Effets sonores';

  @override
  String get m_settingsMusic => 'Musique';

  @override
  String get m_settingsNotify => 'Rappels de retour';

  @override
  String get m_settingsNotifyDesc =>
      'On vous prévient quand l\'entrepôt de la colonie est plein';

  @override
  String get m_settingsHaptics => 'Vibrations';

  @override
  String get m_settingsLanguage => 'Langue';

  @override
  String get m_languageSystem => 'Langue de l\'appareil';

  @override
  String get m_privacyTitle => 'Politique de confidentialité';

  @override
  String m_privacyBody(String email) {
    return 'Star Settlers enregistre les données de jeu (progression, paramètres) uniquement sur votre appareil et ne collecte aucune information personnelle identifiable.\n\nLes achats intégrés sont traités par Google Play / App Store ; les informations de paiement ne sont jamais transmises au développeur.\n\nSi les publicités récompensées sont activées, le fournisseur (Google AdMob) peut collecter des données comme les identifiants publicitaires.\n\nContact : $email (Paramètres → Envoyer un avis au développeur)';
  }

  @override
  String get m_wipeTitle => 'Réinitialiser toutes les données';

  @override
  String get m_wipeDesc =>
      'Supprime toute la progression, les gemmes et les cosmétiques';

  @override
  String get m_wipeConfirmTitle => 'Vraiment tout réinitialiser ?';

  @override
  String get m_wipeConfirmBody =>
      'C\'est irréversible. Les achats peuvent être récupérés avec « Restaurer les achats ».';

  @override
  String get m_wipeOk => 'Réinitialiser';

  @override
  String get m_feedbackTitle => 'Envoyer un avis au développeur';

  @override
  String get m_feedbackDesc =>
      'Bugs, idées, tout ! L\'appareil et la version de l\'app sont ajoutés automatiquement.';

  @override
  String m_noMailApp(String email) {
    return 'Aucune app de messagerie. Écrivez à $email.';
  }

  @override
  String get m_aboutTitle => 'STAR SETTLERS';

  @override
  String m_version(String version) {
    return 'Version $version';
  }

  @override
  String get m_shopTitle => '⭐ Boutique';

  @override
  String get m_buyThanks => 'Achat effectué ! Merci 💜';

  @override
  String get m_adLoading => 'Chargement de la pub. Réessayez dans un instant.';

  @override
  String m_buyShipConfirm(String ship, String price) {
    return 'Dépenser $price pour $ship ?';
  }

  @override
  String m_shipAcquired(String ship) {
    return '$ship obtenu ! Vous êtes à bord';
  }

  @override
  String get m_tabGems => 'Gemmes';

  @override
  String get m_tabPacks => 'Packs';

  @override
  String get m_tabPremiumShips => 'Vaisseaux premium';

  @override
  String get m_tabSkins => 'Skins de vaisseau';

  @override
  String get m_tabOutfits => 'Tenues de capitaine';

  @override
  String get m_tabFree => 'Gemmes gratuites';

  @override
  String get m_testMode => '🧪 Mode test : aucun vrai paiement ni pub';

  @override
  String get m_owned => 'Possédé';

  @override
  String get m_boarded => 'En vol';

  @override
  String get m_gemsInfo =>
      'Les gemmes servent aux cosmétiques, au recrutement premium, aux résurrections et à l\'échange de crédits.\nVous en gagnez aussi en jouant (succès, connexions, boss, capsules).';

  @override
  String get m_crewSection => '👩‍🚀 Équipage (gemmes)';

  @override
  String get m_premiumSection => '🛸 Vaisseaux premium';

  @override
  String get m_premiumDesc =>
      'Chasseurs spéciaux disponibles uniquement contre des gemmes, chacun avec une capacité unique.';

  @override
  String get m_viewLarge => 'Voir en grand';

  @override
  String get m_premiumHangarHint =>
      'Vous pouvez aussi acheter et changer de vaisseau au Hangar (Station → onglet Vaisseau).';

  @override
  String get m_legendTitle => 'Recrutement légendaire garanti';

  @override
  String get m_legendDescNoGame =>
      '1 équipier légendaire ★4 (bonus 20 %+, titre, aura dorée)\nDisponible après le début d\'une partie';

  @override
  String m_legendDesc(int count, int cap) {
    return '1 équipier légendaire ★4 (bonus 20 %+, titre, aura dorée)\nÉquipage $count/$cap';
  }

  @override
  String m_crewJoined(String stars, String name) {
    return '$stars $name a rejoint l\'équipage !';
  }

  @override
  String get m_slotTitle => 'Poste d\'équipage +1';

  @override
  String m_slotDesc(int slots) {
    return 'Équipiers affectables en même temps · Actuel $slots';
  }

  @override
  String m_rosterTitle(int n) {
    return 'Effectif +$n';
  }

  @override
  String m_rosterDesc(int cap, int max) {
    return 'Équipiers que vous pouvez garder · Actuel $cap (max $max)';
  }

  @override
  String m_crewOdds(String odds) {
    return 'Chances premium : $odds · Légendaire garanti : ★4 100 %';
  }

  @override
  String get m_equipped => 'Équipé';

  @override
  String get m_equip => 'Équiper';

  @override
  String get m_passOnly => 'Pass Commandant uniquement';

  @override
  String get m_starterOnly => 'Pack de départ uniquement';

  @override
  String get m_adSection => '📺 Gemmes gratuites via pubs';

  @override
  String m_adInfo(int perDay, int left) {
    return '$perDay fois par jour, ⭐5 chaque fois · reste $left aujourd\'hui';
  }

  @override
  String get m_adClaimPremium => 'Récupérer ⭐5 (Pass Commandant : sans pub)';

  @override
  String get m_adWatch => 'Pub pour ⭐5';

  @override
  String m_loginStreak(int days) {
    return 'Série de connexions : jour $days';
  }

  @override
  String m_dayN(int day) {
    return 'Jour $day';
  }

  @override
  String get m_notEnoughResources => 'Ressources insuffisantes';

  @override
  String m_emptyLot(int n) {
    return 'Terrain vide n°$n · Construire';
  }

  @override
  String get m_buildInGameOnly =>
      'Vous pouvez construire pendant une partie (Menu → Ma planète). Crédits et minerai viennent de votre univers actuel.';

  @override
  String m_heldAll(String credits, String ore, int gems) {
    return 'Stock 💰$credits  💎$ore  ⭐$gems';
  }

  @override
  String m_held(String credits, String ore) {
    return 'Stock 💰$credits  💎$ore';
  }

  @override
  String m_currentEffect(String effect) {
    return 'Actuel : $effect';
  }

  @override
  String m_nextLevel(String effect) {
    return 'Niveau suivant : $effect';
  }

  @override
  String m_upgrade(String cost) {
    return 'Améliorer $cost';
  }

  @override
  String get m_maxLevel => '🌟 Niveau max';

  @override
  String get m_planetName => 'Nom de la planète';

  @override
  String get m_decorateTitle => '🎨 Décorer la planète';

  @override
  String get m_planetRing => 'Anneau planétaire';

  @override
  String get m_giftInGameOnly => 'Les cadeaux se récupèrent pendant une partie';

  @override
  String get m_giftTitle => '🎁 Cadeau de la planète';

  @override
  String m_giftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Un cadeau de vos $count habitants !',
      one: 'Un cadeau de votre habitant !',
    );
    return '$_temp0';
  }

  @override
  String get m_giftThanks => 'Merci !';

  @override
  String m_planetStatus(int level, int residents, int built, int slots) {
    return 'Planète Lv.$level · $residents habitants · Bâtiments $built/$slots';
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
    return 'Bonus permanent · Revenu +$income %  Minerai +$ore %  Attaque +$attack %  PV +$hp %  Recharge -$cooldown %  Hors ligne $offline %';
  }

  @override
  String get m_planetHint =>
      'Glissez pour tourner la planète, touchez un terrain pour construire';

  @override
  String get m_giftClaim => '🎁 Récupérer le cadeau';

  @override
  String m_giftWait(int hours, int minutes) {
    return '🎁 Cadeau dans $hours h $minutes min';
  }

  @override
  String m_planetLevelUp(int level, String cost) {
    return '🌍 Planète Lv.$level (+2 terrains) $cost';
  }

  @override
  String get g_shipScoutName => 'Scout';

  @override
  String get g_shipInterceptorName => 'Intercepteur';

  @override
  String get g_shipFortressName => 'Forteresse';

  @override
  String get g_shipProspectorName => 'Prospecteur';

  @override
  String get g_shipPhantomName => 'Fantôme';

  @override
  String get g_shipNovaName => 'Dragon Nova';

  @override
  String get g_shipAuroraName => 'Aurora';

  @override
  String get g_shipScoutDesc => 'Un vaisseau de départ bien équilibré';

  @override
  String get g_shipInterceptorDesc =>
      'Rapide et tire vite, mais blindage léger';

  @override
  String get g_shipFortressDesc => 'Lent mais robuste, frappe fort';

  @override
  String get g_shipProspectorDesc => 'Minerai +50 %, attire les objets de loin';

  @override
  String get g_shipPhantomDesc => '25 % de chances de critique x2,5';

  @override
  String get g_shipNovaDesc => 'Chasseur premium aux tirs perforants';

  @override
  String get g_shipAuroraDesc =>
      'Gardien premium qui se répare et porte une barrière';

  @override
  String get g_shipNovaAbility =>
      'Tirs perforants : chaque tir traverse jusqu\'à 2 ennemis';

  @override
  String get g_shipAuroraAbility =>
      'Auto-réparation : +3 % PV/s après 3 s sans dégâts\nGarde : bloque 1 coup toutes les 8 s';

  @override
  String g_unlockSector(int n) {
    return 'Atteindre le secteur $n';
  }

  @override
  String g_unlockBosses(int n) {
    return 'Vaincre $n boss pirates';
  }

  @override
  String g_unlockOre(int n) {
    return 'Collecter $n minerais';
  }

  @override
  String get g_skinDefault => 'Scout de base';

  @override
  String get g_skinCrimson => 'Comète rouge';

  @override
  String get g_skinMint => 'Menthe chocolat';

  @override
  String get g_skinStealth => 'Noir furtif';

  @override
  String get g_skinNeon => 'Rose néon';

  @override
  String get g_skinRainbow => 'Rêve arc-en-ciel';

  @override
  String get g_skinGalaxy => 'Galaxie';

  @override
  String get g_skinGold => 'Or royal';

  @override
  String get g_outfitDefault => 'Combinaison de base';

  @override
  String get g_outfitCat => 'Casque chaton';

  @override
  String get g_outfitBunny => 'Oreilles de lapin';

  @override
  String get g_outfitAlien => 'Antennes d\'alien';

  @override
  String get g_outfitFlower => 'Barrette fleur';

  @override
  String get g_outfitHat => 'Casquette de capitaine';

  @override
  String get g_outfitCrown => 'Couronne galactique';

  @override
  String get g_crewRoleGunner => 'Artilleur';

  @override
  String get g_crewEffectGunner => 'Attaque';

  @override
  String get g_crewRoleEngineer => 'Mécanicien';

  @override
  String get g_crewEffectEngineer => 'PV max et réparation';

  @override
  String get g_crewRolePilot => 'Pilote';

  @override
  String get g_crewEffectPilot => 'Vitesse';

  @override
  String get g_crewRoleTrader => 'Marchand';

  @override
  String get g_crewEffectTrader => 'Revenu en crédits';

  @override
  String get g_crewRoleMiner => 'Mineur';

  @override
  String get g_crewEffectMiner => 'Gain de minerai';

  @override
  String get g_crewRoleScientist => 'Scientifique';

  @override
  String get g_crewEffectScientist => 'Recharge des compétences';

  @override
  String get g_crewName0 => 'Pompon';

  @override
  String get g_crewName1 => 'Coco';

  @override
  String get g_crewName2 => 'Étoile';

  @override
  String get g_crewName3 => 'Tofu';

  @override
  String get g_crewName4 => 'Haricot';

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
  String get g_crewName10 => 'Duvet';

  @override
  String get g_crewName11 => 'Papillon';

  @override
  String get g_crewName12 => 'Choco';

  @override
  String get g_crewName13 => 'Orge';

  @override
  String get g_crewName14 => 'Nuage';

  @override
  String get g_crewName15 => 'Bruine';

  @override
  String get g_crewName16 => 'Tori';

  @override
  String get g_crewName17 => 'Happy';

  @override
  String get g_crewName18 => 'Galette';

  @override
  String get g_crewName19 => 'Mochi';

  @override
  String get g_crewName20 => 'Latte';

  @override
  String get g_crewName21 => 'Cookie';

  @override
  String get g_crewName22 => 'Gelée';

  @override
  String get g_crewName23 => 'Coton';

  @override
  String get g_crewName24 => 'Mangue';

  @override
  String get g_crewName25 => 'Prune';

  @override
  String get g_crewName26 => 'Noisette';

  @override
  String get g_crewName27 => 'Réglisse';

  @override
  String get g_crewName28 => 'Bambi';

  @override
  String get g_crewName29 => 'Cheddar';

  @override
  String get g_crewLegend0 => 'Gardien galactique';

  @override
  String get g_crewLegend1 => 'Héros des étoiles';

  @override
  String get g_crewLegend2 => 'Sage des nébuleuses';

  @override
  String get g_crewLegend3 => 'Chevalier comète';

  @override
  String get g_crewLegend4 => 'Supernova';

  @override
  String g_crewLegendName(String title, String name) {
    return '$title $name';
  }

  @override
  String get g_bldHouse => 'Maison';

  @override
  String g_bldHouseEffect(int n) {
    return 'Habitants +$n (plus de cadeaux)';
  }

  @override
  String get g_bldFarm => 'Ferme spatiale';

  @override
  String g_bldFarmEffect(int n) {
    return 'Revenu en crédits +$n %';
  }

  @override
  String get g_bldMine => 'Mine';

  @override
  String g_bldMineEffect(int n) {
    return 'Gain de minerai +$n %';
  }

  @override
  String get g_bldLab => 'Labo';

  @override
  String g_bldLabEffect(int n) {
    return 'Recharge des compétences -$n %';
  }

  @override
  String get g_bldTower => 'Tour de défense';

  @override
  String g_bldTowerEffect(int n) {
    return 'PV max +$n %';
  }

  @override
  String get g_bldShipyard => 'Chantier naval';

  @override
  String g_bldShipyardEffect(int n) {
    return 'Attaque +$n %';
  }

  @override
  String get g_bldPark => 'Parc d\'attractions';

  @override
  String g_bldParkEffect(int n) {
    return 'Revenu hors ligne +$n pts';
  }

  @override
  String get g_bldStatue => 'Statue du capitaine';

  @override
  String g_bldStatueEffect(int n) {
    return 'Gemmes par cadeau de la planète +$n';
  }

  @override
  String get g_homePalette0 => 'Jardin vert';

  @override
  String get g_homePalette1 => 'Désert de sable';

  @override
  String get g_homePalette2 => 'Royaume de glace';

  @override
  String get g_homePalette3 => 'Île de lave';

  @override
  String get g_homePalette4 => 'Gaz violet';

  @override
  String get g_homePalette5 => 'Fleur de cerisier';

  @override
  String get g_homePalette6 => 'Aurore';

  @override
  String get g_homePalette7 => 'Or';

  @override
  String get g_homeDefaultName => 'Ma petite étoile';

  @override
  String get g_achFirstBloodTitle => 'Premier tir';

  @override
  String get g_achFirstBloodDesc => 'Abattre 1 pirate';

  @override
  String get g_achHunterTitle => 'Chasseur de pirates';

  @override
  String get g_achHunterDesc => 'Abattre 100 pirates';

  @override
  String get g_achLegendTitle => 'Capitaine légendaire';

  @override
  String get g_achLegendDesc => 'Abattre 1000 pirates';

  @override
  String get g_achMinerTitle => 'Roi de la mine';

  @override
  String get g_achMinerDesc => 'Collecter 1000 minerais';

  @override
  String get g_achMiner2Title => 'Magnat du minerai';

  @override
  String get g_achMiner2Desc => 'Collecter 10000 minerais';

  @override
  String get g_achColonistTitle => 'Pionnier';

  @override
  String get g_achColonistDesc => 'Coloniser 5 planètes';

  @override
  String get g_achMetropolisTitle => 'Métropole';

  @override
  String get g_achMetropolisDesc => 'Monter une colonie au Lv.5';

  @override
  String get g_achBuilderTitle => 'Bâtisseur';

  @override
  String get g_achBuilderDesc => 'Construire 3 stations';

  @override
  String get g_achBoss1Title => 'Chasse au boss';

  @override
  String get g_achBoss1Desc => 'Vaincre un boss pirate';

  @override
  String get g_achBoss10Title => 'Tueur de boss';

  @override
  String get g_achBoss10Desc => 'Vaincre des boss pirates 10 fois';

  @override
  String get g_achExplorerTitle => 'Explorateur';

  @override
  String get g_achExplorerDesc => 'Atteindre le secteur 3';

  @override
  String get g_achVoyagerTitle => 'Voyageur';

  @override
  String get g_achVoyagerDesc => 'Atteindre le secteur 6';

  @override
  String get g_achRichTitle => 'Capitaine fortuné';

  @override
  String get g_achRichDesc => 'Posséder 10000 crédits';

  @override
  String get g_achCrew6Title => 'Équipage fiable';

  @override
  String get g_achCrew6Desc => 'Recruter 6 équipiers';

  @override
  String get g_achCrew3starTitle => 'Compagnon légendaire';

  @override
  String get g_achCrew3starDesc => 'Recruter un équipier ★3';

  @override
  String get g_achMissionsTitle => 'As des missions';

  @override
  String get g_achMissionsDesc => 'Terminer 20 missions';

  @override
  String get g_achJellyTitle => 'Expert en méduses';

  @override
  String get g_achJellyDesc => 'Vaincre 10 méduses spatiales';

  @override
  String get g_achFashionTitle => 'Fashionista';

  @override
  String get g_achFashionDesc => 'Acheter un cosmétique';

  @override
  String get g_achAscendTitle => 'Nouveau départ';

  @override
  String get g_achAscendDesc => 'Renaître grâce à l\'honneur galactique';

  @override
  String get g_achDroneTitle => 'Drone fidèle';

  @override
  String get g_achDroneDesc => 'Équiper un drone de combat';

  @override
  String get g_achHome5Title => 'Architecte planétaire';

  @override
  String get g_achHome5Desc => '5 bâtiments sur ma planète';

  @override
  String get g_achHomeMaxTitle => 'Planète de rêve';

  @override
  String get g_achHomeMaxDesc => 'Ma planète au niveau max';

  @override
  String get g_dailyKill => 'Abattre 30 pirates';

  @override
  String get g_dailyOre => 'Collecter 300 minerais';

  @override
  String get g_dailyMission => 'Terminer 2 missions';

  @override
  String get g_dailyColony => 'Faire grandir des colonies 2 fois';

  @override
  String get g_dailyBoss => 'Vaincre un boss pirate';

  @override
  String get g_dailyPower => 'Ramasser 3 bonus';

  @override
  String get g_dailyPlay => 'Jouer 10 minutes';

  @override
  String get g_dailyJelly => 'Vaincre 3 méduses spatiales';

  @override
  String g_missionKill(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Éliminer $n pirates',
      one: 'Éliminer $n pirate',
    );
    return '$_temp0';
  }

  @override
  String g_missionMine(int n) {
    return 'Collecter $n minerais';
  }

  @override
  String g_missionDeliver(String planet) {
    return 'Livrer une cargaison à $planet';
  }

  @override
  String g_missionBounty(String name) {
    return 'Recherché : $name';
  }

  @override
  String get g_bounty0 => 'Jack le Borgne';

  @override
  String get g_bounty1 => 'Molly l\'Éclair';

  @override
  String get g_bounty2 => 'Bark, roi de la ferraille';

  @override
  String get g_bounty3 => 'Toto Barbe-Rouge';

  @override
  String get g_bounty4 => 'Lena l\'Ombre';

  @override
  String get g_bounty5 => 'Pork le Dodu';

  @override
  String get g_bounty6 => 'Gigi Deux-Lames';

  @override
  String get g_bounty7 => 'Bud le Marteau fou';

  @override
  String get g_bounty8 => 'Lucy la Renarde galactique';

  @override
  String get g_bounty9 => 'Capitaine Bones le Squelette';

  @override
  String get g_storyAsteroidsTitle => 'Détruire 3 astéroïdes';

  @override
  String get g_storyAsteroidsLine0 =>
      'Capitaine ! D\'abord, détruisez des astéroïdes pour récolter du minerai.';

  @override
  String get g_storyAsteroidsLine1 =>
      'Déplacez-vous avec le joystick et tirez avec le bouton de tir !';

  @override
  String get g_storyKillsTitle => 'Abattre 3 pirates';

  @override
  String get g_storyKillsLine0 => 'Pirates au radar ! Suivez la flèche rouge.';

  @override
  String get g_storyKillsLine1 =>
      'Des pirates ? Rien que de la ferraille face à mon vaisseau !';

  @override
  String get g_storyColoniesTitle => 'S’installer sur Mars';

  @override
  String get g_storyColoniesLine0 =>
      'Fondez votre première colonie sur Mars, la planète rouge voisine de la Terre. Approchez-vous et le bouton d’installation apparaîtra.';

  @override
  String get g_storyColoniesLine1 =>
      'Les colonies rapportent des crédits même pendant que vous vous reposez !';

  @override
  String get g_storyShipLevelsTitle => 'Améliorer le vaisseau à une station';

  @override
  String get g_storyShipLevelsLine0 =>
      'Retournez à la base Haven pour améliorer votre vaisseau. Près des stations, vous êtes aussi réparé.';

  @override
  String get g_storyCrewTitle => 'Recruter 1 équipier';

  @override
  String get g_storyCrewLine0 =>
      'On se sent seul ici ? Recrutez un compagnon dans l\'onglet Équipage du menu de la station !';

  @override
  String get g_storyMissionsTitle => 'Terminer 1 mission';

  @override
  String get g_storyMissionsLine0 =>
      'Acceptez un contrat au tableau des missions de la station. La paie est juteuse.';

  @override
  String get g_storyStationsTitle => 'Construire une nouvelle station';

  @override
  String get g_storyStationsLine0 =>
      'Il est temps de s\'étendre ! Construisez une station dans l\'espace libre, loin des planètes.';

  @override
  String get g_storyDevPercentTitle => 'Système à 100 %';

  @override
  String get g_storyDevPercentLine0 =>
      'Montez chaque planète au Lv.3 pour ouvrir le système suivant. Voyez le bouton Système en haut à droite !';

  @override
  String get g_storySectorTitle => 'Saut vers le système suivant';

  @override
  String get g_storySectorLine0 =>
      'La porte de distorsion est ouverte ! Allez à la porte violette sur la mini-carte.';

  @override
  String get g_storySectorLine1 => 'Tout un nouvel univers nous attend !';

  @override
  String g_storyDevNTitle(int n) {
    return 'Système $n à 100 %';
  }

  @override
  String get g_storyDevNLine =>
      'Montez chaque planète du nouveau système au Lv.3 !';

  @override
  String g_systemN(int n) {
    return 'Système $n';
  }

  @override
  String g_storyWarpNTitle(String system) {
    return 'Saut vers : $system';
  }

  @override
  String get g_storyWarpNLine =>
      'La porte est ouverte. On s\'enfonce plus loin dans l\'espace ?';

  @override
  String get g_powerUpRapid => 'Tir rapide';

  @override
  String get g_powerUpShield => 'Bouclier';

  @override
  String get g_powerUpMagnet => 'Aimant';

  @override
  String get g_powerUpDoubleCredits => 'Crédits x2';

  @override
  String get g_planetKindGarden => 'Planète jardin';

  @override
  String get g_planetKindDesert => 'Planète désertique';

  @override
  String get g_planetKindIce => 'Planète glacée';

  @override
  String get g_planetKindLava => 'Planète de lave';

  @override
  String get g_planetKindGas => 'Planète gazeuse';

  @override
  String get g_colonyBldTurret => 'Tourelle';

  @override
  String get g_colonyBldMine => 'Foreuse';

  @override
  String get g_colonyBldTrade => 'Comptoir';

  @override
  String get g_colonyBldDock => 'Dock de réparation';

  @override
  String get g_colonyBldShieldGen => 'Générateur de bouclier';

  @override
  String get g_colonyBldBlurbTurret =>
      'Tire tout seul sur les pirates près de la colonie. Indispensable contre les raids !';

  @override
  String get g_colonyBldBlurbMine =>
      'Extrait du minerai et envoie des 💎 chaque seconde.';

  @override
  String get g_colonyBldBlurbTrade =>
      'Augmente le revenu en crédits de cette colonie de 25 % par niveau.';

  @override
  String get g_colonyBldBlurbDock =>
      'Répare votre vaisseau quand vous êtes à proximité.';

  @override
  String get g_colonyBldBlurbShieldGen =>
      'Augmente la capacité du bouclier et sa vitesse de recharge.';

  @override
  String get g_stationRoleHome => 'Base principale';

  @override
  String get g_stationRoleDefense => 'Base de défense';

  @override
  String get g_stationRoleRepair => 'Base de réparation';

  @override
  String get g_stationRoleSupport => 'Base de ravitaillement';

  @override
  String get g_stationRoleBlurbHome => 'Batterie laser et zone sûre';

  @override
  String get g_stationRoleBlurbDefense =>
      'Tourelle puissante · Résistance x2 · bloque les tirs ennemis proches';

  @override
  String get g_stationRoleBlurbRepair =>
      'Réparation rapide étendue · relance à 10 % du coût · recharge x2 des boucliers des colonies proches';

  @override
  String get g_stationRoleBlurbSupport =>
      'Production des colonies proches +25 % (+5 % par niveau d\'habitat)';

  @override
  String g_eventRaid(String planet) {
    return 'Raid sur $planet';
  }

  @override
  String get g_eventMeteor => 'Pluie de météores';

  @override
  String get g_eventMerchant => 'Marchande ambulante';

  @override
  String get g_eventSupply => 'Capsule de ravitaillement';

  @override
  String get g_productGems100Title => 'Poignée de gemmes';

  @override
  String get g_productGems550Title => 'Bourse de gemmes';

  @override
  String get g_productGems1200Title => 'Coffre de gemmes';

  @override
  String get g_productStarterTitle => 'Pack de départ';

  @override
  String get g_productPassTitle => 'Pass Commandant';

  @override
  String get g_productGems550Desc => '⭐550 (+10 % de bonus)';

  @override
  String get g_productGems1200Desc => '⭐1200 (+20 % de bonus)';

  @override
  String get g_productStarterDesc =>
      '⭐300 + skin exclusif « Galaxie » + équipier ★3 (une seule fois)';

  @override
  String get g_productPassDesc =>
      'Revenu en crédits +25 %, revenu hors ligne 8 h, récompenses sans pub, skin exclusif « Or royal »';

  @override
  String g_testPurchaseTitle(String product) {
    return '[Achat test] $product';
  }

  @override
  String g_testPurchaseBody(String desc, String price) {
    return 'Aucun paiement réel ne sera effectué.\n$desc\nPrix : $price';
  }

  @override
  String get g_testAdTitle => '[Pub test]';

  @override
  String get g_testAdBody => 'Considérer la pub comme regardée en entier ?';

  @override
  String get g_webDemoTitle => 'Démo web';

  @override
  String get g_webDemoBody =>
      'Les achats et récompenses de pub sont disponibles dans l\'app mobile.';

  @override
  String get g_notifChannelName => 'Rappels de retour';

  @override
  String get g_notifChannelDesc =>
      'Rappels pour le revenu des colonies et les récompenses quotidiennes';

  @override
  String get g_notifStorageTitle => 'L\'entrepôt de votre colonie est plein !';

  @override
  String get g_notifStorageBody =>
      'Capitaine, venez récupérer vos crédits avant que le revenu ne s\'arrête !';

  @override
  String get g_notifPiratesTitle =>
      'Les pirates sèment à nouveau la pagaille !';

  @override
  String get g_notifPiratesBody =>
      'La récompense de connexion et les quêtes du jour vous attendent.';

  @override
  String get g_upgradeWeapon => 'Arme';

  @override
  String get g_upgradeHull => 'Blindage';

  @override
  String get g_upgradeEngine => 'Moteur';

  @override
  String get g_upgradeMissile => 'Missile à tête chercheuse';

  @override
  String get g_upgradeShield => 'Bouclier d\'énergie';

  @override
  String get g_upgradeDrone => 'Drone de combat';

  @override
  String get g_upgradeMagnet => 'Aimant';

  @override
  String g_unknownSector(int n) {
    return 'Secteur inconnu $n';
  }

  @override
  String get g_stationHaven => 'Base Haven';

  @override
  String g_stationOutpost(String sector) {
    return 'Avant-poste $sector';
  }

  @override
  String g_stationNumbered(String role, int n) {
    return '$role n°$n';
  }

  @override
  String get g_dlgWelcome =>
      'Bienvenue, Capitaine ! Je suis Mina, votre seconde.';

  @override
  String get g_dlgMissionsCancelled =>
      'Les missions de livraison et de prime du secteur précédent ont été annulées.';

  @override
  String get g_floatDisabled => 'Hors service !';

  @override
  String get g_floatRebooted => 'De retour !';

  @override
  String get g_dlgBaseRebooted =>
      'La base principale est de retour ! Résistance restaurée à 30 %.';

  @override
  String get g_dlgUpWeapon => 'Armes améliorées ! Gare à vous, les pirates !';

  @override
  String get g_dlgUpHull => 'Blindage amélioré ! Je me sens plus solide.';

  @override
  String get g_dlgUpEngine => 'Moteur amélioré ! Plus vite !';

  @override
  String get g_dlgMissileNew => 'Missiles à tête chercheuse équipés ! (Q)';

  @override
  String get g_dlgMissileUp => 'Missiles améliorés !';

  @override
  String get g_dlgShieldNew => 'Bouclier d\'énergie équipé ! (F)';

  @override
  String get g_dlgShieldUp => 'Bouclier amélioré !';

  @override
  String get g_dlgDroneNew => 'Drone de combat lancé ! Un nouvel ami fidèle.';

  @override
  String get g_dlgDroneUp => 'Drone amélioré !';

  @override
  String get g_dlgUpMagnet =>
      'Aimant amélioré ! Les crédits volent droit vers moi !';

  @override
  String get g_dlgNotOver => 'Ce n\'est pas encore fini !';

  @override
  String get g_floatBlocked => 'Bloqué !';

  @override
  String get g_floatGuard => 'Protégé !';

  @override
  String get g_pirateBossLose => 'Argh ! Ce secteur… est à toi…';

  @override
  String get g_pirateBossFlee => 'Argh ! Je m\'en souviendrai, Capitaine !';

  @override
  String get g_dlgSupplyCollected => 'Capsule de ravitaillement récupérée !';

  @override
  String get g_merchantBye => 'À la prochaine~ miaou !';

  @override
  String get g_pirateRaidTaunt =>
      'Cette colonie est à nous maintenant ! Hahaha !';

  @override
  String get g_dlgMeteor =>
      'Pluie de météores repérée ! Pleine de cristaux. Gros filon de minerai !';

  @override
  String get g_merchantHello =>
      'Nyang-nyang, la marchande ambulante, est là~ Plein de bonnes affaires, miaou !';

  @override
  String get g_dlgSupplySignal =>
      'Signal d\'une capsule de ravitaillement avec des gemmes ! Des pirates la gardent, soyez prudent.';

  @override
  String get g_dlgBossWarning =>
      'Alerte ! Le vaisseau du boss du secteur approche !';

  @override
  String get g_pirateRevenge => 'Je reviens me venger ! Prépare-toi !';

  @override
  String get g_floatShieldBroken => 'Brisé !';

  @override
  String get g_floatShieldBack => 'Rétabli';

  @override
  String get g_floatGoalDone => 'Objectif atteint !';

  @override
  String g_dlgArrived(String sector) {
    return 'Arrivée : $sector !';
  }

  @override
  String get g_dlgNewFrontier => 'Une toute nouvelle frontière.';

  @override
  String g_dlgBaseUpgraded(String station, int level) {
    return '$station : Lv.$level ! Les lasers sont plus puissants.';
  }

  @override
  String g_dlgBaseDisabled(int sec) {
    return 'Base principale hors service ! Protection coupée pendant ${sec}s !';
  }

  @override
  String g_dlgSettled(String planet) {
    return 'Drapeau planté sur $planet ! Colonisation réussie !';
  }

  @override
  String g_dlgStationBuilt(String station, String blurb) {
    return '$station : construction terminée ! $blurb';
  }

  @override
  String g_dlgHabitatUp(String station, int level) {
    return '$station : habitat Lv.$level !';
  }

  @override
  String g_dlgTurretUp(String station, int level) {
    return '$station : tourelle Lv.$level !';
  }

  @override
  String g_dlgShipSwitched(String ship) {
    return 'Je pilote maintenant le $ship ! Ça me plaît !';
  }

  @override
  String g_dlgOreSold(int n, int credits) {
    return '$n minerais vendus pour 💰$credits.';
  }

  @override
  String g_dlgCrewJoined(String stars, String role, String name) {
    return '$stars $role $name a rejoint l\'équipage !';
  }

  @override
  String g_dlgCrewLevel(String name, int level) {
    return '$name passe au Lv.$level ! En progrès.';
  }

  @override
  String g_dlgCargoLoaded(String mission) {
    return 'Cargaison chargée ! $mission';
  }

  @override
  String g_dlgBountyTaunt(String name) {
    return 'Tu crois pouvoir attraper $name ? Viens donc essayer !';
  }

  @override
  String get g_floatMissionDone => 'Mission accomplie !';

  @override
  String g_dlgMissionDone(String mission) {
    return 'Mission accomplie : $mission !';
  }

  @override
  String g_dlgRepairCost(int credits) {
    return 'Vous êtes sain et sauf, Capitaine ! Réparations : 💰$credits.';
  }

  @override
  String g_dlgSectorDeveloped(String sector) {
    return '$sector entièrement développé ! La porte de distorsion vers le système suivant est ouverte.';
  }

  @override
  String g_floatCrit(int dmg) {
    return 'Critique ! $dmg';
  }

  @override
  String g_dlgStationDestroyed(String station) {
    return 'Nous avons perdu $station ! Il nous faut des tourelles !';
  }

  @override
  String g_dlgBossDefeated(int credits) {
    return 'Boss du secteur vaincu ! Récompense 💰$credits';
  }

  @override
  String g_dlgBountyCaught(String name) {
    return 'Cible capturée : $name !';
  }

  @override
  String g_dlgRaidDefended(String planet, int credits) {
    return 'Raid repoussé sur $planet ! Les habitants reconnaissants envoient 💰$credits ⭐2.';
  }

  @override
  String g_dlgRaidLooted(String planet, String level) {
    return '$planet a été pillé et redescend à $level… 😢';
  }

  @override
  String g_dlgRaidLeft(String planet) {
    return 'Les pirates ont pillé $planet et sont partis.';
  }

  @override
  String g_dlgRaidAlert(String planet) {
    return 'Urgence ! Des pirates attaquent $planet ! La production est à l\'arrêt !';
  }

  @override
  String g_pirateBossArrive(String sector) {
    return 'Je règne sur $sector ! Approche, petit capitaine !';
  }

  @override
  String g_dlgWelcomeBack(String goal) {
    return 'Bon retour, Capitaine ! Objectif actuel : $goal';
  }

  @override
  String get g_pirateWin0 => 'Hahaha ! Pas si coriace !';

  @override
  String get g_pirateWin1 => 'Reviens plus fort la prochaine fois, gamin !';

  @override
  String get g_pirateWin2 => 'Ton vaisseau n\'est plus que de la ferraille !';

  @override
  String get g_pirateRage0 => 'Sortez, les gars ! Donnez-leur une leçon !';

  @override
  String get g_pirateRage1 => 'Maintenant, ça devient sérieux !';

  @override
  String get g_pirateRage2 => 'Tu m\'as mis en colère, hein ?!';

  @override
  String get g_captainKill0 => 'Un de moins !';

  @override
  String get g_captainKill1 => 'Où tu crois aller comme ça !';

  @override
  String get g_captainKill2 => 'Ce territoire est à moi !';

  @override
  String get g_captainKill3 => 'Au suivant !';

  @override
  String get g_pirateAmbush0 => 'Hahaha ! Lâche ta cargaison !';

  @override
  String get g_pirateAmbush1 => 'C\'est le territoire de notre bande !';

  @override
  String get g_pirateAmbush2 => 'Donne-nous ces jolis crédits brillants !';

  @override
  String get g_pirateAmbush3 => 'Pas ton jour, gamin !';

  @override
  String get cat_sysSol => 'Système solaire';

  @override
  String get cat_sysAlphaCen => 'Alpha du Centaure';

  @override
  String get cat_sysBarnard => 'Étoile de Barnard';

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
  String get cat_sysTeegarden => 'Étoile de Teegarden';

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
  String get cat_sysOmegaCen => 'Amas Oméga du Centaure';

  @override
  String get cat_sysSgrA => 'Centre galactique (Sgr A*)';

  @override
  String get cat_sysLMC => 'Grand Nuage de Magellan';

  @override
  String get cat_sysSMC => 'Petit Nuage de Magellan';

  @override
  String get cat_sysAndromeda => 'Galaxie d\'Andromède';

  @override
  String get cat_sysTriangulum => 'Galaxie du Triangle';

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
  String get cat_moon => 'Lune';

  @override
  String get cat_venus => 'Vénus';

  @override
  String get cat_mercury => 'Mercure';

  @override
  String get cat_ceres => 'Cérès';

  @override
  String get cat_vesta => 'Vesta';

  @override
  String get cat_jupiter => 'Jupiter';

  @override
  String get cat_io => 'Io';

  @override
  String get cat_europa => 'Europe';

  @override
  String get cat_ganymede => 'Ganymède';

  @override
  String get cat_callisto => 'Callisto';

  @override
  String get cat_saturn => 'Saturne';

  @override
  String get cat_enceladus => 'Encelade';

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
  String get cat_pluto => 'Pluton';

  @override
  String get cat_charon => 'Charon';

  @override
  String get cat_haumea => 'Haumea';

  @override
  String get cat_makemake => 'Makémaké';

  @override
  String get cat_eris => 'Éris';

  @override
  String get cat_sedna => 'Sedna';

  @override
  String get cat_planetNine => 'Planète Neuf';

  @override
  String get u_topUpTitle => 'Crédits insuffisants';

  @override
  String u_topUpBody(int credits, int gems) {
    return 'Il manque 💰$credits. Utiliser ⭐$gems pour compléter et continuer ?';
  }

  @override
  String u_topUpNoGems(int gems) {
    return 'Il faut ⭐$gems. Acheter des gemmes dans la boutique ?';
  }

  @override
  String get u_topUpOk => 'Compléter';

  @override
  String get u_goShop => 'Boutique';

  @override
  String get u_exchangeTitle => '💰 Échanger des crédits';

  @override
  String u_exchangeBody(int gems, int credits) {
    return 'Échanger ⭐$gems contre 💰$credits ?';
  }
}
