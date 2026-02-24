# ~/.zprofile

#setopt EMACS

# Autocompletion
#autoload -U compinit && compinit

# Up/down arrows completion
#autoload -Uz history-search-end
#zle -N history-beginning-search-backward-end history-search-end
#zle -N history-beginning-search-forward-end history-search-end
#bindkey "$terminfo[kcuu1]" history-beginning-search-backward-end
#bindkey "$terminfo[kcud1]" history-beginning-search-forward-end


# Go
if [[ -d $HOME/go ]]; then 
	export GOPATH="$HOME/go"
fi

if [[ "$OSTYPE" == "darwin"* ]] && command -v mvim >/dev/null; then
    export EDITOR='mvim -f' VISUAL='mvim -f'
#	alias mvim='vim -g'
else
    export EDITOR='vim' VISUAL='vim'
fi


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

# Java
if [ -x /usr/libexec/java_home ]; then
    export JAVA_HOME=$(/usr/libexec/java_home >/dev/null 2>&1)
fi

# Android SDK
if [[ -d $HOME/Library/Android/sdk ]]; then
    export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
    export PATH="$PATH:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools"
fi

# VS Code
if [[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]]; then
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi


# Rancher desktop
if [[ -d "$HOME/.rd" ]]; then
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="$HOME/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
fi

# Dart comletion
if [[ -d "$HOME/.dart-cli-completion" ]]; then
## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]] && . "$HOME/.dart-cli-completion/zsh-config.zsh" || true
## [/Completion]
fi

# Mise
if command -v mise >/dev/null 2>&1; then
	eval "$(mise activate zsh)"
fi



