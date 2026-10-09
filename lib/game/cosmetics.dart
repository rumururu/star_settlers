import 'dart:ui';

import '../l10n/l.dart';

/// 치비 캐릭터 머리 장식
enum Accessory { none, catEars, crown, captainHat, antenna, bunnyEars, flower }

class ShipSkin {
  const ShipSkin(this.id, this.hull, this.wing, this.stripe,
      {this.price = 0, this.exclusive, this.rainbow = false});
  final String id;
  String get name => switch (id) {
        'crimson' => tr.g_skinCrimson,
        'mint' => tr.g_skinMint,
        'stealth' => tr.g_skinStealth,
        'neon' => tr.g_skinNeon,
        'rainbow' => tr.g_skinRainbow,
        'galaxy' => tr.g_skinGalaxy,
        'gold' => tr.g_skinGold,
        _ => tr.g_skinDefault,
      };
  final Color hull;
  final Color wing;
  final Color stripe;

  /// 젬 가격 (0 = 무료)
  final int price;

  /// 특정 상품 전용 (premium_pass / starter_pack)
  final String? exclusive;
  final bool rainbow;
}

class CaptainOutfit {
  const CaptainOutfit(this.id, this.accessory, this.suit,
      {this.price = 0, this.hair});
  final String id;
  String get name => switch (id) {
        'cat' => tr.g_outfitCat,
        'bunny' => tr.g_outfitBunny,
        'alien' => tr.g_outfitAlien,
        'flower' => tr.g_outfitFlower,
        'hat' => tr.g_outfitHat,
        'crown' => tr.g_outfitCrown,
        _ => tr.g_outfitDefault,
      };
  final Accessory accessory;
  final Color suit;
  final Color? hair;
  final int price;
}

const shipSkins = [
  ShipSkin('default', Color(0xFFECEFF1), Color(0xFF1565C0), Color(0xFFE53935)),
  ShipSkin('crimson', Color(0xFFFFCDD2), Color(0xFFC62828), Color(0xFFFFD54F), price: 80),
  ShipSkin('mint', Color(0xFFB2DFDB), Color(0xFF5D4037), Color(0xFF26A69A), price: 80),
  ShipSkin('stealth', Color(0xFF424242), Color(0xFF212121), Color(0xFF00E5FF), price: 120),
  ShipSkin('neon', Color(0xFFFCE4EC), Color(0xFFEC407A), Color(0xFF7C4DFF), price: 120),
  ShipSkin('rainbow', Color(0xFFFFFFFF), Color(0xFFFF7043), Color(0xFF42A5F5), price: 300, rainbow: true),
  ShipSkin('galaxy', Color(0xFF311B92), Color(0xFF7C4DFF), Color(0xFFFFD740), exclusive: 'starter_pack'),
  ShipSkin('gold', Color(0xFFFFF8E1), Color(0xFFFFB300), Color(0xFF6D4C41), exclusive: 'premium_pass'),
];

const captainOutfits = [
  CaptainOutfit('default', Accessory.none, Color(0xFF1E88E5)),
  CaptainOutfit('cat', Accessory.catEars, Color(0xFFFF8A65), price: 60),
  CaptainOutfit('bunny', Accessory.bunnyEars, Color(0xFFF48FB1), price: 60),
  CaptainOutfit('alien', Accessory.antenna, Color(0xFF66BB6A), price: 80, hair: Color(0xFF2E7D32)),
  CaptainOutfit('flower', Accessory.flower, Color(0xFFBA68C8), price: 80),
  CaptainOutfit('hat', Accessory.captainHat, Color(0xFF263238), price: 100),
  CaptainOutfit('crown', Accessory.crown, Color(0xFF8E24AA), price: 150, hair: Color(0xFFFFD54F)),
];

ShipSkin skinById(String id) =>
    shipSkins.firstWhere((s) => s.id == id, orElse: () => shipSkins.first);

CaptainOutfit outfitById(String id) => captainOutfits
    .firstWhere((s) => s.id == id, orElse: () => captainOutfits.first);
