# Ansible Playbook - Wazuh dashboard

Installing, deploying and configuring Wazuh Agent.

## Table of content

- [Default Variables](#default-variables)
  - [dashboard_conf_path](#dashboard_conf_path)
  - [dashboard_node_name](#dashboard_node_name)
  - [dashboard_password](#dashboard_password)
  - [dashboard_security](#dashboard_security)
  - [dashboard_server_host](#dashboard_server_host)
  - [dashboard_server_name](#dashboard_server_name)
  - [dashboard_server_port](#dashboard_server_port)
  - [dashboard_user](#dashboard_user)
  - [dashboard_version](#dashboard_version)
  - [indexer_admin_password](#indexer_admin_password)
  - [indexer_api_protocol](#indexer_api_protocol)
  - [indexer_cluster_nodes](#indexer_cluster_nodes)
  - [indexer_http_port](#indexer_http_port)
  - [local_certs_path](#local_certs_path)
  - [wazuh_api_credentials](#wazuh_api_credentials)
  - [wazuh_version](#wazuh_version)
- [Discovered Tags](#discovered-tags)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## OS Requirements

This role is compatible with:

* Red Hat

* CentOS

* Fedora

* Debian

* Ubuntu



## Default Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):


### dashboard_conf_path

#### Default Value

```YAML
dashboard_conf_path: /etc/wazuh-dashboard/
```

### dashboard_node_name

#### Default Value

```YAML
dashboard_node_name: node-1
```

### dashboard_password

#### Default Value

```YAML
dashboard_password: changeme
```

### dashboard_security

#### Default Value

```YAML
dashboard_security: true
```

### dashboard_server_host

#### Default Value

```YAML
dashboard_server_host: 0.0.0.0
```

### dashboard_server_name

#### Default Value

```YAML
dashboard_server_name: dashboard
```

### dashboard_server_port

#### Default Value

```YAML
dashboard_server_port: '443'
```

### dashboard_user

#### Default Value

```YAML
dashboard_user: kibanaserver
```

### dashboard_version

#### Default Value

```YAML
dashboard_version: 4.3.9
```

### indexer_admin_password

#### Default Value

```YAML
indexer_admin_password: changeme
```

### indexer_api_protocol

#### Default Value

```YAML
indexer_api_protocol: https
```

### indexer_cluster_nodes

#### Default Value

```YAML
indexer_cluster_nodes:
  - 127.0.0.1
```

### indexer_http_port

#### Default Value

```YAML
indexer_http_port: 9200
```

### local_certs_path

#### Default Value

```YAML
local_certs_path: '{{ playbook_dir }}/files/indexer/certificates'
```

### wazuh_api_credentials

#### Default Value

```YAML
wazuh_api_credentials:
  - id: default
    url: https://localhost
    port: 55000
    username: wazuh
    password: wazuh
```

### wazuh_version

#### Default Value

```YAML
wazuh_version: 4.3.9
```

## Discovered Tags

**_configure_**

**_install_**

**_security_**


## Dependencies

None.

## License

license (GPLv3)

# Copyright

WAZUH Copyright (C) 2016, Wazuh Inc.

## Author

Wazuh


### Based on previous work from dj-wasabi

- https://github.com/dj-wasabi/ansible-ossec-server

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
