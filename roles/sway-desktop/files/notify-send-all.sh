#!/bin/sh

fail() {
  echo "${1}" >&2
  exit 1
}

[ `id -u` -eq 0 ] || fail "must be root"
[ -x /usr/bin/notify-send ] || fail "notify-send not available"

dbus_addresses=`pgrep dbus-run-session \
  | xargs -n1 pgrep -P \
  | xargs -n1 -I{} cat /proc/{}/environ \
  | xargs -0 -n1 echo \
  | sed -nr 's/^DBUS_SESSION_BUS_ADDRESS=(.*)/\1/p' \
  | uniq`

for dbus_address in $dbus_addresses; do
  dbus_socket=`echo "$dbus_address" | cut -d, -f1 | cut -d= -f2`
  dbus_user=`stat -c '%U' "${dbus_socket}"`
  DBUS_SESSION_BUS_ADDRESS="${dbus_address}" su \
    "${dbus_user}" -s /usr/bin/notify-send -- "$@"
done
