# Description

## What is Wazuh-Ansible?

Wazuh-Ansible is an open-source project designed to simplify the deployment of Wazuh across various operating systems and architectures ([Compatibility](compatibility.md)) using Ansible. It offers a comprehensive set of roles and playbooks to streamline the installation and configuration process, whether for an All-in-One (AIO) setup, a distributed configuration, or the installation and enrollment of one or multiple agents.

Key features include:

- Automated deployment of Wazuh in AIO or distributed environments.
- Component verification to ensure proper installation.
- Seamless support for enrolling new agents.

## How Wazuh-Ansible Works

The project is organized with playbooks located in the project root directory and roles stored in the `roles` directory. Each role contains specific tasks to configure Wazuh components, such as the server, agents, or the web interface.

When a playbook is executed, Ansible uses the defined roles to perform the required tasks. This structure ensures flexibility and code reusability, making it easier to manage configurations across multiple servers.

### Playbooks

The available playbooks in the project include:

- `wazuh-aio.yml`: Deploys Wazuh on a single server (All-in-One).
- `wazuh-distributed.yml`: Deploys Wazuh in a distributed environment.
- `wazuh-agent.yml`: Configures and enrolls one or more agents into the Wazuh server.

### Roles

The roles utilized in the project, executed in sequence, are:

- `package-urls`: Configures the URLs for Wazuh packages.
- `wazuh-indexer`: Installs and configures the Wazuh Indexer component.
- `wazuh-server`: Installs and configures the Wazuh server.
- `wazuh-dashboard`: Installs and configures the Wazuh User Interface (WUI).

## Use Cases

Wazuh-Ansible is particularly useful in scenarios such as:

- Testing Wazuh in development setups.
- Deploying Wazuh configurations across multiple servers.
- Secure a fleet of agents with Wazuh by enrolling them automatically.

## Advantages of Using Wazuh-Ansible

Benefits of using Wazuh-Ansible include:

- Time-saving automation for deployment and configuration.
- Consistency in deployments across various environments.
- Flexibility to adapt to different infrastructure setups.
