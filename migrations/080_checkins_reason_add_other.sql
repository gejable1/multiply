-- 080_checkins_reason_add_other.sql
-- Fix: the S75 "Iba pa" check-in reason submits reason_code='other', but the
-- CHECK constraint from migration 054 (lcg_checkins_reason_chk) was never
-- widened to accept it -- so every "Iba pa" submission fails with
-- "violates check constraint lcg_checkins_reason_chk".
-- Widen the constraint to include 'other'. Flat, idempotent, self-verifying.

alter table public.lcg_leader_checkins drop constraint if exists lcg_checkins_reason_chk;
alter table public.lcg_leader_checkins add constraint lcg_checkins_reason_chk
  check (reason_code is null or reason_code in
    ('met_forgot_log','overwhelmed','need_coleader','unsure_meeting','scheduling','personal','okay','other'));

-- self-verify: expect chk_present = 1 and other_allowed = t
select
  (select count(*) from pg_constraint where conname='lcg_checkins_reason_chk') as chk_present,
  (select position('''other''' in pg_get_constraintdef(oid)) > 0
     from pg_constraint where conname='lcg_checkins_reason_chk') as other_allowed;
