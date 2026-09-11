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
**Description:** The full Wazuh version string (e.g. `5.0.1`) extracted from `wazuh_version_data`.  
**Default value:** `{{ wazuh_version_data.version }}`

---

**Variable:** `wazuh_major_minor_version`  
**Description:** The major and minor version components only (e.g. `5.0`), derived from `wazuh_full_version`.  
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
**Description:** A mapping that defines the indexer node instances involved in the deployment. Each entry specifies the node `name`, its `ip` address, and its `role` (e.g. `aio`, `indexer`). This is used when generating certificates and configuring cluster membership.  
**Default value:**  
```yaml
instances:
  aio_node:
    name: indexer
    ip: "{{ hostvars[inventory_hostname].private_ip }}"
    role: aio
```

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

**Variable:** `wazuh_manager_address`  
**Description:** Hostname or IP of the Wazuh manager the agent will connect and enroll to. Defined in `wazuh-agent.yml` (not in `defaults/main.yml`), maps to the `WAZUH_MANAGER` install-time variable.  
**Default value:** `<Your Wazuh Manager IP>` (must be overridden)

---

**Variable:** `wazuh_registration_password`  
**Description:** Password used for agent auto-enrollment. Defined in `wazuh-agent.yml` (not in `defaults/main.yml`), maps to the `WAZUH_REGISTRATION_PASSWORD` install-time variable.  
**Default value:** `<Your Wazuh Manager Registration Password>` (must be overridden)

---

**Variable:** `wazuh_manager_endpoint`  
**Description:** Optional. Full connection URL for the manager (`host[:port][/path]`), maps to the `WAZUH_MANAGER_ENDPOINT` install-time variable. Added ahead of [wazuh/wazuh#38624](https://github.com/wazuh/wazuh/issues/38624), which will replace `WAZUH_MANAGER`/`WAZUH_MANAGER_PORT` with this single variable at RC1. Empty keeps the role on the legacy `wazuh_manager_address`/`WAZUH_MANAGER` path.  
**Default value:** `""`

---

**Variable:** `wazuh_registration_ca`  
**Description:** Optional. **Absolute** path on the Ansible control node to the CA certificate that signed the manager's TLS certificate. Must be a CA certificate, not a bundle carrying a private key: the file is copied to the target world-readable so the agent daemons can read it. The role copies it to the target node *before* installing the package and passes the remote path as the `WAZUH_REGISTRATION_CA` install-time variable; the installer pins that path into `<agent><ssl><certificate_authorities>`, which governs **all** agent↔manager HTTPS traffic, not just enrollment, and also flips the effective `verification_mode` to `certificate` (see `wazuh_ssl_verification` below — `certificate` validates the certificate chain but does **not** check the manager's hostname). Note that `<enrollment><server_ca_path>`, which the installer also writes, is parsed but ignored by the 5.x agent. Required when the manager presents a self-signed or private CA — with `verification_mode` now enforced by default (see [wazuh/wazuh#38786](https://github.com/wazuh/wazuh/pull/38786)), an agent installed without this variable against such a manager fails closed instead of connecting insecurely. The copied file is a permanent runtime dependency: `wazuh-agentd` reads it on **every** start and refuses to start when it is missing, so it must stay on the node for the life of the install. A relative path is resolved against the role's own `files/` directory by `ansible.builtin.copy`, so the role asserts up front that the value is an absolute path to a regular file on the control node.  
**Default value:** `""`

---

**Variable:** `wazuh_ssl_verification`  
**Description:** Optional. Agent TLS verification posture, mapped to the `SSL_VERIFICATION` install-time variable ([wazuh/wazuh#38786](https://github.com/wazuh/wazuh/pull/38786)) and written to `<agent><ssl><verification_mode>`. One of `full` (verify against the CA **and** check the manager's hostname), `certificate` (verify against the CA only), `system` (trust the OS store) or `none` (no verification, for lab/CI against a self-signed manager with no CA to hand). Empty leaves the tag unset, which resolves to `certificate` when `wazuh_registration_ca` is set and `system` when it is not. Set `full` on a manager whose certificate carries proper SANs. `system` cannot be combined with `wazuh_registration_ca` — the agent refuses to start with both configured — and the role asserts this rather than letting the installer silently drop the CA.  
**Default value:** `""`

---

**Variable:** `wazuh_registration_ca_remote_path` / `wazuh_registration_ca_macos_remote_path` / `wazuh_registration_ca_win_remote_path`  
**Description:** Where the role places `wazuh_registration_ca` on the target node, per platform. These are the CA drop-in locations the agent itself documents (`pkg_installer.sh` on Linux/macOS, `do_upgrade.ps1` on Windows), so one file serves both the install-time pin and the CA a later WPK upgrade looks for, and it is removed when the agent is uninstalled. Derived from `wazuh_agent_install_path`, `wazuh_agent_macos_install_path` and `wazuh_agent_win_install_path` respectively, so overriding a non-default install prefix is enough.  
**Default value:** `/var/ossec/etc/certs/root-ca.pem`, `/Library/Ossec/etc/certs/root-ca.pem`, `<ProgramFiles(x86)>\ossec-agent\certs\root-ca.pem`

---

**Variable:** `wazuh_agent_verify_registration_ca`  
**Description:** Whether to assert, after the install, that the CA really was pinned into `ossec.conf`. Only runs when `wazuh_registration_ca` is set. The check exists because both relevant failure modes are otherwise completely silent: the installer logs its own failures to pin the CA to `ossec.log` and still exits `0`, and a package install skipped on an already-installed agent never runs the installer at all — in both cases the package manager, the service start and the whole play report success while the agent has no CA configured and can never enroll. Set to `false` to skip the check.  
**Default value:** `true`

---

**Variable:** `wazuh_agent_install_path` / `wazuh_agent_macos_install_path` / `wazuh_agent_win_install_path`  
**Description:** Agent installation directory per platform. Used to resolve the CA drop-in locations above and the `ossec.conf` the post-install check reads.  
**Default value:** `/var/ossec`, `/Library/Ossec`, `{{ ansible_facts.env['ProgramFiles(x86)'] }}\ossec-agent`
