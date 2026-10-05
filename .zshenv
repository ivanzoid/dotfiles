# ~/.zshenv

# Linuxbrew bin for non-interactive logins too (e.g. mosh starting mosh-server
# over ssh), so its HEAD mosh-server wins over the distro one.
[[ -d /home/linuxbrew/.linuxbrew/bin ]] && export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
