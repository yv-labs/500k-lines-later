# Provenance

Everything in this repo was extracted from one private project. This page states what can be
verified about it, how the numbers were produced, and how to read the provenance markers inside
the files.

## The reference build (what can be said)

- A greenfield, AWS-serverless web platform (React/TypeScript SPA, Node.js Lambdas on ARM64, a
  relational serverless DB plus a key-value store, managed auth, CDN + WAF, IaC in Terraform,
  CI/CD on AWS-native build/pipeline services). Private. Never named here; it was built as a pet
  project to stress-test an AI IDE at scale and harvest reusable artifacts — this repo.
- Built almost entirely through Cursor over roughly six months, in sequential phases, one feature
  branch at a time, with the pipeline as the only verification gate and no manual console work
  for infrastructure.

## Numbers and methodology

| Figure | Value | How it was counted |
|---|---:|---|
| Hand-authored lines | **427,335** | `git ls-files` minus generated/lock/third-party/snapshot/baseline-image/minified paths; `wc -l` over `.ts .tsx .js .mjs .cjs .tf .sql .yml .yaml .json .md .sh .css .html` |
| All-in lines | 457,037 | same, without the exclusions (adds lockfiles, generated types, OpenAPI output) |
| Strict (source + IaC + tests only) | ≈ 415.7K | excludes Markdown and JSON configuration |
| Commits | 449 | `git rev-list --count` on the integration branch |
| Finding IDs | **133** | regex `F-[A-Z]+[0-9]+` over the retrospective (139 table rows; some rows carry two IDs or a sub-finding) |
| Rules | 23 · 1,751 lines | `wc -l .cursor/rules/*.mdc` before scrubbing |
| Always-on rules | 10 · ≈ 9K tokens/turn | 695 lines × ~13 tokens/line estimate |
| Skills | 6 · 434 lines | 5 project (`.cursor/skills/`) + 1 user-level (`~/.cursor/skills/`) |
| Implementation Log blocks | 189 (~175 marked complete) | heading count in the implementation plan |
| First Implementation Log | 2026-04-19 | earliest dated log |

Counting choices are stated so you can disagree with them. The hand-authored figure is the one used
in titles; the all-in figure is given alongside wherever the first appears.

## Reading the markers inside files

- **`F-<letters><n>`** — a finding ID from the private retrospective. The letter group is a
  theme (A = local-testing waste, B = CI/CD introduced too late, C = infrastructure, I = debugging
  discipline & drift, N = first-time security gates, …); the number is sequence within the theme.
  Themes A–H are cross-cutting; I onward are per-phase sections added as the loop ran. The mapping table itself is private, but every ID cited in a rule is accompanied by
  enough of the incident to understand the lesson. Where a rule says *"(F-N2)"* read it as *"this
  sentence exists because of a specific incident"*.
- **Phase references** (`Phase 16.25`, `16.38d`) — the build was organised in numbered phases
  with lettered sub-phases. They are kept because they let you see *when* in the project a lesson
  arrived (early phases = foundations; 16.x = hardening, performance, E2E, security gates).
- **"Example from the reference build:"** — a tool- or account-specific detail kept as an
  illustration of the principle above it. Substitute your own.
- **Placeholders** — `<project>` `<Project>` `<prefix>` `<account-id>` `<region>` `<env>`
  `<repo>` `<api-package>/` `<infra>/` `<terraform-modules>/` `<user>` `<org>` `<dev-domain>`.
  They mark where a real identifier was.

## Per-rule provenance

See the catalog in [`rules/README.md`](../rules/README.md): born date (first git commit of the
file), revision count, inline finding-ref count, and a money quote. Rules marked `*` entered git in
a single import on 2026-06-09, so their real birth is earlier than their git history.

## Per-skill provenance

Each `skills/<name>/README.md` has a Provenance table: born, revisions, findings absorbed, and the
incident that created it.

## Rules that changed most

| Rule | Revisions | Why |
|---|---:|---|
| `cicd-first.mdc` | 11 | every pipeline-semantics surprise landed here (CI ≠ deploy, validate ≠ plan, default-branch pulls, `dash` not `bash`, trigger-level path filtering) |
| `git-workflow.mdc` | 9 | branch model simplified twice; push mechanics; "escape hatch — confirm first" |
| `terraform-infra.mdc` | 6 (16 inline refs) | import/adopt drift in-session, module default flags, VPC endpoint coupling |
| `cloud-first-verification.mdc` | 5 | the doctrine hardened after each "worked locally" incident |

## Rule that never changed

`tailwind-design-system.mdc` — 1 revision. Design tokens were right from the start and the
glob-scoping meant it never cost a token when it wasn't needed.

## What was deliberately left out of this repo

- The private retrospective table (findings with full incident detail). The *template* ships in
  `templates/`; the content is the project's.
- The implementation plan, PRD, TRD, architecture doc — templates will ship in a later release.
- Anything that could identify the project: name, domain, data model, business rules, region,
  account, URLs. If you find a leak, open an issue titled `scrub:` and it will be fixed same day.
