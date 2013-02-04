#!/bin/bash

pushd $HOME >/dev/null

rm -rf Library/Developer/Xcode/UserData/CodeSnippets
mkdir -p Library/Developer/Xcode/UserData
ln -s -F dotfiles/Xcode/CodeSnippets Library/Developer/Xcode/UserData

rm -rf Library/Developer/Xcode/UserData/FontAndColorThemes
mkdir -p Library/Developer/Xcode/UserData
ln -s -F dotfiles/Xcode/FontAndColorThemes Library/Developer/Xcode/UserData

for f in dotfiles/.[^.]*; do
	ln -s -f "$f" .
done

popd >/dev/null

