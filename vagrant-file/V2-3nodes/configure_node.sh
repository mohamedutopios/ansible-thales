#!/bin/bash

# Mise à jour des paquets
apt-get update

# Installation du serveur SSH
apt-get install -y openssh-server nano apt-utils

# Configuration du mot de passe root
echo "root:root" | chpasswd

# Création du répertoire pour sshd
mkdir -p /var/run/sshd

# Autoriser la connexion root par mot de passe
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Démarrage du service SSH
service ssh start

# Affichage de l'état du service SSH
service ssh status
