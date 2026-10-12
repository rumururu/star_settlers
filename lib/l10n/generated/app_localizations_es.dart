// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class L10nEs extends L10n {
  L10nEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Star Settlers';

  @override
  String get languageName => 'Español';

  @override
  String get u_tabShip => 'Nave';

  @override
  String get u_tabStation => 'Estación';

  @override
  String get u_tabCrew => 'Tripulación';

  @override
  String get u_tabMission => 'Misiones';

  @override
  String get u_tabMarket => 'Mercado';

  @override
  String u_upWeapon(int dmg) {
    return 'Daño $dmg · Lv.3 doble · Lv.6 triple';
  }

  @override
  String u_upHull(int hp) {
    return 'PV máx. $hp';
  }

  @override
  String u_upEngine(int speed) {
    return 'Vel. máx. $speed';
  }

  @override
  String get u_upMissileIntro => 'Misiles teledirigidos (tecla Q / botón 🚀)';

  @override
  String u_upMissile(int count, String cooldown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count misiles',
      one: '1 misil',
    );
    return '$_temp0 · recarga $cooldown s';
  }

  @override
  String get u_upShieldIntro =>
      'Escudo que bloquea todo el daño (tecla F / botón 🛡)';

  @override
  String u_upShield(String duration, String cooldown) {
    return '$duration s · recarga $cooldown s';
  }

  @override
  String get u_upDroneIntro =>
      'Gira a tu alrededor, dispara solo y atrae objetos';

  @override
  String u_upDrone(int dmg, String interval) {
    return 'Daño $dmg · dispara cada $interval s';
  }

  @override
  String u_upMagnet(int range, String power) {
    return 'Atrae créditos y mineral · alcance $range · fuerza x$power';
  }

  @override
  String get u_equip => 'Equipar';

  @override
  String get u_hangarSection => '🛸 Hangar';

  @override
  String get u_viewLarge => 'Ver';

  @override
  String get u_hp => 'PV';

  @override
  String get u_speed => 'Velocidad';

  @override
  String get u_attack => 'Ataque';

  @override
  String get u_fireRate => 'Cadencia';

  @override
  String get u_ore => 'Mineral';

  @override
  String get u_crit => 'Crítico';

  @override
  String get u_boarded => 'A bordo';

  @override
  String get u_board => 'Subir';

  @override
  String get u_boardNow => 'Subir';

  @override
  String get u_gemsOnly => 'Solo con gemas';

  @override
  String u_unlockOrGems(String condition) {
    return 'Desbloqueo: $condition o gemas';
  }

  @override
  String u_unlock(String condition) {
    return 'Desbloqueo: $condition';
  }

  @override
  String u_durability(int hp, int max) {
    return 'Casco $hp / $max';
  }

  @override
  String get u_habitat => 'Hábitat';

  @override
  String u_habitatDesc(String rate, int hp) {
    return 'Ingresos 💰$rate/s · Casco $hp';
  }

  @override
  String get u_turret => 'Torreta defensiva';

  @override
  String get u_turretIntro => 'Dispara a los piratas automáticamente';

  @override
  String u_turretDesc(int dmg, int range) {
    return 'Daño $dmg · Alcance $range';
  }

  @override
  String get u_baseUpgrade => 'Mejora de base';

  @override
  String u_baseDesc(int dmg, int range, int hp) {
    return 'Láser $dmg · Alcance $range · Casco $hp';
  }

  @override
  String u_disabledSec(int sec) {
    return 'Inactiva $sec s';
  }

  @override
  String u_sectorStatus(String sector) {
    return 'Estado de $sector';
  }

  @override
  String u_sectorStats(
    int colonies,
    int planets,
    int stations,
    String mul,
    String other,
  ) {
    return 'Planetas colonizados $colonies / $planets\nEstaciones: $stations\nBonus de sistema: producción x$mul\nOtros sistemas: 💰$other/s';
  }

  @override
  String get u_legendaryGet => '🌟 ¡Legendario! 🌟';

  @override
  String get u_rareGet => '✨ ¡Tripulante raro! ✨';

  @override
  String get u_newCrew => '¡Nuevo tripulante!';

  @override
  String get u_great => '¡Genial!';

  @override
  String u_crewHeader(int count, int cap, int assigned, int slots) {
    return 'Tripulación $count/$cap · Asignados $assigned/$slots';
  }

  @override
  String u_recruit(int cost) {
    return 'Reclutar 💰$cost';
  }

  @override
  String u_recruitPremium(int cost) {
    return 'Reclutamiento premium ⭐$cost';
  }

  @override
  String u_recruitLegendary(int cost) {
    return '🌟 Legendario garantizado ⭐$cost';
  }

  @override
  String u_recruitOdds(String normal, String premium) {
    return 'Probabilidades · Reclutar: $normal\nReclutamiento premium: $premium\nLegendario garantizado: ★4 100%';
  }

  @override
  String u_slotMax(int n) {
    return 'Puestos MÁX. ($n)';
  }

  @override
  String u_slotBuy(int price) {
    return 'Puesto +1 ⭐$price';
  }

  @override
  String u_rosterMax(int n) {
    return 'Plantilla MÁX. ($n)';
  }

  @override
  String u_rosterBuy(int size, int price) {
    return 'Plantilla +$size ⭐$price';
  }

  @override
  String get u_noCrew =>
      'Aún no hay tripulantes. ¡Recluta y asígnalos a tu nave!';

  @override
  String get u_unassign => 'Retirar';

  @override
  String get u_assign => 'Asignar';

  @override
  String get u_dismiss => 'Despedir';

  @override
  String get u_dismissCrewTitle => 'Despedir tripulante';

  @override
  String u_dismissCrewBody(String name) {
    return '¿Dejar ir a $name? No se puede deshacer.';
  }

  @override
  String get u_missionDeliverHint => 'Ve al destino (flecha amarilla)';

  @override
  String get u_missionBountyHint =>
      'Encuentra y derrota al objetivo (flecha amarilla)';

  @override
  String u_reward(String rewards) {
    return 'Recompensa $rewards';
  }

  @override
  String u_activeMissions(int n) {
    return 'En curso ($n/3)';
  }

  @override
  String get u_noActiveMissions => 'No hay misiones en curso.';

  @override
  String get u_abandon => 'Abandonar';

  @override
  String u_missionBoard(int sec) {
    return 'Tablón de misiones · nuevas en $sec s';
  }

  @override
  String get u_accept => 'Aceptar';

  @override
  String get u_priceHigh => '📈 ¡Alto! Hora de vender';

  @override
  String get u_priceLow => '📉 Bajo… mejor espera';

  @override
  String get u_priceNormal => '➡ Normal';

  @override
  String get u_orePrice => 'Precio del mineral';

  @override
  String get u_sell100 => 'Vender 100';

  @override
  String get u_sellHalf => 'Vender mitad';

  @override
  String get u_sellAll => 'Vender todo';

  @override
  String get u_marketTip =>
      'Los precios suben y bajan con el tiempo. ¡Vende caro!';

  @override
  String get u_gemExchange => '⭐ Canje de gemas estelares';

  @override
  String get u_creditPack => 'Paquete de créditos';

  @override
  String get u_exchange => 'Canjear';

  @override
  String get u_openShop => '⭐ Abrir tienda';

  @override
  String u_achievementDone(String title, int gems) {
    return '🏆 Logro: ¡$title! Reclama ⭐$gems en Menú > Logros.';
  }

  @override
  String get u_cannotDo =>
      'No tienes recursos suficientes o no puedes hacerlo ahora.';

  @override
  String get u_welcomeBack => '¡Bienvenido de nuevo, capitán!';

  @override
  String u_offlineHm(int h, int m) {
    return 'Durante tus $h h $m min fuera,\n¡tus colonias trabajaron duro!';
  }

  @override
  String u_offlineM(int m) {
    return 'Durante tus $m min fuera,\n¡tus colonias trabajaron duro!';
  }

  @override
  String get u_passOfflineHint =>
      'Pase de Comandante: hasta 8 h + x2 automático';

  @override
  String get u_collect => 'Recoger';

  @override
  String get u_adLoading =>
      'Cargando anuncio. Inténtalo de nuevo en un momento.';

  @override
  String get u_adLoadingRetry =>
      'Cargando anuncio. Vuelve a tocar en un momento.';

  @override
  String get u_collectDouble => 'Recoger x2 👑';

  @override
  String get u_adDouble => '📺 Ver anuncio para x2';

  @override
  String get u_galaxyHonor => '🌌 Honor galáctico';

  @override
  String u_honorStatus(int honor, int ascensions) {
    return 'Honor $honor (ascendido $ascensions veces)';
  }

  @override
  String u_honorBonus(int income, int attack) {
    return 'Ingresos +$income% · Daño +$attack%';
  }

  @override
  String get u_ascendExplain =>
      'Ascender reinicia este universo (sistemas, colonias, estaciones, mejoras de nave, tripulación, créditos)\ny te otorga honor, un bonus permanente.\nSe conservan gemas, cosméticos, naves y logros.';

  @override
  String u_ascendGain(int gain) {
    return '¡Asciende ahora y gana +$gain de honor!\n(Cuanto mayor tu imperio, más obtienes)';
  }

  @override
  String get u_ascendLocked => 'Llega al sistema 4 para ascender.';

  @override
  String get u_close => 'Cerrar';

  @override
  String u_ascendBtn(int gain) {
    return 'Ascender (+$gain)';
  }

  @override
  String get u_ascendConfirmTitle => '¿Seguro que quieres ascender?';

  @override
  String get u_ascendConfirmBody =>
      'Tu universo actual se reiniciará. No se puede deshacer.';

  @override
  String get u_ascend => 'Ascender';

  @override
  String u_shieldBroken(String name) {
    return '$name roto';
  }

  @override
  String u_hudSector(String sector, int dev, String threat, String value) {
    return '$sector · Des. $dev%\n⚠ Amenaza $threat  🏛 $value';
  }

  @override
  String u_baseDisabled(int sec) {
    return 'Base caída ${sec}s';
  }

  @override
  String u_baseHp(int pct) {
    return 'Base $pct%';
  }

  @override
  String get u_merchantE => 'Mercader (E)';

  @override
  String get u_nextSectorE => 'Sistema sig. (E)';

  @override
  String get u_prevSectorE => 'Sistema ant. (E)';

  @override
  String u_gateLocked(int pct) {
    return '🔒 Se abre al 100% de desarrollo ($pct%)';
  }

  @override
  String u_settle(String name) {
    return 'Colonizar $name';
  }

  @override
  String u_manageE(String name) {
    return 'Gestionar $name (E)';
  }

  @override
  String get u_buildStation => 'Construir estación';

  @override
  String get u_fire => 'FUEGO';

  @override
  String get u_equipAtStation =>
      '¡Puedes equiparlo en la pestaña Nave de la estación!';

  @override
  String get u_shotDown => '💥 ¡Te han derribado!';

  @override
  String u_autoRespawn(int sec) {
    return 'Reaparición automática en la base en $sec s';
  }

  @override
  String get u_reviveFree => '👑 Revivir aquí (gratis)';

  @override
  String get u_reviveAd => '📺 Ver anuncio para revivir aquí';

  @override
  String get u_reviveGems => 'Revivir aquí por ⭐10';

  @override
  String u_respawnBase(int pct) {
    return '🏠 Reaparecer en la base (pierdes $pct% de créditos)';
  }

  @override
  String get u_spkCaptain => 'Capitán';

  @override
  String get u_spkPirate => 'Pirata';

  @override
  String get u_spkAdvisor => 'Tte. Mina';

  @override
  String get u_spkMerchant => 'Nyang, el mercader';

  @override
  String get u_paused => 'Pausa';

  @override
  String u_pauseStats(
    String sector,
    int kills,
    int crew,
    int colonies,
    int stations,
    int missions,
  ) {
    return '$sector · Derribos $kills · Tripulación $crew\nColonias $colonies · Estaciones $stations · Misiones $missions';
  }

  @override
  String get u_resume => '▶︎ Continuar';

  @override
  String get u_shop => '⭐ Tienda';

  @override
  String get u_achievements => '🏆 Logros';

  @override
  String get u_dailyQuests => '📅 Misiones diarias';

  @override
  String get u_myPlanet => '🌍 Mi planeta';

  @override
  String get u_ascendMenu => '🌌 Honor galáctico (Ascender)';

  @override
  String get u_settings => '⚙ Ajustes';

  @override
  String get u_saveAndQuit => '💾 Guardar y volver al título';

  @override
  String get u_keyboardHelp =>
      'Teclas: WASD mover · Space disparar · Q misil · F escudo · Shift impulso\nE interactuar · B construir estación · Esc menú';

  @override
  String get u_recharging => 'Recargando';

  @override
  String get u_tutDome => 'Escudo\nseguro dentro';

  @override
  String get u_tutLevelUp => 'Subir nivel\ningresos·edificios↑';

  @override
  String get u_tutTurret => 'Torreta';

  @override
  String get u_tutRepair => 'Reparar';

  @override
  String get u_tutRaid => 'Frenar asaltos';

  @override
  String get u_gotIt => 'Entendido';

  @override
  String u_damage(int dmg) {
    return 'Daño $dmg';
  }

  @override
  String u_oreRate(String rate) {
    return 'Mineral +$rate/s';
  }

  @override
  String u_incomePct(int pct) {
    return 'Ingresos +$pct%';
  }

  @override
  String u_repairRate(int hp) {
    return 'PV +$hp/s';
  }

  @override
  String u_shieldPlus(int amount) {
    return 'Escudo +$amount';
  }

  @override
  String u_systemTitle(String sector, int n) {
    return '$sector · Sistema $n';
  }

  @override
  String u_systemInfo(String threat, String mul) {
    return 'Amenaza $threat · Recursos x$mul';
  }

  @override
  String u_development(int pct) {
    return 'Desarrollo $pct%';
  }

  @override
  String get u_nextSystemOpen => 'Siguiente sistema abierto';

  @override
  String get u_opensAt100 => 'Se abre al 100%';

  @override
  String get u_devHint => 'Sube todos los planetas a Lv.3 para el 100%';

  @override
  String get u_conqueredSystems => 'Sistemas conquistados (siguen produciendo)';

  @override
  String get u_unsettled => 'Sin colonizar';

  @override
  String get u_underRaid => 'Bajo asalto';

  @override
  String u_unknownSector(int n) {
    return 'Sistema desconocido $n';
  }

  @override
  String u_sectorDev(String name, int pct) {
    return '$name · Des. $pct%';
  }

  @override
  String get u_buildStationTitle => 'Construir estación · Elige un rol';

  @override
  String get u_cost => 'Coste';

  @override
  String get u_build => 'Construir';

  @override
  String get u_toNextSector => '🌀 Al siguiente sistema';

  @override
  String get u_bossLocked => '🔒 Derrota al jefe para abrir';

  @override
  String get u_toPrevSector => '🌀 Al sistema anterior';

  @override
  String get u_raidAlert => '⚠ ¡Bajo asalto!';

  @override
  String u_rechargePct(int pct) {
    return 'Recarga $pct%';
  }

  @override
  String u_merchantLabel(int sec) {
    return '🛒 Mercader errante ($sec s)';
  }

  @override
  String get u_supplyPod => '📦 Cápsula de suministros';

  @override
  String u_sectorBoss(String sector) {
    return '☠ Jefe de $sector';
  }

  @override
  String get u_pirateBoss => '☠ Jefe pirata';

  @override
  String get u_merchantName => 'Nyang, mercader errante';

  @override
  String u_merchantLeaves(int sec, String credits) {
    return 'Se va en $sec s · 💰$credits';
  }

  @override
  String get u_rareCrewOffer => 'Tripulante raro en oferta';

  @override
  String get u_crewSoldOut => '¡El tripulante de hoy ya se vendió, miau!';

  @override
  String get u_gemTrade => 'Canje de gemas (máx. 3)';

  @override
  String u_gemTradeRow(int price, int left) {
    return '💰$price → ⭐5  (quedan $left)';
  }

  @override
  String get u_convert => 'Canjear';

  @override
  String get u_potions => 'Pociones de mejora (duración x2)';

  @override
  String get u_notEnoughGems => 'No tienes gemas suficientes';

  @override
  String get u_buyConfirmTitle => 'Confirmar compra';

  @override
  String u_buyShipConfirm(String ship, String price) {
    return '¿Gastar $price en la $ship?';
  }

  @override
  String u_shipBought(String ship) {
    return '¡Conseguiste la $ship! Ya estás a bordo.';
  }

  @override
  String get u_premiumShips => 'Naves premium';

  @override
  String get u_hangarTitle => 'Hangar';

  @override
  String u_buyGems(int price) {
    return 'Comprar ⭐$price';
  }

  @override
  String get u_premium => 'Premium';

  @override
  String get u_ok => 'Aceptar';

  @override
  String get u_cancel => 'Cancelar';

  @override
  String get m_ok => 'Aceptar';

  @override
  String get m_cancel => 'Cancelar';

  @override
  String get m_close => 'Cerrar';

  @override
  String get m_claim => 'Reclamar';

  @override
  String m_claimGems(int gems) {
    return 'Reclamar ⭐$gems';
  }

  @override
  String get m_done => '✅ Hecho';

  @override
  String get m_notEnoughGems => 'No tienes gemas suficientes';

  @override
  String get m_restorePurchases => 'Restaurar compras';

  @override
  String get m_restoreDone => 'Compras verificadas';

  @override
  String get m_buyConfirmTitle => 'Confirmar compra';

  @override
  String m_spendGemsConfirm(String price) {
    return '¿Gastar $price?';
  }

  @override
  String get m_loginTitle => '📅 Recompensa diaria';

  @override
  String get m_loginWelcome => '¡Qué bueno verte otra vez, capitán!';

  @override
  String get m_loginFirst =>
      '¡Bienvenido a bordo, capitán! Aquí tienes tu primera recompensa.';

  @override
  String get m_loginStreakHint => '¡Entra 7 días seguidos y gana ⭐50!';

  @override
  String get m_newGameTitle => 'Nueva partida';

  @override
  String get m_newGameBody =>
      'Se borrará tu progreso actual.\n(Se conservan gemas, cosméticos, logros y compras). ¿Continuar?';

  @override
  String get m_start => 'Empezar';

  @override
  String get m_loadFailed => 'No se pudieron cargar los datos guardados.';

  @override
  String m_honorLine(int honor, int income, int attack) {
    return '🌌 Honor galáctico $honor · Ingresos +$income% · Ataque +$attack%';
  }

  @override
  String get m_continue => 'Continuar';

  @override
  String get m_newGame => '✨ Nueva partida';

  @override
  String get m_menuHome => 'Mi planeta';

  @override
  String get m_menuShop => 'Tienda';

  @override
  String get m_menuQuest => 'Misiones';

  @override
  String get m_menuAchievements => 'Logros';

  @override
  String get m_menuSettings => 'Ajustes';

  @override
  String m_achievementsTitle(int done, int total) {
    return '🏆 Logros ($done/$total)';
  }

  @override
  String get m_dailyTitle => '📅 Misiones diarias';

  @override
  String m_dailyReset(int hours, int minutes) {
    return 'Se reinicia en $hours h $minutes min';
  }

  @override
  String get m_dailyBonusTitle => '🎁 Bonus por completarlas todas';

  @override
  String get m_dailyBonusDesc => 'Reclama las 3 misiones de hoy';

  @override
  String get m_settingsTitle => '⚙ Ajustes';

  @override
  String get m_settingsSound => 'Efectos de sonido';

  @override
  String get m_settingsMusic => 'Música';

  @override
  String get m_settingsNotify => 'Recordatorios';

  @override
  String get m_settingsNotifyDesc =>
      'Te avisaremos cuando el almacén de tus colonias esté lleno';

  @override
  String get m_settingsHaptics => 'Vibración';

  @override
  String get m_settingsLanguage => 'Idioma';

  @override
  String get m_languageSystem => 'Usar idioma del dispositivo';

  @override
  String get m_settingsOrientation => 'Orientación de pantalla';

  @override
  String get m_orientAuto => 'Automática';

  @override
  String get m_orientPortrait => 'Vertical';

  @override
  String get m_orientLandscape => 'Horizontal';

  @override
  String get m_privacyTitle => 'Política de privacidad';

  @override
  String m_privacyBody(String email) {
    return 'Star Settlers no requiere registro ni recopila información de identificación personal. Los datos del juego (progreso, créditos y mineral, cosméticos, ajustes) se guardan en tu dispositivo. Las gemas y los registros de compra se guardan en un monedero de gemas en nuestro servidor para que no se puedan falsificar ni perder, y el ranking semanal opcional de abajo solo envía sus datos si lo activas.\n\nCompras: las procesa Google Play / App Store; los datos de pago nunca se comparten con el desarrollador. RevenueCat verifica y restaura las compras, procesando un ID de instalación aleatorio y el historial de compras. Cuando se confirma una compra, el servidor la abona en tu monedero de gemas.\n\nMonedero de gemas: las gemas se guardan en nuestro servidor, no en tu dispositivo, así que no se pueden aumentar manipulándolo. El servidor guarda un ID de instalación aleatorio (no es un ID de publicidad ni de dispositivo), tu saldo de gemas, los registros de gemas obtenidas y gastadas y los registros de compra; nada de nombres ni nada que escribas. Para gastar gemas se necesita conexión a internet. El servidor es Supabase (región de Seúl).\n\nAnuncios: los anuncios con recompensa de Google AdMob solo se muestran cuando tú eliges verlos. AdMob puede usar el ID de publicidad, la dirección IP y la información del dispositivo para mostrar anuncios, personalizarlos cuando esté permitido y medirlos. En el EEE, el Reino Unido y Suiza se pide tu consentimiento la primera vez que abres el juego, y puedes cambiarlo en Ajustes → Privacidad de anuncios.\n\nNotificaciones: notificaciones locales programadas en tu dispositivo; no se envía nada.\n\nComentarios: tu mensaje, la versión de la app y los datos del dispositivo solo llegan al desarrollador si envías el correo tú mismo.\n\nRanking semanal (opcional): desactivado por defecto; solo participas si lo activas en Ajustes o en la pantalla del ranking. Solo se envían un ID de instalación aleatorio, un apodo que el juego crea con listas de palabras fijas y tu puntuación semanal. Nada de nombres, nada que escribas y sin chat. Los demás jugadores solo ven el apodo y la puntuación. El servidor es Supabase (región de Seúl).\n\nBorrado: Ajustes → Borrar todos los datos elimina los datos de tu dispositivo. Borrar los datos también deja en 0 tu saldo de gemas en el servidor; el Pack de inicio y el Pase de Comandante de Flota vuelven gracias a tus registros de compra. Si te uniste al ranking, al borrar los datos también se elimina tu registro del ranking en el servidor (ID, apodo, puntuación); también puedes pedir el borrado por correo.\n\nPolítica completa: https://rumururu.github.io/mkideabox/star_settlers/privacy.html\nContacto: $email';
  }

  @override
  String get m_wipeTitle => 'Borrar todos los datos';

  @override
  String get m_wipeDesc =>
      'Elimina todo el progreso, gemas, cosméticos y tu registro del ranking';

  @override
  String get m_wipeConfirmTitle => '¿Seguro que quieres borrarlo todo?';

  @override
  String get m_wipeConfirmBody =>
      'No se puede deshacer. Las gemas y el progreso se borran para siempre. El Pack de inicio y el Pase de Comandante de Flota se recuperan con \"Restaurar compras\".';

  @override
  String get m_wipeOk => 'Borrar';

  @override
  String get m_feedbackTitle => 'Enviar comentarios al desarrollador';

  @override
  String get m_feedbackDesc =>
      'Errores, ideas, ¡lo que sea! El dispositivo y la versión se rellenan solos.';

  @override
  String m_noMailApp(String email) {
    return 'No se encontró una app de correo. Escribe a $email.';
  }

  @override
  String get m_aboutTitle => 'STAR SETTLERS';

  @override
  String m_version(String version) {
    return 'Versión $version';
  }

  @override
  String get m_shopTitle => '⭐ Tienda';

  @override
  String get m_buyThanks => '¡Compra completada! Gracias 💜';

  @override
  String get m_walletOffline =>
      'Las gemas se guardan en nuestro servidor. Conéctate a internet e inténtalo de nuevo.';

  @override
  String get m_purchasePending =>
      'Pago realizado. Tus gemas llegarán en cuanto se confirme.';

  @override
  String get m_adLoading =>
      'Cargando anuncio. Inténtalo de nuevo en un momento.';

  @override
  String m_buyShipConfirm(String ship, String price) {
    return '¿Gastar $price en $ship?';
  }

  @override
  String m_shipAcquired(String ship) {
    return '¡Conseguiste $ship! Ya estás a bordo';
  }

  @override
  String get m_tabGems => 'Gemas';

  @override
  String get m_tabPacks => 'Packs';

  @override
  String get m_tabPremiumShips => 'Naves premium';

  @override
  String get m_tabSkins => 'Aspectos de nave';

  @override
  String get m_tabOutfits => 'Trajes de capitán';

  @override
  String get m_tabFree => 'Gemas gratis';

  @override
  String get m_testMode =>
      '🧪 Modo de prueba: sin pagos reales; anuncios de prueba de Google';

  @override
  String get m_owned => 'En posesión';

  @override
  String get m_boarded => 'Pilotando';

  @override
  String get m_gemsInfo =>
      'Usa gemas en cosméticos, reclutamiento premium, revivir al instante y canje de créditos.\nTambién las ganas jugando (logros, inicios de sesión, jefes, cápsulas de suministros).';

  @override
  String get m_crewSection => '👩‍🚀 Tripulación (gemas)';

  @override
  String get m_premiumSection => '🛸 Naves premium';

  @override
  String get m_premiumDesc =>
      'Cazas especiales que solo se consiguen con gemas, cada uno con una habilidad única.';

  @override
  String get m_viewLarge => 'Ver a tamaño completo';

  @override
  String get m_premiumHangarHint =>
      'También puedes comprar y cambiar naves en el Hangar (Estación → pestaña Nave).';

  @override
  String get m_legendTitle => 'Reclutamiento legendario garantizado';

  @override
  String get m_legendDescNoGame =>
      '1 tripulante legendario ★4 (bonus desde 20% + toda la producción +40%, título, aura dorada)\nDisponible tras empezar una partida';

  @override
  String m_legendDesc(int count, int cap) {
    return '1 tripulante legendario ★4 (bonus desde 20% + toda la producción +40%, título, aura dorada)\nTripulación $count/$cap';
  }

  @override
  String m_crewJoined(String stars, String name) {
    return '¡$stars $name se ha unido!';
  }

  @override
  String get m_slotTitle => 'Puesto de tripulación +1';

  @override
  String m_slotDesc(int slots) {
    return 'Tripulantes que puedes asignar a la vez · Ahora $slots';
  }

  @override
  String m_rosterTitle(int n) {
    return 'Capacidad de tripulación +$n';
  }

  @override
  String m_rosterDesc(int cap, int max) {
    return 'Tripulantes que puedes tener · Ahora $cap (máx. $max)';
  }

  @override
  String m_crewOdds(String odds) {
    return 'Probabilidades premium: $odds · Legendario garantizado: ★4 100%';
  }

  @override
  String get m_equipped => 'Equipado';

  @override
  String get m_equip => 'Equipar';

  @override
  String get m_passOnly => 'Solo Pase de Comandante';

  @override
  String get m_starterOnly => 'Solo Pack de inicio';

  @override
  String get m_adSection => '📺 Gemas gratis con anuncios';

  @override
  String m_adInfo(int perDay, int left) {
    return '$perDay veces al día, ⭐5 cada una · quedan $left hoy';
  }

  @override
  String get m_adClaimPremium =>
      'Reclamar ⭐5 (Pase de Comandante: sin anuncios)';

  @override
  String get m_adWatch => 'Ver anuncio por ⭐5';

  @override
  String m_loginStreak(int days) {
    return 'Racha de inicio de sesión: día $days';
  }

  @override
  String m_dayN(int day) {
    return 'Día $day';
  }

  @override
  String get m_notEnoughResources => 'No tienes recursos suficientes';

  @override
  String m_emptyLot(int n) {
    return 'Parcela vacía #$n · Construir';
  }

  @override
  String get m_buildInGameOnly =>
      'Puedes construir durante una partida (Menú → Mi planeta). Los créditos y el mineral salen de tu universo actual.';

  @override
  String m_heldAll(String credits, String ore, int gems) {
    return 'Tienes 💰$credits  💎$ore  ⭐$gems';
  }

  @override
  String m_held(String credits, String ore) {
    return 'Tienes 💰$credits  💎$ore';
  }

  @override
  String m_currentEffect(String effect) {
    return 'Actual: $effect';
  }

  @override
  String m_nextLevel(String effect) {
    return 'Siguiente nivel: $effect';
  }

  @override
  String m_upgrade(String cost) {
    return 'Mejorar $cost';
  }

  @override
  String get m_maxLevel => '🌟 Nivel máximo';

  @override
  String get m_planetName => 'Nombre del planeta';

  @override
  String get m_decorateTitle => '🎨 Decorar planeta';

  @override
  String get m_planetRing => 'Anillo planetario';

  @override
  String get m_giftInGameOnly => 'Los regalos se recogen durante una partida';

  @override
  String get m_giftTitle => '🎁 Regalo del planeta';

  @override
  String m_giftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¡Un regalo de tus $count habitantes!',
      one: '¡Un regalo de tu único habitante!',
    );
    return '$_temp0';
  }

  @override
  String get m_giftThanks => '¡Gracias!';

  @override
  String m_planetStatus(int level, int residents, int built, int slots) {
    return 'Planeta Lv.$level · $residents habitantes · Edificios $built/$slots';
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
    return 'Bonus permanente · Ingresos +$income%  Mineral +$ore%  Ataque +$attack%  PV +$hp%  Recarga -$cooldown%  Sin conexión $offline%';
  }

  @override
  String get m_planetHint =>
      'Desliza para girar el planeta y toca una parcela para construir';

  @override
  String get m_giftClaim => '🎁 Recoger regalo';

  @override
  String m_giftWait(int hours, int minutes) {
    return '🎁 Regalo en $hours h $minutes min';
  }

  @override
  String m_planetLevelUp(int level, String cost) {
    return '🌍 Planeta Lv.$level (+2 parcelas) $cost';
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
  String get g_shipScoutDesc => 'Nave inicial equilibrada';

  @override
  String get g_shipInterceptorDesc =>
      'Rápida y de disparo veloz, pero con poco blindaje';

  @override
  String get g_shipFortressDesc => 'Lenta pero resistente, con golpes potentes';

  @override
  String get g_shipProspectorDesc => 'Mineral +50%, atrae objetos desde lejos';

  @override
  String get g_shipPhantomDesc => '25% de probabilidad de crítico x2.5';

  @override
  String get g_shipNovaDesc =>
      'Caza premium cuyos disparos atraviesan enemigos';

  @override
  String get g_shipAuroraDesc =>
      'Guardiana premium que se autorrepara y lleva una barrera';

  @override
  String get g_shipNovaAbility =>
      'Disparos perforantes: cada disparo atraviesa hasta 2 enemigos';

  @override
  String get g_shipAuroraAbility =>
      'Autorreparación: recupera 3% de PV/s tras 3 s sin recibir daño\nGuardia: bloquea 1 golpe cada 8 s';

  @override
  String g_crewLegendPerk(int pct) {
    return '👑 Mando legendario: toda la producción (créditos y mineral) +$pct% (no acumulable)';
  }

  @override
  String g_shipCreditBonus(int pct) {
    return '💰 Bono de cazador: +$pct% de créditos que ganas tú mismo (recompensas, asteroides, misiones, defensa de asaltos)';
  }

  @override
  String g_unlockSector(int n) {
    return 'Llega al sistema $n';
  }

  @override
  String g_unlockBosses(int n) {
    return 'Derrota a $n jefes piratas';
  }

  @override
  String g_unlockOre(int n) {
    return 'Recoge $n de mineral';
  }

  @override
  String get g_skinDefault => 'Scout básica';

  @override
  String get g_skinCrimson => 'Cometa Rojo';

  @override
  String get g_skinMint => 'Menta Choco';

  @override
  String get g_skinStealth => 'Negro Sigilo';

  @override
  String get g_skinNeon => 'Rosa Neón';

  @override
  String get g_skinRainbow => 'Sueño Arcoíris';

  @override
  String get g_skinGalaxy => 'Galaxia';

  @override
  String get g_skinGold => 'Oro Real';

  @override
  String get g_outfitDefault => 'Traje espacial básico';

  @override
  String get g_outfitCat => 'Casco de gatito';

  @override
  String get g_outfitBunny => 'Orejas de conejo';

  @override
  String get g_outfitAlien => 'Antenas alienígenas';

  @override
  String get g_outfitFlower => 'Horquilla de flor';

  @override
  String get g_outfitHat => 'Gorra de capitán';

  @override
  String get g_outfitCrown => 'Corona galáctica';

  @override
  String get g_crewRoleGunner => 'Artillero';

  @override
  String get g_crewEffectGunner => 'Ataque';

  @override
  String get g_crewRoleEngineer => 'Ingeniero';

  @override
  String get g_crewEffectEngineer => 'PV máx. y reparación';

  @override
  String get g_crewRolePilot => 'Piloto';

  @override
  String get g_crewEffectPilot => 'Velocidad';

  @override
  String get g_crewRoleTrader => 'Comerciante';

  @override
  String get g_crewEffectTrader => 'Ingresos de créditos';

  @override
  String get g_crewRoleMiner => 'Minero';

  @override
  String get g_crewEffectMiner => 'Obtención de mineral';

  @override
  String get g_crewRoleScientist => 'Científico';

  @override
  String get g_crewEffectScientist => 'Recarga de habilidades';

  @override
  String get g_crewName0 => 'Bolita';

  @override
  String get g_crewName1 => 'Coco';

  @override
  String get g_crewName2 => 'Estrellita';

  @override
  String get g_crewName3 => 'Tofu';

  @override
  String get g_crewName4 => 'Frijolito';

  @override
  String get g_crewName5 => 'Lulú';

  @override
  String get g_crewName6 => 'Haru';

  @override
  String get g_crewName7 => 'Popo';

  @override
  String get g_crewName8 => 'Mimí';

  @override
  String get g_crewName9 => 'Dori';

  @override
  String get g_crewName10 => 'Pelusa';

  @override
  String get g_crewName11 => 'Mariposa';

  @override
  String get g_crewName12 => 'Choco';

  @override
  String get g_crewName13 => 'Cebadita';

  @override
  String get g_crewName14 => 'Nube';

  @override
  String get g_crewName15 => 'Llovizna';

  @override
  String get g_crewName16 => 'Tori';

  @override
  String get g_crewName17 => 'Happy';

  @override
  String get g_crewName18 => 'Arrocito';

  @override
  String get g_crewName19 => 'Mochi';

  @override
  String get g_crewName20 => 'Latte';

  @override
  String get g_crewName21 => 'Galleta';

  @override
  String get g_crewName22 => 'Gomita';

  @override
  String get g_crewName23 => 'Algodón';

  @override
  String get g_crewName24 => 'Mango';

  @override
  String get g_crewName25 => 'Ciruela';

  @override
  String get g_crewName26 => 'Nuez';

  @override
  String get g_crewName27 => 'Carboncito';

  @override
  String get g_crewName28 => 'Bambi';

  @override
  String get g_crewName29 => 'Queso';

  @override
  String get g_crewLegend0 => 'Guardián Galáctico';

  @override
  String get g_crewLegend1 => 'Héroe Estelar';

  @override
  String get g_crewLegend2 => 'Sabio de la Nebulosa';

  @override
  String get g_crewLegend3 => 'Caballero Cometa';

  @override
  String get g_crewLegend4 => 'Supernova';

  @override
  String g_crewLegendName(String title, String name) {
    return '$title $name';
  }

  @override
  String get g_bldHouse => 'Casa';

  @override
  String g_bldHouseEffect(int n) {
    return 'Habitantes +$n (más regalos)';
  }

  @override
  String get g_bldFarm => 'Granja espacial';

  @override
  String g_bldFarmEffect(int n) {
    return 'Ingresos de créditos +$n%';
  }

  @override
  String get g_bldMine => 'Mina';

  @override
  String g_bldMineEffect(int n) {
    return 'Obtención de mineral +$n%';
  }

  @override
  String get g_bldLab => 'Laboratorio';

  @override
  String g_bldLabEffect(int n) {
    return 'Recarga de habilidades -$n%';
  }

  @override
  String get g_bldTower => 'Torre defensiva';

  @override
  String g_bldTowerEffect(int n) {
    return 'PV máx. +$n%';
  }

  @override
  String get g_bldShipyard => 'Astillero';

  @override
  String g_bldShipyardEffect(int n) {
    return 'Ataque +$n%';
  }

  @override
  String get g_bldPark => 'Parque de atracciones';

  @override
  String g_bldParkEffect(int n) {
    return 'Ingresos sin conexión +$n p.p.';
  }

  @override
  String get g_bldStatue => 'Estatua del capitán';

  @override
  String g_bldStatueEffect(int n) {
    return 'Gemas de regalo del planeta +$n';
  }

  @override
  String get g_homePalette0 => 'Jardín verde';

  @override
  String get g_homePalette1 => 'Desierto de arena';

  @override
  String get g_homePalette2 => 'Reino de hielo';

  @override
  String get g_homePalette3 => 'Isla de lava';

  @override
  String get g_homePalette4 => 'Gas violeta';

  @override
  String get g_homePalette5 => 'Flor de cerezo';

  @override
  String get g_homePalette6 => 'Aurora';

  @override
  String get g_homePalette7 => 'Oro';

  @override
  String get g_homeDefaultName => 'Mi pequeña estrella';

  @override
  String get g_achFirstBloodTitle => 'Primer derribo';

  @override
  String get g_achFirstBloodDesc => 'Derriba 1 pirata';

  @override
  String get g_achHunterTitle => 'Cazapiratas';

  @override
  String get g_achHunterDesc => 'Derriba 100 piratas';

  @override
  String get g_achLegendTitle => 'Capitán legendario';

  @override
  String get g_achLegendDesc => 'Derriba 1000 piratas';

  @override
  String get g_achMinerTitle => 'Rey minero';

  @override
  String get g_achMinerDesc => 'Recoge 1000 de mineral';

  @override
  String get g_achMiner2Title => 'Magnate del mineral';

  @override
  String get g_achMiner2Desc => 'Recoge 10000 de mineral';

  @override
  String get g_achColonistTitle => 'Pionero';

  @override
  String get g_achColonistDesc => 'Coloniza 5 planetas';

  @override
  String get g_achMetropolisTitle => 'Metrópolis';

  @override
  String get g_achMetropolisDesc => 'Lleva una colonia a Lv.5';

  @override
  String get g_achBuilderTitle => 'Constructor';

  @override
  String get g_achBuilderDesc => 'Construye 3 estaciones';

  @override
  String get g_achBoss1Title => 'Caza de jefes';

  @override
  String get g_achBoss1Desc => 'Derrota a un jefe pirata';

  @override
  String get g_achBoss10Title => 'Matajefes';

  @override
  String get g_achBoss10Desc => 'Derrota jefes piratas 10 veces';

  @override
  String get g_achExplorerTitle => 'Explorador';

  @override
  String get g_achExplorerDesc => 'Llega al sistema 3';

  @override
  String get g_achVoyagerTitle => 'Viajero';

  @override
  String get g_achVoyagerDesc => 'Llega al sistema 6';

  @override
  String get g_achRichTitle => 'Capitán rico';

  @override
  String get g_achRichDesc => 'Ten 10000 créditos';

  @override
  String get g_achCrew6Title => 'Tripulación fiel';

  @override
  String get g_achCrew6Desc => 'Recluta 6 tripulantes';

  @override
  String get g_achCrew3starTitle => 'Compañero legendario';

  @override
  String get g_achCrew3starDesc => 'Recluta un tripulante ★3';

  @override
  String get g_achMissionsTitle => 'Resuelvetodo';

  @override
  String get g_achMissionsDesc => 'Completa 20 misiones';

  @override
  String get g_achJellyTitle => 'Experto en medusas';

  @override
  String get g_achJellyDesc => 'Derrota 10 medusas espaciales';

  @override
  String get g_achFashionTitle => 'Fashionista';

  @override
  String get g_achFashionDesc => 'Compra un cosmético';

  @override
  String get g_achAscendTitle => 'Nuevo comienzo';

  @override
  String get g_achAscendDesc => 'Asciende con el honor galáctico';

  @override
  String get g_achDroneTitle => 'Dron fiel';

  @override
  String get g_achDroneDesc => 'Equipa un dron de combate';

  @override
  String get g_achHome5Title => 'Arquitecto planetario';

  @override
  String get g_achHome5Desc => '5 edificios en mi planeta';

  @override
  String get g_achHomeMaxTitle => 'Planeta soñado';

  @override
  String get g_achHomeMaxDesc => 'Nivel máximo en mi planeta';

  @override
  String get g_dailyKill => 'Derriba 30 piratas';

  @override
  String get g_dailyOre => 'Recoge 300 de mineral';

  @override
  String get g_dailyMission => 'Completa 2 misiones';

  @override
  String get g_dailyColony => 'Haz crecer colonias 2 veces';

  @override
  String get g_dailyBoss => 'Derrota a un jefe pirata';

  @override
  String get g_dailyPower => 'Consigue 3 potenciadores';

  @override
  String get g_dailyPlay => 'Juega 10 minutos';

  @override
  String get g_dailyJelly => 'Derrota 3 medusas espaciales';

  @override
  String g_missionKill(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n piratas',
      one: '1 pirata',
    );
    return 'Elimina $_temp0';
  }

  @override
  String g_missionMine(int n) {
    return 'Recoge $n de mineral';
  }

  @override
  String g_missionDeliver(String planet) {
    return 'Lleva carga a $planet';
  }

  @override
  String g_missionBounty(String name) {
    return 'Se busca: $name';
  }

  @override
  String get g_bounty0 => 'Jack el Tuerto';

  @override
  String get g_bounty1 => 'Molly Relámpago';

  @override
  String get g_bounty2 => 'Bark, Rey de la Chatarra';

  @override
  String get g_bounty3 => 'Toto Barbarroja';

  @override
  String get g_bounty4 => 'Lena la Sombra';

  @override
  String get g_bounty5 => 'Pork el Gordinflón';

  @override
  String get g_bounty6 => 'Gigi Dos Espadas';

  @override
  String get g_bounty7 => 'Bud Martillo Loco';

  @override
  String get g_bounty8 => 'Lucy Zorro Galáctico';

  @override
  String get g_bounty9 => 'Capitán Calavera Bones';

  @override
  String get g_storyAsteroidsTitle => 'Destruye 3 asteroides';

  @override
  String get g_storyAsteroidsLine0 =>
      '¡Capitán! Primero, destruye asteroides para reunir mineral.';

  @override
  String get g_storyAsteroidsLine1 =>
      '¡Muévete con el joystick y dispara con el botón de fuego!';

  @override
  String get g_storyKillsTitle => 'Derriba 3 piratas';

  @override
  String get g_storyKillsLine0 => '¡Piratas en el radar! Sigue la flecha roja.';

  @override
  String get g_storyKillsLine1 => '¿Piratas? ¡Son chatarra frente a mi nave!';

  @override
  String get g_storyColoniesTitle => 'Coloniza Marte';

  @override
  String get g_storyColoniesLine0 =>
      'Funda tu primera colonia en Marte, el planeta rojo junto a la Tierra. Acércate y aparecerá el botón de colonizar.';

  @override
  String get g_storyColoniesLine1 =>
      '¡Las colonias ganan créditos incluso mientras descansas!';

  @override
  String get g_storyShipLevelsTitle => 'Mejora tu nave en una estación';

  @override
  String get g_storyShipLevelsLine0 =>
      'Vuelve a la Base Haven y mejora tu nave. Cerca de las estaciones también te reparas.';

  @override
  String get g_storyCrewTitle => 'Recluta 1 tripulante';

  @override
  String get g_storyCrewLine0 =>
      '¿Te sientes solo? ¡Recluta a un compañero en la pestaña Tripulación del menú de la estación!';

  @override
  String get g_storyMissionsTitle => 'Completa 1 misión';

  @override
  String get g_storyMissionsLine0 =>
      'Acepta un encargo en el tablón de misiones de la estación. ¡La paga es buena!';

  @override
  String get g_storyStationsTitle => 'Construye una nueva estación';

  @override
  String get g_storyStationsLine0 =>
      '¡Hora de expandirse! Construye una estación en el espacio abierto, lejos de los planetas.';

  @override
  String get g_storyDevPercentTitle => 'Desarrollo del sistema 100%';

  @override
  String get g_storyDevPercentLine0 =>
      'Sube todos los planetas a Lv.3 para abrir el siguiente sistema. ¡Mira el botón Sistema arriba a la derecha!';

  @override
  String get g_storySectorTitle => 'Salta al siguiente sistema';

  @override
  String get g_storySectorLine0 =>
      '¡La puerta de salto está abierta! Ve a la puerta morada del minimapa.';

  @override
  String get g_storySectorLine1 => '¡Todo un universo nuevo nos espera!';

  @override
  String g_storyDevNTitle(int n) {
    return 'Desarrollo del sistema $n 100%';
  }

  @override
  String get g_storyDevNLine =>
      '¡Sube todos los planetas del nuevo sistema a Lv.3!';

  @override
  String g_systemN(int n) {
    return 'Sistema $n';
  }

  @override
  String g_storyWarpNTitle(String system) {
    return 'Salta al $system';
  }

  @override
  String get g_storyWarpNLine =>
      'La puerta está abierta. ¿Nos adentramos más en el espacio?';

  @override
  String get g_powerUpRapid => 'Disparo rápido';

  @override
  String get g_powerUpShield => 'Escudo';

  @override
  String get g_powerUpMagnet => 'Imán';

  @override
  String get g_powerUpDoubleCredits => 'Créditos x2';

  @override
  String get g_planetKindGarden => 'Planeta jardín';

  @override
  String get g_planetKindDesert => 'Planeta desértico';

  @override
  String get g_planetKindIce => 'Planeta helado';

  @override
  String get g_planetKindLava => 'Planeta de lava';

  @override
  String get g_planetKindGas => 'Planeta gaseoso';

  @override
  String get g_colonyBldTurret => 'Torreta';

  @override
  String get g_colonyBldMine => 'Plataforma minera';

  @override
  String get g_colonyBldTrade => 'Puesto comercial';

  @override
  String get g_colonyBldDock => 'Dique de reparación';

  @override
  String get g_colonyBldShieldGen => 'Generador de escudo';

  @override
  String get g_colonyBldBlurbTurret =>
      'Dispara solo a los piratas cerca de la colonia. ¡Imprescindible contra asaltos!';

  @override
  String get g_colonyBldBlurbMine => 'Extrae mineral y envía 💎 cada segundo.';

  @override
  String get g_colonyBldBlurbTrade =>
      'Aumenta los ingresos de créditos de esta colonia un 25% por nivel.';

  @override
  String get g_colonyBldBlurbDock => 'Repara tu nave mientras estás cerca.';

  @override
  String get g_colonyBldBlurbShieldGen =>
      'Aumenta la capacidad del escudo y su velocidad de recarga.';

  @override
  String get g_stationRoleHome => 'Base principal';

  @override
  String get g_stationRoleDefense => 'Base de defensa';

  @override
  String get g_stationRoleRepair => 'Base de reparación';

  @override
  String get g_stationRoleSupport => 'Base de suministros';

  @override
  String get g_stationRoleBlurbHome => 'Batería láser y zona segura';

  @override
  String get g_stationRoleBlurbDefense =>
      'Torreta potente · casco x2 · bloquea disparos enemigos cercanos';

  @override
  String get g_stationRoleBlurbRepair =>
      'Reparación rápida y amplia · relanzar cuesta 10% · recarga de escudo x2 en colonias cercanas';

  @override
  String get g_stationRoleBlurbSupport =>
      'Producción de colonias cercanas +25% (+5% por nivel de hábitat)';

  @override
  String g_eventRaid(String planet) {
    return 'Asalto a $planet';
  }

  @override
  String get g_eventMeteor => 'Lluvia de meteoros';

  @override
  String get g_eventMerchant => 'Mercader errante';

  @override
  String get g_eventSupply => 'Cápsula de suministros';

  @override
  String get g_productGems100Title => 'Puñado de gemas';

  @override
  String get g_productGems550Title => 'Bolsa de gemas';

  @override
  String get g_productGems1200Title => 'Cofre de gemas';

  @override
  String get g_productStarterTitle => 'Pack de inicio';

  @override
  String get g_productPassTitle => 'Pase de Comandante de Flota';

  @override
  String get g_productGems550Desc => '⭐550 (+10% extra)';

  @override
  String get g_productGems1200Desc => '⭐1200 (+20% extra)';

  @override
  String get g_productStarterDesc =>
      '⭐300 + aspecto exclusivo \"Galaxia\" + tripulante ★3 (solo una vez)';

  @override
  String get g_productPassDesc =>
      'Ingresos de créditos +25%, 8 h de ingresos sin conexión, recompensas sin anuncios, aspecto exclusivo \"Oro Real\"';

  @override
  String g_testPurchaseTitle(String product) {
    return '[Compra de prueba] $product';
  }

  @override
  String g_testPurchaseBody(String desc, String price) {
    return 'No se realizará ningún pago real.\n$desc\nPrecio: $price';
  }

  @override
  String get g_testAdTitle => '[Anuncio de prueba]';

  @override
  String get g_testAdBody => '¿Dar el anuncio por visto completo?';

  @override
  String get g_webDemoTitle => 'Demo web';

  @override
  String get g_webDemoBody =>
      'Las compras y las recompensas por anuncios están disponibles en la app móvil.';

  @override
  String get g_notifChannelName => 'Recordatorios de regreso';

  @override
  String get g_notifChannelDesc =>
      'Avisos de ingresos de colonias y recompensas diarias';

  @override
  String get g_notifStorageTitle => '¡El almacén de tu colonia está lleno!';

  @override
  String get g_notifStorageBody =>
      '¡Capitán, ven a recoger tus créditos antes de que se detengan los ingresos!';

  @override
  String get g_notifPiratesTitle =>
      '¡Los piratas vuelven a hacer de las suyas!';

  @override
  String get g_notifPiratesBody =>
      'Te esperan la recompensa diaria y las misiones diarias de hoy.';

  @override
  String get g_upgradeWeapon => 'Arma';

  @override
  String get g_upgradeHull => 'Blindaje';

  @override
  String get g_upgradeEngine => 'Motor';

  @override
  String get g_upgradeMissile => 'Misil teledirigido';

  @override
  String get g_upgradeShield => 'Escudo de energía';

  @override
  String get g_upgradeDrone => 'Dron de combate';

  @override
  String get g_upgradeMagnet => 'Imán';

  @override
  String g_unknownSector(int n) {
    return 'Sistema desconocido $n';
  }

  @override
  String get g_stationHaven => 'Base Haven';

  @override
  String g_stationOutpost(String sector) {
    return 'Avanzada de $sector';
  }

  @override
  String g_stationNumbered(String role, int n) {
    return '$role #$n';
  }

  @override
  String get g_dlgWelcome =>
      '¡Bienvenido, capitán! Soy Mina, tu primera oficial.';

  @override
  String get g_dlgMissionsCancelled =>
      'Se cancelaron las misiones de entrega y de búsqueda del sistema anterior.';

  @override
  String get g_floatDisabled => '¡Inactiva!';

  @override
  String get g_floatRebooted => '¡En línea!';

  @override
  String get g_dlgBaseRebooted =>
      '¡La base principal vuelve a estar en línea! Casco restaurado al 30%.';

  @override
  String get g_dlgUpWeapon => '¡Armas mejoradas! ¡Prepárense, piratas!';

  @override
  String get g_dlgUpHull => '¡Blindaje mejorado! Ahora me siento más seguro.';

  @override
  String get g_dlgUpEngine => '¡Motor mejorado! ¡Más rápido!';

  @override
  String get g_dlgMissileNew => '¡Misiles teledirigidos equipados! (Q)';

  @override
  String get g_dlgMissileUp => '¡Misiles mejorados!';

  @override
  String get g_dlgShieldNew => '¡Escudo de energía equipado! (F)';

  @override
  String get g_dlgShieldUp => '¡Escudo mejorado!';

  @override
  String get g_dlgDroneNew =>
      '¡Dron de combate desplegado! Un nuevo amigo fiel.';

  @override
  String get g_dlgDroneUp => '¡Dron mejorado!';

  @override
  String get g_dlgUpMagnet =>
      '¡Imán mejorado! ¡Los créditos vienen solos a mí!';

  @override
  String get g_dlgNotOver => '¡Esto aún no ha terminado!';

  @override
  String get g_floatBlocked => '¡Bloqueado!';

  @override
  String get g_floatGuard => '¡Protegido!';

  @override
  String get g_pirateBossLose => '¡Argh! Este sistema… es tuyo…';

  @override
  String get g_pirateBossFlee => '¡Argh! ¡Me acordaré de esto, capitán!';

  @override
  String get g_dlgSupplyCollected => '¡Cápsula de suministros recuperada!';

  @override
  String get g_merchantBye => '¡Hasta la próxima~ miau!';

  @override
  String get g_pirateRaidTaunt => '¡Esta colonia ahora es nuestra! ¡Jajaja!';

  @override
  String get g_dlgMeteor =>
      '¡Lluvia de meteoros a la vista! Viene llena de cristales. ¡Gran ocasión para conseguir mineral!';

  @override
  String get g_merchantHello =>
      '¡Llegó Nyang-nyang, el mercader errante~! ¡Tengo muchas cosas buenas, miau!';

  @override
  String get g_dlgSupplySignal =>
      '¡Señal de una cápsula de suministros con gemas! Los piratas la vigilan, así que ten cuidado.';

  @override
  String get g_dlgCruiseOn =>
      '¡Primer entrenamiento listo! Activé [Crucero] sobre el joystick: sigues volando hacia donde miras aunque sueltes. Tócalo otra vez para apagarlo.';

  @override
  String get g_dlgBossWarning =>
      '¡Alerta! ¡Se acerca la nave del jefe del sistema!';

  @override
  String get g_pirateRevenge => '¡He vuelto para vengarme! ¡Prepárate!';

  @override
  String get g_floatShieldBroken => '¡Roto!';

  @override
  String get g_floatShieldBack => 'Reactivado';

  @override
  String get g_floatGoalDone => '¡Objetivo cumplido!';

  @override
  String g_dlgArrived(String sector) {
    return '¡Llegamos a $sector!';
  }

  @override
  String get g_dlgNewFrontier => 'Una frontera totalmente nueva.';

  @override
  String g_dlgBaseUpgraded(String station, int level) {
    return '¡$station mejorada a Lv.$level! Los láseres son más potentes.';
  }

  @override
  String g_dlgBaseDisabled(int sec) {
    return '¡Base principal inactiva! ¡Sin protección durante $sec s!';
  }

  @override
  String g_dlgSettled(String planet) {
    return '¡Bandera plantada en $planet! ¡Colonizado!';
  }

  @override
  String g_dlgStationBuilt(String station, String blurb) {
    return '¡$station construida! $blurb';
  }

  @override
  String g_dlgHabitatUp(String station, int level) {
    return '¡Hábitat de $station Lv.$level!';
  }

  @override
  String g_dlgTurretUp(String station, int level) {
    return '¡Torreta de $station Lv.$level!';
  }

  @override
  String g_dlgShipSwitched(String ship) {
    return '¡Cambié a la $ship! ¡Se siente genial!';
  }

  @override
  String g_dlgOreSold(int n, int credits) {
    return 'Vendiste $n de mineral por 💰$credits.';
  }

  @override
  String g_dlgCrewJoined(String stars, String role, String name) {
    return '¡$stars $role $name se unió a la tripulación!';
  }

  @override
  String g_dlgCrewLevel(String name, int level) {
    return '¡$name Lv.$level! Está mejorando.';
  }

  @override
  String g_dlgCargoLoaded(String mission) {
    return '¡Carga a bordo! $mission';
  }

  @override
  String g_dlgBountyTaunt(String name) {
    return '¿Crees que puedes atrapar a $name? ¡Ven a intentarlo!';
  }

  @override
  String get g_floatMissionDone => '¡Misión cumplida!';

  @override
  String g_dlgMissionDone(String mission) {
    return '¡Misión cumplida: $mission!';
  }

  @override
  String g_dlgRepairCost(int credits) {
    return '¡Estás a salvo, capitán! La reparación costó 💰$credits.';
  }

  @override
  String g_dlgSectorDeveloped(String sector) {
    return '¡$sector totalmente desarrollado! La puerta de salto al siguiente sistema está abierta.';
  }

  @override
  String g_floatCrit(int dmg) {
    return '¡Crítico! $dmg';
  }

  @override
  String g_dlgStationDestroyed(String station) {
    return '¡$station fue destruida! ¡Necesitamos torretas!';
  }

  @override
  String g_dlgBossDefeated(int credits) {
    return '¡Jefe del sistema derrotado! Recompensa 💰$credits';
  }

  @override
  String g_dlgBountyCaught(String name) {
    return '¡Pirata buscado $name capturado!';
  }

  @override
  String g_dlgRaidDefended(String planet, int credits) {
    return '¡$planet defendido! Los habitantes, agradecidos, enviaron 💰$credits ⭐2.';
  }

  @override
  String g_dlgRaidLooted(String planet, String level) {
    return '$planet fue saqueado y bajó a $level… 😢';
  }

  @override
  String g_dlgRaidLeft(String planet) {
    return 'Los piratas saquearon $planet y se fueron.';
  }

  @override
  String g_dlgRaidAlert(String planet) {
    return '¡Emergencia! ¡Los piratas están asaltando $planet! ¡La producción se detuvo!';
  }

  @override
  String g_pirateBossArrive(String sector) {
    return '¡$sector es mío! ¡Ven si te atreves, capitancito!';
  }

  @override
  String g_dlgWelcomeBack(String goal) {
    return '¡Bienvenido de nuevo, capitán! Objetivo actual: $goal';
  }

  @override
  String get g_pirateWin0 => '¡Jajaja! ¡No eras para tanto!';

  @override
  String get g_pirateWin1 => '¡Vuelve más fuerte la próxima vez, mocoso!';

  @override
  String get g_pirateWin2 => '¡Tu nave ya es chatarra!';

  @override
  String get g_pirateRage0 => '¡Salgan, muchachos! ¡Denles una lección!';

  @override
  String get g_pirateRage1 => '¡Ahora va en serio!';

  @override
  String get g_pirateRage2 => '¡¿Así que me hiciste enojar?!';

  @override
  String get g_captainKill0 => '¡Uno menos!';

  @override
  String get g_captainKill1 => '¡¿Adónde crees que vas?!';

  @override
  String get g_captainKill2 => '¡Esta zona es mía!';

  @override
  String get g_captainKill3 => '¡El siguiente!';

  @override
  String get g_pirateAmbush0 => '¡Jajaja! ¡Suelta la carga!';

  @override
  String get g_pirateAmbush1 => '¡Este es territorio de nuestra banda!';

  @override
  String get g_pirateAmbush2 => '¡Entrega esos créditos brillantes!';

  @override
  String get g_pirateAmbush3 => '¡Hoy no es tu día, mocoso!';

  @override
  String get cat_sysSol => 'Sistema Solar';

  @override
  String get cat_sysAlphaCen => 'Alfa Centauri';

  @override
  String get cat_sysBarnard => 'Estrella de Barnard';

  @override
  String get cat_sysWolf359 => 'Wolf 359';

  @override
  String get cat_sysLalande => 'Lalande 21185';

  @override
  String get cat_sysSirius => 'Sirio';

  @override
  String get cat_sysEpsEri => 'Épsilon Eridani';

  @override
  String get cat_sysRoss128 => 'Ross 128';

  @override
  String get cat_sysTauCeti => 'Tau Ceti';

  @override
  String get cat_sysTeegarden => 'Estrella de Teegarden';

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
  String get cat_sysOmegaCen => 'Cúmulo Omega Centauri';

  @override
  String get cat_sysSgrA => 'Centro Galáctico (Sgr A*)';

  @override
  String get cat_sysLMC => 'Gran Nube de Magallanes';

  @override
  String get cat_sysSMC => 'Pequeña Nube de Magallanes';

  @override
  String get cat_sysAndromeda => 'Galaxia de Andrómeda';

  @override
  String get cat_sysTriangulum => 'Galaxia del Triángulo';

  @override
  String get cat_pfxProxima => 'Próxima';

  @override
  String get cat_pfxBarnard => 'Barnard';

  @override
  String get cat_pfxSirius => 'Sirio A';

  @override
  String get cat_pfxEpsEri => 'Épsilon Eridani';

  @override
  String get cat_pfxTauCeti => 'Tau Ceti';

  @override
  String get cat_pfxTeegarden => 'Teegarden';

  @override
  String get cat_mars => 'Marte';

  @override
  String get cat_moon => 'Luna';

  @override
  String get cat_venus => 'Venus';

  @override
  String get cat_mercury => 'Mercurio';

  @override
  String get cat_ceres => 'Ceres';

  @override
  String get cat_vesta => 'Vesta';

  @override
  String get cat_jupiter => 'Júpiter';

  @override
  String get cat_io => 'Ío';

  @override
  String get cat_europa => 'Europa';

  @override
  String get cat_ganymede => 'Ganímedes';

  @override
  String get cat_callisto => 'Calisto';

  @override
  String get cat_saturn => 'Saturno';

  @override
  String get cat_enceladus => 'Encélado';

  @override
  String get cat_titan => 'Titán';

  @override
  String get cat_uranus => 'Urano';

  @override
  String get cat_miranda => 'Miranda';

  @override
  String get cat_titania => 'Titania';

  @override
  String get cat_neptune => 'Neptuno';

  @override
  String get cat_triton => 'Tritón';

  @override
  String get cat_pluto => 'Plutón';

  @override
  String get cat_charon => 'Caronte';

  @override
  String get cat_haumea => 'Haumea';

  @override
  String get cat_makemake => 'Makemake';

  @override
  String get cat_eris => 'Eris';

  @override
  String get cat_sedna => 'Sedna';

  @override
  String get cat_planetNine => 'Planeta Nueve';

  @override
  String get u_topUpTitle => 'Recursos insuficientes';

  @override
  String u_topUpBody(String short, int gems) {
    return 'Te faltan $short. ¿Usar ⭐$gems para completar y seguir?';
  }

  @override
  String u_topUpNoGems(String short, int gems, int have) {
    return 'Te faltan $short. Completarlo cuesta ⭐$gems, pero tienes ⭐$have. ¡Junta un poco más!';
  }

  @override
  String get u_topUpOk => 'Completar';

  @override
  String get u_goShop => 'Ir a la tienda';

  @override
  String get u_exchangeTitle => '💰 Cambiar créditos';

  @override
  String u_exchangeBody(int gems, int credits) {
    return '¿Cambiar ⭐$gems por 💰$credits?';
  }

  @override
  String get m_purchaseFailed =>
      'No se pudo conectar con la tienda. Inténtalo más tarde.';

  @override
  String get m_adWatchToEnd =>
      'Mira el anuncio hasta el final para obtener la recompensa.';

  @override
  String get u_cruise => 'Crucero';

  @override
  String get u_autoFireOn => 'SÍ';

  @override
  String get u_autoFireOff => 'NO';

  @override
  String u_recruitRoleOdds(int count, String pct) {
    return 'Rol (todos los reclutamientos): al azar entre $count, $pct cada uno';
  }

  @override
  String m_feedbackSubject(String app) {
    return 'Comentarios de $app';
  }

  @override
  String get lb_menu => '🏅 Ranking semanal';

  @override
  String get lb_menuShort => 'Ranking';

  @override
  String get lb_title => '🏅 Ranking semanal';

  @override
  String get lb_join => 'Unirme al ranking';

  @override
  String get lb_joinDesc =>
      'Solo se envían un ID anónimo, un apodo creado por el juego y tu puntuación de la semana. Nada de nombres, chat ni nada que escribas. Puedes desactivarlo cuando quieras.';

  @override
  String get lb_yourNick => 'Tu apodo';

  @override
  String lb_reroll(int count) {
    return 'Nuevo nombre ($count)';
  }

  @override
  String lb_weekPoints(String points) {
    return 'Esta semana: $points pts';
  }

  @override
  String lb_rank(int rank, int total) {
    return 'N.º $rank de $total';
  }

  @override
  String lb_rankOnly(int rank) {
    return 'N.º $rank';
  }

  @override
  String get lb_top50 => 'Top 50 de la semana';

  @override
  String get lb_empty => 'Aún no hay puntuaciones esta semana. ¡Sé el primero!';

  @override
  String get lb_retry => 'Reintentar';

  @override
  String get lb_refresh => 'Actualizar';

  @override
  String get lb_offline =>
      'Sin conexión. Tu partida sigue bien; inténtalo más tarde.';

  @override
  String get lb_rateLimited =>
      'Demasiados intentos. Espera un minuto y vuelve a intentarlo.';

  @override
  String get lb_rejected => 'No se pudo enviar esta puntuación.';

  @override
  String get lb_serverError => 'El ranking está ocupado. Inténtalo más tarde.';

  @override
  String get lb_unavailable => 'El ranking no está disponible.';

  @override
  String get lb_optedOut =>
      'Activa «Unirme al ranking» para publicar tu puntuación.';

  @override
  String get lb_howTo =>
      'Nivel de colonia +100 · Nuevo sistema estelar +500 · Pirata +5 · Jefe +200';

  @override
  String get lb_resets =>
      'Cada lunes a las 00:00 UTC empieza una nueva semana.';

  @override
  String nickFormat(String adj, String animal, String number) {
    return '$animal $adj $number';
  }

  @override
  String get nickGenders =>
      'f,m,m,m,m,m,m,m,f,m,f,m,m,m,m,f,f,m,m,m,m,f,m,m,m,m,m,m,f,f,m,m,f,f,f,f,m,f,m,f';

  @override
  String nickAdj0(String g) {
    return 'Valiente';
  }

  @override
  String get nickAnimal0 => 'Nutria';

  @override
  String nickAdj1(String g) {
    return 'Radiante';
  }

  @override
  String get nickAnimal1 => 'Panda';

  @override
  String nickAdj2(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Tranquilo',
      'f': 'Tranquila',
      'n': 'Tranquilo',
      'other': 'Tranquilo',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal2 => 'Zorro';

  @override
  String nickAdj3(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Listo',
      'f': 'Lista',
      'n': 'Listo',
      'other': 'Listo',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal3 => 'Conejo';

  @override
  String nickAdj4(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Cósmico',
      'f': 'Cósmica',
      'n': 'Cósmico',
      'other': 'Cósmico',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal4 => 'Búho';

  @override
  String nickAdj5(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Curioso',
      'f': 'Curiosa',
      'n': 'Curioso',
      'other': 'Curioso',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal5 => 'Pingüino';

  @override
  String nickAdj6(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Saltarín',
      'f': 'Saltarina',
      'n': 'Saltarín',
      'other': 'Saltarín',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal6 => 'Koala';

  @override
  String nickAdj7(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Soñador',
      'f': 'Soñadora',
      'n': 'Soñador',
      'other': 'Soñador',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal7 => 'Delfín';

  @override
  String nickAdj8(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Calentito',
      'f': 'Calentita',
      'n': 'Calentito',
      'other': 'Calentito',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal8 => 'Tortuga';

  @override
  String nickAdj9(String g) {
    return 'Veloz';
  }

  @override
  String get nickAnimal9 => 'Erizo';

  @override
  String nickAdj10(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Esponjoso',
      'f': 'Esponjosa',
      'n': 'Esponjoso',
      'other': 'Esponjoso',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal10 => 'Ardilla';

  @override
  String nickAdj11(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Amistoso',
      'f': 'Amistosa',
      'n': 'Amistoso',
      'other': 'Amistoso',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal11 => 'Gatito';

  @override
  String nickAdj12(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Tierno',
      'f': 'Tierna',
      'n': 'Tierno',
      'other': 'Tierno',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal12 => 'Perrito';

  @override
  String nickAdj13(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Luminoso',
      'f': 'Luminosa',
      'n': 'Luminoso',
      'other': 'Luminoso',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal13 => 'Patito';

  @override
  String nickAdj14(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Dorado',
      'f': 'Dorada',
      'n': 'Dorado',
      'other': 'Dorado',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal14 => 'Corderito';

  @override
  String nickAdj15(String g) {
    return 'Feliz';
  }

  @override
  String get nickAnimal15 => 'Foca';

  @override
  String nickAdj16(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Gracioso',
      'f': 'Graciosa',
      'n': 'Gracioso',
      'other': 'Gracioso',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal16 => 'Ballena';

  @override
  String nickAdj17(String g) {
    return 'Amable';
  }

  @override
  String get nickAnimal17 => 'Hámster';

  @override
  String nickAdj18(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Afortunado',
      'f': 'Afortunada',
      'n': 'Afortunado',
      'other': 'Afortunado',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal18 => 'Castor';

  @override
  String nickAdj19(String g) {
    return 'Musical';
  }

  @override
  String get nickAnimal19 => 'Mapache';

  @override
  String nickAdj20(String g) {
    return 'Fuerte';
  }

  @override
  String get nickAnimal20 => 'Loro';

  @override
  String nickAdj21(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Colorido',
      'f': 'Colorida',
      'n': 'Colorido',
      'other': 'Colorido',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal21 => 'Mariquita';

  @override
  String nickAdj22(String g) {
    return 'Dulce';
  }

  @override
  String get nickAnimal22 => 'Gorrión';

  @override
  String nickAdj23(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Educado',
      'f': 'Educada',
      'n': 'Educado',
      'other': 'Educado',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal23 => 'Cervatillo';

  @override
  String nickAdj24(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Juguetón',
      'f': 'Juguetona',
      'n': 'Juguetón',
      'other': 'Juguetón',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal24 => 'Poni';

  @override
  String nickAdj25(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Silencioso',
      'f': 'Silenciosa',
      'n': 'Silencioso',
      'other': 'Silencioso',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal25 => 'Osito';

  @override
  String nickAdj26(String g) {
    return 'Brillante';
  }

  @override
  String get nickAnimal26 => 'Leoncito';

  @override
  String nickAdj27(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Plateado',
      'f': 'Plateada',
      'n': 'Plateado',
      'other': 'Plateado',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal27 => 'Tigrito';

  @override
  String nickAdj28(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Dormilón',
      'f': 'Dormilona',
      'n': 'Dormilón',
      'other': 'Dormilón',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal28 => 'Jirafa';

  @override
  String nickAdj29(String g) {
    return 'Lunar';
  }

  @override
  String get nickAnimal29 => 'Cebra';

  @override
  String nickAdj30(String g) {
    return 'Solar';
  }

  @override
  String get nickAnimal30 => 'Elefante';

  @override
  String nickAdj31(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Mágico',
      'f': 'Mágica',
      'n': 'Mágico',
      'other': 'Mágico',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal31 => 'Hipopótamo';

  @override
  String nickAdj32(String g) {
    return 'Súper';
  }

  @override
  String get nickAnimal32 => 'Llama';

  @override
  String nickAdj33(String g) {
    return 'Estelar';
  }

  @override
  String get nickAnimal33 => 'Alpaca';

  @override
  String nickAdj34(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Soleado',
      'f': 'Soleada',
      'n': 'Soleado',
      'other': 'Soleado',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal34 => 'Suricata';

  @override
  String nickAdj35(String g) {
    return 'Noble';
  }

  @override
  String get nickAnimal35 => 'Estrella de mar';

  @override
  String nickAdj36(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Diminuto',
      'f': 'Diminuta',
      'n': 'Diminuto',
      'other': 'Diminuto',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal36 => 'Caballito de mar';

  @override
  String nickAdj37(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Sabio',
      'f': 'Sabia',
      'n': 'Sabio',
      'other': 'Sabio',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal37 => 'Ardilla listada';

  @override
  String nickAdj38(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Nevado',
      'f': 'Nevada',
      'n': 'Nevado',
      'other': 'Nevado',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal38 => 'Pez dorado';

  @override
  String nickAdj39(String g) {
    return 'Leal';
  }

  @override
  String get nickAnimal39 => 'Luciérnaga';

  @override
  String get m_adPrivacy => 'Privacidad de anuncios';
}
