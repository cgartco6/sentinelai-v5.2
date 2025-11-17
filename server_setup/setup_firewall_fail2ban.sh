#!/bin/bash
# Setup firewall and fail2ban
sudo apt update && sudo apt install -y ufw fail2ban

# Allow essential ports
sudo ufw allow 22/tcp       # SSH
sudo ufw allow 80/tcp       # HTTP
sudo ufw allow 443/tcp      # HTTPS
sudo ufw allow 5000/tcp     # SentinelAI dashboard
sudo ufw allow 8080/tcp     # Portainer

sudo ufw --force enable

# Basic fail2ban configuration
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
