# wazuh-agent Role

## Description

The `wazuh-agent` role installs the Wazuh Agent on target nodes running Linux, Windows, or macOS, and enrolls it with the manager using a single enrollment token (see below).

The role detects the target operating system at runtime and delegates to the appropriate platform-specific task file (`Linux.yml`, `Windows.yml`, or `macOS.yml`). On Linux, it further delegates to either `RedHat.yml` or `Debian.yml` depending on the OS family.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml` and `vars/artifact_urls.yaml`. |
| Validate variables | Imports `validate.yml`, which checks `wazuh_ssl_verification` before anything is installed. |
| Linux tasks | Imports `Linux.yml` when the target system is Linux, which in turn imports the appropriate distribution-specific tasks. |
| Windows tasks | Imports `Windows.yml` when the target OS family is Windows. |
| macOS tasks | Imports `macOS.yml` when the target system is Darwin (macOS). |

### Platform-specific tasks

On **Linux (RHEL-based)**, the role downloads and installs the `.rpm` package for the detected architecture (`x86_64` or `aarch64`) using `dnf`.

On **Linux (Debian-based)**, the role downloads and installs the `.deb` package for the detected architecture (`amd64` or `arm64`) using `apt`.

On **Windows**, the role downloads and installs the `.msi` package using the Windows package manager.

On **macOS**, the role downloads and installs the `.pkg` package for either ARM64 (Apple Silicon) or Intel64 architectures.

## Enrollment (token-based)

Since [wazuh/wazuh#39063](https://github.com/wazuh/wazuh/issues/39063), a 5.x agent — on Linux, Windows and macOS alike — enrolls with a single `wazuh_enrollment_token`, mapped to the `WAZUH_ENROLLMENT_TOKEN` install-time variable (an MSI property on Windows, passed via a temporary env file on macOS). The manager address and the CA pin both travel inside the token itself: the agent fetches the manager's CA over `/cacerts` on its first start and verifies it against the token's pin, so no CA file is pre-staged and no separate CA-provisioning step exists in this role.

This replaces the classic `WAZUH_MANAGER`/`WAZUH_REGISTRATION_PASSWORD`/`WAZUH_MANAGER_ENDPOINT`/`WAZUH_REGISTRATION_CA` contract entirely — the installer on every platform now warns and ignores those variables rather than acting on them.

`wazuh_enrollment_token` has no default and must be provided by the operator (see `wazuh-agent.yml`) — this role does not mint tokens. A token is minted against a running manager, for example with `wazuh-manager-authd --create-enrollment-token --address <address>`; `<address>` must be one the manager's listener certificate SAN actually names, or minting is refused.

`wazuh_ssl_verification` maps to the `WAZUH_SSL_VERIFICATION` install-time variable and sets `<agent><ssl><verification_mode>` explicitly: `full` (CA and hostname), `certificate` (CA only), `system` (OS trust store) or `none` (lab/CI). Left empty, the tag is unset.

### Do not set `full` or `certificate` on a fresh token install

An explicit `full` or `certificate` deadlocks a fresh agent installed with `wazuh_enrollment_token`: `wazuh-agentd` refuses to start (error `4118`, `<certificate_authorities>` missing) because it validates that tag **before** daemonizing, but the CA it expects is only written by the enrollment-token bootstrap, which runs **on** the first daemon start the validation just refused. Verified against a real 5.0.0 agent — the daemon never recovers on its own once installed this way; it has to be removed and reinstalled with `wazuh_ssl_verification` empty.

Leaving `wazuh_ssl_verification` empty (the default) does not disable verification: `<ssl>` is left out of `ossec.conf` entirely, the bootstrap runs normally, and the agent verifies against the bootstrapped CA from then on — confirmed against a real agent, including a restart after enrollment. `full`/`certificate` are safe to set only once an agent already has a trust anchor on disk (for example, when re-running this role against an agent enrolled earlier without one).

## Usage

This role is used exclusively in the `wazuh-agent.yml` playbook and is applied to all hosts defined under the `[agents]` group in the inventory file.

## Related

- [Variables](../variables.md#wazuh-agent)
- [Deployment](../deployment.md)
