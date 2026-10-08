# Contributing

Maintained by YV Labs (Vidh Yasa). Issues, discussions and PRs are welcome — this repo grows by other
people's findings, and a one-line compatibility report counts.

## Collaboration and access

This repo is **public and fork-friendly** (MIT). You do **not** need to be invited as a collaborator
to help:

- **Fork → branch → pull request** is the normal path. Every change is reviewed before it lands on
  `main`; that review is how contributions are accepted or declined.
- **Issues and Discussions** are open to everyone (compatibility reports, findings, scrub leaks).

**Write access** (org/repo collaborator) is reserved for people who have shipped several merged PRs
and want to help with triage or releases. Ask in a Discussion or on an merged PR if you want that
role — it is hand-picked, not automatic.

This repo has one rule for contributions and it is the same rule the files inside it follow:
**every addition must cite a finding.**

## Adding or changing a rule

1. State the incident: what broke, what the agent (or you) did instead of the right thing, how it
   was discovered. One paragraph. Evidence helps (a CI log excerpt, a diff, a quote).
2. State the principle the incident teaches — as a principle, not a checklist. Say *why*, not just
   *what*.
3. **Extend the rule that already owns the topic.** Do not create a new rule if an existing one is
   within a paragraph of the subject. Fork-free is the point.
4. Put the finding ID (your project's, e.g. `F-X3`) inline where the sentence it justifies lives.
5. Keep frontmatter valid and **do not change a rule's scope** (`globs`/`alwaysApply`) without
   explaining the token-cost trade-off in the PR.
6. Update `rules/README.md` (lines, revs if you track them, money quote if it changed).
7. Run `scripts/validate.sh`. It checks frontmatter, catalog listing, companion-rule sync and the
   scrub list.

## Adding or changing a skill

1. Same incident → principle requirement.
2. `SKILL.md`: `name` equals the folder; `description` is one paragraph of *when to use* triggers.
   Keep it lean — the agent loads it whole.
3. `README.md`: the eight sections (What / When / Where it goes / How it helps / Works best with /
   Provenance / Install / Example). Humans read this, the agent reads SKILL.md.
4. If the skill depends on rules, add them to the mapping in `scripts/sync-companions.sh` and run
   it. Never hand-edit `companion-rules/`.

## What will be declined

- Rewrites that turn a principle into a mechanical checklist.
- Rules that ban an approach instead of explaining the failure mode it causes.
- "Best practice" additions with no incident behind them.
- Anything that identifies the source project. `scripts/scrub-terms.txt` holds the generic
  classes (account ids, home paths, emails, hostnames); the project-specific list is deliberately
  not published.
- Long always-on additions without a token-budget justification.

## Style

Direct. Principle first, incident second, example third. Quote the user or the log when you have
it. Finding IDs and phase references are provenance, not instructions — leave them.

## Reporting a scrub leak

Use the **Scrub leak** issue form (or title an issue `scrub: <file>`) with the line. It will be
fixed the same day and the pattern added to the scrub lists.
