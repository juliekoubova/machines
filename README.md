# Machine Provisioning Scripts

## Some Potentially Useful Stuff

### [automount.sh](https://github.com/juliekoubova/machines/tree/main/roles/automount/files)
`udev` ruleset and script that mounts and unmounts all partitions when a USB disk is connected or disconnected. 

### [Firefox widevinecdm musl patcher](https://github.com/juliekoubova/machines/blob/main/roles/firefox/files/firefox)
Makes DRM-protected media play in Firefox on Alpine Linux (and potentially other musl-based distros). 
Works by patching  `widevinecdm.so` to load `gcompat.so`. **Caution:** [disables Firefox's Media Plugin sandbox!](https://wiki.mozilla.org/Security/Sandbox#Gecko_Media_Plugin_.28GMP.29)

### [notify-send-all.sh](https://github.com/juliekoubova/machines/blob/main/roles/sway-desktop/files/notify-send-all.sh)
A hacky script that sends a FreeDesktop notification to all DBus sessions. Works by enumerating `run-dbus-session` processes, 
reading their children's environment to extract the DBus socket path, and calling `notify-send` on each of them.

## Bootstrap
To bootstrap a new machine, run
```shell
# curl https://raw.githubusercontent.com/juliekoubova/machines/main/scripts/bootstrap | sh
```

### FreeBSD
You need to install `curl` first:
```shell
# pkg install --yes curl
```

To unlock the secrets, install `git-crypt` and run
```shell
git-crypt unlock /path/to/the/keyfile
```
