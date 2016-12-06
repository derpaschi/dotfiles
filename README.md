# Paschi's dotfiles

Your dotfiles are how you personalize your system. These are mine. They are basically forked from
[Holman](https://github.com/holman/dotfiles)' great dotfiles. See the description for detailed infos.

## install

Run this:

```sh
git clone git@github.com:hubeRsen/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

Dont forget to set the standard shell to zsh (brew version).

```sh
# put /usr/local/bin/zsh into the shells file, thats the symlinked version of homebrews zsh
$ sudo vim /etc/shells
# change the standard shell
$ chsh -s /usr/local/bin/zsh
```

## thanks

Inspired by the dotfiles of:

[Zach Holman](https://github.com/holman/dotfiles)

[Paul Millr](https://github.com/paulmillr/dotfiles)

[Pascal Birchler](https://github.com/swissspidy/dotfiles)

