ansible-ossec-agent
=========

This role will install and configure an ossec-agent on the server. When there there is an parameter `ossec_server_name` configured, it will delagate an action for automatically authenticate the agent.

Requirements
------------

This role will work on:
 * Red Hat
 * Debian


Role Variables
--------------

This role needs 1 parameters:
* `ossec_server_ip`: This is the ip address of the server running the ossec-server.


Dependencies
------------

No dependencies.

Example Playbook
----------------

The following is an example how this role can be used:

    - hosts: all:!wazuh-manager
      roles:
         - { role: ansible-ossec-agent, ossec_server_ip: 192.168.1.1 }

License
-------

GPLv3

Author Information
------------------

Github: https://github.com/dj-wasabi/ansible-ossec-agent

mail: ikben [ at ] werner-dijkerman . nl

Modified by Wazuh
