OpenWrt Maintenance Scripts
===========================

This role installs several maintenance scripts on [OpenWrt](https://www.openwrt.org/) targets.

Requirements
------------

This role has no special requirements on the controller.

It does, however, require a working [Python](https://www.python.org/) installation on the target system or [gekmihesg's Ansible library for OpenWrt](https://github.com/gekmihesg/ansible-openwrt) on the Ansible controller.

Role Variables
--------------

* `openwrt_maintenance_scripts_pkg_stats_on_login`  
  Whether to run `pkg-stats.sh` on each login as the `root` user.
  Defaults to `true`.

Dependencies
------------

This role does not depend on any specific roles.

Scripts
-------

### config-update.sh

Configuration file update helper inspired by `dispatch-conf`.
Finds and interactively handles outstanding configuration file updates from packages updates.

This script supports tuning it via the configuration file `/etc/config-update.conf`.
The config file uses ash syntax.
The following options are supported (along with their default values).
```sh
# Command to show changes between old and new config file.
# %s old file
# %s new file
# If using diff --color=always, the less -R option may be required for correct
# display.
diff="diff -u '%s' '%s'"
# Set the pager for use with diff commands (this will cause the $PAGER
# environment variable to be ignored).
# Setting pager="cat" will disable pager usage.
pager=""
# Default options used if less is the pager.
less_opts="-E"
# Command to interactively merge configuration files.
# %s output file
# %s old file
# %s new file
merge="sdiff --suppress-common-lines --output='%s' '%s' '%s'"
# Space-separated list of frozen files for which config-update.sh will
# automatically zap updates.
frozen_files=""
```

### opkg-predict-size.sh

Calculate the total space required to install the given packages, including their dependencies but not package that are already installed on the system.

### pkg-stats.sh

Show how many packages are currently installed and how many package updates are available.

License
-------

MIT
