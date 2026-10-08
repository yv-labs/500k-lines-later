#!/usr/bin/env bash
# Fail if any published file contains a term from the scrub lists.
#   scripts/scrub-terms.txt          generic leak classes (committed)
#   scripts/scrub-terms.private.txt  the maintainer's project-specific terms (gitignored, optional;
#                                    override the path with SCRUB_PRIVATE_LIST=...)
# The private list must never be committed: publishing the words you scrub defeats the scrub.
#
# Implemented in Python (re supports the PCRE features the lists use: \b, lookaheads) so the check
# has no dependency on ripgrep — an earlier version silently PASSED when `rg` was not installed.
# A scrub gate must fail closed.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST="$HERE/scripts/scrub-terms.txt"
PRIV="${SCRUB_PRIVATE_LIST:-$HERE/scripts/scrub-terms.private.txt}"
[ -f "$LIST" ] || { echo "scrub check FAILED — missing $LIST" >&2; exit 2; }
command -v python3 >/dev/null || { echo "scrub check FAILED — python3 is required" >&2; exit 2; }

if [ -d "$HERE/.git" ] && git -C "$HERE" ls-files --error-unmatch scripts/scrub-terms.private.txt >/dev/null 2>&1; then
  echo "scrub check FAILED — scripts/scrub-terms.private.txt is tracked by git. Untrack it." >&2; exit 1
fi

python3 - "$HERE" "$LIST" "$PRIV" <<'PY'
import os, re, sys
root, generic, private = sys.argv[1], sys.argv[2], sys.argv[3]
lists = [generic] + ([private] if os.path.isfile(private) else [])
patterns = []
for path in lists:
    for n, line in enumerate(open(path, encoding="utf-8"), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        try:
            patterns.append((re.compile(s, re.I), s))
        except re.error as e:
            print(f"scrub check FAILED — bad pattern {path}:{n} {s!r}: {e}", file=sys.stderr); sys.exit(2)
skip_files = {os.path.realpath(generic), os.path.realpath(private)}
hits = 0
for dirpath, dirnames, filenames in os.walk(root):
    dirnames[:] = [d for d in dirnames if d != ".git"]
    for fn in filenames:
        p = os.path.join(dirpath, fn)
        if os.path.realpath(p) in skip_files:
            continue
        try:
            text = open(p, encoding="utf-8").read()
        except (UnicodeDecodeError, OSError):
            continue  # binary or unreadable: nothing to scrub
        for i, line in enumerate(text.splitlines(), 1):
            for rx, src in patterns:
                if rx.search(line):
                    print(f"{os.path.relpath(p, root)}:{i}: [{src}] {line.strip()[:160]}"); hits += 1; break
if hits:
    print(f"\nscrub check FAILED — {hits} hit(s); remove the terms above before publishing.", file=sys.stderr); sys.exit(1)
mode = "generic + private lists" if len(lists) == 2 else "generic list only — no private list present"
print(f"scrub check passed (0 hits; {len(patterns)} patterns; {mode})")
PY
