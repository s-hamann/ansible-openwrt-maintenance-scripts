#!/bin/sh
# Predict the total space required to install the given packages and their dependencies.

if [ $# -lt 1 ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
    cat <<EOH
Usage: $0 <pkgs>
  Calculate the total space required to install the given packages, including
  their dependencies but not packages that are already installed on the system.
EOH
fi

pkgs="$*"
processed_pkgs=""
total_size=0

while { pkgs="${pkgs#"${pkgs%%[! ]*}"}"; [ -n "${pkgs}" ]; }; do
    pkg="${pkgs%% *}"
    pkgs="${pkgs#"${pkg}"}"
    # Avoid loops: Check if $pkg is already processed.
    if printf '%s' "${processed_pkgs}" | grep -q -F -w -e "${pkg}"; then
        continue
    fi
    opkg_info="$(opkg info "${pkg}")"
    # Check if the package is already installed.
    if ! printf '%s' "${opkg_info}" | grep -q '^Status: .*not-installed'; then
        continue
    fi
    # Get the size.
    pkg_size="$(printf '%s' "${opkg_info}" | grep -F 'Size: ' | cut -d' ' -f2)"
    let total_size+=pkg_size
    # Get the dependencies and add them to the list.
    pkg_deps="$(printf '%s' "${opkg_info}" | grep -F 'Depends: ' | cut -d' ' -f2- | tr -d ',')"
    pkgs="${pkgs} ${pkg_deps}"
    # Add $pkg to the processed list.
    processed_pkgs="${processed_pkgs} ${pkg}"
done

printf 'The following packages will be installed:\n'
printf ' %s\n' ${processed_pkgs}
printf 'Total size: %i bytes' "${total_size}"
if [ "${total_size}" -gt 1048576 ]; then
    printf ' (%.2f MiB)\n' "$(( 1000000 * total_size / 1048576 ))e-6"
elif [ "${total_size}" -gt 1024 ]; then
    printf ' (%.2f KiB)\n' "$(( 1000 * total_size / 1024 ))e-3"
fi
