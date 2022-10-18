# dashboard

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

## Default Variables

### dashboard_conf_path

#### Default value

```YAML
dashboard_conf_path: /etc/wazuh-dashboard/
```

### dashboard_node_name

#### Default value

```YAML
dashboard_node_name: node-1
```

### dashboard_password

#### Default value

```YAML
dashboard_password: changeme
```

### dashboard_security

#### Default value

```YAML
dashboard_security: true
```

### dashboard_server_host

#### Default value

```YAML
dashboard_server_host: 0.0.0.0
```

### dashboard_server_name

#### Default value

```YAML
dashboard_server_name: dashboard
```

### dashboard_server_port

#### Default value

```YAML
dashboard_server_port: '443'
```

### dashboard_user

#### Default value

```YAML
dashboard_user: kibanaserver
```

### dashboard_version

#### Default value

```YAML
dashboard_version: 4.3.9
```

### indexer_admin_password

#### Default value

```YAML
indexer_admin_password: changeme
```

### indexer_api_protocol

#### Default value

```YAML
indexer_api_protocol: https
```

### indexer_cluster_nodes

#### Default value

```YAML
indexer_cluster_nodes:
  - 127.0.0.1
```

### indexer_http_port

#### Default value

```YAML
indexer_http_port: 9200
```

### local_certs_path

#### Default value

```YAML
local_certs_path: '{{ playbook_dir }}/indexer/certificates'
```

### wazuh_api_credentials

#### Default value

```YAML
wazuh_api_credentials:
  - id: default
    url: https://localhost
    port: 55000
    username: wazuh
    password: wazuh
```

### wazuh_version

#### Default value

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

## Author

Wazuh
