Ansible Playbook - Wazuh agent
==============================

This role will install and configure a Wazuh Agent.

OS Requirements
----------------

This role is compatible with:
 * Red Hat
 * CentOS
 * Fedora
 * Debian
 * Ubuntu
 * Windows
 * macOS


Role Variables
--------------

* `wazuh_managers`: Collection of Wazuh Managers' IP address, port, and protocol used by the agent
* `wazuh_agent_authd`: Collection with the settings to register an agent using authd.
* `wazuh_agent_local_options`: Optional dictionary of settings to be configured in the local_internal_options.conf file.

Playbook example
----------------

The following is an example of how this role can be used:

     - hosts: all:!wazuh-manager
       roles:
         - ansible-wazuh-agent
       vars:
         wazuh_managers:
           - address: 127.0.0.1
             port: 1514
             protocol: tcp
             api_port: 55000
             api_proto: 'http'
             api_user: 'ansible'
         wazuh_agent_authd:
           registration_address: 127.0.0.1
           enable: true
           port: 1515
           ssl_agent_ca: null
           ssl_auto_negotiate: 'no'
         wazuh_agent_local_options:
           logcollector.remote_commands: '0'
           wazuh_command.remote_commands: '1'


License and copyright
---------------------

WAZUH Copyright (C) 2016, Wazuh Inc. (License GPLv3)

### Based on previous work from dj-wasabi

  - https://github.com/dj-wasabi/ansible-ossec-server

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
