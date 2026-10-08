# package-urls Role

## Description

The `package-urls` role is responsible for resolving and downloading the artifact URL definitions file used by all other roles to locate the correct Wazuh packages for the target version.

Depending on the value of the `source` variable, the role downloads the URL file from either the production package repository or the pre-release staging environment. The resulting file is stored locally under `roles/vars/` and is subsequently loaded by other roles at runtime.

This role runs once on the control node (not on target hosts) and is a prerequisite for any deployment that downloads packages from remote sources.

The role also provides `verify_package_signature.yml`, which the `wazuh-indexer`, `wazuh-manager`, `wazuh-dashboard`, and `wazuh-agent` (Linux) roles include on each host before installing the package they downloaded. It downloads the Wazuh GPG key from `wazuh_gpg_key_url`, trusts it only if the file holds a single key whose fingerprint is in `wazuh_gpg_key_fingerprints`, and stops the deployment if the package is not signed with it:

- `.rpm`: the package must be signed with the Wazuh key ID and pass `rpm -K`. `rpm -K` alone accepts an unsigned package, and dnf accepts a package signed with any key in the RPM database.
- `.deb`: apt and dpkg ignore the signature embedded in a `.deb`. Its `_gpgbuilder` member is checked with `gpgv`, and the hashes it signs are compared with the other members of the package.

Set `wazuh_skip_package_signature_check` to `true` only to install unsigned development packages.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml`. |
| Download package URLs file | Downloads the artifact URL definitions YAML file from the configured source URL and saves it to `roles/vars/artifact_urls.yaml`. |
| Verify package signature (`verify_package_signature.yml`) | Included by the other roles on each host: checks that a downloaded package is signed with the Wazuh GPG key before it is installed. |

## Usage

This role is included in the `wazuh-aio.yml`, `wazuh-distributed.yml`, and `wazuh-agent.yml` playbooks as the first role to execute, ensuring that package URLs are available before any installation task runs.

## Related

- [Variables](../variables.md#package-urls)
- [Deployment](../deployment.md)
