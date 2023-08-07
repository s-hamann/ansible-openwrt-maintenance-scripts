#!/bin/sh

set -eu

export EDITOR="${EDITOR:-vi}"
export PAGER="${PAGER:-less}"

if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
    cat - <<EOH
Usage: $0
  Interactively apply config file updates
EOH
  exit
fi

diff="diff -u '%s' '%s'"
pager="${PAGER}"
less_opts="-E"
merge="sdiff --suppress-common-lines --output='%s' '%s' '%s'"
frozen_files=""
if [ -f /etc/config-update.conf ]; then
    . /etc/config-update.conf
fi

if [ "$(basename -- "${pager}")" = less ]; then
    pager="${pager} ${less_opts}"
fi

handle_config_file() {
  local new_file="$1"
  local old_file="${new_file%-opkg}"
  if printf '%s' "${frozen_files}" | grep -q -F -w -e "${old_file}"; then
      # file is frozen, zap the new version
      rm -f -- "${new_file}"
  fi
  local selection=''
  local show_diff=true
  while true; do
    if "${show_diff}"; then
        eval "$(printf "${diff}" "${old_file}" "${new_file}")" | ${pager}
        show_diff=false
    fi
    printf '\n>> %s\n' "${old_file}"
    printf '>> q quit, h help, n next, e edit-new, z zap-new, u use-new, m merge, l look-merge: '
    read -r -n 1 selection
    printf '\n'
    case "${selection}" in
      q) # quit
        exit
        ;;
      h) # help
        cat <<EOH
  u -- update current config with new config and continue
  z -- zap (delete) new config and continue
  n -- skip to next config, leave all intact
  e -- edit new config
  m -- interactively merge current and new configs
  l -- look at diff between pre-merged and merged configs
  h -- this screen
  q -- quit
EOH
        ;;
      n) # next
        break
        ;;
      e) # edit-new
        "${EDITOR}" "${new_file}"
        show_diff=true
        ;;
      z) # zap-new
        rm -f -- "${new_file}"
        break
        ;;
      u) # use-new
        mv -- "${new_file}" "${old_file}"
        break
        ;;
      m) # merge
        eval "$(printf "${merge}" "${old_file}" "${old_file}" "${new_file}")"
        rm -f -- "${new_file}"
        break
        ;;
      l) # look-merge
        show_diff=true
        ;;
    esac
  done
}

find / -xdev -type d -prune -o -name '*-opkg' -print0 | while read -r -d '' new_file; do
  handle_config_file "${new_file}"
done
