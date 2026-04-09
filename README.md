# Paschi's dotfiles

Your dotfiles are how you personalize your system. These are mine. They are basically forked from
[Holman](https://github.com/holman/dotfiles)' great dotfiles. See the description for detailed infos.

## Fresh Mac Setup

**Prerequisites:** Sign into the Mac App Store before running bootstrap (required for `mas`).

```sh
xcode-select --install
git clone https://github.com/derpaschi/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
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

| Command | Purpose |
|---------|---------|
| `dot` | Update dotfiles, Homebrew, and dependencies |
| `mac-backup` | Backup app settings to Dropbox (before switching devices) |
| `mac-sync` | Pull dotfiles + restore app settings (when switching to this Mac) |
| `mac-restore` | Interactive restore assistant (for fresh Mac setups) |
| `gpg-backup` | Export GPG keys for 1Password backup |

## Thanks

Inspired by the dotfiles of:

[Zach Holman](https://github.com/holman/dotfiles)

[Paul Millr](https://github.com/paulmillr/dotfiles)

[Pascal Birchler](https://github.com/swissspidy/dotfiles)

