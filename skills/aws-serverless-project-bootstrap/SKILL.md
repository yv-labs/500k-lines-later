---
name: aws-serverless-project-bootstrap
description: Bootstrap a new AWS-serverless project so CI/CD, cloud-dev and shared foundations are right from day one. Use at the start of a greenfield serverless project (Lambda + API Gateway + Aurora/DynamoDB + Cognito + Terraform), when setting up "Phase 0", or when defining the pipeline, dev environment, config store, lint gates, or shared layers (id factory, schemas, logger) before feature work.
license: MIT
metadata:
  author: YV Labs by Vidh Yasa
  source: https://github.com/yv-labs/500k-lines-later
  provenance: see README.md in this folder
---

# AWS-Serverless Project Bootstrap (Phase 0)

## Overview

The most expensive mistakes on past projects came from doing foundational work **late**:
CI/CD deploy arrived near the end, config was hand-made, ESLint/tsconfig were broken for
months, and IDs/schemas weren't shared. Do all of it in Phase 0, before any feature.

## When to Use
- Day one of a greenfield serverless repo, before the first feature task.
- An existing project has no real deploy stage, hand-made `.env` config, or unlinted packages,
  and you're about to start feature work anyway.

**When NOT to use:** a mature project whose pipeline, config, and shared layers already exist —
use `aws-deploy-and-verify` for the per-change loop instead.

## Phase 0 checklist

```
- [ ] 1. Clean repo bootstrap (no template remnants)
- [ ] 2. CI/CD pipeline wired with a real deploy stage
- [ ] 3. Cloud dev environment provisioned via Terraform
- [ ] 4. Config via SSM/Secrets Manager (no committed .env)
- [ ] 5. Shared foundations: id factory, Zod schemas, response/error/auth + logger layers
- [ ] 6. Lint/type/test config CI-correct, centralized, and gated at 0 warnings — every package
- [ ] 7. Decide the local-dev posture explicitly (default: cloud-first)
- [ ] 8. Test hygiene baked in: frozen clock, TZ=UTC, clean runner teardown
```

**1. Clean bootstrap.** Start from an agreed template with **no leftover scaffolding**
(e.g. no Lovable/Supabase remnants, no stray ports). Pin one dev port (5173). Remove unused
generators from `package.json` and lockfile in the same commit.

**2. CI/CD first.** Define **CodeCommit → CodePipeline → CodeBuild** in Terraform, one pipeline
per package (web/api/infra) per env. Each `buildspec.*.yml` has real **install → lint/test →
build → deploy** stages — the deploy stage is implemented now, not stubbed. Wire type and
coverage **gates** before features. **Make CodeCommit the single remote of record and push to it
directly** — don't rely on a manual GitHub→CodeCommit mirror (it silently goes stale and breaks
the trigger). In Phase 0, install `git-remote-codecommit` on `PATH` and set the remote to
`codecommit::<region>://<profile>@<repo>`; pushes auth via AWS SigV4 (`AWS_PROFILE=...`), no
GitHub creds/SSH. Verify a real push lands before feature work.

**3. Cloud dev env.** Provision the full dev stack in Terraform (VPC, Aurora + RDS Proxy,
DynamoDB, Cognito, Lambdas, API Gateway, S3/CloudFront, SES/SNS, WAF, monitoring). Keep
`staging`/`prod` at structural parity so promotion works later. Bootstrap remote state
(S3 + DynamoDB lock) once per account.

**4. Config.** Build-time and runtime config come from **SSM Parameter Store**
(`/<project>/<env>/...`) and **Secrets Manager**. No committed `.env` files. CodeBuild reads
SSM at build time and writes the env it needs.

**5. Shared foundations** (build these before handlers):
- A **shared RFC-4122-valid id factory** — never hand-roll UUID-shaped strings (they pass
  Postgres but fail `z.string().uuid()`).
- **Shared Zod schemas** as the single source of entity shapes; derive TS types via
  `z.infer`.
- Shared `db` (RDS Proxy), `auth`/RBAC middleware, `responses`, `errors`, `validators`,
  `notifications` layers. IAM for RDS-Proxy Lambdas must grant `rds-db:connect`.
- A **shared structured logger** from the start — **AWS Lambda Powertools `Logger`** or Lambda
  native JSON logging, instantiated outside the handler. Pick explicit levels; **never bare
  `console.log`**. Skipping this leads to ad-hoc `console` + `eslint-disable` sprawl that's
  expensive to undo later.

**6. Lint/type/test config.** ESLint **flat config** (matching the ESLint major version),
fixed once and centrally — for **every package (web AND api/infra)**, not just the frontend; a
backend with `tsc` as its only gate leaves security-critical code unlinted. Add `lint`/`lint:fix`
scripts and wire `npm run lint` into each buildspec `pre_build` (before `typecheck`) at an
effective `--max-warnings 0`. When a rule fires en masse, **triage** (scope config over-reach off
for the right `files`, fix genuine bugs, adopt a principled rule option) — never blanket-disable,
never let a warning backlog accumulate. `tsconfig` for build scripts includes `@types/node`.
Exclude generated/mobile/coverage/IaC dirs from the Vite watcher (`server.watch.ignored`) and
from lint scope so they don't trigger reloads or noise.

**7. Local-dev posture.** Default to **cloud-first** (see the `aws-deploy-and-verify` skill).
If a local stack is offered at all, gate it behind explicit opt-in and document that
integration/E2E/security tests run against **deployed AWS dev**, not local emulation.

**8. Test hygiene.** Make the suite deterministic and leak-free from day one (see
`testing-standards.mdc`): never hard-code near/relative dates in fixtures (they silently rot —
use far-future/past sentinels or freeze the clock with `vi.setSystemTime` / an injected
`Clock`); set `TZ=UTC` in CI; pair `useFakeTimers` with `useRealTimers`; and ensure clean runner
exit (`clearTimeout` raced timers in `finally`, tear down SDK clients + the `fetch`/undici
dispatcher per worker). No `retry` to hide flakes.

## Output
A Phase 0 that yields: a green pipeline that can deploy to dev, a live dev environment,
SSM/Secrets-backed config, and shared foundations — so every later phase is just
`implement → pipeline-deploy → verify in cloud`.

## Anti-rationalization

| If you catch yourself thinking… | Do this instead |
|---|---|
| "We'll add the deploy stage once there's something to deploy." | Implement the real deploy stage in Phase 0; a stubbed stage hides that nothing ships. |
| "A `.env` file is fine for now." | Put config in SSM/Secrets Manager from the start; CodeBuild reads it at build time. |
| "Lint can wait; `tsc` is enough for the backend." | Lint every package at `--max-warnings 0` now — a warning pile trains everyone to ignore red. |
| "`console.log` is fine until we pick a logger." | Instantiate the shared structured logger before the first handler. |
| "A hard-coded 'next week' date in the fixture is fine." | Freeze the clock or use far-future/past sentinels; near dates rot silently. |
