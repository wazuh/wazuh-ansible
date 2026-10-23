# wazuh-manager Role

## Description

The `wazuh-manager` role installs and configures the Wazuh Manager on the target node.

The role supports both RHEL-based and Debian-based Linux distributions. It handles providing the node's credentials and, in a distributed deployment, its certificates issued on the control node before the package is installed, downloading and installing the package for the target architecture, handing the staged certificates to the service after the installation (distributed), configuring `wazuh-manager.conf`, and ensuring the service is running and enabled.

The role supports both single-node and multi-node deployments. In a distributed setup, nodes can be designated as either `master` or `worker` using the `node_type` variable.

The configuration directory of the Wazuh Manager is `/etc/wazuh-manager` (`wazuh_manager_conf_dir`).

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml` and `vars/artifact_urls.yaml`. |
| Validate config path | Verifies that the `local_configs_path` directory exists on the control node before proceeding. |
| Certificate names | Builds `WAZUH_MANAGER_REMOTED_CERT_SANS` and `WAZUH_MANAGER_APID_CERT_SANS`. See [Certificate names](#certificate-names). |
| Provide credentials and CA | Runs the [`wazuh-credentials`](wazuh-credentials.md) role: the manager keys and the certificate names in `/etc/wazuh-manager/local.env`, and, in a distributed deployment, the CA certificate in `/etc/wazuh-manager/ca/` and, in `certs/`, the agent listener (`remoted.pem`) and Server API (`apid.pem`) pairs issued on the control node, the CA as `root-ca.pem` and `indexer-ca.pem`, and the node's own client pair for the Wazuh Indexer, `indexer-connector.pem` / `indexer-connector-key.pem`. All-in-One, the package mints its CA, issues its pairs and imports the indexer trust from the Wazuh Indexer on the host. |
| Create download directory | Ensures the package download directory exists on the target node. |
| Download package (RHEL) | Downloads the `.rpm` package for `x86_64` or `aarch64` architectures. |
| Verify package signature | Checks that the downloaded package is signed with the Wazuh GPG key before it is installed, with `verify_package_signature.yml` from the [package-urls](package-urls.md) role. |
| Install package (RHEL) | Installs the downloaded `.rpm` package using `dnf`. |
| Download package (Debian) | Downloads the `.deb` package for `amd64` or `arm64` architectures. |
| Verify package signature | Checks that the downloaded package is signed with the Wazuh GPG key before it is installed, with `verify_package_signature.yml` from the [package-urls](package-urls.md) role. |
| Install package (Debian) | Installs the downloaded `.deb` package using `apt`. |
| Hand the certificates to the service | Distributed only: gives `certs/` to `root:wazuh-manager` (`0750`, files `0640`) and runs `wazuh-manager-resolve-credentials --upgrade`, with `peer_trust.yml` from the [`wazuh-credentials`](wazuh-credentials.md) role. Not required: on RPM systems the package checks the staged files before it gives them its group, fixes their owner at the end of its installation and resolves the rest at its first start; the step completes that resolution at install time. |
| Check indexer trust | Checks that the `<indexer><ssl>` block of `wazuh-manager.conf` verifies the Wazuh Indexer against `certs/indexer-ca.pem`. |
| Configure `wazuh-manager.conf` | Sets the Wazuh Indexer hosts and the cluster settings (node name, node type, key, nodes). |
| Start service | Starts the `wazuh-manager` service and checks that it stays active, with `start_service.yml` from the [`wazuh-credentials`](wazuh-credentials.md) role. Then checks the Wazuh server API as `wazuh` with the password the package published (master), or the cluster with `cluster_control -l` (worker). |

## Certificate names

The agent listener certificate (`remoted.pem`, served on ports 1515 and 1517 for agents to pin) and the Server API certificate (`apid.pem`, served on port 55000) are issued on the control node in a distributed deployment, and by the package All-in-One, with the names the role writes in `local.env`. A name agents or API clients dial must be in the certificate, or they reject it.

| Certificate | Names |
|-------------|-------|
| `remoted.pem` (`WAZUH_MANAGER_REMOTED_CERT_SANS`) | The `name`, host name, `ip` and `extra_ips` of the node, `wazuh_manager_ips` (single-node only), and `agent_san`. |
| `apid.pem` (`WAZUH_MANAGER_APID_CERT_SANS`) | The `name`, host name, `ip` and `extra_ips` of the node, `wazuh_manager_ips` (single-node only), and `api_san`. |

`localhost`, `127.0.0.1` and `::1` are added to both. A bare value in `agent_san` or `api_san` is taken as an IP address when it is an IPv4 address or contains a colon, and as a DNS name otherwise; `IP:` and `DNS:` prefixes are kept.

Each node's certificates name that node only. Enrollment tokens are minted on the master only, and `wazuh-manager-authd --create-enrollment-token --address <address>` refuses an address that is not in the master's agent listener certificate, so in a multi-node cluster agents enroll through an address shared by every manager node, such as a load balancer or a DNS name that resolves to the workers: set it in `agent_san` and mint the tokens for it. A token minted for the address of a single worker is refused.

In a single-node deployment, `wazuh_manager_ips` adds extra addresses (public IP, EIP, NAT). In a multi-node cluster, each manager node gets its own extra addresses through the `extra_ips` list on its entry in `instances` instead; `wazuh_manager_ips` is rejected there. `agent_san` and `api_san` add addresses that are not tied to a single node, such as a load balancer. See [Variables](../variables.md#wazuh-manager).

Re-running the deployment playbook keeps the CA and every certificate, so agents enrolled earlier keep trusting the manager.

## Usage

This role is used in the `wazuh-aio.yml` and `wazuh-distributed.yml` playbooks. In a distributed deployment with multiple manager nodes, the first node acts as the `master` and the rest as `worker` nodes. `wazuh-distributed.yml` gives the manager plays the same `instances` as the indexer play, so that each manager node takes its `name`, `ip` and `extra_ips` from its own entry.

## Related

- [Variables](../variables.md#wazuh-manager)
- [wazuh-credentials](wazuh-credentials.md)
- [Deployment](../deployment.md#credentials-and-certificates)
