# aws-serverless-project-bootstrap

> Foundations done late are the most expensive mistakes you'll make, so do them all in Phase 0, before the first feature.

## What it does

- Runs an 8-item Phase 0 checklist for a greenfield AWS-serverless repo (Lambda, API Gateway, Aurora/DynamoDB, Cognito, Terraform).
- Wires **CodeCommit → CodePipeline → CodeBuild** in Terraform with a real deploy stage from day one, and makes one remote the single source of record.
- Provisions the cloud dev environment and moves all config to SSM Parameter Store / Secrets Manager (no committed `.env`).
- Builds shared foundations before handlers: an RFC-4122 id factory, shared Zod schemas, db/auth/response/error layers, and a structured logger.
- Gates lint at `--max-warnings 0` for **every** package and bakes in test hygiene (frozen clock, `TZ=UTC`, clean runner exit).

## When to use it

- Day one of a new serverless project, before any feature task.
- You're defining the pipeline, dev environment, config store, or shared layers.
- An existing project is about to start features without a real deploy stage, managed config, or linting.

**When not to use it:** a mature project whose foundations already exist. Use `aws-deploy-and-verify` for the per-change loop.

## Where it goes

| Tool | Path | Scope |
|---|---|---|
| Cursor (project) | `.cursor/skills/aws-serverless-project-bootstrap/` | **Recommended.** Project-level: it's an AWS-stack-specific checklist; commit it in the repo being bootstrapped. |
| Open standard (project) | `.agents/skills/aws-serverless-project-bootstrap/` | Same, for tools that read the open agent-skills layout. |
| Cursor (user-level) | `~/.cursor/skills/aws-serverless-project-bootstrap/` | Possible if you start many AWS-serverless repos, but project-level keeps it visible to the team and to cloud agents. |
| Claude Code | `.claude/skills/aws-serverless-project-bootstrap/` | Project. |
| Codex | `.agents/skills/aws-serverless-project-bootstrap/` | Project. Codex reads `.agents/skills/` (repo root and parents); `.codex/skills/` is legacy. |

Cursor auto-discovers skills at session start; the agent decides when to load this one by matching its `description` against the task.

## How it helps

- **CI/CD on day one, not at the end.** In the reference build the deploy pipeline arrived late, config was hand-made, and ESLint/tsconfig stayed broken for months. The checklist puts all of that before the first feature.
- **A deploy stage that actually deploys.** The reference build's dev infra pipeline once ran plan → manual approval with no Apply stage, so approving it did nothing and drift piled up (F-I3). Step 2 requires a real, implemented deploy stage.
- **One remote of record.** CodeCommit became the sole remote after a manual mirror proved fragile; step 2 says to push to it directly and confirm a real push lands before feature work.
- **No warning pile.** Lint-from-day-one was added on 2026-06-17 because "a perpetual warning pile trains everyone to ignore red."
- **No time-bomb fixtures.** The same day added deterministic-test lessons: hard-coded near dates rot silently, so freeze the clock and set `TZ=UTC`.

## Works best with

| Companion rule | Why |
|---|---|
| `cicd-first.mdc` | The pipeline-semantics rulebook: dev auto-deploy vs prod approval, CI vs deploy buildspec, trigger-level path filtering. Step 2 builds what this rule assumes. |
| `terraform-infra.mdc` | IaC standards and operational hygiene (conservative module flags, import out-of-band changes) for the dev stack in step 3. |
| `static-analysis-and-logging.mdc` | The lint-every-package and structured-logging-only rules behind steps 5 and 6. |
| `local-environment-hygiene.mdc` | One clone on a normal path, version parity with CI, verify the push landed — the environment the bootstrap depends on. |

Copies of these rules are bundled in `./companion-rules/` so this folder is self-sufficient; the canonical versions live in `/rules/` and `scripts/sync-companions.sh` keeps them in sync.

## Provenance

| | |
|---|---|
| Born | 2026-06-16 (first deep retrospective) |
| Revisions | 3 |
| Findings absorbed | F-B1..B7, F-E1..E3, F-D5; lint/logging + deterministic-test lessons (2026-06-17) |
| The incident that created it | The first deep retrospective (143 transcripts, 57 findings) showed that the costliest problems came from foundations added late: deploys were hand-run because CI/CD arrived near the end, and the first real pipeline gate surfaced a backlog of unrelated debt. This skill front-loads that work into Phase 0. |
| Lines / words | 83 / 785 at harvest (this copy adds Overview, When-to-Use, and Anti-rationalization sections) |

## Install

```bash
cp -R skills/aws-serverless-project-bootstrap <your-repo>/.cursor/skills/
cp -R skills/aws-serverless-project-bootstrap <your-repo>/.agents/skills/
```

Then copy the companion rules: `cp skills/aws-serverless-project-bootstrap/companion-rules/*.mdc <your-repo>/.cursor/rules/`

## Example

```text
You:   New repo. Lambda + API Gateway + Aurora + Cognito, Terraform. Let's start on the
       signup feature.
Agent: [loads aws-serverless-project-bootstrap — "start of a greenfield AWS serverless project"]
       Before signup, Phase 0 isn't done:
       - [ ] Pipeline: no deploy stage yet → adding CodePipeline + buildspec with a real deploy.
       - [ ] Config: .env.example is the only config → moving to SSM /<project>/dev/...
       - [ ] Shared: no id factory or logger → adding both before the first handler.
       - [ ] Lint: api/ has no ESLint → flat config, --max-warnings 0 in pre_build.
       I'll push a real commit through the pipeline to dev, then start signup.
```

---

<sub>Part of the YV Labs rules & skills pack · Vidh Yasa · MIT · [all skills](../README.md)</sub>
