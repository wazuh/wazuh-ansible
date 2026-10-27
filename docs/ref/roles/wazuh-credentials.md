# wazuh-credentials Role

## Description

The `wazuh-credentials` role provides the passwords, the names of the certificates and, in a distributed deployment, the certificate authority (CA) of a Wazuh deployment to the Wazuh Indexer, Wazuh Manager, and Wazuh Dashboard packages, which set up their credentials and certificates from them when they are installed.

In a distributed deployment, it generates the five passwords and one CA once, on the control node, and keeps them next to the playbook: the passwords in `deployment-credentials/`, one file per key, and the CA in `deployment-config-files/wazuh-ca/`, where it also issues every certificate of the deployment. Every later run reuses them. On each host, before the component's package is installed, it writes the keys that the component reads to `/etc/<package>/local.env`, and stages the CA certificate (never its key) and the certificates of the host. This is the model of the installation assistant.

In an All-in-One deployment (`single_node`), the packages mint their own CAs and generate the passwords nobody supplied: the role writes only the names of the certificates and the passwords that already have a value to `local.env`, and copies the passwords each package publishes to `deployment-credentials/`.

The `wazuh-indexer`, `wazuh-manager`, and `wazuh-dashboard` roles include it; it is not listed in the playbooks.

## Tasks

| Task | Description |
|------|-------------|
| Validate supplied passwords | Checks the values in `wazuh_credentials_overrides` against the password policy of the packages: 12 to 64 characters from `A-Z a-z 0-9 . , _ + : @ % ^ = ~ -`, with at least one upper case letter, one lower case letter, one digit, and one symbol. Runs once, on the control node. |
| Generate passwords | Writes each missing key to `deployment-credentials/` (`0600`), from `wazuh_credentials_overrides` or as a random value that follows the same policy. All-in-One, only the supplied keys. An existing file is never overwritten. |
| Load passwords | Reads the keys in `deployment-credentials/` for the rest of the play. |
| Create the CA (`ca.yml`) | Distributed only, once, on the control node: creates the CA of the deployment in `wazuh_ca_path` when there is none (RSA 2048, SHA-256, ten years), and issues from it the `admin` pair of the Wazuh Indexer. An existing CA or pair is never replaced. The pairs are issued by `files/wazuh-issue-pair.sh`, with the profile of the installation assistant's certificates tool and backdated one day. |
| Refuse another deployment (`deploy.yml`) | Distributed only: before anything is written on a host, fails if `/etc/<package>/ca/root-ca.pem` is not the CA of this deployment. |
| Provide the credentials and the certificates (`deploy.yml`) | Only before the component's package is installed: writes the component's keys that have a value and the names of its certificates to `/etc/<package>/local.env` (`root:root`, `0600`). Distributed, it also issues the pairs of the host on the control node (`wazuh_credentials_component_pairs`, in `wazuh_ca_path/issued/<inventory host>/`) and stages them in `certs/`, with the CA certificate as `ca/root-ca.pem` (indexer and manager) and as the CA of each peer (`certs/<peer>-ca.pem`), and, on a manager, `certs/root-ca.pem` and, unless `wazuh_manager_indexer_client_certificate` is `false`, the node's own client pair for the Wazuh Indexer (`indexer-connector.pem`: the node name as CN, client authentication, the node's names and addresses). |
| Hand the certificates to the manager (`peer_trust.yml`) | Distributed only, after the Wazuh Manager package is installed: gives `certs/` to `root:wazuh-manager` (`0750`, files `0640`) and runs `wazuh-manager-resolve-credentials --upgrade`, which issues nothing. |
| Use the published passwords (`published.yml`) | Reads `/etc/<package>/export/credentials.env` on the host and uses those values for the health checks. All-in-One, copies them to `deployment-credentials/`; distributed, a value that differs from `deployment-credentials/` is reported by key name. |
| Start the service (`start_service.yml`) | Restarts the service when the caller sets `wazuh_service_restart`, or when one of `wazuh_service_watched_files` changed after the service started (a run stopped before the restart); otherwise only starts it. Then checks that it is still active a few seconds later. When it is not, fails with the `MISSING`, `INVALID`, or `UNSAFE` lines of its pre-start check, or with the last errors of its journal. |

No task prints a password or a private key.

## Keys

| Key | Account | Components that read it |
|-----|---------|-------------------------|
| `WAZUH_INDEXER_ADMIN_PASSWORD` | `admin` (Wazuh Indexer) | Wazuh Indexer |
| `WAZUH_INDEXER_KIBANASERVER_PASSWORD` | `kibanaserver` (Wazuh Indexer) | Wazuh Indexer, Wazuh Dashboard |
| `WAZUH_INDEXER_MANAGER_PASSWORD` | `wazuh-manager` (Wazuh Indexer) | Wazuh Indexer, Wazuh Manager |
| `WAZUH_MANAGER_API_PASSWORD` | `wazuh` (Wazuh server API) | Wazuh Manager |
| `WAZUH_MANAGER_WUI_PASSWORD` | `wazuh-internal-client` (Wazuh server API; used by the Wazuh Dashboard, not a login account) | Wazuh Manager, Wazuh Dashboard |

A supplied password is only used the first time a deployment is created: a component that already resolved its credentials keeps them.

## Usage

The role runs from the `wazuh-indexer`, `wazuh-manager`, and `wazuh-dashboard` roles, before and after each package is installed.

Keep `deployment-credentials/` and `deployment-config-files/`: they are the only record of the passwords and the CA of the deployment. They are in `.gitignore`.

## Related

- [Variables](../variables.md#wazuh-credentials)
- [Deployment](../deployment.md#credentials-and-certificates)
