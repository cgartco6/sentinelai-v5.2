#!/bin/bash
# Configure static IP
# Edit IP addresses before running

INTERFACE="eth0"
STATIC_IP="192.168.1.50/24"
GATEWAY="192.168.1.1"
DNS="8.8.8.8 1.1.1.1"

sudo nmcli con mod "System $INTERFACE" ipv4.addresses $STATIC_IP
sudo nmcli con mod "System $INTERFACE" ipv4.gateway $GATEWAY
sudo nmcli con mod "System $INTERFACE" ipv4.dns "$DNS"
sudo nmcli con mod "System $INTERFACE" ipv4.method manual
sudo nmcli con up "System $INTERFACE"
echo "Static IP configured: $STATIC_IP"
