# 🖥️ Server Infrastructure Checker

A comprehensive Bash script for monitoring and checking the status of multiple servers, applications, and Docker containers across your infrastructure.

## 📋 Overview

This script provides a clean, tabular view of system information, application status, and running Docker containers across multiple servers. It's designed for system administrators who need to quickly assess the health and status of their server infrastructure.

## ✨ Features

- 🌐 **Multi-server support** - Check all servers or target specific ones
- 📊 **Beautiful table output** - Clean, professional formatting with Unicode borders
- 🔍 **Application detection** - Automatically detects Docker, GitLab, Grafana, and Docker Swarm
- 🐳 **Docker container monitoring** - Shows running containers with status
- 🛡️ **Secure SSH handling** - Password prompting with secure storage
- 📱 **Flexible usage** - Command-line flags for different use cases
- ⚡ **Error handling** - Graceful handling of connection failures

## 🚀 Quick Start

### Prerequisites

- `sshpass` - For automated SSH authentication
- `ssh` - SSH client
- Bash 4.0+ - For array support

#### Install Prerequisites (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install sshpass openssh-client
```

#### Install Prerequisites (CentOS/RHEL)
```bash
sudo yum install sshpass openssh-clients
# or for newer versions
sudo dnf install sshpass openssh-clients
```

### Installation

1. Clone or download the script:
```bash
wget https://your-repo/check_servers.sh
# or
curl -O https://your-repo/check_servers.sh
```

2. Make it executable:
```bash
chmod +x check_servers.sh
```

3. Configure your servers (edit the script):
```bash
vim check_servers.sh
```

## 🔧 Configuration

### Server Configuration

Edit the `SERVERS` array in the script to include your server IPs or hostnames:

```bash
SERVERS=(
    10.219.213.5
    10.219.213.10
    10.219.213.11
    your.server.com
    192.168.1.100
)
```

### SSH User Configuration

Modify the `SSH_USER` variable if needed:

```bash
SSH_USER="root"  # Change to your SSH username
```

### Application Monitoring

The script checks for these applications by default:
- **Docker** - Container platform
- **Docker Swarm** - Container orchestration
- **GitLab** - DevOps platform
- **Grafana** - Monitoring and visualization

To add more applications, extend the `APPLICATIONS` array:

```bash
APPLICATIONS=(
    "App Name" "detection_command" "version_command"
    "Nginx" "command -v nginx" "nginx -v"
    "Apache" "command -v apache2" "apache2 -v"
)
```

## 📖 Usage

### Command Line Options

```bash
Usage: ./check_servers.sh [OPTIONS]

Options:
  -A, --all           Check all configured servers
  -S, --srv SERVER    Check a specific server (IP or hostname)
  -h, --help          Show help message

Examples:
  ./check_servers.sh -A                    # Check all servers
  ./check_servers.sh --all                 # Check all servers
  ./check_servers.sh -S 10.219.213.5       # Check specific server
  ./check_servers.sh --srv 10.219.213.10   # Check specific server
```

### Usage Examples

#### Check All Servers
```bash
./check_servers.sh -A
```

#### Check Specific Server
```bash
./check_servers.sh -S 10.219.213.5
```

#### Get Help
```bash
./check_servers.sh -h
```

## 📊 Sample Output

```
Enter SSH password for root: 

🚀 Starting check for all 6 configured servers...

╔═══════════════════════════════════════════════════════════════════════════════════╗
║                              Server: 10.219.213.5                              ║
╚═══════════════════════════════════════════════════════════════════════════════════╝

📋 System Information:
─────────────────────
OS: Ubuntu 22.04.4 LTS
Kernel: 5.15.0-94-generic
Architecture: x86_64
Uptime: up 2 days, 5 hours, 59 minutes

🔍 Application Status:
─────────────────────
┌─────────────────┬─────────────────┬──────────────────────────────────────────┐
│ Application     │ Status          │ Version/Info                             │
├─────────────────┼─────────────────┼──────────────────────────────────────────┤
│ Docker          │ ✅ Installed    │ Docker version 24.0.5, build ced0996     │
│ Docker Swarm    │ ❌ Not Found    │ N/A                                      │
│ GitLab          │ ✅ Installed    │ 16.2.4                                   │
│ Grafana         │ ❌ Not Found    │ N/A                                      │
└─────────────────┴─────────────────┴──────────────────────────────────────────┘

🐳 Running Docker Containers:
────────────────────────────
┌──────────────────────┬────────────────────────────────┬─────────────────┐
│ Container Name       │ Image                          │ Status          │
├──────────────────────┼────────────────────────────────┼─────────────────┤
│ nginx-proxy          │ nginx:latest                   │ Up 2 days       │
│ app-backend          │ myapp:v1.2.3                   │ Up 5 hours      │
└──────────────────────┴────────────────────────────────┴─────────────────┘

╔═══════════════════════════════════════════════════════════════════════════════════╗
║                              All servers checked.                                ║
║                         ✅ Success: 5 | ❌ Failed: 1                             ║
╚═══════════════════════════════════════════════════════════════════════════════════╝
```

## 🔒 Security Considerations

- **Password Handling**: The script prompts for SSH password securely and unsets it after use
- **SSH Options**: Uses `StrictHostKeyChecking=no` for automation - consider using SSH keys in production
- **Network Security**: Ensure your servers are accessible via SSH and properly secured

### Recommended: SSH Key Authentication

For production use, consider setting up SSH key authentication:

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096

# Copy public key to servers
ssh-copy-id root@10.219.213.5

# Modify script to remove password prompting
```

## 🛠️ Troubleshooting

### Common Issues

#### `sshpass: command not found`
```bash
# Install sshpass
sudo apt install sshpass  # Ubuntu/Debian
sudo yum install sshpass  # CentOS/RHEL
```

#### Connection timeouts
- Verify server IPs/hostnames are correct
- Check network connectivity: `ping server_ip`
- Verify SSH service is running: `ssh user@server_ip`

#### Permission denied
- Verify SSH username is correct
- Check SSH key permissions (if using key auth)
- Verify user has required permissions on target servers

#### Docker commands fail
- Ensure the SSH user has Docker permissions
- Add user to docker group: `usermod -aG docker username`

## 🔧 Customization

### Adding New Applications

To monitor additional applications, add entries to the `APPLICATIONS` array:

```bash
APPLICATIONS=(
    # Existing entries...
    "PostgreSQL" "command -v psql" "psql --version"
    "Redis" "command -v redis-cli" "redis-cli --version"
    "Node.js" "command -v node" "node --version"
)
```

### Modifying Table Layouts

Adjust column widths in the print functions:

```bash
# In print_table_header() and related functions
printf "┌─%-20s─┬─%-20s─┬─%-50s─┐\n"  # Wider columns
```

### Adding System Checks

Extend the system information section:

```bash
echo "Memory: $(free -h | grep Mem | awk '{print $3 \"/\" $2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $3 \"/\" $2 \" (\" $5 \" used)\"}')"
```

## 📝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
