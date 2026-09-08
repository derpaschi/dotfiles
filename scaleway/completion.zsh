# Scaleway CLI completions. Uses compdef, so it has to run after compinit.
if (( $+commands[scw] )); then
  eval "$(scw autocomplete script shell=zsh)"
fi
