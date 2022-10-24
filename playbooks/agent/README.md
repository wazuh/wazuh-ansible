# Wazuh Collection


## Agent Deployment Playbook


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

[wazuh_agent]

<ost.example.com> ansible_host=<11.11.11.11> ansible_user=root

```

### <span style="color:#5dbaebff">Vars File</span>

**Path:** /path/to/playbook/repo/inventory/group_vars/wazuh_agent/vars.yml

```yaml

wazuh_managers:

- address: <your manager IP>

port: 1514

protocol: tcp

api_port: 55000

api_proto: "http"

api_user: ansible

max_retries: 5

retry_interval: 5

```

### <span style="color:#5dbaebff">Setup</span>

1. Install collection

```bash

ansible-galaxy collection install https://github.com/atcommander/wazuh.git

```

2. Setup Inventory folder and Vars and Hosts files

3. Run Ansible Playbook to Prepare Server

```bash

ansible-playbook -i inventory/hosts wazuh.wazuh.agent.install --tags "setup-all"

```




## <span style="color:#5dbaebff">Dependencies</span>

None.
