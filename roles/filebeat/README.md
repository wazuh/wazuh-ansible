# Ansible Role: Filebeat for Elastic Stack

An Ansible Role that installs [Filebeat-oss](https://www.elastic.co/products/beats/filebeat), this can be used in conjunction with [ansible-wazuh-manager](https://github.com/wazuh/wazuh-ansible/ansible-wazuh-server).

## Table of content

- [Ansible Role: Filebeat for Elastic Stack](#ansible-role-filebeat-for-elastic-stack)
  - [Table of content](#table-of-content)
  - [Requirements](#requirements)
  - [Default Variables](#default-variables)
    - [filebeat\_module\_destination](#filebeat_module_destination)
      - [Default value](#default-value)
    - [filebeat\_module\_folder](#filebeat_module_folder)
      - [Default value](#default-value-1)
    - [filebeat\_module\_package\_name](#filebeat_module_package_name)
      - [Default value](#default-value-2)
    - [filebeat\_module\_package\_path](#filebeat_module_package_path)
      - [Default value](#default-value-3)
    - [filebeat\_module\_package\_url](#filebeat_module_package_url)
      - [Default value](#default-value-4)
    - [filebeat\_node\_name](#filebeat_node_name)
      - [Default value](#default-value-5)
    - [filebeat\_output\_indexer\_hosts](#filebeat_output_indexer_hosts)
      - [Default value](#default-value-6)
    - [filebeat\_security](#filebeat_security)
      - [Default value](#default-value-7)
    - [filebeat\_ssl\_dir](#filebeat_ssl_dir)
      - [Default value](#default-value-8)
    - [filebeat\_version](#filebeat_version)
      - [Default value](#default-value-9)
    - [filebeatrepo](#filebeatrepo)
      - [Default value](#default-value-10)
    - [indexer\_security\_password](#indexer_security_password)
      - [Default value](#default-value-11)
    - [indexer\_security\_user](#indexer_security_user)
      - [Default value](#default-value-12)
    - [local\_certs\_path](#local_certs_path)
      - [Default value](#default-value-13)
    - [wazuh\_template\_branch](#wazuh_template_branch)
      - [Default value](#default-value-14)
  - [Discovered Tags](#discovered-tags)
  - [Dependencies](#dependencies)
  - [License and copyright](#license-and-copyright)
    - [Based on previous work from geerlingguy](#based-on-previous-work-from-geerlingguy)
    - [Modified by Wazuh](#modified-by-wazuh)

---

Requirements
------------

This role will work on:
 * Red Hat
 * CentOS
 * Fedora
 * Debian
 * Ubuntu

## Default Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

### filebeat_module_destination

#### Default value

```YAML
filebeat_module_destination: /usr/share/filebeat/module
```

### filebeat_module_folder

#### Default value

```YAML
filebeat_module_folder: /usr/share/filebeat/module/wazuh
```

### filebeat_module_package_name

#### Default value

```YAML
filebeat_module_package_name: wazuh-filebeat-0.2.tar.gz
```

### filebeat_module_package_path

#### Default value

```YAML
filebeat_module_package_path: /tmp/
```

### filebeat_module_package_url

#### Default value

```YAML
filebeat_module_package_url: https://packages.wazuh.com/4.x/filebeat
```

### filebeat_node_name

#### Default value

```YAML
filebeat_node_name: node-1
```

### filebeat_output_indexer_hosts

#### Default value

```YAML
filebeat_output_indexer_hosts:
  - localhost:9200
```

### filebeat_security

#### Default value

```YAML
filebeat_security: true
```

### filebeat_ssl_dir

#### Default value

```YAML
filebeat_ssl_dir: /etc/pki/filebeat
```

### filebeat_version

#### Default value

```YAML
filebeat_version: 7.10.2
```

### filebeatrepo

#### Default value

```YAML
filebeatrepo:
  apt: deb https://packages.wazuh.com/4.x/apt/ stable main
  yum: https://packages.wazuh.com/4.x/yum/
  gpg: https://packages.wazuh.com/key/GPG-KEY-WAZUH
  key_id: 0DCFCA5547B19D2A6099506096B3EE5F29111145
```

### indexer_security_password

#### Default value

```YAML
indexer_security_password: changeme
```

### indexer_security_user

#### Default value

```YAML
indexer_security_user: admin
```

### local_certs_path

#### Default value

```YAML
local_certs_path: '{{ playbook_dir }}/indexer/certificates'
```

### wazuh_template_branch

#### Default value

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

## License and copyright

WAZUH Copyright (C) 2016, Wazuh Inc. (License GPLv3)

### Based on previous work from geerlingguy

 - https://github.com/geerlingguy/ansible-role-filebeat

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
