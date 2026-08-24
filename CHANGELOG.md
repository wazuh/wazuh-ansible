## [v5.0.1]

### Added

| Issue | Comment |
| - | - |

### Changed

| Issue | Comment |
| - | - |
| [#2248](https://github.com/wazuh/wazuh-ansible/issues/2248) | Change Codebuild runners to Github runners. |
| [#2213](https://github.com/wazuh/wazuh-ansible/issues/2213) | Change upload and download methods. |
| [#2203](https://github.com/wazuh/wazuh-ansible/issues/2203) | Update deployment for Wazuh Indexer 5.0.0 RBAC. |
| [#2189](https://github.com/wazuh/wazuh-ansible/issues/2189) | Set Wazuh Indexer JVM heap size to one quarter of the host total memory for AIO deployments. |
| [#2205](https://github.com/wazuh/wazuh-ansible/pull/2205) | Add new WF for changelog check |
| [#2186](https://github.com/wazuh/wazuh-ansible/issues/2186) | Set authd password in agents installation. |
| [#2153](https://github.com/wazuh/wazuh-ansible/issues/2153) | Migrate the GHA runner to CodeBuild |
| [#2142](https://github.com/wazuh/wazuh-ansible/issues/2142) | Change file and workflow names for PR Revamp tasks |
| [#2093](https://github.com/wazuh/wazuh-ansible/issues/2093) | Forbid run test in draft PRs |
| [#2044](https://github.com/wazuh/wazuh-ansible/issues/2044) | Update Wazuh manager certificates handling |
| [#2036](https://github.com/wazuh/wazuh-ansible/issues/2036) | Change the destination path of the artifact_urls file in wazuh-ansible |
| [#1982](https://github.com/wazuh/wazuh-ansible/issues/1982) | Adapt the Ansible deployment according to the config.yml changes |
| [#1992](https://github.com/wazuh/wazuh-ansible/issues/1992) | Ansible - Standarize Artifact URL keys |
| [#1986](https://github.com/wazuh/wazuh-ansible/issues/1986) | Update package artifact URLs and standardize artifact file extension |
| [#1981](https://github.com/wazuh/wazuh-ansible/issues/1981) | Fixed INSTALLATION.md file. |
| [#1980](https://github.com/wazuh/wazuh-ansible/issues/1980) | Updated wazuh-ansible documentation config and tooling versions to meet new standards. |
| [#1948](https://github.com/wazuh/wazuh-ansible/issues/1948) | URL presigned file - Update the Wazuh ansible tests workflows |
| [#1941](https://github.com/wazuh/wazuh-ansible/issues/1941) | Development - Separate Agent/Manager - Ansible - E2E Tests |
| [#1955](https://github.com/wazuh/wazuh-ansible/issues/1955) | Wazuh Manager/agent Separation - Breaking changes summary |
| [#1937](https://github.com/wazuh/wazuh-ansible/issues/1937) | Development - Separate Agent/Manager - Ansible - Roles and playbooks update |
| [#1938](https://github.com/wazuh/wazuh-ansible/issues/1938) | Development - Separate Agent/Manager - Ansible - GitHub playbooks and workflows updates |
| [#1939](https://github.com/wazuh/wazuh-ansible/issues/1939) | Development - Separate Agent/Manager - Ansible - Documentation update |
| [#1922](https://github.com/wazuh/wazuh-ansible/issues/1922) | Update workflows to include installation-assistant in COMMIT_LIST |
| [#1925](https://github.com/wazuh/wazuh-ansible/issues/1925) | Update outdated references to branch v5.0.0 |
| [#1912](https://github.com/wazuh/wazuh-ansible/issues/1912) | Adapt main branch to latest changes |
| [#1896](https://github.com/wazuh/wazuh-ansible/issues/1896) | Composite names update |
| [#1860](https://github.com/wazuh/wazuh-ansible/issues/1860) | Implement pending adaptation tasks |
| [#1855](https://github.com/wazuh/wazuh-ansible/issues/1855) | Replace all occurrences of Wazuh server with Wazuh manager |
| [#1852](https://github.com/wazuh/wazuh-ansible/issues/1852) | Documentation backport and adaptation |
| [#1846](https://github.com/wazuh/wazuh-ansible/issues/1846) | GHA workflows backport and adaptation |
| [#1842](https://github.com/wazuh/wazuh-ansible/issues/1842) | Logs gathering playbook backport and adaptation |
| [#1840](https://github.com/wazuh/wazuh-ansible/issues/1840) | Distributed deployment adaptation from backport |
| [#1834](https://github.com/wazuh/wazuh-ansible/issues/1834) | Agent role backport and adaptation |
| [#1831](https://github.com/wazuh/wazuh-ansible/issues/1831) | Dashboard role backport and adaptation |
| [#1825](https://github.com/wazuh/wazuh-ansible/issues/1825) | Server role backport and adaptation |
| [#1823](https://github.com/wazuh/wazuh-ansible/issues/1823) | Indexer role backport and adaptation |
| [#1819](https://github.com/wazuh/wazuh-ansible/issues/1819) | Ansible base configuration files and directories backport |
| [#1735](https://github.com/wazuh/wazuh-ansible/issues/1735) | Remove Wazuh Manager deprecated daemons and CLI tools |
| [#1714](https://github.com/wazuh/wazuh-ansible/issues/1714) | Bucket migrate from packages-dev.wazuh.com to xdrsiem-packages-dev |
| [#1697](https://github.com/wazuh/wazuh-ansible/issues/1697) | DevOps - Ansible - OpenSearch 3.0 deprecated settings |
| [#1709](https://github.com/wazuh/wazuh-ansible/issues/1709) | Bucket migration for packages-dev.wazuh.com |

### Removed

| Issue | Comment |
| - | - |
| [#2239](https://github.com/wazuh/wazuh-ansible/issues/2239) | Remove unnecessary `debhelper` install-time dependency from the `wazuh-dashboard` role. |

### Fixed

| Issue | Comment |
| - | - |
| [#2246](https://github.com/wazuh/wazuh-ansible/issues/2246) | Report skipped bumps in the repository bumper workflow |
| [#2233](https://github.com/wazuh/wazuh-ansible/issues/2233) | Fix changelog check to accept Prior versions entries |
| [#2218](https://github.com/wazuh/wazuh-ansible/issues/2218) | RedHat-based agent install task does not set WAZUH_REGISTRATION_PASSWORD, breaking auto-enrollment. |
| [#2206](https://github.com/wazuh/wazuh-ansible/issues/2206) | Wazuh-manager master and worker nodes keys do not match. |
| [#2195](https://github.com/wazuh/wazuh-ansible/pull/2195) | Fix bumper workflow failure when bump produces no changes |
| [#2159](https://github.com/wazuh/wazuh-ansible/issues/2159) | Bumper script issue when the tag is set to false |
| [#2045](https://github.com/wazuh/wazuh-ansible/issues/2045) | Ansible deployment fails on needrestart task when no services require restart |
| [#2056](https://github.com/wazuh/wazuh-ansible/issues/2056) | No idempotency for the `opensearch.yml` configurations |

## Prior versions

- [v5.0.0](https://github.com/wazuh/wazuh-ansible/blob/v5.0.0/CHANGELOG.md)
