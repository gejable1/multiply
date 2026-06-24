INSERT INTO public.system_settings (church_id, meta)
SELECT
  (SELECT id FROM public.churches WHERE slug='agape'),
  ( ss.meta
    - 'last_edited_at' - 'last_edited_by'
    - 'greeting_updated_at' - 'greeting_updated_by'
    - 'headsup_settings_updated_at' - 'headsup_settings_updated_by'
    - 'instrument_versions_updated_at' - 'instrument_versions_updated_by'
    - 'instrument_redesign_dates'
  ) || jsonb_build_object('version', 1)
FROM public.system_settings ss
JOIN public.churches c ON c.id = ss.church_id AND c.slug='rosehill'
WHERE NOT EXISTS (
  SELECT 1 FROM public.system_settings x
  JOIN public.churches cc ON cc.id = x.church_id WHERE cc.slug='agape'
);
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('031','031_seed_agape_system_settings.sql','Seed Agape system_settings (copy-as-template from Rosehill meta, stripped audit + instrument dates)')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();
SELECT c.slug, s.id, s.church_id, (s.meta ? 'profile_edit_greeting') AS has_greeting
FROM public.system_settings s JOIN public.churches c ON c.id=s.church_id ORDER BY s.id;
