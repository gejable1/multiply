# Claude Code — Setup Checklist (MULTIPLY)

A short path from zero to your first CC session. You're IT, so this is ~15 minutes once.

## One-time setup
1. **Install Claude Code.** Easiest = the **native installer** (no Node.js needed), or `npm i -g @anthropic-ai/claude-code` (needs Node 18+). Verify with `claude --version`.
   - Requires a **paid Claude plan** (Pro/Max/Team/Enterprise or API/Console) — the free plan doesn't include CC. You have one.
   - Docs: https://docs.claude.com/en/docs/claude-code/overview · npm: https://www.npmjs.com/package/@anthropic-ai/claude-code
   - Prefer a GUI? There's a **VS Code** extension and a **Desktop** app too.
2. **Clone the repo:**
   ```
   git clone https://github.com/gejable1/multiply.git
   cd multiply
   ```
3. **Drop `CLAUDE.md` into the repo root** (the file I just made), commit it. Your `HANDOFF.md`, `MULTIPLY_INVARIANTS.md`, etc. are already in the repo — CC reads them.
4. **Set up git push auth** (GitHub Personal Access Token or SSH key) so CC can `git push`.
5. *(Optional — only for lesson/PPTX work)* install **LibreOffice** and **Playwright/Chromium** locally so CC can render-verify PPTX and browser-test.

## Each session
1. `cd multiply && claude`
2. First message: **"Read CLAUDE.md and HANDOFF.md, then tell me the top pending item."**
3. Work normally. CC edits files in the repo → **review the diff (`git diff`)** → let CC commit + push.
4. If `multiply_shared.js` changed, make sure CC bumped `?v=` across all HTML. Then **hard-refresh / relaunch the PWA**.
5. **Smoke-test on your phone** (live Supabase) — your job, not CC's.
6. At close, type **`m.md`** to regenerate HANDOFF + INVARIANTS, then commit them.

## Guardrails (keep these habits)
- **Keep SQL in the Supabase SQL editor.** Don't give CC database credentials / service-role key. CC writes the idempotent SQL; you run it.
- **Review every diff before pushing.** CC has direct filesystem + git access — powerful, but you stay the gate.
- **One commit per coherent change**, with a clear message — easy to revert if a deploy misbehaves.

## What stays here (this chat)
Design, strategy, "should we build X?", lesson-content decisions, and anything where you'd rather
talk it through before code. Use CC for the repo grunt-work (multi-file edits, bumps, commits, deploys);
use this chat for thinking. They share the same `HANDOFF.md`/`INVARIANTS` brain.
