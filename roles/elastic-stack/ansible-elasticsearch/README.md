Ansible Role: Elasticsearch
===========================

An Ansible Role that installs [Elasticsearch](https://www.elastic.co/products/elasticsearch).

Requirements
------------

This role will work on:
 * Red Hat
 * CentOS
 * Fedora
 * Debian
 * Ubuntu
 
For the elasticsearch role with XPack security the `unzip` command must be available on the Ansible master.

Role Variables
--------------

Defaults variables are listed below, along with its values (see `defaults/main.yml`):

```
  elasticsearch_cluster_name: wazuh
  elasticsearch_node_name: node-1
  elasticsearch_http_port: 9200
  elasticsearch_network_host: 127.0.0.1
  elasticsearch_jvm_xms: 1g
  elastic_stack_version: 5.5.0
```

Example Playbook
----------------

- Single-node
```
  - hosts: elasticsearch
    roles:
      - { role: ansible-role-elasticsearch, elasticsearch_network_host: '192.168.33.182', single_host: true }
```

- Three nodes Elasticsearch cluster
```
---
- hosts: 172.16.0.161
  roles:
    - {role: ../roles/elastic-stack/ansible-elasticsearch, elasticsearch_network_host: '172.16.0.161', elasticsearch_bootstrap_node: true, elasticsearch_cluster_nodes: ['172.16.0.162','172.16.0.163','172.16.0.161']}

- hosts: 172.16.0.162
  roles:
    - {role: ../roles/elastic-stack/ansible-elasticsearch, elasticsearch_network_host: '172.16.0.162', elasticsearch_node_master: true, elasticsearch_cluster_nodes: ['172.16.0.162','172.16.0.163','172.16.0.161']}

- hosts: 172.16.0.163
  roles:
    - {role: ../roles/elastic-stack/ansible-elasticsearch, elasticsearch_network_host: '172.16.0.163', elasticsearch_node_master: true, elasticsearch_cluster_nodes: ['172.16.0.162','172.16.0.163','172.16.0.161']}
```

- Three nodes Elasticsearch cluster with XPack security
```
---
- hosts: elastic-1
  roles:
    - role: ../roles/elastic-stack/ansible-elasticsearch
      elasticsearch_network_host: 172.16.0.111
      elasticsearch_node_name: node-1
      single_node: false
      elasticsearch_node_master: true
      elasticsearch_bootstrap_node: true
      elasticsearch_cluster_nodes:
        - 172.16.0.111
        - 172.16.0.112
        - 172.16.0.113
      elasticsearch_discovery_nodes:
        - 172.16.0.111
        - 172.16.0.112
        - 172.16.0.113
      elasticsearch_xpack_security: true
      node_certs_generator: true
      node_certs_generator_ip: 172.16.0.111

  vars:
    instances:
      node-1:
        name: node-1
        ip: 172.16.0.111
      node-2:
        name: node-2
        ip: 172.16.0.112
      node-3:
        name: node-3
        ip: 172.16.0.113

- hosts: elastic-2
  roles:
    - role: ../roles/elastic-stack/ansible-elasticsearch
      elasticsearch_network_host: 172.16.0.112
      elasticsearch_node_name: node-2
      single_node: false
      elasticsearch_xpack_security: true
      elasticsearch_node_master: true
      node_certs_generator_ip: 172.16.0.111
      elasticsearch_discovery_nodes:
        - 172.16.0.111
        - 172.16.0.112
        - 172.16.0.113

- hosts: elastic-3
  roles:
    - role: ../roles/elastic-stack/ansible-elasticsearch
      elasticsearch_network_host: 172.16.0.113
      elasticsearch_node_name: node-3
      single_node: false
      elasticsearch_xpack_security: true
      elasticsearch_node_master: true
      node_certs_generator_ip: 172.16.0.111
      elasticsearch_discovery_nodes:
        - 172.16.0.111
        - 172.16.0.112
        - 172.16.0.113
  vars:
    elasticsearch_xpack_users:
      anne:
        password: 'PasswordHere'
        roles: '["kibana_user", "monitoring_user"]'
      jack:
        password: 'PasswordHere'
        roles: '["superuser"]'

```

It is possible to define users directly on the playbook, these must be defined on a variable `elasticsearch_xpack_users` on the last node of the cluster as in the example.


License and copyright
---------------------

WAZUH Copyright (C) 2020 Wazuh Inc. (License GPLv3)

### Based on previous work from geerlingguy

 - https://github.com/geerlingguy/ansible-role-elasticsearch

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
