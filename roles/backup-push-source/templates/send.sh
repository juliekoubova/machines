#!/bin/sh
{% for target in backup_targets %}
flock --nonblock '{{ backup_home }}/send.{{ target }}.lock' zfs-autobackup \
  --no-snapshot \
  --rate 50M \
  --ssh-target '{{ target }}' \
  --zfs-compressed \
  {{ backup_job_common_args }} \
  '{{ target }}' \
  '{{ hostvars[target].zfs_backups_dataset }}/{{ inventory_hostname }}'
{% endfor %}
