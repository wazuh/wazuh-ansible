# Wazuh-Ansible

[![Slack](https://img.shields.io/badge/slack-join-blue.svg)](https://wazuh.com/community/join-us-on-slack/)
[![Email](https://img.shields.io/badge/email-join-blue.svg)](https://groups.google.com/forum/#!forum/wazuh)
[![Documentation](https://img.shields.io/badge/docs-view-green.svg)](https://documentation.wazuh.com)
[![Documentation](https://img.shields.io/badge/web-view-green.svg)](https://wazuh.com)

These playbooks install and configure Wazuh agent, manager and indexer and dashboard.

## Branches

- `master` branch contains the latest code, be aware of possible bugs on this branch.
- `stable` branch on correspond to the last Wazuh stable version.

## Compatibility Matrix

| Wazuh version | Elastic | ODFE   |
|---------------|---------|--------|
| v4.4.4        |         |        |
| v4.4.3        |         |        |
| v4.4.2        |         |        |
| v4.4.1        |         |        |
| v4.4.0        |         |        |
| v4.3.11       |         |        |
| v4.3.10       |         |        |
| v4.3.9        |         |        |
| v4.3.8        |         |        |
| v4.3.7        |         |        |
| v4.3.6        |         |        |
| v4.3.5        |         |        |
| v4.3.4        |         |        |
| v4.3.3        |         |        |
| v4.3.2        |         |        |
| v4.3.1        |         |        |
| v4.3.0        |         |        |
| v4.2.6        | 7.10.2  | 1.13.2 |
| v4.2.5        | 7.10.2  | 1.13.2 |
| v4.2.4        | 7.10.2  | 1.13.2 |
| v4.2.3        | 7.10.2  | 1.13.2 |
| v4.2.2        | 7.10.2  | 1.13.2 |
| v4.2.1        | 7.10.2  | 1.13.2 |
| v4.2.0        | 7.10.2  | 1.13.2 |
| v4.1.5        | 7.10.2  | 1.13.2 |
| v4.1.4        | 7.10.0  | 1.12.0 |
| v4.1.3        | 7.10.0  | 1.12.0 |
| v4.1.2        | 7.10.0  | 1.12.0 |
| v4.1.1        | 7.10.0  | 1.12.0 |

## Documentation

- [Wazuh Ansible documentation](https://documentation.wazuh.com/current/deploying-with-ansible/index.html)
- [Full documentation](http://documentation.wazuh.com)

## Directory structure

    ├── wazuh-ansible
    │ ├── roles
    │ │ ├── wazuh
    │ │ │ ├── ansible-filebeat-oss
    │ │ │ ├── ansible-wazuh-manager
    │ │ │ ├── ansible-wazuh-agent
    │ │ │ ├── wazuh-dashboard
    │ │ │ ├── wazuh-indexer
    │ │
    │ │ ├── ansible-galaxy
    │ │ │ ├── meta
    │
    │ ├── playbooks
    │ │ ├── wazuh-agent.yml
    │ │ ├── wazuh-dashboard.yml
    │ │ ├── wazuh-indexer.yml
    │ │ ├── wazuh-manager-oss.yml
    | | ├── wazuh-production-ready
    │ │ ├── wazuh-single.yml
    │
    │ ├── README.md
    │ ├── VERSION
    │ ├── CHANGELOG.md

## Example: production-ready distributed environment

### Playbook

The hereunder example playbook uses the `wazuh-ansible` role to provision a production-ready Wazuh environment. The architecture includes 2 Wazuh nodes, 3 Wazuh indexer nodes and a mixed Wazuh dashboard node (Wazuh indexer data node + Wazuh dashboard).

```yaml
---
# Certificates generation
    - hosts: wi1
      roles:
        - role: ../roles/wazuh/wazuh-indexer
          indexer_network_host: "{{ private_ip }}"
          indexer_cluster_nodes:
            - "{{ hostvars.wi1.private_ip }}"
            - "{{ hostvars.wi2.private_ip }}"
            - "{{ hostvars.wi3.private_ip }}"
          indexer_discovery_nodes:
            - "{{ hostvars.wi1.private_ip }}"
            - "{{ hostvars.wi2.private_ip }}"
            - "{{ hostvars.wi3.private_ip }}"
          perform_installation: false
      become: no
      vars:
        indexer_node_master: true
        instances:
          node1:
            name: node-1       # Important: must be equal to indexer_node_name.
            ip: "{{ hostvars.wi1.private_ip }}"   # When unzipping, the node will search for its node name folder to get the cert.
            role: indexer
          node2:
            name: node-2
            ip: "{{ hostvars.wi2.private_ip }}"
            role: indexer
          node3:
            name: node-3
            ip: "{{ hostvars.wi3.private_ip }}"
            role: indexer
          node4:
            name: node-4
            ip: "{{ hostvars.manager.private_ip }}"
            role: wazuh
            node_type: master
          node5:
            name: node-5
            ip: "{{ hostvars.worker.private_ip }}"
            role: wazuh
            node_type: worker
          node6:
            name: node-6
            ip: "{{ hostvars.dashboard.private_ip }}"
            role: dashboard
      tags:
        - generate-certs

# Wazuh indexer cluster
    - hosts: wi_cluster
      strategy: free
      roles:
        - role: ../roles/wazuh/wazuh-indexer
          indexer_network_host: "{{ private_ip }}"
      become: yes
      become_user: root
      vars:
        indexer_cluster_nodes:
          - "{{ hostvars.wi1.private_ip }}"
          - "{{ hostvars.wi2.private_ip }}"
          - "{{ hostvars.wi3.private_ip }}"
        indexer_discovery_nodes:
          - "{{ hostvars.wi1.private_ip }}"
          - "{{ hostvars.wi2.private_ip }}"
          - "{{ hostvars.wi3.private_ip }}"
        indexer_node_master: true
        instances:
          node1:
            name: node-1       # Important: must be equal to indexer_node_name.
            ip: "{{ hostvars.wi1.private_ip }}"   # When unzipping, the node will search for its node name folder to get the cert.
            role: indexer
          node2:
            name: node-2
            ip: "{{ hostvars.wi2.private_ip }}"
            role: indexer
          node3:
            name: node-3
            ip: "{{ hostvars.wi3.private_ip }}"
            role: indexer
          node4:
            name: node-4
            ip: "{{ hostvars.manager.private_ip }}"
            role: wazuh
            node_type: master
          node5:
            name: node-5
            ip: "{{ hostvars.worker.private_ip }}"
            role: wazuh
            node_type: worker
          node6:
            name: node-6
            ip: "{{ hostvars.dashboard.private_ip }}"
            role: dashboard

# Wazuh cluster
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
        wazuh_api_users:
          - username: custom-user
            password: SecretPassword1!
        filebeat_output_indexer_hosts:
                - "{{ hostvars.wi1.private_ip }}"
                - "{{ hostvars.wi2.private_ip }}"
                - "{{ hostvars.wi3.private_ip }}"

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
        filebeat_output_indexer_hosts:
                - "{{ hostvars.wi1.private_ip }}"
                - "{{ hostvars.wi2.private_ip }}"
                - "{{ hostvars.wi3.private_ip }}"

# Indexer + dashboard node
    - hosts: dashboard
      roles:
        - role: "../roles/wazuh/wazuh-indexer"
        - role: "../roles/wazuh/wazuh-dashboard"
      become: yes
      become_user: root
      vars:
        indexer_network_host: "{{ hostvars.dashboard.private_ip }}"
        indexer_node_name: node-6
        indexer_node_master: false
        indexer_node_ingest: false
        indexer_node_data: false
        indexer_cluster_nodes:
            - "{{ hostvars.wi1.private_ip }}"
            - "{{ hostvars.wi2.private_ip }}"
            - "{{ hostvars.wi3.private_ip }}"
        indexer_discovery_nodes:
            - "{{ hostvars.wi1.private_ip }}"
            - "{{ hostvars.wi2.private_ip }}"
            - "{{ hostvars.wi3.private_ip }}"
        dashboard_node_name: node-6
        wazuh_api_credentials:
          - id: default
            url: https://{{ hostvars.manager.private_ip }}
            port: 55000
            username: custom-user
            password: SecretPassword1!
        instances:
          node1:
            name: node-1
            ip: "{{ hostvars.wi1.private_ip }}"   # When unzipping, the node will search for its node name folder to get the cert.
            role: indexer
          node2:
            name: node-2
            ip: "{{ hostvars.wi2.private_ip }}"
            role: indexer
          node3:
            name: node-3
            ip: "{{ hostvars.wi3.private_ip }}"
            role: indexer
          node4:
            name: node-4
            ip: "{{ hostvars.manager.private_ip }}"
            role: wazuh
            node_type: master
          node5:
            name: node-5
            ip: "{{ hostvars.worker.private_ip }}"
            role: wazuh
            node_type: worker
          node6:
            name: node-6
            ip: "{{ hostvars.dashboard.private_ip }}"
            role: dashboard
        ansible_shell_allow_world_readable_temp: true
```

### Inventory file

- The `ansible_host` variable should contain the `address/FQDN` used to gather facts and provision each node.
- The `private_ip` variable should contain the `address/FQDN` used for the internal cluster communications.
- Whether the environment is located in a local subnet, `ansible_host` and `private_ip` variables should match.
- The ssh credentials used by Ansible during the provision can be specified in this file too. Another option is including them directly on the playbook.

```ini
wi1 ansible_host=<wi1_ec2_public_ip> private_ip=<wi1_ec2_private_ip> indexer_node_name=node-1
wi2 ansible_host=<wi2_ec2_public_ip> private_ip=<wi2_ec2_private_ip> indexer_node_name=node-2
wi3 ansible_host=<wi3_ec2_public_ip> private_ip=<wi3_ec2_private_ip> indexer_node_name=node-3
dashboard  ansible_host=<dashboard_node_public_ip> private_ip=<dashboard_ec2_private_ip>
manager ansible_host=<manager_node_public_ip> private_ip=<manager_ec2_private_ip>
worker  ansible_host=<worker_node_public_ip> private_ip=<worker_ec2_private_ip>

[wi_cluster]
wi1
wi2
wi3

[all:vars]
ansible_ssh_user=vagrant
ansible_ssh_private_key_file=/path/to/ssh/key.pem
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
```

### Launching the playbook

```bash
sudo ansible-playbook wazuh-production-ready.yml -i inventory
```

After the playbook execution, the Wazuh UI should be reachable through `https://<dashboard_host>`

## Example: single-host environment

### Playbook

The hereunder example playbook uses the `wazuh-ansible` role to provision a single-host Wazuh environment. This architecture includes all the Wazuh and Opensearch components in a single node.

```yaml
---
# Certificates generation
  - hosts: aio
    roles:
      - role: ../roles/wazuh/wazuh-indexer
        perform_installation: false
    become: no
    #become_user: root
    vars:
      indexer_node_master: true
      instances:
        node1:
          name: node-1       # Important: must be equal to indexer_node_name.
          ip: 127.0.0.1
          role: indexer
    tags:
      - generate-certs
# Single node
  - hosts: aio
    become: yes
    become_user: root
    roles:
      - role: ../roles/wazuh/wazuh-indexer
      - role: ../roles/wazuh/ansible-wazuh-manager
      - role: ../roles/wazuh/ansible-filebeat-oss
      - role: ../roles/wazuh/wazuh-dashboard
    vars:
      single_node: true
      minimum_master_nodes: 1
      indexer_node_master: true
      indexer_network_host: 127.0.0.1
      filebeat_node_name: node-1
      filebeat_output_indexer_hosts:
      - 127.0.0.1
      instances:
        node1:
          name: node-1       # Important: must be equal to indexer_node_name.
          ip: 127.0.0.1
          role: indexer
      ansible_shell_allow_world_readable_temp: true
```

### Inventory file

```ini
[aio]
<your server host>

[all:vars]
ansible_ssh_user=vagrant
ansible_ssh_private_key_file=/path/to/ssh/key.pem
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
```

### Launching the playbook

```bash
sudo ansible-playbook wazuh-single.yml -i inventory
```

After the playbook execution, the Wazuh UI should be reachable through `https://<your server host>`

## Example: Wazuh server cluster (without Filebeat)

### Playbook

The hereunder example playbook uses the `wazuh-ansible` role to provision a Wazuh server cluster without Filebeat. This architecture includes 2 Wazuh servers distributed in two different nodes.

```yaml
---
# Wazuh cluster without Filebeat
    - hosts: manager
      roles:
        - role: "../roles/wazuh/ansible-wazuh-manager"
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
        wazuh_api_users:
          - username: custom-user
            password: SecretPassword1!

    - hosts: worker01
      roles:
        - role: "../roles/wazuh/ansible-wazuh-manager"
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
```

### Inventory file

```ini
[manager]
<your manager master server host>

[worker01]
<your manager worker01 server host>

[all:vars]
ansible_ssh_user=vagrant
ansible_ssh_private_key_file=/path/to/ssh/key.pem
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
```

### Adding additional workers

Add the following block at the end of the playbook

```yaml
    - hosts: worker02
      roles:
        - role: "../roles/wazuh/ansible-wazuh-manager"
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
              node_name: 'worker_02'
              node_type: 'worker'
              key: 'c98b62a9b6169ac5f67dae55ae4a9088'
              nodes:
                  - "{{ hostvars.manager.private_ip }}"
              hidden: 'no'
```

NOTE: `hosts` and `wazuh_manager_config.cluster_node_name` are the only parameters that differ from the `worker01` configuration.

Add the following lines to the inventory file:

```ini
[worker02]
<your manager worker02 server host>
```

### Launching the playbook

```bash
sudo ansible-playbook wazuh-manager-oss-cluster.yml -i inventory
```

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
Copyright (C) 2016, Wazuh Inc.  (License GPLv2)

## Web references

- [Wazuh website](http://wazuh.com)
