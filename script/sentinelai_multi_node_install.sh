#!/bin/bash
# SentinelAI v5.2 Multi-Node Full Cluster Installer
# Ubuntu 24 LTS | AI Agent + Dashboard + Multi-Node Cluster
# Run on each node as admin

set -e

# ==== CONFIGURATION SECTION ====
# Change these values per node
NODE_IP="192.168.1.50"             # Current node IP
GATEWAY_IP="192.168.1.1"
NODE_HOSTNAME="sentinel-node1"
SSH_KEY="/home/admin/.ssh/id_rsa"  # Path to SSH key for multi-node access
INSTALL_HESTIACP="yes"             # yes/no
GIT_REPOS=("https://github.com/username/sentinelai-dashboard.git" "https://github.com/username/sentinelai-agent.git") 
# ================================

echo "🟢 Setting hostname..."
sudo hostnamectl set-hostname $NODE_HOSTNAME

echo "🟢 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "🟢 Installing dependencies..."
sudo apt install -y git python3-pip python3-venv curl wget ufw htop fail2ban unzip openssh-client openssh-server

echo "🟢 Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 5000/tcp
sudo ufw allow 8083/tcp
sudo ufw --force enable

echo "🟢 Configuring passwordless SSH to other nodes..."
if [ ! -f "$SSH_KEY" ]; then
    ssh-keygen -t rsa -b 4096 -f $SSH_KEY -N ""
fi

# Example: Copy keys to other nodes manually if needed
# ssh-copy-id -i $SSH_KEY admin@192.168.1.51

echo "🟢 Creating Python virtual environment..."
python3 -m venv /opt/sentinel_env
source /opt/sentinel_env/bin/activate

echo "🟢 Deploying SentinelAI..."
if [ ! -f "sentinelai-v5.2.zip" ]; then
    echo "❌ sentinelai-v5.2.zip not found! Place it in current directory."
    exit 1
fi
sudo unzip -o sentinelai-v5.2.zip -d /opt/

echo "🟢 Installing Python dependencies..."
pip install --upgrade pip
pip install -r /opt/sentinel_dashboard/dashboard/requirements.txt
pip install -r /opt/sentinel_dashboard/agent/requirements.txt

echo "🟢 Cloning Git repositories for auto-deploy..."
for repo in "${GIT_REPOS[@]}"; do
    name=$(basename $repo .git)
    git clone $repo /opt/sentinel_dashboard/$name || (cd /opt/sentinel_dashboard/$name && git pull)
done

echo "🟢 Setting up systemd services..."
sudo cp /opt/sentinel_dashboard/systemd_services/*.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable sentinel-dashboard
sudo systemctl enable sentinel-agent

echo "🟢 Starting SentinelAI services..."
sudo systemctl start sentinel-dashboard
sudo systemctl start sentinel-agent

# Optional HestiaCP installation
if [ "$INSTALL_HESTIACP" == "yes" ]; then
    echo "🟢 Installing HestiaCP..."
    wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
    sudo bash hst-install.sh --apache yes --nginx yes --phpfpm yes --mysql yes --postgres no --exim yes --dovecot yes --clamav no --softaculous no --interactive no
    echo "🟢 HestiaCP installed at https://$NODE_IP:8083"
fi

echo "🟢 Configuring multi-node static IP..."
sudo nmcli con modify "System eth0" ipv4.addresses $NODE_IP/24
sudo nmcli con modify "System eth0" ipv4.gateway $GATEWAY_IP
sudo nmcli con modify "System eth0" ipv4.method manual
sudo nmcli con up "System eth0"

echo "✅ Installation complete on $NODE_HOSTNAME ($NODE_IP)!"
echo "Dashboard: http://$NODE_IP:5000"
echo "Agent logs: /opt/sentinel_dashboard/agent/logs/"
echo "HestiaCP (optional): https://$NODE_IP:8083"
