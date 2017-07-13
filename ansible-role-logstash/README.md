Ansible Role: Logstash
----------------------

An Ansible Role that installs [Logstash](https://www.elastic.co/products/logstash)

Requirements
------------

This role will work on:
 * Red Hat
 * CentOS
 * Fedora
 * Debian
 * Ubuntu

Role Variables
--------------
```
  ---
  elasticsearch_network_host: "127.0.0.1"
  elasticsearch_http_port: "9200"
  elk_stack_version: 5.4.0
```

Example Playbook
----------------

```
  - hosts: logstash
    roles:
      - { role: ansible-role-logstash, elasticsearch_network_host: '192.168.33.182' }
```

License and copyright
---------------------

WAZUH Copyright (C) 2017 Wazuh Inc. (License GPLv3)

### Based on previous work from geerlingguy

 - https://github.com/geerlingguy/ansible-role-elasticsearch

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
