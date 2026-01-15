# Wazuh Ansible Deployment Guide

Automated deployment of Wazuh SIEM/XDR stack using Ansible with interactive configuration.

## Components

- **Wazuh Indexer**: Stores and indexes security alerts and events
- **Wazuh Manager**: Central component that analyzes data from agents
- **Wazuh Dashboard**: Web interface for visualization and management
- **Wazuh Agent**: Collects security data from monitored endpoints

## Prerequisites

- Ansible 2.12+
- Python 3.8+
- SSH access to target hosts
- Target systems: Ubuntu 20.04+, Debian 10+, RHEL/CentOS 8+

### Required Ansible Collections

```bash
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.general
```

## Quick Start

### 1. Run Interactive Setup

```bash
./setup.sh
```

This will prompt you for:
- Wazuh version
- Indexer, Manager, and Dashboard node addresses
- Agent hosts (optional)
- Security credentials
- SSL/TLS configuration
- Feature toggles

### 2. Prepare Target Machines (Optional but Recommended)

The setup script creates a client preparation package that:
- Detects the OS (Ubuntu, Debian, RHEL, Rocky, Fedora, etc.)
- Removes unnecessary packages (desktop environments, office suites, games)
- Installs required packages (Python, SSH, etc.)
- Creates an Ansible deployment user with sudo access
- Deploys the SSH public key for passwordless authentication
- Configures firewall rules for Wazuh
- Optimizes system settings

**Method A: Copy folder to target machine**
```bash
scp -r client-prep/ root@TARGET_HOST:/tmp/
ssh root@TARGET_HOST 'cd /tmp/client-prep && sudo ./install.sh'
```

**Method B: Use self-extracting script**
```bash
scp wazuh-client-prep.sh root@TARGET_HOST:/tmp/
ssh root@TARGET_HOST 'sudo bash /tmp/wazuh-client-prep.sh'
```

**Method C: Deploy to multiple hosts**
```bash
# Using the deployment script
./scripts/deploy-prep.sh 192.168.1.10 192.168.1.11 192.168.1.12

# Or from a hosts file
./scripts/deploy-prep.sh -f hosts.txt
```

**Method D: Minimal mode (skip package removal)**
```bash
ssh root@TARGET_HOST 'sudo bash /tmp/wazuh-client-prep.sh --minimal'
```

### 3. Generate Certificates

```bash
./generate-certs.sh
```

### 4. Test Connectivity

```bash
ansible all -m ping
```

### 5. Deploy Wazuh Stack

```bash
# Deploy everything
ansible-playbook site.yml

# Or deploy components individually
ansible-playbook playbooks/wazuh-indexer.yml
ansible-playbook playbooks/wazuh-manager.yml
ansible-playbook playbooks/wazuh-dashboard.yml
ansible-playbook playbooks/wazuh-agents.yml
```

## Directory Structure

```
wazuh-ansible/
├── ansible.cfg                  # Ansible configuration
├── setup.sh                     # Interactive setup script
├── generate-certs.sh            # Certificate generation script
├── site.yml                     # Main deployment playbook
├── wazuh-client-prep.sh         # Self-extracting client prep (generated)
├── wazuh-client-prep.tar.gz     # Client prep tarball (generated)
├── inventory/
│   └── hosts.yml                # Inventory file
├── group_vars/
│   └── all.yml                  # Global variables
├── keys/
│   ├── wazuh_ansible_key        # Private SSH key (generated)
│   └── wazuh_ansible_key.pub    # Public SSH key (generated)
├── client-prep/                 # Client preparation package (generated)
│   ├── prepare-client.sh        # OS detection & cleanup script
│   ├── ansible_key.pub          # Public key for deployment
│   ├── install.sh               # Quick install wrapper
│   └── README.txt               # Instructions
├── scripts/
│   ├── prepare-client.sh        # Client preparation script
│   └── deploy-prep.sh           # Multi-host deployment script
├── playbooks/
│   ├── wazuh-indexer.yml        # Indexer deployment
│   ├── wazuh-manager.yml        # Manager deployment
│   ├── wazuh-dashboard.yml      # Dashboard deployment
│   └── wazuh-agents.yml         # Agent deployment
├── roles/
│   ├── wazuh-indexer/           # Indexer role
│   ├── wazuh-manager/           # Manager role
│   ├── wazuh-dashboard/         # Dashboard role
│   └── wazuh-agent/             # Agent role
└── files/
    └── certs/                   # Generated certificates
```

## Configuration

### Inventory (inventory/hosts.yml)

```yaml
all:
  children:
    wazuh_indexers:
      hosts:
        192.168.1.10:
          indexer_node_name: indexer-1
          indexer_cluster_initial_master: true
    wazuh_managers:
      hosts:
        192.168.1.20:
          manager_node_name: manager-1
          manager_node_type: master
    wazuh_dashboards:
      hosts:
        192.168.1.30:
    wazuh_agents:
      hosts:
        192.168.1.100:
        192.168.1.101:
```

### Key Variables (group_vars/all.yml)

| Variable | Description | Default |
|----------|-------------|---------|
| `wazuh_version` | Wazuh version to install | 4.9.0 |
| `wazuh_indexer_http_port` | Indexer HTTP port | 9200 |
| `wazuh_manager_api_port` | Manager API port | 55000 |
| `wazuh_dashboard_port` | Dashboard HTTPS port | 443 |
| `wazuh_manager_cluster_enabled` | Enable manager cluster | false |

### Feature Toggles

| Variable | Description | Default |
|----------|-------------|---------|
| `wazuh_vulnerability_detection_enabled` | Vulnerability detection | true |
| `wazuh_fim_enabled` | File integrity monitoring | true |
| `wazuh_rootkit_detection_enabled` | Rootkit detection | true |
| `wazuh_log_collection_enabled` | Log collection | true |
| `wazuh_active_response_enabled` | Active response | true |

## Multi-Node Deployment

### Indexer Cluster

For high availability, deploy multiple indexer nodes:

```yaml
wazuh_indexer_nodes:
  - name: indexer-1
    ip: 192.168.1.10
  - name: indexer-2
    ip: 192.168.1.11
  - name: indexer-3
    ip: 192.168.1.12
```

### Manager Cluster

For manager clustering, enable and configure:

```yaml
wazuh_manager_cluster_enabled: true
wazuh_manager_cluster_name: "wazuh-cluster"
wazuh_manager_cluster_key: "your-32-character-cluster-key!!"

wazuh_manager_nodes:
  - name: manager-1
    ip: 192.168.1.20
  - name: manager-2
    ip: 192.168.1.21
```

## Tags

Use tags for selective deployment:

```bash
# Deploy only indexers
ansible-playbook site.yml --tags indexer

# Deploy only managers
ansible-playbook site.yml --tags manager

# Deploy only dashboard
ansible-playbook site.yml --tags dashboard

# Deploy only agents
ansible-playbook site.yml --tags agent
```

## Accessing Wazuh

After deployment:

1. Open browser: `https://<dashboard-ip>:443`
2. Login with configured credentials (default: admin/admin)
3. Change default passwords immediately

## Troubleshooting

### Check Service Status

```bash
# On indexer
systemctl status wazuh-indexer

# On manager
systemctl status wazuh-manager

# On dashboard
systemctl status wazuh-dashboard

# On agent
systemctl status wazuh-agent
```

### View Logs

```bash
# Indexer logs
tail -f /var/log/wazuh-indexer/wazuh-indexer.log

# Manager logs
tail -f /var/ossec/logs/ossec.log

# Dashboard logs
tail -f /var/log/wazuh-dashboard/opensearch-dashboards.log
```

### API Health Check

```bash
# Indexer health
curl -k -u admin:admin https://localhost:9200/_cluster/health?pretty

# Manager API
curl -k -u wazuh:wazuh https://localhost:55000/
```

## Security Considerations

1. Change all default passwords immediately after deployment
2. Use strong, unique passwords for all components
3. Consider using external certificate authority for production
4. Restrict network access to management ports
5. Enable firewall rules (handled by playbooks if `wazuh_configure_firewall: true`)
