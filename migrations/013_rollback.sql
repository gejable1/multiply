DELETE FROM churches
WHERE slug = 'agape'
  AND NOT EXISTS (SELECT 1 FROM members WHERE members.church_id = churches.id);
