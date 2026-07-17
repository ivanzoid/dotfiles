# help-complete.zsh — dynamic zsh completions parsed from a command's --help output.
#
# Bound to the -default- context, so it is a *fallback only*: any command that
# already has a real compsys/plugin completion (git, docker, your zsh-completions,
# builtins, ...) still uses that. This only kicks in for commands zsh knows nothing
# about. On first Tab it runs `<cmd> --help` (then -h, then help), scrapes the flags
# with help-complete.awk, and caches the result; later Tabs are served from cache.
# The --help run is sandboxed (no network + read-only filesystem) and hard-killed
# after 2s, so a speculative run can't phone home, write files, or hang.
#
# Config (set before sourcing, or anytime for the runtime ones):
#   ZSH_HELP_COMPLETE=0            disable entirely
#   ZSH_HELP_COMPLETE_CACHE=DIR    cache dir (default ~/.cache/zsh-help-complete)
#   ZSH_HELP_COMPLETE_TTL=SECONDS  re-run --help after this if binary mtime unknown (default 7d)
#   ZSH_HELP_COMPLETE_TIMEOUT=N    per-command hard-kill (SIGKILL) timeout secs (default 2)
#   ZSH_HELP_COMPLETE_DENY=(a b)   never run --help for these command names
#   ZSH_HELP_COMPLETE_SANDBOX=M    sandbox for the --help run (default auto):
#       auto     use bwrap (Linux) / sandbox-exec (macOS) if present, else run unsandboxed
#       require  as auto, but skip the command entirely if no sandbox is available
#       off      never sandbox
#       "<cmd>"  custom wrapper prefix, e.g. "firejail --net=none --read-only=/"
#     The sandbox blocks network and mounts the whole filesystem read-only, so a
#     speculative --help can't phone home or write anything.
#
# Opt-in mode instead of global fallback: comment out the `compdef ... -default-`
# line at the bottom and use `compdef _help_complete mytool othertool` per command.

(( ${ZSH_HELP_COMPLETE:-1} )) || return 0

typeset -g  __HC_DIR=${0:A:h}
typeset -g  __HC_AWK=$__HC_DIR/help-complete.awk
typeset -ga ZSH_HELP_COMPLETE_DENY
[[ -r $__HC_AWK ]] || return 0

__hc_mtime() {                          # print mtime of $1, or 0
  local -a st
  zmodload -F zsh/stat b:zstat 2>/dev/null
  if zstat -A st +mtime -- "$1" 2>/dev/null; then print -r -- $st[1]; else print 0; fi
}

# Timeout tool detected once at source time.
typeset -g __HC_TIMEOUT=''
if   (( $+commands[timeout]  )); then __HC_TIMEOUT=timeout
elif (( $+commands[gtimeout] )); then __HC_TIMEOUT=gtimeout
fi

# Sandbox prefix detected once at source time (no network + read-only filesystem).
# __HC_SANDBOX_OK stays 1 unless mode=require and nothing suitable was found.
typeset -ga __HC_SANDBOX=()
typeset -g  __HC_SANDBOX_OK=1
() {
  local mode=${ZSH_HELP_COMPLETE_SANDBOX:-auto}
  case $mode in
    off) return ;;
    auto|require) ;;
    *) __HC_SANDBOX=( ${=mode} ); return ;;         # custom wrapper prefix
  esac
  if (( $+commands[bwrap] )); then                  # Linux: bubblewrap, unprivileged
    # Whole FS read-only (incl. /tmp, so /tmp commands can still be completed),
    # no network, isolated PID/IPC. No writable mount: --help must not write.
    __HC_SANDBOX=( bwrap --ro-bind / / --dev /dev --proc /proc
                   --unshare-net --unshare-pid --unshare-ipc --die-with-parent -- )
  elif (( $+commands[sandbox-exec] )); then         # macOS: deny network + all writes
    __HC_SANDBOX=( sandbox-exec -p '(version 1)(allow default)(deny network*)(deny file-write*)' )
  elif [[ $mode == require ]]; then
    __HC_SANDBOX_OK=0
  fi
}

__hc_run() {                            # run "$@" sandboxed + hard SIGKILL timeout, stdin </dev/null
  local secs=${ZSH_HELP_COMPLETE_TIMEOUT:-2}
  local -a inner=( $__HC_SANDBOX "$@" )  # sandbox prefix (maybe empty) wraps the command
  if [[ -n $__HC_TIMEOUT ]]; then
    $__HC_TIMEOUT -s KILL "$secs" "${inner[@]}" </dev/null 2>&1
  elif (( $+commands[perl] )); then     # portable: SIGKILL the whole process group at the deadline
    perl -e 'my $t=shift; my $p=fork(); if(!defined $p){exec @ARGV}
             if($p==0){setpgrp(0,0); exec @ARGV or exit 127}
             local $SIG{ALRM}=sub{kill "KILL",-$p}; alarm $t; waitpid($p,0); alarm 0' \
         "$secs" "${inner[@]}" </dev/null 2>&1
  else                                  # last resort: pure-zsh watchdog (direct child only)
    "${inner[@]}" </dev/null 2>&1 &
    local cpid=$!
    ( sleep "$secs"; kill -KILL $cpid 2>/dev/null ) &!
    wait $cpid 2>/dev/null
  fi
}

__hc_generate() {                       # $1=bin -> prints "flag<TAB>desc" lines, or fails
  (( __HC_SANDBOX_OK )) || return 1     # mode=require but no sandbox available
  local bin=$1 out a
  for a in --help -h help; do
    out=$( __hc_run "$bin" $a | head -c 200000 )
    [[ -n $out ]] && break
  done
  [[ -n $out ]] || return 1
  print -r -- "$out" | command awk -f "$__HC_AWK"
}

__hc_load() {                           # $1=array name to fill (value:desc); $2=command name
  local arrname=$1 cmd=$2
  local bin
  if [[ $cmd == */* ]]; then                                  # path form: ./tool, /opt/x/tool
    bin=${cmd:A}                                              # resolve relative to $PWD
    [[ -f $bin && -x $bin ]] || return 1
  else
    bin=${commands[$cmd]}                                     # bare name: resolve via $PATH
    [[ -n $bin ]] || return 1
  fi
  (( ${ZSH_HELP_COMPLETE_DENY[(Ie)$cmd]} || ${ZSH_HELP_COMPLETE_DENY[(Ie)${cmd:t}]} )) && return 1

  local dir=${ZSH_HELP_COMPLETE_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh-help-complete}
  [[ -d $dir ]] || command mkdir -p -- "$dir" 2>/dev/null
  local cache="$dir/${cmd//[^A-Za-z0-9_.-]/_}"

  zmodload zsh/datetime 2>/dev/null
  local now=${EPOCHSECONDS:-0} ttl=${ZSH_HELP_COMPLETE_TTL:-604800}
  local mt=$(__hc_mtime "$bin")
  local awkmt=$(__hc_mtime "$__HC_AWK")                       # bump = parser changed

  local -a lines; local valid=0
  if [[ -r $cache ]]; then
    lines=( "${(@f)$(<$cache)}" )
    if [[ $lines[1] == '#'* ]]; then                         # header: "#<binmtime> <gen_epoch>"
      local -a h=( ${=lines[1]#\#} )
      local gen=${h[2]:-0}
      if (( gen > awkmt )); then                             # cache newer than the parser itself
        if   [[ $mt != 0 && $h[1] == $mt ]]; then valid=1    # binary unchanged
        elif (( now - gen < ttl ));         then valid=1     # or still within TTL
        fi
      fi
    fi
  fi

  if (( ! valid )); then
    local gen; gen=$(__hc_generate "$bin") || return 1
    { print -r -- "#$mt $now"; print -r -- "$gen" } >| "$cache" 2>/dev/null
    lines=( "#$mt $now" "${(@f)gen}" )
  fi

  local -a out; local l flag desc
  for l in "${lines[@]}"; do
    [[ -z $l || $l == '#'* ]] && continue
    flag=${l%%$'\t'*}; desc=${l#*$'\t'}
    [[ $desc == $l ]] && desc=''
    [[ -n $desc ]] && out+=( "${flag}:${desc}" ) || out+=( "$flag" )
  done
  set -A $arrname "${out[@]}"
  return 0
}

_help_complete() {
  # NB: no `emulate -L zsh` here — the completion system already runs with a
  # normalized option set (notably NOMATCH off, which _files relies on).
  local cmd=${words[1]} ret=1
  local -a opts
  if __hc_load opts "$cmd" && (( ${#opts} )); then
    _describe -t options 'option (--help)' opts && ret=0
  fi
  _files && ret=0
  return ret
}

# Global fallback: fires only for commands with no real completion. For opt-in
# instead, replace this with e.g. `compdef _help_complete mytool othertool`.
(( $+functions[compdef] )) && compdef _help_complete -default-
