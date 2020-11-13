Ansible Role: Filebeat for Elastic Stack
------------------------------------

An Ansible Role that installs [Filebeat](https://www.elastic.co/products/beats/filebeat), this can be used in conjunction with [ansible-wazuh-manager](https://github.com/wazuh/wazuh-ansible/ansible-wazuh-server).

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

Available variables are listed below, along with default values (see `defaults/main.yml`):

```
  filebeat_output_elasticsearch_hosts:
    - "localhost:9200"

```

License and copyright
---------------------

WAZUH Copyright (C) 2020 Wazuh Inc. (License GPLv3)

### Based on previous work from geerlingguy

 - https://github.com/geerlingguy/ansible-role-filebeat

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
