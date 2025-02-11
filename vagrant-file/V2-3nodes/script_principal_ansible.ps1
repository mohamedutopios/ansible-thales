
$ansibleScriptPath = "C:\Users\mohamed\Documents\Formation\ansible-rzo\vagrant-file\V2-3nodes\configure_ansible_ssh.sh"


# Étape 1 : Détection des conteneurs
Write-Output "Détection des conteneurs Docker contenant 'V2-' dans leur nom..."
$containers = docker ps --filter "name=V2-" --format "{{.Names}}"

if (-not $containers) {
    Write-Output "Aucun conteneur trouvé. Assurez-vous que vos conteneurs sont en cours d'exécution."
    exit 1
}

$ansibleContainer = $containers | Select-String "ansible-inv"

# Étape 4 : Configuration d'Ansible
Write-Output "Démarrage de la configuration d'Ansible sur le conteneur $ansibleContainer..."
docker cp $ansibleScriptPath "${ansibleContainer}:/root/" | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Output "Échec de la copie du script dans $ansibleContainer"
    exit 1
}

docker exec $ansibleContainer /bin/bash -c "chmod +x /root/$(Split-Path -Leaf $ansibleScriptPath)" | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Output "Échec du chmod sur $ansibleContainer"
    exit 1
}

docker exec $ansibleContainer /bin/bash -c "/root/$(Split-Path -Leaf $ansibleScriptPath)" | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Output "Échec de l'exécution du script dans $ansibleContainer"
    exit 1
}

Write-Output "Configuration terminée pour le conteneur Ansible."
Write-Output "Configuration complète terminée pour tous les conteneurs."
