#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2025
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: service
short_description: Manage services with dinitctl support
description:
    - Controls services on remote hosts with dinitctl support.
    - Falls back to the built-in service module when dinitctl is not available.
    - Supports all standard service module parameters.
version_added: "1.0.0"
options:
    name:
        description:
            - Name of the service.
        type: str
        required: true
        aliases: [ service ]
    state:
        description:
            - C(started)/C(stopped) are idempotent actions that will not run commands unless necessary.
            - C(restarted) will always bounce the service.
            - C(reloaded) will always reload.
        type: str
        choices: [ reloaded, restarted, started, stopped ]
    enabled:
        description:
            - Whether the service should start on boot.
        type: bool
    pattern:
        description:
            - Pattern to look for in process list (used by some service managers).
        type: str
author:
    - Custom Module
'''

EXAMPLES = r'''
- name: Start service httpd, if not started
  service:
    name: httpd
    state: started

- name: Stop service httpd, if started
  service:
    name: httpd
    state: stopped

- name: Restart service httpd
  service:
    name: httpd
    state: restarted

- name: Enable service httpd
  service:
    name: httpd
    enabled: yes

- name: Disable service httpd
  service:
    name: httpd
    enabled: no
'''

RETURN = r'''
name:
    description: The name of the service
    returned: always
    type: str
    sample: "httpd"
state:
    description: The state of the service
    returned: always
    type: str
    sample: "started"
'''

from ansible.module_utils.basic import AnsibleModule
import os


class DinitService:
    """Handler for dinitctl service management"""
    
    def __init__(self, module):
        self.module = module
        self.name = module.params['name']
        self.state = module.params['state']
        self.enabled = module.params['enabled']
        self.dinitctl = module.get_bin_path('dinitctl', required=True)
        
    def get_service_status(self):
        """Check if service is running"""
        rc, stdout, stderr = self.module.run_command([self.dinitctl, 'status', self.name])
        # dinitctl status returns 0 if service exists
        if rc != 0:
            return None
        
        # Check if service is started (look for "started" or "running" in output)
        is_running = 'started' in stdout.lower() or 'running' in stdout.lower()
        return is_running
    
    def get_service_enabled(self):
        """Check if service is enabled"""
        # Check if the service file exists in /etc/dinit.d/boot.d/
        boot_service_path = os.path.join('/etc/dinit.d/boot.d', self.name)
        return os.path.exists(boot_service_path)
    
    def start_service(self):
        """Start the service"""
        rc, stdout, stderr = self.module.run_command([self.dinitctl, 'start', self.name])
        if rc != 0:
            return False, False
        # Check if service was already started
        already_started = 'Service (already) started' in stdout
        return True, not already_started
    
    def stop_service(self):
        """Stop the service"""
        rc, stdout, stderr = self.module.run_command([self.dinitctl, 'stop', self.name])
        if rc != 0:
            return False, False
        # Check if service was already stopped
        already_stopped = 'Service (already) stopped' in stdout
        return True, not already_stopped
    
    def restart_service(self):
        """Restart the service"""
        rc, stdout, stderr = self.module.run_command([self.dinitctl, 'restart', self.name])
        return rc == 0
    
    def reload_service(self):
        """Reload the service"""
        # dinit doesn't have a native reload, so we'll try to send a signal
        # or restart as fallback
        rc, stdout, stderr = self.module.run_command([self.dinitctl, 'reload', self.name])
        if rc != 0:
            # Fallback to restart
            return self.restart_service()
        return True
    
    def enable_service(self):
        """Enable the service"""
        rc, stdout, stderr = self.module.run_command([self.dinitctl, 'enable', self.name])
        if rc == 0:
            return True, True
        # Check if service was already enabled
        if rc == 1 and 'service already enabled' in stderr.lower():
            return True, False
        return False, False
    
    def disable_service(self):
        """Disable the service"""
        rc, stdout, stderr = self.module.run_command([self.dinitctl, 'disable', self.name])
        if rc == 0:
            return True, True
        # Check if service was not currently enabled
        if rc == 1 and 'service not currently enabled' in stderr.lower():
            return True, False
        return False, False
    
    def execute(self):
        """Execute the requested service operations"""
        changed = False
        result = {'name': self.name}
        
        current_status = self.get_service_status()
        
        # Handle state changes
        if self.state == 'started':
            if not self.module.check_mode:
                success, state_changed = self.start_service()
                if not success:
                    self.module.fail_json(msg=f"Failed to start service {self.name}")
                changed = state_changed
            else:
                # In check mode, check if it would change
                if not current_status:
                    changed = True
            result['state'] = 'started'
            
        elif self.state == 'stopped':
            if not self.module.check_mode:
                success, state_changed = self.stop_service()
                if not success:
                    self.module.fail_json(msg=f"Failed to stop service {self.name}")
                changed = state_changed
            else:
                # In check mode, check if it would change
                if current_status:
                    changed = True
            result['state'] = 'stopped'
            
        elif self.state == 'restarted':
            if not self.module.check_mode:
                self.restart_service()
            changed = True
            result['state'] = 'started'
            
        elif self.state == 'reloaded':
            if not self.module.check_mode:
                self.reload_service()
            changed = True
            result['state'] = 'started'
        
        # Handle enabled state
        if self.enabled is not None:
            if self.enabled:
                if not self.module.check_mode:
                    success, enabled_changed = self.enable_service()
                    if not success:
                        self.module.fail_json(msg=f"Failed to enable service {self.name}")
                    if enabled_changed:
                        changed = True
                else:
                    # In check mode, check if it would change
                    current_enabled = self.get_service_enabled()
                    if not current_enabled:
                        changed = True
                result['enabled'] = True
            else:
                if not self.module.check_mode:
                    success, disabled_changed = self.disable_service()
                    if not success:
                        self.module.fail_json(msg=f"Failed to disable service {self.name}")
                    if disabled_changed:
                        changed = True
                else:
                    # In check mode, check if it would change
                    current_enabled = self.get_service_enabled()
                    if current_enabled:
                        changed = True
                result['enabled'] = False
        
        return changed, result


def has_dinitctl():
    """Check if dinitctl is available on the system"""
    return os.path.exists('/usr/bin/dinitctl') or os.path.exists('/bin/dinitctl') or os.path.exists('/usr/local/bin/dinitctl')


def forward_to_builtin_service(module):
    """Forward the call to Ansible's built-in service module"""
    # Import the actual service module
    try:
        from ansible.modules.service import main as service_main
        # The built-in service module will handle the execution
        service_main()
    except ImportError:
        # Fallback: use action plugin by returning parameters
        # This allows Ansible to handle it through the action plugin
        module.fail_json(msg="Built-in service module not found and dinitctl not available")


def main():
    module = AnsibleModule(
        argument_spec=dict(
            name=dict(type='str', required=True, aliases=['service']),
            state=dict(type='str', choices=['reloaded', 'restarted', 'started', 'stopped']),
            enabled=dict(type='bool'),
            pattern=dict(type='str'),
        ),
        supports_check_mode=True,
    )
    
    # Check if dinitctl is available
    if has_dinitctl():
        # Use dinitctl
        try:
            service = DinitService(module)
            changed, result = service.execute()
            module.exit_json(changed=changed, **result)
        except Exception as e:
            module.fail_json(msg=f"Failed to manage service with dinitctl: {str(e)}")
    else:
        # Forward to built-in service module
        forward_to_builtin_service(module)


if __name__ == '__main__':
    main()
