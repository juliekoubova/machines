[ -z "${XDG_RUNTIME_DIR}" ] || exit
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
[ -d "${XDG_RUNTIME_DIR}" ] || mkdir -m 0700 "${XDG_RUNTIME_DIR}"
