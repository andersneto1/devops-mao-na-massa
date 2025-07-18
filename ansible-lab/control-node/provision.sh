#!/bin/sh
set -e  # Aborta o script em caso de erro

echo "Updating the system..."
dnf update -y >/dev/null 2>&1

echo "Installing kernel headers and development tools..."
dnf install -y kernel-devel kernel-headers

echo "Installing EPEL repository..."
dnf install -y epel-release

echo "Installing Ansible..."
dnf install -y ansible

cat <<EOT >> /etc/hosts
192.168.1.2 control-node
192.168.1.3 app01
192.168.1.4 db01
EOT

echo "Provisioning complete."
