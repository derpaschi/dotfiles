# Docker Desktop CLI completions. Must be on fpath before compinit runs, which
# is why this is a plain *.zsh file and not completion.zsh.
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)
