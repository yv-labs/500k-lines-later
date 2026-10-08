# e2e-flake-triage

> Flaky-passed-on-retry is NOT green: track every (test × browser × run) cell, find the one cause behind all of them, and require 3 clean runs.

## What it does

- Makes the agent append a **Run Ledger** row (every blocking cell × browser) for each E2E build *before* doing anything else, and diff it against the previous row to catch regressions.
- Pulls per-shard blob reports (screenshot, video, `error-context.md`) instead of reading the aggregate count.
- Forces a written **unifying root cause**: one condition that explains the failure on every browser and earlier run.
- Accepts only regression-neutral fixes, preferably at the shared layer (readiness signal, common helper), with the neutrality argument stated.
- Gates "fixed" on all 3 browsers green for ≥3 consecutive runs with no code or baseline changes in between.
- Has a separate playbook for visual-snapshot flakes: JS-driven animation, scoped reduced-motion, CI-image baselines, and the loading-spinner baseline trap.

## When to use it

- Any red or flaky Playwright/E2E run.
- You're about to "fix a test," harden a helper, or re-run hoping for green.
- A previously-green test fails on a different browser or run.
- A `toHaveScreenshot` baseline mismatches.

**When not to use it:** a deterministic unit-test failure, or a product bug that fails identically everywhere.

## Where it goes

| Tool | Path | Scope |
|---|---|---|
| Cursor (project) | `.cursor/skills/e2e-flake-triage/` | **Recommended.** Project-level: it references the project's E2E CodeBuild project, report bucket, and flake log. |
| Open standard (project) | `.agents/skills/e2e-flake-triage/` | Same, for tools that read the open agent-skills layout. |
| Cursor (user-level) | `~/.cursor/skills/e2e-flake-triage/` | Not recommended: replace the placeholders per project instead. |
| Claude Code | `.claude/skills/e2e-flake-triage/` | Project. |
| Codex | `.codex/skills/e2e-flake-triage/` | Project. |

Cursor auto-discovers skills at session start; the agent decides when to load this one by matching its `description` against the task.

## How it helps

- **Broke a cross-browser whack-a-mole loop.** Fixes kept moving the red cell between Chromium and Firefox. The matrix exposed three stacked causes: CDN error responses masking missing chunks as HTML (with an edge-cached MIME error), a WAF per-IP rate limit on CI's single NAT IP, and a Firefox-only state-transition race (F-I1).
- **Caught blank visual baselines.** A readiness wait passed on the `<Suspense>` spinner, so every lazy route's cold-cache light-mode baseline captured the loader instead of the page. The skill now waits for the chunk to finish and says to eyeball the PNGs (a light≪dark byte size is the tell).
- **Stopped "passes locally, fails in CI" from a partial push.** A partial push left stale baseline PNGs in the remote while the local tree looked right; the skill now says to confirm the remote blob (F-I5).
- **Stopped declaring victory on one green run.** The ≥3-consecutive-green gate and "a flaky-passed cell is not green" replaced judging progress by the aggregate failure count.

## Works best with

| Companion rule | Why |
|---|---|
| `testing-standards.mdc` | No time-bombs, clean runner exit, no whack-a-mole, and the source of "flaky-passed-on-retry is NOT green." |
| `testing-quality.mdc` | Test stack, CI gates, and how to read test/load output correctly. |
| `systematic-debugging.mdc` | The always-on anti-loop trigger (2 failed attempts → systematic mode + attempt ledger) that this skill specializes for E2E. |

Copies of these rules are bundled in `./companion-rules/` so this folder is self-sufficient; the canonical versions live in `/rules/` and `scripts/sync-companions.sh` keeps them in sync.

## Provenance

| | |
|---|---|
| Born | 2026-06-27 (E2E reliability retrospective) |
| Revisions | 3 |
| Findings absorbed | F-I1, F-I5, F-J4, F-K1 |
| The incident that created it | The cross-browser E2E suite against the deployed dev app kept rotating failures: each fix greened one browser and reddened another. The agent flip-flopped until the user stopped it and asked for a way to track fixes that avoids loops. The missing piece was a per-(test × browser × run) Run Ledger that makes regressions visible. |
| Lines / words | 101 / 1,112 at harvest (this copy adds Overview, When-to-Use, and Anti-rationalization sections) |

## Install

```bash
cp -R skills/e2e-flake-triage <your-repo>/.cursor/skills/
cp -R skills/e2e-flake-triage <your-repo>/.agents/skills/
```

Then copy the companion rules: `cp skills/e2e-flake-triage/companion-rules/*.mdc <your-repo>/.cursor/rules/`

## Example

```text
You:   checkout.spec failed on webkit this time. Can you fix the test?
Agent: [loads e2e-flake-triage — "a previously-green test fails on a different browser"]
       Run Ledger row appended for build 214: checkout chromium ✅ firefox ✅ webkit ❌.
       Diff vs build 213: profile.spec firefox went ✅→❌ → P0 regression from my last change.
       Blob reports: both fail waiting on the cart before the auth session rehydrates.
       Unifying cause: specs act before session rehydrate finishes (class FC-4).
       Fix: shared readiness helper waits on the app's `session-ready` signal; fast
       browsers already pass it, so no green cell can regress.
       Not marking FC-4 fixed until 3 consecutive all-browser green runs.
```

---

<sub>Part of the YV Labs rules & skills pack · Vidh Yasa · MIT · [all skills](../README.md)</sub>
