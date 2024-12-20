#!/bin/sh
if [ `whoami` != "{{ backup_user }}" ]; then
  exec su -s /bin/sh "{{ backup_user }}" "{{ backup_home }}/send.sh"
fi

{% for target in backup_targets | dict2items %}
{% if target.key != 'local' %}
flock --nonblock '{{ backup_home }}/send.{{ target.key }}.lock' zfs-autobackup \
  --filter-properties mountpoint,autobackup:{{ target.key }},keylocation \
  --destroy-missing 60d \
  --destroy-incompatible \
  --clear-mountpoint \
  --clear-refreservation \
  --set-properties readonly=on \
  --force \
  --no-snapshot \
  --ssh-target '{{ target.key }}' \
  --zfs-compressed \
  {{ backup_job_common_args }} \
  '{{ target.key }}' \
  '{{ hostvars[target.key].zfs_backups_dataset }}/{{ inventory_hostname }}'
{% endif %}
{% endfor %}
