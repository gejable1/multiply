-- ============================================================================
-- 074_pathway_rungs_title_tl.sql   ·   Session 70
--
-- Backfill pathway_rungs.title_tl for all 148 base rungs (church_id IS NULL),
-- and repair three corrupted title_en values.
--
-- WHY: every reference rung shipped with title_tl = NULL, so the bilingual UI in
-- MLT and MMT silently showed English in BOTH language modes. The new member
-- celebration notification made this visible ("Your discipler sees 'Joy' growing
-- in you" had no Tagalog to show).
--
-- TRANSLATION POLICY (reviewed and approved by Pastor Gerry, row by row):
--   * 120 rungs TRANSLATED.
--   * 28 rungs KEEP English -- proper nouns: book titles (Mere Christianity,
--     The Making of a Leader), programs (APIIS, CCF Glorious Hope, IDC, BTLI,
--     EGR), and brands (CliftonStrengths). For these, title_tl is set EQUAL to
--     title_en on purpose, so the UI stops falling back and the decision is
--     explicit in the data rather than implied by a NULL.
--   * The three Filipino books (Usbong / Usad / Unlad) get their true Filipino
--     identity rather than the English gloss.
--
-- DATA REPAIRS (step 1): two rows stored the literal HTML entity "&amp;" instead
-- of "&", and one book title was accidentally doubled.
--
-- NOT DONE HERE: the six near-duplicate rungs (e.g. "Weekly Accountability Pair"
-- vs "... Partner") are LEFT AS-IS by Pastor's decision. Merging them would mean
-- deleting a rung, and pathway_progress FKs (level, rung_key) -- a delete would
-- destroy member progress. Any future merge needs a progress-migrating migration.
--
-- FLAT (#209). RERUN-SAFE (#210): step 1 is idempotent; step 2 only writes rows
-- whose title_tl is still NULL/blank, so re-running changes nothing and never
-- overwrites a church's later edit. Ledger-stamped (#212).
-- ============================================================================

-- ── STEP 1: repair corrupted title_en (must run BEFORE step 2, which matches on it)
UPDATE public.pathway_rungs
SET    title_en = 'Knows the gospel & own testimony', updated_at = now()
WHERE  church_id IS NULL AND title_en = 'Knows the gospel &amp; own testimony';

UPDATE public.pathway_rungs
SET    title_en = 'BTLI 102 & 103', updated_at = now()
WHERE  church_id IS NULL AND title_en = 'BTLI 102 &amp; 103';

UPDATE public.pathway_rungs
SET    title_en = 'Christian Coaching (Collins)', updated_at = now()
WHERE  church_id IS NULL AND title_en = 'Christian Coaching (Christian Coaching)';

-- ── STEP 2: backfill title_tl for all 148 base rungs
-- Matches on title_en, so a title repeated across levels (the fruit appear at
-- L1/L2/L3) is filled at EVERY level in one pass -- which is what we want.
UPDATE public.pathway_rungs r
SET    title_tl = v.tl,
       updated_at = now()
FROM  (VALUES
  ('Love', 'Pag-ibig'),
  ('Joy', 'Kagalakan'),
  ('Peace', 'Kapayapaan'),
  ('Patience', 'Pagtitiis'),
  ('Kindness', 'Kabaitan'),
  ('Goodness', 'Kabutihan'),
  ('Faithfulness', 'Katapatan'),
  ('Gentleness', 'Kahinahunan'),
  ('Self-control', 'Pagpipigil sa sarili'),
  ('Assurance of salvation', 'Katiyakan ng kaligtasan'),
  ('Baptism', 'Bautismo'),
  ('Daily devotional habit', 'Araw-araw na debosyon'),
  ('90-day devotional streak', '90-araw na tuloy-tuloy na debosyon'),
  ('Active small group member', 'Aktibong miyembro ng small group'),
  ('Led one person to Christ', 'Nakapag-akay ng isang tao kay Cristo'),
  ('Discipling my EOLO one', 'Dinidisciple ang aking EOLO'),
  ('2 disciples multiplied', 'Nakapagpadami ng 2 disciple'),
  ('Completed 1-yr discipleship', 'Natapos ang 1-taong discipleship'),
  ('Completed BTLI 101', 'Natapos ang BTLI 101'),
  ('Completed New Believers Orientation', 'Natapos ang New Believers Orientation'),
  ('Consistent prayer 2 yrs', 'Tapat sa panalangin sa loob ng 2 taon'),
  ('Consistent tithing 1 yr', 'Tapat sa ikapu sa loob ng 1 taon'),
  ('Elder confirmation', 'Kumpirmasyon bilang elder'),
  ('Family affirmation', 'Pagsang-ayon ng pamilya'),
  ('Financial integrity audit', 'Pagsusuri sa integridad sa pananalapi'),
  ('No active church discipline', 'Walang kasalukuyang disiplina sa iglesya'),
  ('No lifestyle inconsistencies', 'Walang di-pagkakatugma sa pamumuhay'),
  ('No moral failure 5 yrs', 'Walang moral na pagkakamali sa loob ng 5 taon'),
  ('Usbong (Filipino Devotional)', 'Usbong (Debosyonal)'),
  ('Usad (Growth Guide)', 'Usad (Gabay sa Paglago)'),
  ('Unlad (Filipino Discipleship)', 'Unlad (Gabay sa Discipleship)'),
  ('Mere Christianity', 'Mere Christianity'),
  ('Spiritual Leadership', 'Spiritual Leadership'),
  ('The Making of a Leader', 'The Making of a Leader'),
  ('The Master Plan of Evangelism', 'The Master Plan of Evangelism'),
  ('Multiply (Chan)', 'Multiply (Chan)'),
  ('Real-Life Discipleship (Putman)', 'Real-Life Discipleship (Putman)'),
  ('The Advantage (Lencioni)', 'The Advantage (Lencioni)'),
  ('Leadership Coaching (Stoltzfus)', 'Leadership Coaching (Stoltzfus)'),
  ('Disciplines of a Christian Coach (Webb)', 'Disciplines of a Christian Coach (Webb)'),
  ('Christian Coaching (Collins)', 'Christian Coaching (Collins)'),
  ('Happy Lies (Adams)', 'Happy Lies (Adams)'),
  ('Fresh Wind Fresh Fire', 'Fresh Wind Fresh Fire'),
  ('Still Sovereign', 'Still Sovereign'),
  ('Why Men Hate Going to Church', 'Why Men Hate Going to Church'),
  ('New Believers Orientation', 'Oryentasyon para sa Bagong Mananampalataya'),
  ('Conflict Resolution Workshop', 'Workshop sa Paglutas ng Alitan'),
  ('Gifts Discovery Workshop', 'Workshop sa Pagtuklas ng mga Kaloob'),
  ('Daily Bible Reading Plan', 'Plano sa Araw-araw na Pagbasa ng Biblia'),
  ('Preaching Practicum', 'Praktikum sa Pangangaral'),
  ('Entering Formation — Pipeline Orientation', 'Pagpasok sa Paghubog — Pipeline Orientation'),
  ('Biblical Counseling Level 1', 'Biblikal na Pagpapayo — Antas 1'),
  ('APIIS Masters Program', 'APIIS Masters Program'),
  ('CCF Glorious Hope', 'CCF Glorious Hope'),
  ('Coaching Certification (IDC)', 'Coaching Certification (IDC)'),
  ('Discipleship Coaching (IDC)', 'Discipleship Coaching (IDC)'),
  ('IDC Basic Discipleship Training', 'IDC Basic Discipleship Training'),
  ('EGR — Experiencing God Retreat', 'EGR — Experiencing God Retreat'),
  ('EGR Evangelism Retreat', 'EGR Evangelism Retreat'),
  ('EOLO Campaign Orientation', 'EOLO Campaign Orientation'),
  ('BTLI 101', 'BTLI 101'),
  ('BTLI 102 & 103', 'BTLI 102 & 103'),
  ('BTLI 104', 'BTLI 104'),
  ('BTLI 105', 'BTLI 105'),
  ('BTLI 106', 'BTLI 106'),
  ('Basic prayer', 'Pangunahing panalangin'),
  ('Basic prayer disciplines', 'Pangunahing disiplina sa panalangin'),
  ('Basic biblical teaching', 'Pangunahing pagtuturo ng Biblia'),
  ('Finding verses in the Bible', 'Paghanap ng talata sa Biblia'),
  ('Personal Bible study', 'Personal na pag-aaral ng Biblia'),
  ('Knows the gospel & own testimony', 'Alam ang ebanghelyo at sariling patotoo'),
  ('Sharing personal testimony', 'Pagbabahagi ng sariling patotoo'),
  ('Evangelism (EOLO)', 'Pagbabahagi ng Ebanghelio (EOLO)'),
  ('First EOLO invitation', 'Unang paanyaya sa EOLO'),
  ('Serving on a team', 'Paglilingkod sa isang team'),
  ('Group facilitation', 'Pamamatnubay ng grupo'),
  ('Small group facilitation', 'Pamamatnubay ng small group'),
  ('1-to-1 leader coaching', '1-to-1 na coaching ng lider'),
  ('Member care', 'Pag-aaruga sa miyembro'),
  ('Conflict mediation', 'Pamamagitan sa alitan'),
  ('Delegation basics', 'Batayan ng pagtatalaga ng gawain'),
  ('Performance feedback', 'Performance feedback'),
  ('Volunteer recruitment', 'Pangangalap ng boluntaryo'),
  ('Financial stewardship basics', 'Batayan ng pamamahala sa pananalapi'),
  ('Budget stewardship', 'Pamamahala sa badyet'),
  ('Sermon delivery', 'Paghahatid ng sermon'),
  ('Training design', 'Disenyo ng pagsasanay'),
  ('Strategic planning', 'Estratehikong pagpaplano'),
  ('Vision casting', 'Paghahayag ng vision'),
  ('Vision alignment', 'Pagkakatugma sa vision'),
  ('Culture shaping', 'Paghubog ng kultura'),
  ('Crisis leadership', 'Pamumuno sa krisis'),
  ('Succession planning', 'Pagpaplano ng paghalili'),
  ('Church multiplication', 'Pagpaparami ng iglesya'),
  ('Monthly Discipler 1-on-1', 'Buwanang 1-on-1 kasama ang Discipler'),
  ('Monthly Pastor 1-on-1', 'Buwanang 1-on-1 kasama ang Pastor'),
  ('Bi-monthly Coach Check-in', 'Check-in sa Coach tuwing ikalawang buwan'),
  ('Bi-monthly Life Coach', 'Life Coach tuwing ikalawang buwan'),
  ('Executive Coach (monthly)', 'Executive Coach (buwanan)'),
  ('First Steps Plan', 'Plano sa Unang Hakbang'),
  ('First Steps Plan w/ Discipler', 'Plano sa Unang Hakbang kasama ang Discipler'),
  ('Personal Growth Plan', 'Personal na Plano sa Paglago'),
  ('Personal Mission Statement', 'Personal na Pahayag ng Misyon'),
  ('Personal Calling Discernment', 'Pagkilala sa Personal na Tawag'),
  ('Strengths Development Plan', 'Plano sa Pagpapaunlad ng Lakas'),
  ('Leadership Reading Plan', 'Plano sa Pagbabasa para sa Pamumuno'),
  ('Daily Bible Reading + Journal', 'Araw-araw na Pagbasa ng Biblia + Journal'),
  ('Church Devotional Guide (daily)', 'Gabay sa Debosyon ng Iglesya (araw-araw)'),
  ('Salvation Journal', 'Journal ng Kaligtasan'),
  ('Sabbath Rhythm Plan', 'Plano sa Ritmo ng Sabbath'),
  ('Family Priority Covenant', 'Kasunduan sa Prayoridad ng Pamilya'),
  ('Preaching Feedback Loop', 'Feedback sa Pangangaral'),
  ('Team Health Review (Lencioni)', 'Pagsusuri sa Kalusugan ng Team (Lencioni)'),
  ('Accountability App Tracking', 'Pagsubaybay sa Accountability App'),
  ('EOLO Friend first-steps walk', 'Unang hakbang kasama ang EOLO Friend'),
  ('EGR Follow-up Care', 'Pag-aaruga matapos ang EGR'),
  ('CliftonStrengths Debrief', 'CliftonStrengths Debrief'),
  ('Daily Devotional + Journal', 'Araw-araw na Debosyon + Journal'),
  ('Daily Devotional Journal', 'Araw-araw na Journal ng Debosyon'),
  ('Weekly Church Attendance', 'Lingguhang Pagsimba'),
  ('Weekly Gathering Attendance', 'Lingguhang Pagdalo sa Pagtitipon'),
  ('Weekly Accountability Pair', 'Lingguhang Accountability Pair'),
  ('Weekly Accountability Partner', 'Lingguhang Accountability Partner'),
  ('Bi-weekly Accountability Trio', 'Accountability Trio tuwing ikalawang linggo'),
  ('Weekly Spiritual Director', 'Lingguhang Spiritual Director'),
  ('Monthly Board Accountability', 'Buwanang Accountability sa Board'),
  ('Scripture Memorization Plan', 'Plano sa Pagsasaulo ng Kasulatan'),
  ('Quarterly Journal Review', 'Kada-quarter na Pagsusuri ng Journal'),
  ('Journaling Discipline Audit', 'Pagsusuri sa Disiplina ng Journaling'),
  ('Annual Personal Retreat', 'Taunang Personal na Retreat'),
  ('Ministry Fasting Schedule', 'Iskedyul ng Pag-aayuno sa Ministeryo'),
  ('EOLO Invitation Habit', 'Ugali ng Pag-anyaya sa EOLO'),
  ('EOLO Partner Check-in', 'Check-in kasama ang EOLO Partner'),
  ('EOLO Spiritual Friend', 'Espirituwal na Kaibigan sa EOLO'),
  ('Basic Discipleship Self-Assessment', 'Pangunahing Self-Assessment sa Discipleship'),
  ('Salvation Assurance Inventory', 'Imbentaryo ng Katiyakan sa Kaligtasan'),
  ('Spiritual Readiness Inventory', 'Imbentaryo ng Espirituwal na Kahandaan'),
  ('Spiritual Disciplines Inventory', 'Imbentaryo ng Espirituwal na Disiplina'),
  ('Spiritual Gifts Diagnostic', 'Diagnostic ng mga Espirituwal na Kaloob'),
  ('Leadership Readiness Checklist', 'Checklist ng Kahandaan sa Pamumuno'),
  ('Leader Observation Report', 'Ulat sa Obserbasyon ng Lider'),
  ('Coaching Competency Rubric', 'Rubric sa Kakayahan sa Coaching'),
  ('Sermon Evaluation Rubric', 'Rubric sa Pagsusuri ng Sermon'),
  ('Teaching Practicum Score', 'Iskor sa Praktikum ng Pagtuturo'),
  ('Church Health Survey', 'Survey sa Kalusugan ng Iglesya'),
  ('Ministry Health Dashboard', 'Dashboard sa Kalusugan ng Ministeryo'),
  ('360° Peer Feedback', '360° na Feedback mula sa Kapwa'),
  ('360° Elder Evaluation', '360° na Pagsusuri sa Elder')
) AS v(en, tl)
WHERE  r.church_id IS NULL
  AND  r.title_en = v.en
  AND  (r.title_tl IS NULL OR btrim(r.title_tl) = '');

-- ── LEDGER
INSERT INTO public.schema_migrations (version, filename, note)
VALUES (74, '074_pathway_rungs_title_tl.sql',
        'Backfill title_tl for all 148 base pathway_rungs (120 translated, 28 proper nouns kept as English); repair 3 corrupted title_en (2x &amp; entity, 1x doubled book title). Near-duplicate rungs left as-is per Pastor.')
ON CONFLICT (version) DO NOTHING;

-- ── SELF-VERIFY (rerun until true) ──────────────────────────────────────────
-- EXPECT: still_missing = 0, entity_leaks = 0, doubled_title = 0,
--         and total_base = 148 distinct titles.
SELECT
  count(*) FILTER (WHERE title_tl IS NULL OR btrim(title_tl) = '')            AS still_missing,
  count(*) FILTER (WHERE title_en LIKE '%&amp;%' OR title_tl LIKE '%&amp;%')  AS entity_leaks,
  count(*) FILTER (WHERE title_en = 'Christian Coaching (Christian Coaching)') AS doubled_title,
  count(DISTINCT title_en)                                                     AS distinct_titles,
  count(*)                                                                     AS total_rows
FROM public.pathway_rungs
WHERE church_id IS NULL;
