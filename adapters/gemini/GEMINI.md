# GEMINI.md

Read `AGENTS.md` in full before working — it is the canonical index of rules and skills for this
project. Skills live in `.agents/skills/`; each `SKILL.md` is a procedure to follow when its
description matches the task.

Non-negotiables, even if you read nothing else:

- The pipeline, not your machine, decides whether work is done. Push, then read the log.
- "Done" requires a shown artifact (CI log, deployed URL, request-id, live response).
- Search the whole repo before creating anything; extend, don't duplicate.
- After two failed fixes, stop and switch to systematic debugging with an attempt ledger.
- Treat every subagent's "done" as a claim; read the full diff.
- After each task, run the retrospective reflex and extend an existing rule or skill.
