# BTLI Slide Deck — Generic Generation Spec (ALL lessons)

**Status:** ACTIVE standard · **Applies to:** every BTLI lesson deck (`btli1_lN_slides.pptx`), not just Lesson 1
**Established:** from the L2 "Bible Meditation" build (Session 57) · **Revised:** L7 "v3" design language (own-canvas builds), confirmed through the L13–L14 builds (Sep 22, 2026) · **Owner:** Pastor Gerry · Rosehill Christian Church
**Scope:** governs the **FORM** of the facilitator PPTX (timers, question slides, tags, notes, wording).
Per-lesson **content** still comes from that lesson's own spec + its facilitator/participant guides. This doc supersedes the "Slides" conventions in any per-lesson spec.

> One-line intent: **a facilitator should be able to teach the whole lesson from the deck alone — questions on their own slides, time on every slide, and a full script in the notes — without opening the facilitator guide.**

---

## 1. Source inputs (pull fresh from repo every time — never guess, #56/#223)

For lesson N, pull from `lessons/<btli-slug>/`:
| File | Gives us |
|---|---|
| `btli1_lN_facilitator.html` | Movement **pacing** (minutes per movement), flow, pastoral notes, stories, cautions, activity tips |
| `btli1_lN_participant.html` | The **questions participants answer in their Participant Guide** → these become dedicated question slides |
| `btli1_lN_slides.pptx` | The existing **content slides** to enhance (base deck) |

The facilitator guide's **movement minutes are the source of truth for timing.** The participant guide's **questions are the source of truth for the question slides.**

---

## 2. Deck identity & design tokens — **v3 (L7+) house standard**

- **Slide size:** **13.33 × 7.5 in** (pptxgenjs `LAYOUT_WIDE`). *(The 10 × 5.625 size is the legacy L2–L6-era standard; do not use it for new decks.)*
- **Branding (generic only, Inv #26):** question slides carry top-left `MULTIPLY · DISCIPLE-MAKING PIPELINE` (grey `808080`, 11pt Calibri bold). Cover carries the full pipeline kicker line. **No church name.** No internal folder slugs in visible text.
- **Page number:** bottom-right `N / <total>` — content slides: 12pt DM Sans bold, cream-on-dark / ink-on-light; question slides: 12pt Calibri grey. Renumber the whole deck whenever slides are added.
- **Colors (dual palette):**
  - *Content slides:* forest green `2A5C40` (dark bg) · parchment `F6F2E7` (light bg) · ink `1A2E22` (text on light) · cream `FDFBF6` (text on dark) · deep green `1F4530` (accent on light) · gold `D4A854` (accent on dark).
  - *Question slides (always):* navy `0F1C34` bg · question-cream `FEFCF8` text · question-gold `D4A84A` headers/hints · pill gold `D4AF37` · pill ink `141628` · grey `808080` chrome.
- **Sandwich is fine** — content slides alternate green/parchment — **but question slides are ALWAYS dark navy** (a recognizable "stop-and-answer" beat).
- **Fonts:** **Playfair Display** (serif — titles/headlines) · **DM Sans** (content body, badges, page numbers) · **Calibri** (question slides + chrome: brand line, timer pill).
- **Content font scale (L13+ sizes):** serif titles 44–52pt (cover 72pt shrink-fit) · body lines 23–28pt · verse/quote italics 22–26pt. One step bigger than the L7 originals — projector-readable from the back row.
- **Section badge (content slides):** centered outlined rounded pill at y 0.6", h 0.45" — 20pt DM Sans bold, green outline/text on light, gold on dark. **Keep badge text SHORT (≈ 24 characters max)** and size `badgeW` generously: LibreOffice/PowerPoint render fonts wider than estimated, and a badge that wraps outside its pill is the single most recurring visual defect (bit us on L13 and again on L14 — five badges). When a badge wraps, **shorten the text** (e.g. `KASANAYAN 1 · PAKIELAM`, not the full skill name) — the full name lives in the title and notes.
- **Measured auto-layout (Inv #472):** content slides are built **own-canvas** — each text line's height is computed from an average-character-width factor (serif ≈ 0.56–0.60 × pt, sans ≈ 0.545 × pt) and stacked with explicit gaps; the generator prints an `OVERFLOW` warning when the stack passes y 6.9". Never eyeball-position; never trust a build that logged an overflow.

---

## 3. The 5 movements (Rosehill canon)

`⚡ PUKAW` Engage · `📖 TUKLAS` Discover · `💬 TALAKAY` Discuss/Deepen · `🙌 GAWIN / TUGON` Practice/Respond · `🏠 DALHIN` Take Home.
- The 4th movement's name follows the lesson's own facilitator guide: **GAWIN** in the early decks, **TUGON** from L13 onward.
- Question-slide movement headers use: `⚡ PUKAW · TANONG` · `📖 TUKLAS · TANONG` · `💬 TALAKAY · TANONG n` · `🙌 TUGON · TANONG` · `📕 DALHIN · TANONG`.
- On v3 content slides the movement is carried by the **section badge** (see §2) and the speaker-notes header, not a separate gold header line.

---

## 4. Timer badge on EVERY slide

- **Shape:** gold (`D4AF37`) rounded pill, top-right at `[10.88", 0.15", 2.2" × 0.42"]` on the wide canvas — 11pt Calibri bold, ink `141628`, centered (the page number lives bottom-right — no collision).
- **Text:** `⏱ {slide-min} min · ⌛{cumulative}` — cumulative = target elapsed (MM:SS) when you LEAVE that slide. **Slide 1** = `⏱ {total}-min lesson`.
- **Distribution rule:**
  1. Take each movement's total minutes **from the facilitator guide**.
  2. Split that total across the movement's slides (**including its question slides**), whole minutes preferred.
  3. Each movement's slice-sum must equal the movement total; all movements must sum to the lesson core time.
  4. Cumulative clock runs across the whole deck (last slide = core time).
- The badge is a **static reference**, not a live countdown. (An optional live-countdown HTML companion can be produced **on request** — it is NOT part of the standard deck.)

*Worked examples:* **L2, 55-min core** — PUKAW 8 · TUKLAS 15 · TALAKAY 12 · GAWIN 12 · DALHIN 8 across 23 slides, landing 55:00. **L13/L14, 60-min core** — PUKAW 8 · TUKLAS 25 · TALAKAY 12 · TUGON 10 · DALHIN 5 across 32 slides, landing 01:00. The gate is mechanical: per-slide minutes sum to movement totals, cumulative pills are monotonic, and the last slide's pill equals the core time.

---

## 5. Dedicated question slides (the headline rule)

- **Every question a participant answers in their Participant Guide gets its OWN slide.** Never cram questions onto content slides.
- **One slide per question.** If a block has several (e.g., a 3-question table discussion), make **3 separate question slides**, each individually placed and individually timed.
- **Placement = "the right place":** immediately AFTER the content slide that sets it up (soil-choice question right after the 4-soils slide; "agree with Tozer?" right after the Tozer quote; the reflection right after the teaching it reflects on).
- **Design (always dark navy — the L7 anatomy, exact):**
  - Brand top-left (11pt Calibri bold grey) · page number bottom-right (12pt Calibri grey) · timer pill top-right (as §4).
  - Movement header at `[1.0", 0.72"]`: **`<emoji> <MOVEMENT> · TANONG`** — 28pt Calibri bold, question-gold `D4A84A`, left-aligned.
  - Gold pill tag centered at `[4.17", 1.58", 5.0" × 0.55"]`: **`📋 Participant Guide Question`** — 16pt Calibri bold, ink on pill gold — on **every** question slide so it is unmistakable which questions are answered in the guide.
  - The question itself at `[1.0", 2.35", 11.33" × 3.55"]`: Calibri **bold question-cream**, top-aligned, sized by length — **54pt ≤ 80 chars · 44pt ≤ 170 · 36pt above**.
  - Question-gold **sub-instruction** at y 6.2", 26pt, e.g. `Sa tables — pag-usapan.` / `Isulat muna sa participant guide — 1-2 sasagot.` / `Silent writing. Konkreto. Hindi vague.`
- A content slide that happens to display a question (e.g., a quote slide) still gets its **own** question slide after it if that question is answered in the guide — keep the quote slide as the visual, add the question slide next.

---

## 6. Speaker notes on EVERY slide — generous, self-facilitating

- **Goal:** the lecturer never opens the facilitator guide mid-lesson. Everything they need is in the notes (view via **Presenter View**: Slide Show → Use Presenter View, or Alt+F5).
- Each note pulls from the facilitator guide and includes:
  - Movement + this-slide minutes + cumulative target (e.g., `TALAKAY ~2 min (target 28:00)`).
  - What to **say/do** on this slide.
  - The **exact question(s)** to ask (verbatim), tagged `PARTICIPANT GUIDE QUESTION` on question slides.
  - **Pastoral notes** ("celebrate, don't shame the misses"; "watch which role people pick — data for follow-up").
  - **Stories / illustrations / cautions** (told in full, so no lookup needed).
  - **Activity tips** ("push for specifics: 'ngayong linggo' not 'in the future'").
- **Length:** generous — roughly **200–700 characters per slide**, **minimum 4 note lines per slide** (cover's header line exempt). Do not be terse. Richer is better here.
- **Format (v3, hard rule):** **one sentence per paragraph.** pptxgenjs writes multi-line notes as literal `\r\n` inside a single paragraph; the build pipeline post-processes the pptx (binary-safe unzip → split each CRLF-bearing notes paragraph into real `<a:p>` paragraphs → rezip) so Presenter View shows clean separate lines. Every note line ends with terminal punctuation.
- **Stories in full:** every illustration the facilitator must tell (Disney, Moody's shoes, Banaue…) is written out **complete** in the notes of its slide — never "tell the story here." The notes header line is `MOVEMENT · N min (target MM:SS)`.

---

## 7. Wording & language conventions

- Say **"Participant Guide"** everywhere — **never "Booklet."** (Sweep both slide text and notes; verify zero remain.)
- Keep the lesson's bilingual Taglish voice as the source guides use it.
- No church-specific names or internal slugs in visible slide text.

---

## 8. Build & QA workflow (per lesson)

**Two build modes.** *(A) Own-canvas generation* — the v3 standard for every new lesson deck (L7+): the whole deck is generated from a single `pptxgenjs` script (`build_lN_deck.js`), no base deck. *(B) Enhance-an-existing-deck* (`python-pptx`) — legacy mode, kept only for retrofitting old decks; follow the original steps in this doc's history if ever needed.

**Own-canvas pipeline (the standard):**
1. **Read the pptx skill** (`/mnt/skills/public/pptx/SKILL.md`) before touching any deck.
2. **Pull fresh sources** — the lesson's design lock / source books, `facilitator.html`, `participant.html`. Movement minutes come from the facilitator guide; participant questions come from the participant guide, verbatim.
3. **Write the generator** (`build_lN_deck.js`): shared helpers (`base / pill / pageNum / badge / notes / content / question`) carried verbatim from the previous lesson's generator, then the per-slide content array. Every slide declares its movement, minutes, badge, lines, and full notes.
4. **Build & post-process:** `node build_lN_deck.js` → **CRLF notes splitter** (binary-IO unzip/rezip; see §6) → `validate.py` must report ALL PASS.
5. **Gate battery (all mechanical, all mandatory):**
   - page numbers sequential `1..N`;
   - question-slide count matches the plan;
   - timer pills **monotonic**, last slide lands exactly on core time;
   - ≥ 4 note lines per slide, every line terminally punctuated, zero residual CRLF *inside* `<a:t>` content (the XML-declaration CRLF is pptxgenjs noise — harmless);
   - placeholder grep (TODO/TBD/XXX/lorem/FIXME) returns nothing.
6. **Visual QA (mandatory, never skipped):** `soffice → pdftoppm` render → **contact sheets of every slide** → eyeball every sheet. The recurring defect class is **badge text wrapping outside its pill** — fix by shortening text (§2), rebuild, re-render the fixed slides, confirm.
7. **Deliver the `.pptx`** and keep the generator source — the deck must be exactly reproducible by re-running the pipeline. (HTML slides / PDF / live-timer are separate, only if requested.)

---

## 9. Per-lesson reuse checklist (copy this)

- [ ] Sources pulled fresh (design lock / books + facilitator + participant guides)
- [ ] Movement minutes captured from facilitator guide; participant questions verbatim from participant guide
- [ ] Generator written with shared v3 helpers; every Participant-Guide question → one dedicated navy question slide, placed right after its setup
- [ ] `📋 Participant Guide Question` tag on every question slide
- [ ] Timer pill on every slide; per-slide minutes sum to movement totals; pills monotonic; last slide lands on core time
- [ ] Notes: ≥ 4 lines/slide, one sentence per paragraph (CRLF splitter run), stories in full, terminal punctuation
- [ ] validate.py ALL PASS · placeholder grep clean · "Participant Guide" everywhere (zero "Booklet")
- [ ] Contact-sheet visual QA of EVERY slide — badges inside pills, no overflow, then re-render any fixed slides
- [ ] Delivered the .pptx + kept the generator source (exact rebuild possible)

---

*Standard born from L2 "Bible Meditation." Every BTLI deck: questions on their own slides, time on every slide, the whole guide in the notes — so the shepherd can look up from the paper and into the faces.* ✦

## Running order — the check every deck build must pass

A facilitator runs the class from the slides alone. That is the whole point of
putting the participant-guide questions into the deck, and it is why every slide
carries a printed running number: **"7 / 21"**. The number tells the facilitator
where they are and how much of the lesson remains.

When questions are inserted into an existing deck, the printed number and the
slide's real position can drift apart. The facilitator finds out in front of the
class.

### The rule

Every deck build finishes by running:

```bash
python3 tools/check_slide_order.py lessons/btli101_xrw5fg/*.pptx
```

It walks the slides in **deck order** and asserts that each slide's printed
running number equals its position. Exit 0 = clean. Exit 1 = at least one deck
has a real problem.

A deck in which **no slide carries a running number FAILS** as *unverifiable*,
rather than passing silently. Three decks are in that state today — **L5, L6 and
L11** — so their order cannot be checked by any means. That is a real gap for the
facilitator, not a tooling nicety.

### The trap the tool exists to avoid

**PowerPoint does not store running order in the slide part filenames.** It stores
it in `ppt/presentation.xml` under `<p:sldIdLst>`, resolved through
`ppt/_rels/presentation.xml.rels`. A slide inserted third is still `slide17.xml`
on disk, and that is entirely normal.

Auditing by filename reports every slide after the insertion point as misordered.
This produced a false alarm on PR #283, where 19 of 21 slides were declared broken
and all 21 were in fact correct — the questions had been inserted properly and only
the measurement was wrong.

> A defect uniform across everything you measured is more likely a fault in the
> measurement than in the thing measured. (Invariant #429)

The tell was there: every original slide was shifted by exactly the number of
slides inserted before it. A pattern that uniform is an instrument error, not
authoring error.

### When adding questions to an existing deck

1. Insert the question slides at their pedagogical position, not at the end. A
   "why did you rate yourself that way?" follow-up belongs immediately after the
   rating, while the answer is still live — not fourteen slides later.
2. Renumber every slide's printed `N / total` for the new total.
3. Run the check. It should report `PASS` with the new slide count.
4. Notes pages should match the slide count; media should be unchanged.

A drop in on-disk file size is not by itself a problem — a rebuilt deck is often
smaller because it is deflated rather than stored. Compare **uncompressed** part
sizes before concluding anything was lost.

---

## Changelog

- **Sep 22, 2026 (L14 build):** Spec brought current with the v3 (L7+) own-canvas standard as-built through L13–L14: wide 13.33×7.5 canvas, dual green/parchment + navy palette, Playfair/DM Sans/Calibri, L13+ font scale, exact question-slide anatomy, timer-pill geometry, badge-shortening rule (recurring wrap defect), one-sentence-per-paragraph notes via CRLF splitter, own-canvas measured auto-layout (Inv #472), full gate battery + mandatory contact-sheet visual QA, GAWIN/TUGON movement naming. Legacy python-pptx enhance mode retained as mode B.
- **Session 57 (L2 build):** Standard established.
