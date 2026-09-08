# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_ed25519.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

# Load the SSH keys stored in the macOS keychain into the agent.
if [[ "$OSTYPE" == darwin* ]]; then
  ssh-add -q --apple-load-keychain 2>/dev/null
fi
