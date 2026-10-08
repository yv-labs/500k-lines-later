---
name: debugging-with-evidence-ledger
description: Debug a stubborn, flaky, or recurring failure with an evidence/attempt ledger so fixes hit the real (often stacked) root causes, not symptoms. Use when a fix doesn't stick; when a change fixes one variant but breaks another (rotating/whack-a-mole failures); when the same class of error recurs or a test is flaky; after ~2 failed fix attempts on the same problem. Application-agnostic.
license: MIT
metadata:
  author: YV Labs by Vidh Yasa
  source: https://github.com/yv-labs/500k-lines-later
  provenance: see README.md in this folder
---

# Debugging with an Evidence Ledger

## Overview

A discipline for hard bugs: find the **complete** root cause and prove the fix, instead of
chasing the next green run. Counterpart to the always-on `systematic-debugging` rule —
this is the detailed workflow to run when you're at risk of looping.

## When to Use
- A fix didn't hold, OR a change "fixed one thing and broke another," OR the same failure
  class recurs, OR ~2 reactive attempts have already failed.
- A failure rotates across variants (browser / shard / env / OS / role / region / run).

**When NOT to use:** a first-attempt bug with an obvious, deterministic cause and a single
variant — just fix it. For red/flaky Playwright suites, use `e2e-flake-triage` (it builds on this).

Rotating symptoms almost always mean **stacked root causes** — more than one independent
defect. Stop fixing the visible symptom; instrument first.

## Workflow

```
- [ ] 1. Frame: write the failure as a falsifiable claim + how you measure pass/fail
- [ ] 2. Capture a baseline: reproduce against real evidence, record current state of ALL variants
- [ ] 3. Open the ledger: list untested hypotheses
- [ ] 4. One change per hypothesis; record result per variant; never repeat a dead end
- [ ] 5. Keep going until ALL root causes are explained (not just the loud one)
- [ ] 6. Verify holistically across every independently-failing variant; quarantine residual flake
```

### 1–2. Frame and baseline
State what "fixed" means and how you'll measure it. Reproduce against the **real** system
(on a cloud project, the deployed environment — see `cloud-first-verification.mdc`; never
"passes on my machine").
Record the current pass/fail of every variant that can fail independently — that grid is
what tells you whether a later change *helped*, *did nothing*, or *regressed* something.

### 3–4. Ledger
Maintain a short table in the most durable place available (a `docs/.../*_LOG.md`, the PR /
commit body, or a scratch file). Minimum columns:

```
| attempt | hypothesis | change made | result per variant | conclusion / next |
```

Rules:
- **One change per attempt** — bundling changes makes the result uninterpretable.
- **Record every attempt, including failures** — the ledger's main job is to stop you
  re-trying a dead end you already disproved.
- **Track per variant**, e.g. `chromium ✅ / firefox ❌ / webkit ✅`. A single-variant green
  is not "fixed."

### 5. Find ALL root causes
For each failure, you must be able to say: *why it failed*, *why the change addresses that
cause*, and *why it won't regress the variants that previously passed*. If you can't, it's a
symptomatic fix — keep digging. When symptoms shift (A passes, B now fails), that's evidence
of a **second** root cause, not success.

❌ Symptom patches: bump timeout, add blanket retry, widen a selector, relax a limit "to get
green." ✅ Root-cause fixes: explain and remove the actual cause.

### 6. Verify and close
Re-run the full set of independently-failing variants and show the evidence (logs, IDs,
screenshots). If a case is inherently timing-sensitive, **quarantine it explicitly** with an
owner + deadline in a flaky register rather than leaning on retries in the blocking lane.

## Worked example (real, from the reference build)
E2E suite kept "rotating": a fix made Chromium pass while Firefox failed, then vice versa.
The ledger (per test × browser × run) revealed **three stacked root causes**, not one:
1. **FC-10** CloudFront `custom_error_response` masked missing assets as the HTML shell →
   dynamic `import()` failed with a MIME error (edge-cached). Fixed with a viewer-request
   SPA-routing function so assets 404 honestly.
2. **FC-11** WAF per-IP rate limit throttled the single CI NAT IP mid-suite → intermittent
   403s on whatever request crossed the threshold. Raised for dev only.
3. **FC-12** an admin "approve" click raced a workflow state transition, Firefox-only timing.
   Fixed by waiting for the state transition before clicking.
Only after all three were addressed did the suite go green across browsers; the last
inherently-timing-sensitive test was quarantined with a deadline, not retried into "green."

The lesson: without the per-variant ledger, each single fix looked like progress while
silently surfacing the next hidden cause — the definition of a debugging loop.

## Anti-rationalization

| If you catch yourself thinking… | Do this instead |
|---|---|
| "Chromium is green now, so it's fixed." | Check every variant; a single-variant green is not "fixed." |
| "B started failing after I fixed A — unrelated, I'll fix B next." | Treat the shift as evidence of a second root cause; add it to the ledger. |
| "I'll try two or three changes at once to save a run." | One change per attempt, or the result is uninterpretable. |
| "Let me just bump the timeout / add a retry." | Explain the actual cause first; those are symptom patches. |
| "I think I tried that already…" | If it's not in the ledger, you don't know — write every attempt down. |
