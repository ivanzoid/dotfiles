# ~/.zshenv

# Linuxbrew bin for non-interactive logins too (e.g. mosh starting mosh-server
# over ssh), so its HEAD mosh-server wins over the distro one.
[[ -d /home/linuxbrew/.linuxbrew/bin ]] && export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# mosh-server exits after this many seconds without hearing from its client.
# Catches servers orphaned by a Ghostty quit whose tab is never restored (a
# restored tab's `tmux attach -d` already ends its old server); a week keeps a
# sleeping laptop's sessions alive. Read when mosh starts mosh-server over ssh.
export MOSH_SERVER_NETWORK_TMOUT=604800
