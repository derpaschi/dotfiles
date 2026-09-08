export PATH="/usr/local/bin:/usr/local/sbin:$ZSH/bin:$PATH"
export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"

# Antigravity
[[ -d "$HOME/.antigravity/antigravity/bin" ]] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Turso
[[ -d "$HOME/.turso" ]] && export PATH="$PATH:$HOME/.turso"
