# Détection automatique des conteneurs contenant "node" dans leur nom
Write-Output "Détection des conteneurs Docker contenant 'node' dans leur nom..."
$containers = docker ps --filter "name=V2-" --format "{{.Names}}"

if (-not $containers) {
    Write-Output "Aucun conteneur 'node' trouvé. Assurez-vous que vos conteneurs sont en cours d'exécution."
    exit 1
}

Write-Output "Conteneurs détectés :"
$containers.Split("`n") | ForEach-Object { Write-Output $_ }

# Parcours des conteneurs pour les configurer
foreach ($container in $containers.Split("`n")) {
    if (-not $container) { continue }
    Write-Output "Configuration du conteneur $container..."

    # Chemin local vers le script de configuration
    $localScriptPath = "C:\Users\mohamed\Documents\Formation\ansible-rzo\vagrant-file\V2-3nodes\configure_node.sh"

    # Vérification de l'existence du fichier de configuration
    if (-not (Test-Path -Path $localScriptPath)) {
        Write-Output "Fichier $localScriptPath introuvable. Vérifiez son emplacement."
        exit 1
    }

    # Copier le script de configuration dans le conteneur
    docker cp $localScriptPath "${container}:/root/" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Échec de la copie du script dans $container"
        continue
    }

    # Rendre le script exécutable
    docker exec $container /bin/bash -c "chmod +x /root/configure_node.sh" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Échec du chmod sur $container"
        continue
    }

    # Exécuter le script dans le conteneur
    docker exec $container /bin/bash -c "/root/configure_node.sh" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Échec de l'exécution du script dans $container"
        continue
    }

    Write-Output "Configuration terminée pour le conteneur $container."
}

Write-Output "Configuration terminée pour tous les conteneurs."
