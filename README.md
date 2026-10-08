<!-- GitHub: https://github.com/yv-labs/500k-lines-later -->

<div align="center">

# 500k lines later

### 500K lines of code with an AI IDE taught me this.

**23 Cursor rules · 6 agent skills · every line traceable to the mistake that created it.**

<sub>by <b>YV Labs</b> · Vidh Yasa</sub>

Harvested from one private, ~427,000-line AWS-serverless build driven almost entirely by Cursor,
where every friction point was catalogued as a numbered finding and folded back into the rules
the agent reads on the next turn. 133 findings in. These files out.

[Quick start](#quick-start) · [What's inside](#whats-inside) · [How the loop works](#the-loop) ·
[Rules](rules/README.md) · [Skills](skills/README.md) · [Provenance](docs/provenance.md) ·
[Series](#the-series)

<!-- badges: add after publish -->
<!-- ![stars](https://img.shields.io/github/stars/yv-labs/500k-lines-later) ![license](https://img.shields.io/badge/license-MIT-blue) ![skills-scanned](https://img.shields.io/badge/skills-scanned-brightgreen) -->

</div>

---

## Why this exists

Most rule packs tell you what good looks like. This one tells you **what went wrong, how many
times, and what sentence stopped it from happening again.**

| | |
|---|---|
| Lines of hand-authored code the rules survived | **427,335** (457K all-in, methodology in [`docs/provenance.md`](docs/provenance.md)) |
| Catalogued mistakes → findings | **133** finding IDs |
| Rules (always-on / scoped / on-demand) | **23** (10 / 10 / 3), 1,751 lines |
| Skills (project / user-level) | **6** (5 / 1) |
| Most-revised rule | `cicd-first.mdc` — 11 revisions, 8 inline finding refs |
| Rule that never needed a second revision | `tailwind-design-system.mdc` |
| Cost of the always-on set | ≈ 9K tokens per turn. Deliberate. Budgeted. |

No rule here is a style preference. Each is one of three things: a **catalogued failure mode**,
a **verification reflex**, or an **environment fact** — written as a principle, not a script, so
the agent stays free to design. The philosophy is one line long:

> *Guardrails, not cages. If a rule blocks a clearly better solution, do the better thing, then
> update the rule.*

## Quick start

Pick your tool. Everything is plain Markdown — no runtime, no install step beyond a copy.

<details open>
<summary><b>Cursor</b></summary>

```bash
git clone https://github.com/yv-labs/500k-lines-later.git
cd 500k-lines-later
./scripts/install.sh --cursor /path/to/your-repo        # copies rules + skills + AGENTS.md
# then fill in /path/to/your-repo/.cursor/rules/project-context.mdc —
# it is the ONE rule that is unique to your project
```

Or by hand: `cp rules/*.mdc your-repo/.cursor/rules/` and `cp -R skills/* your-repo/.cursor/skills/`.
For the one user-level skill: `cp -R user-level/skills/* ~/.cursor/skills/`.
Details: [`docs/cursor-setup.md`](docs/cursor-setup.md).
</details>

<details>
<summary><b>Claude Code</b></summary>

```bash
./scripts/install.sh --claude /path/to/your-repo   # .claude/rules/ (10 path-scoped) + .claude/skills/ (8) + CLAUDE.md → @AGENTS.md
./scripts/install.sh --claude /path/to/your-repo --full-rules   # + the 10 always-on bodies as launch-loaded rules
```
Scoped standards become native `.claude/rules/*.md` with `paths:`; the three on-demand rules ship as
skills; the always-on set is condensed in `AGENTS.md`, imported by `CLAUDE.md`.
[`docs/claude-code-setup.md`](docs/claude-code-setup.md)
</details>

<details>
<summary><b>Codex</b></summary>

```bash
./scripts/install.sh --codex /path/to/your-repo    # 5 skills + 13 rules-as-skills → .agents/skills/, AGENTS.md
./scripts/install.sh --codex /path/to/your-repo --full-rules   # + full always-on texts in AGENTS.md
```
Codex has no scoped rules, so the scoped/on-demand rules ship as same-named skills — nothing is
dropped, it is shaped differently. [`docs/codex-setup.md`](docs/codex-setup.md)
</details>

<details>
<summary><b>GitHub Copilot · Gemini CLI · Windsurf · anything that reads AGENTS.md</b></summary>

`./scripts/install.sh --agents-md /path/to/your-repo` drops `AGENTS.md` and the open-standard
`.agents/skills/` folder. Tool-specific wrappers (`.github/copilot-instructions.md`, `GEMINI.md`,
`.windsurf/rules/`) live in [`adapters/`](adapters/). Setup notes per tool in [`docs/`](docs/).
</details>

**Start small.** The [Starter pack](rules/README.md#packs-start-small) is five rules. It is enough
to start the self-learning loop; the rest can arrive as your own findings justify them.

## What's inside

```
.
├── AGENTS.md                      canonical cross-tool index (condensed always-on rules + skill index)
├── CLAUDE.md                      Claude Code entry → points at AGENTS.md
├── rules/                         23 Cursor rules (.mdc), flat so `cp rules/*.mdc .cursor/rules/` just works
│   ├── README.md                  catalog: scope · lines · revisions · findings · born · money quote
│   └── project-context.template.mdc   the one rule you must fill in
├── skills/                        5 project-level skills
│   └── <skill>/
│       ├── SKILL.md               agent-facing procedure (lean; trigger-heavy frontmatter)
│       ├── README.md              human-facing: what · when · where it goes · how it helps · provenance
│       └── companion-rules/       copies of the rules this skill depends on (self-sufficient folder)
├── user-level/skills/             1 global skill (lives in ~/.cursor/skills/, follows you across repos)
├── templates/                     retrospective + finding block now; PRD / TRD / ARCH / Implementation Plan next
├── adapters/                      per-tool wrappers (cursor · claude-code · codex · copilot · gemini · windsurf)
├── docs/                          install, per-tool setup, compatibility, the-loop, provenance
├── scripts/                       install.sh · sync-companions.sh · validate.sh · scrub-check.sh
├── .cursor-plugin/                marketplace.json / plugin.json so Cursor can import the pack
│
│   planned (see Roadmap) — same repo, so everything stays in one place:
├── patterns/                      CI lane skeletons · monorepo path-filter dispatcher · security-gate rollout kit
├── observability/                 alarm / SLO catalog pattern · runbook template · "no data ≠ zero" checklist
└── testing/                       E2E run-ledger + flake-ledger templates · journey matrix · test-strategy skeletons
```

### Rules — three tiers, three costs

| Tier | Count | Loaded | Examples |
|---|---:|---|---|
| Always-on | 10 | every turn | `implementation-workflow`, `cloud-first-verification`, `cicd-first`, `systematic-debugging`, `continuous-improvement` |
| Glob-scoped | 10 | when a matching file is touched | `terraform-infra` (16 finding refs), `database-schema`, `react-frontend`, `testing-quality` |
| On-demand | 3 | when the agent judges the description relevant | `aws-services`, `performance-optimization`, `security-compliance` |

Full catalog with scope, where it goes, revisions, finding refs and a money quote per rule:
[`rules/README.md`](rules/README.md).

### Skills — procedures the agent pulls when the situation matches

| Skill | One line | Level |
|---|---|---|
| [`aws-deploy-and-verify`](skills/aws-deploy-and-verify/) | Prove a change is done with cloud evidence, never a local run | project |
| [`aws-serverless-project-bootstrap`](skills/aws-serverless-project-bootstrap/) | Day-0 of a serverless project: CI/CD and cloud dev env before feature #1 | project |
| [`debugging-with-evidence-ledger`](skills/debugging-with-evidence-ledger/) | After two failed fixes, keep a ledger and find *all* the stacked root causes | project |
| [`e2e-flake-triage`](skills/e2e-flake-triage/) | Triage a red/flaky E2E suite without whack-a-mole regressions | project |
| [`phase-retrospective`](skills/phase-retrospective/) | Mine a finished phase for findings and fold them into rules/skills | project |
| [`continuous-improvement-retrospective`](user-level/skills/continuous-improvement-retrospective/) | The post-task reflex that makes the whole pack self-updating, in every repo | **user-level** |

Each skill folder has a `README.md` with **what / when / where it goes / how it helps / works best
with / provenance / install / example**, and a `companion-rules/` folder with the rules it needs
to work well — so a single `cp -R` gives you a working unit. [`skills/README.md`](skills/README.md)

## The loop

The pack is not the point. The **loop that produced it** is.

```
task → always-on rules shape the work
     → the pipeline (never the laptop) says pass/fail
     → Implementation Log records what shipped and what was deferred
     → any friction (a "no", a revert, a fix that broke something, a "done" that wasn't)
     → gets a finding ID in the retrospective
     → extends an EXISTING rule or skill (never a fork)
     → generalizes to a user-level skill if it isn't project-specific
     → next task starts with the smarter rules
```

Two rules make it mandatory and automatic: [`continuous-improvement.mdc`](rules/continuous-improvement.mdc)
(the reflex) and [`systematic-debugging.mdc`](rules/systematic-debugging.mdc) (the anti-loop that
feeds it). One skill does the deep pass: [`phase-retrospective`](skills/phase-retrospective/).
Full write-up with case studies: [`docs/the-loop.md`](docs/the-loop.md).

## How is this different from other rule / skill packs?

| | Typical pack | This pack |
|---|---|---|
| Where the rules came from | opinion, blog posts, "best practices" | a numbered finding from a real incident, per line |
| Proof they work | stars | 427K lines shipped under them; revision history per rule |
| Shape | checklists the agent follows mechanically | principles + the catalogued failure they prevent |
| Scope awareness | everything always-on | always-on / glob / on-demand, with token cost stated |
| Skills ship alone | yes | with the companion rules they depend on |
| Updates | when the author feels like it | when a new finding justifies it (and says which) |

## Trust

- Every file is plain Markdown; there are no executables except the three shell scripts in
  `scripts/`, which only copy files. Read them — they are short.
- Skills were scanned before publish; the report will be linked here. If you run a skill scanner,
  please open an issue with the result.
- The source project is private and is never named. Placeholders (`<project>`, `<prefix>`,
  `<account-id>`, `<region>`, …) mark where its specifics were. Nothing in this repo requires
  knowing what it was.

## The series

**500k lines later** is also the name of the video series this repo accompanies — building half a
million lines with an AI IDE: what broke, what was learned, and how the learning was made automatic. Each rule and skill here
gets its own short episode: what it does, how it works, the incident that created it, how it changed
over time. Links will be added as episodes publish.

## Roadmap

- [x] **v0.1** Rules + skills, scrubbed and documented (this release)
- [ ] **v0.2** `templates/`: PRD · TRD · Architecture · Implementation Plan (task + Implementation Log blocks)
- [ ] **v0.3** `patterns/`: CI lane skeletons, monorepo path-filter dispatcher, security-gate rollout kit, Terraform module conventions
- [ ] **v0.4** `observability/` + `testing/`: alarm/SLO catalog, runbook template, E2E run-ledger and flake-ledger, test-strategy skeletons
- [ ] **v0.5** tooling: anonymization scrub kit, rule-provenance script, `validate.sh` as a reusable action
- [ ] Skill-scanner report + badge; per-skill repos for the ones that stand alone; community compatibility matrix filled in

## Contributing

Additions must cite a finding (what broke, where, what the rule now prevents) — see
[`CONTRIBUTING.md`](CONTRIBUTING.md). Rewrites that turn a principle into a checklist will be declined.

## Compatibility

Cursor is production-tested (this is where the pack lived for months) and was re-run through the
same protocol on a clean workspace — which is how we learned Cursor never matches `{a,b}` globs
(fixed; four rules had silently never fired). **Codex** and **Claude Code** are tested end-to-end
(2026-10-07: install, every skill discovered and invoked, `AGENTS.md` auto-loaded, verification
rule changed behaviour; in Claude Code and Cursor the scoped rules fired on Read of a matching file). Copilot, Gemini CLI and Windsurf/Devin install paths
are verified against each tool's official docs but not yet run end-to-end — the honest table, the
test protocol, and how to report a result are in [`docs/compatibility.md`](docs/compatibility.md).

## Community

The fastest way this repo gets better is other people's findings. Three issue templates:
**Finding** (a mistake → a rule change, with evidence), **Compatibility report** ("works / breaks on tool X"),
**Scrub leak**. Discussions are open for "how do you handle…" threads. See [`CONTRIBUTING.md`](CONTRIBUTING.md).

## License

MIT © 2026 YV Labs (Vidh Yasa). Take it, fork it, fill in your own findings.

---

<div align="center"><sub>Maintained by <b>YV Labs</b> — Vidh Yasa. Companion repo to the <i>500k lines later</i> series.</sub></div>
