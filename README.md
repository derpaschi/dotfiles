# Paschi's dotfiles

Your dotfiles are how you personalize your system. These are mine. They are basically forked from
[Holman](https://github.com/holman/dotfiles)' great dotfiles. See the description for detailed infos.

## Install

Run this:

```sh
git clone git@github.com:derpaschi/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git submodule init
git submodule update --recursive --remote
script/bootstrap
```

**Prerequisites:** Sign into the Mac App Store before running `script/bootstrap` (required for `mas` to install App Store apps).

Set the default shell to zsh (Homebrew version):

```sh
# Add Homebrew's zsh to allowed shells
# Apple Silicon: /opt/homebrew/bin/zsh
# Intel Mac:     /usr/local/bin/zsh
$ sudo vim /etc/shells
# Change the default shell
$ chsh -s /opt/homebrew/bin/zsh
```

Copy the localrc template for local/private environment variables:
```sh
cp ~/.dotfiles/localrc.example ~/.localrc
```

## Thanks

Inspired by the dotfiles of:

[Zach Holman](https://github.com/holman/dotfiles)

[Paul Millr](https://github.com/paulmillr/dotfiles)

[Pascal Birchler](https://github.com/swissspidy/dotfiles)

