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

The deployment playbooks generate the certificates on the control node with `wazuh-certs-tool.sh`, which must run as root. The user running `ansible-playbook` therefore needs `sudo` on the control node: add `-K` (`--ask-become-pass`) to the commands below if `sudo` asks for a password. See [Credentials and certificates](#credentials-and-certificates).

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

## Credentials and certificates

The Wazuh Indexer, Wazuh Manager, and Wazuh Dashboard packages create their credentials and certificates when they are installed, from what they find on the host. The deployment playbooks prepare them on the control node and hand each host what its component needs **before** its package is installed, so no component uses a default password.

### Passwords

The playbooks generate one password per account for the whole deployment, the first time they run:

| Key | Account | Hosts that receive it |
|-----|---------|-----------------------|
| `WAZUH_INDEXER_ADMIN_PASSWORD` | `admin` (Wazuh Indexer; Wazuh Dashboard login) | Wazuh Indexer |
| `WAZUH_INDEXER_KIBANASERVER_PASSWORD` | `kibanaserver` (Wazuh Indexer) | Wazuh Indexer, Wazuh Dashboard |
| `WAZUH_INDEXER_MANAGER_PASSWORD` | `wazuh-manager` (Wazuh Indexer) | Wazuh Indexer, Wazuh Manager |
| `WAZUH_MANAGER_API_PASSWORD` | `wazuh` (Wazuh server API) | Wazuh Manager |
| `WAZUH_MANAGER_WUI_PASSWORD` | `wazuh-wui` (Wazuh server API) | Wazuh Manager, Wazuh Dashboard |

- On the control node, they are kept in `deployment-credentials/`, next to the playbook, one file per key. Every later run reuses them.
- On each host, only the keys its component reads are written to `/etc/wazuh/credentials.env` (`root:root`, `0600`). The package reads them when it is installed.
- To supply your own values instead, for example from Ansible Vault, set `wazuh_credentials_overrides`. They must follow the password policy of the packages. See [Variables](variables.md#wazuh-credentials).

No task prints a password.

### Certificates

The playbooks create one root CA for the whole deployment, and one certificate pair for each node, with `wazuh-certs-tool.sh` on the control node.

- The root CA and its private key stay in `/etc/wazuh/ca` **of the control node** (`wazuh_certs_ca_dir`). The private key never leaves that directory.
- The node certificates are kept in `deployment-config-files/wazuh-certificates/`, next to the playbook.
- Each host receives the root CA certificate and its own pair before its package is installed. The package uses them and creates nothing.

### What to keep

`deployment-credentials/`, `deployment-config-files/` and, on the control node, `/etc/wazuh/ca` belong to the deployment. Back them up and do not commit them: `deployment-credentials/` and `deployment-config-files/` are in `.gitignore`.

### Running a playbook again

Running the same playbook again, from the same directory, keeps the passwords, the root CA, and the certificates. The packages do not create their credentials again.

A host that already holds the root CA or the passwords of another deployment is refused before anything is written. This happens, for example, when the playbook runs from another directory, or after `deployment-credentials/` was removed. To deploy again from scratch, remove `/etc/wazuh` from the hosts, and `deployment-credentials/`, `deployment-config-files/` and `/etc/wazuh/ca` from the control node.

## Post-Deployment Steps

After deployment, access the Wazuh Dashboard by navigating to `https://<WAZUH_DASHBOARD_IP_ADDRESS>` in your web browser. Log in as `admin`, with the password in `deployment-credentials/WAZUH_INDEXER_ADMIN_PASSWORD` on the control node:

```bash
  cat deployment-credentials/WAZUH_INDEXER_ADMIN_PASSWORD
```

### Change the passwords

The deployment playbooks do not rotate passwords. To change them, use the `wazuh-passwords-tool.sh` script of the [Wazuh installation assistant](https://github.com/wazuh/wazuh-installation-assistant), following its documentation. In a distributed deployment it changes the users of the components on the host where it runs; its documentation lists the keystores to update on the other nodes.

The tool writes the new value only to `/etc/wazuh/credentials.env` of the host where it runs. `deployment-credentials/` on the control node, and `credentials.env` on the other hosts, keep the previous values. Running the deployment playbooks again after a password change is not supported yet.
