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

pushd ~ >/dev/null

symlink ~/dotfiles/Xcode/CodeSnippets ~/Library/Developer/Xcode/UserData/
symlink ~/dotfiles/Xcode/FontAndColorThemes ~/Library/Developer/Xcode/UserData/

excludeList=(.git)

for f in dotfiles/.[^.]*; do
	if objectNotExcluded "$(basename $f)" $excludeList ; then
		symlink "$f" ~
	fi
done

popd >/dev/null

