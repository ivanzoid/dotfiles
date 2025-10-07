# ~/.zprofile

[[ -d /usr/local/bin ]] && path=("/usr/local/bin" $path)
[[ -d /usr/local/sbin ]] && path=("/usr/local/sbin" $path)

[[ -d ~/bin ]] && path=("$HOME/bin" $path)
[[ -d ~/private/bin ]] && path=("$HOME/private/bin" $path)

[[ -d $GOPATH/bin ]] && path=("$GOPATH/bin" $path)
[[ -d /usr/local/opt/go/libexec/bin ]] && path+=("/usr/local/opt/go/libexec/bin")
[[ -d /usr/local/opt/dart/libexec/bin ]] && path+=("/usr/local/opt/dart/libexec/bin")

[[ -d "$HOME/.fastlane/bin" ]] && path+=("$HOME/.fastlane/bin")
[[ -d "$HOME/.spicetify" ]] && path+=("$HOME/.spicetify")
[[ -d "$HOME/fvm/default/bin" ]] && path+=("$HOME/fvm/default/bin")
[[ -d "$HOME/.local/bin" ]] && path+=("$HOME/.local/bin")

if (( $+commands[nodenv] )); then
    eval "$(nodenv init - zsh)"
fi

[[ -f "$HOME/.jetbrains.vmoptions.sh" ]] && source "$HOME/.jetbrains.vmoptions.sh"

if [[ "$OSTYPE" == darwin* ]] && [[ ! -f "$HOME/.launchd.conf" ]] && (( $+commands[update-launchd-conf] )); then
    update-launchd-conf
fi
