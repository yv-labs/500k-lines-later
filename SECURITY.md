# Security

This repository contains Markdown and three POSIX shell scripts that copy files. There is no
runtime, no network access, no telemetry.

- **Skills are prompts.** Read a `SKILL.md` before installing it, exactly as you would read a
  script before running it. The agent will follow it.
- **Scanning.** The skills were run through a skill scanner before publish; the report is linked
  from the README once published. If you scan them yourself and find anything, open an issue.
- **Scripts.** `scripts/install.sh` never overwrites without `--force` and prints every path it
  writes. `sync-companions.sh` and `validate.sh` only touch files inside this repo.
- **Reporting.** Open a private security advisory on GitHub or an issue titled `security:`.
  Scrub leaks (anything identifying the source project) go under `scrub:` and are fixed same day.
