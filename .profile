#
# .profile
#

if [[ $- != *i* ]] ; then
	# Shell is non-interactive. Be done now!
	return
fi

# Include .bashrc if needed
if [ -n "$BASH_VERSION" ]; then
	if [ -f "$HOME/.bashrc" ]; then
		. "$HOME/.bashrc"
	fi
fi

# Add homebrew/macports
if [ -d /usr/local/bin ]; then
	export PATH=/usr/local/bin:$PATH
fi

if [ -d /usr/local/sbin ]; then
	export PATH=/usr/local/sbin:$PATH
fi

if [ -d $HOME/android-sdk-macosx/tools ]; then
	export PATH=${PATH}:~/android-sdk-macosx/tools
fi

# Add rbenv
if [ -d $HOME/.rbenv/shims ]; then
	export PATH=$HOME/.rbenv/shims:${PATH}
fi

#eval "$(rbenv init -)"


program_exists () {
	type "$1" &> /dev/null ;
}

# Add ~/bin
if [ -d ~/bin ]; then
	export PATH=~/bin:$PATH
fi

export LANG='en_US.UTF-8'

# set editor
if program_exists mvim; then
	export EDITOR="mvim --nofork -f"
elif program_exists gvim; then
	export EDITOR="gvim -f"
elif program_exists vim; then
	export EDITOR="vim -f"
elif program_exists vi; then
	export EDITOR="vi -f"
fi

export VISUAL=$EDITOR
export SVN_EDITOR=$EDITOR

# Bash settings
shopt -s histappend
export HISTSIZE=1000000
export CLICOLOR=1

# Go setup

export GOPATH=$HOME/Go
export PATH="$GOPATH/bin:$PATH"

if program_exists go; then
	function setupGOROOT()
	{
		local GOPATH=`which go`
		local GODIR=`dirname $GOPATH`
		local GOPATH_BREW_RELATIVE=`readlink $GOPATH`
		local GOPATH_BREW=`dirname $GOPATH_BREW_RELATIVE`
		export GOROOT=`cd $GODIR; cd $GOPATH_BREW/..; pwd`
	}
	setupGOROOT
fi

function setPS1()
{
	# Reset
	local ColorOff='\[\e[0m\]'       # Text Reset

	# Regular Colors
	local ColorBlack='\[\e[0;30m\]'        # Black
	local ColorRed='\[\e[0;31m\]'          # Red
	local ColorGreen='\[\e[0;32m\]'        # Green
	local ColorYellow='\[\e[0;33m\]'       # Yellow
	local ColorBlue='\[\e[0;34m\]'         # Blue
	local ColorPurple='\[\e[0;35m\]'       # Purple
	local ColorCyan='\[\e[0;36m\]'         # Cyan
	local ColorWhite='\[\e[0;37m\]'        # White

	# Bold
	local ColorBBlack='\[\e[1;30m\]'       # Black
	local ColorBRed='\[\e[1;31m\]'         # Red
	local ColorBGreen='\[\e[1;32m\]'       # Green
	local ColorBYellow='\[\e[1;33m\]'      # Yellow
	local ColorBBlue='\[\e[1;34m\]'        # Blue
	local ColorBPurple='\[\e[1;35m\]'      # Purple
	local ColorBCyan='\[\e[1;36m\]'        # Cyan
	local ColorBWhite='\[\e[1;37m\]'       # White

	# Underline
	local ColorUBlack='\[\e[4;30m\]'       # Black
	local ColorURed='\[\e[4;31m\]'         # Red
	local ColorUGreen='\[\e[4;32m\]'       # Green
	local ColorUYellow='\[\e[4;33m\]'      # Yellow
	local ColorUBlue='\[\e[4;34m\]'        # Blue
	local ColorUPurple='\[\e[4;35m\]'      # Purple
	local ColorUCyan='\[\e[4;36m\]'        # Cyan
	local ColorUWhite='\[\e[4;37m\]'       # White

	# Background
	local ColorBgBlack='\[\e[40m\]'       # Black
	local ColorBgRed='\[\e[41m\]'         # Red
	local ColorBgGreen='\[\e[42m\]'       # Green
	local ColorBgYellow='\[\e[43m\]'      # Yellow
	local ColorBgBlue='\[\e[44m\]'        # Blue
	local ColorBgPurple='\[\e[45m\]'      # Purple
	local ColorBgCyan='\[\e[46m\]'        # Cyan
	local ColorBgWhite='\[\e[47m\]'       # White

	# High Intensty
	local ColorIBlack='\[\e[0;90m\]'       # Black
	local ColorIRed='\[\e[0;91m\]'         # Red
	local ColorIGreen='\[\e[0;92m\]'       # Green
	local ColorIYellow='\[\e[0;93m\]'      # Yellow
	local ColorIBlue='\[\e[0;94m\]'        # Blue
	local ColorIPurple='\[\e[0;95m\]'      # Purple
	local ColorICyan='\[\e[0;96m\]'        # Cyan
	local ColorIWhite='\[\e[0;97m\]'       # White

	# Bold High Intensty
	local ColorBIBlack='\[\e[1;90m\]'      # Black
	local ColorBIRed='\[\e[1;91m\]'        # Red
	local ColorBIGreen='\[\e[1;92m\]'      # Green
	local ColorBIYellow='\[\e[1;93m\]'     # Yellow
	local ColorBIBlue='\[\e[1;94m\]'       # Blue
	local ColorBIPurple='\[\e[1;95m\]'     # Purple
	local ColorBICyan='\[\e[1;96m\]'       # Cyan
	local ColorBIWhite='\[\e[1;97m\]'      # White

	# High Intensty backgrounds
	local ColorBgIBlack='\[\e[0;100m\]'   # Black
	local ColorBgIRed='\[\e[0;101m\]'     # Red
	local ColorBgIGreen='\[\e[0;102m\]'   # Green
	local ColorBgIYellow='\[\e[0;103m\]'  # Yellow
	local ColorBgIBlue='\[\e[0;104m\]'    # Blue
	local ColorBgIPurple='\[\e[10;95m\]'  # Purple
	local ColorBgICyan='\[\e[0;106m\]'    # Cyan
	local ColorBgIWhite='\[\e[0;107m\]'   # White

	#export PS1="\n\[\e[36;1m\]\\u@\h \[\e[32;1m\]\W \[\e[35;1m\]$\[\e[0m\] "
	#export PS1="\n\[\e[36;1m\]\\u@\h \[\e[32;1m\]\w\n\[\e[35;1m\]$\[\e[0m\] "
	#export PS1="\n\u@\h: $Green\w $Cyan\d \t\n$Purple>>$Color_Off "
	#PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
	#PS1='\[\033[01;32m\]\u\[\033[01;34m\] \w \$\[\033[00m\] '

	#export PS1="\n${ColorBGreen}\u@\H${ColorBBlue} \w ${ColorBPurple}\$${ColorOff} "
	export PS1="\n${ColorBRed}\h${ColorBBlue} \w \$${ColorOff} "

	if [[ "$HOSTNAME" == *zoid.cc* ]]; then
		export PS1="\n${ColorBRed}\u@\H \w \$${ColorOff} "
	fi
}

setPS1

# Aliases
alias ls='ls -hF'

alias св=cd
alias ды=ls

alias phpa='php ~/bin/phpa-norl'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

#alias svn="$HOME/bin/svn-color.py"

. "$HOME/bin/svn-color.sh"

#alias svn=colorsvn

if [[ $OSTYPE == darwin* ]];
then
	alias .ap="cd '/Users/ivan/Library/Application Support/iPhone Simulator'"
	alias .ap51="cd '/Users/ivan/Library/Application Support/iPhone Simulator/5.1/Applications'"
	alias .ap60="cd '/Users/ivan/Library/Application Support/iPhone Simulator/6.6/Applications'"

	alias ramdisk='diskutil erasevolume HFS+ "Ramdisk" `hdiutil attach -nomount ram://4000000`'

	alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
fi

alias tunnel='ssh -C2qTnN -D 8080 ivan@zoid.cc'

if program_exists rmtrash; then
	alias rm=rmtrash
fi

MC_WRAPPER="$HOME/bin/mc-wrapper.sh"
if [ -x $MC_WRAPPER ]; then
    alias mc=". $MC_WRAPPER" 
fi
unset MC_WRAPPER

if program_exists convert; then
	image_add_shadow()
	{
		convert %@ \( +clone  -background black  -shadow 80x3+0+2 \) +swap -background none -layers merge +repage shadowed-%@
	}
fi

if program_exists gm; then
	deretinize()
	{
		for f in $@; do
			if [[ $f == *@2x* ]]; then
				fout=${f/@2x/}
				echo "Converting $f to $fout ..."
				gm convert -resize 50%x50% "$f" "$fout"
			fi
		done
	}
fi

if program_exists ffmpeg && program_exists metaflac; then
	flac2alac()
	{
		in=$1
		out=${in/.flac/.m4a}
		album_artist=$(metaflac --show-tag='ALBUM ARTIST' "$in" | sed 's/ALBUM ARTIST=//g')
		echo "Converting $in to $out ..."
		ffmpeg -y -i "$in" -acodec alac -metadata album_artist="$album_artist" "$out"
	}

	alias flac2alac_all="for f in *.flac; do flac2alac \"\$f\"; done"
fi

# install: shntool ffmpeg flac cueprint
if program_exists shnsplit && program_exists cuetag && program_exists ffmpeg && program_exists metaflac; then
	ape_cue2alac()
	{
		echo "Converting ape+cue to flac files ..."
		shnsplit -f *.cue -o flac -t '%n %t' *.ape

		echo "Tagging files ..."
		cuetag *.cue *.flac

		echo "Converting to ALAC ..."
		flac2alac_all

		echo "Removing temporary files ..."
		rm *.flac
	}

	flac_cue2alac()
	{
		mkdir -p out
		cd out

		echo "Converting flac+cue to flac files ..."
		shnsplit -f ../*.cue -o flac -t '%n %t' ../*.flac

		echo "Tagging files ..."
		cuetag ../*.cue *.flac

		echo "Converting to ALAC ..."
		flac2alac_all

		echo "Removing temporary files ..."
		rm *.flac
	}

	wv_cue2alac()
	{
		echo "Converting ape+cue to flac files ..."
		shnsplit -f *.cue -o flac -t '%n %t' *.wv

		echo "Tagging files ..."
		cuetag *.cue *.flac

		echo "Converting to ALAC ..."
		flac2alac_all

		echo "Removing temporary files ..."
		rm *.flac
	}
fi

#if [ -x "`which fortune`" ]; then
#    fortune
#fi

if program_exists brew; then
	BREW_PREFIX=`brew --prefix`
	if [ -f $BREW_PREFIX/etc/bash_completion ]; then
		. $BREW_PREFIX/etc/bash_completion
	fi
	if [ -f $BREW_PREFIX/Library/Contributions/brew_bash_completion.sh ]; then
		. $BREW_PREFIX/Library/Contributions/brew_bash_completion.sh
	fi
fi

