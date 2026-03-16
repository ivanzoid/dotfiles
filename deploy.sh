#!/bin/bash -ex

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
	fullTo="${to}/$(basename "$from")"
	rm -rf "$fullTo"
	ln -sf "$from" "$fullTo"
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
	symlink ~/dotfiles/Library/LaunchAgents/com.ivanzoid.ssh-tunnel.plist ~/Library/LaunchAgents
	symlink "$HOME/dotfiles/Library/Application Support/com.mitchellh.ghostty" "$HOME/Library/Application Support"
fi

mkdir -p ~/.config/mc
symlink ~/dotfiles/mc/ini ~/.config/mc

excludeList=(.git .config/hub)

for f in dotfiles/.[^.]*; do
	if objectNotExcluded "$(basename $f)" $excludeList ; then
		symlink "$f" ~
	fi
done

popd >/dev/null

