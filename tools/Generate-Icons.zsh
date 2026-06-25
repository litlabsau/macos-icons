#!/bin/zsh --no-rcs

# Iconomator > Generate-Icons
#
# uses SAP/Icons command line utility to automate icon generation


iconscli="/Applications/Icons.app/Contents/MacOS/icons_cli"
oldIFS=$IFS
IFS=$'\n'
zparseopts -D -E -- i:=input o:=output d=dry_run

appFolder="${input[2]:-/Applications}"
outputPath="${output[2]:-$PWD}"

apps=(`ls ${appFolder}`)


remove_suffix() {
    local file="$1"
    if [[ "$file" != *_install.* ]]; then
        echo "Skipping '$file': no _install suffix found" >&2
        return 1
    fi
    mv -f -- "$file" "${file/_install./.}"
}
if (( $#dry_run )); then
    echo "======================="
    echo "======= DRY RUN ======="
    echo "======================="
    echo "No changes will be processed..."
    sleep 3
fi

for app in ${apps[@]}; do
	iconName=$(echo ${app} | sed -e 's/ //' | tr '[:upper:]' '[:lower:]' | sed -e 's/\.app//')
	appPath="${appFolder}/${app}"
	if (( $#dry_run )); then
	echo "Exporting ${appPath} to ${outputPath}/${iconName}.png"
	else
	    $iconscli -s 1024 -x au -n ${iconName} -i ${appPath} -o ${outputPath}
	    exportedName="${outputPath}/${iconName}_install.png"
		remove_suffix "$exportedName"
	fi
done
IFS=$oldIFS
