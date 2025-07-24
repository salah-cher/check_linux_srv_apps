#!/bin/bash

# --- Configuration ---
# Array of server hostnames or IP addresses
SERVERS=(
10.219.213.5
10.219.213.10
10.219.213.11
10.219.213.6
10.219.213.12
10.219.213.7
)

# SSH username for all servers
SSH_USER="root"

# --- Applications to Check ---
# Each entry is: "App Name" "Check Command" "Version/Info Command"
APPLICATIONS=(
    "Docker" "command -v docker" "docker --version"
    "Docker Swarm" "docker info | grep Swarm | grep active" "docker info | grep Swarm"
    "GitLab" "command -v gitlab-rake || systemctl is-active gitlab-runsvdir" "cat /opt/gitlab/embedded/service/gitlab-rails/VERSION || gitlab-rake gitlab:env:info"
    "Grafana" "command -v grafana-server || systemctl is-active grafana-server" "grafana-server -v || grafana-server -v"
)

# --- Helper Functions ---
print_table_header() {
    local col1_width=$1
    local col2_width=$2
    local col3_width=$3
    
    printf "┌─%-${col1_width}s─┬─%-${col2_width}s─┬─%-${col3_width}s─┐\n" "$(printf '%*s' $col1_width | tr ' ' '─')" "$(printf '%*s' $col2_width | tr ' ' '─')" "$(printf '%*s' $col3_width | tr ' ' '─')"
    printf "│ %-${col1_width}s │ %-${col2_width}s │ %-${col3_width}s │\n" "Application" "Status" "Version/Info"
    printf "├─%-${col1_width}s─┼─%-${col2_width}s─┼─%-${col3_width}s─┤\n" "$(printf '%*s' $col1_width | tr ' ' '─')" "$(printf '%*s' $col2_width | tr ' ' '─')" "$(printf '%*s' $col3_width | tr ' ' '─')"
}

print_table_row() {
    local col1_width=$1
    local col2_width=$2
    local col3_width=$3
    local app_name="$4"
    local status="$5"
    local version="$6"
    
    # Truncate version if too long
    if [ ${#version} -gt $col3_width ]; then
        version="${version:0:$((col3_width-3))}..."
    fi
    
    printf "│ %-${col1_width}s │ %-${col2_width}s │ %-${col3_width}s │\n" "$app_name" "$status" "$version"
}

print_table_footer() {
    local col1_width=$1
    local col2_width=$2
    local col3_width=$3
    
    printf "└─%-${col1_width}s─┴─%-${col2_width}s─┴─%-${col3_width}s─┘\n" "$(printf '%*s' $col1_width | tr ' ' '─')" "$(printf '%*s' $col2_width | tr ' ' '─')" "$(printf '%*s' $col3_width | tr ' ' '─')"
}

print_docker_header() {
    printf "┌─%-20s─┬─%-30s─┬─%-15s─┐\n" "$(printf '%*s' 20 | tr ' ' '─')" "$(printf '%*s' 30 | tr ' ' '─')" "$(printf '%*s' 15 | tr ' ' '─')"
    printf "│ %-20s │ %-30s │ %-15s │\n" "Container Name" "Image" "Status"
    printf "├─%-20s─┼─%-30s─┼─%-15s─┤\n" "$(printf '%*s' 20 | tr ' ' '─')" "$(printf '%*s' 30 | tr ' ' '─')" "$(printf '%*s' 15 | tr ' ' '─')"
}

print_docker_row() {
    local name="$1"
    local image="$2"
    local status="$3"
    
    # Truncate if too long
    if [ ${#name} -gt 20 ]; then
        name="${name:0:17}..."
    fi
    if [ ${#image} -gt 30 ]; then
        image="${image:0:27}..."
    fi
    if [ ${#status} -gt 15 ]; then
        status="${status:0:12}..."
    fi
    
    printf "│ %-20s │ %-30s │ %-15s │\n" "$name" "$image" "$status"
}

print_docker_footer() {
    printf "└─%-20s─┴─%-30s─┴─%-15s─┘\n" "$(printf '%*s' 20 | tr ' ' '─')" "$(printf '%*s' 30 | tr ' ' '─')" "$(printf '%*s' 15 | tr ' ' '─')"
}

# --- Script Logic ---
# Prompt for SSH password
read -s -p "Enter SSH password for $SSH_USER: " SSH_PASS
echo
export SSHPASS="$SSH_PASS" # Export password for sshpass

for SERVER in "${SERVERS[@]}"; do
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                              Server: $SERVER                              ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════════╝"
    
    # Basic System Information
    echo ""
    echo "📋 System Information:"
    echo "─────────────────────"
    if sshpass -e ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SSH_USER@$SERVER" '
        echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d\" -f2)"
        echo "Kernel: $(uname -r)"
        echo "Architecture: $(uname -m)"
        echo "Uptime: $(uptime -p)"
    '; then
        echo ""
    else
        echo "❌ Error: Could not connect to $SERVER or get system info."
        echo ""
        continue # Skip to next server if connection fails
    fi
    
    # Application Status Table
    echo "🔍 Application Status:"
    echo "─────────────────────"
    
    # Define column widths
    local col1_width=15
    local col2_width=15
    local col3_width=40
    
    print_table_header $col1_width $col2_width $col3_width
    
    for (( i=0; i<${#APPLICATIONS[@]}; i+=3 )); do
        APP_NAME="${APPLICATIONS[$i]}"
        CHECK_CMD="${APPLICATIONS[$i+1]}"
        VERSION_CMD="${APPLICATIONS[$i+2]}"
        
        if sshpass -e ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SSH_USER@$SERVER" "$CHECK_CMD" > /dev/null 2>&1; then
            STATUS="✅ Installed"
            VERSION=$(sshpass -e ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SSH_USER@$SERVER" "$VERSION_CMD" 2>/dev/null | head -1 | tr -d '\n\r')
            if [ -z "$VERSION" ]; then
                VERSION="Available"
            fi
        else
            STATUS="❌ Not Found"
            VERSION="N/A"
        fi
        
        print_table_row $col1_width $col2_width $col3_width "$APP_NAME" "$STATUS" "$VERSION"
    done
    
    print_table_footer $col1_width $col2_width $col3_width
    
    # Check for running Docker containers only
    echo ""
    echo "🐳 Running Docker Containers:"
    echo "────────────────────────────"
    
    if sshpass -e ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SSH_USER@$SERVER" "command -v docker >/dev/null" 2>&1; then
        # Get only running containers
        DOCKER_OUTPUT=$(sshpass -e ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SSH_USER@$SERVER" "docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}'" 2>/dev/null)
        
        if [ -n "$DOCKER_OUTPUT" ]; then
            print_docker_header
            echo "$DOCKER_OUTPUT" | while IFS=$'\t' read -r name image status; do
                print_docker_row "$name" "$image" "$status"
            done
            print_docker_footer
        else
            echo "No running Docker containers found."
        fi
    else
        echo "Docker not installed or not accessible."
    fi
    
    echo ""
done

unset SSHPASS # Unset the password variable for security

echo ""
echo "╔═══════════════════════════════════════════════════════════════════════════════════╗"
echo "║                              All servers checked.                                ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════════╝"
