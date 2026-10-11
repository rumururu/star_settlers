// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class L10nId extends L10n {
  L10nId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Star Settlers';

  @override
  String get languageName => 'Bahasa Indonesia';

  @override
  String get u_tabShip => 'Kapal';

  @override
  String get u_tabStation => 'Stasiun';

  @override
  String get u_tabCrew => 'Kru';

  @override
  String get u_tabMission => 'Misi';

  @override
  String get u_tabMarket => 'Pasar';

  @override
  String u_upWeapon(int dmg) {
    return 'Serangan $dmg · Lv.3 ganda · Lv.6 tripel';
  }

  @override
  String u_upHull(int hp) {
    return 'HP maks $hp';
  }

  @override
  String u_upEngine(int speed) {
    return 'Kecepatan maks $speed';
  }

  @override
  String get u_upMissileIntro => 'Rudal pelacak (tombol Q / 🚀)';

  @override
  String u_upMissile(int count, String cooldown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rudal',
    );
    return '$_temp0 · jeda ${cooldown}d';
  }

  @override
  String get u_upShieldIntro =>
      'Perisai yang menahan semua serangan (tombol F / 🛡)';

  @override
  String u_upShield(String duration, String cooldown) {
    return '${duration}d · jeda ${cooldown}d';
  }

  @override
  String get u_upDroneIntro =>
      'Mengitarimu, menembak otomatis dan menarik item';

  @override
  String u_upDrone(int dmg, String interval) {
    return 'Serangan $dmg · tembak tiap ${interval}d';
  }

  @override
  String u_upMagnet(int range, String power) {
    return 'Menarik kredit & bijih · jangkauan $range · daya x$power';
  }

  @override
  String get u_equip => 'Pasang';

  @override
  String get u_hangarSection => '🛸 Hanggar';

  @override
  String get u_viewLarge => 'Lihat';

  @override
  String get u_hp => 'HP';

  @override
  String get u_speed => 'Kecepatan';

  @override
  String get u_attack => 'Serangan';

  @override
  String get u_fireRate => 'Laju tembak';

  @override
  String get u_ore => 'Bijih';

  @override
  String get u_crit => 'Kritis';

  @override
  String get u_boarded => 'Dinaiki';

  @override
  String get u_board => 'Naiki';

  @override
  String get u_boardNow => 'Naiki kapal';

  @override
  String get u_gemsOnly => 'Hanya dengan permata';

  @override
  String u_unlockOrGems(String condition) {
    return 'Buka: $condition atau permata';
  }

  @override
  String u_unlock(String condition) {
    return 'Buka: $condition';
  }

  @override
  String u_durability(int hp, int max) {
    return 'Lambung $hp / $max';
  }

  @override
  String get u_habitat => 'Hunian';

  @override
  String u_habitatDesc(String rate, int hp) {
    return 'Pendapatan 💰$rate/d · Lambung $hp';
  }

  @override
  String get u_turret => 'Menara Pertahanan';

  @override
  String get u_turretIntro => 'Menembak bajak laut secara otomatis';

  @override
  String u_turretDesc(int dmg, int range) {
    return 'Serangan $dmg · Jangkauan $range';
  }

  @override
  String get u_baseUpgrade => 'Tingkatkan Markas';

  @override
  String u_baseDesc(int dmg, int range, int hp) {
    return 'Laser $dmg · Jangkauan $range · Lambung $hp';
  }

  @override
  String u_disabledSec(int sec) {
    return 'Lumpuh ${sec}d';
  }

  @override
  String u_sectorStatus(String sector) {
    return 'Status $sector';
  }

  @override
  String u_sectorStats(
    int colonies,
    int planets,
    int stations,
    String mul,
    String other,
  ) {
    return 'Planet dihuni $colonies / $planets\nStasiun: $stations\nBonus sistem: produksi x$mul\nSistem lain: 💰$other/d';
  }

  @override
  String get u_legendaryGet => '🌟 Legendaris! 🌟';

  @override
  String get u_rareGet => '✨ Kru langka! ✨';

  @override
  String get u_newCrew => 'Kru baru bergabung!';

  @override
  String get u_great => 'Mantap!';

  @override
  String u_crewHeader(int count, int cap, int assigned, int slots) {
    return 'Kru $count/$cap · Ditugaskan $assigned/$slots';
  }

  @override
  String u_recruit(int cost) {
    return 'Rekrut 💰$cost';
  }

  @override
  String u_recruitPremium(int cost) {
    return 'Rekrut Premium ⭐$cost';
  }

  @override
  String u_recruitLegendary(int cost) {
    return '🌟 Pasti Legendaris ⭐$cost';
  }

  @override
  String u_recruitOdds(String normal, String premium) {
    return 'Peluang · Rekrut: $normal\nRekrut Premium: $premium\nPasti Legendaris: ★4 100%';
  }

  @override
  String u_slotMax(int n) {
    return 'Slot kru MAKS ($n)';
  }

  @override
  String u_slotBuy(int price) {
    return 'Slot kru +1 ⭐$price';
  }

  @override
  String u_rosterMax(int n) {
    return 'Kapasitas MAKS ($n)';
  }

  @override
  String u_rosterBuy(int size, int price) {
    return 'Kapasitas +$size ⭐$price';
  }

  @override
  String get u_noCrew => 'Belum ada kru. Rekrut dan tugaskan ke kapalmu!';

  @override
  String get u_unassign => 'Lepas';

  @override
  String get u_assign => 'Tugaskan';

  @override
  String get u_dismiss => 'Pecat';

  @override
  String get u_dismissCrewTitle => 'Pecat Kru';

  @override
  String u_dismissCrewBody(String name) {
    return 'Lepaskan $name? Tidak bisa dibatalkan.';
  }

  @override
  String get u_missionDeliverHint => 'Menuju tujuan (panah kuning)';

  @override
  String get u_missionBountyHint =>
      'Temukan dan kalahkan target (panah kuning)';

  @override
  String u_reward(String rewards) {
    return 'Hadiah $rewards';
  }

  @override
  String u_activeMissions(int n) {
    return 'Aktif ($n/3)';
  }

  @override
  String get u_noActiveMissions => 'Tidak ada misi aktif.';

  @override
  String get u_abandon => 'Batalkan';

  @override
  String u_missionBoard(int sec) {
    return 'Papan Misi · baru dalam ${sec}d';
  }

  @override
  String get u_accept => 'Terima';

  @override
  String get u_priceHigh => '📈 Mahal! Saatnya jual';

  @override
  String get u_priceLow => '📉 Murah… tunggu dulu';

  @override
  String get u_priceNormal => '➡ Normal';

  @override
  String get u_orePrice => 'Harga Bijih';

  @override
  String get u_sell100 => 'Jual 100';

  @override
  String get u_sellHalf => 'Jual Separuh';

  @override
  String get u_sellAll => 'Jual Semua';

  @override
  String get u_marketTip => 'Harga naik turun seiring waktu. Jual saat mahal!';

  @override
  String get u_gemExchange => '⭐ Tukar Permata Bintang';

  @override
  String get u_creditPack => 'Paket Kredit';

  @override
  String get u_exchange => 'Tukar';

  @override
  String get u_openShop => '⭐ Buka Toko';

  @override
  String u_achievementDone(String title, int gems) {
    return '🏆 Pencapaian: $title! Ambil ⭐$gems di Menu > Pencapaian.';
  }

  @override
  String get u_cannotDo =>
      'Sumber daya kurang, atau belum bisa dilakukan sekarang.';

  @override
  String get u_welcomeBack => 'Selamat datang kembali, Kapten!';

  @override
  String u_offlineHm(int h, int m) {
    return 'Selama kamu pergi $h j $m m,\nkoloni bekerja keras!';
  }

  @override
  String u_offlineM(int m) {
    return 'Selama kamu pergi $m m,\nkoloni bekerja keras!';
  }

  @override
  String get u_passOfflineHint => 'Pass Komandan: hingga 8 j + otomatis 2x';

  @override
  String get u_collect => 'Ambil';

  @override
  String get u_adLoading => 'Memuat iklan. Coba lagi sebentar lagi.';

  @override
  String get u_adLoadingRetry => 'Memuat iklan. Ketuk lagi sebentar lagi.';

  @override
  String get u_collectDouble => 'Ambil 2x 👑';

  @override
  String get u_adDouble => '📺 Tonton iklan untuk 2x';

  @override
  String get u_galaxyHonor => '🌌 Kehormatan Galaksi';

  @override
  String u_honorStatus(int honor, int ascensions) {
    return 'Kehormatan $honor (reinkarnasi ${ascensions}x)';
  }

  @override
  String u_honorBonus(int income, int attack) {
    return 'Pendapatan +$income% · Serangan +$attack%';
  }

  @override
  String get u_ascendExplain =>
      'Reinkarnasi mereset alam semesta ini (sistem, koloni, stasiun, upgrade kapal, kru, kredit)\ndan memberimu kehormatan, bonus permanen.\nPermata, kosmetik, kapal, dan pencapaian tetap tersimpan.';

  @override
  String u_ascendGain(int gain) {
    return 'Reinkarnasi sekarang untuk +$gain kehormatan!\n(Makin besar kekaisaranmu, makin banyak yang kamu dapat)';
  }

  @override
  String get u_ascendLocked => 'Capai sistem 4 untuk bereinkarnasi.';

  @override
  String get u_close => 'Tutup';

  @override
  String u_ascendBtn(int gain) {
    return 'Reinkarnasi (+$gain)';
  }

  @override
  String get u_ascendConfirmTitle => 'Yakin bereinkarnasi?';

  @override
  String get u_ascendConfirmBody =>
      'Alam semestamu saat ini akan direset. Tidak bisa dibatalkan.';

  @override
  String get u_ascend => 'Reinkarnasi';

  @override
  String u_shieldBroken(String name) {
    return '$name hancur';
  }

  @override
  String u_hudSector(String sector, int dev, String threat, String value) {
    return '$sector · Perkemb. $dev%\n⚠ Ancaman $threat  🏛 $value';
  }

  @override
  String u_baseDisabled(int sec) {
    return 'Markas lumpuh ${sec}d';
  }

  @override
  String u_baseHp(int pct) {
    return 'Markas $pct%';
  }

  @override
  String get u_merchantE => 'Pedagang (E)';

  @override
  String get u_nextSectorE => 'Sistem Berikut (E)';

  @override
  String get u_prevSectorE => 'Sistem Sebelum (E)';

  @override
  String u_gateLocked(int pct) {
    return '🔒 Terbuka di perkembangan 100% ($pct%)';
  }

  @override
  String u_settle(String name) {
    return 'Huni $name';
  }

  @override
  String u_manageE(String name) {
    return 'Kelola $name (E)';
  }

  @override
  String get u_buildStation => 'Bangun Stasiun';

  @override
  String get u_fire => 'TEMBAK';

  @override
  String get u_equipAtStation => 'Bisa dipasang di tab Kapal di stasiun!';

  @override
  String get u_shotDown => '💥 Kamu tertembak jatuh!';

  @override
  String u_autoRespawn(int sec) {
    return 'Muncul lagi otomatis di markas dalam ${sec}d';
  }

  @override
  String get u_reviveFree => '👑 Bangkit di sini (gratis)';

  @override
  String get u_reviveAd => '📺 Tonton iklan untuk bangkit di sini';

  @override
  String get u_reviveGems => 'Bangkit di sini dengan ⭐10';

  @override
  String u_respawnBase(int pct) {
    return '🏠 Muncul di markas (hilang $pct% kredit)';
  }

  @override
  String get u_spkCaptain => 'Kapten';

  @override
  String get u_spkPirate => 'Bajak Laut';

  @override
  String get u_spkAdvisor => 'Letnan Mina';

  @override
  String get u_spkMerchant => 'Pedagang Nyang';

  @override
  String get u_paused => 'Jeda';

  @override
  String u_pauseStats(
    String sector,
    int kills,
    int crew,
    int colonies,
    int stations,
    int missions,
  ) {
    return '$sector · Musuh jatuh $kills · Kru $crew\nKoloni $colonies · Stasiun $stations · Misi $missions';
  }

  @override
  String get u_resume => '▶︎ Lanjutkan';

  @override
  String get u_shop => '⭐ Toko';

  @override
  String get u_achievements => '🏆 Pencapaian';

  @override
  String get u_dailyQuests => '📅 Misi Harian';

  @override
  String get u_myPlanet => '🌍 Planetku';

  @override
  String get u_ascendMenu => '🌌 Kehormatan Galaksi (Reinkarnasi)';

  @override
  String get u_settings => '⚙ Pengaturan';

  @override
  String get u_saveAndQuit => '💾 Simpan & ke Judul';

  @override
  String get u_keyboardHelp =>
      'Tombol: WASD gerak · Spasi tembak · Q rudal · F perisai · Shift boost\nE interaksi · B bangun stasiun · Esc menu';

  @override
  String get u_recharging => 'Mengisi ulang';

  @override
  String get u_tutDome => 'Perisai\naman di dalam';

  @override
  String get u_tutLevelUp => 'Naik level\npendapatan·bangunan↑';

  @override
  String get u_tutTurret => 'Menara';

  @override
  String get u_tutRepair => 'Perbaiki';

  @override
  String get u_tutRaid => 'Hentikan serbuan';

  @override
  String get u_gotIt => 'Mengerti';

  @override
  String u_damage(int dmg) {
    return 'Serangan $dmg';
  }

  @override
  String u_oreRate(String rate) {
    return 'Bijih +$rate/d';
  }

  @override
  String u_incomePct(int pct) {
    return 'Pendapatan +$pct%';
  }

  @override
  String u_repairRate(int hp) {
    return 'HP +$hp/d';
  }

  @override
  String u_shieldPlus(int amount) {
    return 'Perisai +$amount';
  }

  @override
  String u_systemTitle(String sector, int n) {
    return '$sector · Sistem $n';
  }

  @override
  String u_systemInfo(String threat, String mul) {
    return 'Ancaman $threat · Sumber daya x$mul';
  }

  @override
  String u_development(int pct) {
    return 'Perkembangan $pct%';
  }

  @override
  String get u_nextSystemOpen => 'Sistem berikut terbuka';

  @override
  String get u_opensAt100 => 'Terbuka di 100%';

  @override
  String get u_devHint => 'Naikkan semua planet ke Lv.3 untuk 100%';

  @override
  String get u_conqueredSystems => 'Sistem Taklukan (tetap berproduksi)';

  @override
  String get u_unsettled => 'Belum dihuni';

  @override
  String get u_underRaid => 'Diserbu';

  @override
  String u_unknownSector(int n) {
    return 'Sistem Tak Dikenal $n';
  }

  @override
  String u_sectorDev(String name, int pct) {
    return '$name · Perkemb. $pct%';
  }

  @override
  String get u_buildStationTitle => 'Bangun Stasiun · Pilih Peran';

  @override
  String get u_cost => 'Biaya';

  @override
  String get u_build => 'Bangun';

  @override
  String get u_toNextSector => '🌀 Ke sistem berikutnya';

  @override
  String get u_bossLocked => '🔒 Kalahkan bos untuk membuka';

  @override
  String get u_toPrevSector => '🌀 Ke sistem sebelumnya';

  @override
  String get u_raidAlert => '⚠ Diserbu!';

  @override
  String u_rechargePct(int pct) {
    return 'Isi ulang $pct%';
  }

  @override
  String u_merchantLabel(int sec) {
    return '🛒 Pedagang Keliling (${sec}d)';
  }

  @override
  String get u_supplyPod => '📦 Kapsul Pasokan';

  @override
  String u_sectorBoss(String sector) {
    return '☠ Bos $sector';
  }

  @override
  String get u_pirateBoss => '☠ Bos Bajak Laut';

  @override
  String get u_merchantName => 'Nyang, Pedagang Keliling';

  @override
  String u_merchantLeaves(int sec, String credits) {
    return 'Pergi dalam ${sec}d · 💰$credits';
  }

  @override
  String get u_rareCrewOffer => 'Kru Langka Tersedia';

  @override
  String get u_crewSoldOut => 'Kru hari ini sudah laku, meong!';

  @override
  String get u_gemTrade => 'Tukar Permata (maks 3)';

  @override
  String u_gemTradeRow(int price, int left) {
    return '💰$price → ⭐5  (sisa $left)';
  }

  @override
  String get u_convert => 'Tukar';

  @override
  String get u_potions => 'Ramuan Boost (durasi 2x)';

  @override
  String get u_notEnoughGems => 'Permata tidak cukup';

  @override
  String get u_buyConfirmTitle => 'Konfirmasi Pembelian';

  @override
  String u_buyShipConfirm(String ship, String price) {
    return 'Gunakan $price untuk $ship?';
  }

  @override
  String u_shipBought(String ship) {
    return '$ship didapat! Kamu sudah naik.';
  }

  @override
  String get u_premiumShips => 'Kapal Premium';

  @override
  String get u_hangarTitle => 'Hanggar';

  @override
  String u_buyGems(int price) {
    return 'Beli ⭐$price';
  }

  @override
  String get u_premium => 'Premium';

  @override
  String get u_ok => 'OK';

  @override
  String get u_cancel => 'Batal';

  @override
  String get m_ok => 'OK';

  @override
  String get m_cancel => 'Batal';

  @override
  String get m_close => 'Tutup';

  @override
  String get m_claim => 'Ambil';

  @override
  String m_claimGems(int gems) {
    return 'Ambil ⭐$gems';
  }

  @override
  String get m_done => '✅ Selesai';

  @override
  String get m_notEnoughGems => 'Permata tidak cukup';

  @override
  String get m_restorePurchases => 'Pulihkan Pembelian';

  @override
  String get m_restoreDone => 'Pembelian sudah dicek';

  @override
  String get m_buyConfirmTitle => 'Konfirmasi Pembelian';

  @override
  String m_spendGemsConfirm(String price) {
    return 'Gunakan $price?';
  }

  @override
  String get m_loginTitle => '📅 Login Harian';

  @override
  String get m_loginWelcome => 'Selamat datang kembali, Kapten!';

  @override
  String get m_loginFirst =>
      'Selamat datang, Kapten! Ini hadiah login pertamamu.';

  @override
  String get m_loginStreakHint => 'Login 7 hari berturut-turut untuk ⭐50!';

  @override
  String get m_newGameTitle => 'Game Baru';

  @override
  String get m_newGameBody =>
      'Progresmu saat ini akan dihapus.\n(Permata, kosmetik, pencapaian, dan pembelian tetap tersimpan.) Lanjutkan?';

  @override
  String get m_start => 'Mulai';

  @override
  String get m_loadFailed => 'Gagal memuat data simpanan.';

  @override
  String m_honorLine(int honor, int income, int attack) {
    return '🌌 Kehormatan Galaksi $honor · Pendapatan +$income% · Serangan +$attack%';
  }

  @override
  String get m_continue => 'Lanjutkan';

  @override
  String get m_newGame => '✨ Game Baru';

  @override
  String get m_menuHome => 'Planetku';

  @override
  String get m_menuShop => 'Toko';

  @override
  String get m_menuQuest => 'Misi';

  @override
  String get m_menuAchievements => 'Trofi';

  @override
  String get m_menuSettings => 'Pengaturan';

  @override
  String m_achievementsTitle(int done, int total) {
    return '🏆 Pencapaian ($done/$total)';
  }

  @override
  String get m_dailyTitle => '📅 Misi Harian';

  @override
  String m_dailyReset(int hours, int minutes) {
    return 'Reset dalam $hours j $minutes m';
  }

  @override
  String get m_dailyBonusTitle => '🎁 Bonus Tuntas';

  @override
  String get m_dailyBonusDesc => 'Ambil hadiah ketiga misi hari ini';

  @override
  String get m_settingsTitle => '⚙ Pengaturan';

  @override
  String get m_settingsSound => 'Efek Suara';

  @override
  String get m_settingsMusic => 'Musik';

  @override
  String get m_settingsNotify => 'Pengingat Kembali';

  @override
  String get m_settingsNotifyDesc => 'Kami kabari saat gudang koloni penuh';

  @override
  String get m_settingsHaptics => 'Getaran';

  @override
  String get m_settingsLanguage => 'Bahasa';

  @override
  String get m_languageSystem => 'Ikuti bahasa perangkat';

  @override
  String get m_settingsOrientation => 'Orientasi layar';

  @override
  String get m_orientAuto => 'Otomatis';

  @override
  String get m_orientPortrait => 'Potret';

  @override
  String get m_orientLandscape => 'Lanskap';

  @override
  String get m_privacyTitle => 'Kebijakan Privasi';

  @override
  String m_privacyBody(String email) {
    return 'Star Settlers tidak memerlukan pendaftaran dan tidak mengumpulkan informasi identitas pribadi. Data game (progres, mata uang, pembelian, pengaturan) hanya disimpan di perangkatmu. Satu-satunya pengecualian adalah papan peringkat mingguan opsional di bawah, jika kamu menyalakannya.\n\nPembelian: diproses oleh Google Play / App Store; detail pembayaran tidak pernah dibagikan ke pengembang. RevenueCat memverifikasi dan memulihkan pembelian dengan memproses ID pengguna anonim dan riwayat pembelian.\n\nIklan: iklan berhadiah Google AdMob hanya diputar saat kamu memilih untuk menontonnya. AdMob dapat menggunakan ID iklan, alamat IP, dan info perangkat untuk menayangkan iklan, mempersonalisasinya jika diizinkan, dan mengukurnya. Di Wilayah Ekonomi Eropa, Inggris, dan Swiss, persetujuan diminta saat game pertama kali dibuka dan bisa diubah di Pengaturan → Pengaturan privasi iklan.\n\nNotifikasi: notifikasi lokal yang dijadwalkan di perangkatmu; tidak ada yang dikirim keluar.\n\nMasukan: pesan, versi aplikasi, dan info perangkat hanya sampai ke pengembang jika kamu sendiri mengirim emailnya.\n\nPapan peringkat mingguan (opsional): mati secara default; kamu ikut hanya jika menyalakannya di Pengaturan atau layar peringkat. Yang dikirim hanya ID instalasi acak, nama panggilan yang dibuat game dari daftar kata tetap, dan skor mingguanmu. Tanpa nama, tanpa apa pun yang kamu ketik, dan tanpa chat. Pemain lain hanya melihat nama panggilan dan skor. Servernya Supabase (wilayah Seoul).\n\nPenghapusan: Pengaturan → Reset Semua Data menghapus data di perangkatmu. Jika kamu ikut papan peringkat, reset juga menghapus catatan peringkatmu di server (ID, nama panggilan, skor); kamu juga bisa meminta penghapusan lewat email.\n\nKebijakan lengkap: https://rumururu.github.io/mkideabox/star_settlers/privacy.html\nKontak: $email';
  }

  @override
  String get m_wipeTitle => 'Reset Semua Data';

  @override
  String get m_wipeDesc =>
      'Menghapus semua progres, permata, kosmetik, dan catatan peringkatmu';

  @override
  String get m_wipeConfirmTitle => 'Yakin reset semuanya?';

  @override
  String get m_wipeConfirmBody =>
      'Tidak bisa dibatalkan. Permata dan progres dihapus permanen. Paket Pemula dan Pass Komandan bisa dikembalikan lewat \"Pulihkan Pembelian\".';

  @override
  String get m_wipeOk => 'Reset';

  @override
  String get m_feedbackTitle => 'Kirim Masukan ke Pengembang';

  @override
  String get m_feedbackDesc =>
      'Bug, ide, apa saja! Perangkat dan versi aplikasi terisi otomatis.';

  @override
  String m_noMailApp(String email) {
    return 'Aplikasi email tidak ditemukan. Kirim ke $email.';
  }

  @override
  String get m_aboutTitle => 'STAR SETTLERS';

  @override
  String m_version(String version) {
    return 'Versi $version';
  }

  @override
  String get m_shopTitle => '⭐ Toko';

  @override
  String get m_buyThanks => 'Pembelian selesai! Terima kasih 💜';

  @override
  String get m_adLoading => 'Memuat iklan. Coba lagi sebentar lagi.';

  @override
  String m_buyShipConfirm(String ship, String price) {
    return 'Gunakan $price untuk $ship?';
  }

  @override
  String m_shipAcquired(String ship) {
    return '$ship didapat! Kamu sudah naik';
  }

  @override
  String get m_tabGems => 'Permata';

  @override
  String get m_tabPacks => 'Paket';

  @override
  String get m_tabPremiumShips => 'Kapal Premium';

  @override
  String get m_tabSkins => 'Skin Kapal';

  @override
  String get m_tabOutfits => 'Baju Kapten';

  @override
  String get m_tabFree => 'Permata Gratis';

  @override
  String get m_testMode =>
      '🧪 Mode uji: tanpa pembayaran sungguhan; iklan adalah iklan uji Google';

  @override
  String get m_owned => 'Dimiliki';

  @override
  String get m_boarded => 'Terbang';

  @override
  String get m_gemsInfo =>
      'Permata bisa dipakai untuk kosmetik, rekrut premium, bangkit instan, dan tukar kredit.\nKamu juga bisa mendapatkannya dengan bermain (pencapaian, login, bos, kapsul pasokan).';

  @override
  String get m_crewSection => '👩‍🚀 Kru (Permata)';

  @override
  String get m_premiumSection => '🛸 Kapal Premium';

  @override
  String get m_premiumDesc =>
      'Pesawat tempur khusus yang hanya bisa didapat dengan permata, masing-masing punya kemampuan unik.';

  @override
  String get m_viewLarge => 'Lihat Besar';

  @override
  String get m_premiumHangarHint =>
      'Kamu juga bisa membeli dan ganti kapal di Hanggar (Stasiun → tab Kapal).';

  @override
  String get m_legendTitle => 'Rekrut Pasti Legendaris';

  @override
  String get m_legendDescNoGame =>
      '1 kru legendaris ★4 (bonus 20%+ + semua produksi +40%, gelar, aura emas)\nTersedia setelah kamu memulai game';

  @override
  String m_legendDesc(int count, int cap) {
    return '1 kru legendaris ★4 (bonus 20%+ + semua produksi +40%, gelar, aura emas)\nKru $count/$cap';
  }

  @override
  String m_crewJoined(String stars, String name) {
    return '$stars $name bergabung!';
  }

  @override
  String get m_slotTitle => 'Slot Kru +1';

  @override
  String m_slotDesc(int slots) {
    return 'Jumlah kru yang bisa ditugaskan sekaligus · Kini $slots';
  }

  @override
  String m_rosterTitle(int n) {
    return 'Kapasitas Kru +$n';
  }

  @override
  String m_rosterDesc(int cap, int max) {
    return 'Jumlah kru yang bisa kamu simpan · Kini $cap (maks $max)';
  }

  @override
  String m_crewOdds(String odds) {
    return 'Peluang rekrut premium: $odds · Pasti Legendaris: ★4 100%';
  }

  @override
  String get m_equipped => 'Terpasang';

  @override
  String get m_equip => 'Pasang';

  @override
  String get m_passOnly => 'Khusus Pass Komandan';

  @override
  String get m_starterOnly => 'Khusus Paket Pemula';

  @override
  String get m_adSection => '📺 Permata Gratis dari Iklan';

  @override
  String m_adInfo(int perDay, int left) {
    return '$perDay kali sehari, ⭐5 tiap kali · sisa $left hari ini';
  }

  @override
  String get m_adClaimPremium => 'Ambil ⭐5 (Pass Komandan: tanpa iklan)';

  @override
  String get m_adWatch => 'Tonton Iklan untuk ⭐5';

  @override
  String m_loginStreak(int days) {
    return 'Login beruntun: hari ke-$days';
  }

  @override
  String m_dayN(int day) {
    return 'Hari $day';
  }

  @override
  String get m_notEnoughResources => 'Sumber daya tidak cukup';

  @override
  String m_emptyLot(int n) {
    return 'Lahan Kosong #$n · Bangun';
  }

  @override
  String get m_buildInGameOnly =>
      'Kamu bisa membangun saat bermain (Menu → Planetku). Kredit dan bijih diambil dari alam semestamu saat ini.';

  @override
  String m_heldAll(String credits, String ore, int gems) {
    return 'Punya 💰$credits  💎$ore  ⭐$gems';
  }

  @override
  String m_held(String credits, String ore) {
    return 'Punya 💰$credits  💎$ore';
  }

  @override
  String m_currentEffect(String effect) {
    return 'Saat ini: $effect';
  }

  @override
  String m_nextLevel(String effect) {
    return 'Level berikutnya: $effect';
  }

  @override
  String m_upgrade(String cost) {
    return 'Tingkatkan $cost';
  }

  @override
  String get m_maxLevel => '🌟 Level Maks';

  @override
  String get m_planetName => 'Nama Planet';

  @override
  String get m_decorateTitle => '🎨 Hias Planet';

  @override
  String get m_planetRing => 'Cincin Planet';

  @override
  String get m_giftInGameOnly => 'Hadiah bisa diambil saat bermain';

  @override
  String get m_giftTitle => '🎁 Hadiah Planet';

  @override
  String m_giftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hadiah dari $count pendudukmu!',
    );
    return '$_temp0';
  }

  @override
  String get m_giftThanks => 'Makasih!';

  @override
  String m_planetStatus(int level, int residents, int built, int slots) {
    return 'Planet Lv.$level · $residents penduduk · Bangunan $built/$slots';
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
    return 'Bonus permanen · Pendapatan +$income%  Bijih +$ore%  Serangan +$attack%  HP +$hp%  Jeda -$cooldown%  Offline $offline%';
  }

  @override
  String get m_planetHint =>
      'Geser untuk memutar planet, ketuk lahan untuk membangun';

  @override
  String get m_giftClaim => '🎁 Ambil Hadiah';

  @override
  String m_giftWait(int hours, int minutes) {
    return '🎁 Hadiah dalam $hours j $minutes m';
  }

  @override
  String m_planetLevelUp(int level, String cost) {
    return '🌍 Planet Lv.$level (+2 lahan) $cost';
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
  String get g_shipScoutDesc => 'Kapal pemula yang seimbang';

  @override
  String get g_shipInterceptorDesc =>
      'Cepat dan tembakan beruntun, tapi lapisan tipis';

  @override
  String get g_shipFortressDesc => 'Lambat tapi kokoh, pukulannya keras';

  @override
  String get g_shipProspectorDesc => 'Bijih +50%, menarik item dari jauh';

  @override
  String get g_shipPhantomDesc => 'Peluang 25% kritikal 2.5x';

  @override
  String get g_shipNovaDesc => 'Pesawat tempur premium, peluru menembus musuh';

  @override
  String get g_shipAuroraDesc =>
      'Penjaga premium yang memperbaiki diri dan berpelindung';

  @override
  String get g_shipNovaAbility =>
      'Peluru tembus: tiap peluru menembus hingga 2 musuh';

  @override
  String get g_shipAuroraAbility =>
      'Perbaikan diri: pulih 3% HP/detik setelah 3 detik tanpa terkena serangan\nPerisai Penjaga: menahan 1 serangan tiap 8 detik';

  @override
  String g_crewLegendPerk(int pct) {
    return '👑 Komando legendaris: semua produksi (kredit & bijih) +$pct% (tidak bertumpuk)';
  }

  @override
  String g_shipCreditBonus(int pct) {
    return '💰 Bonus pemburu: +$pct% kredit yang kamu dapat sendiri (hadiah buronan, asteroid, misi, pertahanan serangan)';
  }

  @override
  String g_unlockSector(int n) {
    return 'Capai sistem $n';
  }

  @override
  String g_unlockBosses(int n) {
    return 'Kalahkan bos bajak laut $n kali';
  }

  @override
  String g_unlockOre(int n) {
    return 'Kumpulkan $n bijih';
  }

  @override
  String get g_skinDefault => 'Scout Dasar';

  @override
  String get g_skinCrimson => 'Komet Merah';

  @override
  String get g_skinMint => 'Mint Cokelat';

  @override
  String get g_skinStealth => 'Hitam Siluman';

  @override
  String get g_skinNeon => 'Pink Neon';

  @override
  String get g_skinRainbow => 'Mimpi Pelangi';

  @override
  String get g_skinGalaxy => 'Galaksi';

  @override
  String get g_skinGold => 'Emas Kerajaan';

  @override
  String get g_outfitDefault => 'Baju Antariksa Dasar';

  @override
  String get g_outfitCat => 'Helm Kucing';

  @override
  String get g_outfitBunny => 'Telinga Kelinci';

  @override
  String get g_outfitAlien => 'Antena Alien';

  @override
  String get g_outfitFlower => 'Jepit Bunga';

  @override
  String get g_outfitHat => 'Topi Kapten';

  @override
  String get g_outfitCrown => 'Mahkota Galaksi';

  @override
  String get g_crewRoleGunner => 'Penembak';

  @override
  String get g_crewEffectGunner => 'Serangan';

  @override
  String get g_crewRoleEngineer => 'Teknisi';

  @override
  String get g_crewEffectEngineer => 'HP maks & perbaikan';

  @override
  String get g_crewRolePilot => 'Pilot';

  @override
  String get g_crewEffectPilot => 'Kecepatan';

  @override
  String get g_crewRoleTrader => 'Pedagang';

  @override
  String get g_crewEffectTrader => 'Pendapatan kredit';

  @override
  String get g_crewRoleMiner => 'Penambang';

  @override
  String get g_crewEffectMiner => 'Perolehan bijih';

  @override
  String get g_crewRoleScientist => 'Ilmuwan';

  @override
  String get g_crewEffectScientist => 'Cooldown skill';

  @override
  String get g_crewName0 => 'Bakpao';

  @override
  String get g_crewName1 => 'Coco';

  @override
  String get g_crewName2 => 'Bintang';

  @override
  String get g_crewName3 => 'Tahu';

  @override
  String get g_crewName4 => 'Kacang';

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
  String get g_crewName10 => 'Bulu';

  @override
  String get g_crewName11 => 'Kupu';

  @override
  String get g_crewName12 => 'Choco';

  @override
  String get g_crewName13 => 'Gandum';

  @override
  String get g_crewName14 => 'Awan';

  @override
  String get g_crewName15 => 'Gerimis';

  @override
  String get g_crewName16 => 'Tori';

  @override
  String get g_crewName17 => 'Happy';

  @override
  String get g_crewName18 => 'Klepon';

  @override
  String get g_crewName19 => 'Mochi';

  @override
  String get g_crewName20 => 'Latte';

  @override
  String get g_crewName21 => 'Kuki';

  @override
  String get g_crewName22 => 'Jeli';

  @override
  String get g_crewName23 => 'Kapas';

  @override
  String get g_crewName24 => 'Mangga';

  @override
  String get g_crewName25 => 'Plum';

  @override
  String get g_crewName26 => 'Kenari';

  @override
  String get g_crewName27 => 'Item';

  @override
  String get g_crewName28 => 'Bambi';

  @override
  String get g_crewName29 => 'Keju';

  @override
  String get g_crewLegend0 => 'Penjaga Galaksi';

  @override
  String get g_crewLegend1 => 'Pahlawan Bintang';

  @override
  String get g_crewLegend2 => 'Bijak Nebula';

  @override
  String get g_crewLegend3 => 'Ksatria Komet';

  @override
  String get g_crewLegend4 => 'Supernova';

  @override
  String g_crewLegendName(String title, String name) {
    return '$title $name';
  }

  @override
  String get g_bldHouse => 'Rumah';

  @override
  String g_bldHouseEffect(int n) {
    return 'Penduduk +$n (hadiah lebih banyak)';
  }

  @override
  String get g_bldFarm => 'Kebun Antariksa';

  @override
  String g_bldFarmEffect(int n) {
    return 'Pendapatan kredit +$n%';
  }

  @override
  String get g_bldMine => 'Tambang';

  @override
  String g_bldMineEffect(int n) {
    return 'Perolehan bijih +$n%';
  }

  @override
  String get g_bldLab => 'Lab';

  @override
  String g_bldLabEffect(int n) {
    return 'Cooldown skill -$n%';
  }

  @override
  String get g_bldTower => 'Menara Pertahanan';

  @override
  String g_bldTowerEffect(int n) {
    return 'HP maks +$n%';
  }

  @override
  String get g_bldShipyard => 'Galangan Kapal';

  @override
  String g_bldShipyardEffect(int n) {
    return 'Serangan +$n%';
  }

  @override
  String get g_bldPark => 'Taman Hiburan';

  @override
  String g_bldParkEffect(int n) {
    return 'Pendapatan offline +$n%p';
  }

  @override
  String get g_bldStatue => 'Patung Kapten';

  @override
  String g_bldStatueEffect(int n) {
    return 'Permata hadiah planet +$n';
  }

  @override
  String get g_homePalette0 => 'Taman Hijau';

  @override
  String get g_homePalette1 => 'Gurun Pasir';

  @override
  String get g_homePalette2 => 'Kerajaan Es';

  @override
  String get g_homePalette3 => 'Pulau Lava';

  @override
  String get g_homePalette4 => 'Gas Ungu';

  @override
  String get g_homePalette5 => 'Bunga Sakura';

  @override
  String get g_homePalette6 => 'Aurora';

  @override
  String get g_homePalette7 => 'Emas';

  @override
  String get g_homeDefaultName => 'Bintang Kecilku';

  @override
  String get g_achFirstBloodTitle => 'Tembakan Pertama';

  @override
  String get g_achFirstBloodDesc => 'Jatuhkan 1 bajak laut';

  @override
  String get g_achHunterTitle => 'Pemburu Bajak Laut';

  @override
  String get g_achHunterDesc => 'Jatuhkan 100 bajak laut';

  @override
  String get g_achLegendTitle => 'Kapten Legendaris';

  @override
  String get g_achLegendDesc => 'Jatuhkan 1000 bajak laut';

  @override
  String get g_achMinerTitle => 'Raja Tambang';

  @override
  String get g_achMinerDesc => 'Kumpulkan 1000 bijih';

  @override
  String get g_achMiner2Title => 'Juragan Bijih';

  @override
  String get g_achMiner2Desc => 'Kumpulkan 10000 bijih';

  @override
  String get g_achColonistTitle => 'Perintis';

  @override
  String get g_achColonistDesc => 'Huni 5 planet';

  @override
  String get g_achMetropolisTitle => 'Metropolis';

  @override
  String get g_achMetropolisDesc => 'Kembangkan koloni ke Lv.5';

  @override
  String get g_achBuilderTitle => 'Pembangun';

  @override
  String get g_achBuilderDesc => 'Bangun 3 stasiun';

  @override
  String get g_achBoss1Title => 'Buru Bos';

  @override
  String get g_achBoss1Desc => 'Kalahkan bos bajak laut';

  @override
  String get g_achBoss10Title => 'Penakluk Bos';

  @override
  String get g_achBoss10Desc => 'Kalahkan bos bajak laut 10 kali';

  @override
  String get g_achExplorerTitle => 'Penjelajah';

  @override
  String get g_achExplorerDesc => 'Capai sistem 3';

  @override
  String get g_achVoyagerTitle => 'Pengelana';

  @override
  String get g_achVoyagerDesc => 'Capai sistem 6';

  @override
  String get g_achRichTitle => 'Kapten Kaya';

  @override
  String get g_achRichDesc => 'Miliki 10000 kredit';

  @override
  String get g_achCrew6Title => 'Kru Andalan';

  @override
  String get g_achCrew6Desc => 'Rekrut 6 kru';

  @override
  String get g_achCrew3starTitle => 'Rekan Legendaris';

  @override
  String get g_achCrew3starDesc => 'Rekrut kru ★3';

  @override
  String get g_achMissionsTitle => 'Si Pemecah Masalah';

  @override
  String get g_achMissionsDesc => 'Selesaikan 20 misi';

  @override
  String get g_achJellyTitle => 'Pakar Ubur-ubur';

  @override
  String get g_achJellyDesc => 'Kalahkan 10 ubur-ubur antariksa';

  @override
  String get g_achFashionTitle => 'Fashionista';

  @override
  String get g_achFashionDesc => 'Beli item kosmetik';

  @override
  String get g_achAscendTitle => 'Awal Baru';

  @override
  String get g_achAscendDesc => 'Reinkarnasi dengan Kehormatan Galaksi';

  @override
  String get g_achDroneTitle => 'Drone Andalan';

  @override
  String get g_achDroneDesc => 'Pasang drone tempur';

  @override
  String get g_achHome5Title => 'Arsitek Planet';

  @override
  String get g_achHome5Desc => '5 bangunan di planetku';

  @override
  String get g_achHomeMaxTitle => 'Planet Impian';

  @override
  String get g_achHomeMaxDesc => 'Level planetku maksimal';

  @override
  String get g_dailyKill => 'Jatuhkan 30 bajak laut';

  @override
  String get g_dailyOre => 'Kumpulkan 300 bijih';

  @override
  String get g_dailyMission => 'Selesaikan 2 misi';

  @override
  String get g_dailyColony => 'Kembangkan koloni 2 kali';

  @override
  String get g_dailyBoss => 'Kalahkan bos bajak laut';

  @override
  String get g_dailyPower => 'Ambil 3 power-up';

  @override
  String get g_dailyPlay => 'Main selama 10 menit';

  @override
  String get g_dailyJelly => 'Kalahkan 3 ubur-ubur antariksa';

  @override
  String g_missionKill(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Basmi $n bajak laut',
    );
    return '$_temp0';
  }

  @override
  String g_missionMine(int n) {
    return 'Kumpulkan $n bijih';
  }

  @override
  String g_missionDeliver(String planet) {
    return 'Antar kargo ke $planet';
  }

  @override
  String g_missionBounty(String name) {
    return 'Buronan: $name';
  }

  @override
  String get g_bounty0 => 'Jack Si Mata Satu';

  @override
  String get g_bounty1 => 'Molly Si Kilat';

  @override
  String get g_bounty2 => 'Bark Raja Rongsok';

  @override
  String get g_bounty3 => 'Toto Janggut Merah';

  @override
  String get g_bounty4 => 'Lena Si Bayangan';

  @override
  String get g_bounty5 => 'Pork Si Gendut';

  @override
  String get g_bounty6 => 'Gigi Pedang Kembar';

  @override
  String get g_bounty7 => 'Bud Palu Gila';

  @override
  String get g_bounty8 => 'Lucy Rubah Galaksi';

  @override
  String get g_bounty9 => 'Kapten Tengkorak Bones';

  @override
  String get g_storyAsteroidsTitle => 'Hancurkan 3 asteroid';

  @override
  String get g_storyAsteroidsLine0 =>
      'Kapten! Pertama, hancurkan asteroid untuk mengumpulkan bijih.';

  @override
  String get g_storyAsteroidsLine1 =>
      'Gerak dengan joystick dan tembak dengan tombol tembak!';

  @override
  String get g_storyKillsTitle => 'Jatuhkan 3 bajak laut';

  @override
  String get g_storyKillsLine0 => 'Ada bajak laut di radar! Ikuti panah merah.';

  @override
  String get g_storyKillsLine1 =>
      'Bajak laut? Di depan kapalku mereka cuma rongsokan!';

  @override
  String get g_storyColoniesTitle => 'Huni Mars';

  @override
  String get g_storyColoniesLine0 =>
      'Bangun koloni pertama di Mars, planet merah di sebelah Bumi. Dekati planetnya dan tombol huni akan muncul.';

  @override
  String get g_storyColoniesLine1 =>
      'Koloni menghasilkan kredit bahkan saat kamu santai!';

  @override
  String get g_storyShipLevelsTitle => 'Upgrade kapal di stasiun';

  @override
  String get g_storyShipLevelsLine0 =>
      'Kembali ke Markas Haven dan upgrade kapalmu. Di dekat stasiun, kapalmu juga diperbaiki.';

  @override
  String get g_storyCrewTitle => 'Rekrut 1 kru';

  @override
  String get g_storyCrewLine0 =>
      'Sepi sendirian? Rekrut teman dari tab Kru di menu stasiun!';

  @override
  String get g_storyMissionsTitle => 'Selesaikan 1 misi';

  @override
  String get g_storyMissionsLine0 =>
      'Ambil tugas dari papan misi stasiun. Hadiahnya lumayan, lho.';

  @override
  String get g_storyStationsTitle => 'Bangun stasiun baru';

  @override
  String get g_storyStationsLine0 =>
      'Saatnya memperluas wilayah! Bangun stasiun di ruang kosong jauh dari planet.';

  @override
  String get g_storyDevPercentTitle => 'Perkembangan sistem 100%';

  @override
  String get g_storyDevPercentLine0 =>
      'Naikkan semua planet ke Lv.3 untuk membuka sistem berikutnya. Cek tombol Sistem di kanan atas!';

  @override
  String get g_storySectorTitle => 'Warp ke sistem berikutnya';

  @override
  String get g_storySectorLine0 =>
      'Gerbang warp terbuka! Pergi ke gerbang ungu di minimap.';

  @override
  String get g_storySectorLine1 => 'Alam semesta yang baru menanti!';

  @override
  String g_storyDevNTitle(int n) {
    return 'Perkembangan Sistem $n 100%';
  }

  @override
  String get g_storyDevNLine => 'Naikkan semua planet di sistem baru ke Lv.3!';

  @override
  String g_systemN(int n) {
    return 'Sistem $n';
  }

  @override
  String g_storyWarpNTitle(String system) {
    return 'Warp ke $system';
  }

  @override
  String get g_storyWarpNLine =>
      'Gerbang sudah terbuka. Mau menjelajah lebih dalam?';

  @override
  String get g_powerUpRapid => 'Tembak Cepat';

  @override
  String get g_powerUpShield => 'Perisai';

  @override
  String get g_powerUpMagnet => 'Magnet';

  @override
  String get g_powerUpDoubleCredits => 'Kredit 2x';

  @override
  String get g_planetKindGarden => 'Planet Taman';

  @override
  String get g_planetKindDesert => 'Planet Gurun';

  @override
  String get g_planetKindIce => 'Planet Es';

  @override
  String get g_planetKindLava => 'Planet Lava';

  @override
  String get g_planetKindGas => 'Planet Gas';

  @override
  String get g_colonyBldTurret => 'Menara Tembak';

  @override
  String get g_colonyBldMine => 'Rig Tambang';

  @override
  String get g_colonyBldTrade => 'Pos Dagang';

  @override
  String get g_colonyBldDock => 'Dok Perbaikan';

  @override
  String get g_colonyBldShieldGen => 'Generator Perisai';

  @override
  String get g_colonyBldBlurbTurret =>
      'Otomatis menembak bajak laut di dekat koloni. Wajib untuk menahan serbuan!';

  @override
  String get g_colonyBldBlurbMine =>
      'Menambang bijih dan mengirim 💎 tiap detik.';

  @override
  String get g_colonyBldBlurbTrade =>
      'Menaikkan pendapatan kredit koloni ini 25% per level.';

  @override
  String get g_colonyBldBlurbDock =>
      'Memperbaiki kapalmu saat kamu berada di dekatnya.';

  @override
  String get g_colonyBldBlurbShieldGen =>
      'Menambah kapasitas perisai dan kecepatan pengisian.';

  @override
  String get g_stationRoleHome => 'Markas Utama';

  @override
  String get g_stationRoleDefense => 'Markas Pertahanan';

  @override
  String get g_stationRoleRepair => 'Markas Perbaikan';

  @override
  String get g_stationRoleSupport => 'Markas Suplai';

  @override
  String get g_stationRoleBlurbHome => 'Baterai laser dan zona aman';

  @override
  String get g_stationRoleBlurbDefense =>
      'Menara kuat · ketahanan 2x · menahan tembakan musuh di sekitar';

  @override
  String get g_stationRoleBlurbRepair =>
      'Perbaikan cepat area luas · biaya muncul ulang 10% · isi perisai koloni sekitar 2x';

  @override
  String get g_stationRoleBlurbSupport =>
      'Produksi koloni sekitar +25% (+5% per level hunian)';

  @override
  String g_eventRaid(String planet) {
    return 'Serbuan di $planet';
  }

  @override
  String get g_eventMeteor => 'Hujan Meteor';

  @override
  String get g_eventMerchant => 'Pedagang Keliling';

  @override
  String get g_eventSupply => 'Kapsul Suplai';

  @override
  String get g_productGems100Title => 'Segenggam Permata';

  @override
  String get g_productGems550Title => 'Kantong Permata';

  @override
  String get g_productGems1200Title => 'Peti Permata';

  @override
  String get g_productStarterTitle => 'Paket Pemula';

  @override
  String get g_productPassTitle => 'Pass Komandan';

  @override
  String get g_productGems550Desc => '⭐550 (+10% bonus)';

  @override
  String get g_productGems1200Desc => '⭐1200 (+20% bonus)';

  @override
  String get g_productStarterDesc =>
      '⭐300 + skin eksklusif \"Galaksi\" + kru ★3 (hanya sekali)';

  @override
  String get g_productPassDesc =>
      'Pendapatan kredit +25%, pendapatan offline 8 jam, hadiah tanpa iklan, skin eksklusif \"Emas Kerajaan\"';

  @override
  String g_testPurchaseTitle(String product) {
    return '[Uji pembelian] $product';
  }

  @override
  String g_testPurchaseBody(String desc, String price) {
    return 'Tidak ada pembayaran sungguhan.\n$desc\nHarga: $price';
  }

  @override
  String get g_testAdTitle => '[Uji iklan]';

  @override
  String get g_testAdBody => 'Anggap iklan sudah ditonton sampai habis?';

  @override
  String get g_webDemoTitle => 'Demo Web';

  @override
  String get g_webDemoBody =>
      'Pembelian dan hadiah iklan tersedia di aplikasi seluler.';

  @override
  String get g_notifChannelName => 'Pengingat kembali';

  @override
  String get g_notifChannelDesc =>
      'Pengingat pendapatan koloni dan hadiah harian';

  @override
  String get g_notifStorageTitle => 'Gudang koloni sudah penuh!';

  @override
  String get g_notifStorageBody =>
      'Kapten, ambil kreditmu sebelum pendapatan berhenti!';

  @override
  String get g_notifPiratesTitle => 'Bajak laut mengamuk lagi!';

  @override
  String get g_notifPiratesBody =>
      'Hadiah login dan misi harian hari ini menunggumu.';

  @override
  String get g_upgradeWeapon => 'Senjata';

  @override
  String get g_upgradeHull => 'Lapisan Baja';

  @override
  String get g_upgradeEngine => 'Mesin';

  @override
  String get g_upgradeMissile => 'Rudal Pelacak';

  @override
  String get g_upgradeShield => 'Perisai Energi';

  @override
  String get g_upgradeDrone => 'Drone Tempur';

  @override
  String get g_upgradeMagnet => 'Magnet';

  @override
  String g_unknownSector(int n) {
    return 'Sistem Tak Dikenal $n';
  }

  @override
  String get g_stationHaven => 'Markas Haven';

  @override
  String g_stationOutpost(String sector) {
    return 'Pos Depan $sector';
  }

  @override
  String g_stationNumbered(String role, int n) {
    return '$role #$n';
  }

  @override
  String get g_dlgWelcome =>
      'Selamat datang, Kapten! Saya Mina, wakil kaptenmu.';

  @override
  String get g_dlgMissionsCancelled =>
      'Misi antar kargo dan buronan dari sistem sebelumnya dibatalkan.';

  @override
  String get g_floatDisabled => 'Lumpuh!';

  @override
  String get g_floatRebooted => 'Aktif lagi!';

  @override
  String get g_dlgBaseRebooted =>
      'Markas utama aktif lagi! Ketahanan pulih ke 30%.';

  @override
  String get g_dlgUpWeapon => 'Senjata di-upgrade! Bajak laut, bersiaplah!';

  @override
  String get g_dlgUpHull => 'Lapisan baja di-upgrade! Rasanya lebih kokoh.';

  @override
  String get g_dlgUpEngine => 'Mesin di-upgrade! Lebih cepat!';

  @override
  String get g_dlgMissileNew => 'Rudal pelacak terpasang! (Q)';

  @override
  String get g_dlgMissileUp => 'Rudal di-upgrade!';

  @override
  String get g_dlgShieldNew => 'Perisai energi terpasang! (F)';

  @override
  String get g_dlgShieldUp => 'Perisai di-upgrade!';

  @override
  String get g_dlgDroneNew =>
      'Drone tempur meluncur! Teman baru yang bisa diandalkan.';

  @override
  String get g_dlgDroneUp => 'Drone di-upgrade!';

  @override
  String get g_dlgUpMagnet =>
      'Magnet di-upgrade! Kredit datang sendiri padaku!';

  @override
  String get g_dlgNotOver => 'Ini belum berakhir!';

  @override
  String get g_floatBlocked => 'Tertahan!';

  @override
  String get g_floatGuard => 'Terlindungi!';

  @override
  String get g_pirateBossLose => 'Argh! Sistem ini… milikmu…';

  @override
  String get g_pirateBossFlee => 'Argh! Akan kuingat ini, Kapten!';

  @override
  String get g_dlgSupplyCollected => 'Kapsul suplai berhasil diambil!';

  @override
  String get g_merchantBye => 'Sampai jumpa lagi~ meong!';

  @override
  String get g_pirateRaidTaunt => 'Koloni ini milik kami sekarang! Hahaha!';

  @override
  String get g_dlgMeteor =>
      'Ada hujan meteor! Penuh kristal bijih. Kesempatan panen besar!';

  @override
  String get g_merchantHello =>
      'Pedagang keliling Nyang datang~ Banyak barang bagus, meong!';

  @override
  String get g_dlgSupplySignal =>
      'Ada sinyal kapsul suplai berisi permata! Dijaga bajak laut, jadi hati-hati ya.';

  @override
  String get g_dlgCruiseOn =>
      'Latihan pertama selesai! Aku menyalakan [Jelajah] di atas joystick: kapal terus terbang ke arah hadapnya walau dilepas. Ketuk lagi untuk mematikan.';

  @override
  String get g_dlgBossWarning => 'Peringatan! Kapal bos sistem mendekat!';

  @override
  String get g_pirateRevenge => 'Aku kembali untuk balas dendam! Bersiaplah!';

  @override
  String get g_floatShieldBroken => 'Hancur!';

  @override
  String get g_floatShieldBack => 'Aktif lagi';

  @override
  String get g_floatGoalDone => 'Target tercapai!';

  @override
  String g_dlgArrived(String sector) {
    return 'Tiba di $sector!';
  }

  @override
  String get g_dlgNewFrontier => 'Wilayah baru untuk dirintis.';

  @override
  String g_dlgBaseUpgraded(String station, int level) {
    return '$station naik ke Lv.$level! Laser makin kuat.';
  }

  @override
  String g_dlgBaseDisabled(int sec) {
    return 'Markas utama lumpuh! Perlindungan mati selama $sec detik!';
  }

  @override
  String g_dlgSettled(String planet) {
    return 'Bendera tertancap di $planet! Berhasil dihuni!';
  }

  @override
  String g_dlgStationBuilt(String station, String blurb) {
    return '$station selesai dibangun! $blurb';
  }

  @override
  String g_dlgHabitatUp(String station, int level) {
    return 'Hunian $station Lv.$level!';
  }

  @override
  String g_dlgTurretUp(String station, int level) {
    return 'Menara tembak $station Lv.$level!';
  }

  @override
  String g_dlgShipSwitched(String ship) {
    return 'Ganti ke $ship! Rasanya mantap!';
  }

  @override
  String g_dlgOreSold(int n, int credits) {
    return '$n bijih terjual seharga 💰$credits.';
  }

  @override
  String g_dlgCrewJoined(String stars, String role, String name) {
    return '$stars $role $name bergabung dengan kru!';
  }

  @override
  String g_dlgCrewLevel(String name, int level) {
    return '$name Lv.$level! Makin jago.';
  }

  @override
  String g_dlgCargoLoaded(String mission) {
    return 'Kargo dimuat! $mission';
  }

  @override
  String g_dlgBountyTaunt(String name) {
    return 'Mau menangkap $name? Coba saja kalau berani!';
  }

  @override
  String get g_floatMissionDone => 'Misi selesai!';

  @override
  String g_dlgMissionDone(String mission) {
    return 'Misi selesai: $mission!';
  }

  @override
  String g_dlgRepairCost(int credits) {
    return 'Syukurlah Kapten selamat! Biaya perbaikan 💰$credits.';
  }

  @override
  String g_dlgSectorDeveloped(String sector) {
    return '$sector berkembang penuh! Gerbang warp ke sistem berikutnya terbuka.';
  }

  @override
  String g_floatCrit(int dmg) {
    return 'Kritikal! $dmg';
  }

  @override
  String g_dlgStationDestroyed(String station) {
    return '$station hancur! Kita butuh menara tembak!';
  }

  @override
  String g_dlgBossDefeated(int credits) {
    return 'Bos sistem kalah! Hadiah 💰$credits';
  }

  @override
  String g_dlgBountyCaught(String name) {
    return 'Buronan $name tertangkap!';
  }

  @override
  String g_dlgRaidDefended(String planet, int credits) {
    return '$planet berhasil dipertahankan! Penduduk mengirim 💰$credits ⭐2 sebagai tanda terima kasih.';
  }

  @override
  String g_dlgRaidLooted(String planet, String level) {
    return '$planet dijarah dan turun ke $level… 😢';
  }

  @override
  String g_dlgRaidLeft(String planet) {
    return 'Bajak laut menjarah $planet lalu pergi.';
  }

  @override
  String g_dlgRaidAlert(String planet) {
    return 'Darurat! Bajak laut menyerbu $planet! Produksi berhenti!';
  }

  @override
  String g_pirateBossArrive(String sector) {
    return 'Akulah penguasa $sector! Maju sini, kapten cilik!';
  }

  @override
  String g_dlgWelcomeBack(String goal) {
    return 'Selamat datang kembali, Kapten! Target saat ini: $goal';
  }

  @override
  String get g_pirateWin0 => 'Hahaha! Cuma segitu?';

  @override
  String get g_pirateWin1 => 'Datang lagi kalau sudah lebih kuat, bocah!';

  @override
  String get g_pirateWin2 => 'Kapalmu sekarang jadi rongsokan!';

  @override
  String get g_pirateRage0 => 'Anak-anak, keluar! Beri mereka pelajaran!';

  @override
  String get g_pirateRage1 => 'Sekarang baru serius!';

  @override
  String get g_pirateRage2 => 'Berani bikin aku marah?!';

  @override
  String get g_captainKill0 => 'Satu beres!';

  @override
  String get g_captainKill1 => 'Mau kabur ke mana!';

  @override
  String get g_captainKill2 => 'Wilayah ini punyaku!';

  @override
  String get g_captainKill3 => 'Berikutnya!';

  @override
  String get g_pirateAmbush0 => 'Hahaha! Serahkan kargomu!';

  @override
  String get g_pirateAmbush1 => 'Ini wilayah geng kami!';

  @override
  String get g_pirateAmbush2 => 'Serahkan kredit berkilaumu itu!';

  @override
  String get g_pirateAmbush3 => 'Hari sialmu, bocah!';

  @override
  String get cat_sysSol => 'Tata Surya';

  @override
  String get cat_sysAlphaCen => 'Alpha Centauri';

  @override
  String get cat_sysBarnard => 'Bintang Barnard';

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
  String get cat_sysTeegarden => 'Bintang Teegarden';

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
  String get cat_sysOmegaCen => 'Gugus Omega Centauri';

  @override
  String get cat_sysSgrA => 'Pusat Galaksi (Sgr A*)';

  @override
  String get cat_sysLMC => 'Awan Magellan Besar';

  @override
  String get cat_sysSMC => 'Awan Magellan Kecil';

  @override
  String get cat_sysAndromeda => 'Galaksi Andromeda';

  @override
  String get cat_sysTriangulum => 'Galaksi Triangulum';

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
  String get cat_moon => 'Bulan';

  @override
  String get cat_venus => 'Venus';

  @override
  String get cat_mercury => 'Merkurius';

  @override
  String get cat_ceres => 'Ceres';

  @override
  String get cat_vesta => 'Vesta';

  @override
  String get cat_jupiter => 'Yupiter';

  @override
  String get cat_io => 'Io';

  @override
  String get cat_europa => 'Europa';

  @override
  String get cat_ganymede => 'Ganimede';

  @override
  String get cat_callisto => 'Kalisto';

  @override
  String get cat_saturn => 'Saturnus';

  @override
  String get cat_enceladus => 'Enseladus';

  @override
  String get cat_titan => 'Titan';

  @override
  String get cat_uranus => 'Uranus';

  @override
  String get cat_miranda => 'Miranda';

  @override
  String get cat_titania => 'Titania';

  @override
  String get cat_neptune => 'Neptunus';

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
  String get cat_planetNine => 'Planet Kesembilan';

  @override
  String get u_topUpTitle => 'Kredit kurang';

  @override
  String u_topUpBody(int credits, int gems) {
    return 'Kurang 💰$credits. Pakai ⭐$gems untuk menutupi dan lanjut?';
  }

  @override
  String u_topUpNoGems(int credits, int gems, int have) {
    return 'Kurang 💰$credits. Menukar butuh ⭐$gems, tapi kamu punya ⭐$have. Kumpulkan sedikit kredit lagi!';
  }

  @override
  String get u_topUpOk => 'Tutupi & lanjut';

  @override
  String get u_goShop => 'Ke toko';

  @override
  String get u_exchangeTitle => '💰 Tukar kredit';

  @override
  String u_exchangeBody(int gems, int credits) {
    return 'Tukar ⭐$gems jadi 💰$credits?';
  }

  @override
  String get m_purchaseFailed =>
      'Tidak dapat terhubung ke toko. Coba lagi nanti.';

  @override
  String get m_adWatchToEnd =>
      'Tonton iklan sampai selesai untuk mendapatkan hadiah.';

  @override
  String get u_cruise => 'Jelajah';

  @override
  String get u_autoFireOn => 'ON';

  @override
  String get u_autoFireOff => 'OFF';

  @override
  String u_recruitRoleOdds(int count, String pct) {
    return 'Peran (semua rekrut): acak dari $count, masing-masing $pct';
  }

  @override
  String m_feedbackSubject(String app) {
    return 'Masukan $app';
  }

  @override
  String get lb_menu => '🏅 Peringkat Mingguan';

  @override
  String get lb_menuShort => 'Peringkat';

  @override
  String get lb_title => '🏅 Peringkat Mingguan';

  @override
  String get lb_join => 'Ikut papan peringkat';

  @override
  String get lb_joinDesc =>
      'Yang dikirim hanya ID anonim, nama panggilan buatan game, dan skor mingguanmu. Tanpa nama, tanpa chat, tanpa apa pun yang kamu ketik. Bisa dimatikan kapan saja.';

  @override
  String get lb_yourNick => 'Nama panggilanmu';

  @override
  String lb_reroll(int count) {
    return 'Nama baru ($count)';
  }

  @override
  String lb_weekPoints(String points) {
    return 'Minggu ini: $points poin';
  }

  @override
  String lb_rank(int rank, int total) {
    return '#$rank dari $total';
  }

  @override
  String lb_rankOnly(int rank) {
    return '#$rank';
  }

  @override
  String get lb_top50 => '50 teratas minggu ini';

  @override
  String get lb_empty => 'Belum ada skor minggu ini. Jadilah yang pertama!';

  @override
  String get lb_retry => 'Coba lagi';

  @override
  String get lb_refresh => 'Muat ulang';

  @override
  String get lb_offline =>
      'Tidak ada koneksi. Game tetap bisa dimainkan — coba lagi nanti.';

  @override
  String get lb_rateLimited =>
      'Terlalu sering. Tunggu satu menit lalu coba lagi.';

  @override
  String get lb_rejected => 'Skor ini tidak bisa dikirim.';

  @override
  String get lb_serverError => 'Papan peringkat sedang sibuk. Coba lagi nanti.';

  @override
  String get lb_unavailable => 'Papan peringkat tidak tersedia.';

  @override
  String get lb_optedOut =>
      'Nyalakan \"Ikut papan peringkat\" untuk mengirim skormu.';

  @override
  String get lb_howTo =>
      'Level koloni +100 · Sistem bintang baru +500 · Bajak laut +5 · Bos +200';

  @override
  String get lb_resets => 'Minggu baru dimulai setiap Senin pukul 00:00 UTC.';

  @override
  String nickFormat(String adj, String animal, String number) {
    return '$animal $adj $number';
  }

  @override
  String get nickGenders => '';

  @override
  String nickAdj0(String g) {
    return 'Pemberani';
  }

  @override
  String get nickAnimal0 => 'Berang-berang';

  @override
  String nickAdj1(String g) {
    return 'Ceria';
  }

  @override
  String get nickAnimal1 => 'Panda';

  @override
  String nickAdj2(String g) {
    return 'Tenang';
  }

  @override
  String get nickAnimal2 => 'Rubah';

  @override
  String nickAdj3(String g) {
    return 'Cerdik';
  }

  @override
  String get nickAnimal3 => 'Kelinci';

  @override
  String nickAdj4(String g) {
    return 'Kosmik';
  }

  @override
  String get nickAnimal4 => 'Burung Hantu';

  @override
  String nickAdj5(String g) {
    return 'Ingin Tahu';
  }

  @override
  String get nickAnimal5 => 'Penguin';

  @override
  String nickAdj6(String g) {
    return 'Lincah';
  }

  @override
  String get nickAnimal6 => 'Koala';

  @override
  String nickAdj7(String g) {
    return 'Pemimpi';
  }

  @override
  String get nickAnimal7 => 'Lumba-lumba';

  @override
  String nickAdj8(String g) {
    return 'Hangat';
  }

  @override
  String get nickAnimal8 => 'Kura-kura';

  @override
  String nickAdj9(String g) {
    return 'Cepat';
  }

  @override
  String get nickAnimal9 => 'Landak';

  @override
  String nickAdj10(String g) {
    return 'Berbulu';
  }

  @override
  String get nickAnimal10 => 'Tupai';

  @override
  String nickAdj11(String g) {
    return 'Ramah';
  }

  @override
  String get nickAnimal11 => 'Anak Kucing';

  @override
  String nickAdj12(String g) {
    return 'Lembut';
  }

  @override
  String get nickAnimal12 => 'Anak Anjing';

  @override
  String nickAdj13(String g) {
    return 'Bercahaya';
  }

  @override
  String get nickAnimal13 => 'Anak Bebek';

  @override
  String nickAdj14(String g) {
    return 'Keemasan';
  }

  @override
  String get nickAnimal14 => 'Anak Domba';

  @override
  String nickAdj15(String g) {
    return 'Bahagia';
  }

  @override
  String get nickAnimal15 => 'Anjing Laut';

  @override
  String nickAdj16(String g) {
    return 'Lucu';
  }

  @override
  String get nickAnimal16 => 'Paus';

  @override
  String nickAdj17(String g) {
    return 'Baik Hati';
  }

  @override
  String get nickAnimal17 => 'Hamster';

  @override
  String nickAdj18(String g) {
    return 'Beruntung';
  }

  @override
  String get nickAnimal18 => 'Beaver';

  @override
  String nickAdj19(String g) {
    return 'Musikal';
  }

  @override
  String get nickAnimal19 => 'Rakun';

  @override
  String nickAdj20(String g) {
    return 'Kuat';
  }

  @override
  String get nickAnimal20 => 'Burung Beo';

  @override
  String nickAdj21(String g) {
    return 'Warna-warni';
  }

  @override
  String get nickAnimal21 => 'Kepik';

  @override
  String nickAdj22(String g) {
    return 'Manis';
  }

  @override
  String get nickAnimal22 => 'Burung Pipit';

  @override
  String nickAdj23(String g) {
    return 'Sopan';
  }

  @override
  String get nickAnimal23 => 'Anak Rusa';

  @override
  String nickAdj24(String g) {
    return 'Suka Bermain';
  }

  @override
  String get nickAnimal24 => 'Kuda Poni';

  @override
  String nickAdj25(String g) {
    return 'Pendiam';
  }

  @override
  String get nickAnimal25 => 'Anak Beruang';

  @override
  String nickAdj26(String g) {
    return 'Berkilau';
  }

  @override
  String get nickAnimal26 => 'Anak Singa';

  @override
  String nickAdj27(String g) {
    return 'Perak';
  }

  @override
  String get nickAnimal27 => 'Anak Harimau';

  @override
  String nickAdj28(String g) {
    return 'Mengantuk';
  }

  @override
  String get nickAnimal28 => 'Jerapah';

  @override
  String nickAdj29(String g) {
    return 'Bulan';
  }

  @override
  String get nickAnimal29 => 'Zebra';

  @override
  String nickAdj30(String g) {
    return 'Surya';
  }

  @override
  String get nickAnimal30 => 'Gajah';

  @override
  String nickAdj31(String g) {
    return 'Ajaib';
  }

  @override
  String get nickAnimal31 => 'Kuda Nil';

  @override
  String nickAdj32(String g) {
    return 'Super';
  }

  @override
  String get nickAnimal32 => 'Llama';

  @override
  String nickAdj33(String g) {
    return 'Berbintang';
  }

  @override
  String get nickAnimal33 => 'Alpaka';

  @override
  String nickAdj34(String g) {
    return 'Cerah';
  }

  @override
  String get nickAnimal34 => 'Meerkat';

  @override
  String nickAdj35(String g) {
    return 'Mulia';
  }

  @override
  String get nickAnimal35 => 'Bintang Laut';

  @override
  String nickAdj36(String g) {
    return 'Mungil';
  }

  @override
  String get nickAnimal36 => 'Kuda Laut';

  @override
  String nickAdj37(String g) {
    return 'Bijak';
  }

  @override
  String get nickAnimal37 => 'Tupai Belang';

  @override
  String nickAdj38(String g) {
    return 'Bersalju';
  }

  @override
  String get nickAnimal38 => 'Ikan Mas Koki';

  @override
  String nickAdj39(String g) {
    return 'Setia';
  }

  @override
  String get nickAnimal39 => 'Kunang-kunang';

  @override
  String get m_adPrivacy => 'Pengaturan privasi iklan';
}
