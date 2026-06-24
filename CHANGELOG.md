# Change Log
All notable changes to this project will be documented in this file.

## [5.0.0]

### Added

- Implement ansible integration testing ([#2141](https://github.com/wazuh/wazuh-ansible/pull/2141))
- Add new tags on PR tests ([#2095](https://github.com/wazuh/wazuh-ansible/pull/2095))
- Add roles and variables documentation ([#2088](https://github.com/wazuh/wazuh-ansible/pull/2088))
- 5.x bumper revert changes added ([#2023](https://github.com/wazuh/wazuh-ansible/pull/2023))
- Added set-as-main option to repository bumper ([#2002](https://github.com/wazuh/wazuh-ansible/pull/2002))
- Bring missing GHA workflows aio.yml and distributed.yml to main ([#1644](https://github.com/wazuh/wazuh-ansible/pull/1644))

### Changed

- Migrate the GHA runner to CodeBuild ([#2153](https://github.com/wazuh/wazuh-ansible/pull/2153))
- Change file and workflow names for PR Revamp tasks ([#2142](https://github.com/wazuh/wazuh-ansible/pull/2142))
- Forbid run test in draft PRs ([#2093](https://github.com/wazuh/wazuh-ansible/pull/2093))
- Fixed Wazuh manager certificates handling ([#2055](https://github.com/wazuh/wazuh-ansible/pull/2055))
- URLs file path update ([#2039](https://github.com/wazuh/wazuh-ansible/pull/2039))
- Adapted the Ansible deployment according to the config.yml changes. ([#2000](https://github.com/wazuh/wazuh-ansible/pull/2000))
- Conditionally select RPM artifact URL keys based on source environment ([#1997](https://github.com/wazuh/wazuh-ansible/pull/1997))
- Update package artifact URLs and standardize artifact file extension ([#1986](https://github.com/wazuh/wazuh-ansible/pull/1986))
- Fixed INSTALLATION.md file. ([#1981](https://github.com/wazuh/wazuh-ansible/pull/1981))
- Updated wazuh-ansible documentation config and tooling versions to meet new standards. ([#1980](https://github.com/wazuh/wazuh-ansible/pull/1980))
- Standardize URL presigning process in AIO and distributed workflows ([#1959](https://github.com/wazuh/wazuh-ansible/pull/1959))
- Enhance key management in workflows ([#1958](https://github.com/wazuh/wazuh-ansible/pull/1958))
- Development - Separate Agent/Manager - Ansible - E2E Tests enhancements ([#1957](https://github.com/wazuh/wazuh-ansible/pull/1957))
- Wazuh Manager/agent Separation - Breaking changes ([#1956](https://github.com/wazuh/wazuh-ansible/pull/1956))
- Development - Separate Agent/Manager - Ansible - Roles and playbooks update ([#1944](https://github.com/wazuh/wazuh-ansible/pull/1944))
- Development - Separate Agent/Manager - Ansible - GitHub playbooks and workflows updates ([#1950](https://github.com/wazuh/wazuh-ansible/pull/1950))
- Development - Separate Agent/Manager - Ansible - Documentation update ([#1951](https://github.com/wazuh/wazuh-ansible/pull/1951))
- Update workflows to include installation-assistant in COMMIT_LIST ([#1922](https://github.com/wazuh/wazuh-ansible/pull/1922))
- Update outdated references to branch v5.0.0 ([#1925](https://github.com/wazuh/wazuh-ansible/pull/1925))
- Adapt main branch to latest changes ([#1912](https://github.com/wazuh/wazuh-ansible/pull/1912))
- Composite names update ([#1896](https://github.com/wazuh/wazuh-ansible/pull/1896))
- Implement pending adaptation tasks ([#1860](https://github.com/wazuh/wazuh-ansible/pull/1860))
- Replace all occurrences of Wazuh server with Wazuh manager ([#1855](https://github.com/wazuh/wazuh-ansible/pull/1855))
- Documentation backport and adaptation ([#1852](https://github.com/wazuh/wazuh-ansible/pull/1852))
- GHA workflows backport and adaptation ([#1846](https://github.com/wazuh/wazuh-ansible/pull/1846))
- Logs gathering playbook backport and adaptation ([#1842](https://github.com/wazuh/wazuh-ansible/pull/1842))
- Distributed deployment adaptation from backport ([#1840](https://github.com/wazuh/wazuh-ansible/pull/1840))
- Agent role backport and adaptation ([#1834](https://github.com/wazuh/wazuh-ansible/pull/1834))
- Dashboard role backport and adaptation ([#1831](https://github.com/wazuh/wazuh-ansible/pull/1831))
- Server role backport and adaptation ([#1825](https://github.com/wazuh/wazuh-ansible/pull/1825))
- Indexer role backport and adaptation ([#1823](https://github.com/wazuh/wazuh-ansible/pull/1823))
- Ansible base configuration files and directories backport ([#1819](https://github.com/wazuh/wazuh-ansible/pull/1819))
- Wazuh server clean-up ([#1803](https://github.com/wazuh/wazuh-ansible/pull/1803))
- Bucket migrate from packages-dev.wazuh.com to xdrsiem-packages-dev ([#1714](https://github.com/wazuh/wazuh-ansible/pull/1714))
- Replace OpenSearch deprecated settings ([#1699](https://github.com/wazuh/wazuh-ansible/pull/1699))
- Bucket migration for packages-dev.wazuh.com ([#1709](https://github.com/wazuh/wazuh-ansible/pull/1709))

### Fixed

- Fix needrestart task for debian in the dashboard role ([#2087](https://github.com/wazuh/wazuh-ansible/pull/2087))
- Wazuh indexer idempotency fix ([#2058](https://github.com/wazuh/wazuh-ansible/pull/2058))

### Deleted

- None

## Prior version
- []()