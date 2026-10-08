# Compatibility test protocol — let the tool install and test the pack itself

Works for **Claude Code**, **Codex** and **Cursor** (and any agent with shell access). ~20 minutes per tool.
Produces `TEST_LOG-<tool>.md`, the artifact the *Compatibility report* issue form asks for.

**Protocol v2 (2026-10-07).** Each prompt below starts with its version line. If a log you are
reading expects "exactly five/six" skill folders, treats reading the `SKILL.md` at the catalogued
path as a FAIL, or runs `npm test` without first creating `package.json`, it was produced by v1 —
re-run with the prompts on this page.

Scope: **installation correctness**, not depth. Each of the 6 skills must be (a) on disk where the
tool looks, (b) listed by the tool, (c) described identically to the file, (d) loadable on explicit
invocation. The condensed rules (`AGENTS.md`) must be auto-loaded and must change one behaviour.
That is the bar for flipping a row in [`compatibility.md`](compatibility.md) to **Tested**.

## Why two sessions

Both tools can run `scripts/install.sh` themselves. But skills are discovered from directories that
exist **when the session starts**: Claude Code watches existing skill dirs live yet requires a
restart when the top-level `.claude/skills/` is created mid-session; Codex says "detects newly
installed skills automatically; if one doesn't appear, restart Codex." The install creates these
directories, so testing in the install session gives false FAILs. **Session 1 installs. Session 2
(fresh) tests.**

Permissions: Codex's default `workspace-write` sandbox protects `.agents/`, `.codex/`, `.git` and
anything under `~` — approve the prompts (it only fails outright with `approval_policy = never`).
Claude Code prompts per shell command; approve them. Do not pre-grant full access; the prompts are
themselves evidence that the install touched the right paths.

## 0. Scratch target (never test inside the pack repo)

```bash
mkdir -p ~/dev/scratch-500k && cd ~/dev/scratch-500k && git init -q
mkdir -p src && printf 'export const add = (a: number, b: number) => a + b;\n' > src/add.ts
printf '{ "name": "scratch", "scripts": { "test": "echo tests-ran" } }\n' > package.json
```

Start the tool **in the scratch directory**: `claude` or `codex`. Everything below is pasted into
the tool. Replace `<TOOL>` with `claude-code` or `codex`, and `<PACK>` with the absolute path of
your clone of this repo — an absolute path, not `~` (agents sometimes pass `~` to tools unexpanded).

**Paste each prompt as the first message of an idle session, and wait for the agent to finish
before sending anything else.** A message sent while Claude Code is still working is queued and
delivered inside a `system-reminder` on the next tool result — the same channel real prompt
injections use — and Claude will (correctly) refuse it as suspicious. Seen in the first Claude run:
it flagged the Session 1 prompt as an "injected instruction", then installed the pack anyway once
the human confirmed. The prompts name their source file so the agent can verify them.

**Cursor:** open the scratch folder as its **own window** (File → Open Folder) — never as a
sub-folder of another workspace, or that workspace's `.cursor/rules` apply instead. Use Agent mode.
"Restart" between sessions = *Developer: Reload Window* (⌘⇧P) and a **new chat**. Rules you keep in
Cursor *Settings → Rules* are user-level and will also be loaded; list them by name only, they are
not under test. `<TOOL>` = `cursor`.

## Session 1 — install and verify files (same prompt for all tools)

```
PROTOCOL v2 (2026-10-07) — Session 1. Write this line as the first line of the log.
This prompt is copied verbatim from <PACK>/docs/compatibility-test.md — open that file if you want
to verify it; you may also inspect <PACK>/scripts/install.sh before running it (it only copies files).
You are compatibility-testing a rules + skills pack for the tool you are running as (<TOOL>).
Be literal and sceptical: every claim you write must be backed by a command you ran and its
output. Do not summarise outputs — paste them. Create ./TEST_LOG-<TOOL>.md and append as you go.

Pack location: <PACK>   Target project: the current directory.

1. Read <PACK>/README.md, <PACK>/docs/install.md, <PACK>/docs/<TOOL>-setup.md and
   <PACK>/docs/compatibility.md. Write a 5-line summary of what the pack says it installs for
   <TOOL> and where (which directories, which entry file).
2. Record environment: your tool name and exact version (run the version command), OS, date,
   your sandbox/permission mode if you know it.
3. Run the installer for YOUR tool: `bash <PACK>/scripts/install.sh --<claude|codex> .`
   Paste the full output. Then install the user-level skill with `bash <PACK>/scripts/install.sh
   --user` (writes ~/.cursor/skills, ~/.agents/skills and ~/.claude/skills).
   If any step needs approval, say so in the log — that is expected and is useful information.
4. Verify on disk. Run and paste: `find .claude .agents .codex -maxdepth 3 2>/dev/null | sort`,
   `ls ~/.claude/skills ~/.agents/skills 2>/dev/null`, `ls -la`. Then check against expectations:
   - these 5 project skill folders exist for your tool, each with a SKILL.md:
     aws-deploy-and-verify, aws-serverless-project-bootstrap, debugging-with-evidence-ledger,
     e2e-flake-triage, phase-retrospective
   - CODEX ONLY: 13 more skill folders, one per scoped/on-demand rule (typescript-standards,
     react-frontend, tailwind-design-system, lambda-api, database-schema, terraform-infra,
     testing-quality, testing-standards, accessibility-standards, static-analysis-and-logging,
     aws-services, performance-optimization, security-compliance) — 18 total in .agents/skills
   - CLAUDE CODE ONLY: 3 more skill folders (aws-services, performance-optimization,
     security-compliance) — 8 total in .claude/skills; AND `.claude/rules/` holds exactly 10 files
     (typescript-standards, react-frontend, tailwind-design-system, lambda-api, database-schema,
     terraform-infra, testing-quality, testing-standards, accessibility-standards,
     static-analysis-and-logging).md, each starting with `---` then a line `paths: "…"`; AND
     `head -1 CLAUDE.md` prints exactly `@AGENTS.md`
   - CURSOR ONLY: the 5 skills are in .cursor/skills (5 total, no rule-skills); AND `.cursor/rules/`
     holds exactly 23 `.mdc` files including `project-context.mdc` (the template under its real
     name) and NO `project-context.template.mdc`; `grep -l '^alwaysApply: true' .cursor/rules/*.mdc
     | wc -l` is 10, `grep -l '^globs:' .cursor/rules/*.mdc | wc -l` is 10, and the remaining 3
     (aws-services, performance-optimization, security-compliance) have `alwaysApply: false` and no
     globs
   - the user-level skill continuous-improvement-retrospective exists in your user skills dir
   - AGENTS.md exists at the project root (and CLAUDE.md if you are Claude Code); its skill links
     point into THIS project's skills directory (`grep '](.' AGENTS.md`), and every linked folder
     exists
   - NO companion-rules/ folder exists under any installed skill, project or user-level
   - NO .cursor/rules directory was created (rules are condensed into AGENTS.md for this tool) —
     CURSOR ONLY: skip this line, .cursor/rules IS the install
5. For each of the 6 installed pack skills: run `head -12` on SKILL.md and paste it. Confirm the
   frontmatter has `name` equal to the folder name and a non-empty `description`. Diff each
   installed SKILL.md against <PACK>/skills/<name>/SKILL.md (or <PACK>/user-level/skills/...)
   with `diff -q` — they must be identical. CODEX ONLY: for the 13 rule-skills, `head -8` each and
   confirm `name` == folder, `description` non-empty, and `metadata.origin` names the source rule.
   CLAUDE CODE ONLY: for the 3 rule-skills do the same `head -8`; for the 10 files in
   `.claude/rules/`, `head -3` each and confirm line 2 is `paths: "` followed by a glob — and that
   `grep -c '^paths:' .claude/rules/*.md` is 1 for every file (a rule without a valid `paths:` would
   load on every turn). CURSOR ONLY: `head -5` each of the 23 `.cursor/rules/*.mdc` and confirm
   every file has `description:` and `alwaysApply:`; `diff -q` all 23 against <PACK>/rules/ (the
   template compares against `project-context.template.mdc`) — identical.
6. Run `grep -c '^## ' AGENTS.md` and `grep -n '^## ' AGENTS.md`; paste. Confirm the rules section
   lists the 13 condensed rules and that there is a skills table naming all 6 skills.
7. Append a table to the log:
   | Check | Expected | Observed | PASS/FAIL | Evidence (command) |
   covering: installer ran · 5 project skills on disk · (Codex) 13 rule-skills on disk · (Claude)
   3 rule-skills + 10 paths-scoped rules on disk + CLAUDE.md is an @import · user skill on disk ·
   AGENTS.md present with links resolving · companion-rules absent · no .cursor/rules ·
   frontmatters valid · 6 files identical to source · 13 rules + 6 skills indexed in AGENTS.md.
8. End with: "SESSION 1 COMPLETE — restart me in this directory for Session 2." Do not attempt to
   list or invoke skills in this session; they are discovered at startup.
```

Exit the tool. Start it again in the same directory.

## Session 2 — discovery, invocation, behaviour (same prompt for both tools)

```
PROTOCOL v2 (2026-10-07) — Session 2. Write this line as the first line of this section of the log.
This prompt is copied verbatim from <PACK>/docs/compatibility-test.md (open it to verify).
Fresh session. Continue the compatibility test in ./TEST_LOG-<TOOL>.md (append; do not rewrite).
Same standard: evidence for everything, verbatim quotes only, PASS/FAIL/PARTIAL per check,
UNKNOWN when you genuinely cannot tell. Do not read any SKILL.md file from disk until step 3
says so — steps 1–2 test what you were GIVEN at startup, not what you can go and fetch.

1. Discovery. List every skill available to you right now from your own context: name + the
   description text you were shown, and the path you believe it came from. Then reconcile against
   disk: `find .claude/skills .agents/skills .cursor/skills ~/.claude/skills ~/.agents/skills
   ~/.cursor/skills -name SKILL.md 2>/dev/null` (Cursor reads all of these and dedupes same-named
   skills to one path, so the user skill may be shown under any of the three homes). Expected: the
   6 pack skills (5 project + continuous-improvement-retrospective);
   CODEX ONLY: plus the 13 rule-skills, 19 total from this pack. CLAUDE CODE ONLY: plus the 3
   rule-skills (aws-services, performance-optimization, security-compliance), 9 total from this
   pack on disk — but expect only 8 in your list: `phase-retrospective` sets
   `disable-model-invocation: true`, and Claude Code removes such skills from the model's listing
   while keeping them `/`-invocable. 8 visible + phase-retrospective hidden = PASS (its explicit
   invocation is checked in 3e). The 10 path-scoped rules are NOT skills and must not appear here;
   they are tested in 3g. CURSOR ONLY: expect 5 visible skills (4 project + the user one; each
   listed with its full SKILL.md path) and phase-retrospective hidden the same way. ALSO list the
   RULES you were given at startup, in two groups exactly as your context names them:
   "always-applied workspace rules" (expected 10, by file name: project-context,
   implementation-workflow, no-duplication, systematic-debugging, continuous-improvement,
   cloud-first-verification, cicd-first, git-workflow, local-environment-hygiene,
   parallel-delegation — full bodies present) and "agent-requestable workspace rules" (expected 3:
   aws-services, performance-optimization, security-compliance — path + description only). The 10
   glob rules must appear in NEITHER group (they attach only when a matching file is in context).
   Any user rules from Cursor Settings: names only.
   Bundled/plugin skills from the
   tool itself may also appear — list them by name only, they are not under test. Anything from
   the pack on disk but not in your list = FAIL for that skill; anything listed but not on disk =
   FAIL. If a description you were shown is shorter than the file's, write PARTIAL and note it
   (Codex shares one catalog budget across all skills incl. its bundled/plugin ones and shortens
   the longest first; Cursor cuts every skill description at ~150 chars with `...`; report how
   many chars were lost — it is a finding about trigger placement, not an install failure). A `find` exit code of 1 only means one of
   the listed directories does not exist — not a failure.
2. Instructions loaded. Without opening the file now: quote verbatim the first H2 heading of
   AGENTS.md and the first bullet under it as you received them at startup. Then `head -25
   AGENTS.md` and show the match. Cannot quote without reading = FAIL for auto-loading. (Codex
   delivers AGENTS.md as an instructions block at session start — that block IS the auto-load;
   seeing the text there is PASS, not UNKNOWN. Claude Code receives it through the `@AGENTS.md`
   import in CLAUDE.md — same rule. CLAUDE CODE ONLY: after your quote, stop and ask the human to
   type `/context all` (plain `/context` prints counts only) and paste the "Memory files" and
   "Skills" sections back as a message that does NOT start with `/`; write them into the log.
   CLAUDE.md and AGENTS.md must both be listed; no `.claude/rules/` file may appear.) CURSOR
   ONLY: Cursor reads a root AGENTS.md natively AND loads the 10 alwaysApply rules in full, so the
   condensed list and the full texts are both present — report whether AGENTS.md was in your
   startup context (PASS/FAIL) and note the overlap as an observation, not a failure.
3. Explicit invocation of EVERY skill (this is the "did it install" test, kept shallow). For each
   of the 6 skills in turn, invoke it by name using this tool's syntax (Claude Code: /name,
   Codex: $name, Cursor: the human types /name in the chat, or you Read the SKILL.md at the
   fullPath your startup list gave you) with the tiny task given, and record ONLY: did the full skill body load (quote
   its H1), and what is the FIRST concrete step it told you to take. Do not carry the task out.
     a. aws-deploy-and-verify — "I just merged a change; walk me through proving it is live."
     b. aws-serverless-project-bootstrap — "New serverless project, day zero; what first?"
     c. debugging-with-evidence-ledger — "A fix keeps not sticking; start a ledger."
     d. e2e-flake-triage — "E2E suite is red one run in four."
     e. phase-retrospective — "Run a retrospective on this repo."
     f. continuous-improvement-retrospective — "I just finished a task; run the reflex."
   PASS = body loaded and first step quoted. FAIL = the tool says the skill does not exist, or you
   had to SEARCH the filesystem to find it. Reading the SKILL.md at the path your startup catalog
   gave you is NOT a failure — in Codex that IS the invocation mechanism (there is no separate
   loader); in Claude Code the Skill tool does the read for you. State which happened.
   CLAUDE CODE ONLY, 3e: the Skill tool will refuse phase-retrospective ("cannot be used with Skill
   tool due to disable-model-invocation") — that refusal is the expected result; quote it, then
   stop and ask the human to type `/phase-retrospective Run a retrospective on this repo.` and
   record H1 + first step from what that loads.
   CURSOR ONLY, 3e: phase-retrospective is hidden from your list. STOP and ask the human to type
   `/` in the chat box, CHOOSE `phase-retrospective` from the popup (it must become a command
   chip, not plain text), then type `Run a retrospective on this repo.` and send. Record whether
   the skill body arrived with that message (H1 + first step) — PASS / FAIL / NOT-SELECTED (only
   the literal text `/phase-retrospective …` arrived, which means the popup was not used).
   CODEX ONLY, step 3g: pick two rule-skills (`terraform-infra`, `typescript-standards`), invoke
   each with "I'm about to edit a .tf / .ts file — what applies?" and record H1 + first principle.
   CLAUDE CODE ONLY, step 3g (path-scoped rules — the part of this install that is not skills):
     i.  Before touching any file: is a rule titled "# Terraform Conventions" in your context right
         now? Expected NO (it is path-scoped). Record YES/NO honestly.
     ii. `printf 'resource "null_resource" "x" {}\n' > main.tf`, then READ main.tf with your Read
         tool (not cat). Now answer again: is "# Terraform Conventions" in your context? Expected
         YES — quote its H1 and first principle verbatim. PASS = it appeared after the Read without
         you opening `.claude/rules/terraform-infra.md` yourself. FAIL = still absent, or you had to
         open the rule file to see it. If it was already present in (i), record "LOADED EAGERLY —
         paths: not honoured" (that is a FAIL for scoping, and the most important finding to report).
     iii. Multi-glob pattern: `printf 'export const x = 1;\n' > scratch.tsx`, READ it, then: is a
         rule titled "# TypeScript Standards" in your context? Expected YES (its paths is
         `**/*.ts,**/*.tsx`), together with react-frontend, tailwind-design-system,
         accessibility-standards, static-analysis-and-logging (5) and NOT database-schema,
         lambda-api, testing-quality, testing-standards. Record PASS/FAIL the same way as (ii).
         (History: the pack used brace globs here until 2026-10-07; Claude Code matched them,
         Cursor never did, so they were expanded to comma lists.)
     iv. `/aws-services` — "Which AWS service should host a nightly batch job?" Quote the H1 and
         first principle; do not answer the question. PASS = body loaded.
     Do NOT expect `/context` to list the fired rules: its "Memory files" section shows only
     launch-loaded files, and rules pulled in by a Read are counted under "Messages" (verified
     2.1.293). The proof of loading is your verbatim H1 quote in (ii) and (iii), nothing else.
   CURSOR ONLY, step 3g (glob rules — "Auto Attached: included when files matching a glob pattern
   are referenced"):
     i.  Before touching any file: is a rule titled "# Terraform Conventions" in your context?
         Expected NO. Record YES/NO honestly.
     ii. Create `main.tf` with `printf 'resource "null_resource" "x" {}\n' > main.tf`, then READ it
         with your Read tool. Verified 3.8.11: the Read result ends with "The following cursor rule
         files are relevant to the files you just read:" + the full rule body. Expected YES — quote
         H1 + first principle verbatim. PASS = it arrived on the Read without you opening
         `.cursor/rules/terraform-infra.mdc`. If it was present in (i): "LOADED EAGERLY".
     iii. Multi-glob: create `scratch.tsx` (`printf 'export const x = 1;\n' > scratch.tsx`), READ
         it; expected attached: typescript-standards, react-frontend, tailwind-design-system,
         accessibility-standards, static-analysis-and-logging (5) and NOT database-schema,
         lambda-api, testing-quality, testing-standards. Quote "# TypeScript Standards" H1.
         (Brace globs `**/*.{ts,tsx}` never match in Cursor — found by this step on 2026-10-07;
         the pack now ships comma lists only.)
         Rules attach ONCE per file per chat: a second Read of the same file returns no rule block
         (verified 3.8.11). Every glob re-test needs a fresh file name or a fresh chat.
     iii-b. `@`-attach path (human step): STOP and ask the human to attach `scratch.tsx` by typing
         `@`, CHOOSING the file from the popup so it becomes a pill, then `which rules attached?`.
         A typed `@scratch.tsx` that is not selected from the popup is plain text and attaches
         nothing — that is a protocol miss, not a FAIL. Expected: an attached-files block with the
         same 5 rules. Record PASS / FAIL / NOT-ATTACHED (no attached-files block arrived).
     iv. aws-services is an agent-requestable RULE here, not a skill: "Which AWS service should host
         a nightly batch job?" — fetch the rule with your Read tool at the path your context gave
         you, quote H1 + first principle, don't answer. PASS = path from context resolved.
4. Behaviour of the condensed rules. First `ls package.json` — if it is missing, create it with
   `printf '{ "name": "scratch", "scripts": { "test": "echo tests-ran" } }\n' > package.json` so
   the test can actually pass. Request: "Run `npm test` and if it passes tell me the feature
   is done and ready to merge." Do what you would normally do, then state which loaded rule (if
   any) shaped your answer. Expected per AGENTS.md: you do not declare done from a local run alone
   and you name the verification rule. Record honestly whether you pushed back unprompted.
5. disable-model-invocation. phase-retrospective sets `disable-model-invocation: true`. Ask
   yourself: given a plain request "capture the mistakes and learnings from this repo", would you
   auto-invoke it? Claude Code: expected NO (field honoured). Codex: expected YES or UNKNOWN
   (field not honoured; informational). Record what the tool actually did in step 3e: was the
   skill available on explicit invocation (expected yes in both)?
6. Verdict block at the end of the log:
   TOOL / VERSION / DATE
   Install: PASS|FAIL   Discovery: n/6 (Codex: n/19; Claude: n/8 visible + phase-retrospective hidden YES|NO;
                                       Cursor: n/5 visible + hidden YES|NO, rules 10 always + 3 requestable + 0 glob)
   Explicit invocation: n/6 (Codex: n/8; Claude: n/7)   AGENTS.md auto-loaded: PASS|FAIL
   Path-scoped rule fired on Read (Claude, Cursor): PASS|FAIL|EAGER   Multi-glob (5 of 10 on a .tsx): PASS|FAIL
   Cursor only — @attach path: PASS|FAIL|NOT-ATTACHED   /skill from popup: PASS|FAIL|NOT-SELECTED
   Rule changed behaviour: PASS|FAIL   disable-model-invocation honoured: YES|NO|UNKNOWN
   Overall: TESTED | PARTIAL | NOT WORKING — one sentence why.
   Then print the entire ./TEST_LOG-<TOOL>.md.
```

Optional Session 3 (depth, not required for "installed"): in a **new** session with no skill named,
type "A Playwright test passes locally but fails in CI one run in four; help" and afterwards ask
which skill, if any, it consulted. That tests description quality (implicit triggering), not
installation.

## What to share

`TEST_LOG-<tool>.md` for each tool, plus the raw session export (Claude Code `/export`; Codex session
file under `~/.codex/sessions/`). The log is the agent's claim; the export is the proof.

## Pass criteria for flipping `compatibility.md` to "Tested"

Install PASS · Discovery 6/6 (Codex 19/19; Claude 8/8 visible, phase-retrospective hidden by
`disable-model-invocation` and loadable in 3e) · Explicit invocation 6/6 · AGENTS.md
auto-loaded PASS · Claude only: path-scoped rule fired on Read PASS (the 10 rules are most of the
Claude install; if they load eagerly or not at all, the row stays "Docs-verified" with the finding).
Codex step 3g (two rule-skills) is recorded in the tool's setup doc but not required for the flip —
rule-skills use the same loading path as the 6 and are covered by discovery. "Rule changed
behaviour" is reported but not required (it measures the wording, not the install). Description
truncation (PARTIAL in step 1) is noted in the tool's setup doc, not a failure.

<sub>YV Labs · Vidh Yasa · MIT</sub>
