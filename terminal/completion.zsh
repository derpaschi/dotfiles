# iTerm2 shell integration. Deliberately a completion.zsh: it has to load after
# the prompt is set up (zsh/prompt.zsh) so its precmd hook decorates the pure
# prompt instead of being overwritten by it.
if [[ -e "$HOME/.iterm2_shell_integration.zsh" ]]; then
  source "$HOME/.iterm2_shell_integration.zsh"

  iterm2_print_user_vars() {
    iterm2_set_user_var gitBranch $((git branch 2> /dev/null) | grep \* | cut -c3-)
    iterm2_set_user_var phpVersion $(php -v | awk '/^PHP/ { print $2 }')
    iterm2_set_user_var nodeVersion $(node -v)
    iterm2_set_user_var macUptime "$(uptime | sed -nE 's/.*up ([0-9]+) days.*/\1 days/p')"
  }
fi
