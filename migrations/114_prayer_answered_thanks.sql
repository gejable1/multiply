-- migrations/114_prayer_answered_thanks.sql
-- S87 -- when a prayer is marked answered, the system thanks everyone who
-- prayed for it, and the thank-you carries the requester's own praise note.
--
-- SHAPE. A trigger on prayer_requests fires exactly once per transition INTO
-- status='answered' (WHEN new.status='answered' AND old.status IS DISTINCT
-- FROM new.status -- a repeated tap on an already-answered request fires
-- nothing). It writes one notifications row per DISTINCT member in
-- prayer_intercessions for that request, excluding the requester (nobody is
-- thanked for praying for themselves), with a per-recipient dedup guard so
-- even a request answered, reopened, and answered again thanks each person
-- once.
--
-- WHY A TRIGGER, and why SECURITY DEFINER. notifications RLS is own-rows-only
-- (073): no member's JWT may insert a row for another recipient, which is
-- correct and stays correct. The trigger function runs as its owner,
-- deliberately crossing that line in the ONE narrow, audited way this feature
-- needs -- and it fires no matter which tool marks the answer (MMT today,
-- MLT/MD tomorrow), atomically with the update itself. search_path is pinned,
-- per definer-function hygiene.
--
-- CONTENT. Bilingual payload.en/payload.tl exactly as MMT's _mNotifText
-- expects (#438); legacy title/body columns are baked in the "EN <mid> TL" /
-- "EN\n\nTL" fallback convention so older renderers split them correctly.
-- The body names the requester UNLESS the request was anonymous, quotes a
-- short excerpt of the request so the intercessor remembers WHICH prayer, and
-- carries the praise note verbatim when one was written. payload also holds
-- request_id / answered_at / praise_note for future deep-linking.
--
-- FORWARD-ONLY: requests answered before this migration are not retroactively
-- thanked (a months-late system thank-you reads as noise, not gratitude).
--
-- Flat (#209), idempotent (create or replace + drop/create trigger),
-- self-verifying on its own effects (#403), ledger stamped (#402). Proved on
-- ephemeral PG16 under own-rows notifications RLS with an authenticated
-- invoker, and by deliberate failure (#413). Pure ASCII: the praying-hands
-- emoji ships as E'\U0001F64F'.

create or replace function public.notify_prayer_answered()
returns trigger
language plpgsql
security definer
set search_path = public
as $fn$
declare
  v_excerpt text;
  v_note    text;
  v_en_t    text;
  v_tl_t    text;
  v_en_b    text;
  v_tl_b    text;
begin
  v_excerpt := left(coalesce(new.body, ''), 60)
               || case when length(coalesce(new.body, '')) > 60 then '...' else '' end;
  v_note := nullif(trim(coalesce(new.praise_note, '')), '');

  v_en_t := 'Thank you for praying ' || E'\U0001F64F';
  v_tl_t := 'Salamat sa iyong panalangin ' || E'\U0001F64F';

  if new.is_anonymous or new.requester_name is null then
    v_en_b := 'A prayer you prayed for ("' || v_excerpt || '") has been answered.';
    v_tl_b := 'Nasagot na ang panalanging ipinanalangin mo ("' || v_excerpt || '").';
  else
    v_en_b := new.requester_name || '''s prayer ("' || v_excerpt || '") has been answered.';
    v_tl_b := 'Nasagot na ang panalangin ni ' || new.requester_name || ' ("' || v_excerpt || '").';
  end if;

  if v_note is not null then
    v_en_b := v_en_b || ' Their praise note: "' || v_note || '"';
    v_tl_b := v_tl_b || ' Ang kanyang praise note: "' || v_note || '"';
  end if;

  insert into public.notifications (recipient_id, kind, title, body, payload, church_id)
  select i.member_id,
         'prayer_answered_thanks',
         v_en_t || ' ' || E'\u00b7' || ' ' || v_tl_t,
         v_en_b || E'\n\n' || v_tl_b,
         jsonb_build_object(
           'en', jsonb_build_object('title', v_en_t, 'body', v_en_b),
           'tl', jsonb_build_object('title', v_tl_t, 'body', v_tl_b),
           'request_id',  new.id,
           'answered_at', new.answered_at,
           'praise_note', v_note),
         new.church_id
    from (select distinct pi.member_id
            from public.prayer_intercessions pi
           where pi.request_id = new.id) i
   where i.member_id is distinct from new.requester_id
     and not exists (select 1 from public.notifications n
                      where n.recipient_id = i.member_id
                        and n.kind = 'prayer_answered_thanks'
                        and n.payload->>'request_id' = new.id::text);
  return new;
end
$fn$;

revoke all on function public.notify_prayer_answered() from public;
revoke all on function public.notify_prayer_answered() from anon;

drop trigger if exists trg_prayer_answered_thanks on public.prayer_requests;
create trigger trg_prayer_answered_thanks
  after update on public.prayer_requests
  for each row
  when (new.status = 'answered' and old.status is distinct from new.status)
  execute function public.notify_prayer_answered();

-- ---- ledger stamp (#402/#212)
insert into public.schema_migrations (version, filename, note) values
  ('114','114_prayer_answered_thanks.sql','Answered-prayer gratitude loop: trigger on prayer_requests (transition into status=answered) writes a bilingual thank-you notification to every distinct intercessor except the requester, carrying the requester''s praise note verbatim plus a 60-char request excerpt; per-recipient dedup; SECURITY DEFINER with pinned search_path because notifications RLS is own-rows-only by design; forward-only, no retroactive thanks. Zero frontend changes: the MMT inbox renders payload.en/payload.tl generically.')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- ---- SELF-VERIFY -- asserts only THIS migration's own effects (#403), rerun-safe.
-- Expect: trigger_present 1, fn_secdef true, search_path_pinned true,
-- anon_cannot_exec true, all_ok PASS.
select
  (select count(*) from pg_trigger t join pg_class c on c.oid = t.tgrelid
    where t.tgname = 'trg_prayer_answered_thanks'
      and c.relname = 'prayer_requests' and not t.tgisinternal)               as trigger_present,
  (select p.prosecdef from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'notify_prayer_answered')      as fn_secdef,
  (select coalesce(p.proconfig::text, '') like '%search_path=public%'
     from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'notify_prayer_answered')      as search_path_pinned,
  (select not has_function_privilege('anon',
          'public.notify_prayer_answered()', 'execute'))                      as anon_cannot_exec,
  case when
       (select count(*) from pg_trigger t join pg_class c on c.oid = t.tgrelid
         where t.tgname = 'trg_prayer_answered_thanks'
           and c.relname = 'prayer_requests' and not t.tgisinternal) = 1
   and (select p.prosecdef from pg_proc p join pg_namespace n on n.oid = p.pronamespace
         where n.nspname = 'public' and p.proname = 'notify_prayer_answered')
   and (select coalesce(p.proconfig::text, '') like '%search_path=public%'
          from pg_proc p join pg_namespace n on n.oid = p.pronamespace
         where n.nspname = 'public' and p.proname = 'notify_prayer_answered')
   and (select not has_function_privilege('anon',
          'public.notify_prayer_answered()', 'execute'))
  then 'PASS' else 'FAIL' end                                                 as all_ok;
