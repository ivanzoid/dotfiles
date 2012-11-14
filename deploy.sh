#!/bin/sh

DOTFILES="$HOME/dotfiles"

rm -rf $HOME/Library/Developer/Xcode/UserData/CodeSnippets
mkdir -p $HOME/Library/Developer/Xcode/UserData
ln -F -s $DOTFILES/Xcode/CodeSnippets $HOME/Library/Developer/Xcode/UserData

rm -rf $HOME/Library/Developer/Xcode/UserData/FontAndColorThemes
mkdir -p $HOME/Library/Developer/Xcode/UserData
ln -F -s $DOTFILES/Xcode/FontAndColorThemes $HOME/Library/Developer/Xcode/UserData

