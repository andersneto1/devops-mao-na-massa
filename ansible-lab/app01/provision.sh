#!/bin/bash
set -e

echo "Atualizar sistema..."
dnf update -y

echo "Ativar repositório EPEL..."
dnf install -y epel-release

echo "Instalar dependências para o VirtualBox Guest Additions..."
dnf install -y kernel-devel kernel-headers gcc make perl bzip2 dkms elfutils-libelf-devel

# Verifica se é necessário reiniciar para aplicar novo kernel
running_kernel=$(uname -r)
installed_kernel=$(rpm -q --qf "%{VERSION}-%{RELEASE}.%{ARCH}\n" kernel | tail -n1)

if [[ "$running_kernel" != "$installed_kernel" ]]; then
  echo "Kernel atualizado. Reboot necessário para carregar o novo kernel ($installed_kernel)."
  touch /var/run/reboot-required
  reboot
  exit 0
fi

echo "Montar e instalar VBoxGuestAdditions manualmente (se necessário)..."
if [ ! -f /opt/VBoxGuestAdditions/VBoxGuestAdditions.iso ]; then
  mkdir -p /mnt/cdrom
  mount /dev/cdrom /mnt/cdrom || true
  if [ -f /mnt/cdrom/VBoxLinuxAdditions.run ]; then
    bash /mnt/cdrom/VBoxLinuxAdditions.run || true
  fi
fi

echo "Adicionar chave SSH ao utilizador vagrant..."

mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
touch /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys

cat << EOT >> /home/vagrant/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVwULeV75yomvzwxkLPC6ZmsIdC3CnoT9CNVoKNvassRWRbI7jR47LRqlEsaORtzx6fdZF2rdyhXkeDep2yUQDmxAhuUfiumGFpO+VQmi/2otI9W/gL761pQmyDwOKOwkt5eqR/08K0g0nliI7Em/4VfCai/BtRgV8eCT9qMxAIevigYCGkdzqLlt31PFTUshPw4Ew44hbMWDW9Mmp9zd7ytnKJu20o9b+oSsEerxEnJkcFmguIpIcVFdZP1ZUN+BWtbxx8DHGu+lTzkL6izbHbakhrOn+8p7TJhwvU00lyWRoMNwnUHIdwWSuuZm3Qo6zLegk5XtpliPxFTg5GKik+JekMMZ/LW8+YJJaYMEMq38bLIbKLgg5MNiUXC0mL+xe5r4LBXgijWzzn4MF3xvZp5oKv9rH0cxBY/Cc9iIZRtjciQrGM9W1zvD+KXJb2WpZaINO+5R5TNm82uar7LfUEu9bXtYIKgyhAS+aprEc0VQlfihRlhQYnwDskutf+v0= vagrant@control-node
EOT

chown -R vagrant:vagrant /home/vagrant/.ssh

echo "Provisionamento completo."
