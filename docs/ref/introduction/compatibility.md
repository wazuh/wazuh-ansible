# Compatibility

This section outlines the supported platforms, versions, and dependencies for deploying Wazuh using `wazuh-ansible`. Ensuring compatibility is essential for a successful deployment.

It is important to note that since the Wazuh refactoring, wazuh-ansible is now only compatible with Wazuh version 6.0 and later.

Tambien es importante que revise la documentacion oficial de Ansible para asegurarse de que su nodo de control cumple con los requisitos de compatibilidad. Encuentrela en el siguiente enlace: [Ansible documentation - Release and Maintenance](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html)

## Central Components Compatibility

To install the central components of Wazuh (indexer, server, and dashboard), it is necessary to use a machine running a Linux operating system. The installation of Wazuh via Ansible is compatible with the two major Linux distribution families: Debian and Red Hat.

For detailed information on the compatibility of Wazuh components, please refer to the Wazuh documentation:

- Packages List: [Wazuh Packages List](https://documentation.wazuh.com/current/installation-guide/packages-list.html)

## Agents Compatibility

Wazuh agents are compatible with a wide variety of operating systems. However, the installation and enrollment of agents using Ansible are only supported on Linux, Windows, and macOS operating systems.

For more detailed information on Wazuh agents’ compatibility, please refer to the Wazuh documentation:

- Compatibility Matrix: [Wazuh Compatibility Matrix](https://documentation.wazuh.com/current/user-manual/capabilities/system-inventory/compatibility-matrix.html)
- Packages List: [Wazuh Packages List](https://documentation.wazuh.com/current/installation-guide/packages-list.html)

## Notes on Compatibility

- Ensure the target systems meet the minimum hardware and software requirements for Wazuh.
- Verify that the network configuration allows proper communication between Wazuh components (e.g., server, agents, and dashboard).
- Refer to the Wazuh documentation for detailed information on the [Architecture](https://documentation.wazuh.com/current/getting-started/architecture.html) and network requirements.
- For distributed deployments, ensure all nodes are running compatible operating systems and Wazuh versions.
