# debugging-with-evidence-ledger

> When a fix moves the failure instead of removing it, you have more than one root cause, so stop patching and start a ledger.

## What it does

- Switches the agent from reactive edits to a 6-step systematic workflow once a bug resists ~2 fixes.
- Makes it frame the failure as a falsifiable claim and capture a baseline of **every** variant (browser, shard, env, OS, role, region, run).
- Keeps an attempt ledger (`attempt | hypothesis | change | result per variant | conclusion`) so no dead end is retried.
- Enforces one change per attempt and treats a shifting symptom as evidence of a second root cause.
- Closes only after holistic verification across all variants, quarantining any residual flake with an owner and deadline.

## When to use it

- A fix didn't stick, or it fixed one variant and broke another.
- The same class of failure keeps coming back.
- A test is flaky, or failures rotate across browsers/shards/environments.
- Two reactive fix attempts on the same problem have already failed.

**When not to use it:** a first-attempt bug with an obvious, deterministic cause. For red Playwright suites, use `e2e-flake-triage`, which builds on this.

## Where it goes

| Tool | Path | Scope |
|---|---|---|
| Cursor (project) | `.cursor/skills/debugging-with-evidence-ledger/` | Good default: commit it so the team and cloud agents get it. |
| Open standard (project) | `.agents/skills/debugging-with-evidence-ledger/` | Same, for tools that read the open agent-skills layout. |
| Cursor (user-level) | `~/.cursor/skills/debugging-with-evidence-ledger/` | Also reasonable: it's application-agnostic and useful in every repo. |
| Claude Code | `.claude/skills/debugging-with-evidence-ledger/` | Project. |
| Codex | `.agents/skills/debugging-with-evidence-ledger/` | Project. Codex reads `.agents/skills/` (repo root and parents); `.codex/skills/` is legacy. |

Cursor auto-discovers skills at session start; the agent decides when to load this one by matching its `description` against the task.

## How it helps

- **Ended a 3-root-cause flake saga.** A cross-browser E2E suite flip-flopped (Chromium green/Firefox red, then the reverse) until the user asked for "a better way to track error fixing to avoid loops." The per-variant ledger exposed three stacked causes: CDN error responses masking missing JS chunks as HTML, a WAF rate limit throttling CI's single NAT IP, and a Firefox-only UI race (F-I1, F-I4).
- **Caught a moving symptom on a load test.** Fixing a capacity cap moved the error from "sequence exhausted" to "duplicate key"; it was read as a second cause on the first pass, explicitly citing the rule (F-Y1 → F-Y2).
- **Read a race fix from the logs, not the test.** A race fix whose failure flipped from "2 rows" to "0 rows" was diagnosed from service logs (F-L3).
- **Treated an intermittent security probe as a defect**, not as "flaky" (F-N5).

## Works best with

| Companion rule | Why |
|---|---|
| `systematic-debugging.mdc` | The always-on trigger: "after 2 failed fix attempts, switch to systematic mode." This skill is the workflow it points to. |
| `parallel-delegation.mdc` | If you fan hypotheses out to subagents, hand them ground-truth evidence and verify their diffs; a "done" report is a claim. |

Copies of these rules are bundled in `./companion-rules/` so this folder is self-sufficient; the canonical versions live in `/rules/` and `scripts/sync-companions.sh` keeps them in sync.

## Provenance

| | |
|---|---|
| Born | 2026-06-27 (E2E reliability retrospective, same day as `systematic-debugging`) |
| Revisions | 1 |
| Findings absorbed | F-I1, F-I4 |
| The incident that created it | The E2E suite runs every spec on Chromium, Firefox and WebKit against the deployed dev app. Each fix turned one browser green and another red, and the agent flip-flopped until the user called out "symptomatic fixes." There was no per-(test × browser × run) tracking, so three independent defects looked like one. |
| Lines / words | 80 / 742 at harvest (this copy adds Overview, When-NOT, and Anti-rationalization sections) |

## Install

```bash
cp -R skills/debugging-with-evidence-ledger <your-repo>/.cursor/skills/
cp -R skills/debugging-with-evidence-ledger <your-repo>/.agents/skills/
```

Then copy the companion rules: `cp skills/debugging-with-evidence-ledger/companion-rules/*.mdc <your-repo>/.cursor/rules/`

## Example

```text
You:   The upload test is red again. Your last two fixes didn't hold.
Agent: [loads debugging-with-evidence-ledger — "after ~2 failed fix attempts"]
       Claim: "upload completes on staging in all 3 regions, 5/5 runs."
       Baseline: eu ✅ us ❌ ap ❌ (intermittent).
       | # | hypothesis              | change            | eu | us | ap | conclusion        |
       | 1 | presign URL expiry       | ttl 60→300 s      | ✅ | ❌ | ✅ | ap fixed; us not  |
       | 2 | us bucket CORS missing   | add CORS rule     | ✅ | ✅ | ✅ | second root cause |
       Both causes explained; neither change can affect eu. Re-running 5× per region.
```

---

<sub>Part of the YV Labs rules & skills pack · Vidh Yasa · MIT · [all skills](../README.md)</sub>
