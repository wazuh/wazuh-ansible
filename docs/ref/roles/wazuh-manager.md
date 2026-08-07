# wazuh-manager Role

## Description

The `wazuh-manager` role installs and configures the Wazuh Manager on the target node.

The role supports both RHEL-based and Debian-based Linux distributions. It handles downloading the appropriate package for the target architecture, installing it, deploying configuration files and SSL certificates from `deployment-config-files/`, and ensuring the service is running and enabled.

The role supports both single-node and multi-node deployments. In a distributed setup, nodes can be designated as either `master` or `worker` using the `node_type` variable.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml` and `vars/artifact_urls.yaml`. |
| Validate config path | Verifies that the `local_configs_path` directory exists on the control node before proceeding. |
| Create download directory | Ensures the package download directory exists on the target node. |
| Download package (RHEL) | Downloads the `.rpm` package for `x86_64` or `aarch64` architectures. |
| Install package (RHEL) | Installs the downloaded `.rpm` package using `dnf`. |
| Download package (Debian) | Downloads the `.deb` package for `amd64` or `arm64` architectures. |
| Install package (Debian) | Installs the downloaded `.deb` package using `apt`. |
| Deploy configuration files | Copies `ossec.conf` and other configuration files from the control node to the target. |
| Deploy SSL certificates | Copies the required certificates for manager–indexer communication. |
| Start service | Enables and starts the `wazuh-manager` service. |

## Usage

This role is used in the `wazuh-aio.yml` and `wazuh-distributed.yml` playbooks. In a distributed deployment with multiple manager nodes, the first node acts as the `master` and the rest as `worker` nodes.

## Related

- [Variables](../variables.md#wazuh-manager)
- [Deployment](../deployment.md)
