#!/usr/bin/env bash

snapshots_url="http://commondatastorage.googleapis.com/chromium-browser-continuous/Mac"
snapshots_url_latest="${snapshots_url}/LAST_CHANGE"
download_dir="$TMPDIR/chromedownload"
install_dir="/Applications"
bundle_identifier="org.chromium.Chromium"

[[ -e "$download_dir" ]] && rm -rf "$download_dir";

echo -n "checking for existing installation... "
app_path=$(/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -dump | grep -A 4 "^bundle" | grep -B 4 "$bundle_identifier" | grep -o "/.*\.app" | head -n1)

if [[ $? = 0 && -e "$app_path" ]]; then
	echo "$app_path"
	install_dir="$(dirname "$app_path")"
	echo -n "getting installed revision... "
	current_version=$(osascript -e "tell application \"System Events\" to tell property list file \"${app_path}/Contents/Info.plist\" to return |SCMRevision| of (value of contents as record)" 2>/dev/null)
	[[ $? > 0 ]] && { echo "?"; current_version=0; } || echo "$current_version"
else
	echo "not found"
fi

echo -n "finding latest revision... "
latest_version=$(curl -qsSL -m10 --connect-timeout 15 "$snapshots_url_latest")
echo "$latest_version"

[[ $current_version -ge $latest_version ]] && { echo "no update necessary"; exit 0; }

echo "downloading... "
mkdir "$download_dir"
curl -qSL# --connect-timeout 15 "$snapshots_url/$latest_version/chrome-mac.zip" -o "$download_dir/chrome-mac.zip"

echo "unzipping... "
unzip -qq "$download_dir/chrome-mac.zip" -d "$download_dir"


echo "moving old copy to trash... "
[[ -e "$install_dir/Chromium.app" ]] && { mv "$install_dir/Chromium.app" ~/.Trash/Chromium-$(date +%Y-%m-%d_%H-%M-%s).app/ || exit 2; }

echo "installing into [${install_dir}]... "
cp -R "$download_dir/chrome-mac/Chromium.app" "$install_dir" || exit 2

echo "cleaning up... "
[[ -e "$download_dir" ]] && rm -rf "$download_dir";
echo "done"
