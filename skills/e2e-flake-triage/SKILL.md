---
name: e2e-flake-triage
description: Triage and fix a red or flaky E2E suite WITHOUT whack-a-mole regressions. Use whenever a Playwright/E2E run is red or flaky; before "fixing a test", hardening a helper, or re-running hoping for green; when a previously-green test fails on another browser/run; when a visual snapshot mismatches. Outcome matrix per (test × browser × run), unifying root cause, regression-neutral fixes, ≥3-green gate.
license: MIT
metadata:
  author: YV Labs by Vidh Yasa
  source: https://github.com/yv-labs/500k-lines-later
  provenance: see README.md in this folder
---

# E2E Flake Triage — root-cause, not symptom; matrix, not aggregate

## Overview

Written for a suite that runs the **same specs across chromium + firefox + webkit** against a
**deployed** environment (the reference build's shape; adapt the browser list to yours). Such
failures are mostly non-deterministic *readiness* races (code-split chunk load, entry-module load,
hydration timing, auth-session rehydrate). The trap — it happened many times in the reference
build — is **whack-a-mole**: you fix the one (test × browser) cell that
was red this run, re-run, and a *different* cell goes red, because each browser hits a different
variant of the *same* underlying condition. The aggregate "fewer failures" looks like progress
while you oscillate forever.

This skill is the loop that breaks the cycle. Follow it in order. Do not skip the ledger.

## When to Use
- Any red or flaky Playwright/E2E run, before touching a spec or helper.
- A previously-green cell fails on another browser or run.
- A `toHaveScreenshot` baseline mismatches (see the visual-snapshot section).

**When NOT to use:** a deterministic unit-test failure, or a spec that fails identically on every
browser and run because of a plain product bug — fix the bug.

## 0. Source of truth
- Verification is **cloud-only**: `<e2e-codebuild-project>` (sharded Playwright, LARGE runner) and
  `<ci-codebuild-project>`. Never declare anything from a local run.
- The ledgers live in your project's E2E flake log (reference build: `docs/test/E2E_FLAKE_LOG.md`):
  - **Failure-class log** — one row per *root cause* (FC-1, FC-2, …).
  - **Run Ledger (outcome matrix)** — one row per `<e2e-codebuild-project>` build: every blocking
    shard / previously-flaky cell × browser, with pass/fail/flaky. THIS is what surfaces
    regressions. Append to it EVERY run before doing anything else.

## 1. Capture per-(test × browser) evidence — never just the aggregate
- Pull the failing shard's **blob report**:
  `s3://<reports-bucket>/e2e-reports/<build-id>/blob-report/<shard>.zip`
  (`test-results/` keeps only the last shard). It embeds the screenshot, video, and
  `error-context.md`.
- Record the EXACT failing cell(s): `spec:line › title` + **browser** + retry outcome
  (failed / flaky-passed-on-retry). A flaky-passed cell is NOT green — log it.

## 2. Update the Run Ledger FIRST
Append a row for this build: date, commit, deploy SHA, and for each blocking shard the
per-browser result. **Immediately diff against the previous row.** Any cell that was green and
is now red is a **P0 REGRESSION** — your last change broke it. Stop and reconcile that before
anything else. This is the step that was missing and let the oscillation hide.

## 3. Find the UNIFYING root cause (not the per-cell symptom)
Ask explicitly: *"What single condition explains this failure AND the variants seen on the
other browsers / earlier runs?"* Cross-reference the failure-class log — most new failures are
a known class wearing a different browser. Browser-specific timing differences are a **symptom
of a shared non-determinism**, not three separate bugs. Write the hypothesis down.

## 4. Prefer ONE systemic, regression-neutral fix
- Favor a fix at the shared layer (app readiness signal, helper used by all specs, bundling of
  a critical path) over patching individual specs.
- A candidate fix is valid ONLY if you can state **why it cannot regress any currently-green
  cell**. Example of a safe fix: "the extra re-submit only fires after 12s stuck on /auth/login,
  so fast browsers that already navigate are untouched." If you can't articulate neutrality,
  it's a band-aid — reconsider.
- Weigh systemic trade-offs (e.g. de-code-splitting a path reduces a hydration race but grows
  the initial bundle / perf budget). Note the trade-off in the ledger; don't silently pick one.

## 5. Verify the FULL matrix, then gate on ≥3 green
- After the fix deploys, a class is **not** "fixed" until the Run Ledger shows it green on
  **all three browsers** for **≥3 consecutive `<e2e-codebuild-project>` runs** with **no code/baseline
  changes between them** and **zero regressions** elsewhere.
- One green run is not a fix. A flaky-passed cell is not green.

## Visual-snapshot flakes are a DIFFERENT class — determinism, not readiness
A `toHaveScreenshot` mismatch is **not** a readiness race; the readiness-retry playbook above
won't fix it. Diagnose along these axes (a static content page once flaked at a 35% pixel diff):
- **JS-driven motion isn't frozen by `animations: 'disabled'`.** That option freezes **CSS**
  animations/transitions only — it does **nothing** to GSAP / Framer-Motion JS-driven `opacity`/
  `transform`. Pages that reveal sections via GSAP ScrollTrigger (`opacity:0` until in view, with
  `toggleActions` that *reverse* on scroll-back) capture non-deterministic opacity because the
  settle helper's scroll-to-top un-reveals them. Fix: emulate reduced motion so the app takes its
  static `gsap.set(..., { opacity: 1 })` branch: `await page.emulateMedia({ reducedMotion: 'reduce' })`.
  In the reference build (Playwright 1.60), project-level `use.reducedMotion` and file-level
  `test.use()` were **silently ignored** by the page context — call `emulateMedia` **inside the test body**.
- **Scope determinism tweaks; never globally.** A home page with a 3D WebGL hero has an
  **environment-dependent intrinsic layout height** (masking hides pixels, not layout), so a
  *global* reduced-motion regen shifted it by 55px (7% diff). Keep env-height-sensitive
  pages' baselines CI-generated and **unperturbed**; apply `emulateMedia`/regen only to the
  specific page that needs it, and restore the known-good baseline for the others.
- **Baselines are platform-specific — generate them in the CI image.** Update snapshots inside the
  **exact CI Playwright Docker image** (`mcr.microsoft.com/playwright:v<pinned>-noble`) with the
  repo bind-mounted, never on the host — a host-rendered PNG diffs against CodeBuild's renderer.
- **Confirm the baseline binary actually reached the remote.** A partial push once left stale
  baseline PNGs in the remote while local looked right ("passes locally, fails in CI") — verify the
  remote blob, not just `git push` exit code (see `local-environment-hygiene.mdc`).
- **A "content present" wait can pass on the loading fallback — capture only after the lazy chunk
  mounts.** A generic goto-settle that waits for `#root` to have *any* text is satisfied by
  a skip-link / layout chrome / `<Suspense>` fallback, so a code-split route's screenshot baselined
  the **loading spinner**, not the page. It's deterministic-but-wrong when tied to cache warmth:
  the COLD first visit (in the reference build, always the `light` capture) caught the spinner while the WARM second
  visit (`dark`, edge-cached chunk) caught real content — every lazy route's `light` baseline came
  out blank (~5KB, viewport-height). Before `toHaveScreenshot`, wait for the chunk to actually
  finish (`await page.waitForLoadState('networkidle')`, capped so a streaming-media page can't
  hang), not merely for "some text". And **eyeball the generated PNGs before committing** — a
  regen reporting success is a claim; a byte-size outlier (light≪dark) is the tell.

## Anti-patterns (these are how the loop happened — do not repeat)
- ❌ Declaring "fixed" from the aggregate failure count dropping.
- ❌ Hardening only the spec/browser that was red this run.
- ❌ Re-running to "see if it passes" with no written root-cause hypothesis.
- ❌ Marking a failure-class FIXED after a single green shard (it must clear the matrix gate).
- ❌ Treating chromium-vs-firefox timing differences as unrelated bugs.

## Anti-rationalization

| If you catch yourself thinking… | Do this instead |
|---|---|
| "It passed on retry, so it's fine." | Flaky-passed-on-retry is NOT green — log it in the Run Ledger. |
| "Fewer failures than last run — we're making progress." | Diff the Run Ledger row by row; any green→red cell is a P0 regression. |
| "Firefox and WebKit are failing for different reasons." | Look for the single shared non-determinism first. |
| "Let me just re-run and see." | Write the root-cause hypothesis down before re-running. |
| "One green run — mark the class FIXED." | Require all 3 browsers green for ≥3 consecutive runs with no changes between. |
