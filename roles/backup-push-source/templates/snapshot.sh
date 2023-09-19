#!/bin/sh
{% for target in backup_targets %}
flock --nonblock '{{ backup_home }}/snapshot.{{ target }}.lock' \
  zfs-autobackup \
  {{ backup_job_common_args }} \
  --no-send \
  '{{ target }}' 
{% endfor %}
