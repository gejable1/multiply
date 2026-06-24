-- migrations/029_agape_cluster_guest_to_member.sql
-- Session 46 — Agape onboarding phase 2: flip the 15 Millete-cluster guest->full member.
-- Phase 1 (028) set church_id->Agape while they stayed is_external_user=true (guest). Now that
-- they're Agape members under live RLS, flip to is_external_user=false so they count as full
-- members and appear in Agape's statistical reports (which exclude guests + test). Same 15
-- explicit ids as 028 (Inv #166). Does NOT touch the Agape test member. RUN FLAT — Inv #209.
-- Idempotent. Self-verify (Inv #210): want members_now=15, guests_remaining=0.

UPDATE public.members
SET is_external_user = false
WHERE id IN (
  'd6a09bbe-aad0-4af2-ac67-664fd0fdf334',  -- Jojo Millete (pastor)
  'e5d27914-20ce-4f24-8d7f-a7b61d865be0',  -- Cristy Millete
  '77cde584-5088-4b1d-86fc-908809c2ce1b',
  '3714f474-1f23-4522-a050-79d26e8eaeb9',
  '855fb9cf-f3a6-4d00-951b-d838f326264e',
  '7ac36659-c70e-4380-905d-f22ea086b228',
  'da63a460-a198-4ead-a640-35aa7fcc18c6',
  'eddd8896-c130-4036-9fc5-99fb37d875b3',
  '94b69688-354a-4dd1-82c7-eeb83e7c3938',
  '567a031b-38b9-4d60-83f9-a7501e54c1bf',
  '912082b1-c3eb-42aa-a9fe-3ace0bd411ca',
  'd2a88674-b5c2-4ed6-9af5-f13d771b0360',
  '976f506d-d7f1-4beb-94d1-6ed3bef361c3',
  'e308a13d-3e5e-4b3a-a430-68d56955ea37',
  'f1c34d7e-e011-43a2-a427-16c7a689892a'
);

INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('029','029_agape_cluster_guest_to_member.sql','Agape onboarding phase 2: flip 15 Millete-cluster guest->full member')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();

-- self-verify (Inv #210) — want members_now=15, guests_remaining=0
SELECT
  count(*) FILTER (WHERE is_external_user = false) AS members_now,
  count(*) FILTER (WHERE is_external_user = true)  AS guests_remaining
FROM public.members
WHERE id IN (
  'd6a09bbe-aad0-4af2-ac67-664fd0fdf334','e5d27914-20ce-4f24-8d7f-a7b61d865be0','77cde584-5088-4b1d-86fc-908809c2ce1b',
  '3714f474-1f23-4522-a050-79d26e8eaeb9','855fb9cf-f3a6-4d00-951b-d838f326264e','7ac36659-c70e-4380-905d-f22ea086b228',
  'da63a460-a198-4ead-a640-35aa7fcc18c6','eddd8896-c130-4036-9fc5-99fb37d875b3','94b69688-354a-4dd1-82c7-eeb83e7c3938',
  '567a031b-38b9-4d60-83f9-a7501e54c1bf','912082b1-c3eb-42aa-a9fe-3ace0bd411ca','d2a88674-b5c2-4ed6-9af5-f13d771b0360',
  '976f506d-d7f1-4beb-94d1-6ed3bef361c3','e308a13d-3e5e-4b3a-a430-68d56955ea37','f1c34d7e-e011-43a2-a427-16c7a689892a'
);
