# Changelog

All notable changes. Each entry names the finding(s) that justified it, per `CONTRIBUTING.md`.

## [0.1.0] — unreleased (launch)

### Added
- 23 rules in `rules/` (10 always-on, 10 glob-scoped, 3 on-demand), scrubbed of all source-project
  identifiers; `project-context` ships as a fill-in template.
- 6 skills: `aws-deploy-and-verify`, `aws-serverless-project-bootstrap`,
  `debugging-with-evidence-ledger`, `e2e-flake-triage`, `phase-retrospective` (project-level) and
  `continuous-improvement-retrospective` (user-level), each with a human README and bundled
  companion rules.
- `AGENTS.md` canonical index; `CLAUDE.md`; adapters for Copilot, Gemini CLI, Windsurf.
- `templates/RETROSPECTIVE_AND_PLAYBOOK.template.md` with the single-finding block.
- `scripts/install.sh`, `sync-companions.sh`, `validate.sh`, `scrub-check.sh`.
- `docs/`: install, per-tool setup, the-loop, provenance, `compatibility.md` (honesty matrix:
  Cursor production-tested; other tools docs-verified until a report says otherwise) and
  `compatibility-test.md` (the paste-in protocol that produces a shareable test log).
- Community scaffolding: issue forms (finding · compatibility report · scrub leak), PR template,
  Contributor Covenant, Discussions link; `validate.yml` CI (frontmatter incl. strict YAML, catalogs,
  companion sync, scrub, install smoke for 8 modes).
- Branding: "YV Labs by Vidh Yasa" in LICENSE, README, AGENTS.md footer, SKILL.md `metadata`,
  plugin manifests. Repo name `500k-lines-later`.

### Changed after the first Codex run (2026-10-07, codex-cli 0.159.0-alpha.12.1)
- `install.sh --codex` now installs the 13 scoped/on-demand rules **as skills** (same names, rule
  description + globs as trigger, rule body verbatim) — Codex has no scoped-rule concept, so the
  previous install silently dropped 13 of 23 rules. `--full-rules` appends the full always-on
  texts to `AGENTS.md`. 18 skill folders total.
- Installed `AGENTS.md` has its skill links rewritten to the tool's real skills directory
  (`.cursor/skills/`, `.claude/skills/`, `.agents/skills/`); previously every link 404'd in an
  installed project. Repo-doc links now point at the GitHub URLs.
- `install.sh --user` strips `companion-rules/` like the project installs do.
- Test protocol: "read the SKILL.md at the catalogued path" is Codex's invocation mechanism, not a
  failure; the first run scored 0/6 on a criterion that was wrong for the tool.
- `scrub-check.sh` rewritten in Python: the `rg`-based version **passed silently when `rg` was not
  installed** (the `if rg …` test was just false). A scrub gate must fail closed; it now exits 2
  without python3 and reports the pattern count it actually ran.

### Changed after the second Codex run (2026-10-07, two-session protocol — Codex row → Tested)
- All six skill descriptions trimmed to ≤400 chars with trigger words first. Codex shares one
  ~8,000-char catalog budget across every skill in the session (bundled + plugins + ours) and
  water-fills it, so in a 59-skill catalog four of ours lost their last 7–29 chars. `validate.sh`
  now enforces the cap and rejects `<placeholder>` text in any description (one rule still said
  "for `<api-package>`" — shown verbatim to the agent at startup).
- `e2e-flake-triage` was missing the `license`/`metadata` block and said "This project's E2E
  suite…"; fixed, and `validate.sh` now fails on either.
- On-demand rule descriptions (`aws-services`, `performance-optimization`, `security-compliance`)
  gained explicit "Use when…" triggers — as skills they have nothing but the description to fire on.
- Protocol v2 stamp on both prompts so a stale v1 paste is detectable from the log itself (the
  second run used the v1 prompt and scored itself 0/6 on the retired criterion).
- Receipt check after trimming: 6/6 descriptions whole in the same 59-skill catalog; `$name` injects
  the full body (2/2 rule-skills). Codex row → **Tested**.

### Cursor protocol run found a real bug: brace globs never match (2026-10-07, Cursor 3.8.11)
- Two-session protocol on a fresh workspace: install PASS, discovery exactly 10 always + 3
  requestable + 0 glob rules and 5 visible skills (`phase-retrospective` hidden by
  `disable-model-invocation`), `AGENTS.md` auto-loaded as an always-applied rule, 5/5 explicit
  Reads, verification rule pushed back; glob rules fire on the agent's **own Read** of a matching
  file (the open question from the Claude run).
- **Fixed:** `typescript-standards`, `tailwind-design-system`, `database-schema`, `testing-quality`
  used `{a,b}` globs, which Cursor's auto-attach matcher does not expand — reading a `.tsx`
  attached the plain/CSV-glob rules and neither brace rule, reproduced in the reference build
  (those four rules had silently never fired). All globs are comma lists now; `validate.sh`
  rejects `{` in `globs:`. Re-verified in a fresh chat after the fix: a new `.tsx` attaches all 5
  matching rules (3 before). Rules attach once per file per chat — a repeat Read returns nothing.
- `/phase-retrospective` chosen from the `/` popup delivers the body as a `manually_attached_skills`
  block (typed as text it delivers nothing) — explicit invocation 6/6. `@file`-attach not exercised. Claude Code `paths:` and Codex rule-skill triggers inherit the CSV form
  (CSV was already verified in both).
- Finding: Cursor shows skill descriptions to the agent cut at ~150 chars — trigger must be in the
  first sentence (documented in `rules/README.md`; descriptions unchanged for now).
- Finding: `aws-deploy-and-verify` step 1 ("eslint changed files + affected unit tests, local")
  is in tension with `cloud-first-verification`'s hard rule — open for a wording decision.
- Protocol: Cursor 3e/3g steps require choosing `/skill` and `@file` from the popup; a typed
  `/name` or `@file` that is not selected is plain text and delivers nothing (recorded as
  NOT-SELECTED / NOT-ATTACHED, not FAIL). Re-test after the comma-list fix (fresh chat, new
  `fresh.tsx`): Read attached all 5 matching rules including typescript-standards and
  tailwind-design-system. `@`-attach still produced no attached-files block (picker unused);
  the Read path is the one agents use. Glob rules attach once per file per chat.

### Claude Code tested end-to-end (2026-10-07, Claude Code 2.1.293)
- Two-session protocol: install PASS (8 skills, 10 `paths:` rules, `@AGENTS.md`), 8/8 visible
  skills + `phase-retrospective` hidden by `disable-model-invocation` (Skill tool refuses it; `/name`
  loads it), 7/7 explicit invocations, `@AGENTS.md` import expanded at launch (`/context all`:
  CLAUDE.md 482 + AGENTS.md 2.3k tokens, 8 skills ≈1k), descriptions 0 chars lost, verification
  rule pushed back unprompted. Claude Code row → **Tested**.
- Path-scoped rules: Read of `main.tf` injected `terraform-infra` only; Read of `scratch.tsx`
  injected exactly the 5 matching rules (brace globs `**/*.{ts,tsx}` and comma lists both honoured;
  `**/*.{ts,sql}` correctly not). A shell `printf >` write triggers nothing — only Read/Write/Edit
  tools do. `/context` "Memory files" does not list lazily loaded rules (they count under Messages).
- Protocol v2 amended from the run: paste prompts only into an idle session (a queued message
  arrives as a `system-reminder` and Claude flags it as prompt injection — happened here); prompts
  name their source file; Claude discovery expectation is 8 visible + 1 hidden; 3e asks the human to
  type `/phase-retrospective`; use `/context all`; don't expect `/context` to show fired rules.
- `validate.sh`: `check_desc` used `d=` and clobbered the skills loop variable, making every skill
  fail "missing license/metadata" with an awk "can't open file <description>" error — now `local`.

### Claude Code install rebuilt on verified surfaces (2026-10-07)
- `install.sh --claude` now maps the 10 scoped standards to **native `.claude/rules/<name>.md` with
  `paths:`** (quoted CSV string — the YAML-list form in the docs has open silent-failure reports
  #17204/#19377, and an unparseable frontmatter loads a rule unconditionally), the 3 on-demand
  rules to skills (8 skill folders), and `--full-rules` to launch-loaded `.claude/rules/*.md`.
  Previously only the 5 skills were installed and the setup doc wrongly said Claude Code "has no
  concept of glob-scoped rules".
- `CLAUDE.md` now starts with `@AGENTS.md`. The old file *told* Claude to read AGENTS.md; the
  official memory page says that only works if Claude decides to open the file, and a `CLAUDE.md`
  in the tree suppresses direct `AGENTS.md` loading — so the index was effectively never loaded.
- `install.sh --user` also writes `~/.claude/skills/`.
- Test protocol: Claude-only expectations (9 skills, 10 `paths:` rules, `@AGENTS.md`, `/context`
  evidence) and step 3g tests that a path-scoped rule fires on Read and was not loaded eagerly.
- Codex paths/output unchanged (shared helper gained optional parameters defaulting to the tested
  Codex behaviour).

### Fixed before release
- `scripts/scrub-terms.txt` used to contain the private project's identifiers; now ships only
  generic leak classes, with the project-specific list gitignored and guarded.
- Three rule frontmatters were valid for Cursor but not strict YAML (`globs: **/…`, unquoted `: `).

### Provenance
- Source: 133 catalogued findings from a ~427K-line build; rule revision counts and born dates in
  `rules/README.md`.
