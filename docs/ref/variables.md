# Variables

This page documents all configurable variables available in the `wazuh-ansible` project, organized by scope. General variables are shared across all roles and are defined in `roles/vars/main.yml`. Role-specific variables are defined in each role's `defaults/main.yml` file and can be overridden in the inventory or playbook.

---

## General Variables

These variables are defined in `roles/vars/main.yml` and are automatically loaded by every role.

---

**Variable:** `wazuh_version_data`  
**Description:** Parsed JSON object read from `VERSION.json` in the playbook directory. Contains the full version metadata used by other computed variables.  
**Default value:** `{{ lookup('file', playbook_dir + '/VERSION.json') | from_json }}`

---

**Variable:** `wazuh_full_version`  
**Description:** The full Wazuh version string (e.g. `5.1.0`) extracted from `wazuh_version_data`.  
**Default value:** `{{ wazuh_version_data.version }}`

---

**Variable:** `wazuh_major_minor_version`  
**Description:** The major and minor version components only (e.g. `5.1`), derived from `wazuh_full_version`.  
**Default value:** `{{ wazuh_version_data.version.split('.')[0:2] | join('.') }}`

---

**Variable:** `wazuh_major_version`  
**Description:** The major version string in `X.x` format (e.g. `5.x`), used in package repository URL paths.  
**Default value:** `{{ wazuh_version_data.version.split('.')[0] }}.x`

---

**Variable:** `wazuh_package_revision`  
**Description:** The package revision number appended to package filenames. Increment this when a new package revision is released for the same version.  
**Default value:** `1`

---

**Variable:** `wazuh_stage`  
**Description:** The release stage of the current version (e.g. `alpha`, `beta`, `rc`, `stable`). Used to construct pre-release package URLs.  
**Default value:** `{{ wazuh_version_data.stage }}`

---

**Variable:** `local_configs_path`  
**Description:** Path on the control node to the directory containing deployment configuration files (e.g. `config.yml`, certificates). This directory must exist before running any deployment playbook.  
**Default value:** `{{ playbook_dir }}/deployment-config-files`

---

**Variable:** `urls_file`  
**Description:** Filename of the artifact URLs YAML file that is downloaded by the `package-urls` role and subsequently loaded by all other roles to resolve package download URLs.  
**Default value:** `artifact_urls.yaml`

---

## package-urls

These variables are defined in `roles/package-urls/defaults/main.yml` and control where the artifact URL definitions file is fetched from.

---

**Variable:** `source`  
**Description:** Determines which package source to use when downloading the artifact URL definitions file. Accepted values are `production` (public release packages) and `prerelease` (staging packages for pre-release versions).  
**Default value:** `production`

---

**Variable:** `package_urls_file_uri`  
**Description:** URI path (relative to the production package host) used to download the artifact URL definitions file when `source` is set to `production`.  
**Default value:** `packages.wazuh.com/production/{{ wazuh_major_version }}/artifact-urls/artifact_urls_{{ wazuh_full_version }}.yaml`

---

**Variable:** `package_urls_file_uri_prerelease`  
**Description:** URI path (relative to the staging package host) used to download the artifact URL definitions file when `source` is set to `prerelease`.  
**Default value:** `packages-staging.xdrsiem.wazuh.info/pre-release/{{ wazuh_major_version }}/artifact-urls/artifact_urls_{{ wazuh_full_version }}-{{ wazuh_stage }}.yaml`

---

## wazuh-indexer

These variables are defined in `roles/wazuh-indexer/defaults/main.yml`.

---

**Variable:** `single_node`  
**Description:** When set to `true`, configures the Wazuh Indexer as a single-node cluster, disabling cluster bootstrapping requirements. Set to `false` for multi-node deployments.  
**Default value:** `false`

---

**Variable:** `generate_certs`  
**Description:** When set to `true`, the role triggers certificate generation for the indexer node using the Wazuh certificates tool. Set to `false` if certificates are already in place.  
**Default value:** `true`

---

**Variable:** `instances`  
**Description:** A mapping that defines the indexer node instances involved in the deployment. Each entry specifies the node `name`, its `ip` address, and its `role` (e.g. `aio`, `indexer`). Manager entries also accept an optional `extra_ips` list — additional IPv4/IPv6 addresses (public IP, EIP, NAT) unique to that node, added to its `ip` field in the `config.yml` used to generate certificates. This is used when generating certificates and configuring cluster membership. These variables are resolved on the host where the certificate-generation block runs (`run_once`, the first host of the indexer play — e.g. `wi1` in `wazuh-distributed.yml`); setting `instances` or `extra_ips` as a host var of a `manager` node has no effect.  
**Default value:**  
```yaml
instances:
  aio_node:
    name: indexer
    ip: "{{ hostvars[inventory_hostname].private_ip }}"
    role: aio
```

---

**Variable:** `wazuh_manager_ips`  
**Description:** Optional list of additional IPv4/IPv6 addresses (public IP, EIP, NAT) to add to the manager node's `ip` field in the `config.yml` used to generate certificates. **Single-node deployments only** — `wazuh-certs-tool.sh` rejects manager nodes that share an `ip` value, so the role fails fast if this is set with more than one manager node in `instances`. For a multi-node cluster, set `extra_ips` on the corresponding entry of `instances` instead, to give each manager node its own distinct address. When empty (the default), `ip` stays a single scalar value, identical to the previous behavior.  
**Default value:** `[]`

---

**Variable:** `agent_san`  
**Description:** Optional list of free-standing IP/DNS values (e.g. a load balancer or VIP shared by a manager cluster, not owned by any single node) passed as a repeated `--agent-san <value>` flag when invoking `wazuh-certs-tool.sh -A`. Each value is added to the SAN of every manager node's agent listener certificate (`remoted.pem`). Requires a `wazuh-certs-tool.sh` build that includes `wazuh-installation-assistant#1028` (merged 2026-09-17) — an older build does not recognize `--agent-san` and misparses it as the `-A` root-ca path argument instead.  
**Default value:** `[]`

---

**Variable:** `wazuh_indexer_package_download_path`  
**Description:** Path on the target node where the Wazuh Indexer package file will be downloaded before installation.  
**Default value:** `/tmp/wazuh-indexer`

---

**Variable:** `wazuh_indexer_package_name`  
**Description:** Base filename (without architecture suffix or extension) of the Wazuh Indexer package to download and install.  
**Default value:** `wazuh-indexer-{{ wazuh_full_version }}-{{ wazuh_package_revision }}`

---

**Variable:** `wazuh_indexer_heap_size`  
**Description:** JVM heap size for the Wazuh Indexer, specified as a string with a size unit (e.g. `2g`, `512m`). When empty (the default), the heap size is automatically set to one quarter of the host's total RAM for AIO deployments (`single_node: true`). Has no effect in distributed deployments unless explicitly set.  
**Default value:** `""` (auto-calculated for AIO)

---

## wazuh-manager

These variables are defined in `roles/wazuh-manager/defaults/main.yml`.

---

**Variable:** `single_node`  
**Description:** When set to `true`, configures the Wazuh Manager for a single-node deployment. Set to `false` for multi-node setups where a master and one or more worker nodes are used.  
**Default value:** `false`

---

**Variable:** `node_type`  
**Description:** Defines the role of this manager node within the cluster. Accepted values are `master` (primary node that coordinates the cluster) and `worker` (secondary node that forwards data to the master).  
**Default value:** `master`

---

**Variable:** `manager_node_name`  
**Description:** The logical name assigned to this manager node. Used in the manager configuration file to identify the node within the cluster.  
**Default value:** `manager`

---

**Variable:** `wazuh_indexer_hosts`  
**Description:** List of Wazuh Indexer hosts that this manager node will connect to. Each entry specifies a `host` address and the `port` to use for the connection.  
**Default value:**  
```yaml
wazuh_indexer_hosts:
  - host: "{{ hostvars[inventory_hostname].private_ip }}"
    port: 9200
```

---

**Variable:** `wazuh_manager_package_download_path`  
**Description:** Path on the target node where the Wazuh Manager package file will be downloaded before installation.  
**Default value:** `/tmp/wazuh-manager`

---

**Variable:** `wazuh_manager_package_name`  
**Description:** Base filename (without architecture suffix or extension) of the Wazuh Manager package to download and install.  
**Default value:** `wazuh-manager-{{ wazuh_full_version }}-{{ wazuh_package_revision }}`

---

**Variable:** `wazuh_manager_install_path`  
**Description:** Filesystem path where the Wazuh Manager is installed on the target node.  
**Default value:** `/var/wazuh-manager/`

---

## wazuh-dashboard

These variables are defined in `roles/wazuh-dashboard/defaults/main.yml`.

---

**Variable:** `dashboard_node_name`  
**Description:** The logical name assigned to this dashboard node. Used to identify the node in configuration and certificate files.  
**Default value:** `dashboard`

---

**Variable:** `wazuh_manager_master_address`  
**Description:** IP address or hostname of the Wazuh Manager master node. The dashboard uses this address to configure the Wazuh server URL in `opensearch_dashboards.yml`.  
**Default value:** `{{ hostvars[inventory_hostname].private_ip }}`

---

**Variable:** `indexer_cluster_nodes`  
**Description:** List of IP addresses or hostnames of the Wazuh Indexer nodes. The dashboard uses this list to configure the `opensearch.hosts` entries in `opensearch_dashboards.yml`.  
**Default value:**  
```yaml
indexer_cluster_nodes:
  - "{{ hostvars[inventory_hostname].private_ip }}"
```

---

**Variable:** `wazuh_dashboard_package_download_path`  
**Description:** Path on the target node where the Wazuh Dashboard package file will be downloaded before installation.  
**Default value:** `/tmp/wazuh-dashboard`

---

**Variable:** `wazuh_dashboard_package_name`  
**Description:** Base filename (without architecture suffix or extension) of the Wazuh Dashboard package to download and install.  
**Default value:** `wazuh-dashboard-{{ wazuh_full_version }}-{{ wazuh_package_revision }}`

---

## wazuh-agent

These variables are defined in `roles/wazuh-agent/defaults/main.yml`.

---

**Variable:** `wazuh_agent_package_download_path`  
**Description:** Path on the Linux or macOS target node where the Wazuh Agent package file will be downloaded before installation.  
**Default value:** `/tmp/wazuh-agent`

---

**Variable:** `wazuh_agent_win_package_download_path`  
**Description:** Path on the Windows target node where the Wazuh Agent package file will be downloaded before installation.  
**Default value:** `C:\Temp\wazuh-agent`

---

**Variable:** `wazuh_agent_package_name`  
**Description:** Base filename (without architecture suffix or extension) of the Wazuh Agent package to download and install.  
**Default value:** `wazuh-agent-{{ wazuh_full_version }}-{{ wazuh_package_revision }}`

---

**Variable:** `wazuh_enrollment_token`  
**Description:** Enrollment token for 5.x agents — Linux, Windows and macOS alike — maps to the `WAZUH_ENROLLMENT_TOKEN` install-time variable (see [wazuh/wazuh#39063](https://github.com/wazuh/wazuh/issues/39063)). The manager address always travels inside the token; the CA either travels with it too (a token minted with `--embed-ca`) or is fetched separately over `/cacerts` on the agent's first start and verified against the token's pin. Either way, no separate manager-address or CA variable exists in this role. Defined in `wazuh-agent.yml` (not in `defaults/main.yml`); this role does not mint tokens, the operator must provide one (for example via `wazuh-manager-authd --create-enrollment-token --address <address>`).  
**Default value:** `<Your Wazuh Agent Enrollment Token>` (must be overridden)

---

**Variable:** `wazuh_ssl_verification`  
**Description:** Optional. Agent TLS verification posture, mapped to the `WAZUH_SSL_VERIFICATION` install-time variable and written to `<agent><ssl><verification_mode>`. One of `full` (verify against the CA **and** check the manager's hostname), `certificate` (verify against the CA only), `system` (trust the OS store) or `none` (no verification, for lab/CI). Empty leaves the tag unset. **Do not set `full` or `certificate` on a fresh install with `wazuh_enrollment_token`**: `wazuh-agentd` validates `<certificate_authorities>` before it will start, but that file is only written by the enrollment-token bootstrap, which runs on the very first start the validation just refused — a real deadlock, verified against a live 5.0.0 agent, that leaves the agent needing to be reinstalled. Leaving this empty does not disable verification: the agent bootstraps its trust anchor and verifies against it from then on, confirmed including a restart after enrollment. Re-running this role does not apply a changed value to an agent that is already installed — see [Existing agents are not reconfigured](../roles/wazuh-agent.md#existing-agents-are-not-reconfigured).  
**Default value:** `""`

---

**Variable:** `wazuh_agent_install_path` / `wazuh_agent_macos_install_path` / `wazuh_agent_win_install_path`  
**Description:** Agent installation directory per platform. Not read by any task in this role as of [wazuh/wazuh#39063](https://github.com/wazuh/wazuh/issues/39063) (enrollment moved to a single token, so no task needs the install path to place a CA file or read `ossec.conf` back); kept as documented per-platform metadata.  
**Default value:** `/var/ossec`, `/Library/Ossec`, `{{ ansible_facts.env['ProgramFiles(x86)'] }}\ossec-agent`
