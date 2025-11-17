#!/bin/bash
# Samba
sudo apt install -y samba
sudo smbpasswd -a $USER
sudo systemctl enable smbd
sudo systemctl start smbd

# FTP/SFTP
sudo apt install -y vsftpd
sudo systemctl enable vsftpd
sudo systemctl start vsftpd
