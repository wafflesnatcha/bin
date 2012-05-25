# locate_path TEXT
# Locate files in the system $PATH.
locate_path() { locate "$1" | perl -ne 'if(m/^(('$(echo $PATH | perl -pe 's/\:/\|/g; s/(\/)/\\\//g;')').*)$/){print "$1\n"}'; }
