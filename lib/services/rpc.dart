import 'dart:convert';
import 'dart:io';

/// Supabase PostgREST 함수(rpc) 한 번 호출. (HTTP 상태, 본문)을 돌려준다. 네트워크 오류는 그대로 던진다.
/// 순위표(공용 게임 서버)와 젬 지갑(claires-ranch 프로젝트)이 같이 쓴다.
Future<(int, String)> supabaseRpcPost(
    String baseUrl, String anonKey, Duration timeout, String rpc, Map<String, Object?> body) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final req = await client.postUrl(Uri.parse('$baseUrl/rest/v1/rpc/$rpc'));
    req.headers
      ..set('apikey', anonKey)
      ..set(HttpHeaders.authorizationHeader, 'Bearer $anonKey')
      ..contentType = ContentType.json;
    req.add(utf8.encode(jsonEncode(body)));
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();
    return (res.statusCode, text);
  } finally {
    client.close(force: true);
  }
}
