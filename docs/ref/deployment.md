# Deployment

## Overview

This guide explains how to deploy Wazuh using Ansible with the `wazuh-ansible` tool. This open-source tool facilitates the automated deployment of Wazuh across various operating systems and architectures ([Compatibility](introduction/compatibility.md)).

Before proceeding, configure your Ansible inventory file (`inventory.ini`) based on the deployment type you intend to perform. For more details on inventory configuration, refer to the [Configuration files](configuration/configuration-files.md) section.

Additionally, ensure you clone the `wazuh-ansible` repository and install the necessary dependencies:

```bash
  git clone --branch v6.0.0 https://github.com/wazuh/wazuh-ansible.git
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
- Wazuh Server
- Wazuh Dashboard

To perform an AIO deployment, use the `wazuh-aio.yml` playbook. This playbook installs and configures all required components on one node.

```bash
  ansible-playbook -i inventory.ini wazuh-aio.yml
```

### Distributed Deployment

A distributed deployment spreads components across multiple nodes for improved scalability and redundancy. The components include:

- Three Wazuh Indexer nodes
- Two Wazuh Server nodes (master and worker)
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
