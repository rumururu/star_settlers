-- Star Settlers: "모든 데이터 초기화" in the game's settings empties the gem wallet.
-- The settings text promises gems are deleted for good while the Starter Pack and the Fleet Commander Pass come back,
-- so only the balance goes to 0: the purchase flags stay (the app gives their skins and crew again), and achievement
-- and day records stay (a reset cannot be used to claim the same achievement gems twice).
-- Same rules as 20261012000000_starset_wallet.sql: anon may call it for its own install id, idempotent by p_ref.
-- It can only lower a balance. Answers {ok, wiped, wallet}.

create or replace function public.starset_wipe(p_install_id uuid, p_ref text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare prior jsonb; w starset_wallets; res jsonb;
begin
  perform starset_gate(p_install_id);
  if p_ref is null or p_ref !~ '^[A-Za-z0-9_-]{8,64}$' then raise exception 'invalid ref' using errcode = '22023'; end if;
  select result into prior from starset_ledger where install_id = p_install_id and ref = p_ref;
  if prior is not null then return prior || jsonb_build_object('wallet', starset_wallet_json(p_install_id), 'repeat', true); end if;
  select * into w from starset_wallets where install_id = p_install_id for update;
  update starset_wallets set gems = 0, updated_at = now() where install_id = p_install_id;
  res := jsonb_build_object('ok', true, 'wiped', w.gems);
  insert into starset_ledger (install_id, ref, kind, gems, result) values (p_install_id, p_ref, 'wipe', -w.gems, res);
  return res || jsonb_build_object('wallet', starset_wallet_json(p_install_id));
end $$;

revoke all on function public.starset_wipe(uuid, text) from public, anon, authenticated;
grant execute on function public.starset_wipe(uuid, text) to anon;
