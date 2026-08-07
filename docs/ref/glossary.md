# Glossary

### All-in-One (AIO) Deployment

A deployment method where all Wazuh components (Indexer, Manager, and Dashboard) and its dependencies are installed on a single node. Suitable for small environments or testing purposes.

### Distributed Deployment

A deployment strategy in which Wazuh components are installed on separate nodes to enhance scalability, performance, and fault tolerance. It involves multiple Indexer nodes, Manager nodes, and a single Dashboard node.

### Ansible

An open-source automation tool used for configuration management, application deployment, and task automation. It is the primary tool used in the `wazuh-ansible` project.

### Ansible Inventory File

A configuration file (typically `inventory.ini`) that defines the target nodes, their IP addresses, and connection variables for Ansible playbooks.

### Ansible Playbook

A YAML file containing a set of instructions (tasks) that Ansible executes on target nodes. Examples include `wazuh-aio.yml`, `wazuh-distributed.yml`, and `wazuh-agent.yml`.

### Roles

Reusable Ansible configurations that define tasks for specific components. Examples include `wazuh-indexer`, `wazuh-manager`, and `wazuh-dashboard`.

### SSH

A secure network protocol used to establish encrypted communication between the control node and target nodes during playbook execution.

### Control Node

The machine where Ansible is installed and from which playbooks are executed. It manages the deployment of Wazuh components to target nodes.

### Target Node

A host where Wazuh components (Indexer, Manager, Dashboard, or Agent) are installed using Ansible.

### Wazuh

An open-source security platform that provides threat detection, compliance management, and incident response capabilities.

### Wazuh Agent

A lightweight software component installed on monitored endpoints to collect and send security data to the Wazuh Manager.

### Wazuh Dashboard

A web-based user interface for managing and visualizing Wazuh data.

### Wazuh Indexer

A component responsible for storing and indexing security data collected by Wazuh Agents.

### Wazuh Manager

The central component of Wazuh that processes data from agents and communicates with the Indexer and Dashboard.

### Wazuh-Ansible

An open-source project that simplifies the deployment of Wazuh components using Ansible. It includes predefined playbooks and roles for various deployment scenarios.

### YAML

A human-readable data serialization format used for writing Ansible playbooks and configuration files.
