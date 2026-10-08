# Skills

Five project-level agent skills (plus one user-level skill in [`../user-level/`](../user-level/)), each born from real mistakes on a large AWS-serverless reference build. Every folder holds a lean agent-facing `SKILL.md` and a human-facing `README.md` with provenance.

## Catalog

### Verify & ship

| Skill | One line | Use when | Companion rules | Born / revs |
|---|---|---|---|---|
| [`aws-deploy-and-verify`](aws-deploy-and-verify/) | A change isn't done until it's deployed and you can show an artifact. | After any web/API/infra change; before saying "done"; when tempted to verify locally | `cloud-first-verification`, `cicd-first`, `implementation-workflow` | 2026-06-16 / 4 |
| [`aws-serverless-project-bootstrap`](aws-serverless-project-bootstrap/) | Do CI/CD, config, shared layers, and lint gates in Phase 0, before any feature. | Day one of a greenfield serverless repo | `cicd-first`, `terraform-infra`, `static-analysis-and-logging`, `local-environment-hygiene` | 2026-06-16 / 3 |

### Debug without looping

| Skill | One line | Use when | Companion rules | Born / revs |
|---|---|---|---|---|
| [`debugging-with-evidence-ledger`](debugging-with-evidence-ledger/) | When a fix moves the failure, you have stacked root causes; keep a per-variant ledger. | A fix doesn't stick; symptoms rotate; ~2 failed attempts | `systematic-debugging`, `parallel-delegation` | 2026-06-27 / 1 |
| [`e2e-flake-triage`](e2e-flake-triage/) | Flaky-passed-on-retry is NOT green; matrix, unifying cause, ≥3 clean runs. | Any red/flaky Playwright run; before "fixing a test" | `testing-standards`, `testing-quality`, `systematic-debugging` | 2026-06-27 / 3 |

### Learn from every task

| Skill | One line | Use when | Companion rules | Born / revs |
|---|---|---|---|---|
| [`phase-retrospective`](phase-retrospective/) | Mine transcripts for lessons, give each an ID, map it to a rule or skill. | You ask for a post-mortem; end of a phase (user-invoked only) | `continuous-improvement` + the retrospective template | 2026-06-16 / 1 |
| [`continuous-improvement-retrospective`](../user-level/skills/continuous-improvement-retrospective/) (user-level) | Run a short retrospective after every task, in every repo. | Any task finishing; any friction signal | `continuous-improvement` + `phase-retrospective` | ~2026-06-27 / n/a |

Each skill folder bundles its companion rules in `companion-rules/`.

## Skill vs rule

- A **rule** (`.cursor/rules/*.mdc`) is a guardrail Cursor loads for you: always on, or scoped to matching files by glob. It states a principle the agent must *hold*, usually in about 40 lines.
- A **skill** (`SKILL.md`) is a procedure the agent pulls in **on demand** when the task matches the skill's `description`. It's a checklist to *run*, usually 50–100 lines.
- They pair up. `systematic-debugging.mdc` says "after 2 failed fixes, switch to systematic mode"; `debugging-with-evidence-ledger` is the workflow for doing that. Install both.

## Project-level vs user-level

| | Project-level (`.cursor/skills/`, `.agents/skills/`) | User-level (`~/.cursor/skills/`, `~/.agents/skills/`) |
|---|---|---|
| Lives in | The repo, committed | Your home directory |
| Shared with | Your team, CI, and cloud agents | Only you |
| Follows you across repos | No | Yes |
| Best for | Stack- or project-specific procedures (the AWS skills) | Habits you want everywhere (the post-task retrospective) |

User-level skills aren't synced to Cloud Agents or remote workers. If you use those, also commit a project copy. See [`../user-level/README.md`](../user-level/README.md).

---

<sub>YV Labs · Vidh Yasa · MIT</sub>
