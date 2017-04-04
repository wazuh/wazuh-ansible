# Ansible Role: Elasticsearch


An Ansible Role that installs Kibana and WazuhAPP  on RedHat/CentOS.

## Requirements

Requires at least Java 8 (Java 8+ preferred).

## Role Variables
Available variables are listed below, along with default values (see `vars/main.yml`):

    elasticsearch_network_host: localhost

Network host to listen for incoming connections on. By default we only listen on the localhost interface. Change this to the IP address to listen on a specific interface, or `0.0.0.0` to listen on all interfaces.

    elasticsearch_http_port: 9200

Whether to allow inline scripting against ElasticSearch. You should read the following link as there are possible security implications for enabling these options: [Enable Dynamic Scripting](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-scripting.html#enable-dynamic-scripting). Available options include: `true`, `false`, and `sandbox`.



## Example Playbook

    - hosts: search
      roles:
        - geerlingguy.java
        - geerlingguy.elasticsearch

## License

MIT / BSD

## Author Information

This role was created in 2014 by [Jeff Geerling](https://www.jeffgeerling.com/), author of [Ansible for DevOps](https://www.ansiblefordevops.com/).

## Modified

The playbooks have been modified by Wazuh, Inc, including some specific requirements, templates and configuration for integrating Elastic Stack and Wazuh ecosystem.
