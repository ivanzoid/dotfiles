#!/bin/bash -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXCLUDE_LIST=(".git" ".gitignore" "deploy.sh" ".config/hub" "firefox")
# Direct children of these directories are created as real dirs and their
# contents symlinked, instead of the child being symlinked as a whole — even
# on a fresh machine where the destination doesn't exist yet. Use it for
# parents of dirs an app writes into at runtime (e.g. ~/.config/<tool>/), so
# those runtime files don't land in this repo. Everything below the child is
# still symlinked as usual. Paths are relative to the repo root.
MERGE_PARENTS=(".config" "Library/LaunchAgents")
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

# True if $rel is one of the MERGE_PARENTS or a direct child of one.
isMerged()
{
	local rel=$1
	local m
	for m in "${MERGE_PARENTS[@]}"; do
		[[ "$rel" == "$m" || "${rel%/*}" == "$m" ]] && return 0
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

	# Merge a directory (recurse and symlink each entry) instead of
	# symlinking it as a whole when either:
	#   - the destination is already a real directory, so we don't clobber
	#     unrelated entries already there (e.g. ~/.config, ~/Library), or
	#   - it is a MERGE_PARENTS entry or a direct child of one, which forces
	#     per-file linking even on a fresh machine (see MERGE_PARENTS above).
	# In every other case the source is symlinked as a whole.
	if [[ -d "$fromFile" ]] && { [[ -d "$toFile" && ! -L "$toFile" ]] || isMerged "$rel"; }; then
		[[ $DRY_RUN -eq 0 ]] && mkdir -p "$toFile"
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

# Firefox userChrome (macOS only) — symlink firefox/chrome into every profile
# whose dir name contains "default", skipping named profiles like "Mobbiz".
# If a profile already has a real chrome/ dir (not our symlink), move it aside
# first — ln can't replace a non-empty dir, and we never clobber a backup.
if is_osx; then
	ff_root="$HOME/Library/Application Support/Firefox/Profiles"
	if [[ -d "$ff_root" ]]; then
		for prof in "$ff_root"/*default*/; do
			[[ -d "$prof" ]] || continue
			dest="${prof%/}/chrome"
			if [[ -d "$dest" && ! -L "$dest" ]]; then
				bak="$dest.bak"
				n=1
				while [[ -e "$bak" ]]; do bak="$dest.bak.$n"; n=$((n + 1)); done
				echo "backup: $(prettyPath "$dest") -> $(prettyPath "$bak")"
				[[ $DRY_RUN -eq 0 ]] && mv "$dest" "$bak"
			fi
			symlink "$SCRIPT_DIR/firefox/chrome" "${prof%/}"
		done
	fi
fi
