# Change Log
All notable changes to this project will be documented in this file.

## [v3.7.0]

### Added

- Amazon Linux deployments are now supported ([#71](https://github.com/wazuh/wazuh-ansible/pull/71)) and for the old repository structure ([#67](https://github.com/wazuh/wazuh-ansible/pull/67))

### Changed

- Repository restructure.

### Fixed

- Fix oracle java cookie ([#71](https://github.com/wazuh/wazuh-ansible/pull/71)).

### Removed


## [v3.6.0]

Ansible starting point.

Roles:
 - Elastic Stack:
   - ansible-elasticsearch: This role is prepared to install elasticsearch on the host that runs it. 
   - ansible-logstash: This role involves the installation of logstash on the host that runs it. 
   - ansible-kibana: Using this role we will install Kibana on the host that runs it. 
 - Wazuh: 
   - ansible-filebeat: This role is prepared to install filebeat on the host that runs it. 
   - ansible-wazuh-manager: With this role we will install Wazuh manager and Wazuh API on the host that runs it.
   - ansible-wazuh-agent: Using this role we will install Wazuh agent on the host that runs it and is able to register it. 

