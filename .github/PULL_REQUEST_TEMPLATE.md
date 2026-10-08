## What changed

<!-- one or two lines -->

## Which finding justifies it

<!-- Link the issue, or describe the incident inline: what broke, root cause, evidence.
     "Best practice" with no incident behind it will be declined — see CONTRIBUTING.md. -->

## Checklist

- [ ] Extends an existing rule/skill rather than adding a near-duplicate
- [ ] Principle stated first; the incident is the example, not the rule
- [ ] Frontmatter unchanged (`globs` / `alwaysApply`) — or the token-cost trade-off is explained above
- [ ] `scripts/validate.sh` passes locally (frontmatter · catalogs · companion sync · scrub list)
- [ ] `rules/README.md` / skill `README.md` updated if lines, scope or the money quote changed
- [ ] Nothing identifies the private source project
