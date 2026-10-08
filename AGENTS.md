# AGENTS.md — canonical index

This file is the cross-tool entry point (the [`AGENTS.md`](https://agents.md) convention). Cursor
reads the full rules from `.cursor/rules/` and skills from `.cursor/skills/` or `.agents/skills/`;
Codex, Claude Code (via `CLAUDE.md`), Gemini CLI, Copilot and others read this file. It carries a
**condensed** version of the always-on rules and an index of the skills, so an agent that only reads
this file still behaves the same way on the things that matter most.

Source of truth for the full texts: the pack repository
(`https://github.com/yv-labs/500k-lines-later` — `rules/`, `skills/`). This index is kept in sync with
it by the pack's `scripts/validate.sh`.

## Every-turn rules (condensed)

1. **Read the task before touching code.** Objective, scope, prerequisites, acceptance criteria.
   Read the design sections it references. — `implementation-workflow`
2. **Search before you create.** Across the whole repo, all phases, shared layers first. If
   something similar exists, extend it. Never build a parallel version. — `no-duplication`
3. **Minimum viable implementation.** No speculative abstractions, no `TODO` placeholders for
   future tasks, no optional parameters for hypothetical use. — `implementation-workflow`
4. **The pipeline is the only verification gate.** Lint, typecheck, tests, build, IaC validate and
   deploy run in CI. Local runs are for editing, never for proof. Push the branch, read the log.
   — `cloud-first-verification`, `cicd-first`
5. **Done means a shown artifact.** A CI log, a deployed URL screenshot, a request-id in logs, a
   live API response. "Never claim done from a local run alone." — `implementation-workflow`
6. **One feature branch at a time**, cut from and merged back into the integration branch via a
   PR gated on green CI. Deviations (hotfix off main, parallel branches, force-push) need explicit
   confirmation. — `git-workflow`
7. **Know your pipeline's real semantics.** Read the stages and buildspecs; don't assume. CI is not
   the deploy; `validate` is not `plan`; ad-hoc builds may pull the default branch. — `cicd-first`
8. **One clone, version-matched to CI, never in a cloud-synced folder.** Verify the push actually
   landed (binaries too). Read `git diff` before every commit; never commit an empty module.
   — `local-environment-hygiene`
9. **After two failed fixes, stop and go systematic.** State the failing claim falsifiably, list
   un-ruled-out hypotheses, keep an attempt ledger per variant, find *all* root causes (they stack).
   — `systematic-debugging`
10. **Trust nothing a delegate reports.** Give subagents the exact failing evidence, disjoint
    files, and read the full `git diff` before building on a "done". — `parallel-delegation`
11. **Reconcile out-of-band fixes in the same session.** A console/CLI fix isn't done until it is in
    IaC and adopted into state. — `cicd-first`, `terraform-infra`
12. **Run the retrospective reflex after every task.** Reflect → extend an existing rule/skill
    (never fork) → record a finding with an ID → generalize if not project-specific.
    — `continuous-improvement`
13. **Guardrails, not cages.** If a rule blocks a clearly better solution, do the better thing and
    update the rule. Distinguish hard constraints (business rules, security, cloud-only
    verification) from soft defaults. — `project-context`

## Skills (on-demand procedures)

Each name links to the skill folder in **this project's** skills directory (the installer rewrites
the links for your tool: `.cursor/skills/`, `.claude/skills/` or `.agents/skills/`; the user-level
skill lives in your home skills directory).

| Skill | Pull it when |
|---|---|
| [`aws-deploy-and-verify`](skills/aws-deploy-and-verify/) | A change must be proven done in the cloud; you are tempted to start a local server/emulator |
| [`aws-serverless-project-bootstrap`](skills/aws-serverless-project-bootstrap/) | Day 0 of a serverless project: CI/CD, cloud dev env, shared foundations before features |
| [`debugging-with-evidence-ledger`](skills/debugging-with-evidence-ledger/) | A fix doesn't stick, symptoms rotate, ~2 attempts failed |
| [`e2e-flake-triage`](skills/e2e-flake-triage/) | Any red/flaky E2E run; before "fixing a test" or re-running hoping for green |
| [`phase-retrospective`](skills/phase-retrospective/) | A phase ended; the user asks for a post-mortem or "capture the mistakes" |
| [`continuous-improvement-retrospective`](user-level/skills/continuous-improvement-retrospective/) (user-level) | Automatically at the end of any task in any repo, especially after friction |

## Scoped standards

`typescript-standards` · `react-frontend` · `tailwind-design-system` · `accessibility-standards` ·
`lambda-api` · `database-schema` · `terraform-infra` · `testing-quality` · `testing-standards` ·
`static-analysis-and-logging`

In Cursor these auto-attach by file type from `.cursor/rules/`; in Claude Code they live in
`.claude/rules/` with `paths:` and load when you read or edit a matching file. In tools without
scoped rules (Codex) the installer ships them **as skills with the same names** in the skills
directory — pull the one that matches the files you are about to edit (e.g. `terraform-infra`
before touching `*.tf`).
Catalog with scope, revisions and the incident behind each:
`https://github.com/yv-labs/500k-lines-later/blob/main/rules/README.md`.

## Reference (on demand)

`aws-services` · `performance-optimization` · `security-compliance` — agent-requested by
description. In Cursor they are rules; in Codex and Claude Code the installer ships them as skills
with the same names.

## Where this came from

Every line above survived a ~427K-line serverless build driven almost entirely by an AI IDE. 133
catalogued mistakes became these rules and skills; the mapping is in
`https://github.com/yv-labs/500k-lines-later/blob/main/docs/provenance.md`. The project itself is
private and never named; nothing here requires knowing it.

<sub>Maintained by YV Labs (Vidh Yasa) · MIT · https://github.com/yv-labs/500k-lines-later</sub>
