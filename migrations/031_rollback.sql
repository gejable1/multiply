DELETE FROM public.system_settings WHERE church_id=(SELECT id FROM public.churches WHERE slug='agape');
