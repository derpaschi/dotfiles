#!/bin/bash
#
# Claude Code
#
# Links the Claude Code user config from this topic into ~/.claude/. Runs on
# every `dot`, so it has to be safe to re-run:
#
#   missing, dangling or wrong symlink   -> (re)create the link
#   regular file identical to the repo   -> replace it with the link
#   regular file that differs            -> leave it alone, print what to do
#
# GSD and Claude Code rewrite settings.json atomically (temp file + rename),
# which turns the symlink back into a regular file. The live file is then the
# newer one: adopt it into the repo, review `git diff`, re-link.

set -u

CLAUDE_DIR="$HOME/.claude"

# Absolute path. script/install runs us as ./claude/install.sh, and a relative
# link target would dangle from inside ~/.claude/.
TOPIC_DIR="$(cd "$(dirname "$0")" && pwd -P)"

FILES="settings.json CLAUDE.md"

mkdir -p "$CLAUDE_DIR"

for name in $FILES; do
  src="$TOPIC_DIR/$name"
  dst="$CLAUDE_DIR/$name"

  if [ ! -f "$src" ]; then
    echo "  [claude] missing in dotfiles, skipping: $src"
    continue
  fi

  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$src" ]; then
      continue
    fi
    echo "  [claude] fixing symlink $dst -> $src"
    ln -sfn "$src" "$dst"
  elif [ -e "$dst" ]; then
    if cmp -s "$src" "$dst"; then
      echo "  [claude] $dst matches the dotfiles copy, replacing it with a symlink"
      ln -sfn "$src" "$dst"
    else
      echo "  [claude] WARNING: $dst is a regular file and differs from the dotfiles copy."
      echo "           Leaving it untouched. Review the diff, adopt the live file, re-link:"
      echo "             diff \"$src\" \"$dst\""
      echo "             cp \"$dst\" \"$src\" && ln -sfn \"$src\" \"$dst\""
    fi
  else
    echo "  [claude] linking $dst -> $src"
    ln -sfn "$src" "$dst"
  fi
done
