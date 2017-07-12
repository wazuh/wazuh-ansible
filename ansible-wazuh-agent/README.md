Ansible Playbook - Wazuh agent
==============================

This role will install and configure an Wazuh Agent.

OS Requirements
----------------

This role is compatible with:
 * Red Hat
 * CentOS
 * Fedora
 * Debian
 * Ubuntu


Role Variables
--------------

* `wazuh_manager_ip`: Wazuh Manager IP Address.
* `wazuh_authd_port`: Registration service port (Default: 1515).
* `wazuh_register_client`: If true, agent will request a new key from registration service (Default: True).
* `wazuh_agent_config`: Includes several parameters for configuring agent components as syscheck, rootcheck, open-scap and localfiles.


Playbook example
----------------

The following is an example how this role can be used:

    - hosts: all:!wazuh-manager
      roles:
         - { role: ansible-wazuh-agent, wazuh_manager_ip: 192.168.1.1, wazuh_register_client: true, wazuh_authd_port: 1515 }

License and copyright
---------------------

WAZUH Copyright (C) 2017 Wazuh Inc. (License GPLv3)

### Based on previous work from dj-wasabi

  - https://github.com/dj-wasabi/ansible-ossec-server

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
