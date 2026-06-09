# Fresh Mac Setup — From Zero to Fully Configured

A step-by-step guide for setting up a **brand-new Mac that has nothing on it** —
no iTerm2, no Git, no 1Password, no SSH key, no Homebrew. Everything this
dotfiles repo needs to run gets installed along the way.

Follow the phases in order. The whole thing takes roughly **30–60 minutes**,
most of which is unattended download/install time during `brew bundle`.

---

## What you'll end up with

- Homebrew + all CLI tools, GUI apps and Mac App Store apps from the `Brewfile`
- All dotfiles symlinked into `$HOME` (zsh, git, etc.)
- `zsh` (Homebrew build) as the login shell with the `pure` prompt
- Your GUI app settings restored from Dropbox (via mackup)
- GPG commit signing and an SSH key wired up to GitHub
- macOS system defaults and hostname applied

---

## Phase 0 — Before you wipe / on another device

Some things live **outside** this repo and must be available before you start.
Make sure you can reach them from your phone or another machine:

| You need access to | Why |
|--------------------|-----|
| **1Password account** (email, master password, secret key) | Stores your GPG keys, SSH key, and the secrets that go into `~/.localrc` |
| **GitHub account** | To clone the repo and push over SSH |
| **Dropbox account** | Holds your mackup app-settings backup (`~/Dropbox/Mackup`) |
| **Apple ID** | Required by the Mac App Store for `mas` installs |

> 💡 If this is a migration from an old Mac, run `mac-snapshot` and `mac-backup`
> on the **old** machine first so the `Brewfile` and Dropbox backup are current.
> See `bin/mac-snapshot` and `bin/mac-backup`.

---

## Phase 1 — Bare macOS bootstrap

### 1. Update macOS and sign in to your Apple ID

- System Settings → sign in with your **Apple ID**.
- Open the **App Store** and confirm you're signed in.
  `mas` (used later by `brew bundle`) can only install App Store apps **if you
  are already signed in**, so don't skip this.
- Run any pending **Software Update**.

### 2. Install Xcode Command Line Tools

This gives you `git`, `make`, and the compilers Homebrew needs. Without it you
can't even clone the repo.

```sh
xcode-select --install
```

Accept the GUI prompt and wait for it to finish.

### 3. Install Homebrew

> 💡 The bootstrap (`homebrew/install.sh`) will install Homebrew for you if it's
> missing. Installing it yourself first is still recommended on a fresh machine:
> it lets you verify the install and guarantees `brew` is on your `PATH` before
> anything else runs. The bootstrap detects an existing install and skips this.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then add Homebrew to the **current** shell's PATH (Apple Silicon path shown;
the installer prints the exact command for your machine):

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Verify:

```sh
brew --version
```

---

## Phase 2 — Get the dotfiles

Clone over **HTTPS** — you don't have an SSH key yet. (You'll switch the remote
to SSH later, in Phase 5.)

```sh
git clone https://github.com/derpaschi/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

---

## Phase 3 — Run the bootstrap

```sh
script/bootstrap
```

This single script does a lot. In order, it will:

1. **Ask for a hostname** and set the computer/host/NetBIOS name (needs `sudo`).
2. **Set up your Git identity** — prompts for your Git author name and email,
   then generates `git/gitconfig.local.symlink` from the template.
3. **Symlink all dotfiles** — every `*.symlink` file becomes a `~/.` dotfile
   (e.g. `zsh/zshrc.symlink` → `~/.zshrc`). If a file already exists it asks
   whether to **s**kip / **o**verwrite / **b**ackup.
4. **Run `bin/dot`**, which:
   - applies macOS defaults (`macos/set-defaults.sh`),
   - normalizes the hostname (`macos/set-hostname.sh`),
   - checks Homebrew (already installed in Phase 1, so this is a no-op),
   - runs `brew update && brew upgrade`,
   - runs **`script/install`** → **`brew bundle`** (installs everything in the
     `Brewfile`: 1Password, iTerm2, Dropbox, Cursor, VS Code, GPG, PHP, Node,
     Mac App Store apps, editor extensions, npm globals…), then runs every
     topic's `install.sh` (Mac App Store updates, Claude Code config symlinks,
     the `pure` prompt).

> ⏳ `brew bundle` is the long part — it downloads and installs dozens of apps.
> If a single cask fails (e.g. a network blip), re-run `dot` afterwards; it's
> idempotent.

---

## Phase 4 — Make zsh your login shell

`brew bundle` installed the Homebrew build of `zsh`. Register it and switch to
it:

```sh
# Add Homebrew's zsh to the list of allowed shells
#   Apple Silicon: /opt/homebrew/bin/zsh
#   Intel Mac:     /usr/local/bin/zsh
sudo sh -c 'echo /opt/homebrew/bin/zsh >> /etc/shells'

# Set it as your default shell
chsh -s /opt/homebrew/bin/zsh
```

Open a **new terminal window** (or iTerm2) so the new shell and `pure` prompt
load.

---

## Phase 5 — Restore identity, secrets & app settings

Most of this phase is automated by the **`mac-restore`** assistant, which walks
you through each step interactively:

```sh
mac-restore
```

It guides you through:

1. **Dropbox** — open it, sign in, and wait until `~/Dropbox/Mackup` has fully
   synced.
2. **1Password** — open it and sign in (it was installed by `brew bundle`).
3. **GPG keys** — export your three GPG files from 1Password and import them:
   ```sh
   gpg --import ~/Downloads/gpg-private-keys.asc
   gpg --import ~/Downloads/gpg-public-keys.asc
   gpg --import-ownertrust ~/Downloads/gpg-trust.txt
   ```
   Then delete the exported files. (On the old Mac these were created with
   `gpg-backup`.)
4. **`~/.localrc`** — copies `localrc.example` to `~/.localrc` for your private
   env vars and tokens. Edit it and fill in your secrets.
5. **App settings** — runs `mackup restore` to bring back Cursor / iTerm2 /
   VS Code / TablePlus / Tower / Transmit / etc. preferences from Dropbox.
6. **Dotfiles remote** — offers to switch the `~/.dotfiles` git remote from
   HTTPS to SSH.

### 5a. Verify GPG commit signing ⚠️

This repo sets `commit.gpgsign = true`, so **every commit must be signed** or it
fails. `git/gitconfig.symlink` points `gpg.program` at `/usr/local/bin/gpg` —
the **GPG Suite** path — and GPG Suite is now part of the `Brewfile`, so
`brew bundle` already installed it for you. Once you've imported your keys
(step 3 above), signing should just work.

Verify:

```sh
echo "test" | gpg --clearsign >/dev/null && echo "GPG signing OK"
```

> Prefer Homebrew's `gnupg` (`/opt/homebrew/bin/gpg`) over GPG Suite? Override
> the path locally, without touching the repo:
> ```sh
> git config --file ~/.gitconfig.local gpg.program "$(which gpg)"
> ```

### 5b. Set up your SSH key for GitHub

You started with no SSH key. Two ways to get one:

**Option A — 1Password SSH agent (recommended).** If your SSH key is stored in
1Password: open 1Password → Settings → **Developer** → enable **Use the SSH
agent**, then add to `~/.ssh/config`:

```
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

**Option B — generate a fresh key** and add it to GitHub:

```sh
ssh-keygen -t ed25519 -C "your-email@example.com"
pbcopy < ~/.ssh/id_ed25519.pub   # then paste into GitHub → Settings → SSH keys
```

Test it:

```sh
ssh -T git@github.com
```

> Note: `zshrc` runs `ssh-add --apple-load-keychain` on startup to load keys you
> previously saved to the macOS keychain.

---

## Phase 6 — Verify everything

```sh
# Re-run the maintenance command; it should complete cleanly
dot

# Sanity-check the toolchain
php -v        # PHP 8.3 from Homebrew
node -v       # Node via fnm
git --version

# Confirm a signed commit works (in any repo)
git commit --allow-empty -m "test signing" && git log --show-signature -1
```

Open a fresh terminal — the `pure` prompt, syntax highlighting, aliases and
functions should all be live.

✅ **Done.** From here on, day-to-day maintenance is just `dot`.

---

## Quick reference — the bare-minimum command sequence

For someone who just wants the commands (assuming Apple ID + App Store are
already signed in):

```sh
# 1. Toolchain
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Dotfiles
git clone https://github.com/derpaschi/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap

# 3. Login shell
sudo sh -c 'echo /opt/homebrew/bin/zsh >> /etc/shells'
chsh -s /opt/homebrew/bin/zsh

# 4. Restore identity, secrets & app settings (interactive)
mac-restore

# 5. Verify
dot
```

---

## Known issues & gotchas

1. ~~`homebrew/install.sh` used the removed system Ruby and a deprecated
   installer URL.~~ **Fixed** — it now uses the official Homebrew installer, and
   `dot` loads `brew` onto `PATH` right after a first-time install.
2. ~~The GPG program path mismatch broke commit signing on a fresh Mac.~~
   **Fixed** — `gpg-suite` is now in the `Brewfile`, so the hardcoded
   `/usr/local/bin/gpg` path resolves after `brew bundle`. See Phase 5a.
3. **`mas` needs an App Store sign-in** *before* `brew bundle` runs, or the
   `mas "…"` lines are skipped. Sign in during Phase 1.
4. The `git submodule` steps mentioned in some older notes are a no-op —
   `.gitmodules` is empty, this repo has no submodules.
