# package-urls Role

## Description

The `package-urls` role is responsible for resolving and downloading the artifact URL definitions file used by all other roles to locate the correct Wazuh packages for the target version.

Depending on the value of the `source` variable, the role downloads the URL file from either the production package repository or the pre-release staging environment. The resulting file is stored locally under `roles/vars/` and is subsequently loaded by other roles at runtime.

This role runs once on the control node (not on target hosts) and is a prerequisite for any deployment that downloads packages from remote sources.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml`. |
| Download package URLs file | Downloads the artifact URL definitions YAML file from the configured source URL and saves it to `roles/vars/artifact_urls.yaml`. |

## Usage

This role is included in the `wazuh-aio.yml`, `wazuh-distributed.yml`, and `wazuh-agent.yml` playbooks as the first role to execute, ensuring that package URLs are available before any installation task runs.

## Related

- [Variables](../variables.md#package-urls)
- [Deployment](../deployment.md)
