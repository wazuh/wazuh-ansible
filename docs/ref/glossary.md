# Glossary

### All-in-One (AIO) Deployment

A deployment method where all Wazuh components (Indexer, Server, and Dashboard) are installed on a single node. Suitable for small environments or testing purposes.

### Distributed Deployment

A deployment method where Wazuh components are distributed across multiple nodes for scalability and redundancy. It includes multiple Indexer nodes, Server nodes, a Dashboard node, and a load balancer.

### Ansible

An open-source automation tool used for configuration management, application deployment, and task automation. It is the primary tool used in the `wazuh-ansible` project.

### Ansible Inventory File

A configuration file (`inventory.ini`) that defines the target nodes, their IP addresses, and connection variables for Ansible playbooks.

### Ansible Playbook

A YAML file containing a set of instructions (tasks) that Ansible executes on target nodes. Examples include `wazuh-aio.yml`, `wazuh-distributed.yml`, and `wazuh-agent.yml`.

### Distributed Deployment

A deployment method where Wazuh components are distributed across multiple nodes for scalability and redundancy. Typically includes multiple Indexer nodes, Server nodes, a Dashboard node, and a load balancer.

### Load Balancer

A component (e.g., Nginx) used in distributed deployments to distribute traffic across multiple Wazuh Server nodes.

### Roles

Reusable Ansible configurations that define tasks for specific components. Examples include `wazuh-indexer`, `wazuh-server`, and `wazuh-dashboard`.

### SSH

A protocol used for secure communication between the control node and target nodes during deployment.

### Control Node

The machine where Ansible is installed and from which playbooks are executed. It manages the deployment of Wazuh components to target nodes.

### Target Node

A server or host where Wazuh components (Indexer, Server, Dashboard, or Agent) are installed using Ansible.

### Wazuh

An open-source security platform that provides threat detection, compliance management, and incident response capabilities.

### Wazuh Agent

A lightweight software component installed on monitored endpoints to collect and send security data to the Wazuh Server.

### Wazuh Dashboard

A web-based user interface for managing and visualizing Wazuh data.

### Wazuh Indexer

A component responsible for storing and indexing security data collected by Wazuh Agents.

### Wazuh Server

The central component of Wazuh that processes data from agents and communicates with the Indexer and Dashboard.

### Wazuh-Ansible

An open-source project that simplifies the deployment of Wazuh components using Ansible. It includes predefined playbooks and roles for various deployment scenarios.

### YAML

A human-readable data serialization format used for writing Ansible playbooks and configuration files.
