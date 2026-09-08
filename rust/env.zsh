# Rust toolchain (rustup/cargo). rustup's installer appends this to ~/.zshenv,
# which is not managed here, so source it from the dotfiles as well. The script
# is idempotent: it only prepends ~/.cargo/bin when it is not already on $PATH.
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
