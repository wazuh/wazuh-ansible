#!/bin/bash

# Wazuh Ansible Deployment - Interactive Setup Script
# This script configures Ansible variables for Wazuh deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
DEFAULT_WAZUH_VERSION="4.9.0"
DEFAULT_INDEXER_HTTP_PORT="9200"
DEFAULT_DASHBOARD_PORT="443"
DEFAULT_MANAGER_API_PORT="55000"
DEFAULT_AGENT_PORT="1514"

# Function to print colored output
print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_section() {
    echo -e "\n${GREEN}▶ $1${NC}\n"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    local is_password="${4:-false}"

    if [ "$is_password" = "true" ]; then
        echo -en "${CYAN}$prompt ${NC}[${YELLOW}hidden${NC}]: "
        read -s value
        echo
    else
        echo -en "${CYAN}$prompt ${NC}[${YELLOW}$default${NC}]: "
        read value
    fi

    if [ -z "$value" ]; then
        eval "$var_name='$default'"
    else
        eval "$var_name='$value'"
    fi
}

# Function to prompt for yes/no
prompt_yes_no() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"

    while true; do
        echo -en "${CYAN}$prompt ${NC}[${YELLOW}$default${NC}]: "
        read value

        if [ -z "$value" ]; then
            value="$default"
        fi

        case "${value,,}" in
            y|yes) eval "$var_name='true'"; return ;;
            n|no) eval "$var_name='false'"; return ;;
            *) echo -e "${RED}Please enter yes or no${NC}" ;;
        esac
    done
}

# Function to prompt for multiple hosts
prompt_hosts() {
    local prompt="$1"
    local var_name="$2"
    local hosts=()

    echo -e "${CYAN}$prompt${NC}"
    echo -e "${YELLOW}Enter hostnames/IPs one per line. Enter empty line when done.${NC}"

    local count=1
    while true; do
        echo -en "  Host $count: "
        read host
        if [ -z "$host" ]; then
            break
        fi
        hosts+=("$host")
        ((count++))
    done

    eval "$var_name='${hosts[*]}'"
}

# Function to generate random password
generate_password() {
    openssl rand -base64 24 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*' | fold -w 24 | head -n 1
}

# Function to validate IP address
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    fi
    return 1
}

# Main setup function
main() {
    clear
    print_header "Wazuh Ansible Deployment - Interactive Setup"

    echo -e "${YELLOW}This script will help you configure the Ansible variables for${NC}"
    echo -e "${YELLOW}deploying Wazuh (Manager, Indexer, Dashboard, and Agents).${NC}"
    echo

    # ═══════════════════════════════════════════════════════════════
    # GENERAL SETTINGS
    # ═══════════════════════════════════════════════════════════════
    print_section "General Settings"

    prompt_with_default "Wazuh version to install" "$DEFAULT_WAZUH_VERSION" "WAZUH_VERSION"
    prompt_with_default "Environment name (e.g., production, staging)" "production" "ENVIRONMENT"
    prompt_with_default "Organization name" "MyOrg" "ORG_NAME"

    # ═══════════════════════════════════════════════════════════════
    # WAZUH INDEXER CONFIGURATION
    # ═══════════════════════════════════════════════════════════════
    print_section "Wazuh Indexer Configuration"

    print_info "The Wazuh Indexer stores and indexes alerts and events."
    echo

    prompt_hosts "Enter Wazuh Indexer node(s)" "INDEXER_NODES"

    if [ -z "$INDEXER_NODES" ]; then
        print_error "At least one Indexer node is required!"
        exit 1
    fi

    INDEXER_NODES_ARRAY=($INDEXER_NODES)
    INDEXER_COUNT=${#INDEXER_NODES_ARRAY[@]}

    prompt_with_default "Indexer HTTP port" "$DEFAULT_INDEXER_HTTP_PORT" "INDEXER_HTTP_PORT"
    prompt_with_default "Indexer cluster name" "wazuh-cluster" "INDEXER_CLUSTER_NAME"

    # Indexer memory settings
    prompt_with_default "Indexer JVM heap size (e.g., 1g, 2g, 4g)" "1g" "INDEXER_HEAP_SIZE"

    # ═══════════════════════════════════════════════════════════════
    # WAZUH MANAGER CONFIGURATION
    # ═══════════════════════════════════════════════════════════════
    print_section "Wazuh Manager Configuration"

    print_info "The Wazuh Manager analyzes data received from agents."
    echo

    prompt_hosts "Enter Wazuh Manager node(s)" "MANAGER_NODES"

    if [ -z "$MANAGER_NODES" ]; then
        print_error "At least one Manager node is required!"
        exit 1
    fi

    MANAGER_NODES_ARRAY=($MANAGER_NODES)
    MANAGER_COUNT=${#MANAGER_NODES_ARRAY[@]}

    prompt_with_default "Manager API port" "$DEFAULT_MANAGER_API_PORT" "MANAGER_API_PORT"
    prompt_with_default "Agent registration port" "$DEFAULT_AGENT_PORT" "AGENT_PORT"

    if [ $MANAGER_COUNT -gt 1 ]; then
        print_info "Multiple managers detected. Configuring cluster..."
        prompt_with_default "Manager cluster name" "wazuh-manager-cluster" "MANAGER_CLUSTER_NAME"
        prompt_with_default "Cluster key (32 characters)" "$(openssl rand -hex 16 2>/dev/null || echo 'MyClusterKey32CharactersLong!!')" "MANAGER_CLUSTER_KEY"
    fi

    # ═══════════════════════════════════════════════════════════════
    # WAZUH DASHBOARD CONFIGURATION
    # ═══════════════════════════════════════════════════════════════
    print_section "Wazuh Dashboard Configuration"

    print_info "The Wazuh Dashboard provides a web interface for data visualization."
    echo

    prompt_hosts "Enter Wazuh Dashboard node(s)" "DASHBOARD_NODES"

    if [ -z "$DASHBOARD_NODES" ]; then
        print_error "At least one Dashboard node is required!"
        exit 1
    fi

    DASHBOARD_NODES_ARRAY=($DASHBOARD_NODES)

    prompt_with_default "Dashboard HTTPS port" "$DEFAULT_DASHBOARD_PORT" "DASHBOARD_PORT"

    # ═══════════════════════════════════════════════════════════════
    # WAZUH AGENTS CONFIGURATION
    # ═══════════════════════════════════════════════════════════════
    print_section "Wazuh Agents Configuration"

    print_info "Wazuh Agents collect and forward security data from monitored systems."
    echo

    prompt_yes_no "Do you want to deploy agents now?" "yes" "DEPLOY_AGENTS"

    if [ "$DEPLOY_AGENTS" = "true" ]; then
        prompt_hosts "Enter Agent host(s)" "AGENT_NODES"
        AGENT_NODES_ARRAY=($AGENT_NODES)
    fi

    # ═══════════════════════════════════════════════════════════════
    # SECURITY CONFIGURATION
    # ═══════════════════════════════════════════════════════════════
    print_section "Security Configuration"

    print_info "Setting up authentication credentials..."
    echo

    # Generate default passwords
    DEFAULT_ADMIN_PASS=$(generate_password)
    DEFAULT_API_PASS=$(generate_password)
    DEFAULT_INDEXER_PASS=$(generate_password)

    prompt_with_default "Wazuh API admin username" "wazuh" "API_USER"
    prompt_with_default "Wazuh API admin password" "$DEFAULT_API_PASS" "API_PASSWORD" "true"

    prompt_with_default "Indexer admin username" "admin" "INDEXER_ADMIN_USER"
    prompt_with_default "Indexer admin password" "$DEFAULT_INDEXER_PASS" "INDEXER_ADMIN_PASSWORD" "true"

    prompt_with_default "Dashboard admin username" "admin" "DASHBOARD_ADMIN_USER"
    prompt_with_default "Dashboard admin password" "$DEFAULT_ADMIN_PASS" "DASHBOARD_ADMIN_PASSWORD" "true"

    # ═══════════════════════════════════════════════════════════════
    # SSL/TLS CONFIGURATION
    # ═══════════════════════════════════════════════════════════════
    print_section "SSL/TLS Configuration"

    prompt_yes_no "Generate self-signed certificates?" "yes" "GENERATE_CERTS"

    if [ "$GENERATE_CERTS" = "false" ]; then
        print_info "You will need to provide your own certificates."
        prompt_with_default "Path to CA certificate" "/etc/wazuh/certs/ca.pem" "CA_CERT_PATH"
        prompt_with_default "Path to CA private key" "/etc/wazuh/certs/ca-key.pem" "CA_KEY_PATH"
    fi

    # ═══════════════════════════════════════════════════════════════
    # SSH CONFIGURATION
    # ═══════════════════════════════════════════════════════════════
    print_section "SSH Configuration"

    prompt_yes_no "Generate new SSH key pair for Ansible?" "yes" "GENERATE_SSH_KEY"

    if [ "$GENERATE_SSH_KEY" = "true" ]; then
        ANSIBLE_SSH_KEY="${SCRIPT_DIR}/keys/wazuh_ansible_key"
        print_info "SSH key will be generated at: ${ANSIBLE_SSH_KEY}"
        prompt_with_default "SSH user for Ansible (to create on targets)" "wazuh-deploy" "ANSIBLE_USER"
    else
        prompt_with_default "SSH user for Ansible" "root" "ANSIBLE_USER"
        prompt_with_default "SSH private key path" "~/.ssh/id_rsa" "ANSIBLE_SSH_KEY"
    fi

    prompt_with_default "SSH port" "22" "ANSIBLE_SSH_PORT"
    prompt_yes_no "Use sudo for privilege escalation?" "yes" "USE_BECOME"

    if [ "$USE_BECOME" = "true" ]; then
        prompt_yes_no "Require sudo password?" "no" "BECOME_ASK_PASS"
    fi

    prompt_yes_no "Create client preparation package?" "yes" "CREATE_PREP_PACKAGE"

    # ═══════════════════════════════════════════════════════════════
    # ADDITIONAL OPTIONS
    # ═══════════════════════════════════════════════════════════════
    print_section "Additional Options"

    prompt_yes_no "Enable Wazuh vulnerability detection?" "yes" "ENABLE_VULN_DETECTION"
    prompt_yes_no "Enable Wazuh file integrity monitoring?" "yes" "ENABLE_FIM"
    prompt_yes_no "Enable Wazuh rootkit detection?" "yes" "ENABLE_ROOTKIT"
    prompt_yes_no "Enable Wazuh log collection?" "yes" "ENABLE_LOG_COLLECTION"
    prompt_yes_no "Enable Active Response?" "yes" "ENABLE_ACTIVE_RESPONSE"

    # ═══════════════════════════════════════════════════════════════
    # GENERATE CONFIGURATION FILES
    # ═══════════════════════════════════════════════════════════════
    print_section "Generating Configuration Files"

    # Create inventory file
    print_info "Creating inventory file..."

    cat > "$SCRIPT_DIR/inventory/hosts.yml" << EOF
---
all:
  vars:
    ansible_user: ${ANSIBLE_USER}
    ansible_ssh_private_key_file: ${ANSIBLE_SSH_KEY}
    ansible_port: ${ANSIBLE_SSH_PORT}
    ansible_become: ${USE_BECOME}
EOF

    if [ "$BECOME_ASK_PASS" = "true" ]; then
        echo "    ansible_become_ask_pass: true" >> "$SCRIPT_DIR/inventory/hosts.yml"
    fi

    cat >> "$SCRIPT_DIR/inventory/hosts.yml" << EOF

  children:
    wazuh_indexers:
      hosts:
EOF

    # Add indexer hosts
    for i in "${!INDEXER_NODES_ARRAY[@]}"; do
        node="${INDEXER_NODES_ARRAY[$i]}"
        node_name="indexer-$((i+1))"
        cat >> "$SCRIPT_DIR/inventory/hosts.yml" << EOF
        ${node}:
          indexer_node_name: ${node_name}
EOF
        if [ $i -eq 0 ]; then
            echo "          indexer_cluster_initial_master: true" >> "$SCRIPT_DIR/inventory/hosts.yml"
        fi
    done

    cat >> "$SCRIPT_DIR/inventory/hosts.yml" << EOF

    wazuh_managers:
      hosts:
EOF

    # Add manager hosts
    for i in "${!MANAGER_NODES_ARRAY[@]}"; do
        node="${MANAGER_NODES_ARRAY[$i]}"
        node_name="manager-$((i+1))"
        cat >> "$SCRIPT_DIR/inventory/hosts.yml" << EOF
        ${node}:
          manager_node_name: ${node_name}
EOF
        if [ $MANAGER_COUNT -gt 1 ]; then
            if [ $i -eq 0 ]; then
                echo "          manager_node_type: master" >> "$SCRIPT_DIR/inventory/hosts.yml"
            else
                echo "          manager_node_type: worker" >> "$SCRIPT_DIR/inventory/hosts.yml"
            fi
        fi
    done

    cat >> "$SCRIPT_DIR/inventory/hosts.yml" << EOF

    wazuh_dashboards:
      hosts:
EOF

    # Add dashboard hosts
    for node in "${DASHBOARD_NODES_ARRAY[@]}"; do
        echo "        ${node}:" >> "$SCRIPT_DIR/inventory/hosts.yml"
    done

    if [ "$DEPLOY_AGENTS" = "true" ] && [ -n "$AGENT_NODES" ]; then
        cat >> "$SCRIPT_DIR/inventory/hosts.yml" << EOF

    wazuh_agents:
      hosts:
EOF
        for node in "${AGENT_NODES_ARRAY[@]}"; do
            echo "        ${node}:" >> "$SCRIPT_DIR/inventory/hosts.yml"
        done
    fi

    print_success "Inventory file created: inventory/hosts.yml"

    # Create group_vars/all.yml
    print_info "Creating group variables..."

    cat > "$SCRIPT_DIR/group_vars/all.yml" << EOF
---
# Wazuh Ansible Deployment - Group Variables
# Generated by setup.sh on $(date)

# ═══════════════════════════════════════════════════════════════
# General Settings
# ═══════════════════════════════════════════════════════════════
wazuh_version: "${WAZUH_VERSION}"
environment_name: "${ENVIRONMENT}"
organization_name: "${ORG_NAME}"

# ═══════════════════════════════════════════════════════════════
# Wazuh Indexer Settings
# ═══════════════════════════════════════════════════════════════
wazuh_indexer_cluster_name: "${INDEXER_CLUSTER_NAME}"
wazuh_indexer_http_port: ${INDEXER_HTTP_PORT}
wazuh_indexer_heap_size: "${INDEXER_HEAP_SIZE}"
wazuh_indexer_admin_user: "${INDEXER_ADMIN_USER}"
wazuh_indexer_admin_password: "${INDEXER_ADMIN_PASSWORD}"

# Indexer node list for cluster configuration
wazuh_indexer_nodes:
EOF

    for i in "${!INDEXER_NODES_ARRAY[@]}"; do
        node="${INDEXER_NODES_ARRAY[$i]}"
        echo "  - name: indexer-$((i+1))" >> "$SCRIPT_DIR/group_vars/all.yml"
        echo "    ip: ${node}" >> "$SCRIPT_DIR/group_vars/all.yml"
    done

    cat >> "$SCRIPT_DIR/group_vars/all.yml" << EOF

# ═══════════════════════════════════════════════════════════════
# Wazuh Manager Settings
# ═══════════════════════════════════════════════════════════════
wazuh_manager_api_port: ${MANAGER_API_PORT}
wazuh_manager_agent_port: ${AGENT_PORT}
wazuh_api_user: "${API_USER}"
wazuh_api_password: "${API_PASSWORD}"
EOF

    if [ $MANAGER_COUNT -gt 1 ]; then
        cat >> "$SCRIPT_DIR/group_vars/all.yml" << EOF

# Manager cluster settings
wazuh_manager_cluster_enabled: true
wazuh_manager_cluster_name: "${MANAGER_CLUSTER_NAME}"
wazuh_manager_cluster_key: "${MANAGER_CLUSTER_KEY}"
EOF
    else
        echo "wazuh_manager_cluster_enabled: false" >> "$SCRIPT_DIR/group_vars/all.yml"
    fi

    cat >> "$SCRIPT_DIR/group_vars/all.yml" << EOF

# Manager node list
wazuh_manager_nodes:
EOF

    for i in "${!MANAGER_NODES_ARRAY[@]}"; do
        node="${MANAGER_NODES_ARRAY[$i]}"
        echo "  - name: manager-$((i+1))" >> "$SCRIPT_DIR/group_vars/all.yml"
        echo "    ip: ${node}" >> "$SCRIPT_DIR/group_vars/all.yml"
    done

    cat >> "$SCRIPT_DIR/group_vars/all.yml" << EOF

# ═══════════════════════════════════════════════════════════════
# Wazuh Dashboard Settings
# ═══════════════════════════════════════════════════════════════
wazuh_dashboard_port: ${DASHBOARD_PORT}
wazuh_dashboard_admin_user: "${DASHBOARD_ADMIN_USER}"
wazuh_dashboard_admin_password: "${DASHBOARD_ADMIN_PASSWORD}"

# Dashboard node list
wazuh_dashboard_nodes:
EOF

    for node in "${DASHBOARD_NODES_ARRAY[@]}"; do
        echo "  - ip: ${node}" >> "$SCRIPT_DIR/group_vars/all.yml"
    done

    cat >> "$SCRIPT_DIR/group_vars/all.yml" << EOF

# ═══════════════════════════════════════════════════════════════
# SSL/TLS Configuration
# ═══════════════════════════════════════════════════════════════
wazuh_generate_certs: ${GENERATE_CERTS}
EOF

    if [ "$GENERATE_CERTS" = "false" ]; then
        cat >> "$SCRIPT_DIR/group_vars/all.yml" << EOF
wazuh_ca_cert_path: "${CA_CERT_PATH}"
wazuh_ca_key_path: "${CA_KEY_PATH}"
EOF
    fi

    cat >> "$SCRIPT_DIR/group_vars/all.yml" << EOF

# Certificate paths (on target hosts)
wazuh_certs_path: /etc/wazuh-indexer/certs

# ═══════════════════════════════════════════════════════════════
# Feature Toggles
# ═══════════════════════════════════════════════════════════════
wazuh_vulnerability_detection_enabled: ${ENABLE_VULN_DETECTION}
wazuh_fim_enabled: ${ENABLE_FIM}
wazuh_rootkit_detection_enabled: ${ENABLE_ROOTKIT}
wazuh_log_collection_enabled: ${ENABLE_LOG_COLLECTION}
wazuh_active_response_enabled: ${ENABLE_ACTIVE_RESPONSE}

# ═══════════════════════════════════════════════════════════════
# System Settings
# ═══════════════════════════════════════════════════════════════
# Firewall configuration
wazuh_configure_firewall: true

# SELinux configuration
wazuh_configure_selinux: true

# Package repository settings
wazuh_repo_gpg_key: "https://packages.wazuh.com/key/GPG-KEY-WAZUH"
wazuh_repo_url_apt: "https://packages.wazuh.com/4.x/apt/"
wazuh_repo_url_yum: "https://packages.wazuh.com/4.x/yum/"
EOF

    print_success "Group variables created: group_vars/all.yml"

    # Create ansible.cfg
    print_info "Creating Ansible configuration..."

    cat > "$SCRIPT_DIR/ansible.cfg" << EOF
[defaults]
inventory = inventory/hosts.yml
roles_path = roles
host_key_checking = False
retry_files_enabled = False
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts_cache
fact_caching_timeout = 3600

[privilege_escalation]
become = ${USE_BECOME}
become_method = sudo
become_user = root

[ssh_connection]
pipelining = True
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null
EOF

    print_success "Ansible configuration created: ansible.cfg"

    # ═══════════════════════════════════════════════════════════════
    # SSH KEY GENERATION
    # ═══════════════════════════════════════════════════════════════
    if [ "$GENERATE_SSH_KEY" = "true" ]; then
        print_section "Generating SSH Key Pair"

        mkdir -p "${SCRIPT_DIR}/keys"

        if [ -f "$ANSIBLE_SSH_KEY" ]; then
            print_warning "SSH key already exists: $ANSIBLE_SSH_KEY"
            prompt_yes_no "Overwrite existing key?" "no" "OVERWRITE_KEY"
            if [ "$OVERWRITE_KEY" = "true" ]; then
                rm -f "$ANSIBLE_SSH_KEY" "${ANSIBLE_SSH_KEY}.pub"
            fi
        fi

        if [ ! -f "$ANSIBLE_SSH_KEY" ]; then
            ssh-keygen -t ed25519 -f "$ANSIBLE_SSH_KEY" -N "" -C "wazuh-ansible-deploy"
            chmod 600 "$ANSIBLE_SSH_KEY"
            chmod 644 "${ANSIBLE_SSH_KEY}.pub"
            print_success "SSH key pair generated"
            print_info "Private key: ${ANSIBLE_SSH_KEY}"
            print_info "Public key: ${ANSIBLE_SSH_KEY}.pub"
        fi
    fi

    # ═══════════════════════════════════════════════════════════════
    # CLIENT PREPARATION PACKAGE
    # ═══════════════════════════════════════════════════════════════
    if [ "$CREATE_PREP_PACKAGE" = "true" ]; then
        print_section "Creating Client Preparation Package"

        local prep_dir="${SCRIPT_DIR}/client-prep"
        local tarball="${SCRIPT_DIR}/wazuh-client-prep.tar.gz"

        mkdir -p "$prep_dir"

        # Copy preparation script
        if [ -f "${SCRIPT_DIR}/scripts/prepare-client.sh" ]; then
            cp "${SCRIPT_DIR}/scripts/prepare-client.sh" "$prep_dir/"
        else
            print_warning "Preparation script not found, skipping..."
        fi

        # Copy SSH public key
        if [ -f "${ANSIBLE_SSH_KEY}.pub" ]; then
            cp "${ANSIBLE_SSH_KEY}.pub" "$prep_dir/ansible_key.pub"
        elif [ -f "${SCRIPT_DIR}/keys/wazuh_ansible_key.pub" ]; then
            cp "${SCRIPT_DIR}/keys/wazuh_ansible_key.pub" "$prep_dir/ansible_key.pub"
        fi

        # Create install script for easy deployment
        cat > "$prep_dir/install.sh" << 'INSTALL_EOF'
#!/bin/bash
# Quick install script - run this on target machines
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "${SCRIPT_DIR}/prepare-client.sh"
sudo "${SCRIPT_DIR}/prepare-client.sh" -k "${SCRIPT_DIR}/ansible_key.pub" "$@"
INSTALL_EOF
        chmod +x "$prep_dir/install.sh"

        # Create README
        cat > "$prep_dir/README.txt" << README_EOF
Wazuh Client Preparation Package
=================================

This package prepares target machines for Wazuh deployment via Ansible.

Quick Start:
1. Copy this entire folder to the target machine
2. Run: sudo ./install.sh

Or run with options:
  sudo ./prepare-client.sh -k ansible_key.pub --minimal

Options:
  -u, --user NAME     Ansible user to create (default: wazuh-deploy)
  -p, --port PORT     SSH port (default: 22)
  -k, --key FILE      Path to SSH public key file
  -m, --minimal       Skip package removal (faster)
  -d, --dry-run       Show what would happen
  -h, --help          Show help

What this script does:
- Detects your OS (Ubuntu, Debian, RHEL, Rocky, Fedora, etc.)
- Removes unnecessary packages (desktop, games, office suites, etc.)
- Installs required packages (Python, SSH, etc.)
- Creates an Ansible deployment user
- Deploys the SSH public key for passwordless access
- Configures firewall for Wazuh ports
- Optimizes system settings

SSH User: ${ANSIBLE_USER}
README_EOF

        # Create tarball
        tar -czf "$tarball" -C "${SCRIPT_DIR}" "client-prep"

        # Also create a self-extracting script
        cat > "${SCRIPT_DIR}/wazuh-client-prep.sh" << 'SELFEXTRACT_EOF'
#!/bin/bash
# Wazuh Client Preparation - Self-extracting installer
# Usage: curl -sSL http://your-server/wazuh-client-prep.sh | sudo bash

set -e

TEMP_DIR=$(mktemp -d)
ARCHIVE_START=$(awk '/^__ARCHIVE_START__$/{print NR + 1; exit 0; }' "$0")

echo "Extracting Wazuh client preparation package..."
tail -n+$ARCHIVE_START "$0" | tar -xz -C "$TEMP_DIR"

cd "$TEMP_DIR/client-prep"
chmod +x prepare-client.sh install.sh

echo "Running preparation script..."
sudo ./prepare-client.sh -k ansible_key.pub "$@"

# Cleanup
rm -rf "$TEMP_DIR"

exit 0

__ARCHIVE_START__
SELFEXTRACT_EOF

        # Append tarball to self-extracting script
        cat "$tarball" >> "${SCRIPT_DIR}/wazuh-client-prep.sh"
        chmod +x "${SCRIPT_DIR}/wazuh-client-prep.sh"

        print_success "Client preparation package created:"
        print_info "  Folder: ${prep_dir}/"
        print_info "  Tarball: ${tarball}"
        print_info "  Self-extracting: ${SCRIPT_DIR}/wazuh-client-prep.sh"
    fi

    # ═══════════════════════════════════════════════════════════════
    # SUMMARY
    # ═══════════════════════════════════════════════════════════════
    print_header "Configuration Summary"

    echo -e "${CYAN}Wazuh Version:${NC} ${WAZUH_VERSION}"
    echo -e "${CYAN}Environment:${NC} ${ENVIRONMENT}"
    echo
    echo -e "${GREEN}Indexer Nodes (${INDEXER_COUNT}):${NC}"
    for node in "${INDEXER_NODES_ARRAY[@]}"; do
        echo "  - $node"
    done
    echo
    echo -e "${GREEN}Manager Nodes (${MANAGER_COUNT}):${NC}"
    for node in "${MANAGER_NODES_ARRAY[@]}"; do
        echo "  - $node"
    done
    echo
    echo -e "${GREEN}Dashboard Nodes (${#DASHBOARD_NODES_ARRAY[@]}):${NC}"
    for node in "${DASHBOARD_NODES_ARRAY[@]}"; do
        echo "  - $node"
    done

    if [ "$DEPLOY_AGENTS" = "true" ] && [ -n "$AGENT_NODES" ]; then
        echo
        echo -e "${GREEN}Agent Nodes (${#AGENT_NODES_ARRAY[@]}):${NC}"
        for node in "${AGENT_NODES_ARRAY[@]}"; do
            echo "  - $node"
        done
    fi

    echo
    echo -e "${CYAN}Features Enabled:${NC}"
    [ "$ENABLE_VULN_DETECTION" = "true" ] && echo "  - Vulnerability Detection"
    [ "$ENABLE_FIM" = "true" ] && echo "  - File Integrity Monitoring"
    [ "$ENABLE_ROOTKIT" = "true" ] && echo "  - Rootkit Detection"
    [ "$ENABLE_LOG_COLLECTION" = "true" ] && echo "  - Log Collection"
    [ "$ENABLE_ACTIVE_RESPONSE" = "true" ] && echo "  - Active Response"

    print_header "Next Steps"

    echo -e "1. Review the generated configuration files:"
    echo -e "   ${CYAN}inventory/hosts.yml${NC} - Inventory file"
    echo -e "   ${CYAN}group_vars/all.yml${NC}  - Variables file"
    echo -e "   ${CYAN}ansible.cfg${NC}         - Ansible configuration"
    echo

    if [ "$CREATE_PREP_PACKAGE" = "true" ]; then
        echo -e "2. ${GREEN}Prepare target machines${NC} (choose one method):"
        echo
        echo -e "   ${YELLOW}Method A: Copy and run the preparation folder${NC}"
        echo -e "   scp -r client-prep/ root@TARGET_HOST:/tmp/"
        echo -e "   ssh root@TARGET_HOST 'cd /tmp/client-prep && sudo ./install.sh'"
        echo
        echo -e "   ${YELLOW}Method B: Use the self-extracting script${NC}"
        echo -e "   scp wazuh-client-prep.sh root@TARGET_HOST:/tmp/"
        echo -e "   ssh root@TARGET_HOST 'sudo bash /tmp/wazuh-client-prep.sh'"
        echo
        echo -e "   ${YELLOW}Method C: Use the deployment script for multiple hosts${NC}"
        echo -e "   ./scripts/deploy-prep.sh -f hosts.txt"
        echo -e "   ./scripts/deploy-prep.sh 192.168.1.10 192.168.1.11 192.168.1.12"
        echo
        echo -e "3. Test connectivity to your hosts:"
    else
        echo -e "2. Test connectivity to your hosts:"
    fi
    echo -e "   ${YELLOW}ansible all -m ping${NC}"
    echo

    if [ "$CREATE_PREP_PACKAGE" = "true" ]; then
        echo -e "4. Generate SSL certificates:"
    else
        echo -e "3. Generate SSL certificates:"
    fi
    echo -e "   ${YELLOW}./generate-certs.sh${NC}"
    echo

    if [ "$CREATE_PREP_PACKAGE" = "true" ]; then
        echo -e "5. Run the deployment:"
    else
        echo -e "4. Run the deployment:"
    fi
    echo -e "   ${YELLOW}ansible-playbook site.yml${NC}"
    echo
    echo -e "   Or deploy components individually:"
    echo -e "   ${YELLOW}ansible-playbook playbooks/wazuh-indexer.yml${NC}"
    echo -e "   ${YELLOW}ansible-playbook playbooks/wazuh-manager.yml${NC}"
    echo -e "   ${YELLOW}ansible-playbook playbooks/wazuh-dashboard.yml${NC}"
    echo -e "   ${YELLOW}ansible-playbook playbooks/wazuh-agents.yml${NC}"
    echo

    if [ "$GENERATE_SSH_KEY" = "true" ]; then
        print_header "SSH Key Information"
        echo -e "SSH keys have been generated for Ansible deployment:"
        echo -e "  Private key: ${CYAN}${ANSIBLE_SSH_KEY}${NC}"
        echo -e "  Public key:  ${CYAN}${ANSIBLE_SSH_KEY}.pub${NC}"
        echo
        echo -e "${YELLOW}Keep the private key secure! It provides access to all managed hosts.${NC}"
        echo
    fi

    print_success "Setup complete!"
}

# Run main function
main "$@"
