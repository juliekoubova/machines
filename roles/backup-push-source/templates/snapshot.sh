#!/bin/sh
if [ `whoami` != "{{ backup_user }}" ]; then
  exec su -s /bin/sh "{{ backup_user }}" "{{ backup_home }}/snapshot.sh"
fi

{% for target in backup_targets | dict2items %}
flock --nonblock '{{ backup_home }}/snapshot.{{ target.key }}.lock' \
  zfs-autobackup \
  {{ backup_job_common_args }} \
  --no-send \
  '{{ target.key }}' 
{% endfor %}
