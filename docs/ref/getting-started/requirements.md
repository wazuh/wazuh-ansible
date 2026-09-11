# Requirements

Here is a detailed outline of the requirements needed to implement Wazuh using wazuh-ansible. This document serves as a comprehensive guide covering software, hardware, network, and permission requirements to ensure a successful deployment.

**Supported Platforms**: Refer to the [Compatibility](../introduction/compatibility.md) section for detailed information on supported platforms.
**Setup Development Environment**: Refer to the [Set up the development environment](../../dev/setup.md) section for instructions on configuring the development environment for Wazuh Ansible.

## Software Requirements

**Control Node Requirements**:

- **Ansible**: Recomend to install ansible-core version 2.16 or newer.
- **Python**: Use Python version 3.10 or newer.
- **Additional Tools**:
  - Git: Required for cloning the wazuh-ansible repository.
  - SSH: Necessary for connecting to remote servers.
- **Ansible Collections**: Ensure all required Ansible collections listed in the `requirements.yml` file are installed. Use the `ansible-galaxy` command to do so.

  ```bash
  ansible-galaxy install -r requirements.yml
  ```

- **Inventory Configuration**: Create an `inventory.ini` file to list your target hosts.
  - Ensure target nodes are accessible via SSH and have Python installed.
  - Administrative (root) privileges are required on the target nodes to install and configure Wazuh components.
  - Verify connectivity (optional):
    - For Linux/MacOS hosts, use the `ping`module.

      ```bash
        ansible -i inventory.ini all -m ping
      ```

    - For Windows hosts, use the `win_ping` module.

      ```bash
        ansible -i inventory.ini all -m win_ping
      ```

  - Refer to the [Configuration files](../configuration/configuration-files.md) section for more details on how to configure the inventory file.

**Target Node Requirements**:

- **Python**: Python 3.10 or newer.
- **Additional Tools**:
  - For Linux: Ensure SSH is configured and accessible for remote connections.
  - For Windows: Configure and enable the `winrm` service for remote access.

## Hardware and Network Requirements

Depending on the deployment method (AIO or distributed) and the scale of your environment, hardware requirements can vary.

| Deployment Type | Control Nodes | Target Nodes  | Node Roles                                                    |
|-----------------|---------------|---------------|---------------------------------------------------------------|
| AIO             | 1             | 1             | -                                                             |
| Distributed     | 1             | 6             | Wazuh Indexer: 3<br>Wazuh Manager: 2<br>Wazuh Dashboard: 1    |

Refer to the official documentation of each Wazuh component for detailed hardware requirements:

- **Wazuh Indexer**: [Installation Guide](https://documentation.wazuh.com/current/installation-guide/wazuh-indexer/index.html)
- **Wazuh Manager**: [Installation Guide](https://documentation.wazuh.com/current/installation-guide/wazuh-manager/index.html)
- **Wazuh Dashboard**: [Installation Guide](https://documentation.wazuh.com/current/installation-guide/wazuh-dashboard/index.html)
- **Wazuh Agent**: [Installation Guide](https://documentation.wazuh.com/current/installation-guide/wazuh-agent/index.html)

For detailed network requirements, refer to the official Wazuh architecture documentation:

- **Architecture - Required Ports**: [Details Here](https://documentation.wazuh.com/current/getting-started/architecture.html#required-ports)
