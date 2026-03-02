# Configuration Files

## Inventory File

Here is an example of an inventory file that can be used to deploy Wazuh with Ansible. This file defines the nodes, their respective IP addresses, and the necessary variables for connection.

### Inventory file for AIO deployment

For an All-in-One (AIO) deployment, the inventory file specifies a single node with its public and private IP addresses, along with the required connection variables.

```ini
[aio]
aio_node ansible_host=<aio_public_ip> private_ip=<aio_private_ip>

[aio:vars]
ansible_user=vagrant
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_ssh_private_key_file=/path/to/key.pem
```

### Inventory file for Distributed deployment

For a distributed deployment, the inventory file specifies multiple nodes, each with its public IP address (or FQDN) and private IP address. This setup includes:

- `wi1`, `wi2`, `wi3`: Wazuh Indexer nodes
- `manager`, `worker`: Wazuh Managers.
- `dashboard`: Wazuh Dashboard.

Each entry defines the required connection details, allowing Ansible to efficiently manage and configure the environment. Ensure that node names remain consistent with those used in the documentation's inventory examples.

```ini
[all]
wi1 ansible_host=<indexer1_public_ip> private_ip=<indexer1_private_ip>
wi2 ansible_host=<indexer2_public_ip> private_ip=<indexer2_private_ip>
wi3 ansible_host=<indexer3_public_ip> private_ip=<indexer3_private_ip>
manager ansible_host=<manager_public_ip> private_ip=<manager_private_ip>
worker ansible_host=<worker_public_ip> private_ip=<worker_private_ip>
dashboard ansible_host=<dashboard_public_ip> private_ip=<dashboard_private_ip>

[wi_cluster]
wi1
wi2
wi3

[all:vars]
ansible_user=vagrant
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_ssh_private_key_file=/path/to/private_key.pem
```

### Inventory file for Wazuh Agent deployment

Deploying Wazuh Agents using Ansible requires an inventory file that lists all target hosts where the agents will be installed. Take the following example as a reference:

```ini
[agents]
agent_linux_1 ansible_host=<agent1_ip>
agent_linux_2 ansible_host=<agent2_ip>
agent_windows ansible_host=<windows_agent_ip> ansible_user=<windows_agent_user> ansible_password=<windows_agent_password> ansible_connection=winrm ansible_port=5986 ansible_winrm_server_cert_validation=ignore

[agents:vars]
ansible_user=vagrant
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_ssh_private_key_file=/path/to/private_key.pem
```

## Playbook Configuration

For more information on the deployment procedure refer to the [Deployment](../deployment.md) section.

### AIO Deployment Playbook

The AIO deployment playbook is preconfigured with default values, requiring only the inventory file to be defined for deployment.

The playbook `wazuh-aio.yml` includes:

- **Wazuh Indexer Role**: Manages configuration and certificate creation for each node, deploying a single Wazuh Indexer instance.
- **Wazuh Manager Role**: Sets up a Wazuh manager instance and establishes its connection to the Wazuh Indexer node.
- **Wazuh Dashboard Role**: Installs the Wazuh Dashboard on the same node and configures connections to both the Wazuh Indexer and Wazuh Manager nodes.

### Distributed Deployment Playbook

The distributed deployment playbook comes preconfigured with default values tailored to the following setup:

- Three Wazuh Indexer nodes (`wi1`, `wi2`, `wi3`) forming a cluster.
- Two Wazuh Manager nodes (`manager` and `worker`).
- A Wazuh Dashboard node (`dashboard`).

The playbook `wazuh-distributed.yml` includes:

- Wazuh Indexer role: Handles the configuration and certificate generation for each node.
- Wazuh Manager role:
  - Configures the `manager` and `worker` nodes and their connectivity to the Indexer nodes.
  - When customizing the `instances` section in `wazuh-distributed.yml`, set `role: manager` for both manager and worker nodes, and use `node_type: master` or `node_type: worker` as needed.
- Wazuh Dashboard role: Configures connectivity to both the Wazuh Indexer and Wazuh Manager nodes.

### Wazuh Agent Deployment Playbook

The Wazuh Agent deployment playbook is designed to install and configure the Wazuh agent service on multiple hosts. This playbook supports Linux, MacOS and Windows systems. Check the [Requirements](../getting-started/requirements.md) section for further details.

The playbook `wazuh-agent.yml` includes:

- **Wazuh Agent Role**: Installs and configures the Wazuh agent on each host and enrolls to the Wazuh Manager node.
- **Package URLs Role**: Manages package sources for agent installation.

**Important:**
Before running the playbook, edit the `wazuh-agent.yml` file and replace `<Your Wazuh Manager IP>` with the actual IP address of your Wazuh Manager node.
