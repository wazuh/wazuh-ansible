# Wazuh Collection


## All in One Deployment Playbook


</br>
</br>


## <span style="color:#5dbaebff">Table of content</span>

- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## <span style="color:#5dbaebff">Examples</span>

### <span style="color:#5dbaebff">Host File</span>

```ini

[wazuh_aio]

<ost.example.com> ansible_host=<11.11.11.11> ansible_user=root

```

### <span style="color:#5dbaebff">Vars File</span>

**Path:** /path/to/playbook/repo/inventory/group_vars/wazuh_aio/vars.yml

```yaml

#### Indexer

single_node: true

minimum_master_nodes: 1

indexer_network_host: 127.0.0.1

indexer_node_master: true

instances:

node1:

  name: node-1 # Important: must be equal to indexer_node_name.

  ip: 127.0.0.1

  role: indexer

#### Filebeat

filebeat_node_name: node-1

filebeat_output_indexer_hosts:

  - 127.0.0.1

ansible_shell_allow_world_readable_temp: true

#### Manager

## Alerts

wazuh_manager_log_level: 3

wazuh_manager_email_level: 12

## Email

wazuh_manager_email_notification: "no"

wazuh_manager_mailto:

  - "admin@example.net"

wazuh_manager_email_smtp_server: smtp.example.wazuh.com

wazuh_manager_email_from: wazuh@example.wazuh.com

wazuh_manager_email_maxperhour: 12

wazuh_manager_email_queue_size: 131072

wazuh_manager_email_log_source: "alerts.log"

wazuh_manager_extra_emails:

  - enable: false

    mail_to: "recipient@example.wazuh.com"

    format: full

    level: 7

    event_location: null

    group: null

    do_not_delay: false

    do_not_group: false

    rule_id: null

wazuh_manager_reports:

  - enable: false

    category: "syscheck"

    title: "Daily report: File changes"

    email_to: "recipient@example.wazuh.com"

    location: null

    group: null

    rule: null

    level: null

    srcip: null

    user: null

    showlogs: null

```

### <span style="color:#5dbaebff">Setup</span>

1. Install collection

```bash

ansible-galaxy collection install https://github.com/atcommander/wazuh.git

```

2. Setup Inventory folder and Vars and Hosts files

3. Run Ansible Playbook to Prepare Server

```bash

ansible-playbook -i inventory/hosts wazuh.wazuh.aio.install --tags "setup-all"

```




## <span style="color:#5dbaebff">Dependencies</span>

None.
