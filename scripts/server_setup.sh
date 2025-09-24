#!/bin/bash

# This script sets up Nginx, PHP, and WordPress on Ubuntu

set -e  # Exit on any error

# Variables
DB_NAME="wordpress"
DB_USER="wp_user"
DB_PASS="wp_pass123"
WP_DIR="/var/www/wordpress"
NGINX_CONF="/etc/nginx/sites-available/wordpress"

echo "---- Updating package manager ----"
sudo apt update -y && sudo apt upgrade -y

echo "---- Installing Nginx, PHP, and required extensions ----"
sudo apt install -y nginx php-fpm php-mysql php-cli php-curl php-xml php-mbstring unzip curl

echo "---- Configuring Nginx for WordPress ----"
# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Create WordPress config
cat <<EOF | sudo tee $NGINX_CONF
server {
    listen 80;
    server_name _;
    root $WP_DIR;

    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/

echo "---- Creating WordPress directory ----"
sudo mkdir -p $WP_DIR
cd /tmp

echo "---- Downloading WordPress ----"
curl -O https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz

echo "---- Moving WordPress files ----"
sudo rsync -av wordpress/ $WP_DIR/

echo "---- Setting permissions ----"
sudo chown -R www-data:www-data $WP_DIR
sudo find $WP_DIR -type d -exec chmod 755 {} \;
sudo find $WP_DIR -type f -exec chmod 644 {} \;

echo "---- Restarting Nginx and PHP ----"
sudo systemctl restart nginx
sudo systemctl restart php*-fpm

echo "✅ WordPress setup is ready. Open your server’s IP in a browser to complete installation."
