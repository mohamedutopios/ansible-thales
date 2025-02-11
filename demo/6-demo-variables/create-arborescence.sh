#!/bin/bash

# Nom du projet
PROJECT_NAME="ansible-project"

# Creation des dossiers
mkdir -p "$PROJECT_NAME/inventory"
mkdir -p "$PROJECT_NAME/group_vars"
mkdir -p "$PROJECT_NAME/host_vars"

# Creation des fichiers 
touch "$PROJECT_NAME/ansible.cfg"
touch "$PROJECT_NAME/inventory/hosts.yml"
touch "$PROJECT_NAME/group_vars/all.yml"
touch "$PROJECT_NAME/host_vars/node1.yml"
touch "$PROJECT_NAME/host_vars/node2.yml"
touch "$PROJECT_NAME/host_vars/node3.yml"

echo "Arborescence pour '$PROJECT_NAME' create."
