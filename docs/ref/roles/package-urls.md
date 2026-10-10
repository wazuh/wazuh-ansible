# package-urls Role

## Description

The `package-urls` role is responsible for resolving and downloading the artifact URL definitions file used by all other roles to locate the correct Wazuh packages for the target version.

Depending on the value of the `source` variable, the role downloads the URL file from either the production package repository or the pre-release staging environment. The resulting file is stored locally under `roles/vars/` and is subsequently loaded by other roles at runtime.

This role runs once on the control node (not on target hosts) and is a prerequisite for any deployment that downloads packages from remote sources.

The role also provides `verify_package_signature.yml`, which the `wazuh-indexer`, `wazuh-manager`, `wazuh-dashboard`, and `wazuh-agent` (Linux) roles include on each host before installing the package they downloaded. It downloads the Wazuh GPG key from `wazuh_gpg_key_url`, trusts it only if the file holds a single key whose fingerprint is in `wazuh_gpg_key_fingerprints`, and stops the deployment if the package is not signed with it:

- `.rpm`: the package must be signed with the Wazuh key ID and pass `rpm -K`. `rpm -K` alone accepts an unsigned package, and dnf accepts a package signed with any key in the RPM database.
- `.deb`: apt and dpkg ignore the signature embedded in a `.deb`. Its `_gpgbuilder` member is checked with `gpgv`, and the hashes it signs are compared with the other members of the package.

The Windows and macOS packages of the `wazuh-agent` role are not signed with the GPG key. The role includes `verify_msi_signature.yml` or `verify_pkg_signature.yml` on the host instead, which stop the deployment unless:

- `.msi`: `Get-AuthenticodeSignature` reports the signature as `Valid` (Windows trusts the certificate chain and the signature matches the file), and both the CN and the O of the signer certificate are `wazuh_windows_signer_name`. If `wazuh_windows_signer_eku` is set, the signer certificate must also carry that extended key usage. The certificate itself is not pinned: it is short-lived and renewed every few days. `msiexec` installs an unsigned or re-signed MSI.
- `.pkg`: `pkgutil --check-signature` accepts the package, reports it as signed with a Developer ID certificate issued by Apple, and the leaf certificate is a `Developer ID Installer` certificate of the team `wazuh_macos_signer_team_id`. `installer` does not apply Gatekeeper, and `spctl` is not used because it accepts a signed package whose payload was modified.

Set `wazuh_skip_package_signature_check` to `true` only to install unsigned development packages.

## Tasks

| Task | Description |
|------|-------------|
| Import variables | Loads shared variables from `vars/main.yml`. |
| Download package URLs file | Downloads the artifact URL definitions YAML file from the configured source URL and saves it to `roles/vars/artifact_urls.yaml`. |
| Verify package signature (`verify_package_signature.yml`) | Included by the other roles on each host: checks that a downloaded package is signed with the Wazuh GPG key before it is installed. |
| Verify MSI signature (`verify_msi_signature.yml`) | Included by the `wazuh-agent` role on Windows hosts: checks that the downloaded `.msi` has a valid Authenticode signature from Wazuh before it is installed. |
| Verify PKG signature (`verify_pkg_signature.yml`) | Included by the `wazuh-agent` role on macOS hosts: checks that the downloaded `.pkg` is signed with the Wazuh Developer ID Installer certificate before it is installed. |

## Usage

This role is included in the `wazuh-aio.yml`, `wazuh-distributed.yml`, and `wazuh-agent.yml` playbooks as the first role to execute, ensuring that package URLs are available before any installation task runs.

## Related

- [Variables](../variables.md#package-urls)
- [Deployment](../deployment.md)
