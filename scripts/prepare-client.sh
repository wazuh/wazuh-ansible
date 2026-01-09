#!/bin/bash

# Wazuh Client Preparation Script
# This script prepares a client machine for Wazuh Agent deployment via Ansible
# Run this script on each target machine before Ansible deployment

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

# Configuration
ANSIBLE_USER="${ANSIBLE_USER:-wazuh-deploy}"
SSH_PORT="${SSH_PORT:-22}"
PUBKEY_FILE="${SCRIPT_DIR}/ansible_key.pub"
MINIMAL_MODE="${MINIMAL_MODE:-false}"
DRY_RUN="${DRY_RUN:-false}"

# Logging
LOG_FILE="/var/log/wazuh-client-prep.log"

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

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE" 2>/dev/null || true
    echo -e "$1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
}

# Detect OS
detect_os() {
    print_section "Detecting Operating System"

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID="$ID"
        OS_VERSION="$VERSION_ID"
        OS_NAME="$NAME"
        OS_FAMILY=""

        case "$OS_ID" in
            ubuntu|debian|linuxmint|pop)
                OS_FAMILY="debian"
                PKG_MANAGER="apt"
                ;;
            fedora)
                OS_FAMILY="fedora"
                PKG_MANAGER="dnf"
                ;;
            rhel|centos|rocky|almalinux|ol|redhat)
                OS_FAMILY="rhel"
                if command -v dnf &> /dev/null; then
                    PKG_MANAGER="dnf"
                else
                    PKG_MANAGER="yum"
                fi
                ;;
            opensuse*|sles)
                OS_FAMILY="suse"
                PKG_MANAGER="zypper"
                ;;
            arch|manjaro)
                OS_FAMILY="arch"
                PKG_MANAGER="pacman"
                ;;
            *)
                print_error "Unsupported OS: $OS_ID"
                exit 1
                ;;
        esac
    elif [ -f /etc/redhat-release ]; then
        OS_FAMILY="rhel"
        OS_NAME=$(cat /etc/redhat-release)
        PKG_MANAGER="yum"
    else
        print_error "Cannot detect operating system"
        exit 1
    fi

    print_success "Detected: $OS_NAME"
    print_info "OS Family: $OS_FAMILY"
    print_info "Package Manager: $PKG_MANAGER"

    log "OS Detection: $OS_NAME ($OS_FAMILY) - Package Manager: $PKG_MANAGER"
}

# Define packages to remove per OS family
get_unnecessary_packages() {
    local packages=""

    case "$OS_FAMILY" in
        debian)
            packages="
                # Desktop environments and related
                ubuntu-desktop
                kubuntu-desktop
                xubuntu-desktop
                lubuntu-desktop
                gnome-shell
                gnome-session
                kde-plasma-desktop
                xfce4
                lxde
                cinnamon
                mate-desktop

                # Display managers
                gdm3
                sddm
                lightdm
                lxdm

                # Office and productivity
                libreoffice*
                thunderbird
                evolution

                # Games
                gnome-games
                aisleriot
                gnome-mines
                gnome-sudoku

                # Media
                rhythmbox
                totem
                cheese
                shotwell

                # Browsers (keep one if needed)
                firefox
                chromium-browser

                # Unnecessary services
                cups
                cups-browsed
                avahi-daemon
                bluetooth
                bluez
                pulseaudio
                pipewire

                # Snaps (if not needed)
                snapd

                # Other bloat
                ubuntu-report
                popularity-contest
                apport
                whoopsie
                kerneloops

                # Development tools not needed for Wazuh
                gcc
                g++
                make

                # Documentation
                man-db
                info
            "
            ;;
        rhel|fedora)
            packages="
                # Desktop environments
                @gnome-desktop
                @kde-desktop-environment
                @xfce-desktop
                @lxde-desktop
                @mate-desktop
                @cinnamon-desktop

                # Display managers
                gdm
                sddm
                lightdm

                # Office
                libreoffice*

                # Media
                rhythmbox
                totem
                cheese

                # Games
                gnome-mines
                gnome-chess

                # Unnecessary services
                cups
                avahi
                bluetooth
                bluez
                pulseaudio
                pipewire

                # Development (if not needed)
                gcc
                gcc-c++

                # Other
                abrt*
                cockpit*
            "
            ;;
        suse)
            packages="
                # Desktop
                patterns-gnome*
                patterns-kde*
                patterns-xfce*

                # Office
                libreoffice*

                # Unnecessary services
                cups
                avahi
                bluetooth
            "
            ;;
        arch)
            packages="
                # Desktop
                gnome
                plasma
                xfce4
                lxde

                # Office
                libreoffice*

                # Unnecessary
                cups
                avahi
                bluez
            "
            ;;
    esac

    echo "$packages" | grep -v '^#' | grep -v '^$' | tr '\n' ' '
}

# Define essential packages for Wazuh/Ansible
get_essential_packages() {
    local packages=""

    case "$OS_FAMILY" in
        debian)
            packages="
                openssh-server
                python3
                python3-apt
                sudo
                curl
                wget
                ca-certificates
                gnupg
                lsb-release
                apt-transport-https
                net-tools
                iproute2
                procps
                systemd
            "
            ;;
        rhel|fedora)
            packages="
                openssh-server
                python3
                python3-dnf
                sudo
                curl
                wget
                ca-certificates
                gnupg2
                net-tools
                iproute
                procps-ng
                systemd
            "
            ;;
        suse)
            packages="
                openssh
                python3
                sudo
                curl
                wget
                ca-certificates
            "
            ;;
        arch)
            packages="
                openssh
                python
                sudo
                curl
                wget
                ca-certificates
            "
            ;;
    esac

    echo "$packages" | grep -v '^$' | tr '\n' ' '
}

# Remove unnecessary packages
remove_unnecessary_packages() {
    print_section "Removing Unnecessary Packages"

    local packages=$(get_unnecessary_packages)

    if [ "$DRY_RUN" = "true" ]; then
        print_info "[DRY RUN] Would remove packages:"
        echo "$packages" | tr ' ' '\n' | grep -v '^$' | while read pkg; do
            echo "  - $pkg"
        done
        return
    fi

    case "$PKG_MANAGER" in
        apt)
            # Stop services first
            print_info "Stopping unnecessary services..."
            for service in gdm3 lightdm sddm cups avahi-daemon bluetooth snapd; do
                systemctl stop "$service" 2>/dev/null || true
                systemctl disable "$service" 2>/dev/null || true
            done

            print_info "Removing packages..."
            export DEBIAN_FRONTEND=noninteractive

            # Remove packages (ignore errors for non-existent packages)
            for pkg in $packages; do
                apt-get remove --purge -y "$pkg" 2>/dev/null || true
            done

            # Clean up
            apt-get autoremove -y 2>/dev/null || true
            apt-get autoclean -y 2>/dev/null || true
            apt-get clean 2>/dev/null || true

            # Remove snap completely if installed
            if command -v snap &> /dev/null; then
                print_info "Removing Snap packages..."
                snap list 2>/dev/null | awk 'NR>1 {print $1}' | while read snapname; do
                    snap remove --purge "$snapname" 2>/dev/null || true
                done
                apt-get remove --purge -y snapd 2>/dev/null || true
                rm -rf /var/cache/snapd /snap /var/snap /var/lib/snapd
            fi
            ;;
        dnf|yum)
            print_info "Stopping unnecessary services..."
            for service in gdm lightdm cups avahi bluetooth; do
                systemctl stop "$service" 2>/dev/null || true
                systemctl disable "$service" 2>/dev/null || true
            done

            print_info "Removing packages..."
            for pkg in $packages; do
                $PKG_MANAGER remove -y "$pkg" 2>/dev/null || true
            done

            $PKG_MANAGER autoremove -y 2>/dev/null || true
            $PKG_MANAGER clean all 2>/dev/null || true
            ;;
        zypper)
            print_info "Removing packages..."
            for pkg in $packages; do
                zypper remove -y "$pkg" 2>/dev/null || true
            done
            zypper clean --all 2>/dev/null || true
            ;;
        pacman)
            print_info "Removing packages..."
            for pkg in $packages; do
                pacman -Rns --noconfirm "$pkg" 2>/dev/null || true
            done
            pacman -Sc --noconfirm 2>/dev/null || true
            ;;
    esac

    print_success "Unnecessary packages removed"
}

# Install essential packages
install_essential_packages() {
    print_section "Installing Essential Packages"

    local packages=$(get_essential_packages)

    if [ "$DRY_RUN" = "true" ]; then
        print_info "[DRY RUN] Would install packages:"
        echo "$packages" | tr ' ' '\n' | grep -v '^$' | while read pkg; do
            echo "  - $pkg"
        done
        return
    fi

    case "$PKG_MANAGER" in
        apt)
            apt-get update
            apt-get install -y $packages
            ;;
        dnf|yum)
            $PKG_MANAGER install -y $packages
            ;;
        zypper)
            zypper install -y $packages
            ;;
        pacman)
            pacman -Sy --noconfirm $packages
            ;;
    esac

    print_success "Essential packages installed"
}

# Configure SSH
configure_ssh() {
    print_section "Configuring SSH"

    if [ "$DRY_RUN" = "true" ]; then
        print_info "[DRY RUN] Would configure SSH"
        return
    fi

    # Ensure SSH is installed and running
    case "$OS_FAMILY" in
        debian)
            apt-get install -y openssh-server
            ;;
        rhel|fedora)
            $PKG_MANAGER install -y openssh-server
            ;;
    esac

    # Configure sshd
    local sshd_config="/etc/ssh/sshd_config"

    # Backup original config
    cp "$sshd_config" "${sshd_config}.backup.$(date +%Y%m%d)" 2>/dev/null || true

    # Ensure key authentication is enabled
    sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' "$sshd_config"
    sed -i 's/^#*AuthorizedKeysFile.*/AuthorizedKeysFile .ssh\/authorized_keys/' "$sshd_config"

    # Optionally disable password auth (uncomment if desired)
    # sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$sshd_config"

    # Ensure root login is permitted (or use dedicated user)
    # sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' "$sshd_config"

    # Enable and restart SSH
    systemctl enable sshd 2>/dev/null || systemctl enable ssh 2>/dev/null || true
    systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null || true

    print_success "SSH configured"
}

# Create Ansible deployment user
create_ansible_user() {
    print_section "Creating Ansible Deployment User"

    if [ "$DRY_RUN" = "true" ]; then
        print_info "[DRY RUN] Would create user: $ANSIBLE_USER"
        return
    fi

    # Check if user exists
    if id "$ANSIBLE_USER" &>/dev/null; then
        print_info "User $ANSIBLE_USER already exists"
    else
        # Create user
        useradd -m -s /bin/bash "$ANSIBLE_USER"
        print_success "Created user: $ANSIBLE_USER"
    fi

    # Create .ssh directory
    local ssh_dir="/home/${ANSIBLE_USER}/.ssh"
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
    chown "${ANSIBLE_USER}:${ANSIBLE_USER}" "$ssh_dir"

    # Add to sudoers (passwordless sudo for Ansible)
    local sudoers_file="/etc/sudoers.d/${ANSIBLE_USER}"
    echo "${ANSIBLE_USER} ALL=(ALL) NOPASSWD: ALL" > "$sudoers_file"
    chmod 440 "$sudoers_file"

    print_success "User $ANSIBLE_USER configured with sudo access"
}

# Deploy SSH public key
deploy_ssh_key() {
    print_section "Deploying SSH Public Key"

    if [ "$DRY_RUN" = "true" ]; then
        print_info "[DRY RUN] Would deploy SSH key"
        return
    fi

    local ssh_dir="/home/${ANSIBLE_USER}/.ssh"
    local auth_keys="${ssh_dir}/authorized_keys"

    # Check if public key file exists
    if [ -f "$PUBKEY_FILE" ]; then
        print_info "Found public key file: $PUBKEY_FILE"

        # Create authorized_keys if it doesn't exist
        touch "$auth_keys"

        # Check if key is already present
        if grep -qf "$PUBKEY_FILE" "$auth_keys" 2>/dev/null; then
            print_info "SSH key already present in authorized_keys"
        else
            cat "$PUBKEY_FILE" >> "$auth_keys"
            print_success "SSH key deployed"
        fi

        chmod 600 "$auth_keys"
        chown "${ANSIBLE_USER}:${ANSIBLE_USER}" "$auth_keys"
    else
        print_warning "No public key file found at $PUBKEY_FILE"
        print_info "You can manually add the key later to: $auth_keys"
    fi

    # Also add to root if desired
    if [ "$DEPLOY_TO_ROOT" = "true" ] && [ -f "$PUBKEY_FILE" ]; then
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh
        touch /root/.ssh/authorized_keys
        if ! grep -qf "$PUBKEY_FILE" /root/.ssh/authorized_keys 2>/dev/null; then
            cat "$PUBKEY_FILE" >> /root/.ssh/authorized_keys
            chmod 600 /root/.ssh/authorized_keys
            print_success "SSH key also deployed to root"
        fi
    fi
}

# Configure firewall
configure_firewall() {
    print_section "Configuring Firewall"

    if [ "$DRY_RUN" = "true" ]; then
        print_info "[DRY RUN] Would configure firewall"
        return
    fi

    # UFW (Debian/Ubuntu)
    if command -v ufw &> /dev/null; then
        print_info "Configuring UFW..."
        ufw allow "$SSH_PORT"/tcp comment 'SSH'
        ufw allow 1514/tcp comment 'Wazuh Agent'
        ufw allow 1514/udp comment 'Wazuh Agent'
        ufw allow 1515/tcp comment 'Wazuh Registration'

        # Enable UFW if not already
        if ! ufw status | grep -q "active"; then
            echo "y" | ufw enable
        fi

        print_success "UFW configured"
    fi

    # Firewalld (RHEL/Fedora)
    if command -v firewall-cmd &> /dev/null; then
        print_info "Configuring firewalld..."

        # Ensure firewalld is running
        systemctl start firewalld 2>/dev/null || true
        systemctl enable firewalld 2>/dev/null || true

        firewall-cmd --permanent --add-port="$SSH_PORT"/tcp
        firewall-cmd --permanent --add-port=1514/tcp
        firewall-cmd --permanent --add-port=1514/udp
        firewall-cmd --permanent --add-port=1515/tcp
        firewall-cmd --reload

        print_success "firewalld configured"
    fi
}

# Disable unnecessary services
disable_unnecessary_services() {
    print_section "Disabling Unnecessary Services"

    if [ "$DRY_RUN" = "true" ]; then
        print_info "[DRY RUN] Would disable unnecessary services"
        return
    fi

    local services="
        cups
        cups-browsed
        avahi-daemon
        bluetooth
        ModemManager
        accounts-daemon
        whoopsie
        kerneloops
        apport
        unattended-upgrades
    "

    for service in $services; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            systemctl stop "$service" 2>/dev/null || true
            systemctl disable "$service" 2>/dev/null || true
            print_info "Disabled: $service"
        fi
    done

    print_success "Unnecessary services disabled"
}

# Optimize system for Wazuh
optimize_system() {
    print_section "Optimizing System"

    if [ "$DRY_RUN" = "true" ]; then
        print_info "[DRY RUN] Would optimize system"
        return
    fi

    # Increase file descriptor limits
    cat >> /etc/security/limits.conf << 'EOF'
# Wazuh optimization
* soft nofile 65536
* hard nofile 65536
root soft nofile 65536
root hard nofile 65536
EOF

    # Optimize sysctl settings
    cat >> /etc/sysctl.d/99-wazuh.conf << 'EOF'
# Wazuh optimization
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_tw_reuse = 1
fs.file-max = 2097152
EOF

    sysctl -p /etc/sysctl.d/99-wazuh.conf 2>/dev/null || true

    print_success "System optimized"
}

# Clean up system
cleanup_system() {
    print_section "Cleaning Up System"

    if [ "$DRY_RUN" = "true" ]; then
        print_info "[DRY RUN] Would clean up system"
        return
    fi

    # Remove old kernels (keep current + 1)
    case "$OS_FAMILY" in
        debian)
            apt-get autoremove --purge -y
            # Clean package cache
            apt-get clean
            # Remove old logs
            find /var/log -type f -name "*.gz" -delete 2>/dev/null || true
            find /var/log -type f -name "*.1" -delete 2>/dev/null || true
            journalctl --vacuum-time=7d 2>/dev/null || true
            ;;
        rhel|fedora)
            $PKG_MANAGER autoremove -y
            $PKG_MANAGER clean all
            # Remove old logs
            find /var/log -type f -name "*.gz" -delete 2>/dev/null || true
            journalctl --vacuum-time=7d 2>/dev/null || true
            ;;
    esac

    # Clear temp files
    rm -rf /tmp/* 2>/dev/null || true
    rm -rf /var/tmp/* 2>/dev/null || true

    print_success "System cleaned up"
}

# Generate system report
generate_report() {
    print_section "System Report"

    echo -e "${CYAN}Hostname:${NC} $(hostname)"
    echo -e "${CYAN}OS:${NC} $OS_NAME"
    echo -e "${CYAN}Kernel:${NC} $(uname -r)"
    echo -e "${CYAN}Architecture:${NC} $(uname -m)"
    echo -e "${CYAN}IP Address:${NC} $(hostname -I | awk '{print $1}')"
    echo -e "${CYAN}Ansible User:${NC} $ANSIBLE_USER"
    echo -e "${CYAN}SSH Port:${NC} $SSH_PORT"
    echo ""
    echo -e "${CYAN}Disk Usage:${NC}"
    df -h / | tail -1
    echo ""
    echo -e "${CYAN}Memory:${NC}"
    free -h | head -2
    echo ""
    echo -e "${CYAN}Running Services:${NC}"
    systemctl list-units --type=service --state=running | head -10
}

# Display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Prepare a client machine for Wazuh Agent deployment via Ansible.

OPTIONS:
    -u, --user NAME         Ansible user to create (default: wazuh-deploy)
    -p, --port PORT         SSH port (default: 22)
    -k, --key FILE          Path to SSH public key file
    -m, --minimal           Minimal mode - skip package removal
    -r, --root-key          Also deploy SSH key to root user
    -d, --dry-run           Show what would be done without making changes
    -h, --help              Show this help message

EXAMPLES:
    # Full preparation with SSH key
    $0 -k /path/to/ansible_key.pub

    # Dry run to see what would happen
    $0 --dry-run

    # Minimal mode (just install requirements, don't remove packages)
    $0 --minimal -k /path/to/ansible_key.pub

    # Custom user and port
    $0 -u ansible -p 2222 -k /path/to/key.pub

EOF
    exit 0
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u|--user)
                ANSIBLE_USER="$2"
                shift 2
                ;;
            -p|--port)
                SSH_PORT="$2"
                shift 2
                ;;
            -k|--key)
                PUBKEY_FILE="$2"
                shift 2
                ;;
            -m|--minimal)
                MINIMAL_MODE="true"
                shift
                ;;
            -r|--root-key)
                DEPLOY_TO_ROOT="true"
                shift
                ;;
            -d|--dry-run)
                DRY_RUN="true"
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                ;;
        esac
    done
}

# Main function
main() {
    parse_args "$@"

    print_header "Wazuh Client Preparation Script"

    if [ "$DRY_RUN" = "true" ]; then
        print_warning "Running in DRY RUN mode - no changes will be made"
    fi

    check_root
    detect_os

    # Remove unnecessary packages (unless minimal mode)
    if [ "$MINIMAL_MODE" != "true" ]; then
        remove_unnecessary_packages
    else
        print_info "Skipping package removal (minimal mode)"
    fi

    install_essential_packages
    configure_ssh
    create_ansible_user
    deploy_ssh_key
    configure_firewall
    disable_unnecessary_services
    optimize_system
    cleanup_system
    generate_report

    print_header "Preparation Complete"

    echo -e "The system is now ready for Wazuh deployment via Ansible."
    echo ""
    echo -e "Next steps:"
    echo -e "  1. From your Ansible control node, test connectivity:"
    echo -e "     ${CYAN}ssh -i ~/.ssh/wazuh_ansible_key ${ANSIBLE_USER}@$(hostname -I | awk '{print $1}')${NC}"
    echo ""
    echo -e "  2. Add this host to your Ansible inventory"
    echo ""
    echo -e "  3. Run the Wazuh deployment playbook:"
    echo -e "     ${CYAN}ansible-playbook site.yml${NC}"
    echo ""
}

main "$@"
