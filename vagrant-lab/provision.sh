#!/usr/bin/env bash

set -e  # Aborta o script em caso de erro

echo "Updating the system..."
yum update -y >/dev/null 2>&1

echo "Installing kernel-devel..."
yum install -y kernel-devel

echo "Installing Apache and setting it up..."
yum install -y httpd >/dev/null 2>&1

echo "Copying HTML files to /var/www/html/..."
cp -r /vagrant/html/* /var/www/html/

echo "Current working directory: $(pwd)"
echo "Listing contents of /var/www/html/..."
ls -la /var/www/html/

echo "Starting Apache service..."
service httpd start

echo "Provisioning complete."