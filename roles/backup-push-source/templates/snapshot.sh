#!/bin/sh
{% for target in backup_targets | dict2items %}
flock --nonblock '{{ backup_home }}/snapshot.{{ target.key }}.lock' \
  zfs-autobackup \
  {{ backup_job_common_args }} \
  --no-send \
  '{{ target.key }}' 
{% endfor %}
