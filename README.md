# Wazuh-Ansible

[![Slack](https://img.shields.io/badge/slack-join-blue.svg)](https://wazuh.com/community/join-us-on-slack/)
[![Email](https://img.shields.io/badge/email-join-blue.svg)](https://groups.google.com/forum/#!forum/wazuh)
[![Documentation](https://img.shields.io/badge/docs-view-green.svg)](https://documentation.wazuh.com)
[![Documentation](https://img.shields.io/badge/web-view-green.svg)](https://wazuh.com)

These playbooks install and configure Wazuh agent, manager and Elastic Stack.

## Branches
* `master` branch corresponds to the latest Wazuh Ansible changes. It might be unstable.
* `3.13` branch on correspond to the last Wazuh Ansible stable version.

## Compatibility Matrix

| Wazuh version | Elastic | ODFE   |
|---------------|---------|--------|
| v4.0.3        | 7.9.3   | 1.11.0 |

## Documentation

* [Wazuh Ansible documentation](https://documentation.wazuh.com/current/deploying-with-ansible/index.html)
* [Full documentation](http://documentation.wazuh.com)

## Directory structure

    ├── wazuh-ansible
    │ ├── roles
    │ │ ├── elastic-stack
    │ │ │ ├── ansible-elasticsearch
    │ │ │ ├── ansible-kibana
    │ │
    │ │ ├── opendistro
    │ │ │ ├── opendistro-elasticsearch
    │ │ │ ├── opendistro-kibana
    │ │
    │ │ ├── wazuh
    │ │ │ ├── ansible-filebeat
    │ │ │ ├── ansible-filebeat-oss
    │ │ │ ├── ansible-wazuh-manager
    │ │ │ ├── ansible-wazuh-agent
    │ │
    │ │ ├── ansible-galaxy
    │ │ │ ├── meta
    │
    │ ├── playbooks
    │ │ ├── wazuh-agent.yml
    │ │ ├── wazuh-elastic.yml
    │ │ ├── wazuh-elastic_stack-distributed.yml
    │ │ ├── wazuh-elastic_stack-single.yml
    │ │ ├── wazuh-kibana.yml
    │ │ ├── wazuh-manager.yml
    │ │ ├── wazuh-manager-oss.yml
    │ │ ├── wazuh-opendistro.yml
    │ │ ├── wazuh-opendistro-kibana.yml
    │
    │ ├── README.md
    │ ├── VERSION
    │ ├── CHANGELOG.md


## Example: production-ready distributed environment

### Playbook
The hereunder example playbook uses the `wazuh-ansible` role to provision a production-ready Wazuh environment. The architecture includes 2 Wazuh nodes, 3 ODFE nodes and a mixed ODFE-Kibana node.

```yaml
---
# Certificates generation
    - hosts: es1
      roles:
        - role: ../roles/opendistro/opendistro-elasticsearch
          elasticsearch_network_host: "{{ private_ip }}"
          elasticsearch_cluster_nodes:
            - "{{ hostvars.es1.private_ip }}"
            - "{{ hostvars.es2.private_ip }}"
            - "{{ hostvars.es3.private_ip }}"
          elasticsearch_discovery_nodes:
            - "{{ hostvars.es1.private_ip }}"
            - "{{ hostvars.es2.private_ip }}"
            - "{{ hostvars.es3.private_ip }}"
          perform_installation: false
      become: yes
      become_user: root
      vars:
        elasticsearch_node_master: true
        instances:
          node1:
            name: node-1       # Important: must be equal to elasticsearch_node_name.
            ip: "{{ hostvars.es1.private_ip }}"   # When unzipping, the node will search for its node name folder to get the cert.
          node2:
            name: node-2
            ip: "{{ hostvars.es2.private_ip }}"
          node3:
            name: node-3
            ip: "{{ hostvars.es3.private_ip }}"
          node4:
            name: node-4
            ip: "{{ hostvars.manager.private_ip }}"
          node5:
            name: node-5
            ip: "{{ hostvars.worker.private_ip }}"
          node6:
            name: node-6
            ip: "{{ hostvars.kibana.private_ip }}"
      tags:
        - generate-certs

#ODFE Cluster
    - hosts: odfe_cluster
      strategy: free
      roles:
        - role: ../roles/opendistro/opendistro-elasticsearch
          elasticsearch_network_host: "{{ private_ip }}"
      become: yes
      become_user: root
      vars:
        elasticsearch_cluster_nodes:
          - "{{ hostvars.es1.private_ip }}"
          - "{{ hostvars.es2.private_ip }}"
          - "{{ hostvars.es3.private_ip }}"
        elasticsearch_discovery_nodes:
          - "{{ hostvars.es1.private_ip }}"
          - "{{ hostvars.es2.private_ip }}"
          - "{{ hostvars.es3.private_ip }}"
        elasticsearch_node_master: true
        instances:
          node1:
            name: node-1       # Important: must be equal to elasticsearch_node_name.
            ip: "{{ hostvars.es1.private_ip }}"   # When unzipping, the node will search for its node name folder to get the cert.
          node2:
            name: node-2
            ip: "{{ hostvars.es2.private_ip }}"
          node3:
            name: node-3
            ip: "{{ hostvars.es3.private_ip }}"
          node4:
            name: node-4
            ip: "{{ hostvars.manager.private_ip }}"
          node5:
            name: node-5
            ip: "{{ hostvars.worker.private_ip }}"
          node6:
            name: node-6
            ip: "{{ hostvars.kibana.private_ip }}"

  #Wazuh cluster
    - hosts: manager
      roles:
        - role: "../roles/wazuh/ansible-wazuh-manager"
        - role: "../roles/wazuh/ansible-filebeat-oss"
          filebeat_node_name: node-4
      become: yes
      become_user: root
      vars:
        wazuh_manager_config:
          connection:
              - type: 'secure'
                port: '1514'
                protocol: 'tcp'
                queue_size: 131072
          api:
              https: 'yes'
          cluster:
              disable: 'no'
              node_name: 'master'
              node_type: 'master'
              key: 'c98b62a9b6169ac5f67dae55ae4a9088'
              nodes:
                  - "{{ hostvars.manager.private_ip }}"
              hidden: 'no'
        filebeat_output_elasticsearch_hosts:
                - "{{ hostvars.es1.private_ip }}"
                - "{{ hostvars.es2.private_ip }}"
                - "{{ hostvars.es3.private_ip }}"

    - hosts: worker
      roles:
        - role: "../roles/wazuh/ansible-wazuh-manager"
        - role: "../roles/wazuh/ansible-filebeat-oss"
          filebeat_node_name: node-5
      become: yes
      become_user: root
      vars:
        wazuh_manager_config:
          connection:
              - type: 'secure'
                port: '1514'
                protocol: 'tcp'
                queue_size: 131072
          api:
              https: 'yes'
          cluster:
              disable: 'no'
              node_name: 'worker_01'
              node_type: 'worker'
              key: 'c98b62a9b6169ac5f67dae55ae4a9088'
              nodes:
                  - "{{ hostvars.manager.private_ip }}"
              hidden: 'no'
        filebeat_output_elasticsearch_hosts:
                - "{{ hostvars.es1.private_ip }}"
                - "{{ hostvars.es2.private_ip }}"
                - "{{ hostvars.es3.private_ip }}"

  #ODFE+Kibana node
    - hosts: kibana
      roles:
        - role: "../roles/opendistro/opendistro-elasticsearch"
        - role: "../roles/opendistro/opendistro-kibana"
      become: yes
      become_user: root
      vars:
        elasticsearch_network_host: "{{ hostvars.kibana.private_ip }}"
        elasticsearch_node_name: node-6
        elasticsearch_node_master: false
        elasticsearch_node_ingest: false
        elasticsearch_node_data: false
        elasticsearch_cluster_nodes:
            - "{{ hostvars.es1.private_ip }}"
            - "{{ hostvars.es2.private_ip }}"
            - "{{ hostvars.es3.private_ip }}"
        elasticsearch_discovery_nodes:
            - "{{ hostvars.es1.private_ip }}"
            - "{{ hostvars.es2.private_ip }}"
            - "{{ hostvars.es3.private_ip }}"
        kibana_node_name: node-6
        wazuh_api_credentials:
          - id: default
            url: https://{{ hostvars.manager.private_ip }}
            port: 55000
            user: foo
            password: bar
        instances:
          node1:
            name: node-1       # Important: must be equal to elasticsearch_node_name.
            ip: "{{ hostvars.es1.private_ip }}"   # When unzipping, the node will search for its node name folder to get the cert.
          node2:
            name: node-2
            ip: "{{ hostvars.es2.private_ip }}"
          node3:
            name: node-3
            ip: "{{ hostvars.es3.private_ip }}"
          node4:
            name: node-4
            ip: "{{ hostvars.manager.private_ip }}"
          node5:
            name: node-5
            ip: "{{ hostvars.worker.private_ip }}"
          node6:
            name: node-6
            ip: "{{ hostvars.kibana.private_ip }}"
```

### Inventory file

- The `ansible_host` variable should contain the `address/FQDN` used to gather facts and provision each node.
- The `private_ip` variable should contain the `address/FQDN` used for the internal cluster communications.
- Whether the environment is located in a local subnet, `ansible_host` and `private_ip` variables should match.
- The ssh credentials used by Ansible during the provision can be specified in this file too. Another option is including them directly on the playbook.

```ini
es1 ansible_host=<es1_ec2_public_ip> private_ip=<es1_ec2_private_ip> elasticsearch_node_name=node-1
es2 ansible_host=<es2_ec2_public_ip> private_ip=<es2_ec2_private_ip> elasticsearch_node_name=node-2
es3 ansible_host=<es3_ec2_public_ip> private_ip=<es3_ec2_private_ip> elasticsearch_node_name=node-3
kibana  ansible_host=<kibana_node_public_ip> private_ip=<kibana_ec2_private_ip>
manager ansible_host=<manager_node_public_ip> private_ip=<manager_ec2_private_ip>
worker  ansible_host=<worker_node_public_ip> private_ip=<worker_ec2_private_ip>

[odfe_cluster]
es1
es2
es3

[all:vars]
ansible_ssh_user=vagrant
ansible_ssh_private_key_file=/path/to/ssh/key.pem
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
```

### Launching the playbook

```bash
ansible-playbook wazuh-odfe-production-ready.yml -i inventory
```

After the playbook execution, the Wazuh UI should be reachable through `https://<kibana_host>:5601`

## Example: single-host environment

### Playbook
The hereunder example playbook uses the `wazuh-ansible` role to provision a single-host Wazuh environment. This architecture includes all the Wazuh and ODFE components in a single node.

```yaml
---
# Single node
    - hosts: server
      become: yes
      become_user: root
      roles:
        - role: ../roles/opendistro/opendistro-elasticsearch
        - role: "../roles/wazuh/ansible-wazuh-manager"
        - role: "../roles/wazuh/ansible-filebeat-oss"
        - role: "../roles/opendistro/opendistro-kibana"
      vars:
        single_node: true
        minimum_master_nodes: 1
        elasticsearch_node_master: true
        elasticsearch_network_host: <your server host>
        filebeat_node_name: node-1
        filebeat_output_elasticsearch_hosts: <your server host>
        ansible_ssh_user: vagrant
        ansible_ssh_private_key_file: /path/to/ssh/key.pem
        ansible_ssh_extra_args: '-o StrictHostKeyChecking=no'
        instances:
          node1:
            name: node-1       # Important: must be equal to elasticsearch_node_name.
            ip: <your server host>
```

### Inventory file

```ini
[server]
<your server host>

[all:vars]
ansible_ssh_user=vagrant
ansible_ssh_private_key_file=/path/to/ssh/key.pem
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
```

### Launching the playbook

```bash
ansible-playbook wazuh-odfe-single.yml -i inventory
```

After the playbook execution, the Wazuh UI should be reachable through `https://<your server host>:5601`

## Contribute

If you want to contribute to our repository, please fork our Github repository and submit a pull request.

If you are not familiar with Github, you can also share them through [our users mailing list](https://groups.google.com/d/forum/wazuh), to which you can subscribe by sending an email to `wazuh+subscribe@googlegroups.com`.

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.

## Credits and Thank you

Based on previous work from dj-wasabi.

https://github.com/dj-wasabi/ansible-ossec-server

## License and copyright

WAZUH
Copyright (C) 2016-2020 Wazuh Inc.  (License GPLv2)

## Web references

* [Wazuh website](http://wazuh.com)
