#!/bin/sh
: "${AUTOMOUNT_ROOT:=/media}"
: "${AUTOMOUNT_OPTS:=sync,noatime,noexec,nosuid,nodev}"
: "${AUTOMOUNT_GROUP:=plugdev}"

action="${1}"
device_name="${2}"
device_path="/dev/${device_name}"
mountpoint="${AUTOMOUNT_ROOT}/${device_name}"

log() {
  logger -s -t "automount.sh ${device_name}" "$@"
}

fail() {
  log -p user.error "${1}"
  exit 1
}

notify() {
  if [ -x /usr/local/bin/notify-send-all ]; then
    /usr/local/bin/notify-send-all --expire-time=5000 "automount.sh" "$1"
  fi
}

if [ "${action}" == "remove" ]; then
  if mountpoint -q "${mountpoint}"; then
    log "Unmounting ${mountpoint}"
    notify "Unmounting ${mountpoint}"
    umount "${mountpoint}" || fail "Failed to unmount"
    rmdir "${mountpoint}"
  fi
  exit 0
fi

[ -n "${device_name}" ] || fail "Device name not specified"
[ -b "${device_path}" ] || fail "Not a block device"

fstype=`lsblk "${device_path}" -no fstype` || \
  fail "Could not determine filesystem type"

gid=`getent group "${AUTOMOUNT_GROUP}" | cut -d: -f3`
[ -n "${gid}" ] || fail "Could not determine group id of '${AUTOMOUNT_GROUP}'"

if [ ! -d "${mountpoint}" ]; then
  mkdir "${AUTOMOUNT_ROOT}/${device_name}" || \
    fail "Could not create ${AUTOMOUNT_ROOT}/${device_name}"
fi

case "${fstype}" in
  vfat)
    log "Mounting as vfat"
    notify "Mounting ${mountpoint} as vfat"
    mount -t vfat -o "${AUTOMOUNT_OPTS},dmask=002,fmask=113,gid=${gid}" "${device_path}" "${mountpoint}" \
      || fail "Failed to mount"
    exit 0
    ;;
  *) fail "Unknown fstype: '${fstype}'"
esac
