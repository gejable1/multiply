-- 069_meeting_guides_library.sql
-- Meeting Prep Phase B: provenance + library opt-in + Tagalog columns, and a
-- leader-read RLS branch so LC leaders can browse the church's shared library.
-- Flat, rerunnable, self-verifying. (Table + base RLS came from 047.)

ALTER TABLE public.lc_meeting_guides
  ADD COLUMN IF NOT EXISTS source_guide_id   uuid REFERENCES public.lc_meeting_guides(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS shared_to_library boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS facilitator_md_tl text,
  ADD COLUMN IF NOT EXISTS participant_md_tl text;

-- helper: is the caller an LC leader? SECURITY DEFINER so it ignores members RLS
CREATE OR REPLACE FUNCTION auth_is_leader()
  RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $fn$
  SELECT COALESCE((SELECT is_facilitator FROM members WHERE id = auth_member_id()), false)
$fn$;

-- extend read policy: own rows; members read own LCL's published; leaders read the
-- church library (published AND opted-in). Same church always (outer clause).
DROP POLICY IF EXISTS lcmg_select ON lc_meeting_guides;
CREATE POLICY lcmg_select ON lc_meeting_guides FOR SELECT TO authenticated
  USING (
    church_id = auth_church_id() AND (
      lcl_id = auth_member_id()
      OR (status = 'published' AND lcl_id = auth_discipler_id())
      OR (status = 'published' AND shared_to_library = true AND auth_is_leader())
    )
  );

INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('069','069_meeting_guides_library.sql','Phase B: source_guide_id + shared_to_library + *_md_tl columns; auth_is_leader(); leader church-library read branch on lcmg_select')
ON CONFLICT (version) DO NOTHING;

-- self-verify (#210)
SELECT
  (SELECT count(*) FROM information_schema.columns
     WHERE table_name='lc_meeting_guides'
       AND column_name IN ('source_guide_id','shared_to_library','facilitator_md_tl','participant_md_tl')) AS new_cols,
  (SELECT count(*) FROM pg_proc WHERE proname='auth_is_leader') AS has_fn,
  (SELECT count(*) FROM pg_policies WHERE tablename='lc_meeting_guides' AND policyname='lcmg_select') AS has_policy;
