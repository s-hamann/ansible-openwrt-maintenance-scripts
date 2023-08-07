#!/bin/sh

opkgInstalled="$(opkg list-installed 2>/dev/null | wc -l)"
opkgUpgradable="$(opkg list-upgradable 2>/dev/null | wc -l)"

printf "%i packages are installed. %i packages can be upgraded.\n" "${opkgInstalled}" "${opkgUpgradable}"
