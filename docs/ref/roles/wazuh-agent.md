# wazuh-agent Role

## Description

The `wazuh-agent` role installs the Wazuh Agent on target nodes running Linux, Windows, or macOS. On Windows and macOS it also provisions the manager's CA certificate so the agent can verify the manager's TLS certificate; on Linux, a 5.x agent enrolls with a single enrollment token instead (see below).

The role detects the target operating system at runtime and delegates to the appropriate platform-specific task file (`Linux.yml`, `Windows.yml`, or `macOS.yml`). On Linux, it further delegates to either `RedHat.yml` or `Debian.yml` depending on the OS family.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml` and `vars/artifact_urls.yaml`. |
| Validate variables | Imports `validate.yml`, which checks `wazuh_registration_ca` and `wazuh_ssl_verification` before anything is installed. |
| Linux tasks | Imports `Linux.yml` when the target system is Linux, which in turn imports the appropriate distribution-specific tasks. |
| Windows tasks | Imports `Windows.yml` when the target OS family is Windows. |
| macOS tasks | Imports `macOS.yml` when the target system is Darwin (macOS). |

### Platform-specific tasks

On **Linux (RHEL-based)**, the role downloads and installs the `.rpm` package for the detected architecture (`x86_64` or `aarch64`) using `dnf`.

On **Linux (Debian-based)**, the role downloads and installs the `.deb` package for the detected architecture (`amd64` or `arm64`) using `apt`.

On **Windows**, the role downloads and installs the `.msi` package using the Windows package manager.

On **macOS**, the role downloads and installs the `.pkg` package for either ARM64 (Apple Silicon) or Intel64 architectures.

## Linux enrollment (token-based)

Since [wazuh/wazuh#39063](https://github.com/wazuh/wazuh/issues/39063), a 5.x Linux agent enrolls with a single `wazuh_enrollment_token`, mapped to the `WAZUH_ENROLLMENT_TOKEN` install-time variable. The manager address and the CA pin travel inside the token itself: the agent fetches the manager's CA over `/cacerts` on its first start and verifies it against the token's pin, so no CA file is pre-staged and `wazuh_registration_ca` has no effect on Linux.

This replaces the classic `WAZUH_MANAGER`/`WAZUH_REGISTRATION_PASSWORD`/`WAZUH_REGISTRATION_CA` contract on Linux only. Windows and macOS still use that classic contract, described in the rest of this section — this change does not cover them, regardless of whether their underlying installers still require it.

`wazuh_enrollment_token` has no default and must be provided by the operator (see `wazuh-agent.yml`) — this role does not mint tokens. A token is minted against a running manager, for example with `wazuh-manager-authd --create-enrollment-token --address <address>`; `<address>` must be one the manager's listener certificate SAN actually names, or minting is refused.

## CA provisioning (Windows and macOS)

When `wazuh_registration_ca` is set, the role copies that CA certificate to the target node **before** installing the package, and passes the remote path to the installer as the `WAZUH_REGISTRATION_CA` install-time variable. The installer pins the path into `<agent><ssl><certificate_authorities>` in `ossec.conf`, which governs all agent↔manager HTTPS traffic and is read on every agent start.

Three properties of this flow are worth knowing before changing these tasks:

- **The copy must stay ahead of the install.** The agent's installer script rejects a missing or unreadable `WAZUH_REGISTRATION_CA` path, only writes a line to its own log, and still exits `0`. A CA copied after the package install would therefore never be pinned, silently.
- **The destination is the agent's own CA drop-in path**, not a temporary one: `/Library/Ossec/etc/certs/root-ca.pem` on macOS, and `<install dir>\certs\root-ca.pem` on Windows. This is the location the agent's own upgrade path looks for, so the same file also satisfies a later WPK upgrade against a self-signed manager, and it is removed when the agent is uninstalled. The role creates the directory, since it does not exist before the package install.
- **The result is verified.** After the install, the role reads `ossec.conf` back and asserts that `<certificate_authorities>` holds the expected path (`wazuh_agent_verify_registration_ca`, default `true`). Both ways this can fail are otherwise silent — see below.

`wazuh_ssl_verification` maps to the `SSL_VERIFICATION` install-time variable and sets `<agent><ssl><verification_mode>` explicitly. Left empty, the effective mode is `certificate` when a CA is provisioned, which validates the certificate chain but does **not** check the manager's hostname; `full` adds the hostname check, and `none` disables verification for lab and CI deployments. `system` cannot be combined with `wazuh_registration_ca` — the agent refuses to start with both set — and the role rejects that combination up front.

### Existing agents are not reconfigured

**The role only wires the CA on a fresh install.** Adding `wazuh_registration_ca` to the inventory and re-running the playbook against agents that are already installed does not configure them: `win_package` skips an install that is already satisfied, and the macOS path is explicitly guarded on `pkgutil`, so the installer script that writes `<certificate_authorities>` never runs. The CA file is copied and the play reports success regardless.

The post-install assertion is what makes this visible instead of silent. To remediate an existing agent, either remove the agent and re-run this role, or add the tag to `ossec.conf` by hand inside `<agent><ssl>` and restart the agent:

```xml
<certificate_authorities>/Library/Ossec/etc/certs/root-ca.pem</certificate_authorities>
```

## Usage

This role is used exclusively in the `wazuh-agent.yml` playbook and is applied to all hosts defined under the `[agents]` group in the inventory file.

## Related

- [Variables](../variables.md#wazuh-agent)
- [Deployment](../deployment.md)
