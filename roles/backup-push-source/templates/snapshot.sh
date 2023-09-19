#!/bin/sh
{% for target in backup_targets %}
zfs-autobackup {{ backup_job_common_args }} --no-send '{{ target }}' 
{% endfor %}
