---
name: aws-deploy-and-verify
description: Prove a change is done with real cloud evidence (deployed URL, CI log, request-id), never a local run. Use after implementing any web, API, or infra change on an AWS-serverless project; whenever a task must be proven "done"; when tempted to start a local dev server, emulator, or full local typecheck; when a local preview looks stale; or when judging web performance from Lighthouse lab numbers.
license: MIT
metadata:
  author: YV Labs by Vidh Yasa
  source: https://github.com/yv-labs/500k-lines-later
  provenance: see README.md in this folder
---

# AWS Deploy & Verify

## Overview

On an AWS-only project, a change is proven by **deploying to the dev account and verifying
in the cloud** — not by a local dev server, emulator, or local full typecheck (those hang or
diverge from prod and waste tokens). This skill is the loop that ends a task.

## When to Use
- You finished a web / API / Terraform change and need to confirm it works.
- A task must be marked "done" (the definition of done requires a cloud artifact).
- You catch yourself about to `npm run dev`, boot a simulator, or run a local full-repo
  `tsc` to "check" — stop and use this instead.

**When NOT to use:** pure docs/rules edits that deploy nothing, or a one-time CD bootstrap the
pipeline cannot do for itself (do that targeted and version-matched, then return to this loop).

## Workflow

```
- [ ] 1. Pre-push checks: read the diff; `terraform fmt`; push so CI runs lint/typecheck/tests
- [ ] 2. Build the package in the pipeline (web: vite build; api: esbuild bundle; infra: plan)
- [ ] 3. Deploy to dev (via pipeline if available; otherwise the documented manual deploy)
- [ ] 4. Verify with a real artifact (browser / CloudWatch / live API)
- [ ] 5. Update the Implementation Log; leave no background processes running
```

**1. Pre-push checks.** Read `git status` + `git diff` (nothing empty, stale, or reverted);
`terraform fmt` for `.tf` changes — the one local check with no pass/fail semantics. Then push the
branch: lint, typecheck and unit tests run in CI and the CI log is the verdict. Do not run them
locally as the gate (see `cloud-first-verification`); if no pipeline exists yet, that is the first
thing to build, not a reason to verify on the laptop.

**2. Build.** Happens in the pipeline's Build stage; read its log, not a local build.
- Web: the buildspec's `npm run build` (with the env mode the buildspec sets).
- API: the esbuild bundle step; confirm the artifact was produced.
- Infra: `terraform validate && terraform plan` in the plan stage — read the **full plan**, since
  `validate` does not enforce provider value constraints.

**3. Deploy to dev.** Prefer the **pipeline** (push to the pipeline's source remote → CodePipeline,
e.g. `AWS_PROFILE=<profile> git push <codecommit-remote> <branch>` — never an unused mirror). If
deploying manually as a bridge:
- Web: `aws s3 sync dist/ s3://<web-bucket-dev> --delete` then a CloudFront invalidation.
- API: `aws lambda update-function-code` for the changed function(s).
- Infra: `terraform apply` — use a **targeted apply** if the plan shows unrelated drift.

**4. Verify (mandatory — pick the relevant evidence).**
- UI: open the **dev CloudFront URL** in the browser and screenshot the actual change. Do
  not assume a blank page is fine — confirm content rendered (a past deploy shipped blank).
  - **The deployed CloudFront preview route is the authoritative UI check — not the local
    dev server.** If a local `npm run dev` preview keeps rendering *stale* output after an edit
    (old value survives navigations / `about:blank` / cache-buster / `setCacheDisabled`) while
    `curl` of the module URL and the page's own `fetch('…',{cache:'no-store'})` both return the
    NEW code, it's a **webview HTTP-module cache**, not a code bug — stop editing and verify on
    the deployed dev CloudFront (`/dev/<preview-route>?state=…`). Also: run **one** dev server
    at a time (`lsof -ti tcp:5173` first); `pkill`/`pgrep` may be sandbox-blocked
    (`sysmond service not found`) — kill by explicit PID from `lsof -ti tcp:<port>`.
- API: call the live endpoint and show the response, or show the CloudWatch log line +
  request-id.
- Infra: confirm the resource exists in `<region>` and behaves.
- **Web performance:** verify against **FIELD data (CloudWatch RUM p75)**, not throttled
  Lighthouse lab numbers. On a client-rendered SPA, lab LCP under 4×-CPU/slow-4G is
  structurally ~7–8 s even when real users get ~1.8 s, so the Lighthouse lab budget is a CI
  *regression detector*, and the real Core-Web-Vitals SLO (e.g. LCP p75 ≤ 2.5 s) is enforced
  by a RUM alarm. Don't chase a 2.5 s *lab* LCP with SSR/prerender unless the FIELD p75
  actually misses. Keep synthetic/bot traffic out of RUM. (See
  `.cursor/rules/performance-optimization.mdc` → "FIELD is the SLO, LAB is a regression detector".)

**5. Close out.** Update the Implementation Log (files, decisions, date). Record any deferred
work. Kill any dev server/watcher you started.

## Guardrails
- For UI changes, show the result and get sign-off **before** the production-facing sync.
- Never claim "done" without the verification artifact from step 4.
- `terraform plan` clean is necessary but not sufficient — the resource must be live + verified.
- Don't reuse a stale build environment; each build/deploy gets a fresh one.

## Anti-rationalization

| If you catch yourself thinking… | Do this instead |
|---|---|
| "It works on my local dev server, so it's done." | Deploy to dev and show an artifact from step 4 — local is never proof. |
| "The deploy finished, the page must be fine." | Open the dev CDN URL and confirm content rendered — a past deploy shipped blank. |
| "`terraform plan` is clean, so the infra is done." | Confirm the resource is live in `<region>` and behaves. |
| "My edit didn't show up locally — the code must be wrong." | Check for the webview module cache; verify on the deployed preview route before editing again. |
| "Lighthouse lab LCP is 7 s, we need SSR." | Check FIELD (RUM p75) first; lab is a regression detector, not the SLO. |
