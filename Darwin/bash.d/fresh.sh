# Save the command history and open a new tab at the current directory
fresh() { history -w && echo -e "tell application \"System Events\"\nif not UI elements enabled then return\ntell application process \"Terminal\"\nif not frontmost then return 1\nclick menu item \"New Tab\" of menu \"Shell\" of menu bar 1\ntell application \"Terminal\" to do script \"cd '$PWD' && history -c && history -r\" in front window\nend tell\nend tell\nreturn" | osascript; }
# Run `fresh` and exit
freshe() { fresh && exit; }