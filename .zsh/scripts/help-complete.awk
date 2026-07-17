# help-complete.awk — extract option flags (+ best-effort descriptions) from --help output.
# Handles GNU/cobra/clap ("-x, --long ARG   desc"), Go flag ("  -name type\n\tdesc" /
# "  -v\tdesc"), and BSD usage synopsis ("usage: cmd [-abc] [--long]").
# Emits one line per unique flag:  FLAG \t DESC

function trim(s){ sub(/^[ \t]+/,"",s); sub(/[ \t]+$/,"",s); return s }

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

  # ---- pass C: structured option list (GNU / cobra / clap / Go) ----
  match(line,/^[ \t]*/); indent=RLENGTH; body=substr(line,indent+1)
  if (body=="") { pendc=0; next }

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
        if (t ~ /^--?[A-Za-z0-9?]/ && length(t)>=2){
          if(!(t in flags)) flags[t]=1
          cur[++curc]=t
          if(desc!="" && (!(t in descOf) || descOf[t]=="")) descOf[t]=desc
        }
      } else break                          # first non-flag token = ARG/type -> stop
    }
    if (curc>0 && desc==""){                 # Go style: desc on following indented line
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
}
