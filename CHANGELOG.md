# Change Log
All notable changes to this project will be documented in this file.

## [v5.0.0]

### Added

- Added bump-issue-link support for Revert Stage Bump. ([#2173](https://github.com/wazuh/wazuh-ansible/pull/2173))
- Add integration test module docs ([#2166](https://github.com/wazuh/wazuh-ansible/pull/2166))
- Implement the wazuh-ansible integration testing module ([#1920](https://github.com/wazuh/wazuh-ansible/issues/1920))
- Add new tags on PR tests ([#2095](https://github.com/wazuh/wazuh-ansible/issues/2095))
- Add roles and variables documentation ([#2088](https://github.com/wazuh/wazuh-ansible/issues/2088))
- Support Revert bump functionality in wazuh-ansible ([#2019](https://github.com/wazuh/wazuh-ansible/issues/2019))
- Add `--set-as-main` flag support to repository bumper — `wazuh-ansible` ([#1991](https://github.com/wazuh/wazuh-ansible/issues/1991))
- Bring missing workflows to `main` ([#1643](https://github.com/wazuh/wazuh-ansible/issues/1643))

### Changed

- Migrate the GHA runner to CodeBuild ([#2153](https://github.com/wazuh/wazuh-ansible/issues/2153))
- Change file and workflow names for PR Revamp tasks ([#2142](https://github.com/wazuh/wazuh-ansible/issues/2142))
- Forbid run test in draft PRs ([#2093](https://github.com/wazuh/wazuh-ansible/issues/2093))
- Update Wazuh manager certificates handling ([#2044](https://github.com/wazuh/wazuh-ansible/issues/2044))
- Change the destination path of the artifact_urls file in wazuh-ansible ([#2036](https://github.com/wazuh/wazuh-ansible/issues/2036))
- Adapt the Ansible deployment according to the config.yml changes ([#1982](https://github.com/wazuh/wazuh-ansible/issues/1982))
- Ansible - Standarize Artifact URL keys ([#1992](https://github.com/wazuh/wazuh-ansible/issues/1992))
- Update package artifact URLs and standardize artifact file extension ([#1986](https://github.com/wazuh/wazuh-ansible/issues/1986))
- Fixed INSTALLATION.md file. ([#1981](https://github.com/wazuh/wazuh-ansible/issues/1981))
- Updated wazuh-ansible documentation config and tooling versions to meet new standards. ([#1980](https://github.com/wazuh/wazuh-ansible/issues/1980))
- URL presigned file - Update the Wazuh ansible tests workflows ([#1948](https://github.com/wazuh/wazuh-ansible/issues/1948))
- Development - Separate Agent/Manager - Ansible - E2E Tests ([#1941](https://github.com/wazuh/wazuh-ansible/issues/1941))
- Development - Separate Agent/Manager - Ansible - E2E Tests ([#1941](https://github.com/wazuh/wazuh-ansible/issues/1941))
- Wazuh Manager/agent Separation - Breaking changes summary ([#1955](https://github.com/wazuh/wazuh-ansible/issues/1955))
- Development - Separate Agent/Manager - Ansible - Roles and playbooks update ([#1937](https://github.com/wazuh/wazuh-ansible/issues/1937))
- Development - Separate Agent/Manager - Ansible - GitHub playbooks and workflows updates ([#1938](https://github.com/wazuh/wazuh-ansible/issues/1938))
- Development - Separate Agent/Manager - Ansible - Documentation update ([#1939](https://github.com/wazuh/wazuh-ansible/issues/1939))
- Update workflows to include installation-assistant in COMMIT_LIST ([#1922](https://github.com/wazuh/wazuh-ansible/issues/1922))
- Update outdated references to branch v5.0.0 ([#1925](https://github.com/wazuh/wazuh-ansible/issues/1925))
- Adapt main branch to latest changes ([#1912](https://github.com/wazuh/wazuh-ansible/issues/1912))
- Composite names update ([#1896](https://github.com/wazuh/wazuh-ansible/issues/1896))
- Implement pending adaptation tasks ([#1860](https://github.com/wazuh/wazuh-ansible/issues/1860))
- Replace all occurrences of Wazuh server with Wazuh manager ([#1855](https://github.com/wazuh/wazuh-ansible/issues/1855))
- Documentation backport and adaptation ([#1852](https://github.com/wazuh/wazuh-ansible/issues/1852))
- GHA workflows backport and adaptation ([#1846](https://github.com/wazuh/wazuh-ansible/issues/1846))
- Logs gathering playbook backport and adaptation ([#1842](https://github.com/wazuh/wazuh-ansible/issues/1842))
- Distributed deployment adaptation from backport ([#1840](https://github.com/wazuh/wazuh-ansible/issues/1840))
- Agent role backport and adaptation ([#1834](https://github.com/wazuh/wazuh-ansible/issues/1834))
- Dashboard role backport and adaptation ([#1831](https://github.com/wazuh/wazuh-ansible/issues/1831))
- Server role backport and adaptation ([#1825](https://github.com/wazuh/wazuh-ansible/issues/1825))
- Indexer role backport and adaptation ([#1823](https://github.com/wazuh/wazuh-ansible/issues/1823))
- Ansible base configuration files and directories backport ([#1819](https://github.com/wazuh/wazuh-ansible/issues/1819))
- Remove Wazuh Manager deprecated daemons and CLI tools ([#1735](https://github.com/wazuh/wazuh-ansible/issues/1735))
- Bucket migrate from packages-dev.wazuh.com to xdrsiem-packages-dev ([#1714](https://github.com/wazuh/wazuh-ansible/issues/1714))
- DevOps - Ansible - OpenSearch 3.0 deprecated settings ([#1697](https://github.com/wazuh/wazuh-ansible/issues/1697))
- Bucket migration for packages-dev.wazuh.com ([#1709](https://github.com/wazuh/wazuh-ansible/issues/1709))

### Removed

- None

### Fixed

- Bumper script issue when the tag is set to false ([#2159](https://github.com/wazuh/wazuh-ansible/issues/2159))
- Ansible deployment fails on needrestart task when no services require restart ([#2045](https://github.com/wazuh/wazuh-ansible/issues/2045))
- No idempotency for the `opensearch.yml` configurations ([#2056](https://github.com/wazuh/wazuh-ansible/issues/2056))

## Prior version
- []()
