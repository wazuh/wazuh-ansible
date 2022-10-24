# Ansible Playbook - Wazuh indexer

Installing and maintaining Wazuh indexer.

## Table of content

- [Default Variables](#default-variables)
  - [dashboard_password](#dashboard_password)
  - [domain_name](#domain_name)
  - [generate_certs](#generate_certs)
  - [indexer_admin_password](#indexer_admin_password)
  - [indexer_cluster_name](#indexer_cluster_name)
  - [indexer_cluster_nodes](#indexer_cluster_nodes)
  - [indexer_conf_path](#indexer_conf_path)
  - [indexer_custom_user](#indexer_custom_user)
  - [indexer_custom_user_role](#indexer_custom_user_role)
  - [indexer_discovery_nodes](#indexer_discovery_nodes)
  - [indexer_http_port](#indexer_http_port)
  - [indexer_index_path](#indexer_index_path)
  - [indexer_jvm_xms](#indexer_jvm_xms)
  - [indexer_network_host](#indexer_network_host)
  - [indexer_node_data](#indexer_node_data)
  - [indexer_node_ingest](#indexer_node_ingest)
  - [indexer_node_master](#indexer_node_master)
  - [indexer_node_name](#indexer_node_name)
  - [indexer_nolog_sensible](#indexer_nolog_sensible)
  - [indexer_sec_plugin_conf_path](#indexer_sec_plugin_conf_path)
  - [indexer_sec_plugin_tools_path](#indexer_sec_plugin_tools_path)
  - [indexer_start_timeout](#indexer_start_timeout)
  - [indexer_version](#indexer_version)
  - [local_certs_path](#local_certs_path)
  - [minimum_master_nodes](#minimum_master_nodes)
  - [perform_installation](#perform_installation)
  - [single_node](#single_node)
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


### dashboard_password

#### Default Value

```YAML
dashboard_password: changeme
```

### domain_name

#### Default Value

```YAML
domain_name: wazuh.com
```

### generate_certs

#### Default Value

```YAML
generate_certs: true
```

### indexer_admin_password

#### Default Value

```YAML
indexer_admin_password: changeme
```

### indexer_cluster_name

#### Default Value

```YAML
indexer_cluster_name: wazuh
```

### indexer_cluster_nodes

#### Default Value

```YAML
indexer_cluster_nodes:
  - 127.0.0.1
```

### indexer_conf_path

#### Default Value

```YAML
indexer_conf_path: /etc/wazuh-indexer/
```

### indexer_custom_user

#### Default Value

```YAML
indexer_custom_user: ''
```

### indexer_custom_user_role

#### Default Value

```YAML
indexer_custom_user_role: admin
```

### indexer_discovery_nodes

#### Default Value

```YAML
indexer_discovery_nodes:
  - 127.0.0.1
```

### indexer_http_port

#### Default Value

```YAML
indexer_http_port: 9200
```

### indexer_index_path

#### Default Value

```YAML
indexer_index_path: /var/lib/wazuh-indexer/
```

### indexer_jvm_xms

#### Default Value

```YAML
indexer_jvm_xms:
```

### indexer_network_host

#### Default Value

```YAML
indexer_network_host: 0.0.0.0
```

### indexer_node_data

#### Default Value

```YAML
indexer_node_data: true
```

### indexer_node_ingest

#### Default Value

```YAML
indexer_node_ingest: true
```

### indexer_node_master

#### Default Value

```YAML
indexer_node_master: true
```

### indexer_node_name

#### Default Value

```YAML
indexer_node_name: node-1
```

### indexer_nolog_sensible

#### Default Value

```YAML
indexer_nolog_sensible: true
```

### indexer_sec_plugin_conf_path

#### Default Value

```YAML
indexer_sec_plugin_conf_path: /usr/share/wazuh-indexer/plugins/opensearch-security/securityconfig
```

### indexer_sec_plugin_tools_path

#### Default Value

```YAML
indexer_sec_plugin_tools_path: /usr/share/wazuh-indexer/plugins/opensearch-security/tools
```

### indexer_start_timeout

#### Default Value

```YAML
indexer_start_timeout: 90
```

### indexer_version

#### Default Value

```YAML
indexer_version: 4.3.9
```

### local_certs_path

#### Default Value

```YAML
local_certs_path: '{{ playbook_dir }}/files/indexer/certificates'
```

### minimum_master_nodes

#### Default Value

```YAML
minimum_master_nodes: 2
```

### perform_installation

#### Default Value

```YAML
perform_installation: true
```

### single_node

#### Default Value

```YAML
single_node: false
```

## Discovered Tags

**_configure_**

**_debug_**

**_generate-certs_**

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
