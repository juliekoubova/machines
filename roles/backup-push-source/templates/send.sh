#!/bin/sh
{% for target in backup_targets | dict2items %}
{% if target.key != 'local' %}
flock --nonblock '{{ backup_home }}/send.{{ target.key }}.lock' zfs-autobackup \
  --no-snapshot \
  --rate 50M \
  --ssh-target '{{ target.key }}' \
  --zfs-compressed \
  {{ backup_job_common_args }} \
  '{{ target.key }}' \
  '{{ hostvars[target.key].zfs_backups_dataset }}/{{ inventory_hostname }}'
{% endif %}
{% endfor %}
