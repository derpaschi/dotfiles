# Paschi's dotfiles

Your dotfiles are how you personalize your system. These are mine. They are basically forked from
[Holman](https://github.com/holman/dotfiles)' great dotfiles. See the description for detailed infos.

## Fresh Mac Setup

Setting up a **brand-new Mac with nothing installed** (no Git, Homebrew,
1Password, SSH key…)? Follow the full, step-by-step guide:

**👉 [FRESH-MAC-SETUP.md](FRESH-MAC-SETUP.md)**

The short version (assumes you're already signed in to the Mac App Store, which
`mas` requires):

```sh
# Toolchain
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Dotfiles
git clone https://github.com/derpaschi/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap

# Restore identity, secrets & app settings (interactive)
mac-restore
```

Set the default shell to zsh (Homebrew version):

```sh
# Add Homebrew's zsh to allowed shells
# Apple Silicon: /opt/homebrew/bin/zsh
# Intel Mac:     /usr/local/bin/zsh
$ sudo vim /etc/shells
# Change the default shell
$ chsh -s /opt/homebrew/bin/zsh
```

## Switching Between Macs

When leaving a Mac:
```sh
mac-backup
```

When arriving on a Mac:
```sh
mac-sync
```

## Regular Updates

```sh
dot
```

## Commands

Everything in `bin/` is on your `$PATH`, so the scripts below are runnable from
anywhere as bare commands.

### Mac setup & maintenance

| Command | Purpose |
|---------|---------|
| `dot` | Main maintenance command: `git pull` the dotfiles, apply macOS defaults & hostname, install/update Homebrew, run `brew bundle`, and run every topic's `install.sh`. Run it periodically. `dot -e` opens the dotfiles dir in your editor. |
| `mac-snapshot` | Regenerate the `Brewfile` from what's actually installed (`brew bundle dump` — brews, casks, `mas`, editor extensions, npm globals), show the diff, and offer to commit it. `-y` commits without prompting. Keeps the repo a faithful snapshot of the machine. |
| `mac-backup` | Back up GUI app settings to Dropbox via mackup (copy mode). Run **before** leaving a Mac. |
| `mac-sync` | Pull latest dotfiles, install dependencies, then restore app settings via mackup. Run when **arriving** on a Mac. Quits the relevant apps first so they don't overwrite the restored settings. |
| `mac-restore` | Interactive restore assistant for a **fresh** Mac. Walks through Dropbox & 1Password sign-in, GPG key import, `~/.localrc` creation, `mackup restore`, and switching the dotfiles remote to SSH. |
| `gpg-backup` | Export your GPG keys (private, public, ownertrust) to a temp dir and open Finder so you can drag them into 1Password. Files auto-delete after you're done. |
| `set-defaults` | Apply the macOS system defaults (`macos/set-defaults.sh`). Also run automatically by `dot`. |
| `dns-flush` | Flush the macOS DNS cache (`killall -HUP mDNSResponder`). |

### Git helpers

| Command | Purpose |
|---------|---------|
| `branch [name]` | Switch to an existing branch or create a new one, automatically setting up remote tracking if a matching remote branch exists (prefers `origin`). With no argument, lists all local & remote branches. |
| `merge <branch>` | Merge `<branch>` into the current branch. Rebases local-only branches onto the current branch first; refuses to rewrite history for branches that exist remotely. |
| `push [args…]` | `git push` with upstream tracking, then copy a GitHub **compare** URL to your clipboard. Extra args pass through (e.g. `push -f`). |
| `pull` | Pull with `--rebase`, safely stashing/re-applying local changes and updating submodules. Then auto-installs dependencies if the relevant lockfile changed (Bundler, Yarn, npm, Bower, Composer). |
| `git-unpushed` | Show the diff of everything on the current branch not yet pushed to its remote. |
| `git-wtf` | Readable, scannable summary of how a branch relates to its remote and to integration/feature branches. Also available as `git wtf`. |

### Utilities

| Command | Purpose |
|---------|---------|
| `e [path]` | Open a directory (current dir by default) in the editor — currently Cursor. |
| `search <string>` | Quick case-insensitive search in the current directory tree via `ack` / `ack-grep`. |
| `headers <url>` | Show only the HTTP response headers for a URL (curl). |
| `back-me-up` | `rsync` personal folders to network/external storage (paths configured inside the script). |
| `nyan` | Print a little Nyan Cat. 🐱 |

## Thanks

Inspired by the dotfiles of:

[Zach Holman](https://github.com/holman/dotfiles)

[Paul Millr](https://github.com/paulmillr/dotfiles)

[Pascal Birchler](https://github.com/swissspidy/dotfiles)

