#!/bin/bash -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXCLUDE_LIST=(".git" ".gitignore" "deploy.sh" ".config/hub" "firefox")
DRY_RUN=0

is_osx()
{
	[[ $OSTYPE == darwin* ]]
}

if ! is_osx; then
	EXCLUDE_LIST+=("Library")
fi

for arg in "$@"; do
	case "$arg" in
		--dry-run|-n) DRY_RUN=1 ;;
	esac
done

if [[ $DRY_RUN -ne 0 ]]; then
	echo "DRY RUN — no changes will be made"
fi

isExcluded()
{
	local rel=$1
	local e
	for e in "${EXCLUDE_LIST[@]}"; do
		[[ "$rel" == "$e" ]] && return 0
	done
	return 1
}

prettyPath()
{
	local tilde="~"
	echo "${1/#$HOME/$tilde}"
}

symlink()
{
	local fromFile=$1
	local toDir=$2

	if [[ ! -e "$fromFile" ]]; then
		echo "link: error: source does not exist: $(prettyPath "$fromFile")" >&2
		return 1
	fi

	local toFile="${toDir}/$(basename "$fromFile")"
	echo "link: $(prettyPath "$toFile") -> $(prettyPath "$fromFile")"
	if [[ $DRY_RUN -ne 0 ]]; then
		return
	fi
	ln -sfn "$fromFile" "$toFile"
}

deploy()
{
	local fromFile=$1
	local toDir=$2
	local toFile="${toDir}/$(basename "$fromFile")"

	local rel="${fromFile#$SCRIPT_DIR/}"
	isExcluded "$rel" && return

	if [[ -d "$fromFile" && -d "$toFile" && ! -L "$toFile" ]]; then
		# Both source and destination are real directories — merge by
		# recursing into contents so we don't clobber unrelated entries in
		# the destination (e.g. ~/.config, ~/Library). In every other case
		# the source is symlinked as a whole.
		local sub
		for sub in "$fromFile"/.[^.]* "$fromFile"/*; do
			[[ -e "$sub" ]] || continue
			deploy "$sub" "$toFile"
		done
	else
		symlink "$fromFile" "$toDir"
	fi
}

for f in "$SCRIPT_DIR"/.[^.]* "$SCRIPT_DIR"/*; do
	[[ -e "$f" ]] || continue
	deploy "$f" "$HOME"
done

# Firefox userChrome — symlink firefox/chrome into every profile whose dir
# name contains "default". 
if is_osx; then
	ff_root="$HOME/Library/Application Support/Firefox/Profiles"
else
	ff_root="$HOME/.mozilla/firefox"
fi

if [[ -d "$ff_root" ]]; then
	for prof in "$ff_root"/*default*/; do
		[[ -d "$prof" ]] || continue
		symlink "$SCRIPT_DIR/firefox/chrome" "${prof%/}"
	done
fi
