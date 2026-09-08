#!/bin/bash
# Claude Code statusline — model, cwd, git branch, diff stats, PR + CI.
# Every segment is an OSC 8 terminal hyperlink pointing at the matching GitHub page
# (falls back to a plain/file:// segment when the repo has no GitHub remote).
# Receives session JSON on stdin. GitHub PR/CI data comes from a background-refreshed
# cache (statusline-gh.sh) so this script never blocks on the network.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "?"')
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$cwd")

# context window usage (present since CC 2.1.x; absent → segment is skipped)
read -r ctx_used ctx_size ctx_pct <<<"$(printf '%s' "$input" | jq -r '
  (.context_window // {}) as $c
  | [($c.total_input_tokens // 0), ($c.context_window_size // 0), ($c.used_percentage // -1)]
  | @tsv' | tr '\t' ' ')"

branch=""; sha=""; prefix=""; added=0; removed=0
default_branch="main"
host=""; slug=""

if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
  sha=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  prefix=$(git -C "$cwd" rev-parse --show-prefix 2>/dev/null)

  # staged + unstaged vs HEAD (falls back to worktree-only on an unborn branch)
  if git -C "$cwd" rev-parse --verify -q HEAD >/dev/null 2>&1; then
    numstat=$(git -C "$cwd" diff --numstat HEAD 2>/dev/null)
  else
    numstat=$(git -C "$cwd" diff --numstat 2>/dev/null)
  fi
  read -r added removed <<<"$(printf '%s\n' "$numstat" | awk '{ if ($1 ~ /^[0-9]+$/) a+=$1; if ($2 ~ /^[0-9]+$/) d+=$2 } END { print a+0, d+0 }')"

  remote=$(git -C "$cwd" remote get-url origin 2>/dev/null || git -C "$cwd" remote get-url upstream 2>/dev/null)
  case "$remote" in
    git@*:*)                    h=${remote#git@};   host=${h%%:*}; path=${remote#*:} ;;
    ssh://*|https://*|http://*|git://*)
                                r=${remote#*://};   r=${r#*@};     host=${r%%/*}; path=${r#*/} ;;
    *)                          host=""; path="" ;;
  esac
  path=${path%.git}; path=${path%/}
  case "$host" in
    *github*) slug="$path" ;;
    *)        host=""; slug="" ;;
  esac

  db=$(git -C "$cwd" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  [ -n "$db" ] && default_branch=${db#origin/}
fi

# ── GitHub PR / CI cache (refreshed out of band) ──────────────────────────────
PR=""; PR_STATE=""; PR_DRAFT=""; PR_REVIEW=""; PR_URL=""; CHECKS=""; TS=0
if [ -n "$slug" ]; then
  cache_dir="$HOME/.claude/cache/statusline"
  mkdir -p "$cache_dir" 2>/dev/null
  cache="$cache_dir/${slug//\//_}__${branch//\//_}"
  # shellcheck disable=SC1090
  [ -f "$cache" ] && . "$cache" 2>/dev/null
  now=$(date +%s)
  if [ $((now - ${TS:-0})) -ge 45 ] && command -v gh >/dev/null 2>&1; then
    bash "$HOME/.claude/statusline-gh.sh" "$cache" "$slug" "$branch" "$host" "$sha" \
      >/dev/null 2>&1 </dev/null &
    disown 2>/dev/null
  fi
fi

# ── rendering ────────────────────────────────────────────────────────────────
RESET=$'\033[0m'; DIM=$'\033[2m'; CYAN=$'\033[36m'; MAGENTA=$'\033[1;35m'
GREEN=$'\033[32m'; RED=$'\033[31m'; YELLOW=$'\033[33m'; BLUE=$'\033[34m'
PURPLE=$'\033[35m'
SEP="${DIM} · ${RESET}"

# tokens → compact "12k" / "0.4k"
fmt_k() { awk -v n="$1" 'BEGIN { if (n >= 1000) printf "%dk", (n/1000)+0.5; else printf "%.1fk", n/1000 }'; }

# OSC 8 hyperlink: link <url> <text>  (plain text when the url is empty)
link() {
  if [ -n "$1" ]; then printf '\033]8;;%s\a%s\033]8;;\a' "$1" "$2"
  else printf '%s' "$2"; fi
}

repo_url=""
[ -n "$slug" ] && repo_url="https://$host/$slug"
ref="${branch:-$sha}"

# cwd → that exact folder on GitHub at the current branch, else file:// for Finder
if [ -n "$repo_url" ] && [ -n "$ref" ]; then
  dir_url="$repo_url/tree/$ref/${prefix%/}"
  dir_url="${dir_url%/}"
elif [ -n "$cwd" ]; then
  dir_url="file://$cwd"
else
  dir_url=""
fi

# branch → branch tree view; detached HEAD → the commit itself
if [ -n "$repo_url" ]; then
  if [ -n "$branch" ]; then branch_url="$repo_url/tree/$branch"
  elif [ -n "$sha" ]; then branch_url="$repo_url/commit/$sha"
  fi
fi

# diff stats → the PR's files tab if there is one, else a compare against default
if [ -n "$PR_URL" ]; then
  diff_url="$PR_URL/files"
elif [ -n "$repo_url" ] && [ -n "$branch" ] && [ "$branch" != "$default_branch" ]; then
  diff_url="$repo_url/compare/$default_branch...$branch"
elif [ -n "$repo_url" ] && [ -n "$sha" ]; then
  diff_url="$repo_url/commit/$sha"
fi

out="${MAGENTA}$(link "https://github.com/anthropics/claude-code" "◆ ${model}")${RESET}"

# context: used/total (pct), warming yellow then red as the window fills
if [ "${ctx_size:-0}" -gt 0 ] 2>/dev/null; then
  [ "${ctx_pct:--1}" -lt 0 ] 2>/dev/null && ctx_pct=$(( ctx_used * 100 / ctx_size ))
  if   [ "$ctx_pct" -ge 90 ]; then ctxc="$RED"
  elif [ "$ctx_pct" -ge 70 ]; then ctxc="$YELLOW"
  else ctxc="$DIM"
  fi
  out="${out}${SEP}${ctxc}$(fmt_k "$ctx_used")/$(fmt_k "$ctx_size") (${ctx_pct}%)${RESET}"
fi
[ -n "$dir" ]    && out="${out}${SEP}${CYAN}$(link "$dir_url" "$dir")${RESET}"
[ -n "$branch" ] && out="${out}${SEP}${GREEN}$(link "$branch_url" "⎇ ${branch}")${RESET}"
[ -z "$branch" ] && [ -n "$sha" ] && out="${out}${SEP}${GREEN}$(link "$branch_url" "⎇ ${sha}")${RESET}"

if [ "$added" -gt 0 ] || [ "$removed" -gt 0 ]; then
  stats="${GREEN}+${added}${RESET} ${RED}-${removed}${RESET}"
  out="${out}${SEP}$(link "$diff_url" "$stats")"
fi

# PR segment: #123, coloured by state, plus review decision
if [ -n "$PR" ]; then
  case "$PR_STATE" in
    MERGED) pc="$PURPLE" ;;
    CLOSED) pc="$RED" ;;
    *)      [ "$PR_DRAFT" = "true" ] && pc="$DIM" || pc="$BLUE" ;;
  esac
  label="#${PR}"
  [ "$PR_DRAFT" = "true" ] && label="${label} draft"
  case "$PR_REVIEW" in
    APPROVED)          label="${label} ✓" ;;
    CHANGES_REQUESTED) label="${label} ✗" ;;
    REVIEW_REQUIRED)   label="${label} ⧗" ;;
  esac
  out="${out}${SEP}${pc}$(link "$PR_URL" "$label")${RESET}"
fi

# CI segment: rollup of checks, linked to the checks tab
if [ -n "$CHECKS" ]; then
  case "$CHECKS" in
    SUCCESS) cc="$GREEN";  ci="●" ;;
    FAILURE) cc="$RED";    ci="✗" ;;
    PENDING) cc="$YELLOW"; ci="◐" ;;
    *)       cc="$DIM";    ci="○" ;;
  esac
  if [ -n "$PR_URL" ]; then checks_url="$PR_URL/checks"
  elif [ -n "$repo_url" ] && [ -n "$sha" ]; then checks_url="$repo_url/commit/$sha/checks"
  else checks_url=""
  fi
  out="${out}${SEP}${cc}$(link "$checks_url" "${ci} ci")${RESET}"
fi

printf '%s' "$out"