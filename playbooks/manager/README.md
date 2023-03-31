# Wazuh Collection


## Manager Deployment Playbook


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

[wazuh_manager]

<example.com> ansible_host=<11.11.11.16> ansible_user=root

```

### <span style="color:#5dbaebff">Vars File</span>

**Path:** /path/to/playbook/repo/inventory/group_vars/wazuh_manager/vars.yml

```yaml

filebeat_output_indexer_hosts:

  - "<indexer-node-1>:9200"

  - "<indexer-node-2>:9200"

  - "<indexer-node-2>:9200"

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
