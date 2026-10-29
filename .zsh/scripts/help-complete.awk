# help-complete.awk — extract option flags and subcommands (+ best-effort descriptions)
# from --help output. Handles GNU/cobra/clap ("-x, --long ARG   desc"), Go flag
# ("  -name type\n\tdesc" / "  -v\tdesc"), BSD usage synopsis ("usage: cmd [-abc] [--long]"),
# and prose-style help where the only structure is synopsis lines ("cmd [<n>] up [--fe <ref>]").
# Subcommands come from synopsis lines that start with the command name (pass `-v cmd=NAME`)
# and from a "Commands:" / "Subcommands:" section.
# Emits one line per unique entry:  FLAG \t DESC   (flags start with '-')
#                                   NAME \t DESC   (subcommands do not)

function trim(s){ sub(/^[ \t]+/,"",s); sub(/[ \t]+$/,"",s); return s }

# Synopsis subcommand: "<cmd> [<n>] up [--be <ref>] ..." -> "up". Skips [...] groups and
# <placeholders> after the command name; the first bare lower-case word wins, a flag or
# an upper-case placeholder (COMMAND, FILE) means there is none.
function synopsis_sub(body, usage,   t, nt, k, depth, w, rest, d) {
  if (cmd=="" || body !~ ("^" cmd "([ \t]|$)")) return ""
  rest=substr(body,length(cmd)+1)
  d=""
  if (match(rest,/\t| {2,}/)) { d=trim(substr(rest,RSTART+RLENGTH)); rest=substr(rest,1,RSTART-1) }
  sub(/^[ \t]*(->|:|--)?[ \t]*/,"",d)           # "-> reserve a slot" -> "reserve a slot"
  # A sentence that merely starts with the command name ("rsync is a file transfer
  # program") is not a synopsis: require a usage: prefix or [...]/<...> placeholders.
  if (!usage && rest !~ /[\[<]/) return ""
  nt=split(trim(rest),t,/[ \t]+/); depth=0
  for(k=1;k<=nt;k++){ w=t[k]
    depth+=gsub(/\[/,"[",w)-gsub(/\]/,"]",w)
    if (depth>0 || w ~ /^\[/ || w ~ /^</) continue
    if (w ~ /^[a-z][a-z0-9_-]*$/) { subDesc=d; return w }
    return ""
  }
  return ""
}

BEGIN{ inCmds=0 }

{
  line=$0; sub(/\r$/,"",line)

  # ---- pass A: long options anywhere (--foo) — usually real even inside prose ----
  s=line
  while (match(s,/--[A-Za-z0-9][A-Za-z0-9-]*/)){
    lt=substr(s,RSTART,RLENGTH); s=substr(s,RSTART+RLENGTH)
    if(!(lt in flags)) sflags[lt]=1
  }

  # ---- pass B: bracket clusters from usage synopsis:  [-abc]  [--long]  ----
  s=line
  while (match(s,/\[-[A-Za-z0-9?@#%+]/)){
    rest=substr(s,RSTART+1); s=substr(s,RSTART+RLENGTH)   # rest starts at '-'
    if (rest ~ /^--/){
      inner=rest; sub(/[]= ].*$/,"",inner)
      if(inner ~ /^--[A-Za-z0-9]/ && !(inner in flags)) sflags[inner]=1
    } else {
      cl=substr(rest,2)                                   # chars after the dash
      m=length(cl)
      for(k=1;k<=m;k++){ c=substr(cl,k,1)
        if(c ~ /[A-Za-z0-9@]/){ sf="-" c; if(!(sf in flags)) sflags[sf]=1 }
        else break }
    }
  }

  match(line,/^[ \t]*/); indent=RLENGTH; body=substr(line,indent+1)
  if (body=="") { pendc=0; inCmds=0; next }

  # ---- pass D: subcommands from synopsis lines ("usage: cmd ..." / "  cmd [<n>] up ...") ----
  s=body; usage=sub(/^[Uu]sage:[ \t]*/,"",s)
  w=synopsis_sub(s, usage)
  if (w!="") { if(!(w in subs)) subs[w]=1; if(subDesc!="" && subsDesc[w]=="") subsDesc[w]=subDesc }

  # ---- pass E: "Commands:" / "Subcommands:" section:  "  name[, alias]   desc" ----
  h=tolower(trim(body)); sub(/:$/,"",h)
  if (h ~ /^(available |sub-?)?commands$/ && indent<4) { inCmds=1; cmdsIndent=indent; next }
  if (inCmds) {
    if (indent<=cmdsIndent) inCmds=0              # back at header level: section over
    else if (match(body,/\t| {2,}/)) {
      names=substr(body,1,RSTART-1); d=trim(substr(body,RSTART+RLENGTH))
      nn=split(names,nm,/[ \t]*,[ \t]*/)
      for(k=1;k<=nn;k++){ w=nm[k]
        if (w ~ /^[a-z][a-z0-9_-]*$/) { if(!(w in subs)) subs[w]=1; if(d!="" && subsDesc[w]=="") subsDesc[w]=d }
        else break                              # "name ARG desc"? only the first word
      }
    }
  }

  # ---- pass C: structured option list (GNU / cobra / clap / Go) ----

  if (body ~ /^--?[A-Za-z0-9?]/){          # short (-x) or long-only (--xyz) option line
    desc=""; flagpart=body
    if (match(body,/\t| {2,}/)){                   # tab or 2+ spaces separate flags/desc
      flagpart=substr(body,1,RSTART-1)
      desc=trim(substr(body,RSTART+RLENGTH))
    }
    delete cur; curc=0
    n=split(flagpart,tok,/[ \t,\/|]+/)   # split on space, tab, comma, slash, pipe
    for(i=1;i<=n;i++){ t=tok[i]
      if (t ~ /^--?[A-Za-z0-9?]/){
        sub(/[=\[<].*$/,"",t)               # drop =ARG [=ARG] <ARG>
        gsub(/[^A-Za-z0-9?_-]+$/,"",t)      # drop trailing punctuation
        if (t ~ /^--?[A-Za-z0-9?]/ && length(t)>=2) cur[++curc]=t
      } else break                          # first non-flag token = ARG/type -> stop
    }
    # Prose guard: an option entry carries at most an ARG/type or two after its
    # flags before the (tab / 2+ space) description gap. A line such as
    # "--fe likewise in <FE_ROOT>-<name>; ..." is a sentence that happens to start
    # with a flag; counting it as an entry would make pass C "win" and discard the
    # synopsis flags of a prose-style help. Pass A still records its long options.
    # Option lists are indented, though, and an overlong name can leave only one
    # space before its description ("      --exclude-caches-under exclude everything
    # under directories containing"), so an indented line is prose only when a
    # whole sentence follows the flag.
    if (desc=="" && n-i+1 > 2 && (indent==0 || n-i+1 >= 8)) { pendc=0; next }
    for(k=1;k<=curc;k++){ t=cur[k]
      if(!(t in flags)) flags[t]=1
      if(desc!="" && (!(t in descOf) || descOf[t]=="")) descOf[t]=desc
    }
    if (curc>0 && desc==""){                # Go style: desc on following indented line
      pendc=curc; pendIndent=indent
      for(i=1;i<=curc;i++) pend[i]=cur[i]
    } else pendc=0
    next
  }

  if (pendc>0 && indent>pendIndent){         # continuation desc for pending Go option
    d=trim(body)
    if(d!="") for(j=1;j<=pendc;j++) if(!(pend[j] in descOf)||descOf[pend[j]]=="") descOf[pend[j]]=d
    pendc=0; next
  }
  pendc=0
}
END{
  nf=0
  for(f in flags){ print f "\t" descOf[f]; nf++ }
  # Synopsis scraping (passes A/B) is noisy: it can lift flags out of prose,
  # e.g. a description reading "default: <name>[-N]" yields a bogus -N. Trust it
  # only when there is NO structured option list — i.e. a tool (typically BSD)
  # that prints just a "usage: cmd [-abc]" synopsis and nothing else.
  if(nf==0) for(f in sflags) print f "\t"
  for(w in subs) print w "\t" subsDesc[w]
}
