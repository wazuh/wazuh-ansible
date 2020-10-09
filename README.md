# Wazuh-Ansible 

[![Slack](https://img.shields.io/badge/slack-join-blue.svg)](https://wazuh.com/community/join-us-on-slack/)
[![Email](https://img.shields.io/badge/email-join-blue.svg)](https://groups.google.com/forum/#!forum/wazuh)
[![Documentation](https://img.shields.io/badge/docs-view-green.svg)](https://documentation.wazuh.com)
[![Documentation](https://img.shields.io/badge/web-view-green.svg)](https://wazuh.com)

These playbooks install and configure Wazuh agent, manager and Elastic Stack.

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

## Example custom deploy: Wazuh cluster, ODFE cluster, Kibana 

### Playbook
The hereunder example playbook deploys a complete Wazuh distributed architecture with two Wazuh nodes (master+worker), 3 ODFE nodes and a mixed ODFE and Kibana node.

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
      opendistro_standalone_installation: false
      ansible_ssh_user: centos
      ansible_ssh_private_key_file: /home/zenid/.ssh/core-dev-nv.pem
      ansible_ssh_extra_args: '-o StrictHostKeyChecking=no'
      elasticsearch_node_master: true
      elasticsearch_cluster_name: wazuh
      opendistro_version: 1.10.1
      opendistro_admin_password: T3stP4ssw0rd
      certs_gen_tool_url: https://wazuh-demo.s3-us-west-1.amazonaws.com/search-guard-tlstool-1.7.zip
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
      opendistro_standalone_installation: false
      ansible_ssh_user: centos
      ansible_ssh_private_key_file: /home/zenid/.ssh/core-dev-nv.pem
      ansible_ssh_extra_args: '-o StrictHostKeyChecking=no'
      elasticsearch_node_master: true
      elasticsearch_cluster_name: wazuh
      opendistro_version: 1.10.1
      opendistro_admin_password: T3stP4ssw0rd
      opendistro_custom_user_role: admin
      certs_gen_tool_url: https://wazuh-demo.s3-us-west-1.amazonaws.com/search-guard-tlstool-1.7.zip
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
      ansible_ssh_user: "centos"
      ansible_ssh_private_key_file: /home/zenid/.ssh/core-dev-nv.pem
      ansible_ssh_extra_args: '-o StrictHostKeyChecking=no'
      wazuh_manager_version: 3.13.2
      wazuh_manager_config:
          connection:
          - type: 'secure'
            port: '1514'
            protocol: 'tcp'
            queue_size: 131072
          api:
            port: "55000"
            https: 'yes'
          cluster:
            disable: 'no'
            name: 'wazuh'
            node_name: 'master'
            node_type: 'master'
            key: 'c98b62a9b6169ac5f67dae55ae4a9088'
            port: '1516'
            bind_addr: '0.0.0.0'
            nodes:
                - '"{{ hostvars.manager.private_ip }}"'
            hidden: 'no'
      filebeat_version: 7.9.1
      filebeat_security: true
      elasticsearch_security_user: wazuh
      elasticsearch_security_password: T3stP4ssw0rd
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
        authd:
            enable: false
            port: 1515
            use_source_ip: 'no'
            force_insert: 'yes'
            force_time: 0
            purge: 'yes'
            use_password: 'no'
            limit_maxagents: 'yes'
            ciphers: 'HIGH:!ADH:!EXP:!MD5:!RC4:!3DES:!CAMELLIA:@STRENGTH'
            ssl_agent_ca: null
            ssl_verify_host: 'no'
            ssl_manager_cert: 'sslmanager.cert'
            ssl_manager_key: 'sslmanager.key'
            ssl_auto_negotiate: 'no'
        connection:
            - type: 'secure'
              port: '1514'
              protocol: 'tcp'
              queue_size: 131072
        api:
            port: "55000"
            https: 'yes'
        cluster:
            disable: 'no'
            name: 'wazuh'
            node_name: 'worker_01'
            node_type: 'worker'
            key: 'c98b62a9b6169ac5f67dae55ae4a9088'
            port: '1516'
            bind_addr: '0.0.0.0'
            nodes:
                - '"{{ hostvars.manager.private_ip }}"'
            hidden: 'no'
      ansible_ssh_user: centos
      ansible_ssh_private_key_file: /home/zenid/.ssh/core-dev-nv.pem
      ansible_ssh_extra_args: '-o StrictHostKeyChecking=no'
      wazuh_manager_version: 3.13.2
      filebeat_version: 7.9.1
      filebeat_security: true
      elasticsearch_security_user: wazuh
      elasticsearch_security_password: T3stP4ssw0rd
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
      elasticsearch_jvm_xms: 2560
      elasticsearch_network_host: "{{ hostvars.kibana.private_ip }}"
      elasticsearch_node_name: node-6
      opendistro_kibana_user: wazuh
      opendistro_kibana_password: T3stP4ssw0rd
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
      opendistro_standalone_installation: false
      ansible_ssh_user: centos
      ansible_ssh_private_key_file: /home/zenid/.ssh/core-dev-nv.pem
      ansible_ssh_extra_args: '-o StrictHostKeyChecking=no'
      wazuh_version: 3.13.2
      elastic_stack_version: 7.9.1
      opendistro_version: 1.10.1
      kibana_opendistro_version: -1.10.1-1
      elasticsearch_cluster_name: wazuh
      kibana_opendistro_security: true
      opendistro_admin_password: T3stP4ssw0rd
      opendistro_custom_user: wazuh
      opendistro_custom_user_role: admin
      node_options: "--max-old-space-size=2048"
      certs_gen_tool_url: https://wazuh-demo.s3-us-west-1.amazonaws.com/search-guard-tlstool-1.7.zip
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


### Example inventory file


```ini
es1 ansible_host=<es1_ec2_public_ip> private_ip=<es1_ec2_private_ip> elasticsearch_node_name=node-1
es2 ansible_host=<es2_ec2_public_ip> private_ip=<es2_ec2_private_ip> elasticsearch_node_name=node-2
es3 ansible_host=<es3_ec2_public_ip> private_ip=<es3_ec2_private_ip> elasticsearch_node_name=node-3 opendistro_custom_user=wazuh
kibana ansible_host=<kibana_node_public_ip> private_ip=<kibana_ec2_private_ip>
manager ansible_host=<manager_node_public_ip> private_ip=<manager_ec2_private_ip>
worker ansible_host=<worker_node_public_ip> private_ip=<worker_ec2_private_ip>


[odfe_cluster]
es1
es2
es3
[wui]
kibana
[managers]
manager
worker
```


## Branches

* `stable` branch on correspond to the last Wazuh-Ansible stable version.
* `master` branch contains the latest code, be aware of possible bugs on this branch.

## Testing

1. Get the `wazuh-ansible` folder from the `wazuh-qa` [repository](https://github.com/wazuh/wazuh-qa/tree/master/ansible/wazuh-ansible).

```
git clone https://github.com/wazuh/wazuh-qa
```

2. Copy the `Pipfile` and the `molecule` folder into the root wazuh-ansible directory:

```
cp wazuh-qa/ansible/wazuh-ansible/* . -R
```

3. Follow these steps for launching the tests. Check the Pipfile for running different scenarios:

```
pip install pipenv
sudo pipenv install
pipenv run test
pipenv run agent
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
Copyright (C) 2016-2018 Wazuh Inc.  (License GPLv2)

## Web references

* [Wazuh website](http://wazuh.com)
