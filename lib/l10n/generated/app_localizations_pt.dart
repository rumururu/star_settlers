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
    return 'Planetas colonizados $colonies / $planets\nEstações: $stations\nBônus do setor: produção x$mul\nOutros setores: 💰$other/s';
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
      'Ascender reinicia este universo (setores, colônias, estações, melhorias da nave, tripulação, créditos)\ne concede honra, um bônus permanente.\nGemas, cosméticos, naves e conquistas são mantidos.';

  @override
  String u_ascendGain(int gain) {
    return 'Ascenda agora e ganhe +$gain de honra!\n(Quanto maior seu império, mais você ganha)';
  }

  @override
  String get u_ascendLocked => 'Chegue ao setor 4 para ascender.';

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
    return '$sector · Des. $dev%\n⚠ Ameaça $threat  🏛 $value';
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
  String get u_merchantE => 'Mercador (E)';

  @override
  String get u_nextSectorE => 'Próx. setor (E)';

  @override
  String get u_prevSectorE => 'Setor ant. (E)';

  @override
  String u_gateLocked(int pct) {
    return '🔒 Abre com 100% de desenvolvimento ($pct%)';
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
  String get u_spkAdvisor => 'Ten. Mina';

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
    return 'Desenvolvimento $pct%';
  }

  @override
  String get u_nextSystemOpen => 'Próximo sistema aberto';

  @override
  String get u_opensAt100 => 'Abre com 100%';

  @override
  String get u_devHint => 'Leve todos os planetas ao Lv.3 para 100%';

  @override
  String get u_conqueredSystems => 'Sistemas conquistados (ainda produzindo)';

  @override
  String get u_unsettled => 'Não colonizado';

  @override
  String get u_underRaid => 'Sob ataque';

  @override
  String u_unknownSector(int n) {
    return 'Setor desconhecido $n';
  }

  @override
  String u_sectorDev(String name, int pct) {
    return '$name · Des. $pct%';
  }

  @override
  String get u_buildStationTitle => 'Construir estação · Escolha uma função';

  @override
  String get u_cost => 'Custo';

  @override
  String get u_build => 'Construir';

  @override
  String get u_toNextSector => '🌀 Para o próximo setor';

  @override
  String get u_bossLocked => '🔒 Derrote o chefe para abrir';

  @override
  String get u_toPrevSector => '🌀 Para o setor anterior';

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
  String get m_privacyTitle => 'Política de Privacidade';

  @override
  String m_privacyBody(String email) {
    return 'Star Settlers armazena os dados do jogo (progresso, configurações) apenas no seu aparelho e não coleta informações de identificação pessoal.\n\nAs compras no app são processadas pelo Google Play / App Store; os dados de pagamento nunca são compartilhados com o desenvolvedor.\n\nSe os anúncios premiados estiverem ativos, o provedor de anúncios (Google AdMob) pode coletar dados como identificadores de publicidade.\n\nContato: $email (Configurações → Enviar feedback ao desenvolvedor)';
  }

  @override
  String get m_wipeTitle => 'Apagar todos os dados';

  @override
  String get m_wipeDesc => 'Exclui todo o progresso, gemas e cosméticos';

  @override
  String get m_wipeConfirmTitle => 'Apagar tudo mesmo?';

  @override
  String get m_wipeConfirmBody =>
      'Não dá para desfazer. As compras podem ser recuperadas com \"Restaurar compras\".';

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
  String get m_testMode => '🧪 Modo de teste: sem pagamentos ou anúncios reais';

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
      '1 tripulante lendário ★4 (bônus de 20%+, título, aura dourada)\nDisponível após iniciar um jogo';

  @override
  String m_legendDesc(int count, int cap) {
    return '1 tripulante lendário ★4 (bônus de 20%+, título, aura dourada)\nTripulação $count/$cap';
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
      'Tiros perfurantes: cada tiro atravessa até 2 inimigos';

  @override
  String get g_shipAuroraAbility =>
      'Autorreparo: recupera 3% de PV/s após 3s sem dano\nGuarda: bloqueia 1 golpe a cada 8s';

  @override
  String g_unlockSector(int n) {
    return 'Chegue ao setor $n';
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
  String get g_achExplorerDesc => 'Chegue ao setor 3';

  @override
  String get g_achVoyagerTitle => 'Viajante';

  @override
  String get g_achVoyagerDesc => 'Chegue ao setor 6';

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
      'Capitão! Primeiro, destrua asteroides para juntar minério.';

  @override
  String get g_storyAsteroidsLine1 =>
      'Mova-se com o joystick e atire com o botão de disparo!';

  @override
  String get g_storyKillsTitle => 'Abata 3 piratas';

  @override
  String get g_storyKillsLine0 => 'Piratas no radar! Siga a seta vermelha.';

  @override
  String get g_storyKillsLine1 => 'Piratas? Viram sucata diante da minha nave!';

  @override
  String get g_storyColoniesTitle => 'Colonize Terra Nova';

  @override
  String get g_storyColoniesLine0 =>
      'Tente colonizar Terra Nova, o planeta verde aqui perto. Chegue perto e o botão Colonizar aparece.';

  @override
  String get g_storyColoniesLine1 =>
      'As colônias rendem créditos até enquanto você descansa!';

  @override
  String get g_storyShipLevelsTitle => 'Melhore sua nave numa estação';

  @override
  String get g_storyShipLevelsLine0 =>
      'Volte para a Base Haven e melhore sua nave. Perto das estações você também é reparado.';

  @override
  String get g_storyCrewTitle => 'Recrute 1 tripulante';

  @override
  String get g_storyCrewLine0 =>
      'Sozinho por aqui? Recrute um parceiro na aba Tripulação do menu da estação!';

  @override
  String get g_storyMissionsTitle => 'Complete 1 missão';

  @override
  String get g_storyMissionsLine0 =>
      'Aceite um trabalho no quadro de missões da estação. A recompensa é ótima!';

  @override
  String get g_storyStationsTitle => 'Construa uma nova estação';

  @override
  String get g_storyStationsLine0 =>
      'Hora de expandir! Construa uma estação no espaço aberto, longe dos planetas.';

  @override
  String get g_storyDevPercentTitle => 'Desenvolvimento do sistema 100%';

  @override
  String get g_storyDevPercentLine0 =>
      'Leve todos os planetas ao Lv.3 para abrir o próximo sistema. Confira o botão Sistema no canto superior direito!';

  @override
  String get g_storySectorTitle => 'Salte para o próximo sistema';

  @override
  String get g_storySectorLine0 =>
      'O portal de salto está aberto! Vá até o portal roxo no minimapa.';

  @override
  String get g_storySectorLine1 => 'Um universo totalmente novo nos espera!';

  @override
  String g_storyDevNTitle(int n) {
    return 'Desenvolvimento do sistema $n 100%';
  }

  @override
  String get g_storyDevNLine =>
      'Leve todos os planetas do novo sistema ao Lv.3!';

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
      'O portal está aberto. Vamos mais fundo no espaço?';

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
  String get g_sector0 => 'Santuário Alfa';

  @override
  String get g_sector1 => 'Nebulosa Beta';

  @override
  String get g_sector2 => 'Cânion Gama';

  @override
  String get g_sector3 => 'Zona Pirata Delta';

  @override
  String get g_sector4 => 'Abismo Épsilon';

  @override
  String get g_sector5 => 'Cinturão de Gelo Zeta';

  @override
  String get g_sector6 => 'Aglomerado Flamejante Eta';

  @override
  String get g_sector7 => 'Rota Fantasma Teta';

  @override
  String get g_sector8 => 'Nebulosa Coroa Iota';

  @override
  String get g_sector9 => 'Buraco Negro Kappa';

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
  String get g_planet6 => 'Estrela Momo';

  @override
  String get g_planet7 => 'Nebula';

  @override
  String get g_planet8 => 'Cassiope';

  @override
  String get g_planet9 => 'Aurora';

  @override
  String get g_planet10 => 'Durian';

  @override
  String get g_planet11 => 'Canela';

  @override
  String get g_planet12 => 'Marshmallow';

  @override
  String get g_planet13 => 'Estrela Pipoca';

  @override
  String get g_planet14 => 'Lavanda';

  @override
  String get g_planet15 => 'Esmeraldia';

  @override
  String get g_planet16 => 'Carmesim';

  @override
  String get g_planet17 => 'Polaris';

  @override
  String get g_planet18 => 'Vega';

  @override
  String get g_planet19 => 'Rigel';

  @override
  String get g_planet20 => 'Mira';

  @override
  String get g_planet21 => 'Topázio';

  @override
  String get g_planet22 => 'Cobalto';

  @override
  String get g_planet23 => 'Safira';

  @override
  String get g_planet24 => 'Ônix';

  @override
  String get g_planet25 => 'Peridoto';

  @override
  String get g_planet26 => 'Estrela Menta';

  @override
  String get g_planet27 => 'Baunilha';

  @override
  String get g_planet28 => 'Caramelo';

  @override
  String get g_planet29 => 'Pistache';

  @override
  String get g_planet30 => 'Mirtilo';

  @override
  String get g_planet31 => 'Estrela Limão';

  @override
  String get g_planet32 => 'Cereja';

  @override
  String get g_planet33 => 'Melão';

  @override
  String get g_planet34 => 'Kiwi';

  @override
  String get g_planet35 => 'Estrela Manga';

  @override
  String get g_planet36 => 'Yuzu';

  @override
  String get g_planet37 => 'Toranja';

  @override
  String get g_planet38 => 'Estrela Abóbora';

  @override
  String get g_planetTerraNova => 'Terra Nova';

  @override
  String g_unknownSector(int n) {
    return 'Setor desconhecido $n';
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
  String get g_dlgWelcome => 'Bem-vindo, Capitão! Eu sou a Mina, sua imediata.';

  @override
  String get g_dlgMissionsCancelled =>
      'As missões de entrega e de recompensa do setor anterior foram canceladas.';

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
  String get g_pirateBossLose => 'Argh! Este setor… é seu…';

  @override
  String get g_pirateBossFlee => 'Argh! Vou me lembrar disso, Capitão!';

  @override
  String get g_dlgSupplyCollected => 'Cápsula de suprimentos recuperada!';

  @override
  String get g_merchantBye => 'Até a próxima~ miau!';

  @override
  String get g_pirateRaidTaunt => 'Esta colônia agora é nossa! Hahaha!';

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
  String get g_dlgBossWarning =>
      'Alerta! A nave do chefe do setor está se aproximando!';

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
    return 'Chefe do setor derrotado! Recompensa 💰$credits';
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
  String g_pirateBossArrive(String sector) {
    return '$sector é meu! Pode vir, capitãozinho!';
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
  String get g_pirateAmbush0 => 'Hahaha! Larga a carga!';

  @override
  String get g_pirateAmbush1 => 'Aqui é território do nosso bando!';

  @override
  String get g_pirateAmbush2 => 'Passa esses créditos brilhantes!';

  @override
  String get g_pirateAmbush3 => 'Dia de azar, pirralho!';
}
