# Deployment

## Overview

This guide explains how to deploy Wazuh using Ansible with the `wazuh-ansible` tool. This open-source tool facilitates the automated deployment of Wazuh across various operating systems and architectures ([Compatibility](introduction/compatibility.md)).

Before proceeding, configure your Ansible inventory file (`inventory.ini`) based on the deployment type you intend to perform. For more details on inventory configuration, refer to the [Configuration files](configuration/configuration-files.md) section.

Additionally, ensure you clone the `wazuh-ansible` repository and install the necessary dependencies:

```bash
  git clone --branch v5.0.0 https://github.com/wazuh/wazuh-ansible.git
  cd wazuh-ansible
  ansible-galaxy install -r requirements.yml
```

## Deployment Types

Wazuh can be deployed in two primary ways, each tailored to different needs and scales:

- **All-in-One (AIO):** Installs all components on a single node, suitable for small environments or testing purposes.
- **Distributed:** Distributes components across multiple nodes, ideal for larger environments requiring scalability and redundancy.

Additionally, Wazuh Agents can be installed on one or multiple hosts, simplifying security management in diverse environments.

### All-in-One (AIO) Deployment

In an AIO deployment, all components are installed on a single node, including:

- Wazuh Indexer
- Wazuh Manager
- Wazuh Dashboard

To perform an AIO deployment, use the `wazuh-aio.yml` playbook. This playbook installs and configures all required components on one node.

```bash
  ansible-playbook -i inventory.ini wazuh-aio.yml
```

### Distributed Deployment

A distributed deployment spreads components across multiple nodes for improved scalability and redundancy. The components include:

- Three Wazuh Indexer nodes
- Two Wazuh Manager nodes (master and worker)
- One Wazuh Dashboard node

To execute a distributed deployment, use the `wazuh-distributed.yml` playbook, which installs and configures all necessary components across multiple nodes.

```bash
  ansible-playbook -i inventory.ini wazuh-distributed.yml
```

### Wazuh Agent Deployment

For installing Wazuh Agents on one or more hosts, use the `wazuh-agent.yml` playbook. This playbook installs and configures the Wazuh Agent on specified nodes in the inventory.

```bash
  ansible-playbook -i inventory.ini wazuh-agent.yml
```

## Post-Deployment Steps

After deployment, access the Wazuh Dashboard by navigating to `https://<WAZUH_DASHBOARD_IP_ADDRESS>` in your web browser. Use the [default credentials](https://documentation.wazuh.com/current/installation-guide/wazuh-dashboard/step-by-step.html#starting-the-wazuh-dashboard-service) to log in.

### Change the default passwords

The installation assistant sets default passwords for several Wazuh Indexer internal users (some equal to the username) and for the Wazuh server API users (`wazuh`, `wazuh-wui`). Change them right after deployment, using the `wazuh-passwords-tool.sh` script provided by the [Wazuh installation assistant](https://github.com/wazuh/wazuh-installation-assistant).

> **Save every password printed by the tool.** They cannot be recovered afterwards. Use the new `admin` password to log in to the dashboard.

#### AIO deployment

All components (Wazuh Indexer, Wazuh Manager, and Wazuh Dashboard) live on the same node, so a single run of the passwords tool on that node rotates and propagates every password automatically:

```bash
  ssh <aio-node>
  sudo bash wazuh-passwords-tool.sh -a -au wazuh -ap <current-wazuh-api-password>
```

- `-a` (`--change-all`) rotates every reserved Wazuh Indexer user with a random password.
- `-au`/`-ap` additionally rotates the Wazuh server API users `wazuh` and `wazuh-wui` in the same run.
- The tool updates the Wazuh Manager and Wazuh Dashboard keystores and restarts the affected services automatically — no manual step is needed on an AIO node.

#### Distributed deployment

In a distributed deployment, the Wazuh Indexer, Wazuh Manager, and Wazuh Dashboard nodes are separate hosts, so a single `--change-all` run cannot push the new passwords to the Manager/Dashboard keystores automatically — that update only happens for services installed locally on the node running the tool. Complete these steps instead:

1. Run the tool on **one** Wazuh Indexer node to rotate every Wazuh Indexer user:

   ```bash
     ssh <indexer-node-1>
     sudo bash wazuh-passwords-tool.sh -a
   ```

   Save every printed password, in particular the ones for `admin` and `kibanaserver`.

2. On **each** Wazuh Manager node, update the indexer connection password in the keystore with the new value generated for the `wazuh-manager` user, then restart the service:

   ```bash
     ssh <manager-node>
     sudo /var/wazuh-manager/bin/wazuh-manager-keystore -f indexer -k password -v '<new-wazuh-manager-password>'
     sudo systemctl restart wazuh-manager
   ```

3. On the Wazuh Dashboard node, update the `opensearch.password` keystore entry with the new `kibanaserver` password, then restart the service:

   ```bash
     ssh <dashboard-node>
     echo '<new-kibanaserver-password>' | sudo /usr/share/wazuh-dashboard/bin/opensearch-dashboards-keystore --allow-root add -f --stdin opensearch.password
     sudo systemctl restart wazuh-dashboard
   ```

4. To also rotate the Wazuh server API users (`wazuh`, `wazuh-wui`), run the tool a second time on any node where the Wazuh Manager service is reachable, providing the current API admin credentials. `-a` is required together with `-au`/`-ap` — the tool rejects `-au`/`-ap` on their own — but on a node with no Wazuh Indexer installed it only rotates the API users:

   ```bash
     sudo bash wazuh-passwords-tool.sh -a -au wazuh -ap <current-wazuh-api-password>
   ```

> This is a manual, one-time post-deployment step. It is not run automatically by the `wazuh-aio.yml` or `wazuh-distributed.yml` playbooks.
