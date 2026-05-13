# wazuh-dashboard Role

## Description

The `wazuh-dashboard` role installs and configures the Wazuh Dashboard on the target node.

The role supports both RHEL-based and Debian-based Linux distributions. After installation, it configures the `opensearch_dashboards.yml` file to point to the correct Wazuh Indexer nodes and Wazuh Manager address, deploys the required SSL certificates, and ensures the service is running.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml` and `vars/artifact_urls.yaml`. |
| Install dependencies | Installs required system packages via the `dependencies.yml` task file. |
| Install package (RHEL) | Installs the `.rpm` package using `dnf`. |
| Install package (Debian) | Installs the `.deb` package using `apt`. |
| Reload systemd | Reloads the systemd daemon after installation. |
| Configure OpenSearch hosts | Updates `opensearch_dashboards.yml` with the list of Wazuh Indexer cluster nodes. |
| Configure manager URL | Sets the Wazuh Manager server URL in `opensearch_dashboards.yml`. |
| Detect SSL certificate paths | Reads the expected certificate and key file paths from `opensearch_dashboards.yml`. |
| Deploy SSL certificates | Copies the required SSL certificate and key to the configured paths on the target node. |
| Start service | Enables and starts the `wazuh-dashboard` service. |

## Usage

This role is used in the `wazuh-aio.yml` and `wazuh-distributed.yml` playbooks. In a distributed deployment, it is applied to the dedicated dashboard node.

## Related

- [Variables](../variables.md#wazuh-dashboard)
- [Deployment](../deployment.md)
