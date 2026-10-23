# wazuh-dashboard Role

## Description

The `wazuh-dashboard` role installs and configures the Wazuh Dashboard on the target node.

The role supports both RHEL-based and Debian-based Linux distributions. Before installation, it provides the node's credentials and, in a distributed deployment, its certificate issued on the control node and the CA of the Wazuh Indexer and the Wazuh Manager. After installation, it configures the `opensearch_dashboards.yml` file to point to the correct Wazuh Indexer nodes and Wazuh Manager address, and ensures the service is running.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml` and `vars/artifact_urls.yaml`. |
| Install dependencies | Installs required system packages via the `dependencies.yml` task file. |
| Provide credentials and CA | Runs the [`wazuh-credentials`](wazuh-credentials.md) role: the dashboard keys and `WAZUH_DASHBOARD_CERT_SANS` (the node name, the host name and `private_ip`) in `/etc/wazuh-dashboard/local.env`, and, in a distributed deployment, `certs/dashboard.pem` / `dashboard-key.pem` issued on the control node with the CA of the deployment as `certs/indexer-ca.pem` and `certs/manager-ca.pem`. All-in-One, the package mints its CA, issues its pair and imports the peer CAs from the host. |
| Verify package signature | Checks that the downloaded package is signed with the Wazuh GPG key before it is installed, with `verify_package_signature.yml` from the [package-urls](package-urls.md) role. |
| Install package (RHEL) | Installs the `.rpm` package using `dnf`. |
| Install package (Debian) | Installs the `.deb` package using `apt`. |
| Reload systemd | Reloads the systemd daemon after installation. |
| Configure OpenSearch hosts | Updates `opensearch_dashboards.yml` with the list of Wazuh Indexer cluster nodes. |
| Configure manager URL | Sets the Wazuh Manager server URL in `opensearch_dashboards.yml`. |
| Check peer trust | Checks that `opensearch_dashboards.yml` verifies the Wazuh Indexer against `certs/indexer-ca.pem` and the Wazuh server API against `certs/manager-ca.pem`. |
| Start service | Starts the `wazuh-dashboard` service and checks that it stays active, with `start_service.yml` from the [`wazuh-credentials`](wazuh-credentials.md) role. |

## Usage

This role is used in the `wazuh-aio.yml` and `wazuh-distributed.yml` playbooks. In a distributed deployment, it is applied to the dedicated dashboard node.

## Related

- [Variables](../variables.md#wazuh-dashboard)
- [wazuh-credentials](wazuh-credentials.md)
- [Deployment](../deployment.md#credentials-and-certificates)
