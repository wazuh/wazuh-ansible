# wazuh-indexer Role

## Description

The `wazuh-indexer` role installs and configures the Wazuh Indexer on the target node.

The role supports both RHEL-based and Debian-based Linux distributions and handles the full installation lifecycle: providing the node's credentials and, in a distributed deployment, its certificates issued on the control node before the package is installed, installing the package, configuring the node, initializing the indexer security configuration, and verifying that the service is healthy and reachable via its API.

The role can operate in single-node or multi-node cluster configurations, controlled by the `single_node` variable.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml` and `vars/artifact_urls.yaml`. |
| Install dependencies | Installs required system packages via the `dependencies.yml` task file. |
| Provide credentials and CA | Runs the [`wazuh-credentials`](wazuh-credentials.md) role: the indexer keys and `WAZUH_INDEXER_CERT_SANS` (the node name, the host name and `private_ip`) in `/etc/wazuh-indexer/local.env`, and, in a distributed deployment, the CA certificate in `/etc/wazuh-indexer/ca/` and the node and `admin` pairs issued on the control node in `/etc/wazuh-indexer/certs/`. All-in-One, the package mints its CA and issues them. |
| Verify package signature | Checks that the downloaded package is signed with the Wazuh GPG key before it is installed, with `verify_package_signature.yml` from the [package-urls](package-urls.md) role. |
| Install package (RHEL) | Downloads and installs the `.rpm` package using `dnf`. |
| Install package (Debian) | Downloads and installs the `.deb` package using `apt`. |
| Configure node | Applies node-specific settings via `config_files_setup.yml`, including `plugins.security.nodes_dn` with the DN of every indexer node, read from the certificate the package issued on that node. |
| Reload systemd | Reloads the systemd daemon after installation. |
| Start service | Starts the `wazuh-indexer` service and checks that it stays active, with `start_service.yml` from the [`wazuh-credentials`](wazuh-credentials.md) role. |
| Initialize security | Runs `indexer-security-init.sh` once, from one indexer node, to load the security configuration into a new cluster. It is skipped when a node of the play already reports it loaded (`/_plugins/_security/health`), so a rerun, or the addition of a node, keeps the users, roles and passwords changed later. Set `wazuh_indexer_security_init_force` to load it again. |
| Verify API | Waits for the Wazuh Indexer REST API on port `9200`, authenticating as `admin` with the password the package published. |
| Configure JVM heap | Sets the JVM heap size to one quarter of the host's total RAM in AIO deployments (`single_node: true`), and to half of it on a dedicated indexer node, unless `wazuh_indexer_heap_size` is set. |

## Certificates

In a distributed deployment, the node certificate (`certs/indexer.pem`, `CN=<node name>`) and the `admin` certificate are issued on the control node from the CA of the deployment and staged before the package is installed; All-in-One, the package issues them, with the host name of the node as subject. Either way, the role reads the DN of every node from its certificate after the installation, and writes the whole list in `plugins.security.nodes_dn` on every node.

## Usage

This role is used in the `wazuh-aio.yml` and `wazuh-distributed.yml` playbooks. In a distributed deployment, it is applied to each indexer node in the inventory.

## Related

- [Variables](../variables.md#wazuh-indexer)
- [wazuh-credentials](wazuh-credentials.md)
- [Deployment](../deployment.md#credentials-and-certificates)
