#!/usr/bin/env bash
# Survey repos and report what each one is missing. Read-only: this script never
# writes, pushes, or edits anything. Use it to decide where the effort goes
# before touching a single repo.
#
#   ./audit.sh                  audit the authenticated user's GitHub repos
#   ./audit.sh OWNER            audit another user or org
#   ./audit.sh --local [DIR]    audit local git repos in DIR (default: cwd)
#   ./audit.sh --public-only    skip private repos
#
# Needs `gh` for GitHub mode. Local mode needs only git.

set -uo pipefail

MODE=github
DIR=.
OWNER=""
PUBLIC_ONLY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --local)       MODE=local; if [ $# -gt 1 ] && [ -d "$2" ]; then DIR="$2"; shift; fi ;;
    --public-only) PUBLIC_ONLY=1 ;;
    -h|--help)     sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)             OWNER="$1" ;;
  esac
  shift
done

# Thin README threshold in bytes. Below this a README is a stub, not a page:
# roughly a title and a sentence.
THIN=800

red()  { printf '\033[31m%s\033[0m' "$1"; }
grn()  { printf '\033[32m%s\033[0m' "$1"; }
ylw()  { printf '\033[33m%s\033[0m' "$1"; }

audit_local() {
  printf '%-28s %-8s %-10s %s\n' "REPO" "README" "LICENSE" "NOTES"
  printf '%s\n' "--------------------------------------------------------------------------"
  for d in "$DIR"/*/; do
    [ -d "$d/.git" ] || continue
    name=$(basename "$d")
    notes=""

    readme=$(find "$d" -maxdepth 1 -iname 'readme*' | head -1)
    if [ -z "$readme" ]; then
      rstat=$(red "none")
    else
      size=$(wc -c < "$readme" | tr -d ' ')
      if [ "$size" -lt "$THIN" ]; then rstat=$(ylw "thin"); else rstat=$(grn "ok"); fi
      grep -qi '!\[' "$readme" || grep -qi '<img' "$readme" || notes="${notes}no-image "
      grep -qi '```mermaid' "$readme" || notes="${notes}no-diagram "
    fi

    if find "$d" -maxdepth 1 -iname 'license*' | grep -q .; then
      lstat=$(grn "ok")
    else
      lstat=$(red "none")
    fi

    # Tracked files that should never be tracked.
    if git -C "$d" ls-files 2>/dev/null | grep -qE '\.DS_Store|node_modules/|/\.env$|^\.env$'; then
      notes="${notes}$(red 'tracked-junk') "
    fi

    printf '%-28s %-17s %-19s %s\n' "$name" "$rstat" "$lstat" "$notes"
  done
}

audit_github() {
  command -v gh >/dev/null || { echo "gh not found. Install https://cli.github.com"; exit 1; }
  target="${OWNER:-$(gh api user --jq .login 2>/dev/null)}"
  [ -n "$target" ] || { echo "Not logged in. Run: gh auth login"; exit 1; }
  echo "Auditing GitHub repos for: $target"
  echo

  filter='.[]'
  [ "$PUBLIC_ONLY" -eq 1 ] && filter='.[] | select(.visibility == "PUBLIC")'

  printf '%-28s %-8s %-8s %-8s %-8s %s\n' "REPO" "VIS" "DESC" "TOPICS" "LICENSE" "README"
  printf '%s\n' "--------------------------------------------------------------------------"

  gh repo list "$target" --limit 200 --no-archived \
     --json name,description,repositoryTopics,licenseInfo,visibility \
     --jq "$filter | [.name, .visibility, ((.description // \"\") | length | tostring), ((.repositoryTopics // []) | length | tostring), (.licenseInfo.key // \"none\")] | @tsv" \
  | while IFS=$'\t' read -r name vis desclen ntopics lic; do
      [ -n "$name" ] || continue
      [ "$desclen" -gt 0 ]  && d=$(grn "ok") || d=$(red "none")
      [ "$ntopics" -gt 0 ]  && t=$(grn "$ntopics")  || t=$(red "none")
      [ "$lic" != "none" ]  && l=$(grn "$lic") || l=$(red "none")

      # gh api prints the 404 body to stdout, so a non-zero exit is not enough:
      # discard anything that is not a plain integer.
      size=$(gh api "repos/$target/$name/readme" --jq .size 2>/dev/null)
      case "$size" in (''|*[!0-9]*) size="" ;; esac

      if [ -z "$size" ]; then
        r=$(red "none")
      elif [ "$size" -lt "$THIN" ]; then
        r=$(ylw "thin ${size}b")
      else
        r=$(grn "ok ${size}b")
      fi

      printf '%-28s %-8s %-17s %-17s %-17s %s\n' "$name" "$vis" "$d" "$t" "$l" "$r"
    done

  echo
  echo "Read-only survey. Nothing was changed."
  echo "Pick the repos worth the effort, then run the skill on them one at a time."
}

case "$MODE" in
  local)  audit_local ;;
  github) audit_github ;;
esac
