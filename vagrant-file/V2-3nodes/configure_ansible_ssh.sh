#!/bin/bash

# Vérifier si l'utilisateur est root
if [[ $EUID -ne 0 ]]; then
  echo "Ce script doit être exécuté en tant que root"
  exit 1
fi

# Mise à jour des paquets
echo "Mise à jour des paquets..."
apt-get update -y

# Installation des outils nécessaires
echo "Installation d'OpenSSH, SSHpass, et des outils nécessaires..."
apt-get install -y openssh-server sshpass software-properties-common nano apt-utils

# Ajout du dépôt pour Ansible et installation
echo "Ajout du dépôt officiel pour Ansible..."
apt-add-repository --yes --update ppa:ansible/ansible

echo "Installation d'Ansible..."
apt-get install -y ansible

# Vérification de l'installation d'Ansible
echo "Vérification de l'installation d'Ansible..."
ansible --version || { echo "Échec de l'installation d'Ansible"; exit 1; }

# Démarrage et configuration du serveur SSH
echo "Configuration du serveur SSH..."
mkdir -p /var/run/sshd
echo "root:root" | chpasswd
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
service ssh restart

# Génération des clés SSH pour Ansible
echo "Génération de la clé SSH pour Ansible..."
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N "" -q

# Configuration pour chaque nœud
NODES=("192.168.60.14" "192.168.60.15" "192.168.60.16") # IP des nœuds
NODE_PASSWORD="root" # Mot de passe des nœuds

for NODE in "${NODES[@]}"; do
  echo "Configuration SSH pour le nœud : $NODE"

  # Copie de la clé publique vers le nœud
  sshpass -p "$NODE_PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no root@"$NODE"

  # Test de connexion
  ssh -o StrictHostKeyChecking=no root@"$NODE" "echo 'Connexion réussie à $NODE via SSH !'"
done

echo "Configuration SSH et installation d'Ansible terminées. Vous pouvez maintenant utiliser Ansible pour gérer vos nœuds."
