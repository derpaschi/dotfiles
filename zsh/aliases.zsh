alias reload!='. ~/.zshrc'
alias cls='clear' # Good 'ol Clear Screen command
alias ssh="assh wrapper ssh --" # assh wrapper
alias ..='cd ..'
alias composer="ssh -T git@github.com > /dev/null 2>&1 ; ssh -T git@bitbucket.org > /dev/null 2>&1 ; `brew --prefix`/bin/composer"
alias l='exa --long --header --git'

mockup() {
	if [ -n "$1" ]
	then
		cd ~/Development
		ts-mockup-generator --scroll 200 --url https://$@
	else
		echo "Usage: mockup URL"
	fi
}

freshjobs () {
	pushd /Users/paschi/Development/amazee.io/freshjobs.ch > /dev/null 2>&1
	make $@
	popd > /dev/null 2>&1
}

export COMPOSER_AUTH="`cat ~/.composer/auth.json`"
