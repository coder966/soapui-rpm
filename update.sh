#!/bin/sh

currentVersion="$(cat soapui.spec | grep Version: | awk '{print $2}')"
currentBuildId="$(cat soapui.spec | grep '%global build_id' | awk '{print $3}')"

apiResponse="$(curl -s 'https://api.github.com/repos/SmartBear/soapui/releases/latest')"
latestVersion="$(printf "%s" "${apiResponse}" | jq -r '.tag_name' | sed -e 's/v//g')"
latestBuildId="$latestVersion"

echo "Current version: $currentVersion build: $currentBuildId"
echo "Latest version: $latestVersion build: $latestBuildId"


if [ "$currentBuildId" != "$latestBuildId" ]; then
	DATE="$(date "+%a %b %d %Y")"
	USER="RPM Bot <rpm-bot@coder966.net>"


	sed -i "s/^Version: .*/Version:       ${latestVersion}/" soapui.spec
	sed -i "s/^%global *build_id .*/%global build_id ${latestBuildId}/" soapui.spec
	sed -i "s/^%changelog/%changelog\n\* ${DATE} ${USER} - ${latestVersion}\n- Update to ${latestVersion}\n/" soapui.spec


	git commit soapui.spec -m "Update to ${latestVersion}"
	git push
fi
