# Ansible Role - Filebeat for Elastic Stack

An Ansible Role that installs [Filebeat-oss](https://www.elastic.co/products/beats/filebeat), this can be used in conjunction with [ansible-wazuh-manager](https://github.com/wazuh/wazuh-ansible/ansible-wazuh-server).

## Table of content

- [Default Variables](#default-variables)
  - [filebeat_module_destination](#filebeat_module_destination)
  - [filebeat_module_folder](#filebeat_module_folder)
  - [filebeat_module_package_name](#filebeat_module_package_name)
  - [filebeat_module_package_path](#filebeat_module_package_path)
  - [filebeat_module_package_url](#filebeat_module_package_url)
  - [filebeat_node_name](#filebeat_node_name)
  - [filebeat_output_indexer_hosts](#filebeat_output_indexer_hosts)
  - [filebeat_security](#filebeat_security)
  - [filebeat_ssl_dir](#filebeat_ssl_dir)
  - [filebeat_version](#filebeat_version)
  - [filebeatrepo](#filebeatrepo)
  - [indexer_security_password](#indexer_security_password)
  - [indexer_security_user](#indexer_security_user)
  - [local_certs_path](#local_certs_path)
  - [wazuh_template_branch](#wazuh_template_branch)
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


### filebeat_module_destination

#### Default Value

```YAML
filebeat_module_destination: /usr/share/filebeat/module
```

### filebeat_module_folder

#### Default Value

```YAML
filebeat_module_folder: /usr/share/filebeat/module/wazuh
```

### filebeat_module_package_name

#### Default Value

```YAML
filebeat_module_package_name: wazuh-filebeat-0.2.tar.gz
```

### filebeat_module_package_path

#### Default Value

```YAML
filebeat_module_package_path: /tmp/
```

### filebeat_module_package_url

#### Default Value

```YAML
filebeat_module_package_url: https://packages.wazuh.com/4.x/filebeat
```

### filebeat_node_name

#### Default Value

```YAML
filebeat_node_name: node-1
```

### filebeat_output_indexer_hosts

#### Default Value

```YAML
filebeat_output_indexer_hosts:
  - localhost:9200
```

### filebeat_security

#### Default Value

```YAML
filebeat_security: true
```

### filebeat_ssl_dir

#### Default Value

```YAML
filebeat_ssl_dir: /etc/pki/filebeat
```

### filebeat_version

#### Default Value

```YAML
filebeat_version: 7.10.2
```

### filebeatrepo

#### Default Value

```YAML
filebeatrepo:
  apt: deb https://packages.wazuh.com/4.x/apt/ stable main
  yum: https://packages.wazuh.com/4.x/yum/
  gpg: https://packages.wazuh.com/key/GPG-KEY-WAZUH
  key_id: 0DCFCA5547B19D2A6099506096B3EE5F29111145
```

### indexer_security_password

#### Default Value

```YAML
indexer_security_password: changeme
```

### indexer_security_user

#### Default Value

```YAML
indexer_security_user: admin
```

### local_certs_path

#### Default Value

```YAML
local_certs_path: '{{ playbook_dir }}/files/indexer/certificates'
```

### wazuh_template_branch

#### Default Value

```YAML
wazuh_template_branch: 4.3
```

## Discovered Tags

**_configure_**

**_init_**

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


### Based on previous work from geerlingguy

- https://github.com/geerlingguy/ansible-role-filebeat

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
