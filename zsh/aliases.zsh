alias reload!='. ~/.zshrc'
alias cls='clear' # Good 'ol Clear Screen command
alias ssh="assh wrapper ssh --" # assh wrapper
alias ..='cd ..'
alias composer="ssh -T git@github.com > /dev/null 2>&1 ; ssh -T git@bitbucket.org > /dev/null 2>&1 ; `brew --prefix`/bin/composer"
alias l='ls -la'
alias start='composer server:start'
alias stop='composer server:stop'
alias stopremove='composer server:stop --remove --skip-proxy'
alias mysqladmin='/opt/homebrew/opt/mysql/bin/mysqladmin'
alias dockerwp='docker compose run --rm cli wp'

# Alias `server <command>` to `composer server:<command>`.
server() {
	composer server:$@
}

mockup() {
	if [ -n "$1" ]
	then
		cd ~/Development
		ts-mockup-generator --scroll 200 --url https://$@
	else
		echo "Usage: mockup URL"
	fi
}

export COMPOSER_AUTH="`cat ~/.composer/auth.json`"
