#!/bin/bash
#
# Claude Code
#
# Sets up Claude Code configuration by symlinking config files
# to ~/.claude/

CLAUDE_DIR="$HOME/.claude"
DOTFILES_CLAUDE_DIR="$(dirname "$0")"

# Create ~/.claude directory if it doesn't exist
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "Creating $CLAUDE_DIR directory"
    mkdir -p "$CLAUDE_DIR"
fi

# Symlink settings.json
if [ -f "$CLAUDE_DIR/settings.json" ] && [ ! -L "$CLAUDE_DIR/settings.json" ]; then
    echo "Backing up existing settings.json"
    mv "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.backup"
fi

if [ ! -L "$CLAUDE_DIR/settings.json" ]; then
    echo "Linking settings.json"
    ln -sf "$DOTFILES_CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json"
fi

# Symlink statusline-command.sh
if [ -f "$CLAUDE_DIR/statusline-command.sh" ] && [ ! -L "$CLAUDE_DIR/statusline-command.sh" ]; then
    echo "Backing up existing statusline-command.sh"
    mv "$CLAUDE_DIR/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh.backup"
fi

if [ ! -L "$CLAUDE_DIR/statusline-command.sh" ]; then
    echo "Linking statusline-command.sh"
    ln -sf "$DOTFILES_CLAUDE_DIR/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"
fi

echo "Claude Code configuration linked successfully"
