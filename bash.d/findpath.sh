# Locate files in $PATH. Usage: findpath "TEXT"
findpath() { locate "$1" | perl -ne 'if(m/^(('$(echo $PATH | perl -pe 's/\:/\|/g; s/(\/)/\\\//g;')').*)$/){print "$1\n"}'; }
