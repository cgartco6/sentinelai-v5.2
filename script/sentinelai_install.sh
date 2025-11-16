#!/bin/bash
# SentinelAI v5.2 One-Click Installer
# Ubuntu 24 LTS | Acer i3 | 8GB RAM | 512GB SSD

# Exit on any error
set -e

echo "🟢 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "🟢 Installing dependencies..."
sudo apt install -y git python3-pip python3-venv curl wget ufw htop fail2ban unzip

echo "🟢 Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 5000/tcp      # Dashboard
sudo ufw allow 8083/tcp      # HestiaCP optional
sudo ufw --force enable

echo "🟢 Creating Python virtual environment..."
python3 -m venv /opt/sentinel_env
source /opt/sentinel_env/bin/activate

echo "🟢 Unzipping SentinelAI package..."
if [ ! -f "sentinelai-v5.2.zip" ]; then
    echo "❌ sentinelai-v5.2.zip not found in current directory!"
    exit 1
fi
sudo unzip -o sentinelai-v5.2.zip -d /opt/

echo "🟢 Installing Python dependencies..."
pip install --upgrade pip
pip install -r /opt/sentinel_dashboard/dashboard/requirements.txt
pip install -r /opt/sentinel_dashboard/agent/requirements.txt
pip install -r /opt/sentinel_dashboard/auto_deploy/requirements.txt 2>/dev/null || true

echo "🟢 Configuring systemd services..."
sudo cp /opt/sentinel_dashboard/systemd_services/*.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable sentinel-dashboard
sudo systemctl enable sentinel-agent

echo "🟢 Starting SentinelAI services..."
sudo systemctl start sentinel-dashboard
sudo systemctl start sentinel-agent

echo "🟢 Installation complete!"
echo "Dashboard URL: http://$(hostname -I | awk '{print $1}'):5000"
echo "Agent logs: /opt/sentinel_dashboard/agent/logs/"

echo "✅ SentinelAI v5.2 Galactic Autonomous Cloud AI++ is now running!"
