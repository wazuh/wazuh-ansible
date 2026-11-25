# wazuh-indexer Role

## Description

The `wazuh-indexer` role installs and configures the Wazuh Indexer on the target node.

The role supports both RHEL-based and Debian-based Linux distributions and handles the full installation lifecycle: providing the node's credentials and, in a distributed deployment, its certificates issued on the control node before the package is installed, installing the package, configuring the node, initializing the indexer security configuration, and verifying that the service is healthy and reachable via its API.

The role can operate in single-node or multi-node cluster configurations, controlled by the `single_node` variable.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml` and `vars/artifact_urls.yaml`. |
| Install dependencies | Installs required system packages via the `dependencies.yml` task file. |
| Provide credentials and CA | Runs the [`wazuh-credentials`](wazuh-credentials.md) role: the indexer keys and `WAZUH_INDEXER_CERT_SANS` (the node name, the host name and `private_ip`) in `/etc/wazuh-indexer/local.env`, and, in a distributed deployment, the CA certificate in `/etc/wazuh-indexer/ca/` and the node and `admin` pairs issued on the control node in `/etc/wazuh-indexer/certs/`. All-in-One, the package mints its CA and issues them. |
| Verify package signature | Checks that the downloaded package is signed with the Wazuh GPG key before it is installed, with `verify_package_signature.yml` from the [package-urls](package-urls.md) role. |
| Install package (RHEL) | Downloads and installs the `.rpm` package using `dnf`. |
| Install package (Debian) | Downloads and installs the `.deb` package using `apt`. |
| Configure node | Applies node-specific settings via `config_files_setup.yml`, including `plugins.security.nodes_dn` with the DN of every indexer node (see [Certificates](#certificates)). |
| Configure setup plugin | When `wazuh_indexer_setup_config` or `wazuh_indexer_setup_policies` is set, writes `setup.yml` and the given ISM policy files of the setup plugin with `setup_config.yml` (see [Setup configuration](#setup-configuration)). |
| Reload systemd | Reloads the systemd daemon after installation. |
| Start service | Starts the `wazuh-indexer` service and checks that it stays active, with `start_service.yml` from the [`wazuh-credentials`](wazuh-credentials.md) role. In a distributed deployment, the nodes that were already running restart one at a time, each after the previous one joined the cluster again (`wazuh_indexer_restart_retries`); a stopped node that was already installed starts and joins the cluster first. |
| Initialize security | Runs `indexer-security-init.sh` once, from one indexer node, to load the security configuration into a new cluster, so a rerun, or the addition of a node, keeps the users, roles and passwords changed later. In a distributed deployment, the role first waits for the cluster to have a manager (`/_cluster/health`) and then asks it whether it has the security index (`HEAD /.opendistro_security`), with the `admin` certificate: the script runs only when the index does not exist. A node that does not see a cluster manager stops the run. All-in-One, it is skipped when the node reports the configuration loaded (`/_plugins/_security/health`), and the run stops when the node was installed by an earlier run and does not report it. The script is stopped after `wazuh_indexer_security_init_timeout` seconds. Set `wazuh_indexer_security_init_force` to load the configuration again. |
| Verify API | Waits for the Wazuh Indexer REST API on port `9200`, authenticating as `admin` with the password the package published. |
| Check setup status | When `wazuh_indexer_setup_config` or `wazuh_indexer_setup_policies` is set, waits for the setup plugin to initialize the cluster with the current cluster manager and stops the run when its status is `failed`, with `setup_status.yml` (see [Setup configuration](#setup-configuration)). |
| Configure JVM heap | Sets the JVM heap size to one quarter of the host's total RAM in AIO deployments (`single_node: true`), and to half of it on a dedicated indexer node, unless `wazuh_indexer_heap_size` is set. |

## Certificates

In a distributed deployment, the node certificate (`certs/indexer.pem`, `CN=<node name>`) and the `admin` certificate are issued on the control node from the CA of the deployment and staged before the package is installed; All-in-One, the package issues them, with the host name of the node as subject. The role writes the DN of every indexer node in `plugins.security.nodes_dn` on every node. In a distributed deployment, the list is built from the nodes with the `indexer` role in `instances` (`C=US,L=California,O=Wazuh,OU=Wazuh,CN=<node name>`), so it is the same in a run with `--limit`, and the role checks that the certificate of each node of the run has the DN listed for it. All-in-One, the DN is read from the certificate the package issued.

## Setup configuration

The setup plugin of the Wazuh Indexer creates the index templates, the indices and the ISM policies of Wazuh. It reads its configuration directory, `/etc/wazuh-indexer/wazuh-indexer-setup/`, each time it initializes the cluster, and applies it only to the indices it creates afterwards. The directory holds `setup.yml`, with every supported key commented out, and an editable `<policy-id>.json` copy of each default ISM policy. The keys, their valid values and the defaults are described in the [setup plugin documentation](https://wazuh.github.io/wazuh-indexer-plugins/ref/modules/setup/customization.html).

The role changes these files only when it is given them:

- `wazuh_indexer_setup_config` is the content of `setup.yml`. It replaces the packaged file as a whole, so it holds only the keys to set.
- `wazuh_indexer_setup_policies` maps a default policy id to the content of its `<policy-id>.json`, written as YAML. The plugin uses it only with `policies.<policy-id>.custom: true` in `setup.yml`.

```yaml
wazuh_indexer_setup_config: |
  templates.streams.events.settings.index.number_of_shards: 3
  templates.streams.events.settings.index.auto_expand_replicas: "0-2"
  policies.stream-events-policy.custom: true
wazuh_indexer_setup_policies:
  stream-events-policy:
    policy:
      policy_id: stream-events-policy
      description: Events data streams, deleted 30 days after the rollover
      last_updated_time: 1795392000000
      schema_version: 1
      default_state: hot
      states:
        - name: hot
          actions:
            - rollover:
                min_primary_shard_size: 20gb
          transitions:
            - state_name: delete
              conditions:
                min_rollover_age: 30d
        - name: delete
          actions:
            - delete: {}
          transitions: []
      ism_template:
        - index_patterns:
            - .ds-wazuh-events-v5-*
          priority: 1
```

- The files are written on every indexer node of the play, with the owner, group and mode of the packaged files, before the first start of the service, so a new cluster starts already configured.
- A change to a file restarts the indexer: all-in-one, the node restarts; in a distributed deployment, the running nodes restart one at a time (see [Tasks](#tasks)). A run without changes does not restart it.
- Before writing, the role checks that `setup.yml` is a YAML mapping without tabs, that each policy keeps the id of its file under `policy.policy_id`, and that the package installed the file it replaces. The plugin checks the rest when it initializes the cluster, and a value it does not accept leaves its status `failed` while the indexer keeps running.
- After the indexer is healthy, the role reads the setup status (`.wazuh-setup-status`, document `setup-status`) written after the start of the current cluster manager, which is the one of the configuration in effect, with the `admin` certificate, for up to `wazuh_indexer_api_retries` attempts 5 seconds apart. When it is `failed`, the run stops and names the cluster manager, whose `/var/log/wazuh-indexer/wazuh-cluster.log` has the error with the key or the file. When it is still `running`, which is also the status while an index waits for a schema upgrade, or not written yet, the run goes on with a warning.
- Settings and policies apply only to the indices created after the change. The existing indices keep their values: see [Applying a change to the indices that exist](https://wazuh.github.io/wazuh-indexer-plugins/ref/modules/setup/customization.html#applying-a-change-to-the-indices-that-exist).
- Removing a variable leaves the file the role wrote in place: to go back to the defaults, set `wazuh_indexer_setup_config` to the keys to keep, or comment them out.

## Usage

This role is used in the `wazuh-aio.yml` and `wazuh-distributed.yml` playbooks. In a distributed deployment, it is applied to each indexer node in the inventory.

## Related

- [Variables](../variables.md#wazuh-indexer)
- [wazuh-credentials](wazuh-credentials.md)
- [Deployment](../deployment.md#credentials-and-certificates)
