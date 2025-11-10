# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal macOS dotfiles repository based on Holman's dotfiles architecture. It uses a topic-based organization where each top-level directory represents a "topic" (e.g., `zsh/`, `git/`, `docker/`). The repository manages system configuration, shell settings, and software installation on macOS through symlinks and automated scripts.

## Key Architecture Principles

### Topic-Based Structure
- Each directory is a "topic" containing related configuration files
- Files ending in `.symlink` are automatically symlinked to `$HOME` as dotfiles (e.g., `git/gitconfig.symlink` → `~/.gitconfig`)
- Files named `path.zsh` are loaded first to configure `$PATH`
- Files named `*.zsh` (except `path.zsh` and `completion.zsh`) are auto-loaded by zsh
- Files named `completion.zsh` are loaded last for shell completions
- Files named `install.sh` are executed during installation

### ZSH Configuration Loading Order
The `zsh/zshrc.symlink` file orchestrates all shell configuration:
1. Sources `~/.localrc` if present (for local/private env variables)
2. Loads all `*/path.zsh` files
3. Loads all `*.zsh` files (excluding path.zsh and completion.zsh)
4. Initializes autocompletion
5. Loads all `*/completion.zsh` files

## Installation & Setup

### Initial Setup
```sh
git clone git@github.com:derpaschi/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git submodule init
git submodule update --recursive --remote
script/bootstrap
```

The bootstrap script:
- Prompts for hostname and configures system name
- Creates `git/gitconfig.local.symlink` from template (if missing)
- Symlinks all `*.symlink` files to `$HOME`
- Runs `bin/dot` to install dependencies

### After Initial Setup
Set zsh as default shell:
```sh
# Add homebrew zsh to allowed shells
sudo vim /etc/shells  # add /usr/local/bin/zsh
chsh -s /usr/local/bin/zsh
```

### Regular Updates
```sh
dot
```

The `dot` command:
- Updates dotfiles repository (`git pull`)
- Applies macOS defaults (`macos/set-defaults.sh`)
- Sets hostname (`macos/set-hostname.sh`)
- Installs/updates Homebrew
- Runs `brew bundle` to install/update software from Brewfile
- Executes all `install.sh` scripts

## Important Files & Directories

### Core Scripts
- `script/bootstrap` - Initial setup script
- `script/install` - Runs `brew bundle` and all `install.sh` files
- `bin/dot` - Main update/maintenance command

### Configuration
- `Brewfile` - Homebrew packages and casks to install
- `git/gitconfig.symlink` - Main git configuration
- `git/gitconfig.local.symlink` - Local git config (generated, not tracked)
- `zsh/zshrc.symlink` - Main zsh configuration
- `~/.localrc` - Local environment variables (not tracked, sourced if present)

### Key Aliases & Functions
Defined across various `aliases.zsh` files:
- `reload!` - Reload zsh configuration
- `d` / `d-c` - Docker shortcuts
- `dockerwp` - Run WP-CLI in Docker container
- `server <cmd>` - Execute composer server commands
- `composer` - Wrapper that checks git connectivity first

### Environment Variables
- `$ZSH` - Points to `~/.dotfiles`
- `$COMPOSER_AUTH` - Loaded from `~/.composer/auth.json`
- `WP_I18N_LIB` - WordPress i18n library path

## Development Tools Setup

The environment is configured for:
- **PHP**: PHP 8.3 via Homebrew (in PATH)
- **Node.js**: Managed via `fnm` (Fast Node Manager)
- **Ruby**: Managed via `rbenv`
- **Composer**: Global vendor binaries in PATH
- **Docker**: With completions and Docker Compose
- **Pygmy**: Local development environment tool

## Making Changes

When modifying this dotfiles repository:

1. **Adding new shell configuration**: Create a `.zsh` file in the appropriate topic directory
2. **Adding PATH entries**: Create or modify a `path.zsh` file in the topic directory
3. **Adding shell completions**: Create or modify a `completion.zsh` file in the topic directory
4. **Adding new dotfiles**: Create a `.symlink` file in the appropriate topic directory
5. **Adding new software**: Add to `Brewfile`
6. **Topic-specific setup**: Add an `install.sh` script to the topic directory

After making changes, run `dot` to apply updates system-wide.
