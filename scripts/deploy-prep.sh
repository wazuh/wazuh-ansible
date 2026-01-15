#!/bin/bash

# Wazuh Client Preparation Deployment Script
# This script deploys the preparation script to remote hosts and executes it

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration
PREP_TARBALL="${PARENT_DIR}/wazuh-client-prep.tar.gz"
PREP_SCRIPT="${SCRIPT_DIR}/prepare-client.sh"
SSH_KEY="${PARENT_DIR}/keys/wazuh_ansible_key"
SSH_PUBKEY="${PARENT_DIR}/keys/wazuh_ansible_key.pub"
ANSIBLE_USER="wazuh-deploy"
REMOTE_USER="${REMOTE_USER:-root}"
SSH_PORT="${SSH_PORT:-22}"
HOSTS_FILE=""
PARALLEL_JOBS=5

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

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS] [HOST1 HOST2 ...]

Deploy the Wazuh client preparation script to remote hosts.

OPTIONS:
    -f, --file FILE         File containing list of hosts (one per line)
    -u, --user USER         Remote user for initial SSH (default: root)
    -p, --port PORT         SSH port (default: 22)
    -k, --key FILE          SSH private key for initial connection
    -a, --ansible-user USER User to create for Ansible (default: wazuh-deploy)
    -j, --jobs N            Parallel jobs (default: 5)
    -t, --tarball FILE      Use existing tarball instead of creating new
    --password              Use password authentication instead of key
    --minimal               Use minimal mode (don't remove packages)
    -h, --help              Show this help message

EXAMPLES:
    # Deploy to specific hosts
    $0 192.168.1.10 192.168.1.11 192.168.1.12

    # Deploy using a hosts file
    $0 -f hosts.txt

    # Deploy with password authentication
    $0 --password -u root 192.168.1.10

    # Deploy with custom SSH key
    $0 -k ~/.ssh/id_rsa 192.168.1.10

EOF
    exit 0
}

# Parse arguments
HOSTS=()
USE_PASSWORD=false
MINIMAL_MODE=false
CUSTOM_KEY=""

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--file)
                HOSTS_FILE="$2"
                shift 2
                ;;
            -u|--user)
                REMOTE_USER="$2"
                shift 2
                ;;
            -p|--port)
                SSH_PORT="$2"
                shift 2
                ;;
            -k|--key)
                CUSTOM_KEY="$2"
                shift 2
                ;;
            -a|--ansible-user)
                ANSIBLE_USER="$2"
                shift 2
                ;;
            -j|--jobs)
                PARALLEL_JOBS="$2"
                shift 2
                ;;
            -t|--tarball)
                PREP_TARBALL="$2"
                shift 2
                ;;
            --password)
                USE_PASSWORD=true
                shift
                ;;
            --minimal)
                MINIMAL_MODE=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            -*)
                print_error "Unknown option: $1"
                usage
                ;;
            *)
                HOSTS+=("$1")
                shift
                ;;
        esac
    done
}

# Load hosts from file
load_hosts_from_file() {
    if [ -n "$HOSTS_FILE" ] && [ -f "$HOSTS_FILE" ]; then
        while IFS= read -r line; do
            # Skip empty lines and comments
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            HOSTS+=("$line")
        done < "$HOSTS_FILE"
    fi
}

# Check prerequisites
check_prerequisites() {
    print_section "Checking Prerequisites"

    # Check for required files
    if [ ! -f "$PREP_SCRIPT" ]; then
        print_error "Preparation script not found: $PREP_SCRIPT"
        exit 1
    fi

    # Check for SSH key
    if [ -n "$CUSTOM_KEY" ]; then
        SSH_KEY="$CUSTOM_KEY"
    fi

    if [ "$USE_PASSWORD" != "true" ] && [ ! -f "$SSH_KEY" ]; then
        print_warning "SSH key not found: $SSH_KEY"
        print_info "Will attempt password authentication"
        USE_PASSWORD=true
    fi

    # Check for SSH public key for deployment
    if [ ! -f "$SSH_PUBKEY" ]; then
        print_error "SSH public key not found: $SSH_PUBKEY"
        print_info "Please run setup.sh first to generate SSH keys"
        exit 1
    fi

    # Check for sshpass if using password auth
    if [ "$USE_PASSWORD" = "true" ] && ! command -v sshpass &> /dev/null; then
        print_warning "sshpass not found - will prompt for password on each connection"
    fi

    print_success "Prerequisites check passed"
}

# Create preparation tarball
create_tarball() {
    print_section "Creating Preparation Tarball"

    local temp_dir=$(mktemp -d)
    local prep_dir="${temp_dir}/wazuh-prep"

    mkdir -p "$prep_dir"

    # Copy files
    cp "$PREP_SCRIPT" "$prep_dir/"
    cp "$SSH_PUBKEY" "$prep_dir/ansible_key.pub"

    # Create tarball
    tar -czf "$PREP_TARBALL" -C "$temp_dir" "wazuh-prep"

    rm -rf "$temp_dir"

    print_success "Created tarball: $PREP_TARBALL"
}

# Deploy to a single host
deploy_to_host() {
    local host="$1"
    local result_file="$2"

    echo "STARTED" > "$result_file"

    print_info "Deploying to: $host"

    local ssh_opts="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=30 -p $SSH_PORT"

    if [ "$USE_PASSWORD" != "true" ] && [ -f "$SSH_KEY" ]; then
        ssh_opts="$ssh_opts -i $SSH_KEY"
    fi

    # Test connectivity
    if ! ssh $ssh_opts "${REMOTE_USER}@${host}" "echo 'Connection successful'" &>/dev/null; then
        print_error "Cannot connect to $host"
        echo "FAILED: Cannot connect" > "$result_file"
        return 1
    fi

    # Copy tarball
    print_info "[$host] Copying preparation files..."
    local scp_opts="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $SSH_PORT"
    if [ "$USE_PASSWORD" != "true" ] && [ -f "$SSH_KEY" ]; then
        scp_opts="$scp_opts -i $SSH_KEY"
    fi

    if ! scp $scp_opts "$PREP_TARBALL" "${REMOTE_USER}@${host}:/tmp/" &>/dev/null; then
        print_error "[$host] Failed to copy tarball"
        echo "FAILED: Copy failed" > "$result_file"
        return 1
    fi

    # Execute preparation script
    print_info "[$host] Executing preparation script..."

    local prep_cmd="
        cd /tmp && \
        tar -xzf wazuh-client-prep.tar.gz && \
        cd wazuh-prep && \
        chmod +x prepare-client.sh && \
        ./prepare-client.sh -u '$ANSIBLE_USER' -k ansible_key.pub"

    if [ "$MINIMAL_MODE" = "true" ]; then
        prep_cmd="$prep_cmd --minimal"
    fi

    prep_cmd="$prep_cmd && rm -rf /tmp/wazuh-prep /tmp/wazuh-client-prep.tar.gz"

    if ssh $ssh_opts "${REMOTE_USER}@${host}" "sudo bash -c '$prep_cmd'" 2>&1; then
        print_success "[$host] Preparation complete"
        echo "SUCCESS" > "$result_file"
        return 0
    else
        print_error "[$host] Preparation failed"
        echo "FAILED: Script execution failed" > "$result_file"
        return 1
    fi
}

# Deploy to all hosts
deploy_to_all() {
    print_section "Deploying to ${#HOSTS[@]} host(s)"

    local temp_dir=$(mktemp -d)
    local pids=()
    local host_count=0
    local success_count=0
    local fail_count=0

    for host in "${HOSTS[@]}"; do
        local result_file="${temp_dir}/${host//\//_}.result"

        # Run in background
        deploy_to_host "$host" "$result_file" &
        pids+=($!)
        ((host_count++))

        # Limit parallel jobs
        if [ ${#pids[@]} -ge $PARALLEL_JOBS ]; then
            wait "${pids[0]}"
            pids=("${pids[@]:1}")
        fi
    done

    # Wait for remaining jobs
    for pid in "${pids[@]}"; do
        wait "$pid" || true
    done

    # Collect results
    print_section "Deployment Results"

    for host in "${HOSTS[@]}"; do
        local result_file="${temp_dir}/${host//\//_}.result"
        if [ -f "$result_file" ]; then
            local result=$(cat "$result_file")
            if [ "$result" = "SUCCESS" ]; then
                echo -e "${GREEN}✓${NC} $host"
                ((success_count++))
            else
                echo -e "${RED}✗${NC} $host - $result"
                ((fail_count++))
            fi
        else
            echo -e "${YELLOW}?${NC} $host - Unknown"
        fi
    done

    rm -rf "$temp_dir"

    echo ""
    echo -e "Total: $host_count | ${GREEN}Success: $success_count${NC} | ${RED}Failed: $fail_count${NC}"
}

# Verify deployment
verify_deployment() {
    print_section "Verifying Deployment"

    local verified=0
    local failed=0

    for host in "${HOSTS[@]}"; do
        print_info "Testing: $host"

        local ssh_opts="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 -p $SSH_PORT"

        # Test with new Ansible user and key
        if ssh $ssh_opts -i "$SSH_KEY" "${ANSIBLE_USER}@${host}" "echo 'Ansible user OK'" &>/dev/null; then
            print_success "[$host] Ansible user accessible"
            ((verified++))
        else
            print_error "[$host] Cannot connect as Ansible user"
            ((failed++))
        fi
    done

    echo ""
    echo -e "Verified: $verified | Failed: $failed"
}

# Generate inventory entries
generate_inventory() {
    print_section "Ansible Inventory Entries"

    echo "Add these entries to your inventory/hosts.yml:"
    echo ""
    echo "---"
    echo "all:"
    echo "  vars:"
    echo "    ansible_user: ${ANSIBLE_USER}"
    echo "    ansible_ssh_private_key_file: ${SSH_KEY}"
    echo "    ansible_port: ${SSH_PORT}"
    echo ""
    echo "  children:"
    echo "    wazuh_agents:"
    echo "      hosts:"

    for host in "${HOSTS[@]}"; do
        echo "        ${host}:"
    done
}

# Main function
main() {
    parse_args "$@"
    load_hosts_from_file

    print_header "Wazuh Client Preparation Deployment"

    # Check if we have hosts
    if [ ${#HOSTS[@]} -eq 0 ]; then
        print_error "No hosts specified"
        echo ""
        usage
    fi

    echo "Hosts to prepare:"
    for host in "${HOSTS[@]}"; do
        echo "  - $host"
    done
    echo ""

    check_prerequisites

    # Create or verify tarball
    if [ ! -f "$PREP_TARBALL" ]; then
        create_tarball
    else
        print_info "Using existing tarball: $PREP_TARBALL"
    fi

    # Confirm before proceeding
    echo ""
    read -p "Proceed with deployment? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deployment cancelled"
        exit 0
    fi

    deploy_to_all

    # Ask to verify
    echo ""
    read -p "Verify deployment? [Y/n] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        verify_deployment
    fi

    # Generate inventory
    generate_inventory
}

main "$@"
