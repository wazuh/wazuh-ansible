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

For a distributed deployment, the inventory file defines multiple nodes, including Wazuh Indexers, Wazuh Servers, a load balancer, and a dashboard, along with their respective IP addresses and roles.

- Nodes:
  - `wi1`, `wi2`, `wi3`: Wazuh Indexers forming a cluster.
  - `manager`, `worker`: Wazuh Servers.
  - `balancer`: Load balancer for distributing requests.
  - `dashboard`: Wazuh Dashboard.

```ini
[all]
wi1 ansible_host=<indexer1_public_ip> private_ip=<indexer1_private_ip>
wi2 ansible_host=<indexer2_public_ip> private_ip=<indexer2_private_ip>
wi3 ansible_host=<indexer3_public_ip> private_ip=<indexer3_private_ip>
manager ansible_host=<manager_public_ip> private_ip=<manager_private_ip>
worker ansible_host=<worker_public_ip> private_ip=<worker_private_ip>
balancer ansible_host=<balancer_public_ip> private_ip=<balancer_private_ip>
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

## Playbook Configuration

### AIO Deployment Playbook

The AIO deployment playbook is preconfigured with default values, requiring only the inventory file to be defined for deployment.

The playbook `wazuh-aio.yml` includes:

- **Wazuh Indexer Role**: Manages configuration and certificate creation for each node, deploying a single Wazuh Indexer instance.
- **Wazuh Server Role**: Sets up a `server` instance and establishes its connection to the Indexer.
- **Wazuh Dashboard Role**: Installs the Wazuh Dashboard on the same node and configures connections to both the Wazuh Indexer and Wazuh Server nodes.

### Distributed Deployment Playbook

The distributed deployment playbook comes preconfigured with default values tailored to the following setup:

- Three Wazuh Indexer nodes (`wi1`, `wi2`, `wi3`) forming a cluster.
- Two Wazuh Server nodes (`manager` and `worker`).
- An Nginx load balancer node (`balancer`) to distribute requests among the Wazuh Servers.
- A Wazuh Dashboard node (`dashboard`).

The playbook `wazuh-distributed.yml` includes:

- Wazuh Indexer role: Handles the configuration and certificate generation for each node.
- Wazuh Server role:
  - Configures the `manager` and `worker` nodes and their connectivity to the Indexer nodes.
  - Configures the load balancer and its connectivity to the Wazuh Server nodes.
- Wazuh Dashboard role: Configures connectivity to both the Wazuh Indexer and Wazuh Server nodes.
