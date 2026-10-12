// RevenueCat → Star Settlers gem wallet (supabase/wallet/migrations/20261012000000_starset_wallet.sql).
// Deployed on the claires-ranch project next to claire-purchase-webhook (verify_jwt off: RevenueCat sends its own
// header). The Authorization header must equal the secret STARSET_WEBHOOK_AUTH, set in RevenueCat's webhook settings
// for the Star Settlers project. The app's RevenueCat user id is its install id (a UUID); anything else is ignored.
//
//   NON_RENEWING_PURCHASE / INITIAL_PURCHASE → starset_credit_purchase (once per transaction)
//   CANCELLATION of a one-time purchase (refund) → starset_refund_purchase
//   TRANSFER (restore on a new install) → starset_transfer: the wallet follows the store account's purchases
import { createClient } from "npm:@supabase/supabase-js@2.45.4";

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const uuids = (xs: unknown): string[] => (Array.isArray(xs) ? xs : []).filter((x) => typeof x === "string" && UUID.test(x));

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("method", { status: 405 });
  const expected = Deno.env.get("STARSET_WEBHOOK_AUTH");
  if (!expected || req.headers.get("authorization") !== expected) return new Response("unauthorized", { status: 401 });

  let payload: any;
  try { payload = await req.json(); } catch { return new Response("bad json", { status: 400 }); }
  const e = payload?.event ?? {};
  const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, { auth: { persistSession: false } });

  // the purchase may arrive under the anonymous RevenueCat id first: prefer an install-id alias
  const install = uuids([e.app_user_id, ...(e.aliases ?? []), e.original_app_user_id])[0];

  if (e.type === "NON_RENEWING_PURCHASE" || e.type === "INITIAL_PURCHASE") {
    if (!install) return Response.json({ ignored: "no install id" });
    const { data, error } = await db.rpc("starset_credit_purchase", {
      p_install_id: install, p_transaction_id: e.transaction_id ?? e.id, p_product_id: e.product_id,
      p_price: e.price ?? null, p_currency: e.currency ?? null, p_store: e.store ?? null, p_environment: e.environment ?? null,
    });
    if (error) { console.error("credit", error); return new Response("credit failed", { status: 500 }); } // RevenueCat retries
    return Response.json(data);
  }
  if (e.type === "CANCELLATION" && (e.cancel_reason === "CUSTOMER_SUPPORT" || e.cancel_reason === "REFUND" || e.store === "PLAY_STORE")) {
    const { data, error } = await db.rpc("starset_refund_purchase", { p_transaction_id: e.transaction_id ?? e.id });
    if (error) { console.error("refund", error); return new Response("refund failed", { status: 500 }); }
    return Response.json(data);
  }
  if (e.type === "TRANSFER") {
    const to = uuids(e.transferred_to)[0];
    const from = uuids(e.transferred_from);
    if (!to || from.length === 0) return Response.json({ ignored: "no install ids" });
    const { data, error } = await db.rpc("starset_transfer", { p_from: from, p_to: to });
    if (error) { console.error("transfer", error); return new Response("transfer failed", { status: 500 }); }
    return Response.json(data);
  }
  return Response.json({ ignored: e.type ?? "unknown" });
});
