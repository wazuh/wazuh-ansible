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
| Deploy SSL certificates | Copies the required certificates for manager–indexer communication and the manager's agent listener certificate (`remoted.pem`/`remoted-key.pem`), served on ports 1517/1515 for agents to pin. |
| Start service | Enables and starts the `wazuh-manager` service. |

## Agent listener certificate

Since [wazuh/wazuh#39014](https://github.com/wazuh/wazuh/pull/39014), the Wazuh manager package no longer generates the agent listener certificate (`etc/certs/remoted.pem` / `remoted-key.pem`) and refuses to start without it. This role deploys the pair issued by `wazuh-certs-tool` (see [wazuh-installation-assistant#1009](https://github.com/wazuh/wazuh-installation-assistant/issues/1009)), signed by the same `root-ca.pem` used for the rest of the deployment's trust material.

The certificate's Subject Alternative Name (SAN) comes from the `ip`/`name` fields of the corresponding node under `manager:` in the `config.yml` used to generate certificates with `wazuh-certs-tool`. That value **must** be the address agents will use to reach this manager (port 1517/1515) — not just an internal or management IP — or agents will reject the certificate at connection time.

The SAN can cover more than the node's own private IP: the `wazuh-indexer` role's `wazuh_manager_ips` variable adds extra addresses (public IP, EIP, load balancer VIP, NAT) to every manager node's `ip` field, and `agent_san` adds free-standing addresses (e.g. a load balancer shared by a cluster) that are not tied to any single node. Both are consumed when `config.yml` is generated and passed to `wazuh-certs-tool.sh -A`, before this role deploys the resulting `remoted.pem`. See [Variables](../variables.md#wazuh-indexer).

Re-running the deployment playbook with the default `generate_certs: true` regenerates the CA and every certificate from scratch, this pair included — the same behavior already applied to `root-ca.pem` and the indexer certificate. Set `generate_certs: false` if a re-run must leave existing certificates untouched.

## Usage

This role is used in the `wazuh-aio.yml` and `wazuh-distributed.yml` playbooks. In a distributed deployment with multiple manager nodes, the first node acts as the `master` and the rest as `worker` nodes.

## Related

- [Variables](../variables.md#wazuh-manager)
- [Deployment](../deployment.md)
