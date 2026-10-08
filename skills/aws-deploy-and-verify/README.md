# aws-deploy-and-verify

> A change isn't done until it's deployed to the cloud and you can **show** an artifact proving it works.

## What it does

- Gives the agent a 5-step closing loop for every task: static pre-checks → build → deploy to dev → verify with a real artifact → close out.
- Makes "done" mean a **shown artifact**: a screenshot of the dev CDN URL, a CloudWatch log line + request-id, a live API response, or a live resource.
- Stops the agent from "verifying" with a local dev server, emulator, or full-repo local typecheck.
- Prefers the pipeline for deploys, with a documented manual bridge (S3 sync + CloudFront invalidation, `lambda update-function-code`, targeted `terraform apply`).
- Catches two specific traps: a stale webview module cache that looks like a code bug, and Lighthouse lab numbers mistaken for the performance SLO.

## When to use it

- You just finished a web, API, or Terraform change on an AWS-serverless project.
- A task is about to be marked "done."
- The agent is about to run `npm run dev`, boot a simulator, or run a local full `tsc` "to check."
- A local preview keeps showing old output after an edit.
- Someone wants to chase a lab LCP number with SSR/prerendering.

**When not to use it:** docs/rules-only changes that deploy nothing, or a one-time CD bootstrap the pipeline can't do for itself.

## Where it goes

| Tool | Path | Scope |
|---|---|---|
| Cursor (project) | `.cursor/skills/aws-deploy-and-verify/` | **Recommended.** Project-level: it encodes a specific AWS deploy topology, so commit it with the repo it describes. |
| Open standard (project) | `.agents/skills/aws-deploy-and-verify/` | Same, for tools that read the open agent-skills layout. |
| Cursor (user-level) | `~/.cursor/skills/aws-deploy-and-verify/` | Not recommended — its steps assume one project's pipeline and buckets. |
| Claude Code | `.claude/skills/aws-deploy-and-verify/` | Project. |
| Codex | `.agents/skills/aws-deploy-and-verify/` | Project. Codex reads `.agents/skills/` (repo root and parents); `.codex/skills/` is legacy. |

Cursor auto-discovers skills at session start; the agent decides when to load this one by matching its `description` against the task.

## How it helps

- **Ended "claimed done" with nothing in AWS.** An early phase was reported complete with no user pool and broken Terraform behind it (F-C1, F-G1). Requiring a shown artifact made every "done" checkable.
- **Stopped local-emulation rabbit holes.** The trigger explicitly fires when the agent is tempted to start a local dev server, emulator, or full local typecheck, which the reference build found to diverge from the deployed topology.
- **Stopped a stale-preview edit loop.** A local webview kept serving old modules while `curl` showed new code; the skill now says to stop editing and verify on the deployed preview route (F-Z1).
- **Stopped chasing a structural lab number.** On a client-rendered SPA, throttled lab LCP sits around 7–8 s while real users see ~1.8 s; the skill makes FIELD (RUM p75) the SLO and lab a regression detector.

## Works best with

| Companion rule | Why |
|---|---|
| `cloud-first-verification.mdc` | Always-on rule that says the only pass/fail gate is cloud CI; this skill is the procedure that satisfies it. |
| `cicd-first.mdc` | Explains the pipeline's real semantics (CI vs deploy buildspec, path filtering, dev auto-deploy) that step 3 relies on. |
| `implementation-workflow.mdc` | Defines the Definition of Done and the Implementation Log that step 5 closes out. |

Copies of these rules are bundled in `./companion-rules/` so this folder is self-sufficient; the canonical versions live in `/rules/` and `scripts/sync-companions.sh` keeps them in sync.

## Provenance

| | |
|---|---|
| Born | 2026-06-16 (first deep retrospective, same day as `cloud-first-verification` and `cicd-first`) |
| Revisions | 4 |
| Findings absorbed | F-A1..A7, F-C1, F-C7, F-G1; later field-vs-lab performance (06-24), CSP report-only capture (F-P2), webview-cache trap (F-Z1, 07-22) |
| The incident that created it | The first deep retrospective mined 143 agent transcripts and produced 57 findings. The most common early failure was "claimed done with nothing deployed": a phase reported complete with no user pool and broken Terraform behind it. This skill turned "verify in the cloud, not on the laptop" into a closing checklist. |
| Lines / words | 72 / 731 at harvest (this copy adds Overview, When-NOT, and Anti-rationalization sections) |

## Install

```bash
cp -R skills/aws-deploy-and-verify <your-repo>/.cursor/skills/
cp -R skills/aws-deploy-and-verify <your-repo>/.agents/skills/
```

Then copy the companion rules: `cp skills/aws-deploy-and-verify/companion-rules/*.mdc <your-repo>/.cursor/rules/`

## Example

```text
You:   The order-export endpoint is fixed, mark the task done.
Agent: [loads aws-deploy-and-verify — "whenever a task needs to be proven done"]
       1. Read the diff (no stray files); pushed the feature branch → CI lint/typecheck/tests green.
       2. Pipeline Build stage bundled the API with esbuild; artifact present in the log.
       3. PR merged → dev pipeline deployed.
       4. Verify: GET /orders/export on dev → 200, 42 rows.
          CloudWatch request-id 7f3c…e1 shows no errors.
       5. Implementation Log updated (files, decision, date). No dev servers left running.
       Done, with the response and request-id above as evidence.
```

---

<sub>Part of the YV Labs rules & skills pack · Vidh Yasa · MIT · [all skills](../README.md)</sub>
