#!/usr/bin/env bash
# supabase/wallet/tests/live.sh — Star Settlers gem wallet on the live claires-ranch project.
# The app's path (REST + anon key) for the app functions; the Management API (as the webhook's service role would) for
# purchases, refunds and transfers. Test wallets use fresh random ids and are deleted at the end.
# Usage: ANON=<claires-ranch anon key> supabase/wallet/tests/live.sh   (the key is public; lib/services/wallet.dart has it)
set -u
REF=wthrfgiotkzjxmroljwt
URL="https://$REF.supabase.co"
ANON=${ANON:?set ANON to the claires-ranch anon key}
MGMT=$(security find-generic-password -a mkideabox-games-mgmt-token -s supabase -w)
pass=0; fail=0; ok(){ echo "PASS  $1"; pass=$((pass+1)); }; no(){ echo "FAIL  $1 — $2"; fail=$((fail+1)); }

q(){ python3 -c "import json,sys;print(json.dumps({'query':sys.argv[1]}))" "$1" | curl -s -m 20 -X POST -H "Authorization: Bearer $MGMT" -H "Content-Type: application/json" "https://api.supabase.com/v1/projects/$REF/database/query" -d @-; }
# rpc <fn> <json> → "<http code> <body>"
rpc(){ curl -s -m 20 -w ' %{http_code}' -X POST "$URL/rest/v1/rpc/$1" -H "apikey: $ANON" -H "Authorization: Bearer $ANON" -H "Content-Type: application/json" -d "$2"; }
code(){ echo "${1##* }"; }
# j <response> <python expr on d> — d is the JSON body
j(){ python3 -c "import json,sys;b=sys.argv[1].rsplit(' ',1)[0];d=json.loads(b);print($2)" "$1" "$2" 2>/dev/null; }
id(){ python3 -c "import uuid;print(uuid.uuid4())"; }
ref(){ python3 -c "import uuid;print(uuid.uuid4().hex)"; }
day(){ python3 -c "import datetime as t;print((t.datetime.now(t.timezone.utc)+t.timedelta(days=int('$1'))).strftime('%Y%m%d'))"; }
earn(){ rpc starset_earn "{\"p_install_id\":\"$1\",\"p_ref\":\"$2\",\"p_source\":\"$3\",\"p_key\":\"$4\",\"p_amount\":$5,\"p_day\":$6}"; }
spend(){ rpc starset_spend "{\"p_install_id\":\"$1\",\"p_ref\":\"$2\",\"p_reason\":\"$3\",\"p_amount\":$4}"; }
gems(){ j "$(rpc starset_wallet "{\"p_install_id\":\"$1\"}")" "d['gems']"; }

A=$(id); B=$(id); C=$(id); T=t$(date +%s); D0=$(day 0)

# ── locked doors ──
r=$(rpc starset_wallet "{\"p_install_id\":\"$A\"}"); [ "$(code "$r")" = 200 ] && [ "$(j "$r" "d['gems']")" = 0 ] && ok "a new wallet starts at 0" || no "new wallet" "$r"
r=$(curl -s -o /dev/null -w '%{http_code}' "$URL/rest/v1/starset_wallets?select=*" -H "apikey: $ANON" -H "Authorization: Bearer $ANON"); [ "$r" != 200 ] && ok "the wallet table cannot be read directly ($r)" || no "table read" "$r"
r=$(rpc starset_credit_purchase "{\"p_install_id\":\"$A\",\"p_transaction_id\":\"x$T\",\"p_product_id\":\"gems_1200\",\"p_price\":1,\"p_currency\":\"KRW\",\"p_store\":\"x\",\"p_environment\":\"x\"}"); [ "$(code "$r")" != 200 ] && ok "the app cannot credit a purchase ($(code "$r"))" || no "anon credit" "$r"
r=$(rpc starset_transfer "{\"p_from\":[\"$B\"],\"p_to\":\"$A\"}"); [ "$(code "$r")" != 200 ] && ok "the app cannot move a wallet ($(code "$r"))" || no "anon transfer" "$r"

# ── achievements ──
R1=$(ref)
r=$(earn "$A" "$R1" ach first_blood 999 "$D0"); [ "$(j "$r" "d['credited']")" = 5 ] && ok "an achievement pays its own amount (5), not the asked 999" || no "ach" "$r"
r=$(earn "$A" "$R1" ach first_blood 5 "$D0"); [ "$(j "$r" "d['repeat']")" = True ] && [ "$(j "$r" "d['wallet']['gems']")" = 5 ] && ok "the same request id again changes nothing" || no "repeat ref" "$r"
r=$(earn "$A" "$(ref)" ach first_blood 5 "$D0"); [ "$(j "$r" "d['credited']")" = 0 ] && ok "an achievement pays once per wallet" || no "ach twice" "$r"
r=$(earn "$A" "$(ref)" ach made_up 5 "$D0"); [ "$(code "$r")" = 400 ] && ok "an unknown achievement is refused (400)" || no "unknown ach" "$r"

# ── login ──
r=$(earn "$A" "$(ref)" login "" 50 "$(day -1)"); [ "$(j "$r" "d['credited']")" = 5 ] && ok "login day 1 pays 5 whatever is asked" || no "login 1" "$r"
r=$(earn "$A" "$(ref)" login "" 50 "$(day -1)"); [ "$(j "$r" "d['credited']")" = 0 ] && ok "login the same day again pays 0" || no "login same day" "$r"
r=$(earn "$A" "$(ref)" login "" 50 "$(day -2)"); [ "$(j "$r" "d['credited']")" = 0 ] && ok "login for an earlier day pays 0" || no "login earlier" "$r"
r=$(earn "$A" "$(ref)" login "" 50 "$D0"); [ "$(j "$r" "d['credited']")" = 5 ] && [ "$(j "$r" "d['wallet']['login_streak']")" = 2 ] && ok "the next day continues the streak (2nd day, 5)" || no "login streak" "$r"
r=$(earn "$A" "$(ref)" login "" 5 "$(day 3)"); [ "$(code "$r")" = 400 ] && ok "a day beyond tomorrow is refused (400)" || no "login future" "$r"
r=$(earn "$A" "$(ref)" login "" 5 20261399); [ "$(code "$r")" = 400 ] && ok "a date that does not exist is refused (400)" || no "bad date" "$r"

# ── daily quests ──
for k in kill ore mission; do earn "$A" "$(ref)" quest $k 10 "$D0" >/dev/null; done
r=$(earn "$A" "$(ref)" quest boss 10 "$D0"); [ "$(j "$r" "d['credited']")" = 0 ] && [ "$(j "$r" "d['reason']")" = limit ] && ok "a 4th quest the same day pays 0" || no "quest limit" "$r"
r=$(earn "$A" "$(ref)" quest kill 10 "$D0"); [ "$(j "$r" "d['reason']")" = claimed ] && ok "the same quest twice pays 0" || no "quest twice" "$r"
r=$(earn "$A" "$(ref)" quest bonus 99 "$D0"); [ "$(j "$r" "d['credited']")" = 10 ] && ok "the daily bonus pays 10" || no "bonus" "$r"
r=$(earn "$A" "$(ref)" quest whatever 5 "$D0"); [ "$(code "$r")" = 400 ] && ok "an unknown quest is refused (400)" || no "unknown quest" "$r"

# ── ads ──
for i in 1 2 3; do earn "$A" "$(ref)" ad "" 5 "$D0" >/dev/null; done
r=$(earn "$A" "$(ref)" ad "" 5 "$D0"); [ "$(j "$r" "d['credited']")" = 0 ] && ok "a 4th ad the same day pays 0" || no "ad limit" "$r"

# A: 5 ach + 10 login + 20 quests (5+5+10) + 10 bonus + 15 ads = 60
[ "$(gems "$A")" = 60 ] && ok "balance after the free sources is 60" || no "free total" "$(gems "$A")"

# ── play cap ──
r=$(earn "$B" "$(ref)" play "" 900 "$D0"); [ "$(j "$r" "d['credited']")" = 900 ] && ok "play earnings under the cap are paid in full" || no "play 900" "$r"
r=$(earn "$B" "$(ref)" play "" 300 "$D0"); [ "$(j "$r" "d['credited']")" = 100 ] && [ "$(j "$r" "d['reason']")" = cap ] && ok "play earnings stop at 1000 a day (100 of 300)" || no "play cap" "$r"
r=$(earn "$B" "$(ref)" play "" 100001 "$D0"); [ "$(code "$r")" = 400 ] && ok "an absurd amount is refused (400)" || no "play absurd" "$r"

# ── spend ──
r=$(spend "$B" "$(ref)" revive 1001); [ "$(j "$r" "d['ok']")" = False ] && [ "$(j "$r" "d['wallet']['gems']")" = 1000 ] && ok "spending more than the balance is refused and changes nothing" || no "overspend" "$r"
R2=$(ref)
r=$(spend "$B" "$R2" revive 10); [ "$(j "$r" "d['ok']")" = True ] && [ "$(j "$r" "d['wallet']['gems']")" = 990 ] && ok "spending 10 leaves 990" || no "spend" "$r"
r=$(spend "$B" "$R2" revive 10); [ "$(j "$r" "d['wallet']['gems']")" = 990 ] && ok "the same spend request again takes nothing more" || no "spend repeat" "$r"
r=$(spend "$B" "$(ref)" 'Bad Reason' 1); [ "$(code "$r")" = 400 ] && ok "a malformed reason is refused (400)" || no "bad reason" "$r"
r=$(spend "$B" "$(ref)" revive -5); [ "$(code "$r")" = 400 ] && ok "a negative spend is refused (400)" || no "negative spend" "$r"

# ── purchases (service role) ──
v(){ python3 -c "import json,sys;print(json.loads(sys.argv[1])[0][sys.argv[2]])" "$1" "$2" 2>/dev/null; }
r=$(q "select starset_credit_purchase('$C','$T-1','gems_100',1200,'KRW','PLAY_STORE','SANDBOX')->>'credited' as c"); [ "$(v "$r" c)" = true ] && ok "a gem pack is credited" || no "credit" "$r"
r=$(q "select starset_credit_purchase('$C','$T-1','gems_100',1200,'KRW','PLAY_STORE','SANDBOX')->>'credited' as c"); [ "$(v "$r" c)" = false ] && ok "the same transaction again credits nothing" || no "duplicate tx" "$r"
r=$(q "select starset_credit_purchase('$C','$T-2','gems_550:base',5900,'KRW','PLAY_STORE','SANDBOX')->>'gems' as g"); [ "$(v "$r" g)" = 550 ] && ok "a Play id with a base plan suffix is understood" || no "suffix" "$r"
r=$(q "select starset_credit_purchase('$C','$T-3','starter_pack',3900,'KRW','PLAY_STORE','SANDBOX')->>'gems' as g"); [ "$(v "$r" g)" = 300 ] && ok "the starter pack gives 300" || no "starter" "$r"
r=$(q "select starset_credit_purchase('$C','$T-4','starter_pack',3900,'KRW','PLAY_STORE','SANDBOX')->>'gems' as g"); [ "$(v "$r" g)" = 0 ] && ok "a second starter pack transaction gives nothing again" || no "starter twice" "$r"
r=$(q "select starset_credit_purchase('$C','$T-5','premium_pass',6500,'KRW','PLAY_STORE','SANDBOX')->>'premium' as p"); [ "$(v "$r" p)" = true ] && ok "the commander pass sets premium" || no "premium" "$r"
r=$(q "select starset_credit_purchase('$C','$T-6','nothing_like_this',1,'KRW','PLAY_STORE','SANDBOX')->>'credited' as c"); [ "$(v "$r" c)" = false ] && ok "an unknown product is not credited" || no "unknown product" "$r"
r=$(rpc starset_wallet "{\"p_install_id\":\"$C\"}"); [ "$(j "$r" "d['gems']")" = 950 ] && [ "$(j "$r" "d['premium']")" = True ] && [ "$(j "$r" "d['starter']")" = True ] && [ "$(j "$r" "d['purchases']")" = 5 ] && ok "the app sees 950 gems, premium, starter, 5 purchases" || no "wallet after buying" "$r"
spend "$C" "$(ref)" ship 900 >/dev/null
r=$(q "select starset_refund_purchase('$T-2')->>'taken' as t"); [ "$(v "$r" t)" = 50 ] && ok "a refund takes back only what is left (50 of 550)" || no "refund" "$r"
q "select starset_refund_purchase('$T-5')" >/dev/null
r=$(rpc starset_wallet "{\"p_install_id\":\"$C\"}"); [ "$(j "$r" "d['gems']")" = 0 ] && [ "$(j "$r" "d['premium']")" = False ] && ok "refunding the pass removes premium; balance never goes below 0" || no "after refund" "$r"

# ── transfer (reinstall + restore) ──
r=$(q "select starset_transfer(array['$B']::uuid[],'$A')->>'moved' as m"); [ "$(v "$r" m)" = 990 ] && ok "a transfer moves the old wallet's 990 gems" || no "transfer" "$r"
[ "$(gems "$A")" = 1050 ] && [ "$(gems "$B")" = 0 ] && ok "after the transfer the new wallet has 1050 and the old one 0" || no "transfer balances" "$(gems "$A") $(gems "$B")"

# ── data reset (wipe) ──
q "select starset_credit_purchase('$A','$T-7','premium_pass',6500,'KRW','PLAY_STORE','SANDBOX')" >/dev/null
R3=$(ref)
r=$(rpc starset_wipe "{\"p_install_id\":\"$A\",\"p_ref\":\"$R3\"}"); [ "$(j "$r" "d['wiped']")" = 1050 ] && [ "$(j "$r" "d['wallet']['gems']")" = 0 ] && [ "$(j "$r" "d['wallet']['premium']")" = True ] && ok "a data reset empties the gems (1050) but keeps the commander pass" || no "wipe" "$r"
earn "$A" "$(ref)" play "" 20 "$D0" >/dev/null
r=$(rpc starset_wipe "{\"p_install_id\":\"$A\",\"p_ref\":\"$R3\"}"); [ "$(j "$r" "d['wallet']['gems']")" = 20 ] && ok "the same reset request again does not wipe gems earned after it" || no "wipe repeat" "$r"
r=$(earn "$A" "$(ref)" ach first_blood 5 "$D0"); [ "$(j "$r" "d['credited']")" = 0 ] && ok "after a reset an achievement already paid is not paid again" || no "ach after wipe" "$r"

# ── rate limit (60 a minute) ──
E=$(id); last=""
for i in $(seq 1 61); do last=$(rpc starset_wallet "{\"p_install_id\":\"$E\"}"); done
[ "$(code "$last")" = 429 ] && ok "the 61st call in a minute is refused (429)" || no "rate limit" "$last"

# ── webhook door ──
r=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$URL/functions/v1/starset-purchase-webhook" -H "Authorization: wrong" -d '{}'); [ "$r" = 401 ] && ok "the webhook refuses a call without its secret (401)" || no "webhook auth" "$r"
# RevenueCat-shaped events with the real secret (keychain star-settlers-webhook-auth)
HOOK=$(security find-generic-password -a star-settlers-webhook-auth -s supabase -w)
hook(){ curl -s -m 30 -w ' %{http_code}' -X POST "$URL/functions/v1/starset-purchase-webhook" -H "Authorization: $HOOK" -H "Content-Type: application/json" -d "$1"; }
F=$(id); G=$(id)
r=$(hook "{\"event\":{\"type\":\"NON_RENEWING_PURCHASE\",\"app_user_id\":\"\$RCAnonymousID:abc\",\"aliases\":[\"$F\"],\"transaction_id\":\"$T-w1\",\"product_id\":\"gems_1200\",\"price\":12000,\"currency\":\"KRW\",\"store\":\"PLAY_STORE\",\"environment\":\"SANDBOX\"}}")
[ "$(code "$r")" = 200 ] && [ "$(gems "$F")" = 1200 ] && ok "webhook purchase credits the install id found among the aliases" || no "webhook credit" "$r"
r=$(hook "{\"event\":{\"type\":\"NON_RENEWING_PURCHASE\",\"app_user_id\":\"$F\",\"transaction_id\":\"$T-w1\",\"product_id\":\"gems_1200\"}}")
[ "$(gems "$F")" = 1200 ] && ok "webhook retry of the same transaction credits nothing" || no "webhook retry" "$r"
r=$(hook "{\"event\":{\"type\":\"TRANSFER\",\"transferred_from\":[\"$F\"],\"transferred_to\":[\"$G\"]}}")
[ "$(code "$r")" = 200 ] && [ "$(gems "$G")" = 1200 ] && [ "$(gems "$F")" = 0 ] && ok "webhook transfer moves the wallet to the restoring install" || no "webhook transfer" "$r"
r=$(hook "{\"event\":{\"type\":\"CANCELLATION\",\"cancel_reason\":\"CUSTOMER_SUPPORT\",\"app_user_id\":\"$G\",\"transaction_id\":\"$T-w1\",\"store\":\"PLAY_STORE\"}}")
[ "$(code "$r")" = 200 ] && [ "$(gems "$G")" = 0 ] && ok "webhook refund takes the gems back" || no "webhook refund" "$r"
r=$(hook "{\"event\":{\"type\":\"TEST\"}}"); [ "$(code "$r")" = 200 ] && ok "a RevenueCat test event is answered and ignored" || no "test event" "$r"

# ── clean up ──
q "delete from starset_purchases where install_id in ('$A','$B','$C','$E','$F','$G'); delete from starset_wallets where install_id in ('$A','$B','$C','$E','$F','$G'); delete from starset_calls where install_id in ('$A','$B','$C','$E','$F','$G')" >/dev/null
r=$(q "select (select count(*) from starset_wallets where install_id in ('$A','$B','$C','$E','$F','$G')) + (select count(*) from starset_ledger where install_id in ('$A','$B','$C','$E','$F','$G')) as n"); [ "$(v "$r" n)" = 0 ] && ok "test rows deleted" || no "cleanup" "$r"
echo "RESULT $pass passed, $fail failed"; [ $fail = 0 ]
