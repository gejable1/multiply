# BTLI Slide Deck — Generic Generation Spec (ALL lessons)

**Status:** ACTIVE standard · **Applies to:** every BTLI lesson deck (`btli1_lN_slides.pptx`), not just Lesson 1
**Established:** from the L2 "Bible Meditation" build (Session 57) · **Owner:** Pastor Gerry · Rosehill Christian Church
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

## 2. Deck identity & design tokens

- **Slide size:** 10 × 5.625 in.
- **Branding (generic only, Inv #26):** top-left `MULTIPLY · DISCIPLE-MAKING PIPELINE` (grey `808080`, ~9pt, bold). **No church name.** No internal folder slugs in visible text.
- **Page number:** bottom-right `N / <total>` (grey, right-aligned, ~9pt). Renumber the whole deck whenever slides are added.
- **Colors:** navy `0F1C34` (dark slides), cream `FEFCF8` (light slides + light text on dark), gold `D4A84A` (movement headers/accents), badge gold `D4AF37`, ink `141628` (text on gold), grey `808080` (chrome).
- **Sandwich is fine** — content slides alternate dark/light — **but question slides are ALWAYS dark navy** (a recognizable "stop-and-answer" beat).
- **Fonts:** Calibri for body/added elements (safe, true-to-width). Keep the deck's existing serif headers.

---

## 3. The 5 movements (Rosehill canon)

`⚡ PUKAW` Engage · `📖 TUKLAS` Discover · `💡 TALAKAY` Discuss/Deepen · `🙌 GAWIN` Practice · `🏠 DALHIN` Take Home.
Content-slide header format: **`<emoji> <MOVEMENT> · <SECTION>`**, gold, bold, centered, top (~0.5").

---

## 4. Timer badge on EVERY slide

- **Shape:** gold rounded pill, top-right at `[7.88", 0.13", 2.0" × 0.4"]` (the top-right corner is free; the page number lives bottom-right — no collision).
- **Text:** `⏱ {slide-min} min · ⌛{cumulative}` — cumulative = target elapsed (MM:SS) when you LEAVE that slide. **Slide 1** = `⏱ {total}-min lesson`.
- **Distribution rule:**
  1. Take each movement's total minutes **from the facilitator guide**.
  2. Split that total across the movement's slides (**including its question slides**), whole minutes preferred.
  3. Each movement's slice-sum must equal the movement total; all movements must sum to the lesson core time.
  4. Cumulative clock runs across the whole deck (last slide = core time).
- The badge is a **static reference**, not a live countdown. (An optional live-countdown HTML companion can be produced **on request** — it is NOT part of the standard deck.)

*Worked example — L2, 55-min core:* PUKAW 8 · TUKLAS 15 · TALAKAY 12 · GAWIN 12 · DALHIN 8. Split across 23 slides so every slide (content + question) carries its own minute and the cumulative lands on 55:00 at the last slide.

---

## 5. Dedicated question slides (the headline rule)

- **Every question a participant answers in their Participant Guide gets its OWN slide.** Never cram questions onto content slides.
- **One slide per question.** If a block has several (e.g., a 3-question table discussion), make **3 separate question slides**, each individually placed and individually timed.
- **Placement = "the right place":** immediately AFTER the content slide that sets it up (soil-choice question right after the 4-soils slide; "agree with Tozer?" right after the Tozer quote; the reflection right after the teaching it reflects on).
- **Design (always dark navy):**
  - Brand top-left · page number bottom-right · timer badge top-right (as above).
  - Movement header, gold, centered: **`<emoji> <MOVEMENT> · TANONG`**.
  - Gold pill tag, centered just below the header: **`📋 Participant Guide Question`** — put this on **every** question slide so it is unmistakable which questions are answered in the guide.
  - The question itself: large **cream, bold, centered**, vertically middle.
  - Gold **italic sub-instruction** underneath, e.g. `Sa tables — pag-usapan.` / `Tahimik na sagot — isulat sa Participant Guide.` / `Sa katabi mo — 90 segundo bawat isa.`
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
- **Length:** generous — roughly **200–700 characters per slide**. Do not be terse. Richer is better here.

---

## 7. Wording & language conventions

- Say **"Participant Guide"** everywhere — **never "Booklet."** (Sweep both slide text and notes; verify zero remain.)
- Keep the lesson's bilingual Taglish voice as the source guides use it.
- No church-specific names or internal slugs in visible slide text.

---

## 8. Build & QA workflow (per lesson)

1. **Read the pptx skill** (`/mnt/skills/public/pptx/SKILL.md`) before touching any deck.
2. **Pull** the lesson's `slides.pptx` + `facilitator.html` + `participant.html` from repo.
3. **Extract:** movement minutes + flow + pastoral content (facilitator); every participant question (participant).
4. **Compute timing:** movement totals from the guide, split across all slides incl. new question slides.
5. **Build with `python-pptx`:**
   - Create each **question slide from scratch** (full-slide navy rect → brand → page-num → gold movement header → `📋 Participant Guide Question` gold tag → large cream question → gold italic sub). Building from scratch (not cloning) keeps them uniform.
   - **Reorder** the slide-id list to drop each question slide into its right place.
   - **Renumber** every page number to `i / <newTotal>`.
   - Add the **timer badge** to every slide.
   - Set **generous notes** on every slide.
   - Sweep **"Booklet" → "Participant Guide"** in any pre-existing slide text.
6. **QA** (render `soffice → pdftoppm`, inspect images):
   - New question slides: tag + question fit, no overflow.
   - A renumbered content slide: correct `i / total`, badge not overlapping content.
   - Confirm: exactly **1 timer badge + notes on every slide**, **zero "Booklet"**, page numbers renumbered.
7. **Deliver the `.pptx`.** (HTML slides / PDF / live-timer are separate, only if requested.)

---

## 9. Per-lesson reuse checklist (copy this)

- [ ] Pulled facilitator + participant + slides from repo (fresh)
- [ ] Movement minutes captured from facilitator guide
- [ ] Listed every Participant-Guide question → one dedicated dark question slide each, placed right after its setup
- [ ] `📋 Participant Guide Question` tag on every question slide
- [ ] Timer badge on every slide; per-slide minutes sum to movement totals; cumulative ends at core time
- [ ] Generous, guide-sourced notes on every slide (Presenter View ready)
- [ ] "Participant Guide" everywhere (zero "Booklet")
- [ ] Page numbers renumbered to new total
- [ ] Rendered + visually QA'd; delivered the .pptx

---

*Standard born from L2 "Bible Meditation." Every BTLI deck: questions on their own slides, time on every slide, the whole guide in the notes — so the shepherd can look up from the paper and into the faces.* ✦
