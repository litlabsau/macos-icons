#!/bin/zsh --no-rcs

# Iconomator
# V: 0.1.0 beta
#
# Downloads icon files and stores locally
# 2026 - Litlabs
#
# inspired by Installomator & Setup Your Mac


zparseopts -D -E -- i:=icons o:=output l:=log d=debug h=help c=catalog

log_file="${log[2]:-/Library/Management/au.litlabs.iconomator.log}"
items=("${(s:,:)icons[2]}") # Auto split parsed comma list into array, removes empties
icon_size="${5:-1024}"
output_path="${6:-/Library/Management/Icons}"

#
# FUNCTION: Download from Github Page
#
# usage: download_icon <icon> <size> <output_dir>
#        download_icon catalog -> donwloads the icon catalog MD
download_from_ghpage() {
    local gh_page_url="https://litlabsau.github.io/iconomator"
    local filepath="png"
    local icon_name="${1}"
    local size="${2}"
    local output_dir="${3}"
    local url="${gh_page_url}/${filepath}/${icon_name}.png"
    local curl_response

    log_message debug "item:     $icon_name"
    log_message debug "size:     $size"
    log_message debug "output:   $output_dir"
    log_message debug "url:      $url"

    if [[ ${icon_name} == "catalog" ]]; then
        curl -fsSL "${gh_page_url}/ICONS.md"
        return 0
    fi
    curl_response=$(curl -sS  "$url" -o "${output_dir}/${icon_name}.png" -w '%{http_code}')
    log_message debug "curl exit code: $curl_response"
    if [[ ${curl_response} == 200 ]]; then
        log_message info "Downloaded -> ${output_dir}/${item}.png"
    else
        if [[ -f "${output_dir}/${icon_name}.png" ]]; then
            rm -f -- "${output_dir}/${icon_name}.png"
        fi
        log_message error "Failed to download $url"
        log_message warn "Check icon requested is valid" >&2
        return 1
  fi
}

#
# FUNCTION: Help message
#
print_help () {
    cat <<EOF

Usage: Iconomator.sh -i <icon1,icon2,...> [options]

Fetch one or more icons from litlabsau/macos-icons GitHub repo.

Required:
    -i LIST     Comma-separated list of icon names to download (no spaces).
                A single icon:  -i mail
                Multiple icons: -i pages,numbers
Options:
    -o DIR      Output directory        (default: working directory)
    -l FILE     Log file                (default: /var/log/au.litlabs.iconomator.log)
    -s NUM      Icon size in pixels:
                    1024 (default)
                    512
                    256
                    128
                    64
    -d          Enable debug mode       (default: DISABLED)
    -h          Show this help
EOF
}

#
# FUNCTION: Check and create dependency directories
#
create_directory () {
    # Check if exists and create the directory for log file + output path if not
    if [[ -d $1 ]]; then
        log_message debug "Directory exists: $1"
        return 0
    else
       	mkdir -p "${1}"
        chmod 755 "${1}"
    fi
    return 0
}

#
# FUNCTION: Function to write formatted messages to log file.
#
# usage: log_message <level> <message>
log_message() {
  local log_level="$1"; shift
  local message="$*"

  # Visibility gate: debug lines only emit when the flag is set.
  # Other levels (info/warn/error) always pass through.
  if [[ $log_level == debug ]] && (( ! ${#debug} )); then
    return 0
  fi
  # Console output -> stderr
  printf '[%-5s]    %s\n' "${log_level}" "$message"
  # Formatted log file output
  if [[ -n $log_file ]]; then
    # e.g. 2026-06-24 14:03:11 [level] your message
    printf '%s [%-5s]    %s\n' "${(%):-%D{%Y-%m-%d %H:%M:%S}" "${log_level}" "${message}" >> $log_file
  fi
}

# Create required directories
create_directory "${log_file%/*}"
create_directory "${output_path}"

log_message debug "==== Variables ===="
log_message debug "icons:        ${items[@]}"
log_message debug "icon_size:    $icon_size"
log_message debug "output_path:  $output_path"
log_message debug "log:          $log_file"
log_message debug ""



if (( ${#catalog} )); then
    download_from_ghpage "catalog"
    exit 0
else
    if (( ! ${#icons} )) || (( ${#help} )); then
        print_help
        if (( ! ${#help} )); then exit 2; else exit 0; fi # Exit 0 if -h was called.
    else
    fi
fi


log_message info "Processing downloads..."
for item in ${items[@]}; do
    log_message debug "Download icon: ${item}"
    log_message debug "save to: ${output_path}"
    log_message debug "Parsing -> download_icon ${item} ${size} ${output_path}"
    download_from_ghpage "${item}" ${icon_size} "${output_path}"
done
