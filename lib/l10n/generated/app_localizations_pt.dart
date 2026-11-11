// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class L10nPt extends L10n {
  L10nPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Star Settlers';

  @override
  String get languageName => 'Português';

  @override
  String get u_tabShip => 'Nave';

  @override
  String get u_tabStation => 'Estação';

  @override
  String get u_tabCrew => 'Tripulação';

  @override
  String get u_tabMission => 'Missões';

  @override
  String get u_tabMarket => 'Mercado';

  @override
  String u_upWeapon(int dmg) {
    return 'Dano $dmg · Lv.3 duplo · Lv.6 triplo';
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
  String get u_upMissileIntro => 'Mísseis teleguiados (tecla Q / botão 🚀)';

  @override
  String u_upMissile(int count, String cooldown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mísseis',
      one: '1 míssil',
    );
    return '$_temp0 · recarga ${cooldown}s';
  }

  @override
  String get u_upShieldIntro =>
      'Escudo que bloqueia todo dano (tecla F / botão 🛡)';

  @override
  String u_upShield(String duration, String cooldown) {
    return '${duration}s · recarga ${cooldown}s';
  }

  @override
  String get u_upDroneIntro => 'Orbita você, atira sozinho e puxa itens';

  @override
  String u_upDrone(int dmg, String interval) {
    return 'Dano $dmg · atira a cada ${interval}s';
  }

  @override
  String u_upMagnet(int range, String power) {
    return 'Puxa créditos e minério · alcance $range · força x$power';
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
  String get u_speed => 'Velocidade';

  @override
  String get u_attack => 'Ataque';

  @override
  String get u_fireRate => 'Cadência';

  @override
  String get u_ore => 'Minério';

  @override
  String get u_crit => 'Crítico';

  @override
  String get u_boarded => 'A bordo';

  @override
  String get u_board => 'Embarcar';

  @override
  String get u_boardNow => 'Embarcar';

  @override
  String get u_gemsOnly => 'Só com gemas';

  @override
  String u_unlockOrGems(String condition) {
    return 'Desbloqueio: $condition ou gemas';
  }

  @override
  String u_unlock(String condition) {
    return 'Desbloqueio: $condition';
  }

  @override
  String u_durability(int hp, int max) {
    return 'Casco $hp / $max';
  }

  @override
  String get u_habitat => 'Habitat';

  @override
  String u_habitatDesc(String rate, int hp) {
    return 'Renda 💰$rate/s · Casco $hp';
  }

  @override
  String get u_turret => 'Torre de defesa';

  @override
  String get u_turretIntro => 'Atira em piratas automaticamente';

  @override
  String u_turretDesc(int dmg, int range) {
    return 'Dano $dmg · Alcance $range';
  }

  @override
  String get u_baseUpgrade => 'Melhoria da base';

  @override
  String u_baseDesc(int dmg, int range, int hp) {
    return 'Laser $dmg · Alcance $range · Casco $hp';
  }

  @override
  String u_disabledSec(int sec) {
    return 'Desativada ${sec}s';
  }

  @override
  String u_sectorStatus(String sector) {
    return 'Situação de $sector';
  }

  @override
  String u_sectorStats(
    int colonies,
    int planets,
    int stations,
    String mul,
    String other,
  ) {
    return 'Planetas colonizados $colonies / $planets\nEstações: $stations\nBônus do sistema: produção x$mul\nOutros sistemas: 💰$other/s';
  }

  @override
  String get u_legendaryGet => '🌟 Lendário! 🌟';

  @override
  String get u_rareGet => '✨ Tripulante raro! ✨';

  @override
  String get u_newCrew => 'Novo tripulante!';

  @override
  String get u_great => 'Oba!';

  @override
  String u_crewHeader(int count, int cap, int assigned, int slots) {
    return 'Tripulação $count/$cap · Escalados $assigned/$slots';
  }

  @override
  String u_recruit(int cost) {
    return 'Recrutar 💰$cost';
  }

  @override
  String u_recruitPremium(int cost) {
    return 'Recrutamento premium ⭐$cost';
  }

  @override
  String u_recruitLegendary(int cost) {
    return '🌟 Lendário garantido ⭐$cost';
  }

  @override
  String u_recruitOdds(String normal, String premium) {
    return 'Chances · Recrutar: $normal\nRecrutamento premium: $premium\nLendário garantido: ★4 100%';
  }

  @override
  String u_slotMax(int n) {
    return 'Vagas MÁX. ($n)';
  }

  @override
  String u_slotBuy(int price) {
    return 'Vaga +1 ⭐$price';
  }

  @override
  String u_rosterMax(int n) {
    return 'Elenco MÁX. ($n)';
  }

  @override
  String u_rosterBuy(int size, int price) {
    return 'Elenco +$size ⭐$price';
  }

  @override
  String get u_noCrew =>
      'Ainda sem tripulantes. Recrute e escale-os na sua nave!';

  @override
  String get u_unassign => 'Retirar';

  @override
  String get u_assign => 'Escalar';

  @override
  String get u_dismiss => 'Dispensar';

  @override
  String get u_dismissCrewTitle => 'Dispensar tripulante';

  @override
  String u_dismissCrewBody(String name) {
    return 'Deixar $name ir embora? Não dá para desfazer.';
  }

  @override
  String get u_missionDeliverHint => 'Vá até o destino (seta amarela)';

  @override
  String get u_missionBountyHint => 'Encontre e derrote o alvo (seta amarela)';

  @override
  String u_reward(String rewards) {
    return 'Recompensa $rewards';
  }

  @override
  String u_activeMissions(int n) {
    return 'Em andamento ($n/3)';
  }

  @override
  String get u_noActiveMissions => 'Nenhuma missão em andamento.';

  @override
  String get u_abandon => 'Abandonar';

  @override
  String u_missionBoard(int sec) {
    return 'Quadro de missões · novas em ${sec}s';
  }

  @override
  String get u_accept => 'Aceitar';

  @override
  String get u_priceHigh => '📈 Alta! Hora de vender';

  @override
  String get u_priceLow => '📉 Baixa… melhor esperar';

  @override
  String get u_priceNormal => '➡ Normal';

  @override
  String get u_orePrice => 'Preço do minério';

  @override
  String get u_sell100 => 'Vender 100';

  @override
  String get u_sellHalf => 'Vender metade';

  @override
  String get u_sellAll => 'Vender tudo';

  @override
  String get u_marketTip =>
      'Os preços sobem e descem com o tempo. Venda na alta!';

  @override
  String get u_gemExchange => '⭐ Troca de Gemas Estelares';

  @override
  String get u_creditPack => 'Pacote de créditos';

  @override
  String get u_exchange => 'Trocar';

  @override
  String get u_openShop => '⭐ Abrir loja';

  @override
  String u_achievementDone(String title, int gems) {
    return '🏆 Conquista: $title! Resgate ⭐$gems em Menu > Conquistas.';
  }

  @override
  String get u_cannotDo =>
      'Recursos insuficientes, ou não dá para fazer isso agora.';

  @override
  String get u_welcomeBack => 'Bem-vindo de volta, capitão!';

  @override
  String u_offlineHm(int h, int m) {
    return 'Enquanto você esteve fora por ${h}h ${m}min,\nsuas colônias trabalharam duro!';
  }

  @override
  String u_offlineM(int m) {
    return 'Enquanto você esteve fora por ${m}min,\nsuas colônias trabalharam duro!';
  }

  @override
  String get u_passOfflineHint => 'Passe de Comandante: até 8h + 2x automático';

  @override
  String get u_collect => 'Coletar';

  @override
  String get u_adLoading => 'Carregando anúncio. Tente de novo em instantes.';

  @override
  String get u_adLoadingRetry =>
      'Carregando anúncio. Toque de novo em instantes.';

  @override
  String get u_collectDouble => 'Coletar 2x 👑';

  @override
  String get u_adDouble => '📺 Ver anúncio para 2x';

  @override
  String get u_galaxyHonor => '🌌 Honra Galáctica';

  @override
  String u_honorStatus(int honor, int ascensions) {
    return 'Honra $honor (ascendeu ${ascensions}x)';
  }

  @override
  String u_honorBonus(int income, int attack) {
    return 'Renda +$income% · Dano +$attack%';
  }

  @override
  String get u_ascendExplain =>
      'Ascender reinicia este universo (sistemas, colônias, estações, melhorias da nave, tripulação, créditos)\ne concede honra, um bônus permanente.\nGemas, cosméticos, naves e conquistas são mantidos.';

  @override
  String u_ascendGain(int gain) {
    return 'Ascenda agora e ganhe +$gain de honra!\n(Quanto maior seu império, mais você ganha)';
  }

  @override
  String get u_ascendLocked => 'Chegue ao sistema 4 para ascender.';

  @override
  String get u_close => 'Fechar';

  @override
  String u_ascendBtn(int gain) {
    return 'Ascender (+$gain)';
  }

  @override
  String get u_ascendConfirmTitle => 'Ascender mesmo?';

  @override
  String get u_ascendConfirmBody =>
      'Seu universo atual será reiniciado. Não dá para desfazer.';

  @override
  String get u_ascend => 'Ascender';

  @override
  String u_shieldBroken(String name) {
    return '$name quebrado';
  }

  @override
  String u_hudSector(String sector, int dev, String threat, String value) {
    return '$sector · Estab. $dev%\n⚠ Ameaça $threat  🏛 $value';
  }

  @override
  String u_baseDisabled(int sec) {
    return 'Base parada ${sec}s';
  }

  @override
  String u_baseHp(int pct) {
    return 'Base $pct%';
  }

  @override
  String u_invasionCountdown(int sec) {
    return 'Invasão em ${sec}s';
  }

  @override
  String u_invasionWave(int wave, int total, int left) {
    return 'Invasão $wave/$total · restam $left';
  }

  @override
  String u_invasionWon(int credits) {
    return 'Repelida! 💰$credits ⭐5';
  }

  @override
  String u_invasionRetreat(int pct, int credits) {
    return 'Recuaram · $pct% · 💰$credits';
  }

  @override
  String get u_merchantE => 'Mercador (E)';

  @override
  String get u_nextSectorE => 'Próx. sistema (E)';

  @override
  String get u_prevSectorE => 'Sistema ant. (E)';

  @override
  String u_gateLocked(int pct) {
    return '🔒 Abre com 100% de Estabilização ($pct%)';
  }

  @override
  String u_settle(String name) {
    return 'Colonizar $name';
  }

  @override
  String u_manageE(String name) {
    return 'Gerenciar $name (E)';
  }

  @override
  String get u_buildStation => 'Construir estação';

  @override
  String get u_fire => 'FOGO';

  @override
  String get u_equipAtStation => 'Você pode equipar na aba Nave da estação!';

  @override
  String get u_shotDown => '💥 Você foi abatido!';

  @override
  String u_autoRespawn(int sec) {
    return 'Renascimento automático na base em ${sec}s';
  }

  @override
  String get u_reviveFree => '👑 Reviver aqui (grátis)';

  @override
  String get u_reviveAd => '📺 Ver anúncio para reviver aqui';

  @override
  String get u_reviveGems => 'Reviver aqui por ⭐10';

  @override
  String u_respawnBase(int pct) {
    return '🏠 Renascer na base (perde $pct% dos créditos)';
  }

  @override
  String get u_spkCaptain => 'Capitão';

  @override
  String get u_spkPirate => 'Pirata';

  @override
  String get u_spkAdvisor => 'cientista espacial Mina';

  @override
  String get u_spkMerchant => 'Nyang, o Mercador';

  @override
  String get u_paused => 'Pausado';

  @override
  String u_pauseStats(
    String sector,
    int kills,
    int crew,
    int colonies,
    int stations,
    int missions,
  ) {
    return '$sector · Abates $kills · Tripulação $crew\nColônias $colonies · Estações $stations · Missões $missions';
  }

  @override
  String get u_resume => '▶︎ Continuar';

  @override
  String get u_shop => '⭐ Loja';

  @override
  String get u_achievements => '🏆 Conquistas';

  @override
  String get u_dailyQuests => '📅 Missões diárias';

  @override
  String get u_myPlanet => '🌍 Meu planeta';

  @override
  String get u_ascendMenu => '🌌 Honra Galáctica (Ascender)';

  @override
  String get u_settings => '⚙ Configurações';

  @override
  String get u_saveAndQuit => '💾 Salvar e voltar ao título';

  @override
  String get u_keyboardHelp =>
      'Teclas: WASD mover · Space atirar · Q míssil · F escudo · Shift impulso\nE interagir · B construir estação · Esc menu';

  @override
  String get u_recharging => 'Recarregando';

  @override
  String get u_tutDome => 'Escudo\nseguro dentro';

  @override
  String get u_tutLevelUp => 'Subir nível\nrenda·prédios↑';

  @override
  String get u_tutTurret => 'Torre';

  @override
  String get u_tutRepair => 'Reparar';

  @override
  String get u_tutRaid => 'Parar ataques';

  @override
  String get u_gotIt => 'Entendi';

  @override
  String u_damage(int dmg) {
    return 'Dano $dmg';
  }

  @override
  String u_oreRate(String rate) {
    return 'Minério +$rate/s';
  }

  @override
  String u_incomePct(int pct) {
    return 'Renda +$pct%';
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
    return 'Ameaça $threat · Recursos x$mul';
  }

  @override
  String u_development(int pct) {
    return 'Estabilização $pct%';
  }

  @override
  String get u_nextSystemOpen => 'Próximo sistema aberto';

  @override
  String get u_opensAt100 => 'Abre com 100%';

  @override
  String get u_devHint =>
      '100% quando a soma dos níveis dos Âncoras de Fase for planetas × 3';

  @override
  String u_stabilizerHealth(int hp, int max) {
    return 'Durabilidade $hp/$max';
  }

  @override
  String g_foeIntro(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missile':
          'Um lança-mísseis! Os mísseis te perseguem, mas dá para derrubá-los.',
      'laser':
          'Uma nave laser está mirando! Ao ver a linha vermelha, desvie para o lado.',
      'warden':
          'Um guardião protege os piratas próximos. Dentro do anel azul eles levam metade do dano: derrube-o primeiro!',
      'carrier':
          'Um porta-drones! Ele lança drones sem parar, ataque o porta-drones primeiro.',
      'phantom':
          'Um fantasma some e reaparece. Concentre o fogo quando ele estiver visível!',
      'mine':
          'Um lançador de minas! As minas amarelas explodem de perto, mas dá para atirar nelas.',
      'medic':
          'Uma nave de reparo está consertando os piratas. Derrube-a lá atrás primeiro!',
      'juggernaut':
          'Um colosso! A blindagem frontal é dura: mire nas laterais ou na traseira e desvie da investida.',
      'other': 'Um novo inimigo!',
    });
    return '$_temp0';
  }

  @override
  String u_levelUnlockAtSystem(int level, int system) {
    return 'Nv.$level liberado no sistema estelar $system';
  }

  @override
  String get u_myColonies => 'Minhas colônias';

  @override
  String get u_myColoniesHint =>
      'Evolua qualquer colônia daqui, onde quer que esteja.';

  @override
  String get u_noColonies =>
      'Ainda não há colônias. Voe até um planeta e colonize-o.';

  @override
  String get u_currentHere => 'Você está aqui';

  @override
  String u_anchorEffect(int income, int shield, int regen) {
    return 'Renda +$income% · Escudo compartilhado $shield · Regen. +$regen%';
  }

  @override
  String get u_conqueredSystems => 'Sistemas conquistados (ainda produzindo)';

  @override
  String get u_unsettled => 'Não colonizado';

  @override
  String get u_underRaid => 'Sob ataque';

  @override
  String u_unknownSector(int n) {
    return 'Sistema desconhecido $n';
  }

  @override
  String u_sectorDev(String name, int pct) {
    return '$name · Estab. $pct%';
  }

  @override
  String get u_buildStationTitle => 'Construir estação · Escolha uma função';

  @override
  String get u_cost => 'Custo';

  @override
  String get u_build => 'Construir';

  @override
  String get u_toNextSector => '🌀 Para o próximo sistema';

  @override
  String get u_bossLocked => '🔒 Derrote o chefe para abrir';

  @override
  String get u_toPrevSector => '🌀 Para o sistema anterior';

  @override
  String get u_raidAlert => '⚠ Sob ataque!';

  @override
  String u_rechargePct(int pct) {
    return 'Recarga $pct%';
  }

  @override
  String u_merchantLabel(int sec) {
    return '🛒 Mercador Errante (${sec}s)';
  }

  @override
  String get u_supplyPod => '📦 Cápsula de suprimentos';

  @override
  String u_sectorBoss(String sector) {
    return '☠ Chefe de $sector';
  }

  @override
  String get u_pirateBoss => '☠ Chefe pirata';

  @override
  String get u_merchantName => 'Nyang, Mercador Errante';

  @override
  String u_merchantLeaves(int sec, String credits) {
    return 'Parte em ${sec}s · 💰$credits';
  }

  @override
  String get u_rareCrewOffer => 'Tripulante raro para contratar';

  @override
  String get u_crewSoldOut => 'O tripulante de hoje já foi vendido, miau!';

  @override
  String get u_gemTrade => 'Troca de gemas (máx. 3)';

  @override
  String u_gemTradeRow(int price, int left) {
    return '💰$price → ⭐5  (restam $left)';
  }

  @override
  String get u_convert => 'Trocar';

  @override
  String get u_potions => 'Poções de reforço (duração 2x)';

  @override
  String get u_notEnoughGems => 'Gemas insuficientes';

  @override
  String get u_buyConfirmTitle => 'Confirmar compra';

  @override
  String u_buyShipConfirm(String ship, String price) {
    return 'Gastar $price na $ship?';
  }

  @override
  String u_shipBought(String ship) {
    return 'Você ganhou a $ship! Já está a bordo.';
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
  String get u_ok => 'OK';

  @override
  String get u_cancel => 'Cancelar';

  @override
  String get m_ok => 'OK';

  @override
  String get m_cancel => 'Cancelar';

  @override
  String get m_close => 'Fechar';

  @override
  String get m_claim => 'Resgatar';

  @override
  String m_claimGems(int gems) {
    return 'Resgatar ⭐$gems';
  }

  @override
  String get m_done => '✅ Feito';

  @override
  String get m_notEnoughGems => 'Gemas insuficientes';

  @override
  String get m_restorePurchases => 'Restaurar compras';

  @override
  String get m_restoreDone => 'Compras verificadas';

  @override
  String get m_buyConfirmTitle => 'Confirmar compra';

  @override
  String m_spendGemsConfirm(String price) {
    return 'Gastar $price?';
  }

  @override
  String get m_loginTitle => '📅 Login diário';

  @override
  String get m_loginWelcome => 'Que bom te ver de novo, capitão!';

  @override
  String get m_loginFirst =>
      'Bem-vindo a bordo, capitão! Aqui está sua primeira recompensa.';

  @override
  String get m_loginStreakHint => 'Entre 7 dias seguidos e ganhe ⭐50!';

  @override
  String get m_newGameTitle => 'Novo jogo';

  @override
  String get m_newGameBody =>
      'Seu progresso atual será apagado.\n(Gemas, cosméticos, conquistas e compras são mantidos.) Continuar?';

  @override
  String get m_start => 'Começar';

  @override
  String get m_loadFailed => 'Não foi possível carregar seus dados salvos.';

  @override
  String m_honorLine(int honor, int income, int attack) {
    return '🌌 Honra Galáctica $honor · Renda +$income% · Ataque +$attack%';
  }

  @override
  String get m_continue => 'Continuar';

  @override
  String get m_newGame => '✨ Novo jogo';

  @override
  String get m_menuHome => 'Meu planeta';

  @override
  String get m_menuShop => 'Loja';

  @override
  String get m_menuQuest => 'Missões';

  @override
  String get m_menuAchievements => 'Conquistas';

  @override
  String get m_menuSettings => 'Ajustes';

  @override
  String m_achievementsTitle(int done, int total) {
    return '🏆 Conquistas ($done/$total)';
  }

  @override
  String get m_dailyTitle => '📅 Missões diárias';

  @override
  String m_dailyReset(int hours, int minutes) {
    return 'Reinicia em ${hours}h ${minutes}min';
  }

  @override
  String get m_dailyBonusTitle => '🎁 Bônus de conclusão';

  @override
  String get m_dailyBonusDesc => 'Resgate as 3 missões de hoje';

  @override
  String get m_settingsTitle => '⚙ Configurações';

  @override
  String get m_settingsSound => 'Efeitos sonoros';

  @override
  String get m_settingsMusic => 'Música';

  @override
  String get m_settingsNotify => 'Lembretes de retorno';

  @override
  String get m_settingsNotifyDesc =>
      'Avisamos quando o armazém da colônia estiver cheio';

  @override
  String get m_settingsHaptics => 'Vibração';

  @override
  String get m_settingsLanguage => 'Idioma';

  @override
  String get m_languageSystem => 'Usar idioma do aparelho';

  @override
  String get m_settingsOrientation => 'Orientação da tela';

  @override
  String get m_orientAuto => 'Automática';

  @override
  String get m_orientPortrait => 'Retrato';

  @override
  String get m_orientLandscape => 'Paisagem';

  @override
  String get m_privacyTitle => 'Política de Privacidade';

  @override
  String m_privacyBody(String email) {
    return 'Star Settlers não exige cadastro e não coleta informações de identificação pessoal. Os dados do jogo (progresso, créditos e minério, cosméticos, ajustes) ficam salvos no seu aparelho. As gemas e os registros de compra ficam em uma carteira de gemas no nosso servidor, para que não possam ser falsificados nem perdidos, e o ranking semanal opcional abaixo só envia dados se você ativá-lo.\n\nCompras: processadas pelo Google Play / App Store; os dados de pagamento nunca são compartilhados com o desenvolvedor. O RevenueCat verifica e restaura as compras, processando um ID de instalação aleatório e o histórico de compras. Quando a compra é confirmada, o servidor credita a sua carteira de gemas.\n\nCarteira de gemas: as gemas ficam no nosso servidor, não no seu aparelho, então não dá para aumentá-las adulterando-o. O servidor guarda um ID de instalação aleatório (não é um ID de publicidade nem do aparelho), o seu saldo de gemas, os registros de gemas ganhas e gastas e os registros de compra; nada de nomes nem nada que você digite. Para gastar gemas é preciso internet. O servidor é o Supabase (região de Seul).\n\nBackup na nuvem (opcional): só funciona se você conectar sua conta do Google Play Games ou do Game Center nas Configurações e fizer backup. Seu progresso, suas configurações e o ID de instalação aleatório ficam nos seus jogos salvos do Google Play Games ou no iCloud, não no servidor do desenvolvedor.\n\nAnúncios: os anúncios premiados do Google AdMob só aparecem quando você escolhe assistir. O AdMob pode usar o ID de publicidade, o endereço IP e informações do aparelho para exibir anúncios, personalizá-los quando permitido e medi-los. No EEE, no Reino Unido e na Suíça, seu consentimento é pedido na primeira vez que você abre o jogo e pode ser alterado em Configurações → Privacidade dos anúncios.\n\nNotificações: notificações locais agendadas no seu aparelho; nada é enviado.\n\nFeedback: sua mensagem, a versão do app e as informações do aparelho só chegam ao desenvolvedor se você mesmo enviar o e-mail.\n\nRanking semanal (opcional): desativado por padrão; você só participa se ativar em Ajustes ou na tela do ranking. Só são enviados um ID de instalação aleatório, um apelido que o jogo cria a partir de listas fixas de palavras e sua pontuação semanal. Nada de nomes, nada que você digite e sem chat. Os outros jogadores veem só o apelido e a pontuação. O servidor é o Supabase (região de Seul).\n\nExclusão: Ajustes → Apagar todos os dados apaga os dados do seu aparelho. Apagar os dados também zera o seu saldo de gemas no servidor; o Pacote Inicial e o Passe de Comandante da Frota voltam pelos seus registros de compra. Se você participou do ranking, apagar os dados também exclui seu registro no servidor (ID, apelido, pontuação); você também pode pedir a exclusão por e-mail.\n\nPolítica completa: https://rumururu.github.io/mkideabox/star_settlers/privacy.html\nContato: $email';
  }

  @override
  String get m_wipeTitle => 'Apagar todos os dados';

  @override
  String get m_wipeDesc =>
      'Exclui todo o progresso, gemas, cosméticos e seu registro no ranking';

  @override
  String get m_wipeConfirmTitle => 'Apagar tudo mesmo?';

  @override
  String get m_wipeConfirmBody =>
      'Não dá para desfazer. As gemas e o progresso são apagados para sempre. O Pacote Inicial e o Passe de Comandante da Frota podem ser recuperados com \"Restaurar compras\".';

  @override
  String get m_wipeOk => 'Apagar';

  @override
  String get m_feedbackTitle => 'Enviar feedback ao desenvolvedor';

  @override
  String get m_feedbackDesc =>
      'Bugs, ideias, qualquer coisa! O aparelho e a versão do app são preenchidos automaticamente.';

  @override
  String m_noMailApp(String email) {
    return 'Nenhum app de e-mail encontrado. Escreva para $email.';
  }

  @override
  String get m_aboutTitle => 'STAR SETTLERS';

  @override
  String m_version(String version) {
    return 'Versão $version';
  }

  @override
  String get m_shopTitle => '⭐ Loja';

  @override
  String get m_buyThanks => 'Compra concluída! Obrigado 💜';

  @override
  String get m_walletOffline =>
      'As gemas ficam guardadas no nosso servidor. Conecte-se à internet e tente novamente.';

  @override
  String get m_purchasePending =>
      'Pagamento concluído. Suas gemas chegam assim que for confirmado.';

  @override
  String get m_adLoading => 'Carregando anúncio. Tente de novo em instantes.';

  @override
  String m_buyShipConfirm(String ship, String price) {
    return 'Gastar $price em $ship?';
  }

  @override
  String m_shipAcquired(String ship) {
    return 'Você ganhou $ship! Já está a bordo';
  }

  @override
  String get m_tabGems => 'Gemas';

  @override
  String get m_tabPacks => 'Pacotes';

  @override
  String get m_tabPremiumShips => 'Naves premium';

  @override
  String get m_tabSkins => 'Skins de nave';

  @override
  String get m_tabOutfits => 'Trajes de capitão';

  @override
  String get m_tabFree => 'Gemas grátis';

  @override
  String get m_testMode =>
      '🧪 Modo de teste: sem pagamentos reais; anúncios de teste do Google';

  @override
  String get m_owned => 'Adquirido';

  @override
  String get m_boarded => 'Pilotando';

  @override
  String get m_gemsInfo =>
      'Use gemas em cosméticos, recrutamento premium, reviver na hora e troca por créditos.\nVocê também ganha jogando (conquistas, logins, chefes, cápsulas de suprimentos).';

  @override
  String get m_crewSection => '👩‍🚀 Tripulação (gemas)';

  @override
  String get m_premiumSection => '🛸 Naves premium';

  @override
  String get m_premiumDesc =>
      'Caças especiais disponíveis só com gemas, cada um com uma habilidade única.';

  @override
  String get m_viewLarge => 'Ver em tamanho grande';

  @override
  String get m_premiumHangarHint =>
      'Você também pode comprar e trocar de nave no Hangar (Estação → aba Nave).';

  @override
  String get m_legendTitle => 'Recrutamento lendário garantido';

  @override
  String get m_legendDescNoGame =>
      '1 tripulante lendário ★4 (bônus de 20%+ + toda a produção +40%, título, aura dourada)\nDisponível após iniciar um jogo';

  @override
  String m_legendDesc(int count, int cap) {
    return '1 tripulante lendário ★4 (bônus de 20%+ + toda a produção +40%, título, aura dourada)\nTripulação $count/$cap';
  }

  @override
  String m_crewJoined(String stars, String name) {
    return '$stars $name entrou na equipe!';
  }

  @override
  String get m_slotTitle => 'Vaga de tripulação +1';

  @override
  String m_slotDesc(int slots) {
    return 'Tripulantes que você pode escalar ao mesmo tempo · Agora $slots';
  }

  @override
  String m_rosterTitle(int n) {
    return 'Capacidade de tripulação +$n';
  }

  @override
  String m_rosterDesc(int cap, int max) {
    return 'Tripulantes que você pode ter · Agora $cap (máx. $max)';
  }

  @override
  String m_crewOdds(String odds) {
    return 'Chances do recrutamento premium: $odds · Lendário garantido: ★4 100%';
  }

  @override
  String get m_equipped => 'Equipado';

  @override
  String get m_equip => 'Equipar';

  @override
  String get m_passOnly => 'Só no Passe de Comandante';

  @override
  String get m_starterOnly => 'Só no Pacote Inicial';

  @override
  String get m_adSection => '📺 Gemas grátis com anúncios';

  @override
  String m_adInfo(int perDay, int left) {
    return '$perDay vezes por dia, ⭐5 cada · restam $left hoje';
  }

  @override
  String get m_adClaimPremium =>
      'Resgatar ⭐5 (Passe de Comandante: sem anúncios)';

  @override
  String get m_adWatch => 'Ver anúncio por ⭐5';

  @override
  String m_loginStreak(int days) {
    return 'Sequência de login: dia $days';
  }

  @override
  String m_dayN(int day) {
    return 'Dia $day';
  }

  @override
  String get m_notEnoughResources => 'Recursos insuficientes';

  @override
  String m_emptyLot(int n) {
    return 'Lote vazio #$n · Construir';
  }

  @override
  String get m_buildInGameOnly =>
      'Você pode construir durante um jogo (Menu → Meu planeta). Créditos e minério vêm do seu universo atual.';

  @override
  String m_heldAll(String credits, String ore, int gems) {
    return 'Você tem 💰$credits  💎$ore  ⭐$gems';
  }

  @override
  String m_held(String credits, String ore) {
    return 'Você tem 💰$credits  💎$ore';
  }

  @override
  String m_currentEffect(String effect) {
    return 'Atual: $effect';
  }

  @override
  String m_nextLevel(String effect) {
    return 'Próximo nível: $effect';
  }

  @override
  String m_upgrade(String cost) {
    return 'Melhorar $cost';
  }

  @override
  String get m_maxLevel => '🌟 Nível máximo';

  @override
  String get m_planetName => 'Nome do planeta';

  @override
  String get m_decorateTitle => '🎨 Decorar planeta';

  @override
  String get m_planetRing => 'Anel planetário';

  @override
  String get m_giftInGameOnly =>
      'Presentes só podem ser coletados durante um jogo';

  @override
  String get m_giftTitle => '🎁 Presente do planeta';

  @override
  String m_giftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Um presente dos seus $count moradores!',
      one: 'Um presente do seu 1 morador!',
    );
    return '$_temp0';
  }

  @override
  String get m_giftThanks => 'Valeu!';

  @override
  String m_planetStatus(int level, int residents, int built, int slots) {
    return 'Planeta Lv.$level · $residents moradores · Prédios $built/$slots';
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
    return 'Bônus permanente · Renda +$income%  Minério +$ore%  Ataque +$attack%  PV +$hp%  Recarga -$cooldown%  Offline $offline%';
  }

  @override
  String get m_planetHint =>
      'Deslize para girar o planeta, toque num lote para construir';

  @override
  String get m_giftClaim => '🎁 Coletar presente';

  @override
  String m_giftWait(int hours, int minutes) {
    return '🎁 Presente em ${hours}h ${minutes}min';
  }

  @override
  String m_planetLevelUp(int level, String cost) {
    return '🌍 Planeta Lv.$level (+2 lotes) $cost';
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
      'Rápida e de tiro veloz, mas com blindagem fina';

  @override
  String get g_shipFortressDesc => 'Lenta, mas resistente e de golpes pesados';

  @override
  String get g_shipProspectorDesc => 'Minério +50%, atrai itens de longe';

  @override
  String get g_shipPhantomDesc => '25% de chance de crítico 2,5x';

  @override
  String get g_shipNovaDesc => 'Caça premium cujos tiros atravessam inimigos';

  @override
  String get g_shipAuroraDesc =>
      'Guardiã premium que se autorrepara e usa uma barreira';

  @override
  String get g_shipNovaAbility =>
      'Tiros perfurantes: cada tiro atravessa até 3 inimigos';

  @override
  String get g_shipAuroraAbility =>
      'Autorreparo: recupera 5% de PV/s após 3s sem dano\nGuarda: bloqueia 1 golpe a cada 5s';

  @override
  String g_crewLegendPerk(int pct) {
    return '👑 Comando lendário: toda a produção (créditos e minério) +$pct% (não acumula)';
  }

  @override
  String g_shipCreditBonus(int pct) {
    return '💰 Bônus de caçador: +$pct% de créditos que você mesmo ganha (recompensas, asteroides, missões, defesa contra ataques)';
  }

  @override
  String g_unlockSector(int n) {
    return 'Chegue ao sistema $n';
  }

  @override
  String g_unlockBosses(int n) {
    return 'Derrote $n chefes piratas';
  }

  @override
  String g_unlockOre(int n) {
    return 'Colete $n de minério';
  }

  @override
  String get g_skinDefault => 'Scout básica';

  @override
  String get g_skinCrimson => 'Cometa Vermelho';

  @override
  String get g_skinMint => 'Menta com Chocolate';

  @override
  String get g_skinStealth => 'Preto Furtivo';

  @override
  String get g_skinNeon => 'Rosa Neon';

  @override
  String get g_skinRainbow => 'Sonho Arco-íris';

  @override
  String get g_skinGalaxy => 'Galáxia';

  @override
  String get g_skinGold => 'Ouro Real';

  @override
  String get g_outfitDefault => 'Traje espacial básico';

  @override
  String get g_outfitCat => 'Capacete de gatinho';

  @override
  String get g_outfitBunny => 'Orelhas de coelho';

  @override
  String get g_outfitAlien => 'Antenas alienígenas';

  @override
  String get g_outfitFlower => 'Presilha de flor';

  @override
  String get g_outfitHat => 'Chapéu de capitão';

  @override
  String get g_outfitCrown => 'Coroa galáctica';

  @override
  String get g_crewRoleGunner => 'Artilheiro';

  @override
  String get g_crewEffectGunner => 'Ataque';

  @override
  String get g_crewRoleEngineer => 'Engenheiro';

  @override
  String get g_crewEffectEngineer => 'PV máx. e reparo';

  @override
  String get g_crewRolePilot => 'Piloto';

  @override
  String get g_crewEffectPilot => 'Velocidade';

  @override
  String get g_crewRoleTrader => 'Comerciante';

  @override
  String get g_crewEffectTrader => 'Renda de créditos';

  @override
  String get g_crewRoleMiner => 'Minerador';

  @override
  String get g_crewEffectMiner => 'Ganho de minério';

  @override
  String get g_crewRoleScientist => 'Cientista';

  @override
  String get g_crewEffectScientist => 'Recarga de habilidades';

  @override
  String get g_crewName0 => 'Bolinha';

  @override
  String get g_crewName1 => 'Coco';

  @override
  String get g_crewName2 => 'Estrelinha';

  @override
  String get g_crewName3 => 'Tofu';

  @override
  String get g_crewName4 => 'Feijão';

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
  String get g_crewName10 => 'Fofura';

  @override
  String get g_crewName11 => 'Borboleta';

  @override
  String get g_crewName12 => 'Choco';

  @override
  String get g_crewName13 => 'Cevadinha';

  @override
  String get g_crewName14 => 'Nuvem';

  @override
  String get g_crewName15 => 'Garoa';

  @override
  String get g_crewName16 => 'Tori';

  @override
  String get g_crewName17 => 'Happy';

  @override
  String get g_crewName18 => 'Arrozinho';

  @override
  String get g_crewName19 => 'Mochi';

  @override
  String get g_crewName20 => 'Latte';

  @override
  String get g_crewName21 => 'Biscoito';

  @override
  String get g_crewName22 => 'Jujuba';

  @override
  String get g_crewName23 => 'Algodão';

  @override
  String get g_crewName24 => 'Manga';

  @override
  String get g_crewName25 => 'Ameixa';

  @override
  String get g_crewName26 => 'Noz';

  @override
  String get g_crewName27 => 'Carvãozinho';

  @override
  String get g_crewName28 => 'Bambi';

  @override
  String get g_crewName29 => 'Queijo';

  @override
  String get g_crewLegend0 => 'Guardião Galáctico';

  @override
  String get g_crewLegend1 => 'Herói Estelar';

  @override
  String get g_crewLegend2 => 'Sábio da Nebulosa';

  @override
  String get g_crewLegend3 => 'Cavaleiro Cometa';

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
    return 'Moradores +$n (mais presentes)';
  }

  @override
  String get g_bldFarm => 'Fazenda espacial';

  @override
  String g_bldFarmEffect(int n) {
    return 'Renda de créditos +$n%';
  }

  @override
  String get g_bldMine => 'Mina';

  @override
  String g_bldMineEffect(int n) {
    return 'Ganho de minério +$n%';
  }

  @override
  String get g_bldLab => 'Laboratório';

  @override
  String g_bldLabEffect(int n) {
    return 'Recarga de habilidades -$n%';
  }

  @override
  String get g_bldTower => 'Torre de defesa';

  @override
  String g_bldTowerEffect(int n) {
    return 'PV máx. +$n%';
  }

  @override
  String get g_bldShipyard => 'Estaleiro';

  @override
  String g_bldShipyardEffect(int n) {
    return 'Ataque +$n%';
  }

  @override
  String get g_bldPark => 'Parque de diversões';

  @override
  String g_bldParkEffect(int n) {
    return 'Renda offline +$n p.p.';
  }

  @override
  String get g_bldStatue => 'Estátua do capitão';

  @override
  String g_bldStatueEffect(int n) {
    return 'Gemas do presente do planeta +$n';
  }

  @override
  String get g_homePalette0 => 'Jardim verde';

  @override
  String get g_homePalette1 => 'Deserto de areia';

  @override
  String get g_homePalette2 => 'Reino de gelo';

  @override
  String get g_homePalette3 => 'Ilha de lava';

  @override
  String get g_homePalette4 => 'Gás violeta';

  @override
  String get g_homePalette5 => 'Flor de cerejeira';

  @override
  String get g_homePalette6 => 'Aurora';

  @override
  String get g_homePalette7 => 'Ouro';

  @override
  String get g_homeDefaultName => 'Minha estrelinha';

  @override
  String get g_achFirstBloodTitle => 'Primeiro abate';

  @override
  String get g_achFirstBloodDesc => 'Abata 1 pirata';

  @override
  String get g_achHunterTitle => 'Caçador de piratas';

  @override
  String get g_achHunterDesc => 'Abata 100 piratas';

  @override
  String get g_achLegendTitle => 'Capitão lendário';

  @override
  String get g_achLegendDesc => 'Abata 1000 piratas';

  @override
  String get g_achMinerTitle => 'Rei da mineração';

  @override
  String get g_achMinerDesc => 'Colete 1000 de minério';

  @override
  String get g_achMiner2Title => 'Magnata do minério';

  @override
  String get g_achMiner2Desc => 'Colete 10000 de minério';

  @override
  String get g_achColonistTitle => 'Pioneiro';

  @override
  String get g_achColonistDesc => 'Colonize 5 planetas';

  @override
  String get g_achMetropolisTitle => 'Metrópole';

  @override
  String get g_achMetropolisDesc => 'Leve uma colônia ao Lv.5';

  @override
  String get g_achBuilderTitle => 'Construtor';

  @override
  String get g_achBuilderDesc => 'Construa 3 estações';

  @override
  String get g_achBoss1Title => 'Caça ao chefe';

  @override
  String get g_achBoss1Desc => 'Derrote um chefe pirata';

  @override
  String get g_achBoss10Title => 'Matador de chefes';

  @override
  String get g_achBoss10Desc => 'Derrote chefes piratas 10 vezes';

  @override
  String get g_achExplorerTitle => 'Explorador';

  @override
  String get g_achExplorerDesc => 'Chegue ao sistema 3';

  @override
  String get g_achVoyagerTitle => 'Viajante';

  @override
  String get g_achVoyagerDesc => 'Chegue ao sistema 6';

  @override
  String get g_achRichTitle => 'Capitão rico';

  @override
  String get g_achRichDesc => 'Tenha 10000 créditos';

  @override
  String get g_achCrew6Title => 'Equipe de confiança';

  @override
  String get g_achCrew6Desc => 'Recrute 6 tripulantes';

  @override
  String get g_achCrew3starTitle => 'Parceiro lendário';

  @override
  String get g_achCrew3starDesc => 'Recrute um tripulante ★3';

  @override
  String get g_achMissionsTitle => 'Resolve-tudo';

  @override
  String get g_achMissionsDesc => 'Complete 20 missões';

  @override
  String get g_achJellyTitle => 'Especialista em águas-vivas';

  @override
  String get g_achJellyDesc => 'Derrote 10 águas-vivas espaciais';

  @override
  String get g_achFashionTitle => 'Fashionista';

  @override
  String get g_achFashionDesc => 'Compre um cosmético';

  @override
  String get g_achAscendTitle => 'Novo começo';

  @override
  String get g_achAscendDesc => 'Ascenda com a Honra Galáctica';

  @override
  String get g_achDroneTitle => 'Drone fiel';

  @override
  String get g_achDroneDesc => 'Equipe um drone de combate';

  @override
  String get g_achHome5Title => 'Arquiteto planetário';

  @override
  String get g_achHome5Desc => '5 prédios no meu planeta';

  @override
  String get g_achHomeMaxTitle => 'Planeta dos sonhos';

  @override
  String get g_achHomeMaxDesc => 'Nível máximo no meu planeta';

  @override
  String get g_dailyKill => 'Abata 30 piratas';

  @override
  String get g_dailyOre => 'Colete 300 de minério';

  @override
  String get g_dailyMission => 'Complete 2 missões';

  @override
  String get g_dailyColony => 'Faça colônias crescerem 2 vezes';

  @override
  String get g_dailyBoss => 'Derrote um chefe pirata';

  @override
  String get g_dailyPower => 'Pegue 3 power-ups';

  @override
  String get g_dailyPlay => 'Jogue por 10 minutos';

  @override
  String get g_dailyJelly => 'Derrote 3 águas-vivas espaciais';

  @override
  String g_missionKill(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n piratas',
      one: '1 pirata',
    );
    return 'Elimine $_temp0';
  }

  @override
  String g_missionMine(int n) {
    return 'Colete $n de minério';
  }

  @override
  String g_missionDeliver(String planet) {
    return 'Entregue carga em $planet';
  }

  @override
  String g_missionBounty(String name) {
    return 'Procura-se: $name';
  }

  @override
  String get g_bounty0 => 'Jack Caolho';

  @override
  String get g_bounty1 => 'Molly Relâmpago';

  @override
  String get g_bounty2 => 'Bark, Rei da Sucata';

  @override
  String get g_bounty3 => 'Toto Barba-Ruiva';

  @override
  String get g_bounty4 => 'Lena Sombra';

  @override
  String get g_bounty5 => 'Pork, o Gorducho';

  @override
  String get g_bounty6 => 'Gigi Duas Lâminas';

  @override
  String get g_bounty7 => 'Bud Martelo Louco';

  @override
  String get g_bounty8 => 'Lucy Raposa Galáctica';

  @override
  String get g_bounty9 => 'Capitão Caveira Bones';

  @override
  String get g_storyAsteroidsTitle => 'Destrua 3 asteroides';

  @override
  String get g_storyAsteroidsLine0 =>
      'Precisamos de minério para a base em Marte. Destrua três asteroides primeiro.';

  @override
  String get g_storyAsteroidsLine1 =>
      'Mova-se com o joystick e atire com o botão de disparo!';

  @override
  String get g_storyKillsTitle => 'Derrotar 3 naves atacantes';

  @override
  String get g_storyKillsLine0 =>
      'Naves desconhecidas ameaçam os postos de retransmissão. Siga as setas vermelhas e detenha três atacantes.';

  @override
  String get g_storyKillsLine1 =>
      'Vamos abrir caminho. Outros virão depois de nós!';

  @override
  String get g_storyColoniesTitle => 'Colonize Marte';

  @override
  String get g_storyColoniesLine0 =>
      'Vamos criar um lugar para voltar em Marte. Aproxime-se e toque em Colonizar.';

  @override
  String get g_storyColoniesLine1 =>
      'Os créditos dos moradores vão ajudar a preparar a próxima viagem.';

  @override
  String get g_storyShipLevelsTitle => 'Melhore sua nave numa estação';

  @override
  String get g_storyShipLevelsLine0 =>
      'Melhore a nave para proteger a rede Haven. Volte à base e equipe-a.';

  @override
  String get g_storyCrewTitle => 'Recrute 1 tripulante';

  @override
  String get g_storyCrewLine0 =>
      'Precisamos de companhia para a viagem. Recrute alguém na aba Tripulação da estação.';

  @override
  String get g_storyMissionsTitle => 'Complete 1 missão';

  @override
  String get g_storyMissionsLine0 =>
      'As pessoas da rota precisam de ajuda. Aceite um serviço no quadro de missões da estação.';

  @override
  String get g_storyStationsTitle => 'Construa uma nova estação';

  @override
  String get g_storyStationsLine0 =>
      'Vamos criar outra parada para as naves de suprimentos. Construa uma estação longe dos planetas.';

  @override
  String get g_storyDevPercentTitle => 'Estabilização do sistema 100%';

  @override
  String get g_storyDevPercentLine0 =>
      'Atinja uma soma dos níveis dos Âncoras de Fase igual a planetas × 3 para conectar os suprimentos e abrir o portal. Consulte o botão Sistema.';

  @override
  String get g_storySectorTitle => 'Salte para o próximo sistema';

  @override
  String get g_storySectorLine0 =>
      'Há outro ponto da fenda no próximo sistema. Vá ao portal roxo no minimapa.';

  @override
  String get g_storySectorLine1 =>
      'Amplie a rede de Âncoras de Fase para proteger a Terra.';

  @override
  String g_storyDevNTitle(int n) {
    return 'Estabilização do sistema $n 100%';
  }

  @override
  String get g_storyDevNLine =>
      'Amplie a rede aqui. A soma dos níveis dos Âncoras de Fase deve chegar a planetas × 3 para abrir o próximo portal.';

  @override
  String g_systemN(int n) {
    return 'Sistema $n';
  }

  @override
  String g_storyWarpNTitle(String system) {
    return 'Salte para o $system';
  }

  @override
  String get g_storyWarpNLine =>
      'A rota está aberta. Vamos instalar Âncoras de Fase no próximo sistema.';

  @override
  String get g_powerUpRapid => 'Tiro rápido';

  @override
  String get g_powerUpShield => 'Escudo';

  @override
  String get g_powerUpMagnet => 'Ímã';

  @override
  String get g_powerUpDoubleCredits => 'Créditos 2x';

  @override
  String get g_planetKindGarden => 'Planeta jardim';

  @override
  String get g_planetKindDesert => 'Planeta desértico';

  @override
  String get g_planetKindIce => 'Planeta gelado';

  @override
  String get g_planetKindLava => 'Planeta de lava';

  @override
  String get g_planetKindGas => 'Planeta gasoso';

  @override
  String get g_colonyBldTurret => 'Torreta';

  @override
  String get g_colonyBldMine => 'Plataforma de mineração';

  @override
  String get g_colonyBldTrade => 'Posto comercial';

  @override
  String get g_colonyBldDock => 'Doca de reparo';

  @override
  String get g_colonyBldShieldGen => 'Gerador de escudo';

  @override
  String get g_colonyBldStabilizer => 'Âncora de Fase';

  @override
  String get g_colonyBldBlurbTurret =>
      'Atira sozinha nos piratas perto da colônia. Essencial contra ataques!';

  @override
  String get g_colonyBldBlurbMine =>
      'Extrai minério e envia 💎 a cada segundo.';

  @override
  String get g_colonyBldBlurbTrade =>
      'Aumenta a renda de créditos desta colônia em 25% por nível.';

  @override
  String get g_colonyBldBlurbDock =>
      'Repara sua nave enquanto você estiver por perto.';

  @override
  String get g_colonyBldBlurbShieldGen =>
      'Aumenta a capacidade do escudo e a velocidade de recarga.';

  @override
  String get g_colonyBldBlurbStabilizer =>
      'Estabilização · escudo compartilhado\n+10% de renda da colônia por nível';

  @override
  String g_stabilizerDamaged(String planet, int level) {
    return 'A Âncora de Fase de $planet sofreu danos e caiu para o nível $level.';
  }

  @override
  String get g_stationRoleHome => 'Base principal';

  @override
  String get g_stationRoleDefense => 'Base de defesa';

  @override
  String get g_stationRoleRepair => 'Base de reparo';

  @override
  String get g_stationRoleSupport => 'Base de suprimentos';

  @override
  String get g_stationRoleBlurbHome => 'Bateria laser e zona segura';

  @override
  String get g_stationRoleBlurbDefense =>
      'Torreta forte · casco 2x · bloqueia tiros inimigos próximos';

  @override
  String get g_stationRoleBlurbRepair =>
      'Reparo rápido e amplo · relançar custa 10% · recarga de escudo 2x nas colônias próximas';

  @override
  String get g_stationRoleBlurbSupport =>
      'Produção das colônias próximas +25% (+5% por nível de habitat)';

  @override
  String g_eventRaid(String planet) {
    return 'Ataque a $planet';
  }

  @override
  String get g_eventMeteor => 'Chuva de meteoros';

  @override
  String get g_eventMerchant => 'Mercador Errante';

  @override
  String get g_eventSupply => 'Cápsula de suprimentos';

  @override
  String get g_productGems100Title => 'Punhado de gemas';

  @override
  String get g_productGems550Title => 'Bolsa de gemas';

  @override
  String get g_productGems1200Title => 'Baú de gemas';

  @override
  String get g_productStarterTitle => 'Pacote Inicial';

  @override
  String get g_productPassTitle => 'Passe de Comandante da Frota';

  @override
  String get g_productGems550Desc => '⭐550 (+10% de bônus)';

  @override
  String get g_productGems1200Desc => '⭐1200 (+20% de bônus)';

  @override
  String get g_productStarterDesc =>
      '⭐300 + skin exclusiva \"Galáxia\" + tripulante ★3 (só uma vez)';

  @override
  String get g_productPassDesc =>
      'Renda de créditos +25%, 8h de renda offline, recompensas sem anúncios, skin exclusiva \"Ouro Real\"';

  @override
  String g_testPurchaseTitle(String product) {
    return '[Compra de teste] $product';
  }

  @override
  String g_testPurchaseBody(String desc, String price) {
    return 'Nenhum pagamento real será feito.\n$desc\nPreço: $price';
  }

  @override
  String get g_testAdTitle => '[Anúncio de teste]';

  @override
  String get g_testAdBody => 'Considerar o anúncio como assistido até o fim?';

  @override
  String get g_webDemoTitle => 'Demo web';

  @override
  String get g_webDemoBody =>
      'Compras e recompensas de anúncios estão disponíveis no app para celular.';

  @override
  String get g_notifChannelName => 'Lembretes de retorno';

  @override
  String get g_notifChannelDesc =>
      'Lembretes de renda das colônias e de recompensa diária';

  @override
  String get g_notifStorageTitle => 'O armazém da sua colônia está cheio!';

  @override
  String get g_notifStorageBody =>
      'Capitão, venha coletar seus créditos antes que a renda pare!';

  @override
  String get g_notifPiratesTitle => 'Os piratas estão aprontando de novo!';

  @override
  String get g_notifPiratesBody =>
      'A recompensa de login de hoje e as missões diárias estão esperando.';

  @override
  String get g_upgradeWeapon => 'Arma';

  @override
  String get g_upgradeHull => 'Blindagem';

  @override
  String get g_upgradeEngine => 'Motor';

  @override
  String get g_upgradeMissile => 'Míssil teleguiado';

  @override
  String get g_upgradeShield => 'Escudo de energia';

  @override
  String get g_upgradeDrone => 'Drone de combate';

  @override
  String get g_upgradeMagnet => 'Ímã';

  @override
  String g_unknownSector(int n) {
    return 'Sistema desconhecido $n';
  }

  @override
  String get g_stationHaven => 'Base Haven';

  @override
  String g_stationOutpost(String sector) {
    return 'Posto Avançado de $sector';
  }

  @override
  String g_stationNumbered(String role, int n) {
    return '$role #$n';
  }

  @override
  String get g_dlgWelcome =>
      'Bem-vindo, Capitão. Sou a cientista espacial Mina.';

  @override
  String get g_dlgMissionsCancelled =>
      'As missões de entrega e de recompensa do sistema anterior foram canceladas.';

  @override
  String get g_floatDisabled => 'Desativada!';

  @override
  String get g_floatRebooted => 'Online de novo!';

  @override
  String get g_dlgBaseRebooted =>
      'A base principal voltou a funcionar! Casco restaurado a 30%.';

  @override
  String get g_dlgUpWeapon => 'Armas melhoradas! Preparem-se, piratas!';

  @override
  String get g_dlgUpHull => 'Blindagem melhorada! Agora me sinto mais seguro.';

  @override
  String get g_dlgUpEngine => 'Motor melhorado! Mais rápido!';

  @override
  String get g_dlgMissileNew => 'Mísseis teleguiados equipados! (Q)';

  @override
  String get g_dlgMissileUp => 'Mísseis melhorados!';

  @override
  String get g_dlgShieldNew => 'Escudo de energia equipado! (F)';

  @override
  String get g_dlgShieldUp => 'Escudo melhorado!';

  @override
  String get g_dlgDroneNew =>
      'Drone de combate lançado! Um novo amigo de confiança.';

  @override
  String get g_dlgDroneUp => 'Drone melhorado!';

  @override
  String get g_dlgUpMagnet =>
      'Ímã melhorado! Os créditos vêm sozinhos até mim!';

  @override
  String get g_dlgNotOver => 'Ainda não acabou!';

  @override
  String get g_floatBlocked => 'Bloqueado!';

  @override
  String get g_floatGuard => 'Protegido!';

  @override
  String get g_pirateBossLose => 'Argh! Este sistema… é seu…';

  @override
  String get g_pirateBossFlee => 'Argh! Vou me lembrar disso, Capitão!';

  @override
  String get g_dlgSupplyCollected => 'Cápsula de suprimentos recuperada!';

  @override
  String get g_merchantBye => 'Até a próxima~ miau!';

  @override
  String get g_pirateRaidTaunt => 'Destruam primeiro as âncoras de fase.';

  @override
  String get g_dlgMeteor =>
      'Chuva de meteoros à vista! Cheia de cristais. Grande chance de minério!';

  @override
  String get g_merchantHello =>
      'O Mercador Errante Nyang-nyang chegou~ Tenho muita coisa boa, miau!';

  @override
  String get g_dlgSupplySignal =>
      'Sinal de uma cápsula de suprimentos com gemas! Tem piratas vigiando, então cuidado.';

  @override
  String get g_dlgCruiseOn =>
      'Primeiro treino concluído! Liguei o [Cruzeiro] acima do joystick: você continua voando para onde aponta mesmo soltando. Toque de novo para desligar.';

  @override
  String get g_dlgBossWarning =>
      'Alerta! A nave do chefe do sistema está se aproximando!';

  @override
  String get g_pirateRevenge => 'Voltei para me vingar! Prepare-se!';

  @override
  String get g_floatShieldBroken => 'Quebrado!';

  @override
  String get g_floatShieldBack => 'Reativado';

  @override
  String get g_floatGoalDone => 'Objetivo concluído!';

  @override
  String g_dlgArrived(String sector) {
    return 'Chegamos a $sector!';
  }

  @override
  String get g_dlgNewFrontier => 'Uma fronteira totalmente nova.';

  @override
  String g_dlgBaseUpgraded(String station, int level) {
    return '$station melhorada para Lv.$level! Os lasers estão mais fortes.';
  }

  @override
  String g_dlgBaseDisabled(int sec) {
    return 'Base principal desativada! Sem proteção por ${sec}s!';
  }

  @override
  String g_dlgSettled(String planet) {
    return 'Bandeira fincada em $planet! Colonizado!';
  }

  @override
  String g_dlgStationBuilt(String station, String blurb) {
    return '$station construída! $blurb';
  }

  @override
  String g_dlgHabitatUp(String station, int level) {
    return 'Habitat de $station Lv.$level!';
  }

  @override
  String g_dlgTurretUp(String station, int level) {
    return 'Torreta de $station Lv.$level!';
  }

  @override
  String g_dlgShipSwitched(String ship) {
    return 'Troquei para a $ship! Que sensação boa!';
  }

  @override
  String g_dlgOreSold(int n, int credits) {
    return 'Vendeu $n de minério por 💰$credits.';
  }

  @override
  String g_dlgCrewJoined(String stars, String role, String name) {
    return '$stars $role $name entrou na tripulação!';
  }

  @override
  String g_dlgCrewLevel(String name, int level) {
    return '$name Lv.$level! Está mandando bem.';
  }

  @override
  String g_dlgCargoLoaded(String mission) {
    return 'Carga a bordo! $mission';
  }

  @override
  String g_dlgBountyTaunt(String name) {
    return 'Acha que consegue pegar $name? Venha tentar!';
  }

  @override
  String get g_floatMissionDone => 'Missão concluída!';

  @override
  String g_dlgMissionDone(String mission) {
    return 'Missão concluída: $mission!';
  }

  @override
  String g_dlgRepairCost(int credits) {
    return 'Você está a salvo, Capitão! O reparo custou 💰$credits.';
  }

  @override
  String g_dlgSectorDeveloped(String sector) {
    return '$sector totalmente desenvolvido! O portal de salto para o próximo sistema está aberto.';
  }

  @override
  String g_floatCrit(int dmg) {
    return 'Crítico! $dmg';
  }

  @override
  String g_dlgStationDestroyed(String station) {
    return '$station foi destruída! Precisamos de torretas!';
  }

  @override
  String g_dlgBossDefeated(int credits) {
    return 'Chefe do sistema derrotado! Recompensa 💰$credits';
  }

  @override
  String g_dlgBountyCaught(String name) {
    return 'Pirata procurado $name capturado!';
  }

  @override
  String g_dlgRaidDefended(String planet, int credits) {
    return '$planet defendido! Os moradores, agradecidos, enviaram 💰$credits ⭐2.';
  }

  @override
  String g_dlgRaidLooted(String planet, String level) {
    return '$planet foi saqueado e caiu para $level… 😢';
  }

  @override
  String g_dlgRaidLeft(String planet) {
    return 'Os piratas saquearam $planet e foram embora.';
  }

  @override
  String g_dlgRaidAlert(String planet) {
    return 'Emergência! Piratas estão atacando $planet! A produção parou!';
  }

  @override
  String g_dlgInvasionWarning(int sec) {
    return 'Alerta de invasão! Uma frota pirata chega em ${sec}s. Defenda a base!';
  }

  @override
  String g_dlgInvasionWon(int credits) {
    return 'Detivemos a invasão! Recompensa 💰$credits ⭐5';
  }

  @override
  String g_dlgInvasionRetreat(int pct, int credits) {
    return 'A frota invasora recuou. $pct% abatidos · recompensa 💰$credits';
  }

  @override
  String get g_invasionCommander => 'Comandante invasor';

  @override
  String g_pirateBossArrive(String sector) {
    return 'Cortem a rede de retransmissão de $sector.';
  }

  @override
  String g_dlgWelcomeBack(String goal) {
    return 'Bem-vindo de volta, Capitão! Objetivo atual: $goal';
  }

  @override
  String get g_pirateWin0 => 'Hahaha! Nem foi tão difícil!';

  @override
  String get g_pirateWin1 => 'Volte mais forte da próxima vez, pirralho!';

  @override
  String get g_pirateWin2 => 'Sua nave virou sucata!';

  @override
  String get g_pirateRage0 => 'Saiam, rapazes! Deem uma lição neles!';

  @override
  String get g_pirateRage1 => 'Agora é pra valer!';

  @override
  String get g_pirateRage2 => 'Agora você me deixou bravo?!';

  @override
  String get g_captainKill0 => 'Menos um!';

  @override
  String get g_captainKill1 => 'Aonde pensa que vai?!';

  @override
  String get g_captainKill2 => 'Esta área é minha!';

  @override
  String get g_captainKill3 => 'Próximo!';

  @override
  String get g_pirateAmbush0 =>
      'Nave-alvo confirmada. Continuem a perseguição.';

  @override
  String get g_pirateAmbush1 => 'Interceptem a expedição.';

  @override
  String get g_pirateAmbush2 => 'Mantenham-nos longe dos transmissores.';

  @override
  String get g_pirateAmbush3 => 'Alvo localizado. Iniciem o ataque.';

  @override
  String get cat_sysSol => 'Sistema Solar';

  @override
  String get cat_sysAlphaCen => 'Alfa Centauri';

  @override
  String get cat_sysBarnard => 'Estrela de Barnard';

  @override
  String get cat_sysWolf359 => 'Wolf 359';

  @override
  String get cat_sysLalande => 'Lalande 21185';

  @override
  String get cat_sysSirius => 'Sírius';

  @override
  String get cat_sysEpsEri => 'Epsilon Eridani';

  @override
  String get cat_sysRoss128 => 'Ross 128';

  @override
  String get cat_sysTauCeti => 'Tau Ceti';

  @override
  String get cat_sysTeegarden => 'Estrela de Teegarden';

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
  String get cat_sysOmegaCen => 'Aglomerado Omega Centauri';

  @override
  String get cat_sysSgrA => 'Centro Galáctico (Sgr A*)';

  @override
  String get cat_sysLMC => 'Grande Nuvem de Magalhães';

  @override
  String get cat_sysSMC => 'Pequena Nuvem de Magalhães';

  @override
  String get cat_sysAndromeda => 'Galáxia de Andrômeda';

  @override
  String get cat_sysTriangulum => 'Galáxia do Triângulo';

  @override
  String get cat_pfxProxima => 'Próxima';

  @override
  String get cat_pfxBarnard => 'Barnard';

  @override
  String get cat_pfxSirius => 'Sírius A';

  @override
  String get cat_pfxEpsEri => 'Epsilon Eridani';

  @override
  String get cat_pfxTauCeti => 'Tau Ceti';

  @override
  String get cat_pfxTeegarden => 'Teegarden';

  @override
  String get cat_mars => 'Marte';

  @override
  String get cat_moon => 'Lua';

  @override
  String get cat_venus => 'Vênus';

  @override
  String get cat_mercury => 'Mercúrio';

  @override
  String get cat_ceres => 'Ceres';

  @override
  String get cat_vesta => 'Vesta';

  @override
  String get cat_jupiter => 'Júpiter';

  @override
  String get cat_io => 'Io';

  @override
  String get cat_europa => 'Europa';

  @override
  String get cat_ganymede => 'Ganimedes';

  @override
  String get cat_callisto => 'Calisto';

  @override
  String get cat_saturn => 'Saturno';

  @override
  String get cat_enceladus => 'Encélado';

  @override
  String get cat_titan => 'Titã';

  @override
  String get cat_uranus => 'Urano';

  @override
  String get cat_miranda => 'Miranda';

  @override
  String get cat_titania => 'Titânia';

  @override
  String get cat_neptune => 'Netuno';

  @override
  String get cat_triton => 'Tritão';

  @override
  String get cat_pluto => 'Plutão';

  @override
  String get cat_charon => 'Caronte';

  @override
  String get cat_haumea => 'Haumea';

  @override
  String get cat_makemake => 'Makemake';

  @override
  String get cat_eris => 'Éris';

  @override
  String get cat_sedna => 'Sedna';

  @override
  String get cat_planetNine => 'Planeta Nove';

  @override
  String get u_topUpTitle => 'Recursos insuficientes';

  @override
  String u_topUpBody(String short, int gems) {
    return 'Faltam $short. Usar ⭐$gems para completar e continuar?';
  }

  @override
  String u_topUpNoGems(String short, int gems, int have) {
    return 'Faltam $short. Completar custaria ⭐$gems, mas você tem ⭐$have. Junte mais um pouco!';
  }

  @override
  String get u_topUpOk => 'Completar';

  @override
  String get u_goShop => 'Ir à loja';

  @override
  String get u_exchangeTitle => '💰 Trocar créditos';

  @override
  String u_exchangeBody(int gems, int credits) {
    return 'Trocar ⭐$gems por 💰$credits?';
  }

  @override
  String get m_purchaseFailed =>
      'Não foi possível conectar à loja. Tente novamente mais tarde.';

  @override
  String get m_adWatchToEnd =>
      'Assista ao anúncio até o fim para ganhar a recompensa.';

  @override
  String get u_cruise => 'Cruzeiro';

  @override
  String get u_autoFireOn => 'LIG';

  @override
  String get u_autoFireOff => 'DESL';

  @override
  String u_recruitRoleOdds(int count, String pct) {
    return 'Função (todos os recrutamentos): aleatória entre $count, $pct cada';
  }

  @override
  String m_feedbackSubject(String app) {
    return 'Feedback do $app';
  }

  @override
  String get lb_menu => '🏅 Ranking semanal';

  @override
  String get lb_menuShort => 'Ranking';

  @override
  String get lb_title => '🏅 Ranking semanal';

  @override
  String get lb_join => 'Participar do ranking';

  @override
  String get lb_joinDesc =>
      'Só são enviados um ID anônimo, um apelido criado pelo jogo e sua pontuação da semana. Nada de nomes, chat ou algo que você digite. Você pode desativar quando quiser.';

  @override
  String get lb_yourNick => 'Seu apelido';

  @override
  String lb_reroll(int count) {
    return 'Novo nome ($count)';
  }

  @override
  String lb_weekPoints(String points) {
    return 'Esta semana: $points pts';
  }

  @override
  String lb_rank(int rank, int total) {
    return 'Nº $rank de $total';
  }

  @override
  String lb_rankOnly(int rank) {
    return 'Nº $rank';
  }

  @override
  String get lb_top50 => 'Top 50 da semana';

  @override
  String get lb_empty =>
      'Ainda não há pontuações nesta semana. Seja o primeiro!';

  @override
  String get lb_retry => 'Tentar de novo';

  @override
  String get lb_refresh => 'Atualizar';

  @override
  String get lb_offline =>
      'Sem conexão. Seu jogo continua normal — tente mais tarde.';

  @override
  String get lb_rateLimited =>
      'Tentativas demais. Espere um minuto e tente de novo.';

  @override
  String get lb_rejected => 'Não foi possível enviar esta pontuação.';

  @override
  String get lb_serverError => 'O ranking está ocupado. Tente mais tarde.';

  @override
  String get lb_unavailable => 'O ranking não está disponível.';

  @override
  String get lb_optedOut =>
      'Ative “Participar do ranking” para publicar sua pontuação.';

  @override
  String get lb_howTo =>
      'Nível de colônia +100 · Novo sistema estelar +500 · Pirata +5 · Chefe +200';

  @override
  String get lb_resets =>
      'Toda segunda-feira às 00:00 UTC começa uma nova semana.';

  @override
  String nickFormat(String adj, String animal, String number) {
    return '$animal $adj $number';
  }

  @override
  String get nickGenders =>
      'f,m,f,m,f,m,m,m,f,m,m,m,m,m,m,f,f,m,m,m,m,f,m,f,m,m,m,m,f,f,m,m,f,f,m,f,m,m,m,m';

  @override
  String nickAdj0(String g) {
    return 'Valente';
  }

  @override
  String get nickAnimal0 => 'Lontra';

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
  String get nickAnimal2 => 'Raposa';

  @override
  String nickAdj3(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Esperto',
      'f': 'Esperta',
      'n': 'Esperto',
      'other': 'Esperto',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal3 => 'Coelho';

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
  String get nickAnimal4 => 'Coruja';

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
  String get nickAnimal5 => 'Pinguim';

  @override
  String nickAdj6(String g) {
    return 'Saltitante';
  }

  @override
  String get nickAnimal6 => 'Coala';

  @override
  String nickAdj7(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Sonhador',
      'f': 'Sonhadora',
      'n': 'Sonhador',
      'other': 'Sonhador',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal7 => 'Golfinho';

  @override
  String nickAdj8(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Quentinho',
      'f': 'Quentinha',
      'n': 'Quentinho',
      'other': 'Quentinho',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal8 => 'Tartaruga';

  @override
  String nickAdj9(String g) {
    return 'Veloz';
  }

  @override
  String get nickAnimal9 => 'Ouriço';

  @override
  String nickAdj10(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Fofinho',
      'f': 'Fofinha',
      'n': 'Fofinho',
      'other': 'Fofinho',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal10 => 'Esquilo';

  @override
  String nickAdj11(String g) {
    return 'Amigável';
  }

  @override
  String get nickAnimal11 => 'Gatinho';

  @override
  String nickAdj12(String g) {
    return 'Gentil';
  }

  @override
  String get nickAnimal12 => 'Cachorrinho';

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
  String get nickAnimal13 => 'Patinho';

  @override
  String nickAdj14(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Dourado',
      'f': 'Dourada',
      'n': 'Dourado',
      'other': 'Dourado',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal14 => 'Cordeirinho';

  @override
  String nickAdj15(String g) {
    return 'Feliz';
  }

  @override
  String get nickAnimal15 => 'Foca';

  @override
  String nickAdj16(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Engraçado',
      'f': 'Engraçada',
      'n': 'Engraçado',
      'other': 'Engraçado',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal16 => 'Baleia';

  @override
  String nickAdj17(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Bondoso',
      'f': 'Bondosa',
      'n': 'Bondoso',
      'other': 'Bondoso',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal17 => 'Hamster';

  @override
  String nickAdj18(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Sortudo',
      'f': 'Sortuda',
      'n': 'Sortudo',
      'other': 'Sortudo',
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
  String get nickAnimal19 => 'Guaxinim';

  @override
  String nickAdj20(String g) {
    return 'Forte';
  }

  @override
  String get nickAnimal20 => 'Papagaio';

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
  String get nickAnimal21 => 'Joaninha';

  @override
  String nickAdj22(String g) {
    return 'Doce';
  }

  @override
  String get nickAnimal22 => 'Pardal';

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
  String get nickAnimal23 => 'Corça';

  @override
  String nickAdj24(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Brincalhão',
      'f': 'Brincalhona',
      'n': 'Brincalhão',
      'other': 'Brincalhão',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal24 => 'Pônei';

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
  String get nickAnimal25 => 'Ursinho';

  @override
  String nickAdj26(String g) {
    return 'Brilhante';
  }

  @override
  String get nickAnimal26 => 'Leãozinho';

  @override
  String nickAdj27(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Prateado',
      'f': 'Prateada',
      'n': 'Prateado',
      'other': 'Prateado',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal27 => 'Filhote de tigre';

  @override
  String nickAdj28(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Sonolento',
      'f': 'Sonolenta',
      'n': 'Sonolento',
      'other': 'Sonolento',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal28 => 'Girafa';

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
    return 'Super';
  }

  @override
  String get nickAnimal32 => 'Lhama';

  @override
  String nickAdj33(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Estrelado',
      'f': 'Estrelada',
      'n': 'Estrelado',
      'other': 'Estrelado',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal33 => 'Alpaca';

  @override
  String nickAdj34(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Ensolarado',
      'f': 'Ensolarada',
      'n': 'Ensolarado',
      'other': 'Ensolarado',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal34 => 'Suricato';

  @override
  String nickAdj35(String g) {
    return 'Nobre';
  }

  @override
  String get nickAnimal35 => 'Estrela-do-mar';

  @override
  String nickAdj36(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Pequenino',
      'f': 'Pequenina',
      'n': 'Pequenino',
      'other': 'Pequenino',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal36 => 'Cavalo-marinho';

  @override
  String nickAdj37(String g) {
    String _temp0 = intl.Intl.selectLogic(g, {
      'm': 'Sábio',
      'f': 'Sábia',
      'n': 'Sábio',
      'other': 'Sábio',
    });
    return '$_temp0';
  }

  @override
  String get nickAnimal37 => 'Esquilo-listrado';

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
  String get nickAnimal38 => 'Peixinho-dourado';

  @override
  String nickAdj39(String g) {
    return 'Leal';
  }

  @override
  String get nickAnimal39 => 'Vaga-lume';

  @override
  String get m_adPrivacy => 'Privacidade dos anúncios';

  @override
  String get m_cloudTitle => 'Backup na nuvem';

  @override
  String m_cloudDesc(String service) {
    return 'Faça backup do seu progresso na sua conta $service para continuar jogando depois de trocar de aparelho ou reinstalar. Toque para conectar.';
  }

  @override
  String m_cloudConnectFailed(String service) {
    return 'Não foi possível conectar ao $service. Tente novamente em instantes.';
  }

  @override
  String get m_cloudBackupNow => 'Fazer backup agora';

  @override
  String get m_cloudNever => 'Ainda sem backup';

  @override
  String m_cloudLast(String time) {
    return 'Último backup: $time';
  }

  @override
  String get m_cloudBackedUp => 'Backup feito.';

  @override
  String get m_cloudFailed =>
      'Não foi possível acessar a nuvem. Verifique sua conexão com a internet.';

  @override
  String get m_cloudRestore => 'Restaurar backup';

  @override
  String m_cloudAccount(String account) {
    return 'Conta conectada: $account';
  }

  @override
  String get m_cloudNoBackup => 'Não há backup para restaurar.';

  @override
  String get m_cloudRestoreTitle => 'Restaurar o backup?';

  @override
  String m_cloudRestoreBody(String time) {
    return 'Seu progresso será substituído pelo backup de $time. O progresso neste aparelho será perdido e não poderá ser desfeito. As gemas e compras também passarão a ser as do backup.';
  }

  @override
  String get m_cloudRestoreOk => 'Restaurar';

  @override
  String get m_cloudRestored => 'Restaurado.';

  @override
  String get m_cloudFoundTitle => 'Backup encontrado';

  @override
  String m_cloudFoundBody(String time) {
    return 'Há um backup de $time. Restaurar agora? Você também pode restaurar depois em Configurações.';
  }

  @override
  String get m_cloudLater => 'Depois';

  @override
  String get m_cloudOverwriteTitle => 'Substituir o backup na nuvem?';

  @override
  String m_cloudOverwriteBody(String time) {
    return 'A nuvem tem um backup de outro aparelho ($time). Se você substituí-lo pelo progresso deste aparelho, ele não poderá ser recuperado.';
  }

  @override
  String get m_cloudOverwriteOk => 'Substituir';

  @override
  String get n_title => 'O plano Haven';

  @override
  String get n_signal => 'Visitante de fora';

  @override
  String get n_haven => 'Tempo conquistado';

  @override
  String get n_departure => 'Expedição Haven';

  @override
  String get n_mars => 'Preparar a transmissão';

  @override
  String get n_transmission => 'Primeira transmissão';

  @override
  String get n_gate => 'Além do Sistema Solar';

  @override
  String get n_signalSpeaker => 'cientista espacial Mina';

  @override
  String get n_settler => 'Morador da colônia';

  @override
  String get n_earthReport => 'Relatório da Terra';

  @override
  String get n_open0 =>
      'A detecção de partículas de antimatéria continua aumentando.\nNesse ritmo, uma Terra de antimatéria entrará no sistema solar.';

  @override
  String get n_open1 =>
      'Minha Âncora de Fase passou no primeiro teste com o antigo MOTOR CENTRAL de Haven. Ainda não sabemos quem criou o núcleo, mas ele retardou a Terra de antimatéria.';

  @override
  String get n_open2 =>
      'Vou instalar as âncoras.\nVamos fundar colônias e ligar a rede de transmissão a Haven.';

  @override
  String get n_open3 => 'Haven está ativo. Sigam a expedição.';

  @override
  String get n_enemyCommander => 'Transmissão não identificada';

  @override
  String get n_mars0 =>
      'O assentamento está pronto, capitão. Já podemos enviar energia à Terra?';

  @override
  String get n_mars1 =>
      'Ainda não. Primeiro precisamos construir um Âncora de Fase e conectá-lo a Haven.';

  @override
  String get n_mars2 =>
      'Invasores desconhecidos atacam a Âncora de Fase. Proteja os equipamentos e escudos.';

  @override
  String get n_transmission0 =>
      'Âncora de Fase ativada. Haven confirma o recebimento da primeira transmissão.\n\nA energia que reunimos chegou à Terra.';

  @override
  String get n_transmission1 =>
      'Uma escola fechada pelo racionamento de energia reabriu. As crianças voltaram às aulas.\n\nContinue transmitindo. Proteja os equipamentos e escudos e amplie a rede.';

  @override
  String get n_warp0 =>
      'A rede solar está estável, mas a energia da Terra e do Sistema Solar não basta. Precisamos de outros sistemas para retardar mais a Terra de antimatéria.';

  @override
  String get n_warp1 =>
      'Mantenha esta rede transmitindo e construa colônias e âncoras em outros sistemas. Rumo a Alfa Centauri, capitão.';

  @override
  String get n_next => 'Próximo';

  @override
  String get n_skip => 'Pular cena';

  @override
  String get n_launch => 'Partir';

  @override
  String get g_antimatterEarth => 'Terra de antimatéria';

  @override
  String get u_antimatterHint =>
      'Ainda está além das órbitas planetárias. Mais Âncoras de Fase vão retardar sua aproximação.';

  @override
  String get c_endingTitle => 'A Terra está segura';

  @override
  String get c_endingBody =>
      'A Terra de antimatéria foi afastada. Todas as colônias ajudaram a proteger a Terra, e a colonização continua.';

  @override
  String get c_finalTitle => 'Operação final';

  @override
  String get c_stabilize => 'Levar a rede local de âncoras a 100%';

  @override
  String get c_syncReady => 'Ir ao retransmissor de Haven e sincronizar';

  @override
  String c_syncProgress(int percent) {
    return 'Sincronização $percent%';
  }

  @override
  String get c_guardian => 'Derrotar o guardião do núcleo';

  @override
  String get c_counterattack =>
      'Voltar ao retransmissor e inverter a transmissão';

  @override
  String get c_complete => 'Missão concluída';

  @override
  String get c_syncButton => 'Sincronizar nave';

  @override
  String get c_fireButton => 'Inverter transmissão';

  @override
  String get c_guardianName => 'Guardião do núcleo';

  @override
  String c_title(String sector) {
    String _temp0 = intl.Intl.selectLogic(sector, {
      '1': 'Retransmissor de Alfa Centauri',
      '5': 'Ataque em Sirius',
      '8': 'Diferença em Tau Ceti',
      '12': 'Canal oculto',
      '16': 'Ordens recuperadas',
      '20': 'O núcleo implantado',
      '22': 'Rastro além da galáxia',
      '25': 'Controle manual de fase',
      '26': 'Triângulo: M33 X-7',
      'other': 'Expandir a rede',
    });
    return '$_temp0';
  }

  @override
  String c_body(String sector) {
    String _temp0 = intl.Intl.selectLogic(sector, {
      '1':
          'A primeira transmissão extrassolar chegou a Haven. As âncoras de outros sistemas podem ajudar na defesa da Terra.',
      '5':
          'A rede ampliada reforça a defesa da Terra. Invasores desconhecidos atacam os retransmissores de propósito.',
      '8':
          'Haven recebe um pouco menos energia do que Tau Ceti envia. Mantenha a defesa enquanto investigamos.',
      '12':
          'A análise dos registros de transmissão acumulados revela um canal de saída não documentado no núcleo de Haven. As Âncoras de Fase funcionam normalmente.',
      '16':
          'Interceptamos registros de ordens inimigas durante a viagem. Os invasores são da Ruptura e obedecem a mestres alienígenas.',
      '20':
          'Registros alienígenas de Kepler-90 mostram o mesmo projeto de núcleo. O antigo artefato encontrado na Terra foi colocado lá de propósito.',
      '22':
          'A comparação dos registros de Kepler-90 com o rastro de energia revela uma rota para fora da galáxia. Alienígenas enviaram a Terra de antimatéria para nos forçar a reunir energia; o núcleo rouba parte da defesa necessária.',
      '25':
          'Encontrei um jeito de isolar o controle automático alienígena. Usaremos sua nave como ponto de controle direto de Haven.',
      '26':
          'Esta é a região de origem dos alienígenas, Triângulo M33 X-7. Conclua a rede local de âncoras, sincronize sua nave no retransmissor de Haven, derrote o guardião do núcleo e volte ao retransmissor para inverter a transmissão.',
      'other':
          'Construa colônias e mantenha as Âncoras de Fase transmitindo. A Terra ainda precisa dessa energia.',
    });
    return '$_temp0';
  }

  @override
  String c_task(String task) {
    String _temp0 = intl.Intl.selectLogic(task, {
      'anchor': 'Construir ou reparar uma âncora',
      's1_0': 'Testar a transmissão da âncora',
      's5': 'Derrotar os invasores',
      's5_0': 'Verificar a transmissão restaurada',
      's8_0': 'Medir a potência da âncora',
      's8_1': 'Comparar registros em Haven',
      's12_0': 'Examinar o circuito oculto do núcleo',
      's16': 'Derrotar a nave de comando',
      's16_0': 'Recuperar ordens nos destroços',
      's20_0': 'Investigar o núcleo nas ruínas',
      's22_0': 'Observar a fuga de energia',
      's22_1': 'Comparar arquivos alienígenas em Haven',
      's25_0': 'Isolar o controle automático em Haven',
      'other': 'Expandir a rede',
    });
    return '$_temp0';
  }

  @override
  String get c_operate => 'Iniciar operação';

  @override
  String get c_finishOperation => 'Concluir a operação regional';

  @override
  String get c_reverseResult =>
      'A nave e Haven seguem sincronizados. A energia das colônias é transmitida ao contrário, afastando a Terra de antimatéria.';

  @override
  String get c_severanceName => 'Severance';

  @override
  String get u_sharedShield => 'Escudo compartilhado';

  @override
  String get u_supportOffline => 'Suporte de Haven inativo';

  @override
  String u_systemTrait(String trait) {
    String _temp0 = intl.Intl.selectLogic(trait, {
      'pirateNest':
          'Ninho pirata · Intervalo de surgimento ×0.7, recompensas por abates ×1.5',
      'richVeins': 'Veios ricos · Minério colonial ×2, minério extraído ×1.5',
      'solarFlare':
          'Erupção estelar · Créditos coloniais ×1.25, regeneração de escudos ×0.5',
      'ionNebula':
          'Nebulosa iônica · Recarga de habilidades ×0.7, dano de torres coloniais/estações ×0.7',
      'gravityWell':
          'Poço gravitacional · Velocidade máxima ×0.85, recompensas de combate/missões ×1.3',
      'tradeLane':
          'Rota comercial · Preço de venda do minério ×1.3, frequência de ataques coloniais ×1.3',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String g_traitIntro(String trait) {
    String _temp0 = intl.Intl.selectLogic(trait, {
      'pirateNest':
          'Um ninho pirata! Os piratas chegam mais vezes, mas os abates rendem mais. Prepare a caça!',
      'richVeins':
          'Veios ricos! Colônias produzem o dobro de minério e asteroides rendem 1,5 vez mais. Vamos minerar!',
      'solarFlare':
          'Fortes erupções! Mais créditos coloniais, mas escudos se regeneram pela metade. Reforce a defesa!',
      'ionNebula':
          'Uma nebulosa iônica! Recarga de habilidades e dano de torres de colônias e estações: ×0.7. Dê apoio com suas habilidades!',
      'gravityWell':
          'Um poço gravitacional! Velocidade máxima ×0.85, recompensas de combate e missões ×1.3. Escolha uma missão!',
      'tradeLane':
          'Uma rota comercial! Preço do minério e frequência de ataques coloniais: ×1.3. Negocie de olho nos alertas!',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get u_specTitle => 'Especialização';

  @override
  String u_specName(String spec) {
    String _temp0 = intl.Intl.selectLogic(spec, {
      'industry': 'Indústria',
      'mining': 'Mineração',
      'fortress': 'Fortaleza',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String u_specEffect(String spec) {
    String _temp0 = intl.Intl.selectLogic(spec, {
      'industry': 'Produção de créditos ×1.5',
      'mining': 'Produção de minério ×2.5',
      'fortress':
          'Escudo ×2 · dano das torretas ×1.5 · não perde nível em ataques',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String u_specLocked(int level) {
    return 'Especialização liberada no Nv.$level';
  }

  @override
  String u_specInactive(int level) {
    return 'Ativa só a partir do Nv.$level';
  }

  @override
  String get u_specFree => 'Grátis';

  @override
  String get u_specChoose => 'Especializar';

  @override
  String get u_specSwitch => 'Trocar';

  @override
  String g_dlgSpecUnlocked(String planet) {
    return '$planet chegou ao Nv.5! Agora você pode escolher uma especialização: Indústria para créditos, Mineração para minério e Fortaleza para defesa. A primeira escolha é grátis!';
  }

  @override
  String g_dlgRaidFortress(String planet) {
    return 'A fortaleza de $planet resistiu ao ataque. O nível continua o mesmo!';
  }

  @override
  String u_bossName(String archetype) {
    String _temp0 = intl.Intl.selectLogic(archetype, {
      'fleet': '☠ Almirante pirata',
      'devourer': '☠ Devorador de veios',
      'flare': '☠ Canhoneira de erupção',
      'wraith': '☠ Espectro iônico',
      'gravity': '☠ Senhor gravitacional',
      'plunder': '☠ Cargueiro saqueador',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String g_dlgBossArchetype(String archetype) {
    String _temp0 = intl.Intl.selectLogic(archetype, {
      'fleet':
          'Alerta! O Almirante pirata chama escoltas saqueadoras sem parar. Ataque o chefe antes que se acumulem!',
      'devourer':
          'Alerta! O Devorador de veios espalha minas ao redor. Destrua-as enquanto luta!',
      'flare':
          'Alerta! A Canhoneira de erupção: quando as linhas de mira aparecem, vem um laser triplo. Desvie para o lado!',
      'wraith':
          'Alerta! O Espectro iônico some a cada 4 segundos. Ataque enquanto estiver visível!',
      'gravity':
          'Alerta! O Senhor gravitacional puxa você quando se aproxima. Use o impulso para escapar!',
      'plunder':
          'Alerta! O Cargueiro saqueador é rápido e rouba créditos a cada acerto. Derrube-o para recuperar tudo!',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get codex_title => 'Códice';

  @override
  String codex_tab(String tab) {
    String _temp0 = intl.Intl.selectLogic(tab, {
      'enemies': 'Inimigos',
      'planets': 'Planetas',
      'systems': 'Sistemas',
      'crew': 'Tripulação',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String codex_progress(int found, int total, int pct) {
    return '$found/$total descobertos · $pct%';
  }

  @override
  String codex_enemy(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'scout': 'Batedor',
      'raider': 'Saqueador',
      'bomber': 'Bombardeiro',
      'sniper': 'Atirador',
      'jelly': 'Água-viva espacial',
      'boss': 'Chefe pirata',
      'commander': 'Comandante invasor',
      'missile': 'Lança-mísseis',
      'mine': 'Lançador de minas',
      'laser': 'Nave laser',
      'warden': 'Guardião',
      'phantom': 'Fantasma',
      'medic': 'Nave de reparo',
      'carrier': 'Porta-drones',
      'juggernaut': 'Colosso',
      'arch_fleet': 'Almirante pirata',
      'arch_devourer': 'Devorador de veios',
      'arch_flare': 'Canhoneira de erupção',
      'arch_wraith': 'Espectro iônico',
      'arch_gravity': 'Senhor gravitacional',
      'arch_plunder': 'Cargueiro saqueador',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String codex_kills(int n) {
    return 'Derrotados: $n';
  }

  @override
  String codex_fromSystem(int n) {
    return 'A partir do sistema $n';
  }

  @override
  String codex_planetKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'garden': 'Mundo-jardim',
      'desert': 'Mundo desértico',
      'ice': 'Mundo gelado',
      'lava': 'Mundo de lava',
      'gas': 'Gigante gasoso',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get codex_planetHint => 'Colonize um planeta deste tipo';

  @override
  String codex_settled(int n) {
    return 'Planetas colonizados: $n';
  }

  @override
  String get codex_settledNone => 'Ainda não há planetas colonizados';

  @override
  String get codex_home => 'Sistema natal · sem condições especiais';

  @override
  String get codex_unreached => 'Chegue por um portal de dobra';

  @override
  String get codex_crewHint => 'Recrute para desbloquear';

  @override
  String get codex_rewards => 'Recompensas de coleção';

  @override
  String codex_rewardCrew(String stars) {
    return 'Tripulante $stars';
  }

  @override
  String get codex_outfitName => 'Explorador estelar';

  @override
  String codex_newEntry(String name) {
    return 'Nova entrada no códice: $name';
  }

  @override
  String get codex_claimedLater => 'As recompensas chegam ao começar a jogar';

  @override
  String codex_pendingCrew(int n) {
    return 'Tripulação cheia: $n aguardando vaga';
  }

  @override
  String r3_goalSettle(String planet) {
    return 'Colonizar $planet';
  }

  @override
  String r3_goalSettleNeed(String planet, int n) {
    return 'Faltam 💰$n para $planet';
  }

  @override
  String r3_goalColonyUp(String planet, int level) {
    return 'Colônia $planet ao Nv.$level';
  }

  @override
  String r3_goalBuild(String planet, String building) {
    return '$planet: construir $building';
  }

  @override
  String get r3_goalAssignCrew => 'Designar tripulação na estação';

  @override
  String get r3_goalWarp => 'Dobra para o próximo sistema';

  @override
  String r3_goalDevelop(String sector) {
    return 'Estabilizar $sector';
  }

  @override
  String get r3_goalMiniBoss => 'Derrote o tenente pirata';

  @override
  String get r3_miniBossName => 'Tenente pirata';

  @override
  String get r3_miniBossArrive => 'O tenente chegou! Novato, sua nave é minha!';

  @override
  String get r3_miniBossHint =>
      'É o tenente pirata! Sua nave atual dá conta. Atire sem parar e recue se o casco ficar fraco!';

  @override
  String get r3_miniBossLose => 'N-não pode ser… Vou contar pro chefe!';

  @override
  String get r3_miniBossDown =>
      'Pegou o tenente! Usei as peças dele para melhorar sua arma de graça!';

  @override
  String r3_weaponUp(int level) {
    return 'Arma Nv.$level!';
  }

  @override
  String r3_star3Line(String name) {
    return 'Belo voo! A base mandou um veterano ★3. Diga oi para $name!';
  }

  @override
  String get r3_crewAssigned => 'Designado automaticamente — bônus ativo';

  @override
  String get rift_title => 'Corrida da Fenda';

  @override
  String get rift_menuSub => 'Fenda do dia · 3–5 min';

  @override
  String rift_locked(String step) {
    return 'Desbloqueia após “$step”';
  }

  @override
  String get rift_rules =>
      'Sobreviva a 10 ondas e derrote o chefe da Fenda na onda 10. Após cada onda, escolha uma carta para ficar mais forte. As melhorias do jogo principal não valem: todos pilotam a mesma nave na mesma Fenda do dia.';

  @override
  String rift_bestLine(String score, int wave) {
    return 'Recorde $score pts · Onda $wave';
  }

  @override
  String get rift_noBest => 'Ainda sem recorde';

  @override
  String rift_fullLeft(int n) {
    return 'Recompensa total: restam $n partidas hoje';
  }

  @override
  String get rift_fullUsed => 'Recompensas totais de hoje usadas (agora 1/4)';

  @override
  String get rift_start => 'Decolar';

  @override
  String rift_wave(int n, int total) {
    return 'Onda $n/$total';
  }

  @override
  String rift_score(String score) {
    return 'Pontos $score';
  }

  @override
  String rift_incoming(int n, int s) {
    return 'Onda $n em $s s';
  }

  @override
  String rift_bossIncoming(int s) {
    return 'Chefe da Fenda em $s s';
  }

  @override
  String rift_enemiesLeft(int n) {
    return 'Restam $n inimigos';
  }

  @override
  String get rift_collapse => 'A Fenda está ruindo!';

  @override
  String rift_pickTitle(int n) {
    return 'Onda $n vencida! Escolha uma carta';
  }

  @override
  String rift_cardLevel(int lv, int max) {
    return 'Nv. $lv/$max';
  }

  @override
  String get rift_rarityCommon => 'Comum';

  @override
  String get rift_rarityRare => 'Rara';

  @override
  String get rift_rarityEpic => 'Épica';

  @override
  String get rift_cardDamage => 'Poder de fogo';

  @override
  String get rift_cardDamageDesc => 'Dano dos tiros +25%';

  @override
  String get rift_cardRapid => 'Tiro rápido';

  @override
  String get rift_cardRapidDesc => 'Intervalo de tiro −15%';

  @override
  String get rift_cardMultishot => 'Tiro múltiplo';

  @override
  String get rift_cardMultishotDesc => 'Uma bala a mais por disparo';

  @override
  String get rift_cardPierce => 'Balas perfurantes';

  @override
  String get rift_cardPierceDesc => 'As balas atravessam mais 1 inimigo';

  @override
  String get rift_cardHoming => 'Mísseis teleguiados';

  @override
  String get rift_cardHomingDesc =>
      'Dispara mísseis teleguiados a cada poucos segundos';

  @override
  String get rift_cardRegen => 'Regeneração de escudo';

  @override
  String get rift_cardRegenDesc => 'Recupera 2 PV por segundo';

  @override
  String get rift_cardDrone => 'Drone de combate';

  @override
  String get rift_cardDroneDesc =>
      'Um drone atira em inimigos próximos. Mais forte ao acumular';

  @override
  String get rift_cardMagnet => 'Ímã';

  @override
  String get rift_cardMagnetDesc => 'Puxa fragmentos da Fenda de mais longe';

  @override
  String get rift_cardCrit => 'Acertos críticos';

  @override
  String get rift_cardCritDesc => '12% de chance de causar 2,5× dano';

  @override
  String get rift_cardBlades => 'Lâminas giratórias';

  @override
  String get rift_cardBladesDesc => '+1 lâmina orbitando sua nave';

  @override
  String get rift_cardHull => 'Casco reforçado';

  @override
  String get rift_cardHullDesc => 'PV máx. +35 e reparo total';

  @override
  String get rift_cardEngine => 'Propulsores';

  @override
  String get rift_cardEngineDesc => 'Velocidade +12%';

  @override
  String get rift_cardShockwave => 'Onda de choque';

  @override
  String get rift_cardShockwaveDesc =>
      'Causa dano periódico a todos os inimigos próximos';

  @override
  String get rift_cardGuard => 'Barreira';

  @override
  String get rift_cardGuardDesc => 'Bloqueia um golpe a cada poucos segundos';

  @override
  String get rift_cardVampire => 'Absorção';

  @override
  String get rift_cardVampireDesc => 'Recupera 3 PV por inimigo destruído';

  @override
  String get rift_resultWin => 'Fenda conquistada!';

  @override
  String get rift_resultLose => 'Abatido na Fenda';

  @override
  String get rift_resultGaveUp => 'Retirada da Fenda';

  @override
  String rift_reached(int n) {
    return 'Onda $n alcançada';
  }

  @override
  String get rift_newBest => 'Novo recorde!';

  @override
  String get rift_rewardTitle => 'Recompensas para o jogo principal';

  @override
  String get rift_rewardReduced =>
      'A partir da 4ª partida de hoje, as recompensas são 1/4';

  @override
  String get rift_noSave =>
      'Sem jogo salvo: créditos e minério não foram adicionados';

  @override
  String get rift_again => 'Tentar de novo';

  @override
  String get rift_exit => 'Sair';

  @override
  String get rift_giveUp => 'Desistir e sair';

  @override
  String get rift_giveUpNote =>
      'Sair encerra a partida. Você mantém pontos e recompensas até a onda alcançada.';

  @override
  String get rift_tabPioneer => 'Pontos de pioneiro';

  @override
  String get rift_tabRift => 'Fenda';

  @override
  String get rift_boardHow =>
      'Classificação pela sua melhor pontuação da semana. Todos encaram a mesma Fenda do dia com a mesma nave.';

  @override
  String rift_myWeek(String score, int wave) {
    return 'Melhor da semana: $score pts · Onda $wave';
  }

  @override
  String get rift_noWeekRun => 'Nenhuma corrida nesta semana ainda';

  @override
  String rift_waveShort(int n) {
    return 'O$n';
  }

  @override
  String get r4_calendarTitle => 'Calendário de 7 dias';

  @override
  String r4_calendarStreak(int n) {
    return '$n dias seguidos';
  }

  @override
  String get r4_calendarHint =>
      'Faltou um dia, volta ao dia 1. O dia 7 dá uma skin de nave exclusiva!';

  @override
  String get r4_calendarToday => 'Hoje';

  @override
  String get r4_calendarClaim => 'Pegar a recompensa';

  @override
  String get r4_calendarClaimed => 'Recompensa de hoje recebida!';

  @override
  String get r4_rewardOre => 'Caixa de minério';

  @override
  String get r4_rewardCredits => 'Pacote de créditos';

  @override
  String get r4_rewardCrew2 => 'Tripulante ★2';

  @override
  String get r4_rewardCrew3 => 'Tripulante ★3';

  @override
  String get r4_rewardSkin => 'Skin exclusiva';

  @override
  String r4_tomorrow(String reward) {
    return 'Amanhã: $reward';
  }

  @override
  String get r4_skinName => 'Luz estelar assídua';

  @override
  String get r4_attendanceOnly => 'Prêmio de 7 dias';

  @override
  String get r4_notifCalendarTitle => 'Sua recompensa está esperando';

  @override
  String r4_notifCalendarBody(String reward) {
    return 'Hoje: $reward';
  }

  @override
  String get r4_notifExpeditionTitle => 'A expedição voltou!';

  @override
  String get r4_notifExpeditionBody =>
      'Sua tripulação trouxe recompensas. Pegue numa estação.';

  @override
  String get r4_expTitle => 'Expedições';

  @override
  String r4_expSlots(int n, int max) {
    return '$n/$max equipes';
  }

  @override
  String get r4_expHint =>
      'Envie tripulantes sem posto. O tempo corre mesmo com o app fechado.';

  @override
  String get r4_expPassSlot => 'Passe de comandante: +1 equipe';

  @override
  String get r4_expNoIdle => 'Ninguém livre. Tire alguém do posto ou recrute.';

  @override
  String r4_expHours(int h) {
    return '$h h';
  }

  @override
  String get r4_expLuck => 'Sorte ⭐/★3';

  @override
  String r4_expLeft(String time) {
    return 'faltam $time';
  }

  @override
  String get r4_expClaim => 'Voltou! Pegar';

  @override
  String get r4_expAway => 'Em expedição';

  @override
  String r4_expGot(String rewards) {
    return 'Saque: $rewards';
  }

  @override
  String r4_timeHm(int h, int m) {
    return '$h h $m min';
  }

  @override
  String r4_timeM(int m) {
    return '$m min';
  }

  @override
  String r4_ascendExpWarn(int n) {
    return '$n tripulantes em expedição também vão embora, sem saque.';
  }

  @override
  String srf_dlgUnlock(String planet) {
    return 'Podemos pousar em $planet! Toque em \"Pousar e explorar\" perto do planeta para procurar ruínas e veios com o veículo.';
  }

  @override
  String get srf_dlgOxygen =>
      'Restam 30 segundos de oxigênio! As criaturas estão vindo. Siga a seta até o módulo!';

  @override
  String srf_site(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'ruin': 'Ruínas',
      'wreck': 'Destroços',
      'nest': 'Ninho alienígena',
      'vein': 'Veio raro',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String srf_floatSite(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'ruin': 'Escavado!',
      'wreck': 'Carga recuperada!',
      'nest': 'Ninho destruído!',
      'vein': 'Veio achado!',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get srf_floatRelic => 'Relíquia encontrada!';

  @override
  String srf_relicName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'starMap': 'Mapa estelar antigo',
      'crystalCore': 'Núcleo de cristal',
      'idol': 'Ídolo alienígena',
      'gear': 'Engrenagem antiga',
      'seed': 'Semente fóssil',
      'mask': 'Máscara ritual',
      'tablet': 'Tábua de pedra',
      'compass': 'Bússola gravitacional',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String srf_relicDesc(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'starMap': 'Uma placa gravada com constelações que já não existem.',
      'crystalCore': 'Pulsa de leve quando você o segura.',
      'idol': 'Ninguém sabe quem ele representa.',
      'gear': 'Ainda gira, bem devagar.',
      'seed': 'Talvez brote se você a regar.',
      'mask': 'Uma máscara ritual com três buracos para os olhos.',
      'tablet': 'Cheia de uma escrita que nem a Mina consegue ler.',
      'compass': 'A agulha sempre aponta para o centro da galáxia.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get srf_codexTab => 'Relíquias';

  @override
  String get srf_relicHint => 'Escave em ruínas de planetas';

  @override
  String get srf_land => 'Pousar e explorar';

  @override
  String get srf_gasNoLand => 'Gigante gasoso — sem pouso';

  @override
  String srf_introTitle(String planet) {
    return 'Superfície de $planet';
  }

  @override
  String srf_disc(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'vein': 'Veio achado',
      'nest': 'Ninho destruído',
      'surveyed': 'Exploração completa',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String srf_discEffect(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'vein': 'Minério +0,4/s × nível',
      'nest': 'Escudo máx. ×1,25',
      'surveyed': 'Créditos ×1,1',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get srf_noDisc => 'Nenhuma descoberta neste planeta ainda';

  @override
  String get srf_discPending => 'Vale depois de colonizar';

  @override
  String srf_fullLeft(int n, int total) {
    return 'Recompensas completas hoje: $n/$total';
  }

  @override
  String get srf_reduced =>
      'As recompensas completas de hoje acabaram. Créditos e minério valem 30% desta vez. Descobertas e relíquias continuam valendo.';

  @override
  String get srf_rule1 => 'Encontre e explore os 5 locais';

  @override
  String get srf_rule2 => 'Volte ao módulo antes de o oxigênio acabar';

  @override
  String get srf_rule3 => 'Destruído ou sem oxigênio: metade do saque';

  @override
  String get srf_launch => 'Pousar';

  @override
  String get srf_oxygen => 'O₂';

  @override
  String srf_sitesLeft(int n) {
    return 'Locais restantes $n';
  }

  @override
  String get srf_return => 'Retornar';

  @override
  String get srf_leaveTitle => 'Parar a exploração?';

  @override
  String get srf_leaveBody =>
      'Um retorno de emergência mantém só metade do saque.';

  @override
  String get srf_leaveYes => 'Retorno de emergência';

  @override
  String srf_resultTitle(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'returned': 'Retorno seguro!',
      'oxygen': 'Retorno de emergência',
      'destroyed': 'Veículo destruído',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String srf_kept(int pct) {
    return '$pct% do saque mantido';
  }

  @override
  String srf_sitesDone(int done, int total) {
    return 'Locais explorados $done/$total';
  }

  @override
  String get srf_newDisc => 'Novas descobertas';

  @override
  String get srf_newRelic => 'Novas relíquias';

  @override
  String get srf_back => 'Voltar à órbita';

  @override
  String get srf_colonyDisc => 'Achados na superfície';
}
