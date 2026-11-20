# Migrating from Wazuh 4.x

A Wazuh 4.x deployment cannot be upgraded in place to 5.0. The 5.0 components use other paths (`/var/wazuh-manager` and `/etc/wazuh-manager` instead of `/var/ossec`), other system users, a new configuration format and a new agent protocol, and the 5.0 packages refuse to install over a 4.x Wazuh Indexer or Wazuh Manager. These playbooks deploy 5.0 only ([Compatibility](introduction/compatibility.md)).

A 4.x deployment is migrated instead: 5.0 is deployed with these playbooks, and the agent identity is carried across with the Wazuh manager migration tool, `wazuh-migrate-identity.py`. It keeps the agent ids, names and keys, the group membership and the group folders and, optionally, the Wazuh server API users and the enrollment password, so the 4.x agents reconnect without enrolling again. The Wazuh manager guide [Migrating a Wazuh manager from 4.x to 5.0](https://github.com/wazuh/wazuh/blob/5.0.1/docs/guide/migration/manager-4x-to-5x.md) covers everything else: the configuration, the rules and decoders, upgrading the agents and retiring the legacy channel. This page is the Ansible part of it.

There are two paths:

- [New hosts](#new-hosts) (recommended): 5.0 is deployed on other hosts. The 4.x deployment stays available for rollback and to consult the 4.x alerts.
- [Same hosts](#same-hosts): 4.x is removed and 5.0 is deployed on the same hosts, with the same inventory. It has [costs](#costs-of-the-same-hosts-path): downtime, no rollback, and the 4.x alerts are kept only through a snapshot.

## Before you start

- **Operating system.** The hosts that run 5.0 must run an operating system supported by Wazuh 5.0. For the same hosts path, check it before removing 4.x.
- **Manager address.** Every 4.x agent connects to the address in its `<client><server><address>`. Either give the 5.0 Wazuh Manager that address, or edit it on every agent after the import.
- **Control node.** Run the 5.0 playbooks from a new clone of the `v5.0.1` tag, not from the directory of the 4.x playbooks. The 4.x playbooks keep their certificates in `playbooks/indexer/certificates/`, and the 5.0 playbooks keep the credentials of each deployment in `deployment-credentials/` and `deployment-config-files/` next to the playbook. Use one clone per deployment.
- **Migration tool.** Download it on the 4.x Wazuh Manager host and, later, on the 5.0 Wazuh Manager host (the master node in a distributed deployment):

  ```bash
  sudo curl -fsSLo /root/wazuh-migrate-identity.py https://raw.githubusercontent.com/wazuh/wazuh/5.0.1/tools/migration/wazuh-migrate-identity.py
  ```

  It uses only the Python standard library. On the 4.x host, run it with the system `python3`. On the 5.0 host, run it with the Python bundled with the Wazuh Manager, `/var/wazuh-manager/framework/python/bin/python3`, as root.
- **Enrollment password.** The 4.x `wazuh-manager` role enables `<auth><use_password>` only when `wazuh_manager_config.authd.use_password` is `yes`. If your 4.x agents enroll with a password and new 4.x agents must still enroll during the migration, add `--with-password` to `export` and `import`. The password must be at least 16 bytes long.
- **The bundle.** `export` writes a directory with the agent keys and the hashes of the API passwords. Copy it between hosts as you would copy a credential, and delete it when the migration is complete.

## New hosts

1. **Deploy 5.0** on the new hosts, with a new inventory, as described in [Deployment](deployment.md). The 4.x agents still connect to the 4.x Wazuh Manager, so none of them reaches the 5.0 Wazuh Manager before its registry is restored. Do not point any agent to the new hosts yet.

2. **Export the identity** on the 4.x Wazuh Manager host. In a distributed deployment, run it on the master node: it holds the registry of every agent, including the agents connected to the worker nodes. Stop the Wazuh Manager first; leave the 4.x Wazuh Indexer and Wazuh Dashboard running if you want to consult the 4.x alerts there ([Historical data](#historical-data)):

   ```bash
   sudo systemctl stop wazuh-manager
   sudo python3 /root/wazuh-migrate-identity.py export --with-rbac --dry-run /root/wazuh-4x-bundle
   sudo python3 /root/wazuh-migrate-identity.py export --with-rbac /root/wazuh-4x-bundle
   ```

   The dry run lists the agents and groups it carries, and ends with a **Review before going on** list: files of the `default` group that are not carried, and the features of the 4.x `ossec.conf` that 5.0 does not keep. For example:

   - The 4.x agents read `rootkit_files.txt`, `rootkit_trojans.txt` and the stock audit policies from the 4.x `default` group, which the 5.0 `default` group lacks. To keep their rootkit checks until they are upgraded, copy the files the list names from `/var/ossec/etc/shared/default/` on the 4.x Wazuh Manager to `/etc/wazuh-manager/shared/default/` on the 5.0 Wazuh Manager (owner `wazuh-manager`, mode `0660`).
   - The 4.x Wazuh Manager monitored its own host. 5.0 has no agent `000`: install an agent on the Wazuh Manager host to keep monitoring it.

3. **Import the identity** on the 5.0 Wazuh Manager host (the master node in a distributed deployment), after copying `/root/wazuh-4x-bundle` to it:

   ```bash
   PY=/var/wazuh-manager/framework/python/bin/python3
   sudo $PY /root/wazuh-migrate-identity.py import --with-rbac --dry-run /root/wazuh-4x-bundle
   sudo $PY /root/wazuh-migrate-identity.py import --with-rbac /root/wazuh-4x-bundle
   ```

   The import ends with `Inserted N of N agent(s)`.

4. **Restart the Wazuh Manager and restore the published API passwords.** With `--with-rbac`, the `wazuh` and `wazuh-internal-client` users take their 4.x passwords from the next start. The Wazuh Dashboard and the health check of the playbooks use the passwords published in `/etc/wazuh-manager/export/credentials.env`, so set both users back to them before the next run of the playbooks:

   ```bash
   sudo systemctl restart wazuh-manager
   sudo sed -n 's/^WAZUH_MANAGER_API_PASSWORD=//p' /etc/wazuh-manager/export/credentials.env \
       | sudo /var/wazuh-manager/bin/rbac_control change-password -u wazuh -p -
   sudo sed -n 's/^WAZUH_MANAGER_WUI_PASSWORD=//p' /etc/wazuh-manager/export/credentials.env \
       | sudo /var/wazuh-manager/bin/rbac_control change-password -u wazuh-internal-client -p -
   ```

   The API users you created yourself keep their 4.x passwords, roles and policies. Without these two commands, the next run of the playbooks stops at the Server API health check with `Last HTTP status: 401`.

5. **Check the result:**

   ```bash
   sudo $PY /root/wazuh-migrate-identity.py check /root/wazuh-4x-bundle
   ```

   It reports `The target matches the bundle.`

6. **Point the agents to the 5.0 Wazuh Manager**, unless it took the 4.x address. In a distributed deployment, an agent can be pointed to the master or to a worker node: the master distributes the imported keys to the workers. On each agent, set the new address in `<client><server><address>` of `ossec.conf` and restart it. Do not remove `client.keys` on the agents. Each agent reconnects with its 4.x id and key, and shows as `active` with its groups. The Wazuh Manager logs `Loaded N agent key(s)` in `/var/wazuh-manager/logs/wazuh-manager.log`.

7. **Delete the bundle** from both hosts once the migration is complete. Keep the 4.x deployment until you no longer need it to roll back or to consult its alerts.

## Same hosts

### Costs of the same hosts path

- **Downtime.** The Wazuh Manager is down from the export until the import. The agents keep retrying meanwhile.
- **No rollback.** Once 4.x is removed, going back means reinstalling 4.x and restoring it from your own backups.
- **The 4.x alerts are kept only through a snapshot**, taken while 4.x is running, to a folder that is not removed with 4.x.

### Steps

1. **Take a snapshot of the 4.x indices.** On the 4.x Wazuh Indexer host, create a folder outside the Wazuh Indexer data path, add it to `path.repo` and restart the Wazuh Indexer:

   ```bash
   sudo install -d -o wazuh-indexer -g wazuh-indexer -m 750 /var/backups/wazuh-4x-snapshots
   echo 'path.repo: ["/var/backups/wazuh-4x-snapshots"]' | sudo tee -a /etc/wazuh-indexer/opensearch.yml
   sudo systemctl restart wazuh-indexer
   ```

   Wait until the Wazuh Indexer answers again, then register the folder and take the snapshot, with the 4.x `admin` password:

   ```bash
   until curl -sk -u admin:<4.x admin password> https://<indexer address>:9200/_cluster/health | grep -q '"status"'; do sleep 5; done
   curl -sk -u admin:<4.x admin password> -X PUT https://<indexer address>:9200/_snapshot/wazuh-4x \
     -H 'Content-Type: application/json' -d '{"type":"fs","settings":{"location":"/var/backups/wazuh-4x-snapshots"}}'
   curl -sk -u admin:<4.x admin password> -X PUT 'https://<indexer address>:9200/_snapshot/wazuh-4x/alerts-4x?wait_for_completion=true' \
     -H 'Content-Type: application/json' -d '{"indices":"wazuh-alerts-4.x-*,wazuh-states-*","include_global_state":false}'
   ```

   The snapshot ends with `"state":"SUCCESS"`. Copy the folder off the host as well if you want a backup that survives the host.

   In a distributed deployment, every Wazuh Indexer node writes its own shards to the repository, so the folder must be shared storage (for example, an NFS export) mounted at the same path on every Wazuh Indexer node, and writable by the `wazuh-indexer` user on each. Add it to `path.repo` on every node and restart the nodes one at a time, waiting for the cluster to be `green` before the next. Then register the folder and take the snapshot once, against any node. With a local folder on each node, the registration fails with `repository_verification_exception`.

2. **Export the identity**, as in step 2 of [New hosts](#new-hosts). In a distributed deployment, stop the Wazuh Manager on every node and run the export on the master node. The bundle in `/root/wazuh-4x-bundle` is not removed with 4.x. If you want to copy the files of the 4.x `default` group that the **Review before going on** list names, copy them out of `/var/ossec/etc/shared/default/` now, since step 3 removes `/var/ossec`.

3. **Remove 4.x.** The playbooks have no uninstall. On every host, remove the packages, then the paths they leave behind:

   ```bash
   # RPM-based hosts
   sudo dnf -y remove wazuh-dashboard wazuh-manager wazuh-indexer filebeat
   # Debian-based hosts
   sudo apt-get -y purge wazuh-dashboard wazuh-manager wazuh-indexer filebeat

   sudo rm -rf /var/lib/wazuh-indexer /etc/wazuh-indexer /usr/share/wazuh-indexer /var/log/wazuh-indexer \
     /etc/wazuh-dashboard /usr/share/wazuh-dashboard /var/ossec \
     /etc/filebeat /var/lib/filebeat /usr/share/filebeat
   # Debian-based hosts: the 4.x package repository
   sudo rm -f /etc/apt/sources.list.d/wazuh.sources /usr/share/keyrings/wazuh.gpg
   ```

   Removing these paths is required. The package removal keeps `/var/lib/wazuh-indexer` and `/etc/wazuh-indexer` (and, on RPM-based hosts, `/etc/wazuh-dashboard` and `/var/ossec`). With them in place, the 5.0 Wazuh Indexer starts on the 4.x data and its 4.x security configuration, which rejects the 5.0 passwords: the playbook stops at `Wait for Wazuh indexer API` with `Last HTTP status: 401`. Keep the snapshot folder and the bundle outside these paths.

4. **Deploy 5.0** with the playbooks, against the same inventory, from a new clone of the `v5.0.1` tag ([Before you start](#before-you-start)). While the registry is empty, the 4.x agents ask the new Wazuh Manager for a key and are refused (`Invalid password. Unable to add agent`), because the 5.0 installation requires an enrollment password. They keep their keys and keep retrying.

5. **Import the identity, restore the published API passwords and check the result**, as in steps 3 to 5 of [New hosts](#new-hosts). The agents reconnect on their next retry with their 4.x ids, keys and groups.

6. **Restore the snapshot.** On the 5.0 Wazuh Indexer host, add the snapshot folder to `path.repo` in `/etc/wazuh-indexer/opensearch.yml`, next to the folder 5.0 already sets, and restart the Wazuh Indexer:

   ```yaml
   path.repo: ["/var/lib/wazuh-indexer/backup", "/var/backups/wazuh-4x-snapshots"]
   ```

   Wait until the Wazuh Indexer answers again, then register the folder as a read-only repository and restore the 4.x indices under another name, with the 5.0 `admin` password from `deployment-credentials/WAZUH_INDEXER_ADMIN_PASSWORD` on the control node:

   ```bash
   until curl -sk -u admin:<5.0 admin password> https://<indexer address>:9200/_cluster/health | grep -q '"status"'; do sleep 5; done
   curl -sk -u admin:<5.0 admin password> -X PUT https://<indexer address>:9200/_snapshot/wazuh-4x \
     -H 'Content-Type: application/json' -d '{"type":"fs","settings":{"location":"/var/backups/wazuh-4x-snapshots","readonly":true}}'
   curl -sk -u admin:<5.0 admin password> -X POST 'https://<indexer address>:9200/_snapshot/wazuh-4x/alerts-4x/_restore?wait_for_completion=true' \
     -H 'Content-Type: application/json' \
     -d '{"indices":"wazuh-alerts-4.x-*,wazuh-states-*","include_global_state":false,"rename_pattern":"(.+)","rename_replacement":"restored-$1"}'
   ```

   The 4.x alerts are then in `restored-wazuh-alerts-4.x-*`. A later run of the playbooks keeps `path.repo`.

   In a distributed deployment, the shared folder must still be mounted at the same path on every Wazuh Indexer node. Set `path.repo` on every node, restart the nodes one at a time as in step 1, and run the two commands once, against any node.

## Configuration and content

5.0 does not read any 4.x configuration file, and the 5.0 roles have no variables for the Wazuh Manager configuration.

- **Wazuh Manager configuration.** The 4.x `wazuh-manager` role renders `ossec.conf` from its variables (`wazuh_manager_config` and the `wazuh_manager_*` variables) and the 4.x `local_internal_options.conf` from its own template. They have no counterpart in the 5.0 roles, which only set the Wazuh Indexer hosts and the cluster settings of each node. Rewrite the settings you need in `/etc/wazuh-manager/wazuh-manager.conf` on each 5.0 Wazuh Manager node, as the [Manager configuration migration](https://github.com/wazuh/wazuh/blob/5.0.1/docs/guide/migration/manager-configuration-migration.md) guide describes, taking the 4.x values from the rendered `/var/ossec/etc/ossec.conf` or from your 4.x variables. Validate the file and restart the Wazuh Manager:

  ```bash
  sudo /var/wazuh-manager/bin/wazuh-manager-conf validate
  sudo systemctl restart wazuh-manager
  ```

- **Later runs of the playbooks** keep these edits, with these exceptions in `wazuh-manager.conf`, which the `wazuh-manager` role sets on every run: the `<hosts>` of `<indexer>`, the `<node_name>`, `<node_type>`, `<key>` and `<node>` entries of `<cluster>`, and every `<bind_addr>`, which is set to `0.0.0.0`, the agent listener's `<remote><https><bind_addr>` included. The `wazuh-indexer` role sets only `network.host`, `node.name`, `cluster.initial_cluster_manager_nodes`, `discovery.seed_hosts`, `plugins.security.nodes_dn` and `discovery.type` in `opensearch.yml`, and the heap size in `jvm.options`; the `wazuh-dashboard` role only `opensearch.hosts` and the Server API `url` in `opensearch_dashboards.yml`. Other settings in those files are kept.
- **Rules, decoders and CDB lists** are rewritten as detection rules, engine decoders and KVDBs: [rules](https://github.com/wazuh/wazuh/blob/5.0.1/docs/guide/migration/rules-4x-to-5x.md), [decoders](https://github.com/wazuh/wazuh/blob/5.0.1/docs/guide/migration/xml-decoders-migration.md), [CDB lists](https://github.com/wazuh/wazuh/blob/5.0.1/docs/guide/migration/cdb-to-kvdb-migration.md).
- **Group folders** (`shared/<group>/`) are carried by `wazuh-migrate-identity.py`. Each `agent.conf` must be valid for 5.0.

## Historical data

The 5.0 Wazuh Manager indexes events into `wazuh-events-v5-*` and findings into `wazuh-findings-v5-*`, and does not read or migrate the 4.x `wazuh-alerts-4.x-*` and `wazuh-states-*` indices. Because the agent ids are preserved, the 4.x documents and the 5.0 ones refer to the same agent by the same id.

- **New hosts.** The 4.x Wazuh Indexer and Wazuh Dashboard keep serving the 4.x alerts while they run, with the 4.x Wazuh Manager stopped.
- **Same hosts.** The snapshot restored in step 6 makes them available in the 5.0 Wazuh Indexer as `restored-wazuh-alerts-4.x-*`, for consultation only.
