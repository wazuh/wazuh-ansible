# Roles

## Overview

Roles are the core building blocks of the `wazuh-ansible` project. Each role encapsulates the tasks, default variables, and configuration logic required to install and set up a specific Wazuh component. Roles are designed to be reusable and composable, allowing them to be combined in different playbooks depending on the deployment type.

The available roles are executed in the order defined by each playbook. For more information on how playbooks use these roles, see the [Deployment](../deployment.md) section.

## Available Roles

- [`package-urls`](package-urls.md): Resolves and downloads the package URL definitions file used by all other roles to locate Wazuh packages.
- [`wazuh-indexer`](wazuh-indexer.md): Installs and configures the Wazuh Indexer component, including certificate management and cluster initialization.
- [`wazuh-manager`](wazuh-manager.md): Installs and configures the Wazuh Manager, including certificate deployment and service startup.
- [`wazuh-dashboard`](wazuh-dashboard.md): Installs and configures the Wazuh Dashboard, including OpenSearch Dashboards settings and SSL certificate setup.
- [`wazuh-agent`](wazuh-agent.md): Installs the Wazuh Agent on Linux, Windows, and macOS target nodes.

For a reference of all configurable variables across roles and the shared variable definitions, see [Variables](../variables.md).
