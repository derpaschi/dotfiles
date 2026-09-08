# zsh-syntax-highlighting has to be sourced after compinit and after every other
# plugin that defines ZLE widgets. completion.zsh files load last, and zsh/ sorts
# after all other topics, so this is the final thing zshrc sources.
zsh_hl="${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -f "$zsh_hl" ]] && source "$zsh_hl"
unset zsh_hl
