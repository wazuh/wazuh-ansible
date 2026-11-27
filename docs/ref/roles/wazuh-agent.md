# wazuh-agent Role

## Description

The `wazuh-agent` role installs the Wazuh Agent on target nodes running Linux, Windows, or macOS, and enrolls it with the manager using a single enrollment token (see below).

The role detects the target operating system at runtime and delegates to the appropriate platform-specific task file (`Linux.yml`, `Windows.yml`, or `macOS.yml`). On Linux, it further delegates to either `RedHat.yml` or `Debian.yml` depending on the OS family.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml` and `vars/artifact_urls.yaml`. |
| Validate variables | Imports `validate.yml`, which fails if `wazuh_enrollment_token` is empty or holds a placeholder such as `<Your Wazuh Agent Enrollment Token>`, or if `wazuh_ssl_verification` is set and is not one of `full`, `certificate`, `system` or `none`, before anything is installed. |
| Linux tasks | Imports `Linux.yml` when the target system is Linux, which in turn imports the appropriate distribution-specific tasks and checks that the downloaded package is signed with the Wazuh GPG key before it is installed (see [package-urls](package-urls.md)). |
| Windows tasks | Imports `Windows.yml` when the target OS family is Windows, which checks the Authenticode signature of the downloaded `.msi` before it is installed (see [package-urls](package-urls.md)). |
| macOS tasks | Imports `macOS.yml` when the target system is Darwin (macOS), which checks the Developer ID Installer signature of the downloaded `.pkg` before it is installed (see [package-urls](package-urls.md)). |

### Platform-specific tasks

On **Linux (RHEL-based)**, the role downloads and installs the `.rpm` package for the detected architecture (`x86_64` or `aarch64`) using `dnf`.

On **Linux (Debian-based)**, the role downloads and installs the `.deb` package for the detected architecture (`amd64` or `arm64`) using `apt`.

On **Windows**, the role downloads the `.msi` package, checks that it has a valid Authenticode signature from Wazuh, and installs it using the Windows package manager.

On **macOS**, the role downloads the `.pkg` package for either ARM64 (Apple Silicon) or Intel64 architectures, checks that it is signed with the Wazuh Developer ID Installer certificate, and installs it.

## Enrollment (token-based)

A 5.x agent — on Linux, Windows and macOS alike — enrolls with a single `wazuh_enrollment_token`, mapped to the `WAZUH_ENROLLMENT_TOKEN` install-time variable (an MSI property on Windows, passed via a temporary env file on macOS). The manager address always travels inside the token itself. The CA does too, one of two ways: by default the agent fetches it over `/cacerts` on its first start and verifies it against the token's pin; a token minted with `--embed-ca` carries the CA directly and the agent skips that fetch. Either way, no CA file is pre-staged and no separate CA-provisioning step exists in this role.

The token replaces the 4.x `WAZUH_MANAGER`/`WAZUH_REGISTRATION_PASSWORD`/`WAZUH_REGISTRATION_CA` deployment variables entirely — the 5.x installer on every platform warns and ignores those variables rather than acting on them.

`wazuh_enrollment_token` is empty by default; this role does not mint tokens. A token is minted against a running manager with `wazuh-manager-authd --create-enrollment-token --address <address>`; `<address>` must be one the manager's listener certificate SAN actually names, or minting is refused. Set it in the inventory, `group_vars`, a vaulted file or with `-e` to use your own token.

When it is not set, `wazuh-agent.yml` mints one before installing the agents, on the Wazuh manager of the inventory: `wazuh_enrollment_token_manager`, by default the first host of the `aio` group or, in a distributed deployment, the `manager` host (the master node). The task is delegated to it from the agent hosts, so `--limit` on the agents still runs it, and the manager host must be in the inventory and reachable over SSH. The token is minted for `wazuh_enrollment_token_address`, by default the first of the manager's `agent_san`, `wazuh_manager_ips`, `ansible_host` (when its certificates name it, see `wazuh_manager_san_ansible_host`) and `private_ip`; it allows one enrollment for each agent host of the run and expires after `wazuh_enrollment_token_ttl` (`1d`). The run prints the token id, its expiry and any warning from the manager, never the token. Each run without `wazuh_enrollment_token` mints a new token, also when every agent is already installed and does not use it (see below); `wazuh-manager-authd --list-enrollment-tokens` lists them.

`wazuh_ssl_verification` maps to the `WAZUH_SSL_VERIFICATION` install-time variable and sets `<agent><ssl><verification_mode>` explicitly: `full` (CA and hostname), `certificate` (CA only), `system` (OS trust store) or `none` (lab/CI). Left empty, the tag is unset.

### Do not set `full` or `certificate` on a fresh token install

An explicit `full` or `certificate` deadlocks a fresh agent installed with `wazuh_enrollment_token`: `wazuh-agentd` refuses to start (error `4118`, `<certificate_authorities>` missing) because it validates that tag **before** daemonizing, but the CA it expects is only written by the enrollment-token bootstrap, which runs **on** the first daemon start the validation just refused. The daemon never recovers on its own once installed this way; it has to be removed and reinstalled with `wazuh_ssl_verification` empty.

Leaving `wazuh_ssl_verification` empty (the default) does not disable verification: `<ssl>` is left out of `ossec.conf` entirely, the bootstrap runs normally, and the agent verifies against the bootstrapped CA from then on, also after a restart.

### Existing agents are not reconfigured

**The role only wires the token on a fresh install.** The installers apply `WAZUH_ENROLLMENT_TOKEN`/`WAZUH_SSL_VERIFICATION` on a fresh install only — Debian's `postinst`, the RPM `%post`, the macOS `postinstall.sh` and the Windows MSI all gate that step on "this is not an upgrade of an already-installed agent". On top of that, the role skips the download, the signature check and the installation of an agent already installed: on Linux at the version and revision in the name of its package URL, on Windows at `wazuh_full_version` (the MSI records no revision), and on macOS whenever `pkgutil` lists it. So re-running this role against an agent that is already installed passes `wazuh_enrollment_token`/`wazuh_ssl_verification` to nothing, and still reports success.

An agent whose first run failed — an expired, revoked or otherwise refused token — stays installed but never enrolled. An empty token, or a placeholder, is caught by `validate.yml` before anything is installed. Fixing the token in the inventory and re-running the role does **not** recover it; the package is already present, so the install task (and the token with it) is skipped. The only fix is to remove the agent and run this role again, or, to change `wazuh_ssl_verification` on an agent that already enrolled successfully, edit `<verification_mode>` in `ossec.conf` by hand and restart the agent.

### Reruns

The agent is restarted only when this run installed its package; otherwise the role only makes sure it runs. The Linux packages and the Windows MSI do not start the agent, so the role starts a new installation itself; on macOS, the role loads and starts it after the installation.

## Usage

This role is used exclusively in the `wazuh-agent.yml` playbook and is applied to all hosts defined under the `[agents]` group in the inventory file.

## Related

- [Variables](../variables.md#wazuh-agent)
- [Deployment](../deployment.md)
