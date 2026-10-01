# wazuh-dashboard Role

## Description

The `wazuh-dashboard` role installs and configures the Wazuh Dashboard on the target node.

The role supports both RHEL-based and Debian-based Linux distributions. Before installation, it provides the node's credentials and stages its certificates. After installation, it configures the `opensearch_dashboards.yml` file to point to the correct Wazuh Indexer nodes and Wazuh Manager address, gives the certificates to the `wazuh-dashboard` user, and ensures the service is running.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml` and `vars/artifact_urls.yaml`. |
| Install dependencies | Installs required system packages via the `dependencies.yml` task file. |
| Provide credentials | Runs the [`wazuh-credentials`](wazuh-credentials.md) role for the dashboard keys. |
| Stage certificates | Before the package is installed: the root CA certificate (never its key) in `/etc/wazuh/ca`, and the node's pair in `/etc/wazuh-dashboard/certs` as `dashboard.pem`/`dashboard-key.pem`, root-owned. The package uses them. Skipped when the package is already installed. |
| Install package (RHEL) | Installs the `.rpm` package using `dnf`. |
| Install package (Debian) | Installs the `.deb` package using `apt`. |
| Reload systemd | Reloads the systemd daemon after installation. |
| Configure OpenSearch hosts | Updates `opensearch_dashboards.yml` with the list of Wazuh Indexer cluster nodes. |
| Configure manager URL | Sets the Wazuh Manager server URL in `opensearch_dashboards.yml`. |
| Detect SSL certificate paths | Reads the expected certificate and key file paths from `opensearch_dashboards.yml`. |
| Deploy SSL certificates | Keeps the certificate, its key, and the root CA certificate at the configured paths, owned by `wazuh-dashboard` (`0400`, directory `0500`): the package keeps a pair placed before the installation root-owned. |
| Start service | Enables and starts the `wazuh-dashboard` service. |

## Usage

This role is used in the `wazuh-aio.yml` and `wazuh-distributed.yml` playbooks. In a distributed deployment, it is applied to the dedicated dashboard node.

## Related

- [Variables](../variables.md#wazuh-dashboard)
- [wazuh-credentials](wazuh-credentials.md)
- [Deployment](../deployment.md)
