import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// 앱 이름 (게임 안 제목)
  ///
  /// In ko, this message translates to:
  /// **'우주 개척단'**
  String get appTitle;

  /// 이 언어의 자기 이름 (설정 언어 목록)
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get languageName;

  /// Station panel tab: ship upgrades
  ///
  /// In ko, this message translates to:
  /// **'함선'**
  String get u_tabShip;

  /// Station panel tab: station upgrades
  ///
  /// In ko, this message translates to:
  /// **'정거장'**
  String get u_tabStation;

  /// Station panel tab: crew
  ///
  /// In ko, this message translates to:
  /// **'승무원'**
  String get u_tabCrew;

  /// Station panel tab: missions
  ///
  /// In ko, this message translates to:
  /// **'임무'**
  String get u_tabMission;

  /// Station panel tab: ore market
  ///
  /// In ko, this message translates to:
  /// **'시장'**
  String get u_tabMarket;

  /// Ship tab, weapon upgrade description
  ///
  /// In ko, this message translates to:
  /// **'공격력 {dmg} · Lv.3 2연발 · Lv.6 3연발'**
  String u_upWeapon(int dmg);

  /// Ship tab, hull upgrade description
  ///
  /// In ko, this message translates to:
  /// **'최대 체력 {hp}'**
  String u_upHull(int hp);

  /// Ship tab, engine upgrade description
  ///
  /// In ko, this message translates to:
  /// **'최고 속도 {speed}'**
  String u_upEngine(int speed);

  /// Ship tab, missile description before equipping
  ///
  /// In ko, this message translates to:
  /// **'적을 추적하는 미사일 (Q키 / 🚀 버튼)'**
  String get u_upMissileIntro;

  /// Ship tab, missile stats
  ///
  /// In ko, this message translates to:
  /// **'{count}발 · 쿨타임 {cooldown}초'**
  String u_upMissile(int count, String cooldown);

  /// Ship tab, shield description before equipping
  ///
  /// In ko, this message translates to:
  /// **'모든 피해를 막는 실드 (F키 / 🛡 버튼)'**
  String get u_upShieldIntro;

  /// Ship tab, shield stats
  ///
  /// In ko, this message translates to:
  /// **'{duration}초 · 쿨타임 {cooldown}초'**
  String u_upShield(String duration, String cooldown);

  /// Ship tab, drone description before equipping
  ///
  /// In ko, this message translates to:
  /// **'곁을 돌며 자동으로 쏘고 아이템을 끌어와요'**
  String get u_upDroneIntro;

  /// Ship tab, drone stats
  ///
  /// In ko, this message translates to:
  /// **'피해 {dmg} · {interval}초마다 발사'**
  String u_upDrone(int dmg, String interval);

  /// Ship tab, magnet stats
  ///
  /// In ko, this message translates to:
  /// **'크레딧·광석을 끌어오는 범위 {range} · 힘 x{power}'**
  String u_upMagnet(int range, String power);

  /// Button to equip a new ship module
  ///
  /// In ko, this message translates to:
  /// **'장착'**
  String get u_equip;

  /// Ship tab footnote
  ///
  /// In ko, this message translates to:
  /// **'💨 부스트(Shift / 💨 버튼)는 기본 장착되어 있어요.'**
  String get u_boostNote;

  /// Ship tab section header for ship list
  ///
  /// In ko, this message translates to:
  /// **'🛸 격납고'**
  String get u_hangarSection;

  /// Button opening the full hangar screen
  ///
  /// In ko, this message translates to:
  /// **'크게 보기'**
  String get u_viewLarge;

  /// Stat label: hit points
  ///
  /// In ko, this message translates to:
  /// **'체력'**
  String get u_hp;

  /// Stat label: speed
  ///
  /// In ko, this message translates to:
  /// **'속도'**
  String get u_speed;

  /// Stat label: attack
  ///
  /// In ko, this message translates to:
  /// **'공격'**
  String get u_attack;

  /// Stat label: fire rate
  ///
  /// In ko, this message translates to:
  /// **'연사'**
  String get u_fireRate;

  /// Stat label: ore gain / ore resource
  ///
  /// In ko, this message translates to:
  /// **'광석'**
  String get u_ore;

  /// Stat label: critical hit chance
  ///
  /// In ko, this message translates to:
  /// **'치명타'**
  String get u_crit;

  /// Label shown on the ship currently in use
  ///
  /// In ko, this message translates to:
  /// **'탑승 중'**
  String get u_boarded;

  /// Button to switch to this ship (short)
  ///
  /// In ko, this message translates to:
  /// **'탑승'**
  String get u_board;

  /// Hangar screen button to switch to this ship
  ///
  /// In ko, this message translates to:
  /// **'탑승하기'**
  String get u_boardNow;

  /// Hint under a premium ship
  ///
  /// In ko, this message translates to:
  /// **'젬으로만 구매할 수 있어요'**
  String get u_gemsOnly;

  /// Hint under a locked ship
  ///
  /// In ko, this message translates to:
  /// **'해금: {condition} 또는 젬'**
  String u_unlockOrGems(String condition);

  /// Hangar screen unlock condition
  ///
  /// In ko, this message translates to:
  /// **'해금: {condition}'**
  String u_unlock(String condition);

  /// Station tab, station hull points
  ///
  /// In ko, this message translates to:
  /// **'내구도 {hp} / {max}'**
  String u_durability(int hp, int max);

  /// Station upgrade name
  ///
  /// In ko, this message translates to:
  /// **'거주구역'**
  String get u_habitat;

  /// Station habitat stats
  ///
  /// In ko, this message translates to:
  /// **'수입 💰{rate}/s · 내구도 {hp}'**
  String u_habitatDesc(String rate, int hp);

  /// Station upgrade name
  ///
  /// In ko, this message translates to:
  /// **'방어포탑'**
  String get u_turret;

  /// Station turret description before building
  ///
  /// In ko, this message translates to:
  /// **'해적을 자동으로 요격해요'**
  String get u_turretIntro;

  /// Station turret stats
  ///
  /// In ko, this message translates to:
  /// **'피해 {dmg} · 사거리 {range}'**
  String u_turretDesc(int dmg, int range);

  /// Home base upgrade name
  ///
  /// In ko, this message translates to:
  /// **'본거지 강화'**
  String get u_baseUpgrade;

  /// Home base upgrade stats
  ///
  /// In ko, this message translates to:
  /// **'레이저 {dmg} · 사거리 {range} · 내구도 {hp}'**
  String u_baseDesc(int dmg, int range, int hp);

  /// Home base disabled countdown
  ///
  /// In ko, this message translates to:
  /// **'기능 정지 {sec}초'**
  String u_disabledSec(int sec);

  /// Station tab section header
  ///
  /// In ko, this message translates to:
  /// **'{sector} 현황'**
  String u_sectorStatus(String sector);

  /// Station tab sector summary (4 lines)
  ///
  /// In ko, this message translates to:
  /// **'정착한 행성 {colonies} / {planets}\n정거장 {stations}개\n섹터 보너스: 생산량 x{mul}\n다른 섹터 수입: 💰{other}/s'**
  String u_sectorStats(
    int colonies,
    int planets,
    int stations,
    String mul,
    String other,
  );

  /// Recruit result title (legendary)
  ///
  /// In ko, this message translates to:
  /// **'🌟 전설 등급! 🌟'**
  String get u_legendaryGet;

  /// Recruit result title (rare)
  ///
  /// In ko, this message translates to:
  /// **'✨ 희귀한 동료! ✨'**
  String get u_rareGet;

  /// Recruit result title (normal)
  ///
  /// In ko, this message translates to:
  /// **'새 동료 합류!'**
  String get u_newCrew;

  /// Recruit result dialog close button
  ///
  /// In ko, this message translates to:
  /// **'좋아!'**
  String get u_great;

  /// Crew tab header
  ///
  /// In ko, this message translates to:
  /// **'승무원 {count}/{cap} · 배치 {assigned}/{slots}'**
  String u_crewHeader(int count, int cap, int assigned, int slots);

  /// Recruit with credits button
  ///
  /// In ko, this message translates to:
  /// **'영입 💰{cost}'**
  String u_recruit(int cost);

  /// Recruit with gems button
  ///
  /// In ko, this message translates to:
  /// **'고급 영입 ⭐{cost}'**
  String u_recruitPremium(int cost);

  /// Guaranteed legendary recruit button
  ///
  /// In ko, this message translates to:
  /// **'🌟 전설 확정 모집 ⭐{cost}'**
  String u_recruitLegendary(int cost);

  /// Recruit odds disclosure (3 lines)
  ///
  /// In ko, this message translates to:
  /// **'확률 안내 · 일반 영입: {normal}\n고급 영입: {premium}\n전설 확정 모집: ★4 100%'**
  String u_recruitOdds(String normal, String premium);

  /// Crew slot purchase button when maxed
  ///
  /// In ko, this message translates to:
  /// **'배치 슬롯 MAX ({n})'**
  String u_slotMax(int n);

  /// Buy crew slot button
  ///
  /// In ko, this message translates to:
  /// **'배치 슬롯 +1 ⭐{price}'**
  String u_slotBuy(int price);

  /// Roster expansion button when maxed
  ///
  /// In ko, this message translates to:
  /// **'정원 MAX ({n})'**
  String u_rosterMax(int n);

  /// Buy roster expansion button
  ///
  /// In ko, this message translates to:
  /// **'정원 +{size} ⭐{price}'**
  String u_rosterBuy(int size, int price);

  /// Crew tab empty state
  ///
  /// In ko, this message translates to:
  /// **'아직 동료가 없어요. 영입해서 함선에 배치해봐요!'**
  String get u_noCrew;

  /// Crew unassign button
  ///
  /// In ko, this message translates to:
  /// **'해제'**
  String get u_unassign;

  /// Crew assign button
  ///
  /// In ko, this message translates to:
  /// **'배치'**
  String get u_assign;

  /// Crew dismiss tooltip
  ///
  /// In ko, this message translates to:
  /// **'방출'**
  String get u_dismiss;

  /// Dismiss crew confirm dialog title
  ///
  /// In ko, this message translates to:
  /// **'승무원 방출'**
  String get u_dismissCrewTitle;

  /// Dismiss crew confirm body
  ///
  /// In ko, this message translates to:
  /// **'{name} 떠나보낼까요? 되돌릴 수 없어요.'**
  String u_dismissCrewBody(String name);

  /// Delivery mission progress text
  ///
  /// In ko, this message translates to:
  /// **'목적지로 이동하세요 (노란 화살표)'**
  String get u_missionDeliverHint;

  /// Bounty mission progress text
  ///
  /// In ko, this message translates to:
  /// **'목표를 찾아 처치하세요 (노란 화살표)'**
  String get u_missionBountyHint;

  /// Mission reward line
  ///
  /// In ko, this message translates to:
  /// **'보상 {rewards}'**
  String u_reward(String rewards);

  /// Mission tab header
  ///
  /// In ko, this message translates to:
  /// **'진행 중 ({n}/3)'**
  String u_activeMissions(int n);

  /// Mission tab empty state
  ///
  /// In ko, this message translates to:
  /// **'진행 중인 임무가 없어요.'**
  String get u_noActiveMissions;

  /// Abandon mission button
  ///
  /// In ko, this message translates to:
  /// **'포기'**
  String get u_abandon;

  /// Mission board header
  ///
  /// In ko, this message translates to:
  /// **'임무 게시판 · 새 임무까지 {sec}초'**
  String u_missionBoard(int sec);

  /// Accept mission button
  ///
  /// In ko, this message translates to:
  /// **'수락'**
  String get u_accept;

  /// Ore price trend: high
  ///
  /// In ko, this message translates to:
  /// **'📈 비싸요! 팔 때예요'**
  String get u_priceHigh;

  /// Ore price trend: low
  ///
  /// In ko, this message translates to:
  /// **'📉 싸요… 기다려봐요'**
  String get u_priceLow;

  /// Ore price trend: normal
  ///
  /// In ko, this message translates to:
  /// **'➡ 보통'**
  String get u_priceNormal;

  /// Market tab header
  ///
  /// In ko, this message translates to:
  /// **'광석 시세'**
  String get u_orePrice;

  /// Sell 100 ore button
  ///
  /// In ko, this message translates to:
  /// **'100개 판매'**
  String get u_sell100;

  /// Sell half ore button
  ///
  /// In ko, this message translates to:
  /// **'절반 판매'**
  String get u_sellHalf;

  /// Sell all ore button
  ///
  /// In ko, this message translates to:
  /// **'전부 판매'**
  String get u_sellAll;

  /// Market tab tip
  ///
  /// In ko, this message translates to:
  /// **'시세는 시간에 따라 오르내려요. 비쌀 때 팔면 이득!'**
  String get u_marketTip;

  /// Market tab section header
  ///
  /// In ko, this message translates to:
  /// **'⭐ 스타젬 교환'**
  String get u_gemExchange;

  /// Gems-to-credits pack name
  ///
  /// In ko, this message translates to:
  /// **'크레딧 꾸러미'**
  String get u_creditPack;

  /// Exchange button
  ///
  /// In ko, this message translates to:
  /// **'교환'**
  String get u_exchange;

  /// Open shop button
  ///
  /// In ko, this message translates to:
  /// **'⭐ 상점 열기'**
  String get u_openShop;

  /// Advisor line when an achievement completes
  ///
  /// In ko, this message translates to:
  /// **'🏆 업적 달성: {title}! 메뉴의 업적에서 ⭐{gems}를 받으세요.'**
  String u_achievementDone(String title, int gems);

  /// Advisor line when an action fails
  ///
  /// In ko, this message translates to:
  /// **'자원이 부족하거나 지금은 할 수 없어요.'**
  String get u_cannotDo;

  /// Offline earnings dialog title
  ///
  /// In ko, this message translates to:
  /// **'어서 오세요, 선장님!'**
  String get u_welcomeBack;

  /// Offline earnings body (hours and minutes)
  ///
  /// In ko, this message translates to:
  /// **'자리를 비운 {h}시간 {m}분 동안\n식민지가 열심히 일했어요!'**
  String u_offlineHm(int h, int m);

  /// Offline earnings body (minutes only)
  ///
  /// In ko, this message translates to:
  /// **'자리를 비운 {m}분 동안\n식민지가 열심히 일했어요!'**
  String u_offlineM(int m);

  /// Offline dialog upsell hint
  ///
  /// In ko, this message translates to:
  /// **'사령관 패스: 최대 8시간 + 자동 2배'**
  String get u_passOfflineHint;

  /// Collect offline earnings button
  ///
  /// In ko, this message translates to:
  /// **'받기'**
  String get u_collect;

  /// Toast when the ad is not ready
  ///
  /// In ko, this message translates to:
  /// **'광고를 불러오는 중이에요. 잠시 후 다시 시도해 주세요.'**
  String get u_adLoading;

  /// Advisor line when revive ad is not ready
  ///
  /// In ko, this message translates to:
  /// **'광고를 불러오는 중이에요. 잠시 후 다시 눌러주세요.'**
  String get u_adLoadingRetry;

  /// Offline double collect (premium)
  ///
  /// In ko, this message translates to:
  /// **'2배로 받기 👑'**
  String get u_collectDouble;

  /// Offline double collect via ad
  ///
  /// In ko, this message translates to:
  /// **'📺 광고 보고 2배'**
  String get u_adDouble;

  /// Ascension dialog title
  ///
  /// In ko, this message translates to:
  /// **'🌌 은하 명예'**
  String get u_galaxyHonor;

  /// Ascension dialog current honor
  ///
  /// In ko, this message translates to:
  /// **'현재 명예 {honor}점 (환생 {ascensions}회)'**
  String u_honorStatus(int honor, int ascensions);

  /// Ascension dialog honor bonus
  ///
  /// In ko, this message translates to:
  /// **'수입 +{income}% · 공격력 +{attack}%'**
  String u_honorBonus(int income, int attack);

  /// Ascension dialog explanation
  ///
  /// In ko, this message translates to:
  /// **'환생하면 지금 우주(섹터, 식민지, 정거장, 함선 강화, 승무원, 크레딧)가 초기화되고\n대신 영구 보너스인 명예 점수를 받아요.\n젬, 꾸미기, 함선, 업적은 유지돼요.'**
  String get u_ascendExplain;

  /// Ascension dialog gain preview
  ///
  /// In ko, this message translates to:
  /// **'지금 환생하면 명예 +{gain}점!\n(제국 가치가 클수록 많이 받아요)'**
  String u_ascendGain(int gain);

  /// Ascension dialog when not yet allowed
  ///
  /// In ko, this message translates to:
  /// **'섹터 4에 도달하면 환생할 수 있어요.'**
  String get u_ascendLocked;

  /// Close button
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get u_close;

  /// Ascend button with honor gain
  ///
  /// In ko, this message translates to:
  /// **'환생 (+{gain})'**
  String u_ascendBtn(int gain);

  /// Ascend confirm title
  ///
  /// In ko, this message translates to:
  /// **'정말 환생할까요?'**
  String get u_ascendConfirmTitle;

  /// Ascend confirm body
  ///
  /// In ko, this message translates to:
  /// **'현재 우주가 초기화돼요. 되돌릴 수 없어요.'**
  String get u_ascendConfirmBody;

  /// Ascend confirm button
  ///
  /// In ko, this message translates to:
  /// **'환생'**
  String get u_ascend;

  /// HUD: planet shield is broken
  ///
  /// In ko, this message translates to:
  /// **'{name} 깨짐'**
  String u_shieldBroken(String name);

  /// HUD top-right sector info (2 lines)
  ///
  /// In ko, this message translates to:
  /// **'{sector} · 발전 {dev}%\n⚠ 위협 {threat}  🏛 {value}'**
  String u_hudSector(String sector, int dev, String threat, String value);

  /// HUD: home base disabled
  ///
  /// In ko, this message translates to:
  /// **'본거지 정지 {sec}s'**
  String u_baseDisabled(int sec);

  /// HUD: home base hull percent
  ///
  /// In ko, this message translates to:
  /// **'본거지 {pct}%'**
  String u_baseHp(int pct);

  /// Interact button: merchant
  ///
  /// In ko, this message translates to:
  /// **'상인 (E)'**
  String get u_merchantE;

  /// Interact button: warp forward
  ///
  /// In ko, this message translates to:
  /// **'다음 섹터 (E)'**
  String get u_nextSectorE;

  /// Interact button: warp back
  ///
  /// In ko, this message translates to:
  /// **'이전 섹터 (E)'**
  String get u_prevSectorE;

  /// Locked gate button
  ///
  /// In ko, this message translates to:
  /// **'🔒 발전도 100%에서 열려요 ({pct}%)'**
  String u_gateLocked(int pct);

  /// Interact button: settle planet
  ///
  /// In ko, this message translates to:
  /// **'{name} 정착'**
  String u_settle(String name);

  /// Interact button: manage colony
  ///
  /// In ko, this message translates to:
  /// **'{name} 관리 (E)'**
  String u_manageE(String name);

  /// Interact button: build station
  ///
  /// In ko, this message translates to:
  /// **'정거장 건설'**
  String get u_buildStation;

  /// Touch fire button
  ///
  /// In ko, this message translates to:
  /// **'발사'**
  String get u_fire;

  /// Advisor line when a locked skill button is pressed
  ///
  /// In ko, this message translates to:
  /// **'정거장 함선 개조에서 장착할 수 있어요!'**
  String get u_equipAtStation;

  /// Death overlay title
  ///
  /// In ko, this message translates to:
  /// **'💥 격추당했습니다!'**
  String get u_shotDown;

  /// Death overlay countdown
  ///
  /// In ko, this message translates to:
  /// **'{sec}초 뒤 기지에서 자동 재출격'**
  String u_autoRespawn(int sec);

  /// Revive button (premium)
  ///
  /// In ko, this message translates to:
  /// **'👑 이 자리에서 부활 (무료)'**
  String get u_reviveFree;

  /// Revive button via ad
  ///
  /// In ko, this message translates to:
  /// **'📺 광고 보고 이 자리에서 부활'**
  String get u_reviveAd;

  /// Revive button via gems
  ///
  /// In ko, this message translates to:
  /// **'⭐10 으로 이 자리에서 부활'**
  String get u_reviveGems;

  /// Respawn at base button
  ///
  /// In ko, this message translates to:
  /// **'🏠 기지에서 재출격 (크레딧 {pct}% 손실)'**
  String u_respawnBase(int pct);

  /// Dialog speaker name
  ///
  /// In ko, this message translates to:
  /// **'선장'**
  String get u_spkCaptain;

  /// Dialog speaker name
  ///
  /// In ko, this message translates to:
  /// **'해적'**
  String get u_spkPirate;

  /// Dialog speaker name (advisor character)
  ///
  /// In ko, this message translates to:
  /// **'부관 미나'**
  String get u_spkAdvisor;

  /// Dialog speaker name (cat merchant)
  ///
  /// In ko, this message translates to:
  /// **'상인 냥냥'**
  String get u_spkMerchant;

  /// Pause menu title
  ///
  /// In ko, this message translates to:
  /// **'일시정지'**
  String get u_paused;

  /// Pause menu stats (2 lines)
  ///
  /// In ko, this message translates to:
  /// **'{sector} · 격추 {kills} · 승무원 {crew}\n정착 {colonies} · 정거장 {stations} · 임무 완료 {missions}'**
  String u_pauseStats(
    String sector,
    int kills,
    int crew,
    int colonies,
    int stations,
    int missions,
  );

  /// Pause menu button
  ///
  /// In ko, this message translates to:
  /// **'▶ 계속하기'**
  String get u_resume;

  /// Pause menu button
  ///
  /// In ko, this message translates to:
  /// **'⭐ 상점'**
  String get u_shop;

  /// Pause menu button
  ///
  /// In ko, this message translates to:
  /// **'🏆 업적'**
  String get u_achievements;

  /// Pause menu button
  ///
  /// In ko, this message translates to:
  /// **'📅 일일 퀘스트'**
  String get u_dailyQuests;

  /// Pause menu button
  ///
  /// In ko, this message translates to:
  /// **'🌍 내 행성'**
  String get u_myPlanet;

  /// Pause menu button
  ///
  /// In ko, this message translates to:
  /// **'🌌 은하 명예 (환생)'**
  String get u_ascendMenu;

  /// Pause menu button
  ///
  /// In ko, this message translates to:
  /// **'⚙ 설정'**
  String get u_settings;

  /// Pause menu button
  ///
  /// In ko, this message translates to:
  /// **'💾 저장하고 타이틀로'**
  String get u_saveAndQuit;

  /// Pause menu keyboard help
  ///
  /// In ko, this message translates to:
  /// **'키보드: WASD 이동 · Space 사격 · Q 미사일 · F 실드 · Shift 부스트\nE 상호작용 · B 정거장 건설 · Esc 메뉴'**
  String get u_keyboardHelp;

  /// Colony panel: shield recharging
  ///
  /// In ko, this message translates to:
  /// **'재충전 중'**
  String get u_recharging;

  /// Colony tutorial tile
  ///
  /// In ko, this message translates to:
  /// **'방어막\n안에 있으면 안전'**
  String get u_tutDome;

  /// Colony tutorial tile
  ///
  /// In ko, this message translates to:
  /// **'레벨업\n수입·건물↑'**
  String get u_tutLevelUp;

  /// Colony tutorial tile
  ///
  /// In ko, this message translates to:
  /// **'포탑'**
  String get u_tutTurret;

  /// Colony tutorial tile
  ///
  /// In ko, this message translates to:
  /// **'수리'**
  String get u_tutRepair;

  /// Colony tutorial tile
  ///
  /// In ko, this message translates to:
  /// **'습격 막기'**
  String get u_tutRaid;

  /// Tutorial dismiss button
  ///
  /// In ko, this message translates to:
  /// **'알겠어요'**
  String get u_gotIt;

  /// Building effect: damage
  ///
  /// In ko, this message translates to:
  /// **'피해 {dmg}'**
  String u_damage(int dmg);

  /// Building effect: ore per second
  ///
  /// In ko, this message translates to:
  /// **'광석 +{rate}/s'**
  String u_oreRate(String rate);

  /// Building effect: income bonus
  ///
  /// In ko, this message translates to:
  /// **'수입 +{pct}%'**
  String u_incomePct(int pct);

  /// Building effect: repair per second
  ///
  /// In ko, this message translates to:
  /// **'체력 +{hp}/s'**
  String u_repairRate(int hp);

  /// Building effect: shield capacity
  ///
  /// In ko, this message translates to:
  /// **'방어막 +{amount}'**
  String u_shieldPlus(int amount);

  /// Star system panel title
  ///
  /// In ko, this message translates to:
  /// **'{sector} · 항성계 {n}'**
  String u_systemTitle(String sector, int n);

  /// Star system panel subtitle
  ///
  /// In ko, this message translates to:
  /// **'위협 {threat} · 자원 배율 x{mul}'**
  String u_systemInfo(String threat, String mul);

  /// Star system development
  ///
  /// In ko, this message translates to:
  /// **'발전도 {pct}%'**
  String u_development(int pct);

  /// Gate status: open
  ///
  /// In ko, this message translates to:
  /// **'다음 항성계 열림'**
  String get u_nextSystemOpen;

  /// Gate status: locked
  ///
  /// In ko, this message translates to:
  /// **'100%에서 열림'**
  String get u_opensAt100;

  /// Development hint
  ///
  /// In ko, this message translates to:
  /// **'모든 행성을 Lv.3까지 키우면 100%'**
  String get u_devHint;

  /// System panel section header
  ///
  /// In ko, this message translates to:
  /// **'점령한 항성계 (계속 생산 중)'**
  String get u_conqueredSystems;

  /// Planet status: not settled
  ///
  /// In ko, this message translates to:
  /// **'미정착'**
  String get u_unsettled;

  /// Planet status: being raided
  ///
  /// In ko, this message translates to:
  /// **'습격 중'**
  String get u_underRaid;

  /// Fallback sector name
  ///
  /// In ko, this message translates to:
  /// **'미지의 섹터 {n}'**
  String u_unknownSector(int n);

  /// Conquered system row
  ///
  /// In ko, this message translates to:
  /// **'{name} · 발전 {pct}%'**
  String u_sectorDev(String name, int pct);

  /// Build station panel title
  ///
  /// In ko, this message translates to:
  /// **'정거장 건설 · 역할 고르기'**
  String get u_buildStationTitle;

  /// Cost label
  ///
  /// In ko, this message translates to:
  /// **'비용'**
  String get u_cost;

  /// Build button
  ///
  /// In ko, this message translates to:
  /// **'건설'**
  String get u_build;

  /// Gate label in world
  ///
  /// In ko, this message translates to:
  /// **'🌀 다음 섹터로'**
  String get u_toNextSector;

  /// Locked gate label in world
  ///
  /// In ko, this message translates to:
  /// **'🔒 두목을 쓰러뜨리면 열림'**
  String get u_bossLocked;

  /// Gate label in world
  ///
  /// In ko, this message translates to:
  /// **'🌀 이전 섹터로'**
  String get u_toPrevSector;

  /// World label over raided planet
  ///
  /// In ko, this message translates to:
  /// **'⚠ 습격 중!'**
  String get u_raidAlert;

  /// World label: shield reboot progress
  ///
  /// In ko, this message translates to:
  /// **'재충전 {pct}%'**
  String u_rechargePct(int pct);

  /// World label over the merchant
  ///
  /// In ko, this message translates to:
  /// **'🛒 떠돌이 상인 ({sec}초)'**
  String u_merchantLabel(int sec);

  /// World label over supply pod
  ///
  /// In ko, this message translates to:
  /// **'📦 보급 캡슐'**
  String get u_supplyPod;

  /// World label over sector boss
  ///
  /// In ko, this message translates to:
  /// **'☠ {sector} 두목'**
  String u_sectorBoss(String sector);

  /// World label over pirate boss
  ///
  /// In ko, this message translates to:
  /// **'☠ 해적 두목'**
  String get u_pirateBoss;

  /// Merchant panel title
  ///
  /// In ko, this message translates to:
  /// **'떠돌이 상인 냥냥'**
  String get u_merchantName;

  /// Merchant panel subtitle
  ///
  /// In ko, this message translates to:
  /// **'{sec}초 뒤에 떠나요 · 💰{credits}'**
  String u_merchantLeaves(int sec, String credits);

  /// Merchant section header
  ///
  /// In ko, this message translates to:
  /// **'희귀 동료 소개'**
  String get u_rareCrewOffer;

  /// Merchant crew sold out
  ///
  /// In ko, this message translates to:
  /// **'오늘의 동료는 이미 팔렸다냥!'**
  String get u_crewSoldOut;

  /// Merchant section header
  ///
  /// In ko, this message translates to:
  /// **'젬 환전 (3회 한정)'**
  String get u_gemTrade;

  /// Merchant gem trade row
  ///
  /// In ko, this message translates to:
  /// **'💰{price} → ⭐5  ({left}회 남음)'**
  String u_gemTradeRow(int price, int left);

  /// Merchant gem trade button
  ///
  /// In ko, this message translates to:
  /// **'환전'**
  String get u_convert;

  /// Merchant section header
  ///
  /// In ko, this message translates to:
  /// **'강화 물약 (효과 시간 2배)'**
  String get u_potions;

  /// Toast
  ///
  /// In ko, this message translates to:
  /// **'젬이 부족해요'**
  String get u_notEnoughGems;

  /// Purchase confirm title
  ///
  /// In ko, this message translates to:
  /// **'구매 확인'**
  String get u_buyConfirmTitle;

  /// Ship purchase confirm body
  ///
  /// In ko, this message translates to:
  /// **'{ship}에 {price} 사용할까요?'**
  String u_buyShipConfirm(String ship, String price);

  /// Toast after buying a ship
  ///
  /// In ko, this message translates to:
  /// **'{ship} 획득! 바로 탑승했어요'**
  String u_shipBought(String ship);

  /// Hangar title (premium only)
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 함선'**
  String get u_premiumShips;

  /// Hangar screen title
  ///
  /// In ko, this message translates to:
  /// **'격납고'**
  String get u_hangarTitle;

  /// Hangar buy button
  ///
  /// In ko, this message translates to:
  /// **'⭐{price} 구매'**
  String u_buyGems(int price);

  /// Premium badge
  ///
  /// In ko, this message translates to:
  /// **'프리미엄'**
  String get u_premium;

  /// Default confirm button
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get u_ok;

  /// Default cancel button
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get u_cancel;

  /// 공통 확인 버튼 (결제 확인 대화상자, 이름 입력)
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get m_ok;

  /// 공통 취소 버튼
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get m_cancel;

  /// 공통 닫기 버튼
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get m_close;

  /// 출석 보상 대화상자의 받기 버튼
  ///
  /// In ko, this message translates to:
  /// **'받기'**
  String get m_claim;

  /// 업적/일일 퀘스트 보상 받기 버튼
  ///
  /// In ko, this message translates to:
  /// **'⭐{gems} 받기'**
  String m_claimGems(int gems);

  /// 업적/일일 퀘스트 보상을 이미 받음 표시
  ///
  /// In ko, this message translates to:
  /// **'✅ 완료'**
  String get m_done;

  /// 젬 부족 토스트 (상점, 행성 꾸미기)
  ///
  /// In ko, this message translates to:
  /// **'젬이 부족해요'**
  String get m_notEnoughGems;

  /// 구매 복원 버튼 (상점 패키지 탭, 설정)
  ///
  /// In ko, this message translates to:
  /// **'구매 복원'**
  String get m_restorePurchases;

  /// 구매 복원 후 토스트
  ///
  /// In ko, this message translates to:
  /// **'구매 내역을 확인했어요'**
  String get m_restoreDone;

  /// 젬 사용 확인 대화상자 제목
  ///
  /// In ko, this message translates to:
  /// **'구매 확인'**
  String get m_buyConfirmTitle;

  /// 젬 사용 확인 본문. 한국어는 목적격 조사가 붙은 가격
  ///
  /// In ko, this message translates to:
  /// **'{price} 사용할까요?'**
  String m_spendGemsConfirm(String price);

  /// 출석 보상 대화상자 제목 / 상점 무료 젬 탭 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'📅 출석 보상'**
  String get m_loginTitle;

  /// 출석 보상 대화상자 인사
  ///
  /// In ko, this message translates to:
  /// **'오늘도 와주셨네요, 선장님!'**
  String get m_loginWelcome;

  /// 출석 보상 대화상자 안내
  ///
  /// In ko, this message translates to:
  /// **'7일 연속 출석하면 ⭐50!'**
  String get m_loginStreakHint;

  /// 새 게임 확인 대화상자 제목
  ///
  /// In ko, this message translates to:
  /// **'새 게임'**
  String get m_newGameTitle;

  /// 새 게임 확인 대화상자 본문
  ///
  /// In ko, this message translates to:
  /// **'기존 진행 상황이 지워져요.\n(젬, 꾸미기, 업적, 구매 상품은 유지돼요) 계속할까요?'**
  String get m_newGameBody;

  /// 새 게임 확인 버튼
  ///
  /// In ko, this message translates to:
  /// **'시작'**
  String get m_start;

  /// 이어하기 실패 토스트
  ///
  /// In ko, this message translates to:
  /// **'저장 데이터를 불러오지 못했어요.'**
  String get m_loadFailed;

  /// 타이틀 화면의 환생 명예 보너스 줄
  ///
  /// In ko, this message translates to:
  /// **'🌌 은하 명예 {honor}점 · 수입 +{income}% · 공격 +{attack}%'**
  String m_honorLine(int honor, int income, int attack);

  /// 타이틀 화면 이어하기 버튼
  ///
  /// In ko, this message translates to:
  /// **'▶ 이어하기'**
  String get m_continue;

  /// 타이틀 화면 새 게임 버튼
  ///
  /// In ko, this message translates to:
  /// **'✨ 새 게임'**
  String get m_newGame;

  /// 타이틀 메뉴 아이콘 (내 행성)
  ///
  /// In ko, this message translates to:
  /// **'내 행성'**
  String get m_menuHome;

  /// 타이틀 메뉴 아이콘 (상점)
  ///
  /// In ko, this message translates to:
  /// **'상점'**
  String get m_menuShop;

  /// 타이틀 메뉴 아이콘 (일일 퀘스트)
  ///
  /// In ko, this message translates to:
  /// **'퀘스트'**
  String get m_menuQuest;

  /// 타이틀 메뉴 아이콘 (업적)
  ///
  /// In ko, this message translates to:
  /// **'업적'**
  String get m_menuAchievements;

  /// 타이틀 메뉴 아이콘 (설정)
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get m_menuSettings;

  /// 업적 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'🏆 업적 ({done}/{total})'**
  String m_achievementsTitle(int done, int total);

  /// 일일 퀘스트 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'📅 일일 퀘스트'**
  String get m_dailyTitle;

  /// 일일 퀘스트 초기화까지 남은 시간
  ///
  /// In ko, this message translates to:
  /// **'초기화까지 {hours}시간 {minutes}분'**
  String m_dailyReset(int hours, int minutes);

  /// 일일 퀘스트 전체 완료 보너스 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'🎁 모두 완료 보너스'**
  String get m_dailyBonusTitle;

  /// 전체 완료 보너스 조건
  ///
  /// In ko, this message translates to:
  /// **'오늘의 퀘스트 3개를 모두 받으면'**
  String get m_dailyBonusDesc;

  /// 설정 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'⚙ 설정'**
  String get m_settingsTitle;

  /// 설정: 효과음 스위치
  ///
  /// In ko, this message translates to:
  /// **'효과음'**
  String get m_settingsSound;

  /// 설정: 배경음악 스위치
  ///
  /// In ko, this message translates to:
  /// **'배경음악'**
  String get m_settingsMusic;

  /// 설정: 복귀 알림 스위치
  ///
  /// In ko, this message translates to:
  /// **'복귀 알림'**
  String get m_settingsNotify;

  /// 설정: 복귀 알림 설명
  ///
  /// In ko, this message translates to:
  /// **'식민지 창고가 가득 차면 알려드려요'**
  String get m_settingsNotifyDesc;

  /// 설정: 진동 스위치
  ///
  /// In ko, this message translates to:
  /// **'진동'**
  String get m_settingsHaptics;

  /// 설정: 언어 선택 항목 제목 (영어가 아니면 뒤에 " / Language"가 붙음)
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get m_settingsLanguage;

  /// 언어 선택 목록의 시스템 기본값 항목
  ///
  /// In ko, this message translates to:
  /// **'기기 언어 따라가기'**
  String get m_languageSystem;

  /// 설정: 개인정보처리방침 항목/대화상자 제목
  ///
  /// In ko, this message translates to:
  /// **'개인정보처리방침'**
  String get m_privacyTitle;

  /// 개인정보처리방침 요약 본문
  ///
  /// In ko, this message translates to:
  /// **'우주 개척단은 게임 진행 데이터(진행 상황, 설정)를 기기 안에만 저장하며, 개인을 식별할 수 있는 정보를 수집하지 않습니다.\n\n인앱 결제는 Google Play / App Store가 처리하며, 결제 정보는 개발자에게 전달되지 않습니다.\n\n보상형 광고가 적용될 경우 광고 제공사(Google AdMob)가 광고 식별자 등을 수집할 수 있습니다.\n\n문의: {email} (설정 → 개발자에게 피드백 보내기)'**
  String m_privacyBody(String email);

  /// 설정: 데이터 초기화 항목
  ///
  /// In ko, this message translates to:
  /// **'모든 데이터 초기화'**
  String get m_wipeTitle;

  /// 설정: 데이터 초기화 설명
  ///
  /// In ko, this message translates to:
  /// **'진행 상황, 젬, 꾸미기가 모두 삭제돼요'**
  String get m_wipeDesc;

  /// 데이터 초기화 확인 제목
  ///
  /// In ko, this message translates to:
  /// **'정말 초기화할까요?'**
  String get m_wipeConfirmTitle;

  /// 데이터 초기화 확인 본문
  ///
  /// In ko, this message translates to:
  /// **'되돌릴 수 없어요. 구매한 상품은 \"구매 복원\"으로 되찾을 수 있어요.'**
  String get m_wipeConfirmBody;

  /// 데이터 초기화 확인 버튼
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get m_wipeOk;

  /// 설정: 피드백 메일 항목
  ///
  /// In ko, this message translates to:
  /// **'개발자에게 피드백 보내기'**
  String get m_feedbackTitle;

  /// 설정: 피드백 설명
  ///
  /// In ko, this message translates to:
  /// **'버그·건의 뭐든 좋아요. 기기와 앱 버전이 자동으로 적혀요.'**
  String get m_feedbackDesc;

  /// 메일 앱이 없을 때 토스트
  ///
  /// In ko, this message translates to:
  /// **'메일 앱이 없어요. {email} 으로 보내주세요.'**
  String m_noMailApp(String email);

  /// 설정 맨 아래 앱 이름
  ///
  /// In ko, this message translates to:
  /// **'STAR SETTLERS · 우주 개척단'**
  String get m_aboutTitle;

  /// 설정 맨 아래 앱 버전
  ///
  /// In ko, this message translates to:
  /// **'버전 {version}'**
  String m_version(String version);

  /// 상점 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'⭐ 상점'**
  String get m_shopTitle;

  /// 인앱 구매 성공 토스트
  ///
  /// In ko, this message translates to:
  /// **'구매 완료! 감사합니다 💜'**
  String get m_buyThanks;

  /// 광고 준비 안 됨 토스트
  ///
  /// In ko, this message translates to:
  /// **'광고를 불러오는 중이에요. 잠시 후 다시 시도해 주세요.'**
  String get m_adLoading;

  /// 프리미엄 함선 구매 확인 본문. price는 한국어 목적격 조사 포함
  ///
  /// In ko, this message translates to:
  /// **'{ship}에 {price} 사용할까요?'**
  String m_buyShipConfirm(String ship, String price);

  /// 프리미엄 함선 구매 성공 토스트
  ///
  /// In ko, this message translates to:
  /// **'{ship} 획득! 바로 탑승했어요'**
  String m_shipAcquired(String ship);

  /// 상점 탭
  ///
  /// In ko, this message translates to:
  /// **'젬 충전'**
  String get m_tabGems;

  /// 상점 탭
  ///
  /// In ko, this message translates to:
  /// **'패키지'**
  String get m_tabPacks;

  /// 상점 탭
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 함선'**
  String get m_tabPremiumShips;

  /// 상점 탭
  ///
  /// In ko, this message translates to:
  /// **'함선 스킨'**
  String get m_tabSkins;

  /// 상점 탭
  ///
  /// In ko, this message translates to:
  /// **'선장 의상'**
  String get m_tabOutfits;

  /// 상점 탭
  ///
  /// In ko, this message translates to:
  /// **'무료 젬'**
  String get m_tabFree;

  /// 상점 하단 테스트 모드 띠
  ///
  /// In ko, this message translates to:
  /// **'🧪 테스트 모드: 실제 결제/광고가 일어나지 않아요'**
  String get m_testMode;

  /// 상점: 이미 가진 상품/함선
  ///
  /// In ko, this message translates to:
  /// **'보유 중'**
  String get m_owned;

  /// 상점: 지금 탄 함선
  ///
  /// In ko, this message translates to:
  /// **'탑승 중'**
  String get m_boarded;

  /// 상점 젬 충전 탭 하단 안내
  ///
  /// In ko, this message translates to:
  /// **'젬은 꾸미기, 고급 영입, 즉시 부활, 크레딧 교환에 쓸 수 있어요.\n게임 플레이(업적·출석·두목·보급 캡슐)로도 모을 수 있어요.'**
  String get m_gemsInfo;

  /// 상점 패키지 탭 승무원 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'👩‍🚀 승무원 (젬)'**
  String get m_crewSection;

  /// 프리미엄 함선 탭 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'🛸 프리미엄 함선'**
  String get m_premiumSection;

  /// 프리미엄 함선 탭 설명
  ///
  /// In ko, this message translates to:
  /// **'젬으로만 얻을 수 있는 특별한 전투기예요. 고유 능력이 있어요.'**
  String get m_premiumDesc;

  /// 프리미엄 함선을 격납고 화면에서 크게 보기 버튼
  ///
  /// In ko, this message translates to:
  /// **'한 장씩 크게 보기'**
  String get m_viewLarge;

  /// 프리미엄 함선 탭 하단 안내
  ///
  /// In ko, this message translates to:
  /// **'격납고(정거장 → 함선 탭)에서도 구매·교체할 수 있어요.'**
  String get m_premiumHangarHint;

  /// 젬 아이템: 전설 승무원 모집
  ///
  /// In ko, this message translates to:
  /// **'전설 승무원 확정 모집'**
  String get m_legendTitle;

  /// 전설 모집 설명 (게임 시작 전)
  ///
  /// In ko, this message translates to:
  /// **'★4 전설 승무원 1명 (보너스 20%~, 칭호·금빛 오라)\n게임을 시작한 뒤 구매할 수 있어요'**
  String get m_legendDescNoGame;

  /// 전설 모집 설명 (게임 중)
  ///
  /// In ko, this message translates to:
  /// **'★4 전설 승무원 1명 (보너스 20%~, 칭호·금빛 오라)\n승무원 {count}/{cap}'**
  String m_legendDesc(int count, int cap);

  /// 승무원 합류 토스트
  ///
  /// In ko, this message translates to:
  /// **'{stars} {name} 합류!'**
  String m_crewJoined(String stars, String name);

  /// 젬 아이템: 배치 슬롯
  ///
  /// In ko, this message translates to:
  /// **'배치 슬롯 +1'**
  String get m_slotTitle;

  /// 배치 슬롯 설명
  ///
  /// In ko, this message translates to:
  /// **'함선에 동시에 배치할 수 있는 승무원 수 · 현재 {slots}'**
  String m_slotDesc(int slots);

  /// 젬 아이템: 승무원 정원 확장
  ///
  /// In ko, this message translates to:
  /// **'승무원 정원 +{n}'**
  String m_rosterTitle(int n);

  /// 정원 확장 설명
  ///
  /// In ko, this message translates to:
  /// **'보유할 수 있는 승무원 수 · 현재 {cap} (최대 {max})'**
  String m_rosterDesc(int cap, int max);

  /// 상점 승무원 섹션 확률 표시
  ///
  /// In ko, this message translates to:
  /// **'고급 영입 확률: {odds} · 전설 확정 모집: ★4 100%'**
  String m_crewOdds(String odds);

  /// 꾸미기 카드: 장착 중
  ///
  /// In ko, this message translates to:
  /// **'장착 중'**
  String get m_equipped;

  /// 꾸미기 카드: 장착 버튼
  ///
  /// In ko, this message translates to:
  /// **'장착'**
  String get m_equip;

  /// 꾸미기 카드: 사령관 패스 전용
  ///
  /// In ko, this message translates to:
  /// **'사령관 패스 전용'**
  String get m_passOnly;

  /// 꾸미기 카드: 스타터 팩 전용
  ///
  /// In ko, this message translates to:
  /// **'스타터 팩 전용'**
  String get m_starterOnly;

  /// 무료 젬 탭 광고 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'📺 광고 보고 무료 젬'**
  String get m_adSection;

  /// 광고 보상 안내
  ///
  /// In ko, this message translates to:
  /// **'하루 {perDay}회, 1회에 ⭐5 · 오늘 {left}회 남음'**
  String m_adInfo(int perDay, int left);

  /// 사령관 패스 보유 시 광고 없이 받기 버튼
  ///
  /// In ko, this message translates to:
  /// **'⭐5 받기 (사령관 패스: 광고 없음)'**
  String get m_adClaimPremium;

  /// 광고 보고 젬 받기 버튼
  ///
  /// In ko, this message translates to:
  /// **'광고 보고 ⭐5 받기'**
  String get m_adWatch;

  /// 무료 젬 탭 연속 출석 일수
  ///
  /// In ko, this message translates to:
  /// **'연속 출석 {days}일째'**
  String m_loginStreak(int days);

  /// 출석 보상 달력 칸의 날짜
  ///
  /// In ko, this message translates to:
  /// **'{day}일'**
  String m_dayN(int day);

  /// 내 행성: 건설/업그레이드 실패 토스트
  ///
  /// In ko, this message translates to:
  /// **'자원이 부족해요'**
  String get m_notEnoughResources;

  /// 내 행성 빈 칸 시트 제목
  ///
  /// In ko, this message translates to:
  /// **'빈 땅 #{n} · 건물 짓기'**
  String m_emptyLot(int n);

  /// 게임 밖에서 내 행성을 열었을 때 안내
  ///
  /// In ko, this message translates to:
  /// **'건설은 게임 중(메뉴 → 내 행성)에 할 수 있어요. 크레딧과 광석은 현재 우주에서 써요.'**
  String get m_buildInGameOnly;

  /// 내 행성 시트: 보유 자원
  ///
  /// In ko, this message translates to:
  /// **'보유 💰{credits}  💎{ore}  ⭐{gems}'**
  String m_heldAll(String credits, String ore, int gems);

  /// 내 행성 하단: 보유 자원
  ///
  /// In ko, this message translates to:
  /// **'보유 💰{credits}  💎{ore}'**
  String m_held(String credits, String ore);

  /// 건물 시트: 현재 레벨 효과
  ///
  /// In ko, this message translates to:
  /// **'현재 효과: {effect}'**
  String m_currentEffect(String effect);

  /// 건물 시트: 다음 레벨 효과
  ///
  /// In ko, this message translates to:
  /// **'다음 레벨: {effect}'**
  String m_nextLevel(String effect);

  /// 건물 업그레이드 버튼
  ///
  /// In ko, this message translates to:
  /// **'업그레이드 {cost}'**
  String m_upgrade(String cost);

  /// 건물 최대 레벨 표시
  ///
  /// In ko, this message translates to:
  /// **'🌟 최대 레벨'**
  String get m_maxLevel;

  /// 행성 이름 변경 대화상자 제목
  ///
  /// In ko, this message translates to:
  /// **'행성 이름'**
  String get m_planetName;

  /// 행성 꾸미기 시트 제목
  ///
  /// In ko, this message translates to:
  /// **'🎨 행성 꾸미기'**
  String get m_decorateTitle;

  /// 행성 꾸미기: 고리 스위치
  ///
  /// In ko, this message translates to:
  /// **'행성 고리'**
  String get m_planetRing;

  /// 게임 밖에서 선물 받기 시도 토스트
  ///
  /// In ko, this message translates to:
  /// **'선물은 게임 중에 받을 수 있어요'**
  String get m_giftInGameOnly;

  /// 행성 선물 대화상자 제목
  ///
  /// In ko, this message translates to:
  /// **'🎁 행성 선물'**
  String get m_giftTitle;

  /// 행성 선물 대화상자 본문
  ///
  /// In ko, this message translates to:
  /// **'주민 {count}명이 모은 선물이에요!'**
  String m_giftBody(int count);

  /// 행성 선물 대화상자 닫기 버튼
  ///
  /// In ko, this message translates to:
  /// **'고마워!'**
  String get m_giftThanks;

  /// 내 행성 상단 상태 줄
  ///
  /// In ko, this message translates to:
  /// **'행성 Lv.{level} · 주민 {residents}명 · 건물 {built}/{slots}'**
  String m_planetStatus(int level, int residents, int built, int slots);

  /// 내 행성 영구 보너스 요약
  ///
  /// In ko, this message translates to:
  /// **'영구 보너스 · 수입 +{income}%  광석 +{ore}%  공격 +{attack}%  체력 +{hp}%  쿨타임 -{cooldown}%  오프라인 {offline}%'**
  String m_permBonus(
    int income,
    int ore,
    int attack,
    int hp,
    int cooldown,
    int offline,
  );

  /// 내 행성 조작 안내
  ///
  /// In ko, this message translates to:
  /// **'행성을 좌우로 밀어 돌리고, 칸을 눌러 건물을 지어요'**
  String get m_planetHint;

  /// 행성 선물 받기 버튼
  ///
  /// In ko, this message translates to:
  /// **'🎁 행성 선물 받기'**
  String get m_giftClaim;

  /// 선물까지 남은 시간 버튼
  ///
  /// In ko, this message translates to:
  /// **'🎁 {hours}시간 {minutes}분 후 선물'**
  String m_giftWait(int hours, int minutes);

  /// 행성 레벨업 버튼
  ///
  /// In ko, this message translates to:
  /// **'🌍 행성 Lv.{level} (칸 +2) {cost}'**
  String m_planetLevelUp(int level, String cost);

  /// ship type name (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'스카우트'**
  String get g_shipScoutName;

  /// ship type name (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'인터셉터'**
  String get g_shipInterceptorName;

  /// ship type name (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'포트리스'**
  String get g_shipFortressName;

  /// ship type name (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'프로스펙터'**
  String get g_shipProspectorName;

  /// ship type name (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'팬텀'**
  String get g_shipPhantomName;

  /// ship type name (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'노바 드래곤'**
  String get g_shipNovaName;

  /// ship type name (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'오로라'**
  String get g_shipAuroraName;

  /// ship type short description (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'균형 잡힌 기본 함선'**
  String get g_shipScoutDesc;

  /// ship type short description (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'빠르고 연사가 빠르지만 장갑이 얇아요'**
  String get g_shipInterceptorDesc;

  /// ship type short description (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'느리지만 단단하고 한 방이 세요'**
  String get g_shipFortressDesc;

  /// ship type short description (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'광석 +50%, 아이템을 멀리서 끌어당겨요'**
  String get g_shipProspectorDesc;

  /// ship type short description (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'25% 확률로 2.5배 치명타'**
  String get g_shipPhantomDesc;

  /// ship type short description (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'탄환이 적을 꿰뚫는 프리미엄 전투기'**
  String get g_shipNovaDesc;

  /// ship type short description (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'스스로 고치고 보호막을 두르는 프리미엄 수호선'**
  String get g_shipAuroraDesc;

  /// Nova Dragon unique ability (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'관통탄: 탄환 하나가 적 2기까지 꿰뚫어요'**
  String get g_shipNovaAbility;

  /// Aurora unique ability, two lines (hangar, shop)
  ///
  /// In ko, this message translates to:
  /// **'자가 수리: 3초간 피격이 없으면 초당 체력 3% 회복\n수호막: 8초마다 피격 1회 방어'**
  String get g_shipAuroraAbility;

  /// ship unlock condition; n = sector number
  ///
  /// In ko, this message translates to:
  /// **'섹터 {n} 도달'**
  String g_unlockSector(int n);

  /// ship unlock condition; n = boss kills
  ///
  /// In ko, this message translates to:
  /// **'해적 두목 {n}회 격파'**
  String g_unlockBosses(int n);

  /// ship unlock condition; n = ore count
  ///
  /// In ko, this message translates to:
  /// **'광석 {n}개 수집'**
  String g_unlockOre(int n);

  /// ship skin name (shop)
  ///
  /// In ko, this message translates to:
  /// **'기본 스카우트'**
  String get g_skinDefault;

  /// ship skin name (shop)
  ///
  /// In ko, this message translates to:
  /// **'레드 코멧'**
  String get g_skinCrimson;

  /// ship skin name (shop)
  ///
  /// In ko, this message translates to:
  /// **'민트 초코'**
  String get g_skinMint;

  /// ship skin name (shop)
  ///
  /// In ko, this message translates to:
  /// **'스텔스 블랙'**
  String get g_skinStealth;

  /// ship skin name (shop)
  ///
  /// In ko, this message translates to:
  /// **'네온 핑크'**
  String get g_skinNeon;

  /// ship skin name (shop)
  ///
  /// In ko, this message translates to:
  /// **'무지개 드림'**
  String get g_skinRainbow;

  /// ship skin name (shop)
  ///
  /// In ko, this message translates to:
  /// **'갤럭시'**
  String get g_skinGalaxy;

  /// ship skin name (shop)
  ///
  /// In ko, this message translates to:
  /// **'골드 로열'**
  String get g_skinGold;

  /// captain outfit name (shop)
  ///
  /// In ko, this message translates to:
  /// **'기본 우주복'**
  String get g_outfitDefault;

  /// captain outfit name (shop)
  ///
  /// In ko, this message translates to:
  /// **'냥냥 헬멧'**
  String get g_outfitCat;

  /// captain outfit name (shop)
  ///
  /// In ko, this message translates to:
  /// **'토끼 귀'**
  String get g_outfitBunny;

  /// captain outfit name (shop)
  ///
  /// In ko, this message translates to:
  /// **'외계인 더듬이'**
  String get g_outfitAlien;

  /// captain outfit name (shop)
  ///
  /// In ko, this message translates to:
  /// **'꽃 핀'**
  String get g_outfitFlower;

  /// captain outfit name (shop)
  ///
  /// In ko, this message translates to:
  /// **'함장 모자'**
  String get g_outfitHat;

  /// captain outfit name (shop)
  ///
  /// In ko, this message translates to:
  /// **'은하 왕관'**
  String get g_outfitCrown;

  /// crew role name
  ///
  /// In ko, this message translates to:
  /// **'포수'**
  String get g_crewRoleGunner;

  /// what a crew role boosts (crew list)
  ///
  /// In ko, this message translates to:
  /// **'공격력'**
  String get g_crewEffectGunner;

  /// crew role name
  ///
  /// In ko, this message translates to:
  /// **'기관사'**
  String get g_crewRoleEngineer;

  /// what a crew role boosts (crew list)
  ///
  /// In ko, this message translates to:
  /// **'최대 체력·수리'**
  String get g_crewEffectEngineer;

  /// crew role name
  ///
  /// In ko, this message translates to:
  /// **'조종사'**
  String get g_crewRolePilot;

  /// what a crew role boosts (crew list)
  ///
  /// In ko, this message translates to:
  /// **'속도'**
  String get g_crewEffectPilot;

  /// crew role name
  ///
  /// In ko, this message translates to:
  /// **'상인'**
  String get g_crewRoleTrader;

  /// what a crew role boosts (crew list)
  ///
  /// In ko, this message translates to:
  /// **'크레딧 수입'**
  String get g_crewEffectTrader;

  /// crew role name
  ///
  /// In ko, this message translates to:
  /// **'광부'**
  String get g_crewRoleMiner;

  /// what a crew role boosts (crew list)
  ///
  /// In ko, this message translates to:
  /// **'광석 획득'**
  String get g_crewEffectMiner;

  /// crew role name
  ///
  /// In ko, this message translates to:
  /// **'과학자'**
  String get g_crewRoleScientist;

  /// what a crew role boosts (crew list)
  ///
  /// In ko, this message translates to:
  /// **'스킬 쿨타임 감소'**
  String get g_crewEffectScientist;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'뭉치'**
  String get g_crewName0;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'코코'**
  String get g_crewName1;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'별이'**
  String get g_crewName2;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'두부'**
  String get g_crewName3;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'콩이'**
  String get g_crewName4;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'루루'**
  String get g_crewName5;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'하루'**
  String get g_crewName6;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'포포'**
  String get g_crewName7;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'미미'**
  String get g_crewName8;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'도리'**
  String get g_crewName9;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'몽실'**
  String get g_crewName10;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'나비'**
  String get g_crewName11;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'초코'**
  String get g_crewName12;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'보리'**
  String get g_crewName13;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'구름'**
  String get g_crewName14;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'단비'**
  String get g_crewName15;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'토리'**
  String get g_crewName16;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'해피'**
  String get g_crewName17;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'찹쌀'**
  String get g_crewName18;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'모찌'**
  String get g_crewName19;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'라떼'**
  String get g_crewName20;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'쿠키'**
  String get g_crewName21;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'젤리'**
  String get g_crewName22;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'솜이'**
  String get g_crewName23;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'망고'**
  String get g_crewName24;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'자두'**
  String get g_crewName25;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'호두'**
  String get g_crewName26;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'깜이'**
  String get g_crewName27;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'밤비'**
  String get g_crewName28;

  /// crew member nickname (cute pet-like name), list order matters
  ///
  /// In ko, this message translates to:
  /// **'치즈'**
  String get g_crewName29;

  /// title prefixed to a 4-star legendary crew name
  ///
  /// In ko, this message translates to:
  /// **'은하수호자'**
  String get g_crewLegend0;

  /// title prefixed to a 4-star legendary crew name
  ///
  /// In ko, this message translates to:
  /// **'별의 영웅'**
  String get g_crewLegend1;

  /// title prefixed to a 4-star legendary crew name
  ///
  /// In ko, this message translates to:
  /// **'성운의 현자'**
  String get g_crewLegend2;

  /// title prefixed to a 4-star legendary crew name
  ///
  /// In ko, this message translates to:
  /// **'혜성 기사'**
  String get g_crewLegend3;

  /// title prefixed to a 4-star legendary crew name
  ///
  /// In ko, this message translates to:
  /// **'초신성'**
  String get g_crewLegend4;

  /// legendary crew display name; title = legend title, name = crew name
  ///
  /// In ko, this message translates to:
  /// **'{title} {name}'**
  String g_crewLegendName(String title, String name);

  /// home planet building name
  ///
  /// In ko, this message translates to:
  /// **'주택'**
  String get g_bldHouse;

  /// home planet building effect at its level; n = bonus amount
  ///
  /// In ko, this message translates to:
  /// **'주민 +{n}명 (선물 증가)'**
  String g_bldHouseEffect(int n);

  /// home planet building name
  ///
  /// In ko, this message translates to:
  /// **'우주 농장'**
  String get g_bldFarm;

  /// home planet building effect at its level; n = bonus amount
  ///
  /// In ko, this message translates to:
  /// **'크레딧 수입 +{n}%'**
  String g_bldFarmEffect(int n);

  /// home planet building name
  ///
  /// In ko, this message translates to:
  /// **'광산'**
  String get g_bldMine;

  /// home planet building effect at its level; n = bonus amount
  ///
  /// In ko, this message translates to:
  /// **'광석 획득 +{n}%'**
  String g_bldMineEffect(int n);

  /// home planet building name
  ///
  /// In ko, this message translates to:
  /// **'연구소'**
  String get g_bldLab;

  /// home planet building effect at its level; n = bonus amount
  ///
  /// In ko, this message translates to:
  /// **'스킬 쿨타임 -{n}%'**
  String g_bldLabEffect(int n);

  /// home planet building name
  ///
  /// In ko, this message translates to:
  /// **'방어탑'**
  String get g_bldTower;

  /// home planet building effect at its level; n = bonus amount
  ///
  /// In ko, this message translates to:
  /// **'최대 체력 +{n}%'**
  String g_bldTowerEffect(int n);

  /// home planet building name
  ///
  /// In ko, this message translates to:
  /// **'조선소'**
  String get g_bldShipyard;

  /// home planet building effect at its level; n = bonus amount
  ///
  /// In ko, this message translates to:
  /// **'공격력 +{n}%'**
  String g_bldShipyardEffect(int n);

  /// home planet building name
  ///
  /// In ko, this message translates to:
  /// **'놀이공원'**
  String get g_bldPark;

  /// home planet building effect at its level; n = bonus amount
  ///
  /// In ko, this message translates to:
  /// **'오프라인 수입 +{n}%p'**
  String g_bldParkEffect(int n);

  /// home planet building name
  ///
  /// In ko, this message translates to:
  /// **'선장 동상'**
  String get g_bldStatue;

  /// home planet building effect at its level; n = bonus amount
  ///
  /// In ko, this message translates to:
  /// **'행성 선물 젬 +{n}'**
  String g_bldStatueEffect(int n);

  /// home planet color palette name
  ///
  /// In ko, this message translates to:
  /// **'초록 정원'**
  String get g_homePalette0;

  /// home planet color palette name
  ///
  /// In ko, this message translates to:
  /// **'모래 사막'**
  String get g_homePalette1;

  /// home planet color palette name
  ///
  /// In ko, this message translates to:
  /// **'얼음 왕국'**
  String get g_homePalette2;

  /// home planet color palette name
  ///
  /// In ko, this message translates to:
  /// **'용암 섬'**
  String get g_homePalette3;

  /// home planet color palette name
  ///
  /// In ko, this message translates to:
  /// **'보라 가스'**
  String get g_homePalette4;

  /// home planet color palette name
  ///
  /// In ko, this message translates to:
  /// **'벚꽃'**
  String get g_homePalette5;

  /// home planet color palette name
  ///
  /// In ko, this message translates to:
  /// **'오로라'**
  String get g_homePalette6;

  /// home planet color palette name
  ///
  /// In ko, this message translates to:
  /// **'황금'**
  String get g_homePalette7;

  /// default name of the player home planet (player can rename)
  ///
  /// In ko, this message translates to:
  /// **'나의 작은 별'**
  String get g_homeDefaultName;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'첫 격추'**
  String get g_achFirstBloodTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'해적 1척 격추'**
  String get g_achFirstBloodDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'해적 사냥꾼'**
  String get g_achHunterTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'해적 100척 격추'**
  String get g_achHunterDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'전설의 선장'**
  String get g_achLegendTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'해적 1000척 격추'**
  String get g_achLegendDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'광산왕'**
  String get g_achMinerTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'광석 1000개 수집'**
  String get g_achMinerDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'광석 부자'**
  String get g_achMiner2Title;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'광석 10000개 수집'**
  String get g_achMiner2Desc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'개척자'**
  String get g_achColonistTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'행성 5곳 정착'**
  String get g_achColonistDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'메트로폴리스'**
  String get g_achMetropolisTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'식민지 Lv.5 달성'**
  String get g_achMetropolisDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'건축가'**
  String get g_achBuilderTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'정거장 3개 건설'**
  String get g_achBuilderDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'두목 사냥'**
  String get g_achBoss1Title;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'해적 두목 격파'**
  String get g_achBoss1Desc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'두목 킬러'**
  String get g_achBoss10Title;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'해적 두목 10회 격파'**
  String get g_achBoss10Desc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'탐험가'**
  String get g_achExplorerTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'섹터 3 도달'**
  String get g_achExplorerDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'항해자'**
  String get g_achVoyagerTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'섹터 6 도달'**
  String get g_achVoyagerDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'부자 선장'**
  String get g_achRichTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'크레딧 10000 보유'**
  String get g_achRichDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'든든한 동료'**
  String get g_achCrew6Title;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'승무원 6명 영입'**
  String get g_achCrew6Desc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'전설의 동료'**
  String get g_achCrew3starTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'★3 승무원 영입'**
  String get g_achCrew3starDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'해결사'**
  String get g_achMissionsTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'임무 20개 완료'**
  String get g_achMissionsDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'해파리 박사'**
  String get g_achJellyTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'우주 해파리 10마리 처치'**
  String get g_achJellyDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'패셔니스타'**
  String get g_achFashionTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'꾸미기 아이템 구매'**
  String get g_achFashionDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'새로운 시작'**
  String get g_achAscendTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'은하 명예로 환생'**
  String get g_achAscendDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'든든한 드론'**
  String get g_achDroneTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'전투 드론 장착'**
  String get g_achDroneDesc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'행성 건축가'**
  String get g_achHome5Title;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'내 행성에 건물 5개'**
  String get g_achHome5Desc;

  /// achievement title
  ///
  /// In ko, this message translates to:
  /// **'꿈의 행성'**
  String get g_achHomeMaxTitle;

  /// achievement goal description
  ///
  /// In ko, this message translates to:
  /// **'내 행성 최대 레벨'**
  String get g_achHomeMaxDesc;

  /// daily quest title
  ///
  /// In ko, this message translates to:
  /// **'해적 30척 격추'**
  String get g_dailyKill;

  /// daily quest title
  ///
  /// In ko, this message translates to:
  /// **'광석 300개 수집'**
  String get g_dailyOre;

  /// daily quest title
  ///
  /// In ko, this message translates to:
  /// **'임무 2개 완료'**
  String get g_dailyMission;

  /// daily quest title
  ///
  /// In ko, this message translates to:
  /// **'식민지 2번 성장'**
  String get g_dailyColony;

  /// daily quest title
  ///
  /// In ko, this message translates to:
  /// **'해적 두목 격파'**
  String get g_dailyBoss;

  /// daily quest title
  ///
  /// In ko, this message translates to:
  /// **'파워업 3개 획득'**
  String get g_dailyPower;

  /// daily quest title
  ///
  /// In ko, this message translates to:
  /// **'10분 플레이'**
  String get g_dailyPlay;

  /// daily quest title
  ///
  /// In ko, this message translates to:
  /// **'우주 해파리 3마리 처치'**
  String get g_dailyJelly;

  /// mission board title; n = pirates to destroy
  ///
  /// In ko, this message translates to:
  /// **'해적 {n}척 소탕'**
  String g_missionKill(int n);

  /// mission board title; n = ore to collect
  ///
  /// In ko, this message translates to:
  /// **'광석 {n}개 수집'**
  String g_missionMine(int n);

  /// mission board title; planet = destination planet name (Korean: already has 으로/로 particle attached)
  ///
  /// In ko, this message translates to:
  /// **'{planet} 화물 운송'**
  String g_missionDeliver(String planet);

  /// bounty mission title; name = wanted pirate name
  ///
  /// In ko, this message translates to:
  /// **'현상수배: {name}'**
  String g_missionBounty(String name);

  /// wanted pirate name (bounty missions); proper noun nickname
  ///
  /// In ko, this message translates to:
  /// **'외눈 잭'**
  String get g_bounty0;

  /// wanted pirate name (bounty missions); proper noun nickname
  ///
  /// In ko, this message translates to:
  /// **'번개 몰리'**
  String get g_bounty1;

  /// wanted pirate name (bounty missions); proper noun nickname
  ///
  /// In ko, this message translates to:
  /// **'고철왕 바르크'**
  String get g_bounty2;

  /// wanted pirate name (bounty missions); proper noun nickname
  ///
  /// In ko, this message translates to:
  /// **'붉은 수염 토토'**
  String get g_bounty3;

  /// wanted pirate name (bounty missions); proper noun nickname
  ///
  /// In ko, this message translates to:
  /// **'그림자 레나'**
  String get g_bounty4;

  /// wanted pirate name (bounty missions); proper noun nickname
  ///
  /// In ko, this message translates to:
  /// **'뚱보 포크'**
  String get g_bounty5;

  /// wanted pirate name (bounty missions); proper noun nickname
  ///
  /// In ko, this message translates to:
  /// **'쌍칼 지지'**
  String get g_bounty6;

  /// wanted pirate name (bounty missions); proper noun nickname
  ///
  /// In ko, this message translates to:
  /// **'미친 망치 버드'**
  String get g_bounty7;

  /// wanted pirate name (bounty missions); proper noun nickname
  ///
  /// In ko, this message translates to:
  /// **'은하 여우 루시'**
  String get g_bounty8;

  /// wanted pirate name (bounty missions); proper noun nickname
  ///
  /// In ko, this message translates to:
  /// **'해골 선장 본즈'**
  String get g_bounty9;

  /// story/tutorial objective title (top of HUD)
  ///
  /// In ko, this message translates to:
  /// **'소행성 3개 부수기'**
  String get g_storyAsteroidsTitle;

  /// story dialogue line spoken by advisor Mina or the captain
  ///
  /// In ko, this message translates to:
  /// **'선장님! 먼저 소행성을 부숴서 광석을 모아봐요.'**
  String get g_storyAsteroidsLine0;

  /// story dialogue line spoken by advisor Mina or the captain
  ///
  /// In ko, this message translates to:
  /// **'조이스틱으로 이동하고, 발사 버튼으로 쏘면 돼요!'**
  String get g_storyAsteroidsLine1;

  /// story/tutorial objective title (top of HUD)
  ///
  /// In ko, this message translates to:
  /// **'해적 3척 격추'**
  String get g_storyKillsTitle;

  /// story dialogue line spoken by advisor Mina or the captain
  ///
  /// In ko, this message translates to:
  /// **'레이더에 해적이 잡혀요! 빨간 화살표 방향이에요.'**
  String get g_storyKillsLine0;

  /// story dialogue line spoken by advisor Mina or the captain
  ///
  /// In ko, this message translates to:
  /// **'해적 따위, 내 함선 앞에선 고철이지!'**
  String get g_storyKillsLine1;

  /// story/tutorial objective title (top of HUD)
  ///
  /// In ko, this message translates to:
  /// **'테라노바에 정착하기'**
  String get g_storyColoniesTitle;

  /// story dialogue line spoken by advisor Mina or the captain
  ///
  /// In ko, this message translates to:
  /// **'근처 초록 행성 테라노바에 정착해봐요. 가까이 가면 정착 버튼이 떠요.'**
  String get g_storyColoniesLine0;

  /// story dialogue line spoken by advisor Mina or the captain
  ///
  /// In ko, this message translates to:
  /// **'식민지는 가만히 있어도 크레딧을 벌어줘요!'**
  String get g_storyColoniesLine1;

  /// story/tutorial objective title (top of HUD)
  ///
  /// In ko, this message translates to:
  /// **'정거장에서 함선 개조'**
  String get g_storyShipLevelsTitle;

  /// story dialogue line spoken by advisor Mina or the captain
  ///
  /// In ko, this message translates to:
  /// **'헤이븐 기지로 돌아가서 함선을 개조해봐요. 정거장 근처에선 수리도 돼요.'**
  String get g_storyShipLevelsLine0;

  /// story/tutorial objective title (top of HUD)
  ///
  /// In ko, this message translates to:
  /// **'승무원 1명 영입'**
  String get g_storyCrewTitle;

  /// story dialogue line spoken by advisor Mina or the captain
  ///
  /// In ko, this message translates to:
  /// **'혼자는 외롭잖아요? 정거장 메뉴의 승무원 탭에서 동료를 영입해봐요!'**
  String get g_storyCrewLine0;

  /// story/tutorial objective title (top of HUD)
  ///
  /// In ko, this message translates to:
  /// **'임무 1개 완료'**
  String get g_storyMissionsTitle;

  /// story dialogue line spoken by advisor Mina or the captain
  ///
  /// In ko, this message translates to:
  /// **'정거장 임무 게시판에서 의뢰를 받아보세요. 보상이 짭짤해요.'**
  String get g_storyMissionsLine0;

  /// story/tutorial objective title (top of HUD)
  ///
  /// In ko, this message translates to:
  /// **'새 정거장 건설'**
  String get g_storyStationsTitle;

  /// story dialogue line spoken by advisor Mina or the captain
  ///
  /// In ko, this message translates to:
  /// **'이제 영역을 넓힐 때예요! 행성에서 떨어진 빈 우주에 정거장을 지어봐요.'**
  String get g_storyStationsLine0;

  /// story/tutorial objective title (top of HUD)
  ///
  /// In ko, this message translates to:
  /// **'항성계 발전도 100%'**
  String get g_storyDevPercentTitle;

  /// story dialogue line spoken by advisor Mina or the captain
  ///
  /// In ko, this message translates to:
  /// **'모든 행성을 Lv.3까지 키우면 다음 항성계가 열려요. 오른쪽 위 항성계 버튼에서 확인해요!'**
  String get g_storyDevPercentLine0;

  /// story/tutorial objective title (top of HUD)
  ///
  /// In ko, this message translates to:
  /// **'워프 게이트로 다음 항성계 이동'**
  String get g_storySectorTitle;

  /// story dialogue line spoken by advisor Mina or the captain
  ///
  /// In ko, this message translates to:
  /// **'워프 게이트가 열렸어요! 미니맵의 보라색 게이트로 가봐요.'**
  String get g_storySectorLine0;

  /// story dialogue line spoken by advisor Mina or the captain
  ///
  /// In ko, this message translates to:
  /// **'새로운 우주가 기다리고 있어!'**
  String get g_storySectorLine1;

  /// endless story objective; n = star system number
  ///
  /// In ko, this message translates to:
  /// **'항성계 {n} 발전도 100%'**
  String g_storyDevNTitle(int n);

  /// advisor dialogue for endless development objective
  ///
  /// In ko, this message translates to:
  /// **'새 항성계의 행성들을 모두 Lv.3까지 키워요!'**
  String get g_storyDevNLine;

  /// star system with its number
  ///
  /// In ko, this message translates to:
  /// **'항성계 {n}'**
  String g_systemN(int n);

  /// endless story objective; system = "System N" (Korean: with 으로/로 particle attached)
  ///
  /// In ko, this message translates to:
  /// **'{system} 워프'**
  String g_storyWarpNTitle(String system);

  /// advisor dialogue for endless warp objective
  ///
  /// In ko, this message translates to:
  /// **'게이트가 열렸어요. 더 깊은 우주로 가볼까요?'**
  String get g_storyWarpNLine;

  /// power-up name (HUD)
  ///
  /// In ko, this message translates to:
  /// **'연사'**
  String get g_powerUpRapid;

  /// power-up name (HUD)
  ///
  /// In ko, this message translates to:
  /// **'실드'**
  String get g_powerUpShield;

  /// power-up name (HUD)
  ///
  /// In ko, this message translates to:
  /// **'자석'**
  String get g_powerUpMagnet;

  /// power-up name (HUD)
  ///
  /// In ko, this message translates to:
  /// **'크레딧 2배'**
  String get g_powerUpDoubleCredits;

  /// planet type label
  ///
  /// In ko, this message translates to:
  /// **'정원 행성'**
  String get g_planetKindGarden;

  /// planet type label
  ///
  /// In ko, this message translates to:
  /// **'사막 행성'**
  String get g_planetKindDesert;

  /// planet type label
  ///
  /// In ko, this message translates to:
  /// **'얼음 행성'**
  String get g_planetKindIce;

  /// planet type label
  ///
  /// In ko, this message translates to:
  /// **'용암 행성'**
  String get g_planetKindLava;

  /// planet type label
  ///
  /// In ko, this message translates to:
  /// **'가스 행성'**
  String get g_planetKindGas;

  /// colony building name
  ///
  /// In ko, this message translates to:
  /// **'방어포탑'**
  String get g_colonyBldTurret;

  /// colony building name
  ///
  /// In ko, this message translates to:
  /// **'채굴 시설'**
  String get g_colonyBldMine;

  /// colony building name
  ///
  /// In ko, this message translates to:
  /// **'교역소'**
  String get g_colonyBldTrade;

  /// colony building name
  ///
  /// In ko, this message translates to:
  /// **'수리 도크'**
  String get g_colonyBldDock;

  /// colony building name
  ///
  /// In ko, this message translates to:
  /// **'방어막 발생기'**
  String get g_colonyBldShieldGen;

  /// colony building description
  ///
  /// In ko, this message translates to:
  /// **'식민지 근처 해적을 자동으로 요격해요. 습격 방어에 필수!'**
  String get g_colonyBldBlurbTurret;

  /// colony building description
  ///
  /// In ko, this message translates to:
  /// **'광석을 캐서 매초 💎를 보내줘요.'**
  String get g_colonyBldBlurbMine;

  /// colony building description
  ///
  /// In ko, this message translates to:
  /// **'이 식민지의 크레딧 수입을 25%씩 늘려요.'**
  String get g_colonyBldBlurbTrade;

  /// colony building description
  ///
  /// In ko, this message translates to:
  /// **'근처에 있으면 함선 체력을 회복해요.'**
  String get g_colonyBldBlurbDock;

  /// colony building description
  ///
  /// In ko, this message translates to:
  /// **'방어막 용량과 충전 속도를 늘려요.'**
  String get g_colonyBldBlurbShieldGen;

  /// station role name
  ///
  /// In ko, this message translates to:
  /// **'본거지'**
  String get g_stationRoleHome;

  /// station role name
  ///
  /// In ko, this message translates to:
  /// **'방어 기지'**
  String get g_stationRoleDefense;

  /// station role name
  ///
  /// In ko, this message translates to:
  /// **'수리 기지'**
  String get g_stationRoleRepair;

  /// station role name
  ///
  /// In ko, this message translates to:
  /// **'보급 기지'**
  String get g_stationRoleSupport;

  /// station role description
  ///
  /// In ko, this message translates to:
  /// **'레이저 포대와 안전 구역'**
  String get g_stationRoleBlurbHome;

  /// station role description
  ///
  /// In ko, this message translates to:
  /// **'강한 포탑 · 내구도 2배 · 주변 적 탄환 차단'**
  String get g_stationRoleBlurbDefense;

  /// station role description
  ///
  /// In ko, this message translates to:
  /// **'넓은 범위 빠른 수리 · 재출격 비용 10% · 근처 식민지 방어막 충전 2배'**
  String get g_stationRoleBlurbRepair;

  /// station role description
  ///
  /// In ko, this message translates to:
  /// **'근처 식민지 생산 +25% (거주구역 레벨마다 +5%)'**
  String get g_stationRoleBlurbSupport;

  /// event title; planet = attacked colony name
  ///
  /// In ko, this message translates to:
  /// **'{planet} 습격'**
  String g_eventRaid(String planet);

  /// event title
  ///
  /// In ko, this message translates to:
  /// **'유성우'**
  String get g_eventMeteor;

  /// event title
  ///
  /// In ko, this message translates to:
  /// **'떠돌이 상인'**
  String get g_eventMerchant;

  /// event title
  ///
  /// In ko, this message translates to:
  /// **'보급 캡슐'**
  String get g_eventSupply;

  /// in-app product title
  ///
  /// In ko, this message translates to:
  /// **'젬 한 줌'**
  String get g_productGems100Title;

  /// in-app product title
  ///
  /// In ko, this message translates to:
  /// **'젬 주머니'**
  String get g_productGems550Title;

  /// in-app product title
  ///
  /// In ko, this message translates to:
  /// **'젬 상자'**
  String get g_productGems1200Title;

  /// in-app product title
  ///
  /// In ko, this message translates to:
  /// **'스타터 팩'**
  String get g_productStarterTitle;

  /// in-app product title
  ///
  /// In ko, this message translates to:
  /// **'함대 사령관 패스'**
  String get g_productPassTitle;

  /// in-app product description
  ///
  /// In ko, this message translates to:
  /// **'⭐550 (+10% 보너스)'**
  String get g_productGems550Desc;

  /// in-app product description
  ///
  /// In ko, this message translates to:
  /// **'⭐1200 (+20% 보너스)'**
  String get g_productGems1200Desc;

  /// in-app product description
  ///
  /// In ko, this message translates to:
  /// **'⭐300 + 전용 스킨 \"갤럭시\" + ★3 승무원 (1회 한정)'**
  String get g_productStarterDesc;

  /// in-app product description
  ///
  /// In ko, this message translates to:
  /// **'크레딧 수입 +25%, 오프라인 수입 8시간, 광고 없이 보상, 전용 스킨 \"골드 로열\"'**
  String get g_productPassDesc;

  /// dev-build purchase confirm dialog title; product = product title
  ///
  /// In ko, this message translates to:
  /// **'[테스트 결제] {product}'**
  String g_testPurchaseTitle(String product);

  /// dev-build purchase confirm dialog body; desc = product description, price = formatted price
  ///
  /// In ko, this message translates to:
  /// **'실제 결제는 일어나지 않아요.\n{desc}\n가격: {price}'**
  String g_testPurchaseBody(String desc, String price);

  /// dev-build rewarded ad confirm dialog title
  ///
  /// In ko, this message translates to:
  /// **'[테스트 광고]'**
  String get g_testAdTitle;

  /// dev-build rewarded ad confirm dialog body
  ///
  /// In ko, this message translates to:
  /// **'광고를 끝까지 본 것으로 처리할까요?'**
  String get g_testAdBody;

  /// web demo notice dialog title
  ///
  /// In ko, this message translates to:
  /// **'웹 데모'**
  String get g_webDemoTitle;

  /// web demo notice dialog body
  ///
  /// In ko, this message translates to:
  /// **'구매와 광고 보상은 모바일 앱에서 이용할 수 있어요.'**
  String get g_webDemoBody;

  /// Android notification channel name
  ///
  /// In ko, this message translates to:
  /// **'복귀 알림'**
  String get g_notifChannelName;

  /// Android notification channel description
  ///
  /// In ko, this message translates to:
  /// **'식민지 수입, 출석 보상 알림'**
  String get g_notifChannelDesc;

  /// push notification title when offline income storage is full
  ///
  /// In ko, this message translates to:
  /// **'식민지 창고가 가득 찼어요!'**
  String get g_notifStorageTitle;

  /// push notification body (storage full)
  ///
  /// In ko, this message translates to:
  /// **'선장님, 쌓인 크레딧을 받으러 오세요. 더 늦으면 수입이 멈춰요.'**
  String get g_notifStorageBody;

  /// next-day push notification title
  ///
  /// In ko, this message translates to:
  /// **'해적들이 다시 날뛰고 있어요!'**
  String get g_notifPiratesTitle;

  /// next-day push notification body
  ///
  /// In ko, this message translates to:
  /// **'오늘의 출석 보상과 일일 퀘스트가 기다리고 있어요.'**
  String get g_notifPiratesBody;

  /// ship upgrade name (station upgrade list)
  ///
  /// In ko, this message translates to:
  /// **'무기'**
  String get g_upgradeWeapon;

  /// ship upgrade name (station upgrade list)
  ///
  /// In ko, this message translates to:
  /// **'장갑'**
  String get g_upgradeHull;

  /// ship upgrade name (station upgrade list)
  ///
  /// In ko, this message translates to:
  /// **'엔진'**
  String get g_upgradeEngine;

  /// ship upgrade name (station upgrade list)
  ///
  /// In ko, this message translates to:
  /// **'유도 미사일'**
  String get g_upgradeMissile;

  /// ship upgrade name (station upgrade list)
  ///
  /// In ko, this message translates to:
  /// **'에너지 실드'**
  String get g_upgradeShield;

  /// ship upgrade name (station upgrade list)
  ///
  /// In ko, this message translates to:
  /// **'전투 드론'**
  String get g_upgradeDrone;

  /// ship upgrade name (station upgrade list)
  ///
  /// In ko, this message translates to:
  /// **'자석'**
  String get g_upgradeMagnet;

  /// name of star system/sector 1 (proper noun)
  ///
  /// In ko, this message translates to:
  /// **'알파 성역'**
  String get g_sector0;

  /// name of star system/sector 2 (proper noun)
  ///
  /// In ko, this message translates to:
  /// **'베타 성운'**
  String get g_sector1;

  /// name of star system/sector 3 (proper noun)
  ///
  /// In ko, this message translates to:
  /// **'감마 협곡'**
  String get g_sector2;

  /// name of star system/sector 4 (proper noun)
  ///
  /// In ko, this message translates to:
  /// **'델타 해적지대'**
  String get g_sector3;

  /// name of star system/sector 5 (proper noun)
  ///
  /// In ko, this message translates to:
  /// **'엡실론 심연'**
  String get g_sector4;

  /// name of star system/sector 6 (proper noun)
  ///
  /// In ko, this message translates to:
  /// **'제타 얼음벨트'**
  String get g_sector5;

  /// name of star system/sector 7 (proper noun)
  ///
  /// In ko, this message translates to:
  /// **'에타 불꽃성단'**
  String get g_sector6;

  /// name of star system/sector 8 (proper noun)
  ///
  /// In ko, this message translates to:
  /// **'세타 유령항로'**
  String get g_sector7;

  /// name of star system/sector 9 (proper noun)
  ///
  /// In ko, this message translates to:
  /// **'이오타 왕관성운'**
  String get g_sector8;

  /// name of star system/sector 10 (proper noun)
  ///
  /// In ko, this message translates to:
  /// **'카파 블랙홀'**
  String get g_sector9;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'아쿠아리스'**
  String get g_planet0;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'루비아'**
  String get g_planet1;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'프로스타'**
  String get g_planet2;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'볼카노'**
  String get g_planet3;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'젤리오'**
  String get g_planet4;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'솔라리스'**
  String get g_planet5;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'모모별'**
  String get g_planet6;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'네뷸라'**
  String get g_planet7;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'카시오페'**
  String get g_planet8;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'오로라'**
  String get g_planet9;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'두리안'**
  String get g_planet10;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'시나몬'**
  String get g_planet11;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'마시멜로'**
  String get g_planet12;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'팝콘별'**
  String get g_planet13;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'라벤더'**
  String get g_planet14;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'에메랄디아'**
  String get g_planet15;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'크림슨'**
  String get g_planet16;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'폴라리스'**
  String get g_planet17;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'베가'**
  String get g_planet18;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'리겔'**
  String get g_planet19;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'미라'**
  String get g_planet20;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'토파즈'**
  String get g_planet21;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'코발트'**
  String get g_planet22;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'사파이어'**
  String get g_planet23;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'오닉스'**
  String get g_planet24;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'페리도트'**
  String get g_planet25;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'민트별'**
  String get g_planet26;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'바닐라'**
  String get g_planet27;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'캐러멜'**
  String get g_planet28;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'피스타치오'**
  String get g_planet29;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'블루베리'**
  String get g_planet30;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'레몬별'**
  String get g_planet31;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'체리'**
  String get g_planet32;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'멜론'**
  String get g_planet33;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'키위'**
  String get g_planet34;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'망고별'**
  String get g_planet35;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'유자'**
  String get g_planet36;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'자몽'**
  String get g_planet37;

  /// random planet name (proper noun); list order matters for world generation
  ///
  /// In ko, this message translates to:
  /// **'호박별'**
  String get g_planet38;

  /// name of the first (home) planet; proper noun
  ///
  /// In ko, this message translates to:
  /// **'테라노바'**
  String get g_planetTerraNova;

  /// name for sectors beyond the named list; n = sector number
  ///
  /// In ko, this message translates to:
  /// **'미지의 섹터 {n}'**
  String g_unknownSector(int n);

  /// name of the home station in the first sector (proper noun)
  ///
  /// In ko, this message translates to:
  /// **'헤이븐 기지'**
  String get g_stationHaven;

  /// home station name in later sectors; sector = sector name
  ///
  /// In ko, this message translates to:
  /// **'{sector} 전진기지'**
  String g_stationOutpost(String sector);

  /// name of a newly built station; role = station role, n = station number
  ///
  /// In ko, this message translates to:
  /// **'{role} {n}호'**
  String g_stationNumbered(String role, int n);

  /// advisor greeting at new game
  ///
  /// In ko, this message translates to:
  /// **'선장님, 환영합니다! 저는 부관 미나예요.'**
  String get g_dlgWelcome;

  /// advisor line after warping
  ///
  /// In ko, this message translates to:
  /// **'이전 섹터의 운송·현상수배 임무는 취소됐어요.'**
  String get g_dlgMissionsCancelled;

  /// floating text when home base is disabled
  ///
  /// In ko, this message translates to:
  /// **'기능 정지!'**
  String get g_floatDisabled;

  /// floating text when home base reboots
  ///
  /// In ko, this message translates to:
  /// **'재가동!'**
  String get g_floatRebooted;

  /// advisor line
  ///
  /// In ko, this message translates to:
  /// **'본거지 재가동! 내구도 30%로 복구됐어요.'**
  String get g_dlgBaseRebooted;

  /// captain line after upgrade
  ///
  /// In ko, this message translates to:
  /// **'무기 강화! 해적들 각오해라!'**
  String get g_dlgUpWeapon;

  /// captain line after upgrade
  ///
  /// In ko, this message translates to:
  /// **'장갑 강화! 이제 좀 든든하군.'**
  String get g_dlgUpHull;

  /// captain line after upgrade
  ///
  /// In ko, this message translates to:
  /// **'엔진 강화! 더 빠르게!'**
  String get g_dlgUpEngine;

  /// captain line after first missile upgrade
  ///
  /// In ko, this message translates to:
  /// **'유도 미사일 장착! (Q)'**
  String get g_dlgMissileNew;

  /// captain line after upgrade
  ///
  /// In ko, this message translates to:
  /// **'미사일 강화!'**
  String get g_dlgMissileUp;

  /// captain line after first shield upgrade
  ///
  /// In ko, this message translates to:
  /// **'에너지 실드 장착! (F)'**
  String get g_dlgShieldNew;

  /// captain line after upgrade
  ///
  /// In ko, this message translates to:
  /// **'실드 강화!'**
  String get g_dlgShieldUp;

  /// captain line after first drone upgrade
  ///
  /// In ko, this message translates to:
  /// **'전투 드론 출격! 든든한 친구가 생겼다.'**
  String get g_dlgDroneNew;

  /// captain line after upgrade
  ///
  /// In ko, this message translates to:
  /// **'드론 강화!'**
  String get g_dlgDroneUp;

  /// captain line after upgrade
  ///
  /// In ko, this message translates to:
  /// **'자석 강화! 크레딧이 알아서 붙는다!'**
  String get g_dlgUpMagnet;

  /// captain line after respawn
  ///
  /// In ko, this message translates to:
  /// **'아직 끝나지 않았다!'**
  String get g_dlgNotOver;

  /// floating text when shield blocks a hit
  ///
  /// In ko, this message translates to:
  /// **'막음!'**
  String get g_floatBlocked;

  /// floating text when Aurora guard blocks a hit
  ///
  /// In ko, this message translates to:
  /// **'수호막!'**
  String get g_floatGuard;

  /// sector boss defeat line
  ///
  /// In ko, this message translates to:
  /// **'으아악! 이 섹터는… 네 것이다…'**
  String get g_pirateBossLose;

  /// boss defeat line
  ///
  /// In ko, this message translates to:
  /// **'으아악! 기억해 두겠다, 선장!'**
  String get g_pirateBossFlee;

  /// advisor line
  ///
  /// In ko, this message translates to:
  /// **'보급 캡슐 회수 완료!'**
  String get g_dlgSupplyCollected;

  /// cat merchant farewell (cat-like speech)
  ///
  /// In ko, this message translates to:
  /// **'그럼 다음에 또 봐요~ 냥!'**
  String get g_merchantBye;

  /// pirate line during a raid
  ///
  /// In ko, this message translates to:
  /// **'이 식민지는 이제 우리 거다! 크하하!'**
  String get g_pirateRaidTaunt;

  /// advisor line for meteor event
  ///
  /// In ko, this message translates to:
  /// **'유성우 발견! 크리스탈이 잔뜩 섞여 있어요. 광석 대박 기회!'**
  String get g_dlgMeteor;

  /// cat merchant greeting (cat-like speech)
  ///
  /// In ko, this message translates to:
  /// **'떠돌이 상인 냥냥이 왔어요~ 좋은 물건 많다냥!'**
  String get g_merchantHello;

  /// advisor line for supply event
  ///
  /// In ko, this message translates to:
  /// **'젬이 든 보급 캡슐 신호가 잡혔어요! 해적이 지키고 있으니 조심하세요.'**
  String get g_dlgSupplySignal;

  /// advisor warning
  ///
  /// In ko, this message translates to:
  /// **'경고! 섹터 두목 함선이 접근 중입니다!'**
  String get g_dlgBossWarning;

  /// returning boss line
  ///
  /// In ko, this message translates to:
  /// **'복수하러 왔다! 각오해라!'**
  String get g_pirateRevenge;

  /// floating text when a colony shield breaks (after 🛡)
  ///
  /// In ko, this message translates to:
  /// **'파괴!'**
  String get g_floatShieldBroken;

  /// floating text when a colony shield recovers (after 🛡)
  ///
  /// In ko, this message translates to:
  /// **'재가동'**
  String get g_floatShieldBack;

  /// floating text when a story objective is done (followed by rewards)
  ///
  /// In ko, this message translates to:
  /// **'목표 달성!'**
  String get g_floatGoalDone;

  /// advisor line on entering a sector; sector = sector name
  ///
  /// In ko, this message translates to:
  /// **'{sector}에 도착했어요!'**
  String g_dlgArrived(String sector);

  /// appended after arrival line for a new sector
  ///
  /// In ko, this message translates to:
  /// **'새로운 개척지예요.'**
  String get g_dlgNewFrontier;

  /// advisor line; station = station name, level = new level
  ///
  /// In ko, this message translates to:
  /// **'{station} 강화 Lv.{level}! 레이저가 더 세졌어요.'**
  String g_dlgBaseUpgraded(String station, int level);

  /// advisor alert; sec = seconds
  ///
  /// In ko, this message translates to:
  /// **'본거지 기능 정지! {sec}초간 보호가 꺼져요!'**
  String g_dlgBaseDisabled(int sec);

  /// captain line on colonizing; planet = planet name
  ///
  /// In ko, this message translates to:
  /// **'{planet}에 깃발을 꽂았다! 정착 완료!'**
  String g_dlgSettled(String planet);

  /// advisor line; station = station name, blurb = role description
  ///
  /// In ko, this message translates to:
  /// **'{station} 건설 완료! {blurb}'**
  String g_dlgStationBuilt(String station, String blurb);

  /// advisor line; station name and new habitat level
  ///
  /// In ko, this message translates to:
  /// **'{station} 거주구역 Lv.{level}!'**
  String g_dlgHabitatUp(String station, int level);

  /// advisor line; station name and new turret level
  ///
  /// In ko, this message translates to:
  /// **'{station} 방어포탑 Lv.{level}!'**
  String g_dlgTurretUp(String station, int level);

  /// captain line on changing ship; ship = ship name (Korean: 으로/로 particle attached)
  ///
  /// In ko, this message translates to:
  /// **'{ship} 갈아탔다! 느낌 좋은데?'**
  String g_dlgShipSwitched(String ship);

  /// advisor line; n = ore count, credits = earned
  ///
  /// In ko, this message translates to:
  /// **'광석 {n}개를 💰{credits}에 팔았어요.'**
  String g_dlgOreSold(int n, int credits);

  /// advisor line; stars = ★ rating, role = crew role, name = crew name (Korean: 이/가 particle attached)
  ///
  /// In ko, this message translates to:
  /// **'{stars} {role} {name} 합류했어요!'**
  String g_dlgCrewJoined(String stars, String role, String name);

  /// advisor line; crew name and new level
  ///
  /// In ko, this message translates to:
  /// **'{name} Lv.{level}! 실력이 늘었어요.'**
  String g_dlgCrewLevel(String name, int level);

  /// advisor line; mission = mission title
  ///
  /// In ko, this message translates to:
  /// **'화물을 실었어요! {mission}'**
  String g_dlgCargoLoaded(String mission);

  /// wanted pirate taunt; name = pirate name (Korean: 을/를 particle attached)
  ///
  /// In ko, this message translates to:
  /// **'{name} 잡겠다고? 어디 한번 와봐라!'**
  String g_dlgBountyTaunt(String name);

  /// floating text on mission complete (followed by reward)
  ///
  /// In ko, this message translates to:
  /// **'임무 완료!'**
  String get g_floatMissionDone;

  /// advisor line (followed by rewards); mission = mission title
  ///
  /// In ko, this message translates to:
  /// **'임무 완료: {mission}!'**
  String g_dlgMissionDone(String mission);

  /// advisor line after respawn; credits = repair cost
  ///
  /// In ko, this message translates to:
  /// **'선장님 무사하시군요! 수리비로 💰{credits} 썼어요.'**
  String g_dlgRepairCost(int credits);

  /// advisor line; sector = sector name
  ///
  /// In ko, this message translates to:
  /// **'{sector} 발전 완료! 다음 항성계로 가는 워프 게이트가 열렸어요.'**
  String g_dlgSectorDeveloped(String sector);

  /// floating damage text on a critical hit; dmg = damage
  ///
  /// In ko, this message translates to:
  /// **'치명타! {dmg}'**
  String g_floatCrit(int dmg);

  /// advisor alert; station name (Korean: 이/가 particle attached)
  ///
  /// In ko, this message translates to:
  /// **'{station} 파괴됐어요! 방어포탑이 필요해요!'**
  String g_dlgStationDestroyed(String station);

  /// advisor line; credits = reward
  ///
  /// In ko, this message translates to:
  /// **'섹터 두목 격파! 보상 💰{credits}'**
  String g_dlgBossDefeated(int credits);

  /// captain line; name = wanted pirate name
  ///
  /// In ko, this message translates to:
  /// **'현상수배범 {name} 체포 완료!'**
  String g_dlgBountyCaught(String name);

  /// advisor line after a raid; planet name, credits reward
  ///
  /// In ko, this message translates to:
  /// **'{planet} 방어 성공! 주민들이 감사의 뜻으로 💰{credits} ⭐2를 보냈어요.'**
  String g_dlgRaidDefended(String planet, int credits);

  /// advisor line; planet name (Korean: 이/가 attached), level = "Lv.N" (Korean: 으로/로 attached)
  ///
  /// In ko, this message translates to:
  /// **'{planet} 약탈당해 {level} 떨어졌어요… 😢'**
  String g_dlgRaidLooted(String planet, String level);

  /// advisor line; planet name (Korean: 을/를 attached)
  ///
  /// In ko, this message translates to:
  /// **'해적들이 {planet} 약탈하고 떠났어요.'**
  String g_dlgRaidLeft(String planet);

  /// advisor alert; planet name (Korean: 을/를 attached)
  ///
  /// In ko, this message translates to:
  /// **'긴급! 해적이 {planet} 습격하고 있어요! 생산이 멈췄어요!'**
  String g_dlgRaidAlert(String planet);

  /// sector boss arrival line; sector = sector name
  ///
  /// In ko, this message translates to:
  /// **'{sector}의 주인은 나다! 덤벼라, 꼬마 선장!'**
  String g_pirateBossArrive(String sector);

  /// advisor line on loading a save; goal = current objective
  ///
  /// In ko, this message translates to:
  /// **'다시 오신 걸 환영해요, 선장님! 현재 목표: {goal}'**
  String g_dlgWelcomeBack(String goal);

  /// pirate line when the player is defeated
  ///
  /// In ko, this message translates to:
  /// **'크하하! 별것 아니군!'**
  String get g_pirateWin0;

  /// pirate line when the player is defeated
  ///
  /// In ko, this message translates to:
  /// **'다음엔 더 강해져서 와라, 꼬마!'**
  String get g_pirateWin1;

  /// pirate line when the player is defeated
  ///
  /// In ko, this message translates to:
  /// **'네 함선은 고철이 됐다!'**
  String get g_pirateWin2;

  /// boss enraged line (calls reinforcements)
  ///
  /// In ko, this message translates to:
  /// **'얘들아, 나와라! 본때를 보여줘!'**
  String get g_pirateRage0;

  /// boss enraged line (calls reinforcements)
  ///
  /// In ko, this message translates to:
  /// **'이제부터 진짜다!'**
  String get g_pirateRage1;

  /// boss enraged line (calls reinforcements)
  ///
  /// In ko, this message translates to:
  /// **'화나게 했겠다?!'**
  String get g_pirateRage2;

  /// captain line after shooting a pirate
  ///
  /// In ko, this message translates to:
  /// **'한 놈 처리!'**
  String get g_captainKill0;

  /// captain line after shooting a pirate
  ///
  /// In ko, this message translates to:
  /// **'어딜 도망가!'**
  String get g_captainKill1;

  /// captain line after shooting a pirate
  ///
  /// In ko, this message translates to:
  /// **'이 구역은 내 거야!'**
  String get g_captainKill2;

  /// captain line after shooting a pirate
  ///
  /// In ko, this message translates to:
  /// **'다음!'**
  String get g_captainKill3;

  /// pirate line when a pirate wave appears
  ///
  /// In ko, this message translates to:
  /// **'크하하! 짐 내려놔!'**
  String get g_pirateAmbush0;

  /// pirate line when a pirate wave appears
  ///
  /// In ko, this message translates to:
  /// **'여긴 우리 해적단 구역이다!'**
  String get g_pirateAmbush1;

  /// pirate line when a pirate wave appears
  ///
  /// In ko, this message translates to:
  /// **'그 반짝이는 크레딧 내놔!'**
  String get g_pirateAmbush2;

  /// pirate line when a pirate wave appears
  ///
  /// In ko, this message translates to:
  /// **'오늘 운이 나쁘구나, 꼬마!'**
  String get g_pirateAmbush3;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'id',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return L10nDe();
    case 'en':
      return L10nEn();
    case 'es':
      return L10nEs();
    case 'fr':
      return L10nFr();
    case 'id':
      return L10nId();
    case 'ja':
      return L10nJa();
    case 'ko':
      return L10nKo();
    case 'pt':
      return L10nPt();
    case 'ru':
      return L10nRu();
    case 'zh':
      return L10nZh();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
