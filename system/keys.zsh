# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_ed25519.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

# Load the SSH keys stored in the macOS keychain into the agent, so SSH commit
# signing works before the first ssh connection. Loading takes ~1s, listing is
# instant, so only load when the agent is empty (i.e. once after a reboot).
if [[ "$OSTYPE" == darwin* ]] && ! ssh-add -l &>/dev/null; then
  ssh-add -q --apple-load-keychain 2>/dev/null
fi
