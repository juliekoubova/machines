# Machine Provisioning Scripts

## Some Maybe Useful Stuff

### [notify-send-all.sh](https://github.com/juliekoubova/machines/blob/main/roles/sway-desktop/files/notify-send-all.sh)
A hacky script that sends a FreeDesktop notification to all DBus sessions. Works by enumerating `run-dbus-session` processes, 
reading their children's environment to extract the DBus socket path, and calling `notify-send` on each of them.

### [automount.sh](https://github.com/juliekoubova/machines/tree/main/roles/automount/files)
`udev` ruleset and script that mounts and unmounts all partitions when a USB disk is connected or disconnected. 

## Bootstrap
To bootstrap a new machine, run
```shell
# wget https://raw.github.com/juliekoubova/machines/main/scripts/bootstrap -q -O - | sh
```

To unlock the secrets, install `git-crypt` and run
```shell
git-crypt unlock /path/to/the/keyfile
```
