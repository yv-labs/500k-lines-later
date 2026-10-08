#!/usr/bin/env bash
# Copy rules / skills into a target repo in the layout a given tool reads.
# Plain file copies only. Never overwrites without --force. Prints every path it writes.
#
#   ./scripts/install.sh --cursor    <repo>   rules → .cursor/rules, skills → .cursor/skills, AGENTS.md
#   ./scripts/install.sh --claude    <repo>   skills → .claude/skills, CLAUDE.md (@AGENTS.md import), AGENTS.md,
#                                             10 scoped rules → .claude/rules/<name>.md with `paths:` (native
#                                             path-scoping), 3 on-demand rules installed AS skills
#   ./scripts/install.sh --codex     <repo>   skills → .agents/skills, AGENTS.md, and the 13 scoped/on-demand
#                                             rules installed AS skills (Codex has no scoped-rule concept)
#   ./scripts/install.sh --agents-md <repo>   AGENTS.md + .agents/skills
#   ./scripts/install.sh --copilot   <repo>   .github/copilot-instructions.md + .github/instructions/*.instructions.md
#   ./scripts/install.sh --gemini    <repo>   GEMINI.md + AGENTS.md + .agents/skills
#   ./scripts/install.sh --windsurf  <repo>   .windsurf/rules/*.md (frontmatter mapped, long rules split at 12K chars)
#   ./scripts/install.sh --devin     <repo>   same, into .devin/rules/ (current Devin Desktop; takes precedence)
#   ./scripts/install.sh --user                user-level skill → ~/.cursor/skills + ~/.agents/skills + ~/.claude/skills
#   options: --pack starter|verification|standards|on-demand|all (default all)   --force
#            --full-rules   full always-on rule bodies, ~9K tokens/turn: codex → appended to AGENTS.md;
#                           claude → .claude/rules/<name>.md without `paths:` (loaded at launch)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="" TARGET="" PACK="all" FORCE=0 FULL=0

while [ $# -gt 0 ]; do
  case "$1" in
    --cursor|--claude|--codex|--agents-md|--copilot|--gemini|--windsurf|--devin) MODE="${1#--}"; TARGET="${2:?target repo path required}"; shift 2 ;;
    --user) MODE="user"; shift ;;
    --pack) PACK="${2:?pack name}"; shift 2 ;;
    --force) FORCE=1; shift ;;
    --full-rules) FULL=1; shift ;;
    -h|--help) sed -n '2,19p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
[ -n "$MODE" ] || { sed -n '2,19p' "$0"; exit 2; }

STARTER="project-context.template implementation-workflow no-duplication systematic-debugging continuous-improvement"
VERIFICATION="cloud-first-verification cicd-first git-workflow local-environment-hygiene parallel-delegation"
STANDARDS="typescript-standards react-frontend tailwind-design-system lambda-api database-schema terraform-infra testing-quality testing-standards accessibility-standards static-analysis-and-logging"
ONDEMAND="aws-services performance-optimization security-compliance"

rules_for_pack() {
  case "$1" in
    starter) echo "$STARTER" ;;
    verification) echo "$VERIFICATION" ;;
    standards) echo "$STANDARDS" ;;
    on-demand) echo "$ONDEMAND" ;;
    all) echo "$STARTER $VERIFICATION $STANDARDS $ONDEMAND" ;;
    *) echo "unknown pack: $1" >&2; exit 2 ;;
  esac
}
in_list() { case " $2 " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }   # in_list <item> "<space list>"

copy() { # copy <src> <dst>
  if [ -e "$2" ] && [ "$FORCE" -ne 1 ]; then echo "skip (exists): $2"; return; fi
  mkdir -p "$(dirname "$2")"
  if [ -d "$1" ]; then rm -rf "$2"; cp -R "$1" "$2"; else cp "$1" "$2"; fi
  echo "wrote: $2"
}

copy_rules() { # copy_rules <dest-dir>
  for r in $(rules_for_pack "$PACK"); do
    # The project-context template is installed under its REAL name so a half-filled template is
    # never silently loaded always-on under a second filename.
    dst="$r"; [ "$r" = "project-context.template" ] && dst="project-context"
    copy "$HERE/rules/$r.mdc" "$1/$dst.mdc"
  done
}

copy_skills() { # copy_skills <dest-dir>
  for d in "$HERE"/skills/*/; do
    n="$(basename "$d")"; copy "$d" "$1/$n"
    rm -rf "$1/$n/companion-rules"   # companions are for cherry-picking; full installs get rules/ instead
  done
}

# AGENTS.md is written for the INSTALLED project: its skill links are rewritten to the directory
# this tool actually reads, so an agent following a link lands on a file that exists.
install_agents_md() { # install_agents_md <dest-file> <project-skills-dir> <user-skills-dir>
  if [ -e "$1" ] && [ "$FORCE" -ne 1 ]; then echo "skip (exists): $1"; return; fi
  mkdir -p "$(dirname "$1")"
  sed -e "s#](skills/#](${2}/#g" -e "s#](user-level/skills/#](${3}/#g" "$HERE/AGENTS.md" > "$1"
  echo "wrote: $1"
}

# --- frontmatter helpers (pure sed/awk; no yaml parser) ---
fm_value() { awk -v k="$2" 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} index($0,k":")==1{sub(k":[ ]*","");gsub(/^"|"$/,"");print;exit}' "$1"; }
body()     { awk 'NR==1&&$0=="---"{infm=1;next} infm&&$0=="---"{infm=0;next} !infm{print}' "$1"; }

# Tools without glob-scoped rules get the 10 scoped standards + 3 on-demand rules as SKILLS: same
# name, the rule's description (plus its globs) as the trigger, the rule body as the procedure.
# The agent then pulls `terraform-infra` when it edits Terraform, exactly as Cursor would auto-attach it.
rules_as_skills() { # rules_as_skills <dest-skills-dir> [<rule list>] [<reason>]
  list="${2:-$STANDARDS $ONDEMAND}"
  reason="${3:-installed as a skill because this tool has no scoped rules}"
  for r in $(rules_for_pack "$PACK"); do
    in_list "$r" "$list" || continue
    src="$HERE/rules/$r.mdc"; dst="$1/$r/SKILL.md"
    if [ -e "$dst" ] && [ "$FORCE" -ne 1 ]; then echo "skip (exists): $dst"; continue; fi
    d="$(fm_value "$src" description | sed 's/"/\\"/g')"; g="$(fm_value "$src" globs)"
    case "$d" in *.|*!|*\?) ;; *) d="$d." ;; esac          # end the sentence before adding the trigger
    [ -n "$g" ] && d="$d Use when creating or editing files matching: $g"
    mkdir -p "$1/$r"
    { printf -- '---\nname: %s\ndescription: "%s"\nlicense: MIT\nmetadata:\n  author: YV Labs by Vidh Yasa\n  source: https://github.com/yv-labs/500k-lines-later\n  origin: rules/%s.mdc, %s\n---\n' "$r" "$d" "$r" "$reason"
      body "$src"; } > "$dst"
    echo "wrote: $dst"
  done
}

# Claude Code has native path-scoped rules: `.claude/rules/<name>.md` with `paths:` loads only when
# Claude reads/edits a matching file (the same semantics as Cursor `globs`). The value is written as a
# quoted comma-separated string — valid YAML, and the form that passed Claude Code's own issue
# tracker test matrix (#19377); a YAML list is documented but reported to fail silently, and an
# unparseable frontmatter makes the rule load UNCONDITIONALLY. `paths:` is the only field Claude
# reads, so nothing else goes in the frontmatter. Scoped rules are project-level only: `paths:` is
# not honoured under ~/.claude/rules/ (#57722).
claude_rules() { # claude_rules <dest-rules-dir> <rule list> <scoped:1|0>
  for r in $(rules_for_pack "$PACK"); do
    in_list "$r" "$2" || continue
    src="$HERE/rules/$r.mdc"; n="$r"; [ "$r" = "project-context.template" ] && n="project-context"
    dst="$1/$n.md"
    if [ -e "$dst" ] && [ "$FORCE" -ne 1 ]; then echo "skip (exists): $dst"; continue; fi
    mkdir -p "$1"
    if [ "$3" -eq 1 ]; then
      g="$(fm_value "$src" globs)"; [ -n "$g" ] || { echo "skip (no globs): $src" >&2; continue; }
      { printf -- '---\npaths: "%s"\n---\n' "$g"; body "$src"; } > "$dst"
    else
      body "$src" > "$dst"
    fi
    echo "wrote: $dst"
  done
}

# Optional: the full always-on bodies appended to AGENTS.md (what Cursor loads every turn, ~9K tokens).
append_full_rules() { # append_full_rules <agents-md>
  { printf '\n\n## Full always-on rules (installed with --full-rules)\n\nThe condensed list above is the summary; these are the complete texts Cursor would load every turn.\n'
    for r in $(rules_for_pack "$PACK"); do
      in_list "$r" "$STARTER $VERIFICATION" || continue
      n="$r"; [ "$r" = "project-context.template" ] && n="project-context (fill this in)"
      printf '\n---\n\n### %s\n\n' "$n"; body "$HERE/rules/$r.mdc"
    done; } >> "$1"
  echo "appended full always-on rules: $1"
}

case "$MODE" in
  cursor)
    copy_rules "$TARGET/.cursor/rules"; copy_skills "$TARGET/.cursor/skills"
    install_agents_md "$TARGET/AGENTS.md" ".cursor/skills" "~/.cursor/skills"
    echo; echo "Next: fill in $TARGET/.cursor/rules/project-context.mdc — it is the one rule unique to your project." ;;
  claude)
    copy_skills "$TARGET/.claude/skills"
    claude_rules "$TARGET/.claude/rules" "$STANDARDS" 1                      # 10 scoped → native paths: rules
    rules_as_skills "$TARGET/.claude/skills" "$ONDEMAND" "installed as a skill because Claude Code has no description-triggered rules"
    copy "$HERE/CLAUDE.md" "$TARGET/CLAUDE.md"
    install_agents_md "$TARGET/AGENTS.md" ".claude/skills" "~/.claude/skills"
    if [ "$FULL" -eq 1 ]; then claude_rules "$TARGET/.claude/rules" "$STARTER $VERIFICATION" 0; fi
    echo; echo "Claude Code: 10 scoped rules → .claude/rules/ (paths:), 3 on-demand rules → .claude/skills/ as skills,"
    echo "CLAUDE.md imports AGENTS.md with @AGENTS.md. Start a NEW session (or /reload-skills) in $TARGET."
    [ "$FULL" -eq 1 ] || echo "Full always-on texts (~9K tokens/turn): re-run with --full-rules." ;;
  codex)
    copy_skills "$TARGET/.agents/skills"; rules_as_skills "$TARGET/.agents/skills"
    install_agents_md "$TARGET/AGENTS.md" ".agents/skills" "~/.agents/skills"
    if [ "$FULL" -eq 1 ]; then append_full_rules "$TARGET/AGENTS.md"; fi
    echo; echo "Codex: scoped/on-demand rules were installed as skills in .agents/skills/ (Codex has no scoped rules)."
    echo "Start a NEW Codex session in $TARGET — skills are discovered at startup." ;;
  agents-md)
    copy_skills "$TARGET/.agents/skills"; install_agents_md "$TARGET/AGENTS.md" ".agents/skills" "~/.agents/skills" ;;
  gemini)
    copy_skills "$TARGET/.agents/skills"; install_agents_md "$TARGET/AGENTS.md" ".agents/skills" "~/.agents/skills"
    copy "$HERE/adapters/gemini/GEMINI.md" "$TARGET/GEMINI.md" ;;
  copilot)
    copy "$HERE/adapters/copilot/copilot-instructions.md" "$TARGET/.github/copilot-instructions.md"
    install_agents_md "$TARGET/AGENTS.md" ".agents/skills" "~/.agents/skills"; copy_skills "$TARGET/.agents/skills"
    for r in $STANDARDS; do
      src="$HERE/rules/$r.mdc"; dst="$TARGET/.github/instructions/$r.instructions.md"
      g="$(fm_value "$src" globs)"; [ -n "$g" ] || continue
      if [ -e "$dst" ] && [ "$FORCE" -ne 1 ]; then echo "skip (exists): $dst"; continue; fi
      mkdir -p "$(dirname "$dst")"
      { printf -- '---\napplyTo: "%s"\n---\n' "$g"; body "$src"; } > "$dst"; echo "wrote: $dst"
    done ;;
  windsurf|devin)
    CAP=12000; RULEDIR=".windsurf/rules"; [ "$MODE" = devin ] && RULEDIR=".devin/rules"
    for r in $(rules_for_pack "$PACK"); do
      src="$HERE/rules/$r.mdc"; outdir="$TARGET/$RULEDIR"; mkdir -p "$outdir"
      [ "$r" = "project-context.template" ] && r="project-context"
      g="$(fm_value "$src" globs)"; a="$(fm_value "$src" alwaysApply)"; d="$(fm_value "$src" description)"
      if [ "$a" = "true" ]; then fm=$'---\ntrigger: always_on\n---'
      elif [ -n "$g" ]; then fm=$'---\ntrigger: glob\nglobs: "'"$g"$'"\n---'
      else fm=$'---\ntrigger: model_decision\ndescription: '"$d"$'\n---'; fi
      tmp="$(mktemp)"; body "$src" > "$tmp"
      if [ "$(wc -c < "$tmp")" -le "$CAP" ]; then
        dst="$outdir/$r.md"; { echo "$fm"; cat "$tmp"; } > "$dst"; echo "wrote: $dst"
      else
        # split into chunks under CAP; break at headings, falling back to blank lines
        FM="$fm" awk -v cap="$CAP" -v out="$outdir/$r" '
          BEGIN{ fm=ENVIRON["FM"] }
          function flush(){ if(buf!=""){ f=out "-" (++n) ".md"; print fm > f; printf "%s", buf > f; close(f); print "wrote: " f; buf="" } }
          /^#{2,3} / || /^[[:space:]]*$/ { if(length(buf)>0 && length(buf)+length(para)>cap) flush(); buf=buf para; para="" }
          { para=para $0 "\n" } END{ if(length(buf)+length(para)>cap) flush(); buf=buf para; flush() }' "$tmp"
      fi; rm -f "$tmp"
    done
    install_agents_md "$TARGET/AGENTS.md" ".agents/skills" "~/.agents/skills"; copy_skills "$TARGET/.agents/skills" ;;
  user)
    for d in "$HERE"/user-level/skills/*/; do n="$(basename "$d")"
      for root in .cursor .agents .claude; do
        copy "$d" "$HOME/$root/skills/$n"; rm -rf "$HOME/$root/skills/$n/companion-rules"
      done; done ;;
esac
