#!/bin/sh
[ "$1" == "pre-commit" ] || exit 0

errexit() {
  echo $1 >&2
  exit 1
}

_rootfs=`df / | tail -n -1 | cut -d' ' -f1` \
  || errexit "couldn't determine the root dataset"

zfs set autobackup:apk=true "${_rootfs}" \
  || errexit "couldn't set the autobackup:apk property on ${_rootfs}"

echo "Creating ZFS autobackup snapshot..."
exec zfs-autobackup \
  --utc --snapshot-format '{}-%Y-%m-%d-%H%M%SZ' \
  --no-send \
  --keep-source 10 \
  apk
