#!/bin/bash

PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi

mkdir -p $PROJECT_NAME/{inventory/{dev,prod},playbooks,roles,group_vars,host_vars,files,templates,logs}

# Fichiers par défaut
touch $PROJECT_NAME/ansible.cfg
touch $PROJECT_NAME/inventory/hosts.ini
touch $PROJECT_NAME/playbooks/site.yml
touch $PROJECT_NAME/group_vars/all.yml

echo "Structure de projet $PROJECT_NAME créée avec succès !"
