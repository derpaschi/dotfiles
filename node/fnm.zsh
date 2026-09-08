# Node via fnm (Fast Node Manager). --use-on-cd switches the version when a
# directory contains .node-version or .nvmrc. Global npm binaries of the active
# version are on $PATH through fnm's multishell directory, nothing else needed.
if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd)"
fi
