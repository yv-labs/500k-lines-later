# Cursor setup

Cursor is the native target: rules and skills are used exactly as they were in the reference build.

## 1. Rules

```bash
mkdir -p your-repo/.cursor/rules
cp rules/*.mdc your-repo/.cursor/rules/
mv your-repo/.cursor/rules/project-context.template.mdc your-repo/.cursor/rules/project-context.mdc
```

(`scripts/install.sh --cursor your-repo` does the same and renames the template for you. Never leave
the file with `.template` in the name inside `.cursor/rules/` — it is `alwaysApply: true` and would
load unfilled.)

Open `project-context.mdc` and fill it in. Then open Cursor → Settings → Rules and confirm the
rules appear with the right scope (Always / Auto Attached / Agent Requested).

### Frontmatter → behaviour

| Frontmatter | Cursor label | Effect |
|---|---|---|
| `alwaysApply: true` | Always | injected into every turn |
| `globs: "**/*.tf"` | Auto Attached | injected when a matching file is in context |
| neither | Agent Requested | the agent reads the `description` and decides |

### Token budget

The 10 always-on rules are ≈ 9K tokens per turn. That is a deliberate cost in the reference build.
If you want to trim: start with the Starter pack (5 rules) and let findings justify the rest. Never
make a glob-scoped rule always-on "to be safe" — it was scoped for a reason.

### Cursor-specific notes

- Rules are re-read when a chat starts; after editing a rule, start a new chat to see the effect.
- `description` is what the agent reads to decide relevance for Agent-Requested rules — keep it a
  single, specific line.
- Legacy `.cursorrules` is not used by this pack.

## 2. Skills

Two valid locations; Cursor reads both:

```bash
cp -R skills/* your-repo/.cursor/skills/      # Cursor-native
# or
cp -R skills/* your-repo/.agents/skills/      # open standard, also read by Codex / Claude Code
```

Cursor also discovers skills from `.claude/skills/` and `.codex/skills/` in the project, and from
user-level `~/.cursor/skills/`, `~/.agents/skills/`, `~/.claude/skills/`, `~/.codex/skills/`.

### Companion rules

Each skill folder carries `companion-rules/` — copies of the rules the skill assumes are loaded. If
you installed all rules you already have them; if you cherry-picked one skill, copy its companions:

```bash
cp skills/<name>/companion-rules/*.mdc your-repo/.cursor/rules/
```

### The user-level skill

```bash
mkdir -p ~/.cursor/skills
cp -R user-level/skills/continuous-improvement-retrospective ~/.cursor/skills/
```

It will fire at the end of tasks in every repo. To use it with Cloud Agents, turn on *Settings →
Agents → Sync Skills for Cloud Agents* (syncs `~/.cursor/skills/` only — `~/.agents/skills/` never
syncs), or commit a copy under `.cursor/skills/` in repos that use them.

## 3. Importing as a plugin

The repo carries `.cursor-plugin/marketplace.json` and `plugin.json` so it can be imported through
Cursor's plugin import flow once published. Until then, the copy commands above are the install.

## 4. Optional: on-demand rules as skills

The three on-demand rules (`aws-services`, `performance-optimization`, `security-compliance`) are
"Apply Intelligently" rules — exactly the kind Cursor's built-in `/migrate-to-skills` converts into
skills. Either form works; skills give you `/`-invocation and progressive loading, rules keep them
visible alongside the rest of the pack. The pack ships them as rules so one `cp` installs everything.

## 5. Verifying it works

Start a new chat and ask: *"What rules are you following right now?"* — the always-on set should be
listed. Open a `.tf` file and ask again — `terraform-infra` should join. Ask it to *"prove this change
is done"* — it should reach for the `aws-deploy-and-verify` skill (or your CI equivalent), not start
a local server.
