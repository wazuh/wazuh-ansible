# wazuh-manager Role

## Description

The `wazuh-manager` role installs and configures the Wazuh Manager on the target node.

The role supports both RHEL-based and Debian-based Linux distributions. It handles providing the node's credentials, staging its certificates from `deployment-config-files/` before the package is installed, downloading and installing the package for the target architecture, deploying the configuration, and ensuring the service is running and enabled.

The role supports both single-node and multi-node deployments. In a distributed setup, nodes can be designated as either `master` or `worker` using the `node_type` variable.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml` and `vars/artifact_urls.yaml`. |
| Validate config path | Verifies that the `local_configs_path` directory exists on the control node before proceeding. |
| Provide credentials | Runs the [`wazuh-credentials`](wazuh-credentials.md) role for the manager keys. |
| Stage certificates | Before the package is installed: the root CA certificate (never its key) in `/etc/wazuh/ca`, and the indexer connector (`indexer-connector.pem`), agent listener (`remoted.pem`) and Server API (`apid.pem`) pairs in `etc/certs`, root-owned. The package gives them their owners and uses them. Skipped when the package is already installed. |
| Create download directory | Ensures the package download directory exists on the target node. |
| Download package (RHEL) | Downloads the `.rpm` package for `x86_64` or `aarch64` architectures. |
| Install package (RHEL) | Installs the downloaded `.rpm` package using `dnf`. |
| Download package (Debian) | Downloads the `.deb` package for `amd64` or `arm64` architectures. |
| Install package (Debian) | Installs the downloaded `.deb` package using `apt`. |
| Deploy configuration files | Copies `ossec.conf` and other configuration files from the control node to the target. |
| Deploy SSL certificates | After the installation, keeps the certificates for manager–indexer communication and the agent listener certificate (`remoted.pem`/`remoted-key.pem`, served on ports 1517/1515 for agents to pin), and the Server API certificate (`apid.pem`/`apid-key.pem`, served on port 55000) in place, with their final owners. |
| Start service | Enables and starts the `wazuh-manager` service, then checks the Wazuh server API as `wazuh` with the password of the deployment (master) or the cluster with `cluster_control -l` (worker). |

## Agent listener certificate

Since [wazuh/wazuh#39014](https://github.com/wazuh/wazuh/pull/39014), the Wazuh manager package no longer generates the agent listener certificate (`etc/certs/remoted.pem` / `remoted-key.pem`) and refuses to start without it. This role deploys the pair issued by `wazuh-certs-tool` (see [wazuh-installation-assistant#1009](https://github.com/wazuh/wazuh-installation-assistant/issues/1009)), signed by the same `root-ca.pem` used for the rest of the deployment's trust material.

The certificate's Subject Alternative Name (SAN) comes from the `ip`/`name` fields of the corresponding node under `manager:` in the `config.yml` used to generate certificates with `wazuh-certs-tool`. That value **must** be the address agents will use to reach this manager (port 1517/1515) — not just an internal or management IP — or agents will reject the certificate at connection time.

The SAN can cover more than the node's own private IP. In a single-node deployment, the `wazuh-indexer` role's `wazuh_manager_ips` variable adds extra addresses (public IP, EIP, NAT) to the manager's `ip` field. In a multi-node cluster, each manager node gets its own extra addresses through the `extra_ips` list on its entry in `instances` instead — `wazuh_manager_ips` is rejected there, since `wazuh-certs-tool` does not allow manager nodes to share an `ip` value. `agent_san` adds free-standing addresses (e.g. a load balancer shared by a cluster) that are not tied to any single node, in both deployment modes. All three are consumed when `config.yml` is generated and passed to `wazuh-certs-tool.sh -A`, before this role deploys the resulting `remoted.pem`. See [Variables](../variables.md#wazuh-indexer).

Re-running the deployment playbook keeps the root CA and every certificate, this pair included, so agents enrolled earlier keep trusting the manager. See [Certificates](wazuh-indexer.md#certificates).

## Server API certificate

Since [wazuh/wazuh#40085](https://github.com/wazuh/wazuh/pull/40085), the Wazuh manager package no longer generates the Server API certificate (`etc/certs/apid.pem` / `apid-key.pem`) and the API refuses to start without it. This role deploys the pair issued by `wazuh-certs-tool -A` for each manager node, signed by the same `root-ca.pem` as the rest of the deployment. It has the same profile as `remoted.pem` but its own SAN: the `ip`/`name` of the node under `manager:` in `config.yml`, plus loopback.

`api_san` adds addresses that API clients dial and that are not tied to a single node, such as a published name or a load balancer in front of the Server API. See [Variables](../variables.md#wazuh-indexer).

A `wazuh-certificates/` directory generated by an older `wazuh-certs-tool.sh` has no `*-apid.pem` pair. Remove it and run the playbook again to issue the certificates from the same root CA, as described in [Certificates](wazuh-indexer.md#certificates).

## Usage

This role is used in the `wazuh-aio.yml` and `wazuh-distributed.yml` playbooks. In a distributed deployment with multiple manager nodes, the first node acts as the `master` and the rest as `worker` nodes.

## Related

- [Variables](../variables.md#wazuh-manager)
- [wazuh-credentials](wazuh-credentials.md)
- [Deployment](../deployment.md)
