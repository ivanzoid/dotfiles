# ~/.zshenv

export LANG='en_US.UTF-8'
export EDITOR="vim"
export VISUAL="$EDITOR"

if [ -x /usr/libexec/java_home ]; then
    export JAVA_HOME=$(/usr/libexec/java_home >/dev/null 2>&1)
fi

export GOPATH="$HOME/go"

if [[ -d $HOME/Library/Android/sdk ]]; then
    export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
    export PATH="$PATH:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools"
fi

if [[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]]; then
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

# Rancher Desktop
if [[ -d "/Users/ivan/.rd/bin" ]]; then
	export PATH="/Users/ivan/.rd/bin:$PATH"
fi


