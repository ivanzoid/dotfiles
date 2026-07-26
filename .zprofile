# ~/.zprofile

# Ghostty Cmd+T / Cmd+N remote reconnect. Hammerspoon (ghostty-remote-tabs.lua)
# stages a request file just before opening a native new tab/window; if it is
# fresh (<3s), hand off to ~/bin/ghostty-reconnect *now* — before any heavy init
# below runs — so a new Ghostty surface connects straight out to the same remote
# dir without first paying for a full local login shell. The freshness gate is
# the real guard (only the surface Hammerspoon just opened finds the file fresh);
# the top-level interactive + no-TMUX + no-SSH_TTY checks keep the remote from
# ever tripping it (the file only exists on the Mac anyway). Deliberately does
# NOT test TERM_PROGRAM: Ghostty may set it after .zprofile runs, which would
# silently disable this.
if [[ -o interactive && -z "$TMUX" && -z "$SSH_TTY" ]]; then
	_grf="$HOME/.cache/ghostty-reconnect"
	if [[ -r "$_grf" ]]; then
		read -r _grts < "$_grf"
		if [[ "$_grts" == <-> && $(( $(date +%s) - _grts )) -le 3 ]]; then
			exec "$HOME/bin/ghostty-reconnect" "$_grf"
		fi
	fi
	unset _grf _grts
fi

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
[[ -d "$HOME/flutter/bin" ]] && path=("$HOME/flutter/bin" $path)
[[ -d "$HOME/.local/bin" ]] && path+=("$HOME/.local/bin")

# Node version manager: prefer mise, fall back to nodenv.
# mise lives in ~/.local/bin (added to path above), so $commands sees it here.
if (( $+commands[mise] )); then
    # Put mise shims on PATH so node/npm/npx work in non-interactive shells too
    # (the activate hook in .zshrc only runs in interactive shells).
    [[ -d "$HOME/.local/share/mise/shims" ]] && path=("$HOME/.local/share/mise/shims" $path)
elif (( $+commands[nodenv] )); then
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

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

