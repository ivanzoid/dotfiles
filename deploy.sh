#!/bin/bash

pushd $HOME >/dev/null

rm -rf Library/Developer/Xcode/UserData/CodeSnippets
mkdir -p Library/Developer/Xcode/UserData
ln -sf dotfiles/Xcode/CodeSnippets Library/Developer/Xcode/UserData

rm -rf Library/Developer/Xcode/UserData/FontAndColorThemes
mkdir -p Library/Developer/Xcode/UserData
ln -sf dotfiles/Xcode/FontAndColorThemes Library/Developer/Xcode/UserData

for f in dotfiles/.[^.]*; do
	ln -sf "$f" .
done

popd >/dev/null

