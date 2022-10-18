# indexer

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

## Default Variables

### dashboard_password

#### Default value

```YAML
dashboard_password: changeme
```

### domain_name

#### Default value

```YAML
domain_name: wazuh.com
```

### generate_certs

#### Default value

```YAML
generate_certs: true
```

### indexer_admin_password

#### Default value

```YAML
indexer_admin_password: changeme
```

### indexer_cluster_name

#### Default value

```YAML
indexer_cluster_name: wazuh
```

### indexer_cluster_nodes

#### Default value

```YAML
indexer_cluster_nodes:
  - 127.0.0.1
```

### indexer_conf_path

#### Default value

```YAML
indexer_conf_path: /etc/wazuh-indexer/
```

### indexer_custom_user

#### Default value

```YAML
indexer_custom_user: ''
```

### indexer_custom_user_role

#### Default value

```YAML
indexer_custom_user_role: admin
```

### indexer_discovery_nodes

#### Default value

```YAML
indexer_discovery_nodes:
  - 127.0.0.1
```

### indexer_http_port

#### Default value

```YAML
indexer_http_port: 9200
```

### indexer_index_path

#### Default value

```YAML
indexer_index_path: /var/lib/wazuh-indexer/
```

### indexer_jvm_xms

#### Default value

```YAML
indexer_jvm_xms:
```

### indexer_network_host

#### Default value

```YAML
indexer_network_host: 0.0.0.0
```

### indexer_node_data

#### Default value

```YAML
indexer_node_data: true
```

### indexer_node_ingest

#### Default value

```YAML
indexer_node_ingest: true
```

### indexer_node_master

#### Default value

```YAML
indexer_node_master: true
```

### indexer_node_name

#### Default value

```YAML
indexer_node_name: node-1
```

### indexer_nolog_sensible

#### Default value

```YAML
indexer_nolog_sensible: true
```

### indexer_sec_plugin_conf_path

#### Default value

```YAML
indexer_sec_plugin_conf_path: /usr/share/wazuh-indexer/plugins/opensearch-security/securityconfig
```

### indexer_sec_plugin_tools_path

#### Default value

```YAML
indexer_sec_plugin_tools_path: /usr/share/wazuh-indexer/plugins/opensearch-security/tools
```

### indexer_start_timeout

#### Default value

```YAML
indexer_start_timeout: 90
```

### indexer_version

#### Default value

```YAML
indexer_version: 4.3.9
```

### local_certs_path

#### Default value

```YAML
local_certs_path: '{{ playbook_dir }}/indexer/certificates'
```

### minimum_master_nodes

#### Default value

```YAML
minimum_master_nodes: 2
```

### perform_installation

#### Default value

```YAML
perform_installation: true
```

### single_node

#### Default value

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

## Author

Wazuh
