# wazuh-indexer Role

## Description

The `wazuh-indexer` role installs and configures the Wazuh Indexer on the target node.

The role supports both RHEL-based and Debian-based Linux distributions and handles the full installation lifecycle: downloading the package, installing system dependencies, deploying SSL certificates, configuring the node, initializing the indexer security configuration, and verifying that the service is healthy and reachable via its API.

The role can operate in single-node or multi-node cluster configurations, controlled by the `single_node` variable.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml` and `vars/artifact_urls.yaml`. |
| Install dependencies | Installs required system packages via the `dependencies.yml` task file. |
| Install package (RHEL) | Downloads and installs the `.rpm` package using `dnf`. |
| Install package (Debian) | Downloads and installs the `.deb` package using `apt`. |
| Configure node | Applies node-specific settings and deploys SSL certificates via `config_files_setup.yml`. |
| Reload systemd | Reloads the systemd daemon after installation. |
| Start service | Enables and starts the `wazuh-indexer` service. |
| Initialize security | Runs `indexer-security-init.sh` to initialize the indexer cluster security configuration. |
| Verify API | Waits for the Wazuh Indexer REST API to become available on port `9200`. |
| Configure JVM heap | Sets the JVM heap size to one quarter of the host's total RAM. Only applied in AIO deployments (`single_node: true`). |

## Usage

This role is used in the `wazuh-aio.yml` and `wazuh-distributed.yml` playbooks. In a distributed deployment, it is applied to each indexer node in the inventory.

## Related

- [Variables](../variables.md#wazuh-indexer)
- [Deployment](../deployment.md)
