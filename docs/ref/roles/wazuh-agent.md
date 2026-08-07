# wazuh-agent Role

## Description

The `wazuh-agent` role installs the Wazuh Agent on target nodes running Linux, Windows, or macOS.

The role detects the target operating system at runtime and delegates to the appropriate platform-specific task file (`Linux.yml`, `Windows.yml`, or `macOS.yml`). On Linux, it further delegates to either `RedHat.yml` or `Debian.yml` depending on the OS family.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml` and `vars/artifact_urls.yaml`. |
| Linux tasks | Imports `Linux.yml` when the target system is Linux, which in turn imports the appropriate distribution-specific tasks. |
| Windows tasks | Imports `Windows.yml` when the target OS family is Windows. |
| macOS tasks | Imports `macOS.yml` when the target system is Darwin (macOS). |

### Platform-specific tasks

On **Linux (RHEL-based)**, the role downloads and installs the `.rpm` package for the detected architecture (`x86_64` or `aarch64`) using `dnf`.

On **Linux (Debian-based)**, the role downloads and installs the `.deb` package for the detected architecture (`amd64` or `arm64`) using `apt`.

On **Windows**, the role downloads and installs the `.msi` package using the Windows package manager.

On **macOS**, the role downloads and installs the `.pkg` package for either ARM64 (Apple Silicon) or Intel64 architectures.

## Usage

This role is used exclusively in the `wazuh-agent.yml` playbook and is applied to all hosts defined under the `[agents]` group in the inventory file.

## Related

- [Variables](../variables.md#wazuh-agent)
- [Deployment](../deployment.md)
