// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class L10nRu extends L10n {
  L10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Star Settlers';

  @override
  String get languageName => 'Русский';

  @override
  String get u_tabShip => 'Корабль';

  @override
  String get u_tabStation => 'Станция';

  @override
  String get u_tabCrew => 'Экипаж';

  @override
  String get u_tabMission => 'Задания';

  @override
  String get u_tabMarket => 'Рынок';

  @override
  String u_upWeapon(int dmg) {
    return 'Урон $dmg · Lv.3 двойной · Lv.6 тройной';
  }

  @override
  String u_upHull(int hp) {
    return 'Макс. ОЗ $hp';
  }

  @override
  String u_upEngine(int speed) {
    return 'Макс. скорость $speed';
  }

  @override
  String get u_upMissileIntro =>
      'Самонаводящиеся ракеты (клавиша Q / кнопка 🚀)';

  @override
  String u_upMissile(int count, String cooldown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ракеты',
      many: '$count ракет',
      few: '$count ракеты',
      one: '$count ракета',
    );
    return '$_temp0 · перезарядка $cooldownс';
  }

  @override
  String get u_upShieldIntro =>
      'Щит, блокирующий весь урон (клавиша F / кнопка 🛡)';

  @override
  String u_upShield(String duration, String cooldown) {
    return '$durationс · перезарядка $cooldownс';
  }

  @override
  String get u_upDroneIntro =>
      'Кружит рядом, сам стреляет и притягивает предметы';

  @override
  String u_upDrone(int dmg, String interval) {
    return 'Урон $dmg · выстрел каждые $intervalс';
  }

  @override
  String u_upMagnet(int range, String power) {
    return 'Притягивает кредиты и руду · радиус $range · сила x$power';
  }

  @override
  String get u_equip => 'Установить';

  @override
  String get u_hangarSection => '🛸 Ангар';

  @override
  String get u_viewLarge => 'Смотреть';

  @override
  String get u_hp => 'ОЗ';

  @override
  String get u_speed => 'Скорость';

  @override
  String get u_attack => 'Атака';

  @override
  String get u_fireRate => 'Скорострельность';

  @override
  String get u_ore => 'Руда';

  @override
  String get u_crit => 'Крит';

  @override
  String get u_boarded => 'На борту';

  @override
  String get u_board => 'Сесть';

  @override
  String get u_boardNow => 'Сесть на борт';

  @override
  String get u_gemsOnly => 'Только за кристаллы';

  @override
  String u_unlockOrGems(String condition) {
    return 'Открытие: $condition или кристаллы';
  }

  @override
  String u_unlock(String condition) {
    return 'Открытие: $condition';
  }

  @override
  String u_durability(int hp, int max) {
    return 'Корпус $hp / $max';
  }

  @override
  String get u_habitat => 'Жилой модуль';

  @override
  String u_habitatDesc(String rate, int hp) {
    return 'Доход 💰$rate/с · Корпус $hp';
  }

  @override
  String get u_turret => 'Оборонная турель';

  @override
  String get u_turretIntro => 'Сама стреляет по пиратам';

  @override
  String u_turretDesc(int dmg, int range) {
    return 'Урон $dmg · Дальность $range';
  }

  @override
  String get u_baseUpgrade => 'Улучшение базы';

  @override
  String u_baseDesc(int dmg, int range, int hp) {
    return 'Лазер $dmg · Дальность $range · Корпус $hp';
  }

  @override
  String u_disabledSec(int sec) {
    return 'Отключено $secс';
  }

  @override
  String u_sectorStatus(String sector) {
    return '$sector: сводка';
  }

  @override
  String u_sectorStats(
    int colonies,
    int planets,
    int stations,
    String mul,
    String other,
  ) {
    return 'Освоено планет $colonies / $planets\nСтанций: $stations\nБонус системы: добыча x$mul\nДругие системы: 💰$other/с';
  }

  @override
  String get u_legendaryGet => '🌟 Легендарный! 🌟';

  @override
  String get u_rareGet => '✨ Редкий член экипажа! ✨';

  @override
  String get u_newCrew => 'Новый член экипажа!';

  @override
  String get u_great => 'Отлично!';

  @override
  String u_crewHeader(int count, int cap, int assigned, int slots) {
    return 'Экипаж $count/$cap · На посту $assigned/$slots';
  }

  @override
  String u_recruit(int cost) {
    return 'Нанять 💰$cost';
  }

  @override
  String u_recruitPremium(int cost) {
    return 'Премиум-найм ⭐$cost';
  }

  @override
  String u_recruitLegendary(int cost) {
    return '🌟 Гарантированный легендарный ⭐$cost';
  }

  @override
  String u_recruitOdds(String normal, String premium) {
    return 'Шансы · Найм: $normal\nПремиум-найм: $premium\nГарантированный легендарный: ★4 100%';
  }

  @override
  String u_slotMax(int n) {
    return 'Посты МАКС ($n)';
  }

  @override
  String u_slotBuy(int price) {
    return 'Пост экипажа +1 ⭐$price';
  }

  @override
  String u_rosterMax(int n) {
    return 'Состав МАКС ($n)';
  }

  @override
  String u_rosterBuy(int size, int price) {
    return 'Состав +$size ⭐$price';
  }

  @override
  String get u_noCrew =>
      'Экипажа пока нет. Наймите кого-нибудь и назначьте на корабль!';

  @override
  String get u_unassign => 'Снять';

  @override
  String get u_assign => 'Назначить';

  @override
  String get u_dismiss => 'Уволить';

  @override
  String get u_dismissCrewTitle => 'Уволить члена экипажа';

  @override
  String u_dismissCrewBody(String name) {
    return 'Отпустить $name? Это нельзя отменить.';
  }

  @override
  String get u_missionDeliverHint => 'Летите к цели (жёлтая стрелка)';

  @override
  String get u_missionBountyHint =>
      'Найдите и уничтожьте цель (жёлтая стрелка)';

  @override
  String u_reward(String rewards) {
    return 'Награда $rewards';
  }

  @override
  String u_activeMissions(int n) {
    return 'Активные ($n/3)';
  }

  @override
  String get u_noActiveMissions => 'Нет активных заданий.';

  @override
  String get u_abandon => 'Отказаться';

  @override
  String u_missionBoard(int sec) {
    return 'Доска заданий · новое через $secс';
  }

  @override
  String get u_accept => 'Принять';

  @override
  String get u_priceHigh => '📈 Дорого! Пора продавать';

  @override
  String get u_priceLow => '📉 Дёшево… лучше подождать';

  @override
  String get u_priceNormal => '➡ Обычно';

  @override
  String get u_orePrice => 'Цена руды';

  @override
  String get u_sell100 => 'Продать 100';

  @override
  String get u_sellHalf => 'Продать половину';

  @override
  String get u_sellAll => 'Продать всё';

  @override
  String get u_marketTip =>
      'Цены со временем растут и падают. Продавайте дорого!';

  @override
  String get u_gemExchange => '⭐ Обмен кристаллов';

  @override
  String get u_creditPack => 'Набор кредитов';

  @override
  String get u_exchange => 'Обменять';

  @override
  String get u_openShop => '⭐ Открыть магазин';

  @override
  String u_achievementDone(String title, int gems) {
    return '🏆 Достижение: $title! Заберите ⭐$gems в Меню > Достижения.';
  }

  @override
  String get u_cannotDo => 'Не хватает ресурсов, или сейчас это невозможно.';

  @override
  String get u_welcomeBack => 'С возвращением, капитан!';

  @override
  String u_offlineHm(int h, int m) {
    return 'Пока вас не было $h ч $m мин,\nколонии усердно трудились!';
  }

  @override
  String u_offlineM(int m) {
    return 'Пока вас не было $m мин,\nколонии усердно трудились!';
  }

  @override
  String get u_passOfflineHint => 'Пропуск командира: до 8 ч + авто x2';

  @override
  String get u_collect => 'Забрать';

  @override
  String get u_adLoading => 'Загружаем рекламу. Попробуйте чуть позже.';

  @override
  String get u_adLoadingRetry =>
      'Загружаем рекламу. Нажмите ещё раз чуть позже.';

  @override
  String get u_collectDouble => 'Забрать x2 👑';

  @override
  String get u_adDouble => '📺 Реклама за x2';

  @override
  String get u_galaxyHonor => '🌌 Галактическая честь';

  @override
  String u_honorStatus(int honor, int ascensions) {
    return 'Честь $honor (возрождений: $ascensions)';
  }

  @override
  String u_honorBonus(int income, int attack) {
    return 'Доход +$income% · Урон +$attack%';
  }

  @override
  String get u_ascendExplain =>
      'Возрождение сбрасывает эту вселенную (системы, колонии, станции, улучшения корабля, экипаж, кредиты)\nи даёт честь — постоянный бонус.\nКристаллы, украшения, корабли и достижения сохраняются.';

  @override
  String u_ascendGain(int gain) {
    return 'Возродитесь сейчас и получите +$gain чести!\n(Чем больше империя, тем больше награда)';
  }

  @override
  String get u_ascendLocked => 'Доберитесь до системы 4, чтобы возродиться.';

  @override
  String get u_close => 'Закрыть';

  @override
  String u_ascendBtn(int gain) {
    return 'Возродиться (+$gain)';
  }

  @override
  String get u_ascendConfirmTitle => 'Точно возродиться?';

  @override
  String get u_ascendConfirmBody =>
      'Текущая вселенная будет сброшена. Это нельзя отменить.';

  @override
  String get u_ascend => 'Возродиться';

  @override
  String u_shieldBroken(String name) {
    return '$name разрушен';
  }

  @override
  String u_hudSector(String sector, int dev, String threat, String value) {
    return '$sector · Разв. $dev%\n⚠ Угроза $threat  🏛 $value';
  }

  @override
  String u_baseDisabled(int sec) {
    return 'База откл. $secс';
  }

  @override
  String u_baseHp(int pct) {
    return 'База $pct%';
  }

  @override
  String get u_merchantE => 'Торговец (E)';

  @override
  String get u_nextSectorE => 'След. система (E)';

  @override
  String get u_prevSectorE => 'Пред. система (E)';

  @override
  String u_gateLocked(int pct) {
    return '🔒 Откроется при 100% развития ($pct%)';
  }

  @override
  String u_settle(String name) {
    return 'Заселить $name';
  }

  @override
  String u_manageE(String name) {
    return 'Управлять $name (E)';
  }

  @override
  String get u_buildStation => 'Построить станцию';

  @override
  String get u_fire => 'ОГОНЬ';

  @override
  String get u_equipAtStation =>
      'Установить можно на вкладке «Корабль» станции!';

  @override
  String get u_shotDown => '💥 Вас сбили!';

  @override
  String u_autoRespawn(int sec) {
    return 'Авто-возврат на базу через $secс';
  }

  @override
  String get u_reviveFree => '👑 Воскреснуть здесь (бесплатно)';

  @override
  String get u_reviveAd => '📺 Реклама — воскреснуть здесь';

  @override
  String get u_reviveGems => 'Воскреснуть здесь за ⭐10';

  @override
  String u_respawnBase(int pct) {
    return '🏠 Вернуться на базу (−$pct% кредитов)';
  }

  @override
  String get u_spkCaptain => 'Капитан';

  @override
  String get u_spkPirate => 'Пират';

  @override
  String get u_spkAdvisor => 'Лейт. Мина';

  @override
  String get u_spkMerchant => 'Торговка Нян';

  @override
  String get u_paused => 'Пауза';

  @override
  String u_pauseStats(
    String sector,
    int kills,
    int crew,
    int colonies,
    int stations,
    int missions,
  ) {
    return '$sector · Сбито $kills · Экипаж $crew\nКолонии $colonies · Станции $stations · Задания $missions';
  }

  @override
  String get u_resume => '▶︎ Продолжить';

  @override
  String get u_shop => '⭐ Магазин';

  @override
  String get u_achievements => '🏆 Достижения';

  @override
  String get u_dailyQuests => '📅 Ежедневные задания';

  @override
  String get u_myPlanet => '🌍 Моя планета';

  @override
  String get u_ascendMenu => '🌌 Галактическая честь (возрождение)';

  @override
  String get u_settings => '⚙ Настройки';

  @override
  String get u_saveAndQuit => '💾 Сохранить и выйти';

  @override
  String get u_keyboardHelp =>
      'Клавиши: WASD движение · Пробел огонь · Q ракета · F щит · Shift ускорение\nE действие · B построить станцию · Esc меню';

  @override
  String get u_recharging => 'Перезарядка';

  @override
  String get u_tutDome => 'Щит\nвнутри безопасно';

  @override
  String get u_tutLevelUp => 'Новый уровень\nдоход·здания↑';

  @override
  String get u_tutTurret => 'Турель';

  @override
  String get u_tutRepair => 'Ремонт';

  @override
  String get u_tutRaid => 'Отбить набеги';

  @override
  String get u_gotIt => 'Понятно';

  @override
  String u_damage(int dmg) {
    return 'Урон $dmg';
  }

  @override
  String u_oreRate(String rate) {
    return 'Руда +$rate/с';
  }

  @override
  String u_incomePct(int pct) {
    return 'Доход +$pct%';
  }

  @override
  String u_repairRate(int hp) {
    return 'ОЗ +$hp/с';
  }

  @override
  String u_shieldPlus(int amount) {
    return 'Щит +$amount';
  }

  @override
  String u_systemTitle(String sector, int n) {
    return '$sector · Система $n';
  }

  @override
  String u_systemInfo(String threat, String mul) {
    return 'Угроза $threat · Ресурсы x$mul';
  }

  @override
  String u_development(int pct) {
    return 'Развитие $pct%';
  }

  @override
  String get u_nextSystemOpen => 'След. система открыта';

  @override
  String get u_opensAt100 => 'Откроется при 100%';

  @override
  String get u_devHint => 'Прокачайте каждую планету до Lv.3 для 100%';

  @override
  String get u_conqueredSystems => 'Захваченные системы (продолжают добычу)';

  @override
  String get u_unsettled => 'Не заселена';

  @override
  String get u_underRaid => 'Под атакой';

  @override
  String u_unknownSector(int n) {
    return 'Неизвестная система $n';
  }

  @override
  String u_sectorDev(String name, int pct) {
    return '$name · Разв. $pct%';
  }

  @override
  String get u_buildStationTitle => 'Строительство станции · Выбор роли';

  @override
  String get u_cost => 'Цена';

  @override
  String get u_build => 'Построить';

  @override
  String get u_toNextSector => '🌀 В следующую систему';

  @override
  String get u_bossLocked => '🔒 Победите босса, чтобы открыть';

  @override
  String get u_toPrevSector => '🌀 В предыдущую систему';

  @override
  String get u_raidAlert => '⚠ Набег!';

  @override
  String u_rechargePct(int pct) {
    return 'Перезарядка $pct%';
  }

  @override
  String u_merchantLabel(int sec) {
    return '🛒 Странствующая торговка ($secс)';
  }

  @override
  String get u_supplyPod => '📦 Капсула снабжения';

  @override
  String u_sectorBoss(String sector) {
    return '☠ Босс: $sector';
  }

  @override
  String get u_pirateBoss => '☠ Главарь пиратов';

  @override
  String get u_merchantName => 'Нян, странствующая торговка';

  @override
  String u_merchantLeaves(int sec, String credits) {
    return 'Улетит через $secс · 💰$credits';
  }

  @override
  String get u_rareCrewOffer => 'Редкий член экипажа';

  @override
  String get u_crewSoldOut => 'Сегодняшнего члена экипажа уже забрали, мяу!';

  @override
  String get u_gemTrade => 'Обмен на кристаллы (макс. 3)';

  @override
  String u_gemTradeRow(int price, int left) {
    return '💰$price → ⭐5  (осталось $left)';
  }

  @override
  String get u_convert => 'Обменять';

  @override
  String get u_potions => 'Зелья усиления (x2 время)';

  @override
  String get u_notEnoughGems => 'Не хватает кристаллов';

  @override
  String get u_buyConfirmTitle => 'Подтвердите покупку';

  @override
  String u_buyShipConfirm(String ship, String price) {
    return 'Потратить $price на $ship?';
  }

  @override
  String u_shipBought(String ship) {
    return '$ship получен! Вы уже на борту.';
  }

  @override
  String get u_premiumShips => 'Премиум-корабли';

  @override
  String get u_hangarTitle => 'Ангар';

  @override
  String u_buyGems(int price) {
    return 'Купить ⭐$price';
  }

  @override
  String get u_premium => 'Премиум';

  @override
  String get u_ok => 'ОК';

  @override
  String get u_cancel => 'Отмена';

  @override
  String get m_ok => 'ОК';

  @override
  String get m_cancel => 'Отмена';

  @override
  String get m_close => 'Закрыть';

  @override
  String get m_claim => 'Забрать';

  @override
  String m_claimGems(int gems) {
    return 'Забрать ⭐$gems';
  }

  @override
  String get m_done => '✅ Готово';

  @override
  String get m_notEnoughGems => 'Не хватает кристаллов';

  @override
  String get m_restorePurchases => 'Восстановить покупки';

  @override
  String get m_restoreDone => 'Покупки проверены';

  @override
  String get m_buyConfirmTitle => 'Подтвердите покупку';

  @override
  String m_spendGemsConfirm(String price) {
    return 'Потратить $price?';
  }

  @override
  String get m_loginTitle => '📅 Ежедневный вход';

  @override
  String get m_loginWelcome => 'С возвращением, капитан!';

  @override
  String get m_loginStreakHint => 'Заходите 7 дней подряд — получите ⭐50!';

  @override
  String get m_newGameTitle => 'Новая игра';

  @override
  String get m_newGameBody =>
      'Текущий прогресс будет удалён.\n(Кристаллы, украшения, достижения и покупки сохранятся.) Продолжить?';

  @override
  String get m_start => 'Начать';

  @override
  String get m_loadFailed => 'Не удалось загрузить сохранение.';

  @override
  String m_honorLine(int honor, int income, int attack) {
    return '🌌 Галактическая честь $honor · Доход +$income% · Атака +$attack%';
  }

  @override
  String get m_continue => 'Продолжить';

  @override
  String get m_newGame => '✨ Новая игра';

  @override
  String get m_menuHome => 'Планета';

  @override
  String get m_menuShop => 'Магазин';

  @override
  String get m_menuQuest => 'Задания';

  @override
  String get m_menuAchievements => 'Трофеи';

  @override
  String get m_menuSettings => 'Настройки';

  @override
  String m_achievementsTitle(int done, int total) {
    return '🏆 Достижения ($done/$total)';
  }

  @override
  String get m_dailyTitle => '📅 Ежедневные задания';

  @override
  String m_dailyReset(int hours, int minutes) {
    return 'Сброс через $hours ч $minutes мин';
  }

  @override
  String get m_dailyBonusTitle => '🎁 Бонус за всё';

  @override
  String get m_dailyBonusDesc => 'Заберите награды за все 3 задания дня';

  @override
  String get m_settingsTitle => '⚙ Настройки';

  @override
  String get m_settingsSound => 'Звуковые эффекты';

  @override
  String get m_settingsMusic => 'Музыка';

  @override
  String get m_settingsNotify => 'Напоминания';

  @override
  String get m_settingsNotifyDesc => 'Сообщим, когда склад колонии заполнится';

  @override
  String get m_settingsHaptics => 'Вибрация';

  @override
  String get m_settingsLanguage => 'Язык';

  @override
  String get m_languageSystem => 'Язык устройства';

  @override
  String get m_privacyTitle => 'Политика конфиденциальности';

  @override
  String m_privacyBody(String email) {
    return 'Star Settlers хранит игровые данные (прогресс, настройки) только на вашем устройстве и не собирает персональные данные.\n\nВнутриигровые покупки обрабатываются Google Play / App Store; платёжные данные никогда не передаются разработчику.\n\nЕсли включена реклама с наградой, рекламный партнёр (Google AdMob) может собирать данные, например рекламные идентификаторы.\n\nКонтакты: $email (Настройки → Отправить отзыв разработчику)';
  }

  @override
  String get m_wipeTitle => 'Сбросить все данные';

  @override
  String get m_wipeDesc => 'Удаляет весь прогресс, кристаллы и украшения';

  @override
  String get m_wipeConfirmTitle => 'Точно сбросить всё?';

  @override
  String get m_wipeConfirmBody =>
      'Это нельзя отменить. Покупки можно вернуть через «Восстановить покупки».';

  @override
  String get m_wipeOk => 'Сбросить';

  @override
  String get m_feedbackTitle => 'Отправить отзыв разработчику';

  @override
  String get m_feedbackDesc =>
      'Баги, идеи — что угодно! Устройство и версия приложения добавятся автоматически.';

  @override
  String m_noMailApp(String email) {
    return 'Почтовое приложение не найдено. Напишите на $email.';
  }

  @override
  String get m_aboutTitle => 'STAR SETTLERS';

  @override
  String m_version(String version) {
    return 'Версия $version';
  }

  @override
  String get m_shopTitle => '⭐ Магазин';

  @override
  String get m_buyThanks => 'Покупка завершена! Спасибо 💜';

  @override
  String get m_adLoading => 'Загружаем рекламу. Попробуйте чуть позже.';

  @override
  String m_buyShipConfirm(String ship, String price) {
    return 'Потратить $price на $ship?';
  }

  @override
  String m_shipAcquired(String ship) {
    return '$ship получен! Вы уже на борту';
  }

  @override
  String get m_tabGems => 'Кристаллы';

  @override
  String get m_tabPacks => 'Наборы';

  @override
  String get m_tabPremiumShips => 'Премиум-корабли';

  @override
  String get m_tabSkins => 'Скины кораблей';

  @override
  String get m_tabOutfits => 'Наряды капитана';

  @override
  String get m_tabFree => 'Бесплатно';

  @override
  String get m_testMode => '🧪 Тестовый режим: без реальных платежей и рекламы';

  @override
  String get m_owned => 'Есть';

  @override
  String get m_boarded => 'В полёте';

  @override
  String get m_gemsInfo =>
      'Кристаллы тратятся на украшения, премиум-найм, мгновенное воскрешение и обмен на кредиты.\nИх также можно получить в игре (достижения, входы, боссы, капсулы снабжения).';

  @override
  String get m_crewSection => '👩‍🚀 Экипаж (кристаллы)';

  @override
  String get m_premiumSection => '🛸 Премиум-корабли';

  @override
  String get m_premiumDesc =>
      'Особые истребители только за кристаллы, у каждого уникальная способность.';

  @override
  String get m_viewLarge => 'Смотреть крупно';

  @override
  String get m_premiumHangarHint =>
      'Корабли также можно купить и сменить в Ангаре (Станция → вкладка «Корабль»).';

  @override
  String get m_legendTitle => 'Гарантированный легендарный найм';

  @override
  String get m_legendDescNoGame =>
      '1 легендарный член экипажа ★4 (бонус от 20% + всё производство +40%, титул, золотая аура)\nДоступно после начала игры';

  @override
  String m_legendDesc(int count, int cap) {
    return '1 легендарный член экипажа ★4 (бонус от 20% + всё производство +40%, титул, золотая аура)\nЭкипаж $count/$cap';
  }

  @override
  String m_crewJoined(String stars, String name) {
    return '$stars $name в команде!';
  }

  @override
  String get m_slotTitle => 'Пост экипажа +1';

  @override
  String m_slotDesc(int slots) {
    return 'Сколько членов экипажа можно назначить одновременно · Сейчас $slots';
  }

  @override
  String m_rosterTitle(int n) {
    return 'Состав экипажа +$n';
  }

  @override
  String m_rosterDesc(int cap, int max) {
    return 'Сколько членов экипажа можно держать · Сейчас $cap (макс. $max)';
  }

  @override
  String m_crewOdds(String odds) {
    return 'Шансы премиум-найма: $odds · Гарантированный легендарный: ★4 100%';
  }

  @override
  String get m_equipped => 'Надето';

  @override
  String get m_equip => 'Надеть';

  @override
  String get m_passOnly => 'Только с пропуском командира';

  @override
  String get m_starterOnly => 'Только в стартовом наборе';

  @override
  String get m_adSection => '📺 Кристаллы за рекламу';

  @override
  String m_adInfo(int perDay, int left) {
    return '$perDay раз в день, по ⭐5 · сегодня осталось $left';
  }

  @override
  String get m_adClaimPremium => 'Забрать ⭐5 (пропуск командира: без рекламы)';

  @override
  String get m_adWatch => 'Реклама за ⭐5';

  @override
  String m_loginStreak(int days) {
    return 'Серия входов: день $days';
  }

  @override
  String m_dayN(int day) {
    return 'День $day';
  }

  @override
  String get m_notEnoughResources => 'Не хватает ресурсов';

  @override
  String m_emptyLot(int n) {
    return 'Пустой участок №$n · Строить';
  }

  @override
  String get m_buildInGameOnly =>
      'Строить можно во время игры (Меню → Моя планета). Кредиты и руда берутся из текущей вселенной.';

  @override
  String m_heldAll(String credits, String ore, int gems) {
    return 'Есть 💰$credits  💎$ore  ⭐$gems';
  }

  @override
  String m_held(String credits, String ore) {
    return 'Есть 💰$credits  💎$ore';
  }

  @override
  String m_currentEffect(String effect) {
    return 'Сейчас: $effect';
  }

  @override
  String m_nextLevel(String effect) {
    return 'След. уровень: $effect';
  }

  @override
  String m_upgrade(String cost) {
    return 'Улучшить $cost';
  }

  @override
  String get m_maxLevel => '🌟 Макс. уровень';

  @override
  String get m_planetName => 'Название планеты';

  @override
  String get m_decorateTitle => '🎨 Украсить планету';

  @override
  String get m_planetRing => 'Кольцо планеты';

  @override
  String get m_giftInGameOnly => 'Подарки можно забрать во время игры';

  @override
  String get m_giftTitle => '🎁 Подарок планеты';

  @override
  String m_giftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Подарок от $count жителя!',
      many: 'Подарок от $count жителей!',
      few: 'Подарок от $count жителей!',
      one: 'Подарок от $count жителя!',
    );
    return '$_temp0';
  }

  @override
  String get m_giftThanks => 'Спасибо!';

  @override
  String m_planetStatus(int level, int residents, int built, int slots) {
    return 'Планета Lv.$level · Жители $residents · Здания $built/$slots';
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
    return 'Постоянный бонус · Доход +$income%  Руда +$ore%  Атака +$attack%  ОЗ +$hp%  Перезарядка -$cooldown%  Офлайн $offline%';
  }

  @override
  String get m_planetHint =>
      'Проведите пальцем, чтобы вращать планету, нажмите на участок, чтобы строить';

  @override
  String get m_giftClaim => '🎁 Забрать подарок';

  @override
  String m_giftWait(int hours, int minutes) {
    return '🎁 Подарок через $hours ч $minutes мин';
  }

  @override
  String m_planetLevelUp(int level, String cost) {
    return '🌍 Планета Lv.$level (+2 участка) $cost';
  }

  @override
  String get g_shipScoutName => 'Скаут';

  @override
  String get g_shipInterceptorName => 'Перехватчик';

  @override
  String get g_shipFortressName => 'Крепость';

  @override
  String get g_shipProspectorName => 'Старатель';

  @override
  String get g_shipPhantomName => 'Фантом';

  @override
  String get g_shipNovaName => 'Нова-Дракон';

  @override
  String get g_shipAuroraName => 'Аврора';

  @override
  String get g_shipScoutDesc => 'Сбалансированный стартовый корабль';

  @override
  String get g_shipInterceptorDesc =>
      'Быстрый и скорострельный, но броня тонкая';

  @override
  String get g_shipFortressDesc => 'Медленный, но крепкий и бьёт мощно';

  @override
  String get g_shipProspectorDesc => 'Руда +50%, притягивает предметы издалека';

  @override
  String get g_shipPhantomDesc => '25% шанс крита x2.5';

  @override
  String get g_shipNovaDesc => 'Премиум-истребитель, снаряды пробивают врагов';

  @override
  String get g_shipAuroraDesc => 'Премиум-страж: чинит себя и носит барьер';

  @override
  String get g_shipNovaAbility =>
      'Пробивные снаряды: каждый пробивает до 2 врагов';

  @override
  String get g_shipAuroraAbility =>
      'Самопочинка: 3% ОЗ/с, если 3с без урона\nЗащита: блокирует 1 удар каждые 8с';

  @override
  String g_crewLegendPerk(int pct) {
    return '👑 Легендарное командование: всё производство (кредиты и руда) +$pct% (не суммируется)';
  }

  @override
  String g_shipCreditBonus(int pct) {
    return '💰 Бонус охотника: +$pct% к кредитам, заработанным лично (награды, астероиды, задания, отражение набегов)';
  }

  @override
  String g_unlockSector(int n) {
    return 'Достигнуть системы $n';
  }

  @override
  String g_unlockBosses(int n) {
    return 'Победить главарей пиратов: $n';
  }

  @override
  String g_unlockOre(int n) {
    return 'Собрать руды: $n';
  }

  @override
  String get g_skinDefault => 'Обычный Скаут';

  @override
  String get g_skinCrimson => 'Красная комета';

  @override
  String get g_skinMint => 'Мятный шоколад';

  @override
  String get g_skinStealth => 'Чёрный стелс';

  @override
  String get g_skinNeon => 'Неоновый розовый';

  @override
  String get g_skinRainbow => 'Радужная мечта';

  @override
  String get g_skinGalaxy => 'Галактика';

  @override
  String get g_skinGold => 'Королевское золото';

  @override
  String get g_outfitDefault => 'Обычный скафандр';

  @override
  String get g_outfitCat => 'Шлем-котик';

  @override
  String get g_outfitBunny => 'Заячьи ушки';

  @override
  String get g_outfitAlien => 'Антенны пришельца';

  @override
  String get g_outfitFlower => 'Заколка-цветок';

  @override
  String get g_outfitHat => 'Капитанская фуражка';

  @override
  String get g_outfitCrown => 'Галактическая корона';

  @override
  String get g_crewRoleGunner => 'Стрелок';

  @override
  String get g_crewEffectGunner => 'Атака';

  @override
  String get g_crewRoleEngineer => 'Инженер';

  @override
  String get g_crewEffectEngineer => 'Макс. ОЗ и ремонт';

  @override
  String get g_crewRolePilot => 'Пилот';

  @override
  String get g_crewEffectPilot => 'Скорость';

  @override
  String get g_crewRoleTrader => 'Торговец';

  @override
  String get g_crewEffectTrader => 'Доход кредитов';

  @override
  String get g_crewRoleMiner => 'Шахтёр';

  @override
  String get g_crewEffectMiner => 'Добыча руды';

  @override
  String get g_crewRoleScientist => 'Учёный';

  @override
  String get g_crewEffectScientist => 'Перезарядка навыков';

  @override
  String get g_crewName0 => 'Булочка';

  @override
  String get g_crewName1 => 'Коко';

  @override
  String get g_crewName2 => 'Звёздочка';

  @override
  String get g_crewName3 => 'Тофу';

  @override
  String get g_crewName4 => 'Бобик';

  @override
  String get g_crewName5 => 'Лулу';

  @override
  String get g_crewName6 => 'Хару';

  @override
  String get g_crewName7 => 'Попо';

  @override
  String get g_crewName8 => 'Мими';

  @override
  String get g_crewName9 => 'Дори';

  @override
  String get g_crewName10 => 'Пушок';

  @override
  String get g_crewName11 => 'Бабочка';

  @override
  String get g_crewName12 => 'Шоко';

  @override
  String get g_crewName13 => 'Зёрнышко';

  @override
  String get g_crewName14 => 'Облачко';

  @override
  String get g_crewName15 => 'Капелька';

  @override
  String get g_crewName16 => 'Тори';

  @override
  String get g_crewName17 => 'Хэппи';

  @override
  String get g_crewName18 => 'Рисинка';

  @override
  String get g_crewName19 => 'Моти';

  @override
  String get g_crewName20 => 'Латте';

  @override
  String get g_crewName21 => 'Печенька';

  @override
  String get g_crewName22 => 'Желейка';

  @override
  String get g_crewName23 => 'Пушинка';

  @override
  String get g_crewName24 => 'Манго';

  @override
  String get g_crewName25 => 'Сливка';

  @override
  String get g_crewName26 => 'Орешек';

  @override
  String get g_crewName27 => 'Уголёк';

  @override
  String get g_crewName28 => 'Бэмби';

  @override
  String get g_crewName29 => 'Сырок';

  @override
  String get g_crewLegend0 => 'Страж галактики';

  @override
  String get g_crewLegend1 => 'Звёздный герой';

  @override
  String get g_crewLegend2 => 'Мудрец туманности';

  @override
  String get g_crewLegend3 => 'Рыцарь кометы';

  @override
  String get g_crewLegend4 => 'Сверхновая';

  @override
  String g_crewLegendName(String title, String name) {
    return '$title $name';
  }

  @override
  String get g_bldHouse => 'Дом';

  @override
  String g_bldHouseEffect(int n) {
    return 'Жители +$n (больше подарков)';
  }

  @override
  String get g_bldFarm => 'Космоферма';

  @override
  String g_bldFarmEffect(int n) {
    return 'Доход кредитов +$n%';
  }

  @override
  String get g_bldMine => 'Шахта';

  @override
  String g_bldMineEffect(int n) {
    return 'Добыча руды +$n%';
  }

  @override
  String get g_bldLab => 'Лаборатория';

  @override
  String g_bldLabEffect(int n) {
    return 'Перезарядка навыков -$n%';
  }

  @override
  String get g_bldTower => 'Оборонная башня';

  @override
  String g_bldTowerEffect(int n) {
    return 'Макс. ОЗ +$n%';
  }

  @override
  String get g_bldShipyard => 'Верфь';

  @override
  String g_bldShipyardEffect(int n) {
    return 'Атака +$n%';
  }

  @override
  String get g_bldPark => 'Парк аттракционов';

  @override
  String g_bldParkEffect(int n) {
    return 'Офлайн-доход +$n п.п.';
  }

  @override
  String get g_bldStatue => 'Статуя капитана';

  @override
  String g_bldStatueEffect(int n) {
    return 'Кристаллы в подарках планеты +$n';
  }

  @override
  String get g_homePalette0 => 'Зелёный сад';

  @override
  String get g_homePalette1 => 'Песчаная пустыня';

  @override
  String get g_homePalette2 => 'Ледяное царство';

  @override
  String get g_homePalette3 => 'Лавовый остров';

  @override
  String get g_homePalette4 => 'Фиолетовый газ';

  @override
  String get g_homePalette5 => 'Цветущая сакура';

  @override
  String get g_homePalette6 => 'Аврора';

  @override
  String get g_homePalette7 => 'Золото';

  @override
  String get g_homeDefaultName => 'Моя звёздочка';

  @override
  String get g_achFirstBloodTitle => 'Первая победа';

  @override
  String get g_achFirstBloodDesc => 'Сбить 1 пирата';

  @override
  String get g_achHunterTitle => 'Охотник на пиратов';

  @override
  String get g_achHunterDesc => 'Сбить 100 пиратов';

  @override
  String get g_achLegendTitle => 'Легендарный капитан';

  @override
  String get g_achLegendDesc => 'Сбить 1000 пиратов';

  @override
  String get g_achMinerTitle => 'Король шахт';

  @override
  String get g_achMinerDesc => 'Собрать 1000 руды';

  @override
  String get g_achMiner2Title => 'Рудный магнат';

  @override
  String get g_achMiner2Desc => 'Собрать 10000 руды';

  @override
  String get g_achColonistTitle => 'Первопроходец';

  @override
  String get g_achColonistDesc => 'Заселить 5 планет';

  @override
  String get g_achMetropolisTitle => 'Мегаполис';

  @override
  String get g_achMetropolisDesc => 'Развить колонию до Lv.5';

  @override
  String get g_achBuilderTitle => 'Строитель';

  @override
  String get g_achBuilderDesc => 'Построить 3 станции';

  @override
  String get g_achBoss1Title => 'Охота на главаря';

  @override
  String get g_achBoss1Desc => 'Победить главаря пиратов';

  @override
  String get g_achBoss10Title => 'Гроза главарей';

  @override
  String get g_achBoss10Desc => 'Победить главарей пиратов 10 раз';

  @override
  String get g_achExplorerTitle => 'Исследователь';

  @override
  String get g_achExplorerDesc => 'Достигнуть системы 3';

  @override
  String get g_achVoyagerTitle => 'Путешественник';

  @override
  String get g_achVoyagerDesc => 'Достигнуть системы 6';

  @override
  String get g_achRichTitle => 'Богатый капитан';

  @override
  String get g_achRichDesc => 'Накопить 10000 кредитов';

  @override
  String get g_achCrew6Title => 'Надёжная команда';

  @override
  String get g_achCrew6Desc => 'Нанять 6 членов экипажа';

  @override
  String get g_achCrew3starTitle => 'Легендарный товарищ';

  @override
  String get g_achCrew3starDesc => 'Нанять члена экипажа ★3';

  @override
  String get g_achMissionsTitle => 'Мастер на все руки';

  @override
  String get g_achMissionsDesc => 'Выполнить 20 заданий';

  @override
  String get g_achJellyTitle => 'Знаток медуз';

  @override
  String get g_achJellyDesc => 'Победить 10 космических медуз';

  @override
  String get g_achFashionTitle => 'Модница';

  @override
  String get g_achFashionDesc => 'Купить украшение';

  @override
  String get g_achAscendTitle => 'Новое начало';

  @override
  String get g_achAscendDesc => 'Возродиться с галактической честью';

  @override
  String get g_achDroneTitle => 'Верный дрон';

  @override
  String get g_achDroneDesc => 'Установить боевой дрон';

  @override
  String get g_achHome5Title => 'Архитектор планеты';

  @override
  String get g_achHome5Desc => '5 зданий на моей планете';

  @override
  String get g_achHomeMaxTitle => 'Планета мечты';

  @override
  String get g_achHomeMaxDesc => 'Макс. уровень моей планеты';

  @override
  String get g_dailyKill => 'Сбить 30 пиратов';

  @override
  String get g_dailyOre => 'Собрать 300 руды';

  @override
  String get g_dailyMission => 'Выполнить 2 задания';

  @override
  String get g_dailyColony => 'Развить колонии 2 раза';

  @override
  String get g_dailyBoss => 'Победить главаря пиратов';

  @override
  String get g_dailyPower => 'Подобрать 3 усиления';

  @override
  String get g_dailyPlay => 'Играть 10 минут';

  @override
  String get g_dailyJelly => 'Победить 3 космических медуз';

  @override
  String g_missionKill(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Сбить $n пирата',
      many: 'Сбить $n пиратов',
      few: 'Сбить $n пиратов',
      one: 'Сбить $n пирата',
    );
    return '$_temp0';
  }

  @override
  String g_missionMine(int n) {
    return 'Собрать руды: $n';
  }

  @override
  String g_missionDeliver(String planet) {
    return 'Доставка груза: $planet';
  }

  @override
  String g_missionBounty(String name) {
    return 'Розыск: $name';
  }

  @override
  String get g_bounty0 => 'Одноглазый Джек';

  @override
  String get g_bounty1 => 'Молния Молли';

  @override
  String get g_bounty2 => 'Барк, король хлама';

  @override
  String get g_bounty3 => 'Тото Рыжая Борода';

  @override
  String get g_bounty4 => 'Тень Лена';

  @override
  String get g_bounty5 => 'Пухлый Порк';

  @override
  String get g_bounty6 => 'Джиджи Два Клинка';

  @override
  String get g_bounty7 => 'Бад Бешеный Молот';

  @override
  String get g_bounty8 => 'Галактическая Лиса Люси';

  @override
  String get g_bounty9 => 'Капитан Череп Бонс';

  @override
  String get g_storyAsteroidsTitle => 'Разбейте 3 астероида';

  @override
  String get g_storyAsteroidsLine0 =>
      'Капитан! Для начала разбейте астероиды и соберите руду.';

  @override
  String get g_storyAsteroidsLine1 =>
      'Двигайтесь джойстиком и стреляйте кнопкой огня!';

  @override
  String get g_storyKillsTitle => 'Сбейте 3 пиратов';

  @override
  String get g_storyKillsLine0 =>
      'Пираты на радаре! Следуйте за красной стрелкой.';

  @override
  String get g_storyKillsLine1 =>
      'Пираты? Перед моим кораблём они просто металлолом!';

  @override
  String get g_storyColoniesTitle => 'Освойте Марс';

  @override
  String get g_storyColoniesLine0 =>
      'Основайте первую колонию на Марсе — красной планете рядом с Землёй. Подлетите ближе, и появится кнопка заселения.';

  @override
  String get g_storyColoniesLine1 =>
      'Колонии приносят кредиты, даже пока вы отдыхаете!';

  @override
  String get g_storyShipLevelsTitle => 'Улучшите корабль на станции';

  @override
  String get g_storyShipLevelsLine0 =>
      'Вернитесь на базу «Приют» и улучшите корабль. Рядом со станциями корабль ещё и чинится.';

  @override
  String get g_storyCrewTitle => 'Наймите 1 члена экипажа';

  @override
  String get g_storyCrewLine0 =>
      'Одному скучно? Наймите товарища во вкладке «Экипаж» в меню станции!';

  @override
  String get g_storyMissionsTitle => 'Выполните 1 задание';

  @override
  String get g_storyMissionsLine0 =>
      'Возьмите заказ на доске заданий станции. Награда приятная.';

  @override
  String get g_storyStationsTitle => 'Постройте новую станцию';

  @override
  String get g_storyStationsLine0 =>
      'Пора расширяться! Постройте станцию в открытом космосе подальше от планет.';

  @override
  String get g_storyDevPercentTitle => 'Развитие системы 100%';

  @override
  String get g_storyDevPercentLine0 =>
      'Прокачайте все планеты до Lv.3, и откроется следующая система. Смотрите кнопку «Система» справа вверху!';

  @override
  String get g_storySectorTitle => 'Варп в следующую систему';

  @override
  String get g_storySectorLine0 =>
      'Варп-врата открыты! Летите к фиолетовым вратам на миникарте.';

  @override
  String get g_storySectorLine1 => 'Впереди целая новая вселенная!';

  @override
  String g_storyDevNTitle(int n) {
    return 'Развитие системы $n: 100%';
  }

  @override
  String get g_storyDevNLine => 'Прокачайте все планеты новой системы до Lv.3!';

  @override
  String g_systemN(int n) {
    return 'Система $n';
  }

  @override
  String g_storyWarpNTitle(String system) {
    return 'Варп: $system';
  }

  @override
  String get g_storyWarpNLine => 'Врата открыты. Отправимся глубже в космос?';

  @override
  String get g_powerUpRapid => 'Скорострел';

  @override
  String get g_powerUpShield => 'Щит';

  @override
  String get g_powerUpMagnet => 'Магнит';

  @override
  String get g_powerUpDoubleCredits => 'Кредиты x2';

  @override
  String get g_planetKindGarden => 'Планета-сад';

  @override
  String get g_planetKindDesert => 'Пустынная планета';

  @override
  String get g_planetKindIce => 'Ледяная планета';

  @override
  String get g_planetKindLava => 'Лавовая планета';

  @override
  String get g_planetKindGas => 'Газовая планета';

  @override
  String get g_colonyBldTurret => 'Турель';

  @override
  String get g_colonyBldMine => 'Буровая';

  @override
  String get g_colonyBldTrade => 'Фактория';

  @override
  String get g_colonyBldDock => 'Ремонтный док';

  @override
  String get g_colonyBldShieldGen => 'Генератор щита';

  @override
  String get g_colonyBldBlurbTurret =>
      'Сама сбивает пиратов возле колонии. Без неё от налётов не отбиться!';

  @override
  String get g_colonyBldBlurbMine =>
      'Добывает руду и каждую секунду присылает 💎.';

  @override
  String get g_colonyBldBlurbTrade =>
      'Повышает доход кредитов колонии на 25% за уровень.';

  @override
  String get g_colonyBldBlurbDock => 'Чинит ваш корабль, пока вы рядом.';

  @override
  String get g_colonyBldBlurbShieldGen =>
      'Увеличивает запас щита и скорость перезарядки.';

  @override
  String get g_stationRoleHome => 'Главная база';

  @override
  String get g_stationRoleDefense => 'Оборонная база';

  @override
  String get g_stationRoleRepair => 'Ремонтная база';

  @override
  String get g_stationRoleSupport => 'База снабжения';

  @override
  String get g_stationRoleBlurbHome => 'Лазерная батарея и безопасная зона';

  @override
  String get g_stationRoleBlurbDefense =>
      'Мощная турель · прочность x2 · блокирует вражеские выстрелы рядом';

  @override
  String get g_stationRoleBlurbRepair =>
      'Быстрый ремонт в большом радиусе · возврат в бой за 10% · щиты колоний рядом x2';

  @override
  String get g_stationRoleBlurbSupport =>
      'Добыча колоний рядом +25% (+5% за уровень жилого модуля)';

  @override
  String g_eventRaid(String planet) {
    return 'Налёт: $planet';
  }

  @override
  String get g_eventMeteor => 'Метеорный дождь';

  @override
  String get g_eventMerchant => 'Странствующая торговка';

  @override
  String get g_eventSupply => 'Капсула снабжения';

  @override
  String get g_productGems100Title => 'Горсть кристаллов';

  @override
  String get g_productGems550Title => 'Мешочек кристаллов';

  @override
  String get g_productGems1200Title => 'Сундук кристаллов';

  @override
  String get g_productStarterTitle => 'Стартовый набор';

  @override
  String get g_productPassTitle => 'Пропуск командира';

  @override
  String get g_productGems550Desc => '⭐550 (+10% бонус)';

  @override
  String get g_productGems1200Desc => '⭐1200 (+20% бонус)';

  @override
  String get g_productStarterDesc =>
      '⭐300 + эксклюзивный скин «Галактика» + экипаж ★3 (только один раз)';

  @override
  String get g_productPassDesc =>
      'Доход кредитов +25%, офлайн-доход 8 ч, награды без рекламы, эксклюзивный скин «Королевское золото»';

  @override
  String g_testPurchaseTitle(String product) {
    return '[Тестовая покупка] $product';
  }

  @override
  String g_testPurchaseBody(String desc, String price) {
    return 'Реальной оплаты не будет.\n$desc\nЦена: $price';
  }

  @override
  String get g_testAdTitle => '[Тестовая реклама]';

  @override
  String get g_testAdBody => 'Засчитать рекламу как просмотренную до конца?';

  @override
  String get g_webDemoTitle => 'Веб-демо';

  @override
  String get g_webDemoBody =>
      'Покупки и награды за рекламу доступны в мобильном приложении.';

  @override
  String get g_notifChannelName => 'Напоминания';

  @override
  String get g_notifChannelDesc => 'Доход колоний и ежедневные награды';

  @override
  String get g_notifStorageTitle => 'Склад колонии заполнен!';

  @override
  String get g_notifStorageBody =>
      'Капитан, заберите кредиты, пока доход не остановился!';

  @override
  String get g_notifPiratesTitle => 'Пираты снова бесчинствуют!';

  @override
  String get g_notifPiratesBody =>
      'Вас ждут награда за вход и ежедневные задания.';

  @override
  String get g_upgradeWeapon => 'Оружие';

  @override
  String get g_upgradeHull => 'Броня';

  @override
  String get g_upgradeEngine => 'Двигатель';

  @override
  String get g_upgradeMissile => 'Самонаводящиеся ракеты';

  @override
  String get g_upgradeShield => 'Энергощит';

  @override
  String get g_upgradeDrone => 'Боевой дрон';

  @override
  String get g_upgradeMagnet => 'Магнит';

  @override
  String g_unknownSector(int n) {
    return 'Неизвестная система $n';
  }

  @override
  String get g_stationHaven => 'База «Приют»';

  @override
  String g_stationOutpost(String sector) {
    return 'Аванпост · $sector';
  }

  @override
  String g_stationNumbered(String role, int n) {
    return '$role №$n';
  }

  @override
  String get g_dlgWelcome => 'Добро пожаловать, капитан! Я Мина, ваш старпом.';

  @override
  String get g_dlgMissionsCancelled =>
      'Задания доставки и розыска из прошлой системы отменены.';

  @override
  String get g_floatDisabled => 'Отключено!';

  @override
  String get g_floatRebooted => 'Снова в строю!';

  @override
  String get g_dlgBaseRebooted =>
      'Главная база снова в строю! Прочность восстановлена до 30%.';

  @override
  String get g_dlgUpWeapon => 'Оружие улучшено! Пираты, держитесь!';

  @override
  String get g_dlgUpHull => 'Броня улучшена! Теперь надёжнее.';

  @override
  String get g_dlgUpEngine => 'Двигатель улучшен! Быстрее!';

  @override
  String get g_dlgMissileNew => 'Самонаводящиеся ракеты установлены! (Q)';

  @override
  String get g_dlgMissileUp => 'Ракеты улучшены!';

  @override
  String get g_dlgShieldNew => 'Энергощит установлен! (F)';

  @override
  String get g_dlgShieldUp => 'Щит улучшен!';

  @override
  String get g_dlgDroneNew => 'Боевой дрон запущен! Новый верный друг.';

  @override
  String get g_dlgDroneUp => 'Дрон улучшен!';

  @override
  String get g_dlgUpMagnet => 'Магнит улучшен! Кредиты сами летят ко мне!';

  @override
  String get g_dlgNotOver => 'Это ещё не конец!';

  @override
  String get g_floatBlocked => 'Блок!';

  @override
  String get g_floatGuard => 'Защита!';

  @override
  String get g_pirateBossLose => 'Аргх! Эта система… твоя…';

  @override
  String get g_pirateBossFlee => 'Аргх! Я это запомню, капитан!';

  @override
  String get g_dlgSupplyCollected => 'Капсула снабжения подобрана!';

  @override
  String get g_merchantBye => 'До новых встреч~ мяу!';

  @override
  String get g_pirateRaidTaunt => 'Теперь эта колония наша! Ха-ха-ха!';

  @override
  String get g_dlgMeteor =>
      'Замечен метеорный дождь! В нём полно руды — отличный шанс!';

  @override
  String get g_merchantHello =>
      'Странствующая торговка Нян тут как тут~ Много хороших товаров, мяу!';

  @override
  String get g_dlgSupplySignal =>
      'Сигнал капсулы снабжения с кристаллами! Её охраняют пираты, будьте осторожны.';

  @override
  String get g_dlgBossWarning =>
      'Внимание! Приближается корабль босса системы!';

  @override
  String get g_pirateRevenge => 'Я вернулся отомстить! Готовься!';

  @override
  String get g_floatShieldBroken => 'Пробит!';

  @override
  String get g_floatShieldBack => 'Восстановлен';

  @override
  String get g_floatGoalDone => 'Цель выполнена!';

  @override
  String g_dlgArrived(String sector) {
    return 'Прибыли: $sector!';
  }

  @override
  String get g_dlgNewFrontier => 'Совершенно новые рубежи.';

  @override
  String g_dlgBaseUpgraded(String station, int level) {
    return '$station: Lv.$level! Лазеры стали мощнее.';
  }

  @override
  String g_dlgBaseDisabled(int sec) {
    return 'Главная база отключена! Защиты нет $secс!';
  }

  @override
  String g_dlgSettled(String planet) {
    return '$planet: флаг установлен! Колония основана!';
  }

  @override
  String g_dlgStationBuilt(String station, String blurb) {
    return '$station построена! $blurb';
  }

  @override
  String g_dlgHabitatUp(String station, int level) {
    return '$station: жилой модуль Lv.$level!';
  }

  @override
  String g_dlgTurretUp(String station, int level) {
    return '$station: турель Lv.$level!';
  }

  @override
  String g_dlgShipSwitched(String ship) {
    return 'Новый корабль — $ship! Отличные ощущения!';
  }

  @override
  String g_dlgOreSold(int n, int credits) {
    return 'Продано руды: $n за 💰$credits.';
  }

  @override
  String g_dlgCrewJoined(String stars, String role, String name) {
    return '$stars $role $name теперь в экипаже!';
  }

  @override
  String g_dlgCrewLevel(String name, int level) {
    return '$name: Lv.$level! Всё лучше и лучше.';
  }

  @override
  String g_dlgCargoLoaded(String mission) {
    return 'Груз на борту! $mission';
  }

  @override
  String g_dlgBountyTaunt(String name) {
    return 'Поймать меня? Меня, $name? Ну попробуй!';
  }

  @override
  String get g_floatMissionDone => 'Задание выполнено!';

  @override
  String g_dlgMissionDone(String mission) {
    return 'Задание выполнено: $mission!';
  }

  @override
  String g_dlgRepairCost(int credits) {
    return 'Вы целы, капитан! Ремонт стоил 💰$credits.';
  }

  @override
  String g_dlgSectorDeveloped(String sector) {
    return '$sector: развитие завершено! Варп-врата в следующую систему открыты.';
  }

  @override
  String g_floatCrit(int dmg) {
    return 'Крит! $dmg';
  }

  @override
  String g_dlgStationDestroyed(String station) {
    return '$station: станция уничтожена! Нужны турели!';
  }

  @override
  String g_dlgBossDefeated(int credits) {
    return 'Босс системы побеждён! Награда 💰$credits';
  }

  @override
  String g_dlgBountyCaught(String name) {
    return 'Разыскиваемый пират пойман: $name!';
  }

  @override
  String g_dlgRaidDefended(String planet, int credits) {
    return '$planet: оборона удалась! Благодарные жители прислали 💰$credits ⭐2.';
  }

  @override
  String g_dlgRaidLooted(String planet, String level) {
    return '$planet: колония разграблена, уровень упал до $level… 😢';
  }

  @override
  String g_dlgRaidLeft(String planet) {
    return '$planet: пираты всё разграбили и ушли.';
  }

  @override
  String g_dlgRaidAlert(String planet) {
    return 'Тревога! Пираты атакуют колонию: $planet! Добыча остановлена!';
  }

  @override
  String g_pirateBossArrive(String sector) {
    return '$sector — мои владения! Ну давай, капитан-малявка!';
  }

  @override
  String g_dlgWelcomeBack(String goal) {
    return 'С возвращением, капитан! Текущая цель: $goal';
  }

  @override
  String get g_pirateWin0 => 'Ха-ха-ха! Слабовато!';

  @override
  String get g_pirateWin1 => 'Приходи, когда подрастёшь, малыш!';

  @override
  String get g_pirateWin2 => 'Твой корабль теперь металлолом!';

  @override
  String get g_pirateRage0 => 'Ребята, на выход! Проучим их!';

  @override
  String get g_pirateRage1 => 'А теперь всё по-настоящему!';

  @override
  String get g_pirateRage2 => 'Ну всё, я в ярости!';

  @override
  String get g_captainKill0 => 'Минус один!';

  @override
  String get g_captainKill1 => 'Куда собрался?!';

  @override
  String get g_captainKill2 => 'Это моя территория!';

  @override
  String get g_captainKill3 => 'Следующий!';

  @override
  String get g_pirateAmbush0 => 'Ха-ха-ха! Груз на бочку!';

  @override
  String get g_pirateAmbush1 => 'Это территория нашей банды!';

  @override
  String get g_pirateAmbush2 => 'Гони блестящие кредиты!';

  @override
  String get g_pirateAmbush3 => 'Не твой сегодня день, малыш!';

  @override
  String get cat_sysSol => 'Солнечная система';

  @override
  String get cat_sysAlphaCen => 'Альфа Центавра';

  @override
  String get cat_sysBarnard => 'Звезда Барнарда';

  @override
  String get cat_sysWolf359 => 'Вольф 359';

  @override
  String get cat_sysLalande => 'Лаланд 21185';

  @override
  String get cat_sysSirius => 'Сириус';

  @override
  String get cat_sysEpsEri => 'Эпсилон Эридана';

  @override
  String get cat_sysRoss128 => 'Росс 128';

  @override
  String get cat_sysTauCeti => 'Тау Кита';

  @override
  String get cat_sysTeegarden => 'Звезда Тигардена';

  @override
  String get cat_sysGliese581 => 'Глизе 581';

  @override
  String get cat_sysGliese667C => 'Глизе 667 C';

  @override
  String get cat_sysTrappist1 => 'TRAPPIST-1';

  @override
  String get cat_sys55Cnc => '55 Рака';

  @override
  String get cat_sys51Peg => '51 Пегаса';

  @override
  String cat_sysKepler(int n) {
    return 'Kepler-$n';
  }

  @override
  String get cat_sysOmegaCen => 'Скопление Омега Центавра';

  @override
  String get cat_sysSgrA => 'Центр Галактики (Sgr A*)';

  @override
  String get cat_sysLMC => 'Большое Магелланово Облако';

  @override
  String get cat_sysSMC => 'Малое Магелланово Облако';

  @override
  String get cat_sysAndromeda => 'Галактика Андромеды';

  @override
  String get cat_sysTriangulum => 'Галактика Треугольника';

  @override
  String get cat_pfxProxima => 'Проксима';

  @override
  String get cat_pfxBarnard => 'Барнард';

  @override
  String get cat_pfxSirius => 'Сириус A';

  @override
  String get cat_pfxEpsEri => 'Эпсилон Эридана';

  @override
  String get cat_pfxTauCeti => 'Тау Кита';

  @override
  String get cat_pfxTeegarden => 'Тигарден';

  @override
  String get cat_mars => 'Марс';

  @override
  String get cat_moon => 'Луна';

  @override
  String get cat_venus => 'Венера';

  @override
  String get cat_mercury => 'Меркурий';

  @override
  String get cat_ceres => 'Церера';

  @override
  String get cat_vesta => 'Веста';

  @override
  String get cat_jupiter => 'Юпитер';

  @override
  String get cat_io => 'Ио';

  @override
  String get cat_europa => 'Европа';

  @override
  String get cat_ganymede => 'Ганимед';

  @override
  String get cat_callisto => 'Каллисто';

  @override
  String get cat_saturn => 'Сатурн';

  @override
  String get cat_enceladus => 'Энцелад';

  @override
  String get cat_titan => 'Титан';

  @override
  String get cat_uranus => 'Уран';

  @override
  String get cat_miranda => 'Миранда';

  @override
  String get cat_titania => 'Титания';

  @override
  String get cat_neptune => 'Нептун';

  @override
  String get cat_triton => 'Тритон';

  @override
  String get cat_pluto => 'Плутон';

  @override
  String get cat_charon => 'Харон';

  @override
  String get cat_haumea => 'Хаумеа';

  @override
  String get cat_makemake => 'Макемаке';

  @override
  String get cat_eris => 'Эрида';

  @override
  String get cat_sedna => 'Седна';

  @override
  String get cat_planetNine => 'Девятая планета';

  @override
  String get u_topUpTitle => 'Мало кредитов';

  @override
  String u_topUpBody(int credits, int gems) {
    return 'Не хватает 💰$credits. Доплатить ⭐$gems и продолжить?';
  }

  @override
  String u_topUpNoGems(int gems) {
    return 'Нужно ⭐$gems. Купить кристаллы в магазине?';
  }

  @override
  String get u_topUpOk => 'Доплатить';

  @override
  String get u_goShop => 'В магазин';

  @override
  String get u_exchangeTitle => '💰 Обмен кредитов';

  @override
  String u_exchangeBody(int gems, int credits) {
    return 'Обменять ⭐$gems на 💰$credits?';
  }
}
