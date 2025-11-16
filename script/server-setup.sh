#!/bin/bash

echo "==============================================="
echo " FULL AUTOMATED SERVER INSTALLER (Ubuntu 24.04)"
echo "==============================================="

# -----------------------------------------------------------
# 0. UPDATE SYSTEM
# -----------------------------------------------------------
apt update && apt upgrade -y

# -----------------------------------------------------------
# 1. STATIC IP SETUP
# -----------------------------------------------------------
IFACE=$(ip -o -4 route show to default | awk '{print $5}')

echo "Setting static IP for interface: $IFACE"

cat <<EOF >/etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    $IFACE:
      dhcp4: no
      addresses:
        - 192.168.1.50/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8,1.1.1.1]
EOF

netplan apply

# -----------------------------------------------------------
# 2. DOCKER + PORTAINER
# -----------------------------------------------------------
apt install ca-certificates curl gnupg -y
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo $VERSION_CODENAME) stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
systemctl enable docker
systemctl start docker

docker volume create portainer_data
docker run -d -p 9000:9000 -p 9443:9443 --name portainer \
--restart=always \
-v /var/run/docker.sock:/var/run/docker.sock \
-v portainer_data:/data \
portainer/portainer-ce

# -----------------------------------------------------------
# 3. LAMP STACK (Apache + PHP + MySQL)
# -----------------------------------------------------------
apt install apache2 mysql-server php libapache2-mod-php php-mysql php-cli \
php-curl php-xml php-zip php-gd php-mbstring php-intl -y

mysql_secure_installation <<EOF
y
n
y
y
y
EOF

# -----------------------------------------------------------
# 4. NGINX + PHP-FPM
# -----------------------------------------------------------
apt install nginx php-fpm -y

# -----------------------------------------------------------
# 5. WORDPRESS (Docker)
# -----------------------------------------------------------
mkdir -p /opt/wordpress
cat <<EOF >/opt/wordpress/docker-compose.yml
version: '3.8'
services:
  db:
    image: mysql:8
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass123
      MYSQL_DATABASE: wpdb
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass123
    volumes:
      - db_data:/var/lib/mysql

  wordpress:
    image: wordpress
    restart: always
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass123
      WORDPRESS_DB_NAME: wpdb
    volumes:
      - wp_data:/var/www/html

volumes:
  db_data:
  wp_data:
EOF

docker compose -f /opt/wordpress/docker-compose.yml up -d

# -----------------------------------------------------------
# 6. NEXTCLOUD (Docker)
# -----------------------------------------------------------
mkdir -p /opt/nextcloud
cat <<EOF >/opt/nextcloud/docker-compose.yml
version: '3'
services:
  db:
    image: mariadb
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: pass123
      MYSQL_DATABASE: nextclouddb
      MYSQL_USER: ncuser
      MYSQL_PASSWORD: pass123
    volumes:
      - db:/var/lib/mysql

  app:
    image: nextcloud
    restart: always
    ports:
      - "8081:80"
    links:
      - db
    volumes:
      - nc:/var/www/html

volumes:
  db:
  nc:
EOF

docker compose -f /opt/nextcloud/docker-compose.yml up -d

# -----------------------------------------------------------
# 7. SAMBA SHARE
# -----------------------------------------------------------
apt install samba -y
mkdir -p /srv/shared
chmod 777 /srv/shared

cat <<EOF >>/etc/samba/smb.conf

[Shared]
path = /srv/shared
browsable = yes
writable = yes
guest ok = yes
force user = nobody
EOF

systemctl restart smbd

# -----------------------------------------------------------
# 8. FTP SERVER
# -----------------------------------------------------------
apt install vsftpd -y

sed -i 's/#local_enable=YES/local_enable=YES/' /etc/vsftpd.conf
sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf
echo "chroot_local_user=YES" >> /etc/vsftpd.conf

systemctl restart vsftpd

# -----------------------------------------------------------
# 9. PYTHON + AI PACKAGES
# -----------------------------------------------------------
apt install python3 python3-pip python3-venv -y
pip install openai fastapi uvicorn aiohttp requests

# -----------------------------------------------------------
# 10. FIREWALL + FAIL2BAN
# -----------------------------------------------------------
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw allow 8080
ufw allow 8081
ufw allow 9000
ufw --force enable

apt install fail2ban -y

# -----------------------------------------------------------
# 11. HESTIA CP
# -----------------------------------------------------------
wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh -O /root/hestia.sh
bash /root/hestia.sh --apache yes --phpfpm yes --multiphp yes --mysql yes --clamav no --exim yes --dovecot yes --named yes --iptables yes --fail2ban yes --quota no --port 8083 -y

# -----------------------------------------------------------
echo "==============================================="
echo " INSTALLATION COMPLETE!"
echo "==============================================="
echo "Static IP: 192.168.1.50"
echo "WordPress: http://192.168.1.50:8080"
echo "Nextcloud: http://192.168.1.50:8081"
echo "Portainer: https://192.168.1.50:9443"
echo "Hestia CP: https://192.168.1.50:8083"
echo "==============================================="
