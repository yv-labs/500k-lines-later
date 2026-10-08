# Compatibility — what is tested, what is verified, what is assumed

Honesty table. "Production-tested" means the files ran this way for months on the reference build.
"Docs-verified" means the install path and frontmatter were checked against the tool's official
documentation on the date shown, but **nobody has yet run this pack inside that tool end-to-end**.
If you do, please open a *Compatibility report* issue (template provided) — a one-line "works on
X vY" is a real contribution.

Last doc check: 2026-10-07. To move a row from "Docs-verified" to "Tested", run
[`compatibility-test.md`](compatibility-test.md) and attach the log to a *Compatibility report* issue.

| Tool | Rules | Skills | Entry file | Status | Notes |
|---|---|---|---|---|---|
| **Cursor** | `.cursor/rules/*.mdc` (always / glob / agent-requested) | `.cursor/skills/` or `.agents/skills/`; user `~/.cursor/skills/`, `~/.agents/skills/`; also reads `.claude/skills/`, `.codex/skills/` | `AGENTS.md` also supported natively (a root `AGENTS.md` arrives as an always-applied rule) | **Production-tested** + protocol-tested 2026-10-07, Cursor 3.8.11 | Install PASS (23 rules identical, 5 skills, `AGENTS.md`; sandbox needs approval to create `.cursor/`) · startup context exactly 10 always-applied + 3 agent-requestable + 0 glob rules, 5 visible skills, `phase-retrospective` hidden by `disable-model-invocation` · AGENTS.md auto-loaded · explicit invocation 6/6 (5 Reads at the catalogued paths; `/phase-retrospective` chosen from the `/` popup arrives as a `manually_attached_skills` block — typed as plain text it delivers nothing) · **glob rules fire on the agent's own Read** of a matching file ("The following cursor rule files are relevant to the files you just read") · verification rule pushed back unprompted. **Bug found and fixed:** brace globs (`**/*.{ts,tsx}`) never match in Cursor — reading a `.tsx` attached the three plain/CSV-glob rules and neither brace-glob rule, reproduced in the reference build itself (4 rules silently never fired for months); all globs are now comma lists and `validate.sh` rejects `{`; re-verified in a fresh chat — reading a new `.tsx` now attaches all 5 matching rules (was 3). The `@file`-attach path was not exercised (three attempts produced no attached-files block — the picker was not used; the Read path is the one agents rely on). Glob rules attach once per file per chat (a repeat Read returns no rule block) — re-test with a fresh file or chat. Skill descriptions are shown to the agent cut at ~150 chars — put the trigger in the first sentence. `~/.cursor/skills/` can be synced to Cloud Agents via *Settings → Agents → Sync Skills*; `~/.agents/skills/` never syncs; Cursor also reads `~/.claude/skills/` and dedupes same-named skills to one entry. Repo import requires `.cursor-plugin/marketplace.json`. |
| **Claude Code** | always-on condensed in `AGENTS.md`, imported via `CLAUDE.md` `@AGENTS.md` (`--full-rules` → launch-loaded `.claude/rules/*.md`); 10 scoped standards → `.claude/rules/*.md` with `paths:` (native, load on Read/Write/Edit of a matching file); 3 on-demand rules → skills | `.claude/skills/<name>/SKILL.md` (8); personal `~/.claude/skills/` | `CLAUDE.md` (`@AGENTS.md`) | **Tested** 2026-10-07, Claude Code 2.1.293 (claude-opus-5-5), two sessions | Install PASS (8 skill folders, 10 `paths:` rules, `CLAUDE.md` = `@AGENTS.md`) · discovery 8/8 visible + `phase-retrospective` hidden by `disable-model-invocation` (the Skill tool refuses it verbatim: "cannot be used with Skill tool due to disable-model-invocation"; `/phase-retrospective` typed by the human loads it) · explicit invocation 7/7 · AGENTS.md auto-loaded through the `@AGENTS.md` import (`/context all`: `CLAUDE.md` 482 tokens + `AGENTS.md` 2.3k; the 8 skills ≈1k tokens) · **path-scoped rules fire on the Read tool**: reading `main.tf` injected `terraform-infra.md` only; reading `scratch.tsx` injected exactly the 5 rules whose globs match, including brace (`**/*.{ts,tsx}`) and comma-list forms, and none of the 5 that don't · descriptions 0 chars lost · verification rule pushed back unprompted. Gotchas found: a `bash printf >` write does **not** trigger a rule (only Read/Write/Edit tools do); `/context` → "Memory files" lists only launch-loaded files — lazily loaded rules are counted under Messages, so use it to prove *no eager load*, not to see scoped rules. `paths:` written as a quoted CSV string (YAML-list form has silent-failure reports #17204, #19377; a parse failure makes a rule load unconditionally); `paths:` ignored in `~/.claude/rules/` (#57722), so scoped rules are project-only. A `CLAUDE.md` in the tree suppresses a bare `AGENTS.md`, hence the import. Personal skills not loaded in Cowork/cloud sessions. Ignores `license`/`metadata` silently. |
| **Codex** (CLI / desktop) | `AGENTS.md` (13 condensed; `--full-rules` for full texts) + the 13 scoped/on-demand rules **installed as skills** | `.agents/skills/` (repo root and every parent of CWD); user `~/.agents/skills/` | `AGENTS.md` | **Tested** 2026-10-07, codex-cli 0.159.0-alpha.12.1 (desktop), two sessions | Install PASS (18 skill folders + `AGENTS.md`; sandbox approval prompt on `.agents/` as documented) · discovery 19/19 pack skills in the startup catalog next to 40 bundled/plugin skills · explicit invocation 6/6 · AGENTS.md auto-loaded (delivered as Codex's startup instructions block) · verification rule pushed back unprompted. Codex "invokes" a skill by reading the catalogued `SKILL.md` with file tools — its own startup text says so; there is no separate loader. Descriptions in a 59-skill catalog were water-filled to ≈430 chars (4 of ours lost 7–29 trailing chars; trimmed to ≤400 and re-checked: 6/6 whole). `$name` injects the full body (2/2 rule-skills). Logs: Session 1 + 2 + receipt check, 2026-10-07. `disable-model-invocation` not honoured (use `agents/openai.yaml` → `policy.allow_implicit_invocation: false`). |
| **GitHub Copilot** | `.github/copilot-instructions.md` + `.github/instructions/*.instructions.md` (`applyTo`) | `.agents/skills/` (coding agent) | `AGENTS.md` (also reads `CLAUDE.md`/`GEMINI.md`) | Docs-verified | Path-specific instructions on GitHub.com apply to the cloud agent and code review; IDEs apply them in chat. `install.sh --copilot` generates the `applyTo` files from glob-scoped rules. |
| **Gemini CLI** | `GEMINI.md` (hierarchical; `@file` imports) | `.agents/skills/` | `GEMINI.md`, or set `context.fileName` to include `AGENTS.md` | Docs-verified | `@rules/<name>.mdc` inside `GEMINI.md` inlines a rule verbatim (frontmatter included — harmless). |
| **Windsurf / Devin Desktop** | `.devin/rules/*.md` (preferred) or `.windsurf/rules/*.md` (fallback); `trigger: always_on / glob / model_decision / manual` | Cascade skills, or paste into a `manual` rule | `AGENTS.md` processed natively (root = always-on) | Docs-verified | 12,000-char cap per workspace rule file; `install.sh --windsurf` / `--devin` splits longer rules at headings. Global rules file capped at 6,000. |

## What "copy and paste" gives you

Everything is plain Markdown, so yes — you can skip the script entirely:

- **Rules:** copy any `rules/*.mdc` into `.cursor/rules/`. Each file is self-contained; cross-references
  like "see `cicd-first.mdc`" are pointers, not imports — a missing target degrades to a dangling
  mention, nothing breaks. Rename `project-context.template.mdc` → `project-context.mdc` and fill it in.
- **Skills:** copy any `skills/<name>/` folder into a skills directory. The agent only reads `SKILL.md`;
  `README.md` and `companion-rules/` are for you (Cursor and Codex ignore extra files in a skill
  folder; the spec allows them).
- **Companion rules:** if you copy one skill without the full rule set, copy its `companion-rules/*.mdc`
  too — otherwise the skill refers to guardrails the agent doesn't have.

## Known limitations

- Rules reference project documents by conventional names (`docs/IMPLEMENTATION_PLAN.md`,
  `docs/RETROSPECTIVE_AND_PLAYBOOK.md`, `docs/TRD.md`). If yours are named differently, change the
  path in the rule or create the file — the retrospective template ships; the others are on the roadmap.
- Several rules are written for AWS (CodeBuild/CodePipeline/Terraform). The principle is stated first
  and the AWS detail is marked "reference build"; adopters on other clouds should keep the principle
  and swap the example.
- Tools without glob scoping get the condensed always-on set from `AGENTS.md`. **Codex** has exactly
  two instruction surfaces — the `AGENTS.md` chain (`~/.codex/AGENTS.md` global, then one file per
  directory from repo root to CWD, 32 KiB cap) and skills. It scopes by *directory*, never by file
  glob, so a generic pack cannot express `**/*.tf` there. The installer therefore ships the 13
  scoped/on-demand rules as same-named skills: nothing is missing, it is shaped differently (Codex's
  own guidance puts "short conventions" in `AGENTS.md` and "procedures used for some tasks" in
  skills). **Claude Code** *does* have path-scoped rules (`.claude/rules/*.md` with `paths:`), so
  `install.sh --claude` maps the 10 standards there and only the 3 description-triggered rules
  become skills — the closest shape to Cursor of any tool here. One semantic difference from
  Cursor: a Claude rule fires when the agent **Reads, Writes or Edits** a matching file with its
  tools, not when a file is merely open or created by a shell command.
