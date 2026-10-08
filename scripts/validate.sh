#!/usr/bin/env bash
# Structural checks run in CI and before every release:
#   1. every rules/*.mdc has valid frontmatter (description, alwaysApply; globs optional)
#   2. every skill folder has SKILL.md (name == folder, description) and README.md
#   3. every rule and skill is listed in AGENTS.md and the catalogs (rules/README.md, skills/README.md)
#   4. companion-rules are in sync (scripts/sync-companions.sh --check)
#   5. scrub list has 0 hits (scripts/scrub-check.sh)
#   6. every description is <= 400 chars and has no <placeholder>: Codex shares one ~8,000-char
#      budget across ALL skills in a session (bundled + plugins + ours) and water-fills it, so on a
#      machine with ~60 skills anything past ~430 chars is cut. Front-load the trigger words.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; fail=0
err() { echo "FAIL: $*" >&2; fail=1; }
DESC_MAX=400
desc_of() { awk 'NR>1&&$0=="---"{exit} /^description:/{sub(/^description:[ ]*/,"");gsub(/^"|"$/,"");print;exit}' "$1"; }
check_desc() { # check_desc <label> <file>
  local desc len  # local: the skills loop below uses $d for the folder
  desc="$(desc_of "$2")"; len="$(printf '%s' "$desc" | wc -m | tr -d ' ')"
  [ "$len" -le "$DESC_MAX" ] || err "$1: description is $len chars (max $DESC_MAX — Codex shortens long ones)"
  case "$desc" in *\<*\>*) err "$1: description contains a <placeholder> — it is shown to the agent verbatim" ;; esac
}

for f in "$HERE"/rules/*.mdc; do
  b="$(basename "$f")"
  [ "$(sed -n 1p "$f")" = "---" ] || err "$b: no opening frontmatter"
  end="$(awk 'NR>1&&$0=="---"{print NR;exit}' "$f")"; [ -n "$end" ] || { err "$b: frontmatter not closed"; continue; }
  fm="$(sed -n "2,$((end-1))p" "$f")"
  echo "$fm" | grep -q '^description:' || err "$b: missing description"
  echo "$fm" | grep -q '^alwaysApply:' || err "$b: missing alwaysApply"
  # Cursor's auto-attach matcher does not expand {a,b} (verified 3.8.11: **/*.{ts,tsx} never fired
  # on a .tsx read while **/*.tsx did). Write comma-separated globs — the form every tool honours.
  echo "$fm" | grep '^globs:' | grep -q '{' && err "$b: brace glob in globs — Cursor never matches it; expand to a comma-separated list"
  check_desc "$b" "$f"
  n="${b%.mdc}"; n="${n%.template}"
  grep -q "$n" "$HERE/AGENTS.md" || err "$b: not listed in AGENTS.md"
  grep -q "$b" "$HERE/rules/README.md" || err "$b: not in rules/README.md catalog"
done

for d in "$HERE"/skills/*/ "$HERE"/user-level/skills/*/; do
  n="$(basename "$d")"
  [ -f "$d/SKILL.md" ] || { err "$n: missing SKILL.md"; continue; }
  [ -f "$d/README.md" ] || err "$n: missing README.md"
  [ "$(sed -n 1p "$d/SKILL.md")" = "---" ] || err "$n: SKILL.md has no frontmatter"
  sn="$(awk 'NR>1&&$0=="---"{exit} /^name:/{sub(/^name:[ ]*/,"");print;exit}' "$d/SKILL.md")"
  [ "$sn" = "$n" ] || err "$n: SKILL.md name '$sn' != folder"
  awk 'NR>1&&$0=="---"{exit} /^description:/{f=1} END{exit !f}' "$d/SKILL.md" || err "$n: SKILL.md missing description"
  check_desc "$n" "$d/SKILL.md"
  # attribution block is required on every skill (one was missed by hand once; caught in a Codex run)
  awk 'NR>1&&$0=="---"{exit} /^license:/{f=1} END{exit !f}' "$d/SKILL.md" || err "$n: SKILL.md missing license"
  awk 'NR>1&&$0=="---"{exit} /^metadata:/{f=1} END{exit !f}' "$d/SKILL.md" || err "$n: SKILL.md missing metadata"
  grep -q "This project's" "$d/SKILL.md" && err "$n: SKILL.md says \"This project's\" — a published skill must say \"the reference build\""
  grep -q "$n" "$HERE/AGENTS.md" || err "$n: not listed in AGENTS.md"
  grep -q "$n" "$HERE/skills/README.md" || err "$n: not in skills/README.md"
done

# strict YAML parse of every frontmatter (Cursor is lenient; Windsurf/Copilot conversions and
# third-party validators are not). Best-effort: skipped if python3+pyyaml are unavailable.
if python3 -c 'import yaml' 2>/dev/null; then
  python3 - "$HERE" <<'PY' || fail=1
import sys,glob,re,yaml
root=sys.argv[1]; bad=0
for f in glob.glob(root+'/rules/*.mdc')+glob.glob(root+'/skills/*/SKILL.md')+glob.glob(root+'/user-level/skills/*/SKILL.md'):
    m=re.match(r'---\n(.*?)\n---\n',open(f).read(),re.S)
    try:
        d=yaml.safe_load(m.group(1)); assert isinstance(d,dict) and d.get('description')
    except Exception as e:
        print(f"FAIL: strict YAML {f.replace(root+'/','')}: {str(e).splitlines()[0]}", file=sys.stderr); bad=1
sys.exit(bad)
PY
else
  echo "note: python3+pyyaml not found; strict YAML check skipped"
fi

bash "$HERE/scripts/sync-companions.sh" --check || fail=1
bash "$HERE/scripts/scrub-check.sh" || fail=1

[ "$fail" -eq 0 ] && echo "validate: OK" || { echo "validate: FAILED" >&2; exit 1; }
