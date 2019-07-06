alias reload!='. ~/.zshrc'
alias cls='clear' # Good 'ol Clear Screen command
alias ssh='assh wrapper ssh' # assh wrapper
alias ..='cd ..'
alias wearerequiredup='cd ~/Development/wearerequired.local/_vagrant && vagrant up'
alias compupstage='composer update && git add composer.json composer.lock && git commit -m "Composer update" && git push && bundle exec cap staging deploy'
alias composer='ssh -T git@github.com > /dev/null 2>&1 ; ssh -T git@bitbucket.org > /dev/null 2>&1 ; /usr/local/bin/composer'

atlantis() {
    pushd ~/.appflow/playbooks >/dev/null 2>&1
    vagrant $@ atlantis
    popd >/dev/null 2>&1
}

export COMPOSER_AUTH="`cat ~/.composer/auth.json`"