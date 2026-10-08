# User-level skills

One skill in this collection is meant to be installed **globally**, not per repo: [`continuous-improvement-retrospective`](skills/continuous-improvement-retrospective/).

## Why this one is global

The other skills encode a specific stack or project layout (AWS pipelines, an E2E flake log, a retrospective doc in the repo), so they belong in the repository they describe. The post-task retrospective is a **habit**. It should fire at the end of every task in every repo, including repos that have never heard of these rules. It's the portable version of the project rule `continuous-improvement.mdc`: the rule makes the reflex mandatory in one repo, and the user-level skill carries it everywhere else.

It exists because of finding F-I9: for the first ten weeks of the reference build, lessons were captured only when the user demanded a post-mortem. Once the reflex became automatic, the findings catalog grew from 67 to 139 in four weeks.

## Install

```bash
# Cursor
cp -R user-level/skills/continuous-improvement-retrospective ~/.cursor/skills/

# Open agent-skills layout (other compatible tools)
cp -R user-level/skills/continuous-improvement-retrospective ~/.agents/skills/
```

Cursor discovers user-level skills at session start, alongside project skills. The agent loads this one when a task matches its description.

## Caveat: Cloud Agents and remote workers

According to Cursor's docs, user-level skills aren't copied to Cloud Agents or remote workers; those only see what's committed in the repository. If you use them, also commit a project copy:

```bash
cp -R user-level/skills/continuous-improvement-retrospective <your-repo>/.cursor/skills/
```

The project copy and your global copy can coexist. Keep them in sync when you edit either one.

---

<sub>YV Labs · Vidh Yasa · MIT</sub>
