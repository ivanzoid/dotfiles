#!/bin/bash

objectNotExcluded()
{
	object=$1
	array=$2
	case "$array[@]"
		in *"$object"*)
			return 1
	esac
	return 0
}

symlink()
{
	from=$1
	to=$2

	mkdir -p "$to"
	toLastComponent="$(basename $from)"
	fullTo="${to}/${toLastComponent}"
	if [ -d "$fullTo" ]; then
		rm -rf "$fullTo"
	fi
	ln -sf "$from" "$to"
}

is_osx()
{
	if [[ $OSTYPE == darwin* ]]; then
		return 0
	else
		return 1
	fi
}

pushd ~ >/dev/null

if is_osx; then
	symlink "$HOME/dotfiles/Library/Developer/Xcode/UserData/CodeSnippets" "$HOME/Library/Developer/Xcode/UserData"
	symlink "$HOME/dotfiles/Library/Developer/Xcode/UserData/FontAndColorThemes" "$HOME/Library/Developer/Xcode/UserData"
	symlink "$HOME/dotfiles/Library/Developer/Xcode/Templates" "$HOME/Library/Developer/Xcode"
	symlink ~/dotfiles/Library/LaunchAgents/com.ivanzoid.ssh-tunnel.plist ~/Library/LaunchAgents
	symlink ~/dotfiles/Library/LaunchAgents/com.ivanzoid.environment.plist ~/Library/LaunchAgents
fi

mkdir -p ~/.config/mc
symlink ~/dotfiles/mc/ini ~/.config/mc

excludeList=(.git)

for f in dotfiles/.[^.]*; do
	if objectNotExcluded "$(basename $f)" $excludeList ; then
		symlink "$f" ~
	fi
done

popd >/dev/null

