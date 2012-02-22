#!/usr/bin/env bash

chrome_app="/Applications/Google Chrome.app"
[ ! -e "${chrome_app}" ] && chrome_app="$(find_app "com.google.Chrome")"
chrome_path="${chrome_app}/Contents/MacOS/Google Chrome"
[ ! -e "${chrome_path}" ] && { echo "${0##*/}: can't find Google Chrome.app" >&2; exit 1; }

echo "What should the Application be called (no spaces allowed e.g. GCal)?"
read name

echo "What is the url (e.g. https://www.google.com/calendar/render)?"
read url

echo "What is the full path to the icon (e.g. /Users/username/Desktop/icon.png)?"
read icon


appRoot="/Applications"



# various paths used when creating the app
resourcePath="$appRoot/$name.app/Contents/Resources"
execPath="$appRoot/$name.app/Contents/MacOS" 
profilePath="$appRoot/$name.app/Contents/Profile"
plistPath="$appRoot/$name.app/Contents/Info.plist"

# make the directories
mkdir -p "$resourcePath" "$execPath" "$profilePath"

# convert the icon and copy into Resources
if [ -f "$icon" ] ; then
    sips -s format tiff "$icon" --out "$resourcePath/icon.tiff" --resampleWidth 128 >& /dev/null
    tiff2icns -noLarge "$resourcePath/icon.tiff" >& /dev/null
fi

# create the executable
cat >"$execPath/$name" <<EOF
#!/bin/sh
exec "$chrome_path" --app="$url" --user-data-dir="$profilePath" "\$@"
EOF
chmod +x "$execPath/$name"

# create the Info.plist 
cat > "$plistPath" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" “http://www.apple.com/DTDs/PropertyList-1.0.dtd”>
<plist version=”1.0″>
<dict>
<key>CFBundleExecutable</key>
<string>$name</string>
<key>CFBundleIconFile</key>
<string>icon</string>
</dict>
</plist>
EOF
