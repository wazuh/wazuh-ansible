# wazuh-credentials Role

## Description

The `wazuh-credentials` role provides the passwords of a Wazuh deployment to the Wazuh Indexer, Wazuh Manager, and Wazuh Dashboard packages, which read them when they are installed.

It generates the five passwords of the deployment once, on the control node, and keeps them in `deployment-credentials/`, next to the playbook, one file per key. Every later run reuses them. On each host, it writes only the keys that the host's component reads to `/etc/wazuh/credentials.env`, before the component's package is installed. Once the package is installed, the file is not written again: the package only reads it at installation.

The `wazuh-indexer`, `wazuh-manager`, and `wazuh-dashboard` roles include it; it is not listed in the playbooks.

## Tasks

| Task | Description |
|------|-------------|
| Validate supplied passwords | Checks the values in `wazuh_credentials_overrides` against the password policy of the packages: 12 to 64 characters from `A-Z a-z 0-9 . , _ + : @ % ^ = ~ -`, with at least one upper case letter, one lower case letter, one digit, and one symbol. Runs once, on the control node. |
| Generate passwords | Writes each missing key to `deployment-credentials/` (`0600`), from `wazuh_credentials_overrides` or as a random value that follows the same policy. An existing file is never overwritten. |
| Load passwords | Reads the five keys for the rest of the play. |
| Refuse another deployment | Before anything is written on a host, fails if its `/etc/wazuh/ca/root-ca.pem` is not the root CA of this deployment. Before the component's package is installed, it also fails if the host's `/etc/wazuh/credentials.env` holds another value for one of the component's keys. The message names only the keys. |
| Provide the component credentials | Only before the component's package is installed: writes the component's keys to `/etc/wazuh/credentials.env` (`root:root`, `0600`, in `/etc/wazuh` `0700`), in a block of its own outside the one the packages manage. |

No task prints a password.

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

The role runs from the `wazuh-indexer`, `wazuh-manager`, and `wazuh-dashboard` roles, before each package is installed. It does not remove `/etc/wazuh/credentials.env`; see [What to keep](../deployment.md#what-to-keep).

Keep `deployment-credentials/`: it is the only record of the passwords of the deployment. It is in `.gitignore`.

## Related

- [Variables](../variables.md#wazuh-credentials)
- [Deployment](../deployment.md#credentials-and-certificates)
