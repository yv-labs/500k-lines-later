# Copilot instructions

Read `AGENTS.md` at the repo root — it is the canonical index of rules and skills. Path-scoped
standards are in `.github/instructions/*.instructions.md` and apply automatically by file type.

Every-turn rules, condensed:

1. Read the task and the design sections it references before touching code.
2. Search the whole repo before creating any file, function, type or module; extend, don't duplicate.
3. Build the minimum that satisfies the acceptance criteria. No speculative abstractions, no TODO
   placeholders for future tasks.
4. The CI pipeline is the only verification gate. Push the branch and read the log; never cite a
   local run as proof.
5. "Done" requires a shown artifact: CI log, deployed URL, request-id, live response.
6. One feature branch at a time, merged via PR gated on green CI. Deviations need explicit
   confirmation.
7. Know what the pipeline actually does (stages, buildspecs) before relying on it. CI is not the
   deploy; `validate` is not `plan`.
8. After two failed fixes on the same problem, stop and go systematic: falsifiable claim, list of
   un-ruled-out hypotheses, attempt ledger per variant, look for stacked root causes.
9. Treat a subagent's or tool's "done" as a claim — read the full diff.
10. A console/CLI fix to live infra is not done until it is in IaC and adopted into state.
11. After every task, run the retrospective reflex: record any friction as a finding and extend an
    existing rule or skill.
12. Guardrails, not cages: if a rule blocks a clearly better solution, do the better thing and update
    the rule.
