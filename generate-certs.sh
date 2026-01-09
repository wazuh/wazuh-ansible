#!/bin/bash

# Wazuh Certificate Generation Script
# This script generates self-signed certificates for Wazuh components

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTS_DIR="${SCRIPT_DIR}/files/certs"
CONFIG_FILE="${SCRIPT_DIR}/group_vars/all.yml"

print_header() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check for required tools
check_requirements() {
    if ! command -v openssl &> /dev/null; then
        print_error "OpenSSL is required but not installed."
        exit 1
    fi
}

# Parse nodes from config
parse_nodes() {
    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "Configuration file not found: $CONFIG_FILE"
        print_info "Please run ./setup.sh first to generate the configuration."
        exit 1
    fi
}

# Create certificates directory
create_dirs() {
    mkdir -p "$CERTS_DIR"
    print_success "Created certificates directory: $CERTS_DIR"
}

# Generate Root CA
generate_root_ca() {
    print_info "Generating Root CA..."

    # Generate CA private key
    openssl genrsa -out "${CERTS_DIR}/root-ca-key.pem" 4096 2>/dev/null

    # Generate CA certificate
    openssl req -new -x509 -sha256 -days 3650 \
        -key "${CERTS_DIR}/root-ca-key.pem" \
        -out "${CERTS_DIR}/root-ca.pem" \
        -subj "/C=US/ST=California/L=California/O=Wazuh/OU=Wazuh/CN=Wazuh Root CA" \
        2>/dev/null

    print_success "Generated Root CA certificate"
}

# Generate Admin certificate
generate_admin_cert() {
    print_info "Generating Admin certificate..."

    # Generate private key
    openssl genrsa -out "${CERTS_DIR}/admin-key.pem" 2048 2>/dev/null

    # Generate CSR
    openssl req -new -sha256 \
        -key "${CERTS_DIR}/admin-key.pem" \
        -out "${CERTS_DIR}/admin.csr" \
        -subj "/C=US/ST=California/L=California/O=Wazuh/OU=Wazuh/CN=admin" \
        2>/dev/null

    # Generate certificate
    openssl x509 -req -sha256 -days 3650 \
        -in "${CERTS_DIR}/admin.csr" \
        -CA "${CERTS_DIR}/root-ca.pem" \
        -CAkey "${CERTS_DIR}/root-ca-key.pem" \
        -CAcreateserial \
        -out "${CERTS_DIR}/admin.pem" \
        2>/dev/null

    rm -f "${CERTS_DIR}/admin.csr"
    print_success "Generated Admin certificate"
}

# Generate certificate for a node
generate_node_cert() {
    local node_name="$1"
    local node_ip="$2"
    local san_entries="$3"

    print_info "Generating certificate for: $node_name ($node_ip)"

    # Create extension file for SAN
    cat > "${CERTS_DIR}/${node_name}.ext" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${node_name}
DNS.2 = localhost
IP.1 = ${node_ip}
IP.2 = 127.0.0.1
${san_entries}
EOF

    # Generate private key
    openssl genrsa -out "${CERTS_DIR}/${node_name}-key.pem" 2048 2>/dev/null

    # Generate CSR
    openssl req -new -sha256 \
        -key "${CERTS_DIR}/${node_name}-key.pem" \
        -out "${CERTS_DIR}/${node_name}.csr" \
        -subj "/C=US/ST=California/L=California/O=Wazuh/OU=Wazuh/CN=${node_name}" \
        2>/dev/null

    # Generate certificate with SAN
    openssl x509 -req -sha256 -days 3650 \
        -in "${CERTS_DIR}/${node_name}.csr" \
        -CA "${CERTS_DIR}/root-ca.pem" \
        -CAkey "${CERTS_DIR}/root-ca-key.pem" \
        -CAcreateserial \
        -out "${CERTS_DIR}/${node_name}.pem" \
        -extfile "${CERTS_DIR}/${node_name}.ext" \
        2>/dev/null

    rm -f "${CERTS_DIR}/${node_name}.csr" "${CERTS_DIR}/${node_name}.ext"
    print_success "Generated certificate for: $node_name"
}

# Generate Dashboard certificate
generate_dashboard_cert() {
    print_info "Generating Dashboard certificate..."
    generate_node_cert "dashboard" "0.0.0.0" ""
}

# Main function
main() {
    print_header "Wazuh Certificate Generator"

    check_requirements
    create_dirs
    parse_nodes

    # Generate Root CA
    generate_root_ca

    # Generate Admin certificate
    generate_admin_cert

    # Generate Dashboard certificate
    generate_dashboard_cert

    echo
    print_info "Parsing node configuration..."
    echo

    # Read indexer nodes from config and generate certs
    if grep -q "wazuh_indexer_nodes:" "$CONFIG_FILE"; then
        print_info "Generating Indexer certificates..."
        local i=1
        while IFS= read -r line; do
            if [[ "$line" =~ ip:\ *(.+) ]]; then
                local ip="${BASH_REMATCH[1]}"
                ip=$(echo "$ip" | tr -d '"' | tr -d "'")
                generate_node_cert "indexer-${i}" "$ip" ""
                ((i++))
            fi
        done < <(sed -n '/wazuh_indexer_nodes:/,/^[a-z]/p' "$CONFIG_FILE" | head -n -1)
    fi

    # Read manager nodes from config and generate certs
    if grep -q "wazuh_manager_nodes:" "$CONFIG_FILE"; then
        print_info "Generating Manager certificates..."
        local i=1
        while IFS= read -r line; do
            if [[ "$line" =~ ip:\ *(.+) ]]; then
                local ip="${BASH_REMATCH[1]}"
                ip=$(echo "$ip" | tr -d '"' | tr -d "'")
                generate_node_cert "manager-${i}" "$ip" ""
                ((i++))
            fi
        done < <(sed -n '/wazuh_manager_nodes:/,/^[a-z]/p' "$CONFIG_FILE" | head -n -1)
    fi

    print_header "Certificate Generation Complete"

    echo -e "Certificates have been generated in: ${CYAN}${CERTS_DIR}${NC}"
    echo
    echo "Generated files:"
    ls -la "$CERTS_DIR"
    echo
    print_info "Remember to copy these certificates to the appropriate locations"
    print_info "or update the certificate paths in your configuration."
}

main "$@"
