import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/services/monetization.dart';

/// 서버 지갑의 보상표(supabase/wallet/migrations/20261012000000_starset_wallet.sql)가 게임 상수와 같은지.
/// 한쪽만 바꾸면 화면에 보인 보상과 서버가 확정한 보상이 달라진다.
void main() {
  final sql = File('supabase/wallet/migrations/20261012000000_starset_wallet.sql').readAsStringSync();

  /// `create ... function public.<name>` 본문의 `when '<id>' then <n>` 목록
  Map<String, int> caseTable(String name) {
    final start = sql.indexOf('function public.$name(');
    expect(start, isNonNegative, reason: name);
    final body = sql.substring(start, sql.indexOf(r'$$;', start));
    return {
      for (final m in RegExp(r"when '([^']+)' then (\d+)").allMatches(body)) m[1]!: int.parse(m[2]!),
    };
  }

  int constant(String name) {
    final m = RegExp('function public\\.$name\\(\\) returns int language sql immutable as \\\$\\\$ select (\\d+)')
        .firstMatch(sql);
    expect(m, isNotNull, reason: name);
    return int.parse(m![1]!);
  }

  test('업적 보상', () {
    expect(caseTable('starset_achievement_gems'), {for (final a in achievements) a.id: a.gems});
  });

  test('일일 퀘스트와 보너스 보상', () {
    expect(caseTable('starset_quest_gems'), {for (final q in dailyPool) q.id: q.gems, 'bonus': dailyBonusGems});
  });

  test('출석 보상 7일', () {
    final m = RegExp(r'array\[([\d, ]+)\]').firstMatch(sql);
    expect(m![1]!.split(',').map((s) => int.parse(s.trim())).toList(), loginRewards);
  });

  test('광고 젬 횟수와 양', () {
    expect(constant('starset_ads_per_day'), Profile.adGemsPerDay);
    expect(constant('starset_ad_gems'), Profile.adGemAmount);
  });

  test('서버가 아는 상품 = 앱 상품', () {
    final start = sql.indexOf('function public.starset_product(');
    final body = sql.substring(start, sql.indexOf(r'$$;', start));
    final ids = RegExp(r"when '([a-z_0-9]+)'").allMatches(body).map((m) => m[1]!).toSet();
    expect(ids, productDefs.map((d) => d.id).toSet());
  });
}
