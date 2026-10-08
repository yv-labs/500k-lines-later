# Templates

The documents the loop runs on. Rules and skills tell the agent *how* to work; these templates give
it *where* to record what happened so the next task starts smarter.

| Template | Status | Used by |
|---|---|---|
| [`RETROSPECTIVE_AND_PLAYBOOK.template.md`](RETROSPECTIVE_AND_PLAYBOOK.template.md) | **shipped** | `continuous-improvement.mdc` (reflex), `phase-retrospective` skill (deep pass). Includes the single-finding block and the traceability table. |
| `IMPLEMENTATION_PLAN.template.md` — task block + Implementation Log block | next release | `implementation-workflow.mdc` (read the task; update the log) |
| `PRD.template.md` | next release | project-context rule, planning |
| `TRD.template.md` | next release | `implementation-workflow.mdc` ("read referenced TRD sections") |
| `ARCHITECTURE.template.md` | next release | `aws-services.mdc`, `terraform-infra.mdc` (canonical inventory) |

## How to use the retrospective template

1. `cp templates/RETROSPECTIVE_AND_PLAYBOOK.template.md docs/RETROSPECTIVE_AND_PLAYBOOK.md`
2. Replace `<Project>`; delete the placeholder rows.
3. Start with section **0** (ground-truth corrections) — every project has a few on day one.
4. Create theme sections only when a finding needs one. Don't pre-create letters.
5. The `continuous-improvement.mdc` rule will append findings; the `phase-retrospective` skill will
   add per-phase sections. Your job is to read it occasionally and make sure the traceability table
   is honest.
